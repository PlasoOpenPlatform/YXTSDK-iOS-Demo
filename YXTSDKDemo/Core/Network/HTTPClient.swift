//
//  HTTPClient.swift
//  YXTSDKDemo
//
//  基于 URLSession 的轻量 HTTP 客户端。
//

import Foundation

/// URLSession 封装。不引入第三方网络库。
final class HTTPClient {

    static let shared = HTTPClient()

    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        session = URLSession(configuration: config)
    }

    /// 发送 JSON POST 请求并解析为字典。
    /// - Parameters:
    ///   - url: 完整 URL
    ///   - body: JSON 字典
    ///   - headers: 额外请求头
    ///   - completion: 主线程回调
    func postJSON(
        url: URL,
        body: [String: Any],
        headers: [String: String] = [:],
        completion: @escaping (Result<[String: Any], APIError>) -> Void
    ) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            DispatchQueue.main.async {
                completion(.failure(.underlying(error)))
            }
            return
        }

        let task = session.dataTask(with: request) { data, response, error in
            let result = Self.parse(data: data, response: response, error: error)
            DispatchQueue.main.async {
                completion(result)
            }
        }
        task.resume()
    }

    private static func parse(
        data: Data?,
        response: URLResponse?,
        error: Error?
    ) -> Result<[String: Any], APIError> {
        if let error = error {
            return .failure(.underlying(error))
        }
        guard let http = response as? HTTPURLResponse else {
            return .failure(.invalidResponse)
        }
        guard (200...299).contains(http.statusCode) else {
            return .failure(.httpStatus(http.statusCode))
        }
        guard let data = data,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return .failure(.decodingFailed)
        }
        return .success(json)
    }
}
