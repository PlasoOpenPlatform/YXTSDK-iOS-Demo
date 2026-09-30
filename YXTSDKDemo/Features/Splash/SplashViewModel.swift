//
//  SplashViewModel.swift
//  YXTSDKDemo
//
//  Splash 页 ViewModel：检查本地 token 并决定下一步路由。
//

import Foundation
import Combine

/// Splash 业务逻辑。
final class SplashViewModel: ObservableObject {

    /// 路由依赖
    private let router: RootRouter
    private let store: SessionStore
    private let bootstrap: PlasoSDKBootstrap

    init(
        router: RootRouter,
        store: SessionStore = .shared,
        bootstrap: PlasoSDKBootstrap = .shared
    ) {
        self.router = router
        self.store = store
        self.bootstrap = bootstrap
    }

    /// 启动后延时检查会话
    func start() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            self?.evaluateSession()
        }
    }

    private func evaluateSession() {
        guard let token = store.validToken else {
            router.showAuth()
            return
        }
        DemoHUD.showLoading(text: "登录中...")
        bootstrap.requestUser(token: token) { [weak self] result in
            DemoHUD.hideLoading()
            guard let self = self else { return }
            switch result {
            case .success:
                self.router.showMain()
            case .failure(let error):
                DemoHUD.showToast(error.localizedDescription)
                self.store.clearToken()
                self.router.showAuth()
            }
        }
    }
}
