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

// STK PUSH REQUEST - Save temporary data to payments, userEmail optional
exports.stkPush = functions.https.onRequest(async (req, res) => {
  // Add CORS headers
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET, POST');
  res.set('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }

  // Log the incoming request for debugging
  console.log('🔍 Incoming request body:', JSON.stringify(req.body, null, 2));
  console.log('🔍 Request headers:', JSON.stringify(req.headers, null, 2));

  // Extract fields
  const { phone, amount, name, receipt, userEmail } = req.body;

  // Detailed validation with logging
  console.log('📋 Received fields:', { 
    phone: phone || 'MISSING', 
    amount: amount || 'MISSING', 
    name: name || 'MISSING', 
    receipt: receipt ? receipt.substring(0, 50) + '...' : 'MISSING',
    userEmail: userEmail || 'NOT PROVIDED'
  });

  // Validate required fields (userEmail is optional)
  if (!phone || !amount || !name || !receipt) {
    const missingFields = [];
    if (!phone) missingFields.push('phone');
    if (!amount) missingFields.push('amount');
    if (!name) missingFields.push('name');
    if (!receipt) missingFields.push('receipt');
    
    console.log('❌ Missing required fields:', missingFields);
    return res.status(400).json({ 
      errorMessage: `Missing required fields: ${missingFields.join(', ')}`,
      received: { phone: !!phone, amount: !!amount, name: !!name, receipt: !!receipt, userEmail: !!userEmail }
    });
  }

  // Clean and validate phone number
  const cleanPhone = phone.toString().replace(/\D/g, '');
  if (!cleanPhone.startsWith('254') || cleanPhone.length !== 12) {
    console.log('❌ Invalid phone format. Received:', phone, 'Cleaned:', cleanPhone);
    return res.status(400).json({ 
      errorMessage: 'Phone number must be in format 254XXXXXXXXX (12 digits)',
      received: phone,
      cleaned: cleanPhone
    });
  }

  // Validate amount
  const numAmount = parseFloat(amount);
  if (isNaN(numAmount) || numAmount < 1) {
    console.log('❌ Invalid amount:', amount);
    return res.status(400).json({ 
      errorMessage: 'Amount must be at least 1 KES',
      received: amount
    });
  }

  try {
    console.log('🔐 Getting access token...');
    const auth = base64.encode(`${consumerKey}:${consumerSecret}`);
    const tokenResponse = await axios.get(
      'https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials',
      {
        headers: { Authorization: `Basic ${auth}` },
      }
    );

    const accessToken = tokenResponse.data.access_token;
    console.log('✅ Access token received');

    const timestamp = new Date().toISOString().replace(/[^0-9]/g, '').slice(0, -3);
    const password = base64.encode(shortCode + passkey + timestamp);
    const randomRef = `SHLIH-${Math.floor(100000 + Math.random() * 900000)}`;

    console.log('💸 Initiating STK Push:', { 
      phone: cleanPhone, 
      amount: Math.ceil(numAmount), 
      name, 
      accountRef: randomRef 
    });

    const stkPushPayload = {
      BusinessShortCode: shortCode,
      Password: password,
      Timestamp: timestamp,
      TransactionType: 'CustomerPayBillOnline',
      Amount: Math.ceil(numAmount),
      PartyA: cleanPhone,
      PartyB: shortCode,
      PhoneNumber: cleanPhone,
      CallBackURL: callbackURL,
      AccountReference: randomRef,
      TransactionDesc: `Payment from ${name} to Shlih Kitchen`,
    };

    console.log('📤 STK Push payload:', JSON.stringify(stkPushPayload, null, 2));

    const stkPushResponse = await axios.post(
      'https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest',
      stkPushPayload,
      {
        headers: {
          Authorization: `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
        },
      }
    );

    console.log('📥 STK Push response:', JSON.stringify(stkPushResponse.data, null, 2));

    const checkoutRequestID = stkPushResponse.data.CheckoutRequestID;
    const responseCode = stkPushResponse.data.ResponseCode;
    
    console.log('📋 STK Push Response Details:', {
      CheckoutRequestID: checkoutRequestID,
      ResponseCode: responseCode,
      ResponseDescription: stkPushResponse.data.ResponseDescription
    });

    // Check if STK Push was actually successful
    if (responseCode !== "0") {
      console.log('❌ STK Push failed with response code:', responseCode);
      return res.status(400).json({
        success: false,
        errorMessage: stkPushResponse.data.ResponseDescription || 'STK Push failed',
        ResponseCode: responseCode,
        details: stkPushResponse.data
      });
    }

    // Save temporary data to payments collection
    if (checkoutRequestID) {
      try {
        await db.collection('payments').doc(checkoutRequestID).set({
          orderId: checkoutRequestID,
          userEmail: userEmail || 'not-provided@example.com',
          orders: receipt,
          status: 'initiating',
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });
        console.log('✅ Temporary payment saved with orderId:', checkoutRequestID, 'userEmail:', userEmail || 'not-provided@example.com');
      } catch (firestoreError) {
        console.error('⚠️ Firestore save error (but STK Push was successful):', firestoreError);
        // Don't fail the whole request if Firestore fails, STK Push already succeeded
      }
    }

    console.log('✅ STK Push Sent Successfully');

    res.status(200).json({
      success: true,
      message: 'STK Push sent successfully',
      CheckoutRequestID: checkoutRequestID,
      MerchantRequestID: stkPushResponse.data.MerchantRequestID,
      ResponseCode: responseCode,
      ResponseDescription: stkPushResponse.data.ResponseDescription,
      CustomerMessage: stkPushResponse.data.CustomerMessage,
      accountReference: randomRef,
      pushedAmount: Math.ceil(numAmount),
    });
  } catch (error) {
    console.error('❌ STK Push Error:', error.response?.data || error.message);
    console.error('❌ Full error:', error);
    
    let errorMessage = 'STK Push Failed';
    let userFriendlyMessage = '';
    
    if (error.response?.data) {
      const mpesaError = error.response.data;
      console.log('🔍 M-Pesa Error Details:', JSON.stringify(mpesaError, null, 2));
      
      if (mpesaError.errorCode === '500.001.1001') {
        userFriendlyMessage = '⏰ Please wait 2-3 minutes before trying again. M-Pesa rate limit reached.';
      } else if (mpesaError.errorMessage?.includes('duplicate')) {
        userFriendlyMessage = '🔄 Duplicate transaction detected. Please wait and try with a different amount.';
      } else if (mpesaError.errorMessage?.includes('rate')) {
        userFriendlyMessage = '⏰ Too many requests. Please wait 2-3 minutes and try again.';
      } else if (mpesaError.errorCode === '400.002.02') {
        userFriendlyMessage = '📱 Invalid phone number format. Please check and try again.';
      } else {
        errorMessage = mpesaError.errorMessage || mpesaError.message || errorMessage;
        userFriendlyMessage = `❌ ${errorMessage}`;
      }
    }

    res.status(500).json({
      success: false,
      errorMessage: userFriendlyMessage || errorMessage,
      details: error.response?.data || error.message,
      suggestion: 'Wait 2-3 minutes, then try again with a slightly different amount (e.g., KES 2.00 instead of KES 1.98)'
    });
  }
});

// CALLBACK HANDLER - Finalize payments and save to orders on success
exports.mpesaCallback = functions.https.onRequest(async (req, res) => {
  try {
    console.log('🔍 Full Callback Request:', JSON.stringify(req.body, null, 2));
    
    const callbackData = req.body;
    const result = callbackData?.Body?.stkCallback;
    
    if (!result) {
      console.error('❌ Invalid callback structure - no stkCallback found');
      return res.status(200).send('OK');
    }

    const metadata = result?.CallbackMetadata?.Item || [];
    const checkoutRequestId = result?.CheckoutRequestID || '';
    const resultCode = result?.ResultCode;
    const resultDesc = result?.ResultDesc;

    const amount = metadata.find(i => i.Name === 'Amount')?.Value || 0;
    const receiptNo = metadata.find(i => i.Name === 'MpesaReceiptNumber')?.Value || '';
    const phone = metadata.find(i => i.Name === 'PhoneNumber')?.Value || '';
    const transactionDate = metadata.find(i => i.Name === 'TransactionDate')?.Value || '';

    console.log('🔁 M-Pesa Callback Received:', {
      resultCode,
      resultDesc,
      checkoutRequestId,
      receiptNo,
      amount,
      phone
    });

    // Retrieve temporary payment data
    let userEmail = 'not-provided@example.com';
    let orders = 'unknown';
    try {
      const paymentDoc = await db.collection('payments').doc(checkoutRequestId).get();
      if (paymentDoc.exists) {
        userEmail = paymentDoc.data().userEmail || 'not-provided@example.com';
        orders = paymentDoc.data().orders || 'unknown';
        console.log('🧾 Temporary payment data found with userEmail:', userEmail, 'orders:', orders);
      } else {
        console.warn('⚠️ No temporary payment found for:', checkoutRequestId);
      }
    } catch (e) {
      console.error('⚠️ Error retrieving temporary payment:', e);
    }

    if (resultCode === 0) {
      try {
        const paymentData = {
          MpesaReceiptNumber: receiptNo,
          userEmail,
          orders,
          orderId: checkoutRequestId,
          delivery_status: 'pending',
          estimatedDeliveryTime: new Date(Date.now() + 45 * 60 * 1000),
          date: admin.firestore.FieldValue.serverTimestamp(),
        };

        console.log('💾 About to save payment with orderId:', checkoutRequestId);
        await db.collection('payments').doc(checkoutRequestId).set(paymentData);
        console.log('✅ Payment saved with orderId:', checkoutRequestId);

        const orderData = {
          MpesaReceiptNumber: receiptNo,
          userEmail,
          orders,
          orderId: checkoutRequestId,
          delivery_status: 'pending',
          estimatedDeliveryTime: new Date(Date.now() + 45 * 60 * 1000),
          date: admin.firestore.FieldValue.serverTimestamp(),
        };

        console.log('💾 About to save order with orderId:', checkoutRequestId);
        await db.collection('orders').doc(checkoutRequestId).set(orderData);
        console.log('✅ Order saved with orderId:', checkoutRequestId);
      } catch (firestoreError) {
        console.error('❌ Firestore Error:', firestoreError);
      }
    } else {
      console.log(`❌ Payment failed (${resultCode}): ${resultDesc}. Deleting temporary payment.`);
      try {
        await db.collection('payments').doc(checkoutRequestId).delete();
        console.log('🗑️ Temporary payment deleted for orderId:', checkoutRequestId);
      } catch (e) {
        console.error('⚠️ Error deleting temporary payment:', e);
      }
    }

    res.status(200).send('OK');
    
  } catch (error) {
    console.error('❌ Callback Error:', error.message);
    console.error('❌ Error stack:', error.stack);
    res.status(200).send('OK');
  }
});