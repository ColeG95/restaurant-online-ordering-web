const functions = require("firebase-functions");
const admin = require("firebase-admin");
// const { default: Stripe } = require("stripe");
admin.initializeApp(functions.config().firebase);
const stripe = require("stripe")(functions.config().stripe.testkey);

exports.getEncKey = functions.https.onCall((data, context) => {
  return "kh7vnIYda+4vJCavmO8q+RuuxMUW/6jEPPjVLcQTR0c=";
});

exports.stripeCheckout = functions.https.onCall(async(data, context) => {
  var restaurant = data.restaurant;
  var price = data.total;
  var imageLinkList = data.imageLinkList;
  var email = data.email;
  var orderDocRefEnc = data.orderDocRefEnc;
  var session;

  if (email == null) {
    session = await stripe.checkout.sessions.create({
      payment_method_types: ["card"],
      line_items: [{
        name: restaurant,
        description: `Your ${restaurant} Order!`,
        images: imageLinkList,
        amount: Math.round(price * 100),
        currency: "usd",
        quantity: 1
        }],
      mode: 'payment',
      payment_intent_data: {
        capture_method: "manual",
      },
      success_url: `${data.currentUrl}submitted?order_ref=${orderDocRefEnc}`,
      cancel_url: `${data.currentUrl}${restaurant.toLowerCase()}/menu?order_ref=${orderDocRefEnc}`,
    });
  } else {
    session = await stripe.checkout.sessions.create({
      payment_method_types: ["card"],
      customer_email: email,
      line_items: [{
        name: restaurant,
        description: `Your ${restaurant} Online Order!`,
        images: imageLinkList,
        amount: Math.round(price * 100),
        currency: "usd",
        quantity: 1
        }],
      mode: 'payment',
      payment_intent_data: {
        capture_method: "manual",
      },
      success_url: `${data.currentUrl}submitted?order_ref=${orderDocRefEnc}`,
      cancel_url: `${data.currentUrl}${restaurant.toLowerCase()}/menu?order_ref=${orderDocRefEnc}`,
    });
  }
  return session;
});

// // http request 1
// exports.randomNumber = functions.https.onRequest((request, response) => {
//   const number = Math.round(Math.random() * 100);
//   console.log(number);
//   response.send(number.toString());
// });

// // http request 2
// exports.toGoogle = functions.https.onRequest((request, response) => {
//   response.redirect('www.google.com');
// });

// // auth trigger (new user signup)
// exports.newUserSignupFirestore = functions.auth.user().onCreate((user) => {
//   // for background triggers, you must return a value/promise
//   return admin.firestore().collection("users").doc(user.uid).set({
//     emailTest: user.email,
//     upvotedOn: [],
//   });
// });

// exports.upvote = functions.https.onCall((data, context) => {
//   //check auth state
//   if (context.auth) {
//     throw new functions.https.HttpsError(
//       "unauthenticated",
//       "only authenticated users can add requests"
//     );
//   }
//   // get refs for user doc & request doc
//   const user = admin.firestore.collection("users").doc(context.auth.uid);
//   const request = admin.firestore().collection("requests").doc(data.id);

//   return user.get().then(doc => {
//     // check if user hasnt upvoted already
//     if (doc.data().upvotedOn.includes(data.id)) {
//       throw new functions.https.HttpsError(
//         "failed-precondition",
//         "you can only upvote something once"
//       );
//     }
//     // update user array
//     return user.update({
//       upvotedOn: [...doc.data().upvotedOn, data.id]
//     })
//     .then(() => {
//       // update votes on the ui
//       return request.update({
//         upvotes: admin.firestore.FieldValue.increment(1)
//       });
//     });
//   });
// });

// // auth trigger (new user signup)
// exports.newUserSignup = functions.auth.user().onCreate((user) => {
//   console.log("user created", user.email, user.uid);
// });

// // auth trigger (user deleted)
// exports.userDeleted = functions.auth.user().onDelete((user) => {
//   console.log("user deleted", user.email, user.uid);
// });

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
