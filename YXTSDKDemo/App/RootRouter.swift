//
//  RootRouter.swift
//  YXTSDKDemo
//
//  根页面路由：Splash / 授权 / 主 Tab。
//

import UIKit
import SwiftUI
import PlasoCommonSDK

/// 应用根路由，负责切换 Window 的 rootViewController。
final class RootRouter {

    static let shared = RootRouter()

    weak var window: UIWindow?

    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTokenExpired),
            name: NSNotification.Name("kUserTokenExpiredNotification"),
            object: nil
        )
    }

    /// 启动进入 Splash
    func showSplash() {
        let view = SplashView(viewModel: SplashViewModel(router: self))
        setRoot(UIHostingController(rootView: view), animated: false)
    }

    /// 进入授权配置页
    func showAuth() {
        let view = AuthConfigView(viewModel: AuthConfigViewModel(router: self))
        let host = UIHostingController(rootView: view)
        let nav = UINavigationController(rootViewController: host)
        nav.navigationBar.prefersLargeTitles = false
        setRoot(nav, animated: true)
    }

    /// 进入主 Tab
    func showMain() {
        let tab = MainTabBarController()
        setRoot(tab, animated: true)
    }

    /// 退出登录并回到授权页
    func logoutToAuth(message: String? = nil) {
        SessionStore.shared.clearToken()
        PlasoerUser.current = nil
        showAuth()
        if let message = message {
            DemoHUD.showToast(message)
        }
    }

    @objc private func handleTokenExpired() {
        DispatchQueue.main.async {
            self.logoutToAuth(message: "Token 已失效，请重新授权")
        }
    }

    private func setRoot(_ controller: UIViewController, animated: Bool) {
        guard let window = window else { return }
        if animated {
            UIView.transition(
                with: window,
                duration: 0.25,
                options: .transitionCrossDissolve,
                animations: {
                    window.rootViewController = controller
                },
                completion: nil
            )
        } else {
            window.rootViewController = controller
        }
        window.makeKeyAndVisible()
    }
}
