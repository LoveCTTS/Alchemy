
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().functions);

var newData;

exports.TestMessageTrigger = functions.firestore.document('groups/{groupId}/messages/{messageId}').onCreate(async (snapshot, context) => {

    if (snapshot.empty) {
             console.log('No Devices');
             return;
         }

         newData = snapshot.data();
         const _deviceTokensInGroup = await admin.firestore().collection('groups').get();

         var payload = {
             notification: {
                 title: 'Push Title',
                 body: 'Push Body',
                 sound: 'default',
             },
             data: {
                 click_action: 'FLUTTER_NOTIFICATION_CLICK',
                 message: newData.message,
             },
         };

         try {

               for (var token of _deviceTokensInGroup.docs) {
                    const response = await admin.messaging().sendToDevice(token.data().deviceTokens, payload);
               }

             console.log('Notification sent successfully');
         } catch (err) {
             console.log(err);
         }
});


// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
