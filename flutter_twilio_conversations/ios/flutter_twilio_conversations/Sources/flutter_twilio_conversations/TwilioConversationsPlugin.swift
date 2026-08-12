import Flutter

/// Entry point named after `pluginClass` in pubspec.yaml.
///
/// `GeneratedPluginRegistrant.m` calls `[TwilioConversationsPlugin registerWithRegistrar:]`,
/// resolving this class through `@import flutter_twilio_conversations`. This replaces the former
/// `TwilioConversationsPlugin.h`/`.m` shim, which cannot live in a Swift package target.
public class TwilioConversationsPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        SwiftTwilioConversationsPlugin.register(with: registrar)
    }
}
