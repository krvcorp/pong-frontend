# Pong iOS


A fire app.

## Notifications
### Registration

Throughout the app, a user may be suggested to enable notifications. Once the user enables notifications, an FCM token will be generated for that user. At the point of enabling notifications, the iOS app will send a `POST` request to `/api/notifications/register`, with the following schema:

```json
{
  "fcm_token": "SSLCOPWPPPei40330dndlspfjiwofjio"
}
```

It is the responsibility of the API to permanently associate this FCM token with the user.

### Delivery

To deliver push notifications via APNS, the API must use the [Firebase Admin SDK for FCM](https://firebase.google.com/docs/cloud-messaging/server#firebase-admin-sdk-for-fcm). To install the Firebase Admin SDK, follow the [install instructions for Python](https://firebase.google.com/docs/admin/setup). During setup, you will be required to authenticate the API to Firebase via a private key file, which I have shared on our Discord server. Here is a sample configuration snippet:

```python
import firebase_admin
from firebase_admin import credentials

cred = credentials.Certificate("path/to/serviceAccountKey.json")
firebase_admin.initialize_app(cred)
```
You can also configure the SDK via an environment variable:
```bash
export GOOGLE_APPLICATION_CREDENTIALS="/home/user/Downloads/service-account-file.json"
```

To begin sending messages, follow the [buld app server send requests](https://firebase.google.com/docs/cloud-messaging/send-message) guide. TLDR:

```python
# This registration token comes from the client FCM SDKs.
registration_token = 'YOUR_REGISTRATION_TOKEN'

# See documentation on defining a message payload.
message = messaging.Message(
    notification=messaging.Notification(
        title='$GOOG up 1.43% on the day',
        body='$GOOG gained 11.80 points to close at 835.67, up 1.43% on the day.',
    ),
    token=registration_token,
)

# Send a message to the device corresponding to the provided
# registration token.
response = messaging.send(message)
# Response is a message ID string.
print('Successfully sent message:', response)
```
Note that `registration_token` is equivalent to the FCM token obtained from the client.
