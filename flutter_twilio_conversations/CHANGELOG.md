## 2.1.0+20

Fixes the native Twilsock transport crashes (SIGABRT / EXC_BAD_ACCESS) tracked as BK-6201.

### Both platforms
* Every method that requires a live client now fails fast with `CLIENT_NOT_INITIALIZED` when the client is missing or shut down, instead of never resolving the Dart `await` (the method-channel result was previously only delivered from inside SDK callbacks that a null client never reached).

### iOS
* Updated Twilio Conversations iOS SDK from 4.0.2 to [4.0.9](https://www.twilio.com/docs/conversations/ios/changelog) (SwiftPM only): upstream fixed shutdown crashes, transport race conditions, and the `updateToken`-vs-`shutdown` race in 4.0.3–4.0.9.
* `ChatClient#shutdown` now tears down every plugin-level reference (client, listener, channel stream handlers) instead of leaving dangling statics.
* `create` shuts down any existing client before replacing it, closing a use-after-free window during re-login.
* `create` and `Messages#sendMessage` report failures via the method-channel result instead of silently hanging the Dart `await`; `sendMessage` fails fast with `CLIENT_NOT_INITIALIZED` when no client exists.
* `sendMessage` media fixes: media without a filename no longer hangs (falls back to `image.jpeg`), the provided filename is honored, the media input stream is no longer force-unwrapped, and media now attaches to the same message as body/attributes.
* `updateToken` resolves the Dart `await` even when the SDK reports failure without an error object.
* **Note:** the CocoaPods path is frozen at Twilio SDK 4.0.2 (Twilio no longer publishes to CocoaPods) and does not carry these fixes. SwiftPM (stable Flutter 3.44+, which introduced the generated FlutterFramework package this plugin depends on) is the supported iOS build path; the Flutter constraint was raised accordingly.

### Android
* `ChatClient#shutdown` / `create` teardown parity with iOS.
* **Breaking:** `create` is no longer idempotent — it tears down and replaces an existing client instead of returning it (the reused client kept a connection authenticated with the previous token). Always call `shutdown` before `create`; after a failed `create` there is no client, so retry `create` rather than assuming the old client survives. The `region` / `deferCA` mismatch validation was removed along with the reuse path.

## 2.0.9+19

### Android
* Fixed issue [#42](https://github.com/Diversido/flutter_twilio_conversations/issues/42) related to `setNoMessagesReadWithResult`
* Fixed issue [#45](https://github.com/Diversido/flutter_twilio_conversations/issues/45) related to the namespace in Gradle builds
* Updated Twilio Conversations Android SDK to [6.1.1](https://www.twilio.com/docs/conversations/android/changelog#conversations-611-september-2-2024)

### Web
* Fixed crash in `unregisterForNotification` if the token is empty
* example: Updated index.html to use the latest Twilio Conversations JavaScript SDK [2.6.1](https://www.twilio.com/docs/conversations/javascript/changelog#conversations-261-february-17-2025)

### General
* Fixed issue [#44](https://github.com/Diversido/flutter_twilio_conversations/issues/44) related to `getMembersList`

## 2.0.8+18
* Fixed issue [#41](https://github.com/Diversido/flutter_twilio_conversations/issues/41)
 
## 2.0.7+17
* Android: Fixed issue [#39](https://github.com/Diversido/flutter_twilio_conversations/issues/39)

## 2.0.6+16
* example: Add unread message count, send typing status when typing and added message indexes for debugging
* WEB: Fix crash with `typing`, `getUnreadMessagesCount`, `connectionStateChanged` and `connectionError` methods
* WEB: Refactored `sendMessage` to improve stability during conversation creation

## 2.0.5+15
* WEB: Update `getLastMessages` to return newest messages first and count backwards

## 2.0.4+14
* INTERFACE: Added optional `webChannel` parameter to `registerForNotification` and `unregisterForNotification` methods
* WEB: Added implementation for `registerForNotification` and `unregisterForNotification` methods
* WEB: Update signatures for `tokenExpired` and `tokenAboutToExpire` events

## 2.0.3+13
* WEB: Fixed JS Mapper - [#35](https://github.com/Diversido/flutter_twilio_conversations/issues/35)

## 2.0.2+12
* WEB: Fixed issue with messages containing Media
* Removed unnecessary logging operations

## 2.0.1+11
* Fixed dependency implementations for android and ios

## 2.0.0+10
* Added web support

## 1.1.7+9

* Update Twilio Conversations Android SDK to [6.0.3](https://www.twilio.com/docs/conversations/android/changelog#conversations-603-october-26-2023)
* Update Twilio Conversations iOS SDK to [4.0.2](https://www.twilio.com/docs/conversations/ios/changelog#conversations-402-august-3-2023)

## 1.1.6+8  
* Fixed issue [#21](https://github.com/Diversido/flutter_twilio_conversations/issues/21)

## 1.1.5+7  
* Fixed issue [#19](https://github.com/Diversido/flutter_twilio_conversations/issues/19)

## 1.1.4+6  
* Fixed issue [#17](https://github.com/Diversido/flutter_twilio_conversations/issues/17)

## 1.1.3+5 — Sep 27, 2023
* Fixed issue [#15](https://github.com/Diversido/flutter_twilio_conversations/issues/15)

## 1.1.2+4 — Sep 27, 2023
* Fixed issue [#12](https://github.com/Diversido/flutter_twilio_conversations/issues/12)

## 1.1.1+3 — Sep 18, 2023
* Fixed issue [#11](https://github.com/Diversido/flutter_twilio_conversations/issues/11)

## 1.1.0+2 — Jul 28, 2023

* Fixed tons of issues: [#1](https://github.com/Diversido/flutter_twilio_conversations/pull/1), [#2](https://github.com/Diversido/flutter_twilio_conversations/pull/2), [#3](https://github.com/Diversido/flutter_twilio_conversations/pull/3), [#4](https://github.com/Diversido/flutter_twilio_conversations/pull/4), [#5](https://github.com/Diversido/flutter_twilio_conversations/pull/5), [#6](https://github.com/Diversido/flutter_twilio_conversations/pull/6), [#7](https://github.com/Diversido/flutter_twilio_conversations/pull/7) thanks to the [@martintrollip](https://github.com/martintrollip) ❤️
  
## 1.0.0+1 — Jan 19, 2023

* First release, based on [twilio_programmable_chat v0.1.1+7](https://pub.dev/packages/twilio_programmable_chat/versions/0.1.1+7)