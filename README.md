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
        'id': '62505215624257b417055bc4',
        'timestamp': '2022-04-08T15:17:41.900560',
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
  "id": "62505215624257b417055bc4",
  "timestamp": "2022-04-08T15:17:41.900560",
  "type": "like",
  "url": "https://pong.college/posts/DKJWDO3820NKKDHW2920EN",
}
```
The `type` field identifies the type of the notification to the client. The primary purpose of `type` is to identify to the app which graphics should be displayed alongside each notification. Valid notification types are as follows:

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

### Reception

*Note: This section is still a work in progress.*

Refer to [receive messages in an Apple app](https://firebase.google.com/docs/cloud-messaging/ios/receive) and [handling notifications and notification-related actions](https://developer.apple.com/documentation/usernotifications/handling_notifications_and_notification-related_actions). TLDR:

```swift
@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
  // Receive displayed notifications for iOS 10 devices.
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
                                -> Void) {
    let userInfo = notification.request.content.userInfo

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)

    // ...

    // Print full message.
    print(userInfo)

    // Change this to your preferred presentation option
    completionHandler([[.alert, .sound]])
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo

    // ...

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)

    // Print full message.
    print(userInfo)

    completionHandler()
  }
}
```

It is still unclear at this point how to access notification metadata (`data` as mentioned in delivery section). It is important that this is acessible in order for `AppDelegate` to be able to direct the user to the proper resource upon a notification tap. Note that `AppDelegate` will handle notifications differently based on the app state (foreground, background, stopped).

### Settings

In the app's settings, the user is able to toggle their notifications preferences. As such, the iOS app will send a `PATCH` request to `/api/notifications/settings`, with the following body schema:

```json
{
  "enabled": false
}
```
A response of HTTP `200 OK` means that the notifications preferences were succesfully updated and the app does not need to re-fetch.

### History

Inside the app, the user should be able to view notification history. The app iOS will do this by sending a `GET` request to `/api/notifications/history` with an empty body. The request should return the notification history pursuant to the following schema:

```json
{
  "history": [
    {
      "notification": {
        "title": "$GOOG up 1.43% on the day",
        "body": "$GOOG gained 11.80 points to close at 835.67, up 1.43% on the day.",
      },
      "data": {
        "id": "62505215624257b417055bc4",
        "timestamp": "2022-04-08T15:17:41.900560",
        "type": "like",
        "url": "https://pong.college/posts/DKJWDO3820NKKDHW2920EN",
      }
    },
    {
      "notification": {
        "title": "Pong is the best app",
        "body": "Download now",
      },
      "data": {
        "id": "6250523a74227b9f561e5bb8",
        "timestamp": "2022-07-11T15:36:00.442669",
        "type": "generic",
        "url": null,
      }
    }
  ]
}
```
Note that the schema of each "notification" in the history list reflects the schema of `messaging.Message` from the delivery section.

### Simulation

In order to facilitate the testing of our notification system, the API should provide a testing utility. Its implementation should provide for the following flags:

| Flag and Argument | Description |
| ---- | ----------- |
| `-u 62cc403b99ef` | Send an arbitrary notification to user with ID `62cc403b99ef`. |
| `-t upvote` | Send an arbitrary notification of type `upvote`. |
| `-r /posts/DTF42069` | Send an arbitrary notification referencing resource `/posts/DTF42069`. |
| `-h "Hello World"` | Send an arbitrary notification with title/header `Hello World`. |
| `-b "Goodbye World"` | Send an arbitrary notification with body `Goodbye World`. |

For example, the following command should send a notification to user `62cc403b99efc110a9a73a55` of type `generic` with a resource reference to `https://pong.college/`:

```bash
python3 notifsim.py -u 62cc403b99efc110a9a73a55 -t generic -r /
```


### Summary

The notifications system can be split into six parts: Registration, Delivery, Reception, Settings, History, and Simulation. The relevant API routes are:

```
POST /api/notifications/register
```

```
PATCH /api/notifications/settings
```

```
GET /api/notifications/history
```

Notification reception is still a work in progress. It is still unclear how to access notification metadata (`data`). It is expected that research on this topic will become much easier once the rest of the notifications system is built.
