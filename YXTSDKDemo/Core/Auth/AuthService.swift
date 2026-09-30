//
//  AuthService.swift
//  YXTSDKDemo
//
//  OpenAPI getToken 授权服务。
//

import Foundation

/// 调用开放平台 `/dataentry/user/getToken` 获取访问令牌。
final class AuthService {

    private let client: HTTPClient

    init(client: HTTPClient = .shared) {
        self.client = client
    }

    /// 使用表单配置请求用户 Token。
    /// - Parameters:
    ///   - form: 授权配置
    ///   - completion: 主线程回调
    func getToken(
        form: AuthFormModel,
        completion: @escaping (Result<TokenResult, APIError>) -> Void
    ) {
        let appId = form.appId.trimmingCharacters(in: .whitespacesAndNewlines)
        let signKey = form.signKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let loginName = form.loginName.trimmingCharacters(in: .whitespacesAndNewlines)

        var parameters: [String: Any] = [
            "appId": appId,
            "loginName": loginName,
            "userType": form.userType.rawValue,
            "validBegin": Int(Date().timeIntervalSince1970),
            "validTime": 1200
        ]

        guard SignHelper.sign(parameters: &parameters, signKey: signKey) != nil else {
            completion(.failure(.signFailed))
            return
        }

        client.postJSON(url: form.environment.getTokenURL, body: parameters) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let json):
                completion(Self.parseTokenResponse(json))
            }
        }
    }

    private static func parseTokenResponse(
        _ json: [String: Any]
    ) -> Result<TokenResult, APIError> {
        let code = (json["code"] as? Int) ?? -1
        let message = (json["msg"] as? String)
            ?? (json["message"] as? String)
            ?? "授权失败"
        guard code == 0 else {
            return .failure(.business(code: code, message: message))
        }
        guard let obj = json["obj"] as? [String: Any],
              let token = obj["token"] as? String,
              !token.isEmpty else {
            return .failure(.emptyToken)
        }
        let expire = (obj["expire"] as? Int) ?? 36000
        let expireDate = Date().addingTimeInterval(TimeInterval(expire))
        return .success(TokenResult(token: token, expire: expire, expireDate: expireDate))
    }
}
