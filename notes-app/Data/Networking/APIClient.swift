//
//  notes_appApp.swift
//  notes-app
//
//  Created by Cem Girgin on 17.10.25.
//


import Foundation

// Basit ağ günlükleyici
private enum NetLog {
    static func request(_ method: String, _ url: URL, headers: [String: String], body: Data?) {
        var msg = "\n➡️ REQUEST \(method) \(url.absoluteString)"
        if !headers.isEmpty { msg += "\nHeaders: \(headers)" }
        if let body, !shouldRedact(url: url) {
            msg += "\nBody: \(String(data: body, encoding: .utf8) ?? "<binary>")"
        } else if body != nil {
            msg += "\nBody: <redacted>"
        }
        print(msg)
    }

    static func response(_ url: URL, status: Int, data: Data?) {
        var msg = "\n⬅️ RESPONSE \(status) \(url.absoluteString)"
        if let data { msg += "\nBody: \(String(data: data, encoding: .utf8) ?? "<binary>")" }
        print(msg)
    }

    private static func shouldRedact(url: URL) -> Bool {
        let p = url.path.lowercased()
        return p.contains("/auth/login") || p.contains("/auth/signup")
    }
}

// Toleranslı tarih decode
private extension JSONDecoder.DateDecodingStrategy {
    static var tolerantISO8601: JSONDecoder.DateDecodingStrategy {
        .custom { decoder in
            let c = try decoder.singleValueContainer()
            let s = try c.decode(String.self)

            let iso = ISO8601DateFormatter()
            iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let d = iso.date(from: s) { return d }
            iso.formatOptions = [.withInternetDateTime]
            if let d = iso.date(from: s) { return d }

            let f1 = DateFormatter()
            f1.locale = Locale(identifier: "en_US_POSIX")
            f1.timeZone = .init(secondsFromGMT: 0)
            f1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            if let d = f1.date(from: s) { return d }

            let f2 = DateFormatter()
            f2.locale = Locale(identifier: "en_US_POSIX")
            f2.timeZone = .init(secondsFromGMT: 0)
            f2.dateFormat = "yyyy-MM-dd HH:mm:ss"
            if let d = f2.date(from: s) { return d }

            throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unsupported date: \(s)"))
        }
    }
}

final class APIClient {
    private let baseURL: URL
    private let session: URLSession
    private let tokenProvider: () -> String?

    init(baseURL: URL, session: URLSession = .shared, tokenProvider: @escaping () -> String?) {
        self.baseURL = baseURL
        self.session = session
        self.tokenProvider = tokenProvider
    }

    private func requestRaw(
        path: String,
        method: String = "GET",
        query: [URLQueryItem] = [],
        body: Encodable? = nil
    ) async throws -> (Data, HTTPURLResponse, URL) {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)
        components?.queryItems = query.isEmpty ? nil : query
        guard let url = components?.url else { throw APIError.invalidURL }

        var req = URLRequest(url: url)
        req.httpMethod = method
        req.addValue("application/json", forHTTPHeaderField: "Accept")
        if let token = tokenProvider() {
            req.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body = body {
            let data = try JSONEncoder().encode(AnyEncodable(body))
            req.httpBody = data
            req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        NetLog.request(method, url, headers: req.allHTTPHeaderFields ?? [:], body: req.httpBody)

        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw APIError.unknown }

        NetLog.response(http.url ?? url, status: http.statusCode, data: data)

        switch http.statusCode {
        case 200...299: return (data, http, http.url ?? url)
        case 401: throw APIError.unauthorized
        default:
            let message = String(data: data, encoding: .utf8)
            throw APIError.badStatus(http.statusCode, message)
        }
    }

    // JSON decode eden
    func request<T: Decodable>(
        path: String,
        method: String = "GET",
        query: [URLQueryItem] = [],
        body: Encodable? = nil
    ) async throws -> T {
        let (data, _, _) = try await requestRaw(path: path, method: method, query: query, body: body)
        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .tolerantISO8601
        return try dec.decode(T.self, from: data)
    }

    // Sadece status kontrol
    func requestVoid(
        path: String,
        method: String = "DELETE",
        body: Encodable? = nil
    ) async throws {
        _ = try await requestRaw(path: path, method: method, body: body)
    }

    // 🔽 YENİ: Ham veri (PDF vb.) indirme
    func requestData(
        path: String,
        method: String = "GET",
        query: [URLQueryItem] = []
    ) async throws -> Data {
        let (data, _, _) = try await requestRaw(path: path, method: method, query: query, body: Optional<Data>.none)
        return data
    }
}

// Yardımcılar / Hatalar
private struct AnyEncodable: Encodable {
    let value: Encodable
    init(_ value: Encodable) { self.value = value }
    func encode(to encoder: Encoder) throws { try value.encode(to: encoder) }
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case badStatus(Int, String?)
    case decoding(Error)
    case transport(Error)
    case unauthorized
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL: "Invalid URL"
        case .badStatus(let code, let message): "HTTP \(code): \(message ?? "-")"
        case .decoding: "Failed to decode server response"
        case .transport(let err): err.localizedDescription
        case .unauthorized: "Unauthorized. Please sign in again."
        case .unknown: "Unknown error"
        }
    }
}


