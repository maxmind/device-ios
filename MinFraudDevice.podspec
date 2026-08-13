Pod::Spec.new do |s|
  s.name          = 'MinFraudDevice'
  s.version       = '0.1.1'
  s.summary       = 'MaxMind minFraud device tracking SDK for iOS.'
  s.description   = <<~DESC
    iOS SDK for collecting device data and sending it to MaxMind servers for
    device fingerprinting and fraud detection. Returns a tracking token to use
    with the minFraud API.
  DESC
  s.homepage      = 'https://github.com/maxmind/device-ios'
  s.license       = { :type => 'Apache-2.0 OR MIT',
                      :text => 'Dual-licensed under Apache-2.0 or MIT. ' \
                               'See LICENSE-APACHE and LICENSE-MIT in the repository.' }
  s.author        = 'MaxMind, Inc.'
  # CocoaPods vendors only one auto-detected license file. Preserve both so the
  # dual license in the notice above is complete in the consumer's Pods
  # directory.
  s.preserve_paths = ['LICENSE-APACHE', 'LICENSE-MIT']
  s.source        = { :git => 'https://github.com/maxmind/device-ios.git',
                      :tag => s.version.to_s }
  s.platform      = :ios, '15.0'
  s.swift_version = '5.9'
  s.source_files  = 'Sources/MinFraudDevice/**/*.swift'
  s.resource_bundles = {
    'MinFraudDevice' => ['Sources/MinFraudDevice/Resources/PrivacyInfo.xcprivacy']
  }
end
