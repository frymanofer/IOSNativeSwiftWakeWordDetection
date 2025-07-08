# KeyWordDetectionIOSFramework
This is the IOS framework for KeyWordDetection from DaVoice.io

It is extracted from our react-native integration.

You will find the main xfcframwork under ios/WakeWordNative

Currently to access the framework you can see legacy objective-c examples and .swiftinterface inside the xcframework to see the same API in Swift.
ios/WakeWordNative/WakeWordNative.mm
ios/WakeWordNative/WakeWordNative.h
We will provide easier to consume swift api and swift example asap.

** IMPORTANT **
1. Please add the following files to your project:
"ios/WakeWordNative/models/*"
2. Add this framework to your project: ios/WakeWordNative/KeyWordDetection.xcframework

Swill work in progress to make it Swift Package plug and play.

