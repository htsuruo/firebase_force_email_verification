import * as functions from 'firebase-functions'

export const beforeCreate = functions.auth
  .user()
  .beforeCreate((user, context) => {
    // TODO(tsuruoka):
  })

export const beforeSignIn = functions.auth
  .user()
  .beforeSignIn((user, context) => {
    // TODO(tsuruoka):
  })
