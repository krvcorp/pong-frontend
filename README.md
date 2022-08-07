# Pong iOS


A fire app.

## Notifications
### Registration

Throughout the app, a user may be suggested to enable notifications. Once the user enables notifications, an FCM token will be generated for that user. At the point of enabling notifications, the iOS app will send a `POST` request to `/api/notifications/register`, with the following body schema:

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
    data={
        'type': 'like',
        'url': 'https://pong.college/posts/DKJWDO3820NKKDHW2920EN',
    },
    token=registration_token,
)

# Send a message to the device corresponding to the provided
# registration token.
response = messaging.send(message)
# Response is a message ID string.
print('Successfully sent message:', response)
```
Note that `registration_token` is equivalent to the FCM token obtained from the client. Also note the schema of `data`:

```json
{
  "type": "like",
  "url": "https://pong.college/posts/DKJWDO3820NKKDHW2920EN",
}
```
The `type` field identifies the type of the notification to the client. Their primary purpose is to identify to the app which graphics should be displayed alongside each notification. Valid notification types are as follows:

| Type | Description |
| ---- | ----------- |
| `upvote` | User receives an arbitrary amount of upvotes in any context. |
| `comment` | User's post receives a new comment. |
| `hot` | User's post reaches the hot section. |
| `top` | User's post reaches the top section. |
| `leader` | User reaches a signficant point on the leaderboard. |
| `message` | User receives an arbitrary amount of messages from a single sender. |
| `reply` | User receives a reply in any non-messaging context. |
| `violation` | User violated community guidelines or terms of service. |
| `generic` | Generic notification type usable in any context. |

Note again that this is not an exhaustive list of possible notifications, but rather broad categories based on graphical groupings.

The `url` field identifies the resource to which the notification refers. Note that in the chart below, domains and protocols are omitted. However, the entire URL should be delivered to the client, as in the example above. Valid notification urls are as follows:

| URL Suffix | Description |
| ---- | ----------- |
| `/posts/{POST_ID}` | Notification refers to a post context. This could be a new upvote, comment, etc. |
| `/messages/{THREAD_ID}` | Notification refers to a message thread with another user. |
| `/stats` | Notification refers to a development on the stats tab. |
| null | Notification does not refer to any resource. |

### Settings

In the app's settings, the user is able to toggle their notifications preferences. As such, the iOS app will send a `PATCH` request to `/api/notifications/settings`, with the following body schema:

```json
{
  "enabled": "false"
}
```

### Testing

In order to facilitate the testing of our notification system, the 
