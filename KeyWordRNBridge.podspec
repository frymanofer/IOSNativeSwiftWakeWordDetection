require 'json'

Pod::Spec.new do |s|
    s.name         = "WakeWordNative"
    s.version      = "1.0.1" # Update to your package version
    s.summary      = "Wake word detection for IOS Native."
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
  
    s.dependency "onnxruntime-objc", "~> 1.20.0"
    s.preserve_paths = 'docs', 'CHANGELOG.md', 'LICENSE', 'package.json'

  end
  