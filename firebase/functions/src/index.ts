import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'

import { createTransport, SendMailOptions, SentMessageInfo } from 'nodemailer'
import { AuthUserRecord } from 'firebase-functions/lib/common/providers/identity'

admin.initializeApp()
// const bundleId = 'com.tsuruoka.firebaseForceEmailVerification'
// const packageName = 'com.tsuruoka.firebase_force_email_verification'

export const beforeCreate = functions
  .runWith({ secrets: ['GMAIL_USER', 'GMAIL_PASS'] })
  .auth.user()
  .beforeCreate(async (user, context) => {
    const locale = context.locale
    const email = user.email
    if (email && !user.emailVerified) {
      const link = await admin.auth().generateEmailVerificationLink(email)
      sendCustomVerificationEmail({ user, link, locale })
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

export const sendTestMail = functions
  .runWith({ secrets: ['GMAIL_USER', 'GMAIL_PASS'] })
  .https.onRequest(async (req, resp): Promise<SentMessageInfo> => {
    await MailSender.instance.send({
      to: req.body.email,
      subject: 'Test Mail',
      text: `This is a test message.

これは。

これはテストメッセージです。
`,
    })
    return resp.sendStatus(200)
  })

async function sendCustomVerificationEmail(param: {
  user: AuthUserRecord
  link: string
  locale: string | undefined
}): Promise<SentMessageInfo> {
  // TODO(tsuruoka): 本来はlocaleに応じて表示言語を切り替えるだが省略
  const mail: Mail = {
    to: param.user.email!,
    subject: 'メールアドレスの確認',
    text: `${param.user.displayName} 様

メールアドレスを確認するには、次のリンクをクリックしてください。

${param.link}

このアドレスの確認を依頼していない場合は、このメールを無視してください。

よろしくお願いいたします。
`,
  }
  return await MailSender.instance.send(mail)
}

class MailSender {
  static get instance() {
    return (this._instance ??= new MailSender())
  }
  private static _instance: MailSender | undefined

  async send(mail: Mail): Promise<SentMessageInfo> {
    const transporter = createTransport({
      service: 'gmail',
      auth: {
        user: process.env.GMAIL_USER,
        pass: process.env.GMAIL_PASS,
      },
    })
    const options: SendMailOptions = {
      from: 'noreply@gmail.com',
      to: mail.to,
      subject: mail.subject,
      text: mail.text,
    }
    const response = await transporter.sendMail(options)
    functions.logger.info(`${response.messageId}: ${response.response}`)
    return response
  }
}

interface Mail {
  readonly to: string
  readonly subject: string
  readonly text: string
}
