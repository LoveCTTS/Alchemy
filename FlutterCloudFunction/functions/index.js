
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
         //사용자의 프로필사진을 push Notification 하고싶은데.. 아래코드시도해보니 안되네.. 다른방법을 찾자.
        /* const myFile = admin.storage().bucket().file('user_image/${newData.sender}/${newData.sender}[0]');
         myFile.getSignedUrl({action: 'read', expires: someDateObj}).then(urls => {
         const signedUrl = urls[0];
         });*/
         const _deviceTokensInGroup = await admin.firestore().collection('groups').get();

         var payload = {
             notification: {
                 title: newData.sender,
                 body: newData.message,
                 sound: 'default',
                 //icon: signedUrl
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
