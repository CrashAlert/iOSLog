platform :ios, "10.1"
use_frameworks!

workspace "iOSLog"

target "iOSLog" do
    pod "Charts"
    pod "RealmSwift"
    pod "ReachabilitySwift", "~> 3"
    pod "AWSS3", "~> 2.3.3"
    pod "PromiseKit", "~> 4.0"
end

target "iOSLogTests" do

end

target "iOSLogUITests" do

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = "3.0"
    end
  end
end
