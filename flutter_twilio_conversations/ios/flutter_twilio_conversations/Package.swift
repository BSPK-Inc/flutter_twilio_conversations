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
        .package(url: "https://github.com/twilio/conversations-ios", exact: "4.0.2"),
        // conversations-ios requires twilsock with .upToNextMajor(from: "2.0.2"), which would
        // resolve to 2.1.1. CocoaPods pinned it to exactly 2.0.2, so pin it here too to keep the
        // binary set identical to the pods build. Bumping it is a deliberate, separate change.
        .package(url: "https://github.com/twilio/twilsock-ios", exact: "2.0.2"),
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
