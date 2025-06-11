require 'json'

Pod::Spec.new do |s|
    s.name         = "WakeWordNative"
    s.version      = "1.0.1" # Update to your package version
    s.summary      = "Wake word detection for React Native."
    s.description  = <<-DESC
                     A React Native module for wake word detection .
                     DESC
    s.homepage     = "https://github.com/frymanofer/KeywordsDetectionAndroidLibrary.git" # Update with your repo URL
    s.license      = { :type => "MIT" } # Update if different
    s.author       = { "Your Name" => "ofer@davoice.io" } # Update with your info
    s.platform     = :ios, "11"
#   s.source       = { :git => "https://github.com/frymanofer/KeywordsDetectionAndroidLibrary.git", :tag => s.version.to_s } # Update accordingly
    s.source       = { :path => "." }

#    s.source_files = "ios/*.{h,m,mm,swift}"
    s.resources    = "ios/WakeWordNative/models/*"
    s.source_files = 'ios/WakeWordNative/WakeWordNative.h', 'ios/WakeWordNative/WakeWordNative.mm'

    #s.static_framework = true

    s.vendored_frameworks = "ios/WakeWordNative/KeyWordDetection.xcframework"
  
    s.dependency "React-Core"
    s.dependency "onnxruntime-objc", "~> 1.20.0"
    s.preserve_paths = 'docs', 'CHANGELOG.md', 'LICENSE', 'package.json'

  end
  
  # /Users/oferfryman/projects/porcuSafe/node_modules/react-native-background-fetch/RNBackgroundFetch.podspec
  # require 'json'

  # package = JSON.parse(File.read(File.join(__dir__, 'package.json')))
  
  # Pod::Spec.new do |s|
  #   s.cocoapods_version   = '>= 1.10.0'
  #   s.name                = 'RNBackgroundFetch'
  #   s.version             = package['version']
  #   s.summary             = package['description']
  #   s.description         = <<-DESC
  #     iOS BackgroundFetch API Implementation
  #   DESC
  #   s.homepage            = package['homepage']
  #   s.license             = package['license']
  #   s.author              = package['author']
  #   s.source              = { :git => 'https://github.com/transistorsoft/react-native-background-fetch.git', :tag => s.version }
  
  #   s.requires_arc        = true
  #   s.platform            = :ios, '8.0'
  
  #   s.dependency 'React-Core'
  #   s.preserve_paths      = 'docs', 'CHANGELOG.md', 'LICENSE', 'package.json', 'RNBackgroundFetch.ios.js'
  #   s.source_files        = 'ios/RNBackgroundFetch/RNBackgroundFetch.h', 'ios/RNBackgroundFetch/RNBackgroundFetch.m'
  #   s.vendored_frameworks = 'ios/RNBackgroundFetch/TSBackgroundFetch.xcframework'
  #   s.resource_bundles = {'TSBackgroundFetchPrivacy' => ['ios/Resources/PrivacyInfo.xcprivacy']}
  # end
  