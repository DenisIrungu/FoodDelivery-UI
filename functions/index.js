const admin = require('firebase-admin');
admin.initializeApp();
const db = admin.firestore();

const functions = require('firebase-functions');
const axios = require('axios');
const base64 = require('base-64');

// Safaricom sandbox credentials
const consumerKey = 'ULceWzBC86evkqJz54f6TZy9LbPFDioePMdocfa5gY0SbGLT';
const consumerSecret = 'Vk0nh2fIghXdeZ2ITGoJjGyyypLzSQkmyPfDS230Wb6FAySiF56Z5G2MkaYG6MCr';
const passkey = 'bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919';
const shortCode = '174379';
const callbackURL = 'https://us-central1-fooddelivery-36ca1.cloudfunctions.net/mpesaCallback';

exports.stkPush = functions.https.onRequest(async (req, res) => {
  const { phone, amount, name } = req.body;

  if (!phone || !amount || !name) {
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

    res.status(200).json({
      ...stkPushResponse.data,
      accountReference: randomRef,
      pushedAmount: Math.ceil(amount),
    });
  } catch (error) {
    console.error('M-Pesa STK Push Error:', (error.response?.data || error.message));
    res.status(500).json({
      errorMessage: 'STK Push Failed',
      details: error.response?.data || error.message,
    });
  }
});

exports.mpesaCallback = functions.https.onRequest(async (req, res) => {
  try {
    const callbackData = req.body;
    console.log('🔁 M-Pesa Callback Received:', JSON.stringify(callbackData, null, 2));

    const result = callbackData?.Body?.stkCallback;

    const payment = {
      MerchantRequestID: result?.MerchantRequestID,
      CheckoutRequestID: result?.CheckoutRequestID,
      ResultCode: result?.ResultCode,
      ResultDesc: result?.ResultDesc,
      Amount: result?.CallbackMetadata?.Item?.find(i => i.Name === 'Amount')?.Value || 0,
      MpesaReceiptNumber: result?.CallbackMetadata?.Item?.find(i => i.Name === 'MpesaReceiptNumber')?.Value || '',
      TransactionDate: result?.CallbackMetadata?.Item?.find(i => i.Name === 'TransactionDate')?.Value || '',
      PhoneNumber: result?.CallbackMetadata?.Item?.find(i => i.Name === 'PhoneNumber')?.Value || '',
      timestamp: admin.firestore.FieldValue.serverTimestamp()
    };

    await db.collection('payments').add(payment);
    console.log('💾 Payment saved to Firestore');
    res.status(200).send('Callback processed & saved');
  } catch (error) {
    console.error('❌ Callback Error:', error);
    res.status(500).json({ error: 'Error saving callback', details: error.message });
  }
});
