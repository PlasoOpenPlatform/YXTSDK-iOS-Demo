//
//  ServerEnvironment.swift
//  YXTSDKDemo
//
//  开放平台与 SDK 共用的服务器环境定义。
//

import Foundation

/// 服务器环境。授权页可选，同时驱动 OpenAPI 域名与 SDK `plaso_env_ver`。
enum ServerEnvironment: String, CaseIterable, Codable {
    /// 正式环境
    case production
    /// 开发环境
    case development
    /// 测试环境
    case test
    /// 集成测试环境
    case integrationTest

    /// 展示名称
    var displayName: String {
        switch self {
        case .production:
            return "正式"
        case .development:
            return "Dev"
        case .test:
            return "Test"
        case .integrationTest:
            return "集成测试"
        }
    }

    /// OpenAPI / SDK 业务域名（不含路径）
    var host: String {
        switch self {
        case .production:
            return "www.plaso.cn"
        case .development:
            return "dev.plaso.cn"
        case .test:
            return "test.plaso.cn"
        case .integrationTest:
            return "itest.plaso.cn"
        }
    }

    /// 完整 HTTPS 根地址，用于 `updatePreferServerHost`
    var serviceHostURL: String {
        return "https://\(host)"
    }

    /// 写入 `UserDefaults` 的 `plaso_env_ver` 值，供 SDK 拼文件 CDN 前缀
    var plasoEnvVerValue: String {
        switch self {
        case .production:
            return "plaso_prod_env"
        case .development:
            return "plaso_dev_env"
        case .test:
            return "plaso_test_env"
        case .integrationTest:
            return "plaso_in_test_env"
        }
    }

    /// getToken 完整地址
    var getTokenURL: URL {
        return URL(string: "\(serviceHostURL)/dataentry/user/getToken")!
    }
}
