# YXT SDK Demo（iOS）

伯索云课堂（YXT）iOS SDK 对外接入示例工程。演示从授权配置、OpenAPI 获取 Token，到嵌入课堂、作业等 SDK 页面的完整流程。

## 环境要求

- macOS + Xcode 14+（建议 Xcode 15+）
- CocoaPods 1.12+
- iOS 部署目标：**13.0**
- 伯索开放平台账号，以及分配的 **AppId**、**SignKey**、测试用户 **loginName**

> **模拟器说明：** 当前 SDK 模拟器二进制为 `x86_64`。在 Apple Silicon Mac 上，工程已配置 `EXCLUDED_ARCHS[sdk=iphonesimulator*]=arm64`，请使用 Rosetta 模拟器或真机调试。

## 快速开始

```bash
cd YXTSDK-iOS-Demo

# 若尚未生成 Xcode 工程
xcodegen generate

# 安装 SDK 依赖（需能访问伯索 Specs）
pod install

# 打开工作区（务必打开 .xcworkspace，不要打开 .xcodeproj）
open YXTSDKDemo.xcworkspace
```

在 Xcode 中选择真机或模拟器运行 `YXTSDKDemo` Scheme。

## 使用流程

1. **Splash**：启动闪屏，若本地 Token 未过期会尝试自动登录。
2. **授权配置**（SwiftUI）
   - 填写 AppId、SignKey、用户名（loginName）
   - 选择用户类型（学生 / 教师 / 助教）
   - 点击「登录授权」
3. **主界面**（UIKit Tab）
   - 课堂（iPhone：`YXTLiveClassiPhoneVC`；iPad：`YXTRealTimeMainVC`）
   - 作业
   - 我的（会话信息与退出登录）

## Pod 依赖

```ruby
  pod "LAME-xcframework", "~> 3.100.3"
  pod "PlasoFeaturedSDK", "0.5.1"
  pod "PlasoStyleUpime", "1.70.103"
  pod "PlasoInnerModule", "1.70.103"
  pod "Upimet", "0.9.1701011"
  pod "AliPlayerSDK_iOS", "7.12.0-54557273"
  pod "AliPlayerSDK_iOS_ARTC", "7.12.0"
  pod "RtsSDK", "7.12.0"
```



Specs 源：

```ruby
source 'https://cdn.cocoapods.org/'
source 'https://github.com/PlasoOpenPlatform/plaso-open-specs.git'
```

## 文档

- [接入说明.md](./接入说明.md)：初始化顺序、签名、getToken、页面嵌入与注意事项
- 开放平台：[https://open.plaso.cn/](https://open.plaso.cn/)
- 用户 Token API：[https://open.plaso.cn/api-120430699](https://open.plaso.cn/api-120430699)

## 目录结构

```text
YXTSDKDemo/
  App/                 入口与路由
  Core/Auth/           签名、Token、会话、环境
  Core/Network/        URLSession 封装
  Core/HUD/            自绘 Loading / Toast
  Core/SDK/            SDK 初始化
  Features/Splash/     启动页（SwiftUI）
  Features/Auth/       授权配置（SwiftUI）
  Features/Main/       Tab 容器（UIKit）
  Features/Homework/   作业
  Features/Mine/       我的
  Resources/           Info.plist、yxt.html、资源
```

## 说明

- Demo 在客户端完成 HMAC-SHA1 签名，仅便于联调。建议:**正式环境请在服务端签名，勿将 SignKey 打入客户端包。**
