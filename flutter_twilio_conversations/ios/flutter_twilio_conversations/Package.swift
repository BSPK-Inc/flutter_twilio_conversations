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
        // races (BK-6201: SIGABRT/EXC_BAD_ACCESS in TwilioTwilsockLib). A range rather than an
        // exact pin so downstream graphs stay resolvable; consumers pin exact versions in their
        // committed Package.resolved. Twilsock comes in transitively (4.0.9 requires
        // .upToNextMajor(from: "3.0.2")). SwiftPM is the only iOS build path: the CocoaPods
        // podspec was removed because Twilio stopped publishing after 4.0.2, so a pods build
        // could only ever produce the crashing SDK.
        .package(url: "https://github.com/twilio/conversations-ios", .upToNextMinor(from: "4.0.9")),
    ],
    targets: [
        .target(
            name: "flutter_twilio_conversations",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "TwilioConversationsClient", package: "conversations-ios"),
            ]
        )
    ]
)
