# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'lovediary' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'SwiftLint'
  pod 'lottie-ios', '~> 3.2.1'
  pod 'DeviceKit', '~> 4.0'
  pod 'DKImagePickerController', :subspecs => ['PhotoGallery', 'PhotoEditor']
  pod 'Google-Mobile-Ads-SDK', '7.69.0'
  pod 'Valet'
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
  pod 'FSCalendar'
  pod 'Zip', '~> 2.1'
  pod 'RealmSwift', '4.4.1'

end

post_install do |installer_representation|
    installer_representation.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'
            config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'NO'
            config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
        end
    end
end
