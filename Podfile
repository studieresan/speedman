# Global project platform
platform :ios, '11.0'

target 'Studs' do
  # Use dynamic frameworks (Swift - YES)
  use_frameworks!
  # Ignore warnings from pods
  inhibit_all_warnings!

  # Pods for Studs
  pod 'Alamofire', '~> 4.5'
  pod 'SwiftyJSON', '~> 4.0'
  pod '1PasswordExtension', '~> 1.8.5'
  pod 'FirebaseFirestore', '~> 0.10'

  # Dev dependencies
  pod 'SwiftLint'

  target 'StudsTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    plist_buddy = "/usr/libexec/PlistBuddy"
    plist = "Pods/Target Support Files/#{target}/Info.plist"

    puts "Add arm64 to #{target} to make it pass iTC verification."

    `#{plist_buddy} -c "Add UIRequiredDeviceCapabilities array" "#{plist}"`
    `#{plist_buddy} -c "Add UIRequiredDeviceCapabilities:0 string arm64" "#{plist}"`
  end
end
