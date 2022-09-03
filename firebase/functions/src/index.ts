import * as functions from 'firebase-functions'
// import * as admin from 'firebase-admin'

// import { createTransport, SendMailOptions, SentMessageInfo } from 'nodemailer'

// const bundleId = 'com.tsuruoka.firebaseForceEmailVerification'
// const packageName = 'com.tsuruoka.firebase_force_email_verification'

export const beforeCreate = functions.auth
  .user()
  .beforeCreate(async (user, context) => {
    if (user.email && !user.emailVerified) {
      // 本来は確認用のメールを送信するべきだがSMTPサーバを用意したりメール送信の処理は本質ではないのでなので省略
      throw new functions.auth.HttpsError(
        'invalid-argument',
        `"${user.email}" required verification.`
      )
    }
  })

export const beforeSignIn = functions.auth.user().beforeSignIn((user, _) => {
  if (user.email && !user.emailVerified) {
    throw new functions.auth.HttpsError(
      'invalid-argument',
      `"${user.email}" needs to be verified before access is granted.`
    )
  }
})

// export const sendCustomVerificationEmail = functions.https.onRequest(
//   async (_, __): Promise<SentMessageInfo> => {
//     const transporter = createTransport({
//       host: 'smtp.gmail.com',
//       port: 465,
//       secure: true, // SSL
//       auth: {
//         user: 'hideki.tsuruoka.fb@gmail.com',
//         pass: 'hideki226fb',
//       },
//     })
//     const options: SendMailOptions = {
//       from: 'hideki.tsuruoka.fb@gmail.com',
//       to: 'haribari920@gmail.com',
//       subject: '{件名}',
//       text: '{本文}',
//     }
//     const response = await transporter.sendMail(options)
//     functions.logger.info(`${response.messageId}: ${response.response}`)
//     if (response.rejected) {
//       functions.logger.warn('sendCustomVerificationEmail error.')
//     }
//     return response
//   }
// )
