const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');
const base64 = require('base-64');

admin.initializeApp();
const db = admin.firestore();

// Safaricom sandbox credentials
const consumerKey = 'ULceWzBC86evkqJz54f6TZy9LbPFDioePMdocfa5gY0SbGLT';
const consumerSecret = 'Vk0nh2fIghXdeZ2ITGoJjGyyypLzSQkmyPfDS230Wb6FAySiF56Z5G2MkaYG6MCr';
const passkey = 'bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919';
const shortCode = '174379';
const callbackURL = 'https://us-central1-fooddelivery-36ca1.cloudfunctions.net/mpesaCallback';

// STK PUSH REQUEST
exports.stkPush = functions.https.onRequest(async (req, res) => {
  const { phone, amount, name, receipt } = req.body;

  if (!phone || !amount || !name || !receipt) {
    return res.status(400).json({ errorMessage: 'Missing required fields' });
  }

  try {
    const auth = base64.encode(`${consumerKey}:${consumerSecret}`);
    const tokenResponse = await axios.get(
      'https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials',
      {
        headers: { Authorization: `Basic ${auth}` },
      }
    );

    const accessToken = tokenResponse.data.access_token;
    const timestamp = new Date().toISOString().replace(/[^0-9]/g, '').slice(0, -3);
    const password = base64.encode(shortCode + passkey + timestamp);
    const randomRef = `SHLIH-${Math.floor(100000 + Math.random() * 900000)}`;

    console.log('💸 Initiating STK Push for', { phone, amount, name });

    const stkPushResponse = await axios.post(
      'https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest',
      {
        BusinessShortCode: shortCode,
        Password: password,
        Timestamp: timestamp,
        TransactionType: 'CustomerPayBillOnline',
        Amount: Math.ceil(amount),
        PartyA: phone,
        PartyB: shortCode,
        PhoneNumber: phone,
        CallBackURL: callbackURL,
        AccountReference: randomRef,
        TransactionDesc: 'Payment to Shlih Kitchen',
      },
      {
        headers: {
          Authorization: `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
        },
      }
    );

    const checkoutRequestID = stkPushResponse.data.CheckoutRequestID;
    if (checkoutRequestID) {
      // Save both pending receipt and initial request data
      await db.collection('pending_receipts').doc(checkoutRequestID).set({
        receipt,
        phone,
        amount: Math.ceil(amount),
        name,
        accountReference: randomRef,
        status: 'pending',
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });
      
      console.log('✅ Pending receipt saved:', checkoutRequestID);
    }

    console.log('✅ STK Push Sent Successfully:', stkPushResponse.data);

    res.status(200).json({
      ...stkPushResponse.data,
      accountReference: randomRef,
      pushedAmount: Math.ceil(amount),
    });
  } catch (error) {
    console.error('❌ STK Push Error:', error.response?.data || error.message);
    res.status(500).json({
      errorMessage: 'STK Push Failed',
      details: error.response?.data || error.message,
    });
  }
});

// CALLBACK HANDLER
exports.mpesaCallback = functions.https.onRequest(async (req, res) => {
  try {
    // Log the entire request for debugging
    console.log('🔍 Full Callback Request:', JSON.stringify(req.body, null, 2));
    
    const callbackData = req.body;
    const result = callbackData?.Body?.stkCallback;
    
    if (!result) {
      console.error('❌ Invalid callback structure - no stkCallback found');
      return res.status(400).send('Invalid callback structure');
    }

    const metadata = result?.CallbackMetadata?.Item || [];
    const checkoutRequestId = result?.CheckoutRequestID || '';
    const merchantRequestId = result?.MerchantRequestID || '';
    const resultCode = result?.ResultCode;
    const resultDesc = result?.ResultDesc;

    // Extract payment details
    const amount = metadata.find(i => i.Name === 'Amount')?.Value || 0;
    const receiptNo = metadata.find(i => i.Name === 'MpesaReceiptNumber')?.Value || '';
    const phone = metadata.find(i => i.Name === 'PhoneNumber')?.Value || '';
    const transactionDate = metadata.find(i => i.Name === 'TransactionDate')?.Value || '';
    const balance = metadata.find(i => i.Name === 'Balance')?.Value || 0;

    console.log('🔁 M-Pesa Callback Received:', {
      resultCode,
      resultDesc,
      checkoutRequestId,
      receiptNo,
      amount,
      phone
    });

    // Get the original request data
    let originalData = {};
    try {
      const doc = await db.collection('pending_receipts').doc(checkoutRequestId).get();
      if (doc.exists) {
        originalData = doc.data();
        console.log('🧾 Original request data found:', originalData);
      } else {
        console.warn('⚠️ No matching receipt found for:', checkoutRequestId);
      }
    } catch (e) {
      console.error('⚠️ Error retrieving receipt:', e);
    }

    // Prepare payment data
    const paymentData = {
      MerchantRequestID: merchantRequestId,
      CheckoutRequestID: checkoutRequestId,
      Amount: amount,
      MpesaReceiptNumber: receiptNo,
      PhoneNumber: phone,
      TransactionDate: transactionDate,
      Balance: balance,
      ResultCode: resultCode,
      ResultDesc: resultDesc,
      Status: resultCode === 0 ? 'success' : 'failed',
      
      // Include original request data
      OriginalPhone: originalData.phone || '',
      OriginalAmount: originalData.amount || 0,
      CustomerName: originalData.name || '',
      AccountReference: originalData.accountReference || '',
      Receipt: originalData.receipt || 'No receipt attached',
      
      timestamp: admin.firestore.FieldValue.serverTimestamp()
    };

    console.log('💾 About to save payment data:', paymentData);

    // Save to Firestore regardless of success/failure
    try {
      // Save to payments collection
      const paymentRef = await db.collection('payments').add(paymentData);
      console.log('✅ Payment saved to Firestore with ID:', paymentRef.id);
      
      // If successful, also save to orders
      if (resultCode === 0) {
        const orderRef = await db.collection('orders').add(paymentData);
        console.log('✅ Order saved to Firestore with ID:', orderRef.id);
      }
      
      // Clean up pending receipt
      if (originalData && Object.keys(originalData).length > 0) {
        await db.collection('pending_receipts').doc(checkoutRequestId).delete();
        console.log('🧾 Pending receipt deleted.');
      }
      
    } catch (firestoreError) {
      console.error('❌ Firestore Error:', firestoreError);
      console.error('❌ Error details:', firestoreError.message);
      // Don't throw here, we want to acknowledge the callback
    }

    if (resultCode === 0) {
      console.log('✅ Payment successful!');
    } else {
      console.log(`❌ Payment failed: ${resultDesc}`);
    }

    res.status(200).send('Callback processed successfully');
    
  } catch (error) {
    console.error('❌ Callback Error:', error.message);
    console.error('❌ Error stack:', error.stack);
    res.status(500).json({ error: 'Callback handling failed', details: error.message });
  }
});

// Helper function to test callback manually (for debugging)
exports.testCallback = functions.https.onRequest(async (req, res) => {
  const testData = {
    Body: {
      stkCallback: {
        MerchantRequestID: "test-merchant-id",
        CheckoutRequestID: "test-checkout-id",
        ResultCode: 0,
        ResultDesc: "The service request is processed successfully.",
        CallbackMetadata: {
          Item: [
            { Name: "Amount", Value: 1 },
            { Name: "MpesaReceiptNumber", Value: "TEST123456" },
            { Name: "PhoneNumber", Value: "254721904342" },
            { Name: "TransactionDate", Value: 20250712183000 }
          ]
        }
      }
    }
  };
  
  console.log('🧪 Testing callback with data:', testData);
  req.body = testData;
  
  // Call the actual callback function
  return exports.mpesaCallback(req, res);
});