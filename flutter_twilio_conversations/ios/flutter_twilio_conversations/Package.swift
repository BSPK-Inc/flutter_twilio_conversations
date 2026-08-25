// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "flutter_twilio_conversations",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "flutter-twilio-conversations", targets: ["flutter_twilio_conversations"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        // 4.0.3–4.0.9 fix shutdown crashes, transport race conditions, and updateToken-vs-shutdown
        // races (BK-6201: SIGABRT/EXC_BAD_ACCESS in TwilioTwilsockLib). Keep both pins moving
        // together: conversations-ios 4.0.9 requires twilsock .upToNextMajor(from: "3.0.2").
        // twilsock 3.x is not published to CocoaPods, so the podspec cannot track these versions —
        // SwiftPM is the supported build path.
        .package(url: "https://github.com/twilio/conversations-ios", exact: "4.0.9"),
        .package(url: "https://github.com/twilio/twilsock-ios", exact: "3.0.2"),
    ],
    targets: [
        .target(
            name: "flutter_twilio_conversations",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "TwilioConversationsClient", package: "conversations-ios"),
                // Linked transitively via TwilioConversationsClient; named explicitly so the
                // version pin above applies to a product this target actually uses.
                .product(name: "TwilioTwilsockLib", package: "twilsock-ios"),
            ]
        )
    ]
)
