//
//  SignHelper.swift
//  YXTSDKDemo
//
//  OpenAPI HMAC-SHA1 签名工具。
//

import Foundation
import CommonCrypto

/// OpenAPI 参数签名。正式环境建议在服务端完成，Demo 仅作演示。
enum SignHelper {

    /// 对业务参数补充签名字段并生成 signature。
    /// - Parameters:
    ///   - parameters: 业务参数（会被原地写入 `signature`）
    ///   - signKey: 开放平台分配的签名密钥
    /// - Returns: 大写十六进制签名；失败返回 nil
    @discardableResult
    static func sign(
        parameters: inout [String: Any],
        signKey: String
    ) -> String? {
        let sortedKeys = parameters.keys.sorted()
        let content = sortedKeys.map { key in
            "\(key)=\(stringify(parameters[key]))"
        }.joined(separator: "&")

        guard let signature = hmacSHA1(content: content, key: signKey) else {
            return nil
        }
        parameters["signature"] = signature
        return signature
    }

    /// HMAC-SHA1，输出大写十六进制
    static func hmacSHA1(content: String, key: String) -> String? {
        guard let keyData = key.data(using: .utf8),
              let contentData = content.data(using: .utf8) else {
            return nil
        }
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        keyData.withUnsafeBytes { keyBytes in
            contentData.withUnsafeBytes { contentBytes in
                CCHmac(
                    CCHmacAlgorithm(kCCHmacAlgSHA1),
                    keyBytes.baseAddress,
                    keyData.count,
                    contentBytes.baseAddress,
                    contentData.count,
                    &digest
                )
            }
        }
        return digest.map { String(format: "%02X", $0) }.joined()
    }

    /// 将参数值转为签名用字符串
    private static func stringify(_ value: Any?) -> String {
        guard let value = value else { return "" }
        if let number = value as? NSNumber {
            return number.stringValue
        }
        return "\(value)"
    }
}
