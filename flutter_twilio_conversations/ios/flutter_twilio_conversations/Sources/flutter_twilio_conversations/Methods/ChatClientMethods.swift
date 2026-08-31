import Flutter
import Foundation
import TwilioConversationsClient

public class ChatClientMethods {
    public static func updateToken(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?] else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        guard let token = arguments["token"] as? String else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'token' parameter", details: nil))
        }

        let flutterResult = result
        SwiftTwilioConversationsPlugin.chatListener?.chatClient?.updateToken(token, completion: {(result: TCHResult) -> Void in
            if result.isSuccessful {
                SwiftTwilioConversationsPlugin.debug("ChatClientMethods.updateToken => onSuccess")
                flutterResult(nil)
            } else {
                // Always resolve the Dart await, even when the SDK reports failure
                // without an error object.
                let error = result.error as NSError?
                SwiftTwilioConversationsPlugin.debug("ChatClientMethods.updateToken => onError: \(String(describing: error))")
                flutterResult(FlutterError(
                    code: "\(error?.code ?? 0)",
                    message: "Failed to update token: \(error?.description ?? "unknown error")",
                    details: nil))
            }
            } as TCHCompletion)
    }

    public static func shutdown(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        tearDownClient()
        result(nil)
    }

    /// Shuts down the current client (if any) and then clears every plugin-level reference to
    /// it, so later method calls fail fast instead of dereferencing a dead client. Requesting
    /// shutdown() before dropping our references gives the SDK an orderly teardown, but the
    /// transport teardown continues asynchronously on the SDK's own queues — protection against
    /// the over-release inside shutdownTransport() (twilio/conversations-ios#54, BK-6201) comes
    /// from the SDK bump to 4.0.9, not from this ordering.
    ///
    /// Note for Dart-side callers: the plugin's Dart layer caches Channel objects statically and
    /// only clears them in ChatClient.shutdown(). Always call shutdown() before create() —
    /// create() tears down any leftover native client as a safety net, but Dart channels that
    /// survive it will have dead native stream handlers and silently stop receiving events.
    public static func tearDownClient() {
        SwiftTwilioConversationsPlugin.debug("ChatClientMethods.tearDownClient => shutting down client")
        SwiftTwilioConversationsPlugin.chatListener?.chatClient?.shutdown()
        SwiftTwilioConversationsPlugin.chatListener?.chatClient = nil
        SwiftTwilioConversationsPlugin.chatListener = nil

        for (_, eventChannel) in SwiftTwilioConversationsPlugin.channelChannels {
            eventChannel.setStreamHandler(nil)
        }
        SwiftTwilioConversationsPlugin.channelChannels.removeAll()
        SwiftTwilioConversationsPlugin.channelListeners.removeAll()
    }
}
