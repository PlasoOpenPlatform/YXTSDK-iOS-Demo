//
//  MineViewModel.swift
//  YXTSDKDemo
//
//  「我的」页 ViewModel。SDK 无公开「我的」页面，自行展示会话信息。
//

import Foundation
import PlasoCommonSDK

/// 「我的」页数据与退出逻辑。
final class MineViewModel {

    struct ProfileItem {
        let title: String
        let value: String
    }

    private let store: SessionStore
    private let router: RootRouter

    init(store: SessionStore = .shared, router: RootRouter = .shared) {
        self.store = store
        self.router = router
    }

    /// 构建展示列表
    func makeItems() -> [ProfileItem] {
        let user = PlasoerUser.current
        let form = store.loadForm()
        let expireText: String
        if let date = store.tokenExpireDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            expireText = formatter.string(from: date)
        } else {
            expireText = "-"
        }

        return [
            ProfileItem(title: "姓名", value: user?.name ?? "-"),
            ProfileItem(title: "登录名", value: user?.loginName ?? form.loginName),
            ProfileItem(title: "用户类型", value: form.userType.displayName),
            ProfileItem(title: "服务器环境", value: "\(form.environment.displayName) (\(form.environment.host))"),
            ProfileItem(title: "AppId", value: form.appId.isEmpty ? "-" : form.appId),
            ProfileItem(title: "Token 过期时间", value: expireText)
        ]
    }

    /// 退出登录，清除 token 并返回授权页
    func logout() {
        store.clearToken()
        PlasoerUser.current = nil
        router.showAuth()
        DemoHUD.showToast("已退出登录")
    }
}
