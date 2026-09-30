# YXT SDK Demo - CocoaPods 依赖
# Spec 源需包含伯索开放平台私有 Specs
source "https://cdn.cocoapods.org/"
source "https://github.com/PlasoOpenPlatform/plaso-open-specs.git"

platform :ios, "13.0"
use_frameworks!

target "YXTSDKDemo" do
  pod "LAME-xcframework", "~> 3.100.3"
  pod "PlasoFeaturedSDK", "0.5.1"
  pod "PlasoStyleUpime", "1.70.103"
  pod "PlasoInnerModule", "1.70.103"
  pod "Upimet", "0.9.1701011"

  # 第三方SDK PlasoFeaturedSDK 0.5.1 保持一致。
  pod "AliPlayerSDK_iOS", "7.12.0-54557273"
  pod "AliPlayerSDK_iOS_ARTC", "7.12.0"
  pod "RtsSDK", "7.12.0"
 end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "12.0"
      config.build_settings["ENABLE_BITCODE"] = "NO"
      # SDK 模拟器仅提供 x86_64 slice，Apple Silicon 上需排除 arm64 模拟器架构
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    end
  end

  # 传递依赖中部分二进制仍含 bitcode，需剥离以兼容新版 Xcode
  bitcode_strip_path = `xcrun --find bitcode_strip`.chomp
  framework_paths = [
    "Pods/RtsSDK/RtsSDK.framework/RtsSDK",
    "Pods/AliPlayerSDK_iOS/AliyunMediaDownloader.framework/AliyunMediaDownloader",
    "Pods/AliPlayerSDK_iOS/AliyunPlayer.framework/AliyunPlayer",
    "Pods/AliPlayerSDK_iOS/alivcffmpeg.framework/alivcffmpeg",
    "Pods/AliPlayerSDK_iOS_ARTC/artcSource.framework/artcSource"
  ]
  framework_paths.each do |relative_path|
    framework_path = File.join(Dir.pwd, relative_path)
    next unless File.exist?(framework_path)
    command = "#{bitcode_strip_path} #{framework_path} -r -o #{framework_path}"
    puts "Stripping bitcode: #{command}"
    system(command)
  end
end
