//
//  AuthModels.swift
//  YXTSDKDemo
//
//  授权相关数据模型。
//

import Foundation

/// 用户类型，对应 OpenAPI `userType` 字段。
enum UserType: String, CaseIterable, Codable {
    case student
    case teacher
    case assistant

    /// 展示名称
    var displayName: String {
        switch self {
        case .student:
            return "学生"
        case .teacher:
            return "教师"
        case .assistant:
            return "助教"
        }
    }
}

/// 授权配置页表单数据。
struct AuthFormModel {
    var environment: ServerEnvironment = .production
    var appId: String = ""
    var signKey: String = ""
    var loginName: String = ""
    var userType: UserType = .student

    /// 是否已填写必填项
    var isValid: Bool {
        return !appId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !signKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !loginName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

/// getToken 成功后的结果。
struct TokenResult {
    /// 访问令牌
    let token: String
    /// 有效期（秒）
    let expire: Int
    /// 本地过期时间点
    let expireDate: Date

    /// 是否仍在有效期内（预留 60 秒缓冲）
    var isValid: Bool {
        return Date().addingTimeInterval(60) < expireDate
    }
}
