const functions = require('firebase-functions')
const admin = require('firebase-admin')
const stripe = require("stripe")("sk_test_51LCR7AKoEwOhE0oQ5Q5Uw7Y15LYQtjleokk3icmddmmGrvj9dTPwBs6sdg45HaJR4yc0nf9i43yJtuivdPhGLCUw006tuOn0YS")
admin.initializeApp()
exports.stripePaymentIntentRequest = functions.https.onRequest(async (req, res) => {
    try {
        let customerId;

        //Gets the customer who's email id matches the one sent by the client
        const customerList = await stripe.customers.list({
            email: req.body.email,
            limit: 1
        });
                
        //Checks the if the customer exists, if not creates a new customer
        if (customerList.data.length !== 0) {
            customerId = customerList.data[0].id;
        }
        else {
            const customer = await stripe.customers.create({
                email: req.body.email
            });
            customerId = customer.data.id;
        }

        //Creates a temporary secret key linked with the customer 
        const ephemeralKey = await stripe.ephemeralKeys.create(
            { customer: customerId },
            { apiVersion: '2020-08-27' }
        );

        //Creates a new payment intent with amount passed in from the client
        const paymentIntent = await stripe.paymentIntents.create({
            amount: parseInt(req.body.amount),
            currency: 'usd',
            customer: customerId,
        })

        res.status(200).send({
            paymentIntent: paymentIntent.client_secret,
            ephemeralKey: ephemeralKey.secret,
            customer: customerId,
            success: true,
        })
        
    } catch (error) {
        res.status(404).send({ success: false, error: error.message })
    }
});
exports.sendNotification = functions.firestore
  .document('Contracts/{contractId}/messages/{messageId}')
  .onCreate((snap, context) => {
    console.log('----------------start function--------------------')

    const doc = snap.data()
    console.log(doc)

    const idFrom = doc.senderId
    const idTo = doc.recieverId
    const contentMessage = doc.content

    // Get push token user to (receive)
    admin
      .firestore()
      .collection('users')
      .where('uid', '==', idTo)
      .get()
      .then(querySnapshot => {
        querySnapshot.forEach(userTo => {
          console.log(`Found user to: ${userTo.data().fname} ${userTo.data().lname}`)
          if (userTo.data().pushToken !== idFrom) {
            // Get info user from (sent)
            admin
              .firestore()
              .collection('users')
              .where('uid', '==', idFrom)
              .get()
              .then(querySnapshot2 => {
                querySnapshot2.forEach(doc => {
                  console.log(`Found user from: ${doc.data().fname} ${doc.data().lname}`)
                  const payload = {
                    notification: {
                      title: `You have a message from "${doc.data().fname} ${doc.data().lname}"`,
                      body: contentMessage,
                      badge: '1',
                      sound: 'default'
                    }
                  }
                  // Let push to the target device
                  admin
                    .messaging()
                    .sendToDevice(userTo.data().pushToken, payload)
                    .then(response => {
                      console.log('Successfully sent message:', response)
                    })
                    .catch(error => {
                      console.log('Error sending message:', error)
                    })
                })
              })
          } else {
            console.log('Can not find pushToken target user')
          }
        })
      })
    return null
  })
