//
//  AuthConfigViewModel.swift
//  YXTSDKDemo
//
//  授权配置页 ViewModel。
//

import Foundation
import Combine
import PlasoCommonSDK

/// 授权配置业务逻辑：环境切换、getToken、拉用户。
final class AuthConfigViewModel: ObservableObject {

    @Published var form: AuthFormModel
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let router: RootRouter
    private let store: SessionStore
    private let authService: AuthService
    private let bootstrap: PlasoSDKBootstrap

    init(
        router: RootRouter,
        store: SessionStore = .shared,
        authService: AuthService = AuthService(),
        bootstrap: PlasoSDKBootstrap = .shared
    ) {
        self.router = router
        self.store = store
        self.authService = authService
        self.bootstrap = bootstrap
        self.form = store.loadForm()
    }

    /// 切换服务器环境。会清空 token，并同步 SDK 环境键与 serviceHost。
    func selectEnvironment(_ environment: ServerEnvironment) {
        guard form.environment != environment else { return }
        form.environment = environment
        store.environment = environment
        store.clearToken()
        // 若 SDK 已初始化，覆盖业务域名；文件 CDN 依赖 plaso_env_ver（已在 setter 写入）
        if bootstrap.isInitialized {
            AppConfig.updatePreferServerHost(environment.serviceHostURL)
            ServletHelper.sharedInstance().serviceHost = AppConfig.serviceHost()
        }
    }

    /// 提交授权：签名 → getToken → requetUserWith → 进主页
    func submit() {
        errorMessage = nil
        guard form.isValid else {
            errorMessage = "请填写 AppId、SignKey 与用户名"
            return
        }
        store.saveForm(form)
        isLoading = true
        DemoHUD.showLoading(text: "授权中...")

        authService.getToken(form: form) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                self.isLoading = false
                DemoHUD.hideLoading()
                self.errorMessage = error.localizedDescription
                DemoHUD.showToast(error.localizedDescription)
            case .success(let tokenResult):
                self.store.saveToken(tokenResult)
                self.fetchUser(token: tokenResult.token)
            }
        }
    }

    private func fetchUser(token: String) {
        bootstrap.requestUser(token: token) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            DemoHUD.hideLoading()
            switch result {
            case .success:
                self.router.showMain()
            case .failure(let error):
                self.store.clearToken()
                self.errorMessage = error.localizedDescription
                DemoHUD.showToast(error.localizedDescription)
            }
        }
    }
}
