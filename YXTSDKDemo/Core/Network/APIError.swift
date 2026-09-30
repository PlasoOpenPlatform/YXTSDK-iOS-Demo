//
//  APIError.swift
//  YXTSDKDemo
//
//  网络层统一错误类型。
//

import Foundation

/// Demo 网络请求错误。
enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
    case business(code: Int, message: String)
    case decodingFailed
    case signFailed
    case emptyToken
    case underlying(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的请求地址"
        case .invalidResponse:
            return "服务器返回异常"
        case .httpStatus(let code):
            return "HTTP 状态码 \(code)"
        case .business(_, let message):
            return message.isEmpty ? "业务请求失败" : message
        case .decodingFailed:
            return "响应解析失败"
        case .signFailed:
            return "签名生成失败，请检查 SignKey"
        case .emptyToken:
            return "未获取到有效 Token"
        case .underlying(let error):
            return error.localizedDescription
        }
    }
}
