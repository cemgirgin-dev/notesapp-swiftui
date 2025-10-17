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

// Çok formatlı / toleranslı tarih decoder
private extension JSONDecoder.DateDecodingStrategy {
    static var tolerantISO8601: JSONDecoder.DateDecodingStrategy {
        return .custom { decoder in
            let container = try decoder.singleValueContainer()
            let str = try container.decode(String.self)

            // 1) Tam ISO8601 (Z veya timezone’lu)
            let iso = ISO8601DateFormatter()
            iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let d = iso.date(from: str) { return d }
            iso.formatOptions = [.withInternetDateTime]
            if let d = iso.date(from: str) { return d }

            // 2) "yyyy-MM-dd'T'HH:mm:ss" (timezone yok)
            let f1 = DateFormatter()
            f1.locale = Locale(identifier: "en_US_POSIX")
            f1.timeZone = TimeZone(secondsFromGMT: 0)
            f1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            if let d = f1.date(from: str) { return d }

            // 3) "yyyy-MM-dd HH:mm:ss" (bazı backend’ler böyle döner)
            let f2 = DateFormatter()
            f2.locale = Locale(identifier: "en_US_POSIX")
            f2.timeZone = TimeZone(secondsFromGMT: 0)
            f2.dateFormat = "yyyy-MM-dd HH:mm:ss"
            if let d = f2.date(from: str) { return d }

            // Olmadıysa decode hatası ver
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: decoder.codingPath,
                                      debugDescription: "Unsupported date format: \(str)")
            )
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

    // Ham istek + status kontrol + LOG
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

        // LOG: Request
        let headers = req.allHTTPHeaderFields ?? [:]
        NetLog.request(method, url, headers: headers, body: req.httpBody)

        do {
            let (data, resp) = try await session.data(for: req)
            guard let http = resp as? HTTPURLResponse else { throw APIError.unknown }

            // LOG: Response (URLSession redirect sonrası farklı URL’ye gitmişse, http.url ile göster)
            NetLog.response(http.url ?? url, status: http.statusCode, data: data)

            switch http.statusCode {
            case 200...299:
                return (data, http, http.url ?? url)
            case 401:
                throw APIError.unauthorized
            default:
                let message = String(data: data, encoding: .utf8)
                throw APIError.badStatus(http.statusCode, message)
            }
        } catch let err as APIError {
            throw err
        } catch {
            throw APIError.transport(error)
        }
    }

    // Decode eden generic istek
    func request<T: Decodable>(
        path: String,
        method: String = "GET",
        query: [URLQueryItem] = [],
        body: Encodable? = nil
    ) async throws -> T {
        let (data, _, _) = try await requestRaw(path: path, method: method, query: query, body: body)
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .tolerantISO8601
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }

    // Boş/önemsiz gövdeyi decode etme—sadece durum kontrol et (log already printed)
    func requestVoid(
        path: String,
        method: String = "DELETE",
        body: Encodable? = nil
    ) async throws {
        _ = try await requestRaw(path: path, method: method, body: body)
    }
}

// MARK: - Yardımcılar ve Hatalar

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
        case .invalidURL: return "Invalid URL"
        case .badStatus(let code, let message): return "HTTP \(code): \(message ?? "-")"
        case .decoding: return "Failed to decode server response"
        case .transport(let err): return err.localizedDescription
        case .unauthorized: return "Unauthorized. Please sign in again."
        case .unknown: return "Unknown error"
        }
    }
}

