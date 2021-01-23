
const functions = require('firebase-functions');
const admin = require('firebase-admin');


admin.initializeApp(functions.config().functions);

var newData;

var groups = functions.firestore.collection('groups');
var allGroupDocs = groups.get()

exports.TestMessageTrigger = groups.docs.collection('messages').document('').onCreate(async (snapshot, context) => {
    //



    console.log("Success Creating Group Message!");
    /*if (snapshot.empty) {
             console.log('No Devices');
             return;
         }

         newData = snapshot.data();

         const deviceTokens = await admin.firestore().collection('groups').get();


         var tokens = new Array(10);

         for(var i = 0; i< tokens.length; i++){
             tokens[i] = new Array(10);
         }


         for (var token of deviceTokens.docs) {
             tokens.push(token.data().device_tokens);
         }
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
             const response = await admin.messaging().sendToDevice(tokens, payload);
             console.log('Notification sent successfully');
         } catch (err) {
             console.log(err);
         }*/
});


// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
