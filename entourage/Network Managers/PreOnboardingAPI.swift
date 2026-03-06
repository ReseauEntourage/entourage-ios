//
//  PreOnboardingAPI.swift
//  entourage
//
//  Created by Clement entourage on 25/09/2025.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case http(Int, Data?)
    case decoding(Error, Data?)
    case network(Error)
}

final class PreOnboardingAPI {
    static let shared = PreOnboardingAPI()

    // Same token used on Android for the outings endpoint

    // Base URL & API key come from EnvironmentConfigurationManager
    // APIHostURL is expected to be like: "https://api-preprod.entourage.social/api/v1"
    private let baseURL: URL = {
        let raw = EnvironmentConfigurationManager.sharedInstance.APIHostURL as String
        let normalized = raw.hasSuffix("/") ? String(raw.dropLast()) : raw
        guard let url = URL(string: normalized) else {
            // Fallback to preprod if something is misconfigured
            return URL(string: "https://api-preprod.entourage.social/api/v1")!
        }
        return url
    }()

    private let apiKey: String = {
        EnvironmentConfigurationManager.sharedInstance.APIKey as String
    }()

    private let appVersion: String = {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "0"
        return "\(version)(\(build))"
    }()

    private let jsonDecoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    // MARK: - Generic GET (iOS 11+ compatible)
    func get<T: Decodable>(
        _ path: String,
        queryItems: [URLQueryItem]? = nil,
        headers extraHeaders: [String: String]? = nil,
        completion: @escaping (Swift.Result<T, APIError>) -> Void
    ) {
        // Compose URL
        var url = baseURL.appendingPathComponent(path)
        if var comps = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            if let queryItems = queryItems, !queryItems.isEmpty {
                comps.queryItems = (comps.queryItems ?? []) + queryItems
            }
            if let u = comps.url { url = u }
        }

        var req = URLRequest(url: url, timeoutInterval: 30)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue(apiKey,               forHTTPHeaderField: "X-API-KEY")
        req.setValue("iOS",                forHTTPHeaderField: "X-PLATFORM")
        req.setValue(appVersion,           forHTTPHeaderField: "X-APP-VERSION")
        extraHeaders?.forEach { k, v in req.setValue(v, forHTTPHeaderField: k) }

        let task = URLSession.shared.dataTask(with: req) { [jsonDecoder] data, resp, error in
            if let error = error {
                return DispatchQueue.main.async { completion(.failure(.network(error))) }
            }
            guard let http = resp as? HTTPURLResponse else {
                let err = NSError(domain: "Invalid response", code: -1)
                return DispatchQueue.main.async { completion(.failure(.network(err))) }
            }
            guard (200..<300).contains(http.statusCode) else {
                return DispatchQueue.main.async { completion(.failure(.http(http.statusCode, data))) }
            }
            guard let data = data else {
                let err = NSError(domain: "Empty body", code: -2)
                return DispatchQueue.main.async { completion(.failure(.network(err))) }
            }
            do {
                let obj = try jsonDecoder.decode(T.self, from: data)
                DispatchQueue.main.async { completion(.success(obj)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(.decoding(error, data))) }
            }
        }
        task.resume()
    }

    // MARK: - Public Endpoints (names kept)

    /// GET /salesforce/entreprises
    func fetchEnterprises(completion: @escaping (Swift.Result<[SalesforceEnterprise], APIError>) -> Void) {
        get("salesforce/entreprises", completion: completion)
    }

    /// GET /salesforce/entreprises/{id}/outings?token=SALESFORCE_TOKEN
    func fetchEventsForEnterprise(enterpriseId: String,
                                  completion: @escaping (Swift.Result<[SalesforceEvent], APIError>) -> Void) {
        get("salesforce/entreprises/\(enterpriseId)/outings", completion: completion)
    }

    /// GET /home/metadata
    func fetchSummaryBeforeLogin(completion: @escaping (Swift.Result<Metadata, APIError>) -> Void) {
        get("home/metadata", completion: completion)
    }
}
