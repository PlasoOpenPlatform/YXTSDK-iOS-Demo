//
//  SessionStore.swift
//  YXTSDKDemo
//
//  本地会话与授权配置持久化。
//

import Foundation

/// 本地会话存储。保存授权配置、token 与过期时间。
final class SessionStore {

    static let shared = SessionStore()

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let environment = "yxt_demo_environment"
        static let appId = "yxt_demo_app_id"
        static let signKey = "yxt_demo_sign_key"
        static let loginName = "yxt_demo_login_name"
        static let userType = "yxt_demo_user_type"
        static let token = "yxt_demo_token"
        static let expireDate = "yxt_demo_expire_date"
        /// SDK 读取的环境键，值与 AppConfig 常量一致
        static let plasoEnvVer = "plaso_env_ver"
    }

    private init() {}

    // MARK: - 环境

    /// 当前服务器环境，默认正式
    var environment: ServerEnvironment {
        get {
            guard let raw = defaults.string(forKey: Keys.environment),
                  let env = ServerEnvironment(rawValue: raw) else {
                return .production
            }
            return env
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.environment)
            // 同步写入 SDK 环境键，供文件 CDN 与 appServerEnv 使用
            defaults.set(newValue.plasoEnvVerValue, forKey: Keys.plasoEnvVer)
            defaults.synchronize()
        }
    }

    // MARK: - 授权配置

    /// 读取已保存的授权表单
    func loadForm() -> AuthFormModel {
        var form = AuthFormModel()
        form.environment = environment
        form.appId = defaults.string(forKey: Keys.appId) ?? ""
        form.signKey = defaults.string(forKey: Keys.signKey) ?? ""
        form.loginName = defaults.string(forKey: Keys.loginName) ?? ""
        if let raw = defaults.string(forKey: Keys.userType),
           let type = UserType(rawValue: raw) {
            form.userType = type
        }
        return form
    }

    /// 保存授权表单（不含 token）
    func saveForm(_ form: AuthFormModel) {
        environment = form.environment
        defaults.set(form.appId, forKey: Keys.appId)
        defaults.set(form.signKey, forKey: Keys.signKey)
        defaults.set(form.loginName, forKey: Keys.loginName)
        defaults.set(form.userType.rawValue, forKey: Keys.userType)
        defaults.synchronize()
    }

    // MARK: - Token

    /// 当前有效 token，过期则返回 nil
    var validToken: String? {
        guard let token = defaults.string(forKey: Keys.token), !token.isEmpty else {
            return nil
        }
        guard let date = defaults.object(forKey: Keys.expireDate) as? Date else {
            return nil
        }
        let result = TokenResult(token: token, expire: 0, expireDate: date)
        return result.isValid ? token : nil
    }

    /// token 过期时间
    var tokenExpireDate: Date? {
        return defaults.object(forKey: Keys.expireDate) as? Date
    }

    /// 保存 token 结果
    func saveToken(_ result: TokenResult) {
        defaults.set(result.token, forKey: Keys.token)
        defaults.set(result.expireDate, forKey: Keys.expireDate)
        defaults.synchronize()
    }

    /// 清除 token（切换环境或退出登录时调用）
    func clearToken() {
        defaults.removeObject(forKey: Keys.token)
        defaults.removeObject(forKey: Keys.expireDate)
        defaults.synchronize()
    }

    /// 清除全部会话数据
    func clearAll() {
        clearToken()
        defaults.removeObject(forKey: Keys.appId)
        defaults.removeObject(forKey: Keys.signKey)
        defaults.removeObject(forKey: Keys.loginName)
        defaults.removeObject(forKey: Keys.userType)
        defaults.synchronize()
    }

    /// 应用启动时确保 `plaso_env_ver` 与本地环境一致
    func applyEnvironmentBeforeSDKInit() {
        let env = environment
        defaults.set(env.plasoEnvVerValue, forKey: Keys.plasoEnvVer)
        defaults.synchronize()
    }
}
