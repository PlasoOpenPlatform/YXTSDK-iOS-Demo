//
//  PlasoSDKBootstrap.swift
//  YXTSDKDemo
//
//  YXT SDK 初始化与登录用户拉取。
//

import Foundation
import UIKit
import PlasoCommonSDK
import PlasoFeatureWeb
import PlasoLiveMini

/// SDK 初始化与业务入口封装。
final class PlasoSDKBootstrap: NSObject {

    static let shared = PlasoSDKBootstrap()

    /// 是否已经完成 SDK 初始化
    private(set) var isInitialized = false

    private override init() {
        super.init()
    }

    /// 在授权配置选定环境后初始化 SDK。
    /// 顺序：写环境键 → switchToOemPlatform → updatePreferServerHost → initSDK → 注册 DI。
    func initializeIfNeeded() {
        if isInitialized {
            // 已初始化时仅刷新业务域名，避免进程内热切换 firstHost 不一致
            let host = SessionStore.shared.environment.serviceHostURL
            AppConfig.updatePreferServerHost(host)
            ServletHelper.sharedInstance().serviceHost = AppConfig.serviceHost()
            return
        }

        SessionStore.shared.applyEnvironmentBeforeSDKInit()
        copyYXTHtmlToTmp()

        // 先切 OEM，再覆盖 serviceHost，避免 switch(toOemPlatform:) 把域名写回 firstHost
        AppConfig.shareInstance().switch(toOemPlatform: "plaso")
        let host = SessionStore.shared.environment.serviceHostURL
        AppConfig.updatePreferServerHost(host)

        PlasoSDK.initSDK([
            "useInClientSDK": "1",
            "iosversion": "5.68.200"
        ])

        YXTThemeManager.switch(to: .default)
        // 无自有历史页，不显示「往期课程>」。有外部历史页并实现 openExtHisotry 后再设为 true。
        PlasoSDKConfig.setEnableSDKOtherHistory(false)
        // FollowLab 走实验室/机构配置。Off 全部关闭，On 全部打开。
        PlasoSDKConfig.setNativePlayerSwitch(.off)
        PlasoSDKConfig.setNativeUpimeSwitch(.off)
        PMediatorWebDI.register()
        PMediatorLiveMiniDI.register()
        PMediatorDemo.register()

        isInitialized = true
    }

    /// 使用 bstoken 拉取用户信息并写入 `PlasoerUser.current`
    func requestUser(
        token: String,
        completion: @escaping (Result<PlasoerUser, Error>) -> Void
    ) {
        initializeIfNeeded()
        // 经 Bridge 包装，回调参数可为空（原 API 在 ObjC 中可能传 nil）
        PlasoSDKBridge.requestUser(withToken: token) { user, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let user = user else {
                    completion(.failure(APIError.emptyToken))
                    return
                }
                completion(.success(user))
            }
        }
    }

    /// 将 bundle 内 yxt.html 复制到临时目录，供 SDK WebView 兜底页使用
    private func copyYXTHtmlToTmp() {
        guard let src = Bundle.main.path(forResource: "yxt", ofType: "html") else {
            NSLog("[YXTSDKDemo] yxt.html 未找到")
            return
        }
        let dst = NSTemporaryDirectory().appending("yxt.html")
        let fm = FileManager.default
        if fm.fileExists(atPath: dst) {
            try? fm.removeItem(atPath: dst)
        }
        do {
            try fm.copyItem(atPath: src, toPath: dst)
        } catch {
            NSLog("[YXTSDKDemo] 复制 yxt.html 失败: \(error)")
        }
    }
}

/// Demo 侧 `IPlasoSDKCaller` 实现。对外 Demo 无自有历史页，空实现即可。
@objc final class PMediatorDemo: NSObject, IPlasoSDKCaller {

    @objc static let shared = PMediatorDemo()

    @objc static func register() {
        PMediatorDefault.register(IPlasoSDKCaller.self, name: DIConstants.IPlasoSDKCaller) { _ in
            return shared
        }
    }

    func openExtHisotry() {
        NSLog("[YXTSDKDemo] openExtHisotry 未实现（Demo 无外部历史页）")
    }
}
