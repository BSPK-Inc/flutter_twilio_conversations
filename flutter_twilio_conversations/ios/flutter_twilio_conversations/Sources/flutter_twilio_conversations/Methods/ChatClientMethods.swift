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
                if let error = result.error as NSError? {
                    SwiftTwilioConversationsPlugin.debug("ChatClientMethods.updateToken => onError: \(error)")
                    flutterResult(FlutterError(code: "\(error.code)", message: "\(error.description)", details: nil))
                }
            }
            } as TCHCompletion)
    }

    public static func shutdown(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        tearDownClient()
        result(nil)
    }

    /// Shuts down the current client (if any) and clears every plugin-level reference to it.
    /// The SDK's shutdown must run while our references are still in place: dropping the last
    /// strong reference to a client with a live twilsock transport is what caused the
    /// use-after-free crashes in TwilioTwilsockLib (BK-6201).
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
