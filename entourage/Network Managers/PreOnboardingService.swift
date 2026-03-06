//
//  PreOnboardingService.swift
//  entourage
//
//  Created by Clement entourage on 25/09/2025.
//

import Foundation

/// Typealias pour rester aligné avec tes modèles déjà posés
typealias Metadata = HomeMetadata

/// Service façade au-dessus de PreOnboardingAPI (caching + helpers UI)
final class PreOnboardingService {

    static let shared = PreOnboardingService()

    // MARK: - In-memory cache
    private var enterprisesCache: [SalesforceEnterprise]?
    private var eventsCache: [String: [SalesforceEvent]] = [:] // key = enterpriseId
    private var metadataCache: Metadata?

    // Synchronisation simple
    private let syncQueue = DispatchQueue(label: "preonboarding.service.sync")

    private init() {}

    // MARK: - Public API

    /// Charge la liste des entreprises (cache + forceReload)
    func loadEnterprises(forceReload: Bool = false,
                         completion: @escaping (Swift.Result<[SalesforceEnterprise], Error>) -> Void) {
        // Cache hit
        if !forceReload, let cached = syncQueue.sync(execute: { enterprisesCache }) {
            return completion(.success(cached))
        }

        PreOnboardingAPI.shared.fetchEnterprises { [weak self] result in
            switch result {
            case .success(let list):
                self?.syncQueue.async {
                    self?.enterprisesCache = list
                }
                completion(.success(list))
            case .failure(let apiErr):
                completion(.failure(apiErr))
            }
        }
    }

    /// Charge les events d’une entreprise (cache + forceReload)
    func loadEvents(for enterpriseId: String,
                    forceReload: Bool = false,
                    completion: @escaping (Swift.Result<[SalesforceEvent], Error>) -> Void) {
        // Cache hit
        if !forceReload, let cached = syncQueue.sync(execute: { eventsCache[enterpriseId] }) {
            return completion(.success(cached))
        }

        PreOnboardingAPI.shared.fetchEventsForEnterprise(enterpriseId: enterpriseId) { [weak self] result in
            switch result {
            case .success(let events):
                self?.syncQueue.async {
                    self?.eventsCache[enterpriseId] = events
                }
                completion(.success(events))
            case .failure(let apiErr):
                completion(.failure(apiErr))
            }
        }
    }

    /// Charge le metadata (cache + forceReload)
    func loadMetadata(forceReload: Bool = false,
                      completion: @escaping (Swift.Result<Metadata, Error>) -> Void) {
        // Cache hit
        if !forceReload, let cached = syncQueue.sync(execute: { metadataCache }) {
            return completion(.success(cached))
        }

        PreOnboardingAPI.shared.fetchSummaryBeforeLogin { [weak self] result in
            switch result {
            case .success(let meta):
                self?.syncQueue.async {
                    self?.metadataCache = meta
                }
                completion(.success(meta))
            case .failure(let apiErr):
                completion(.failure(apiErr))
            }
        }
    }

    // MARK: - Helpers UI (facultatifs, pratiques)

    /// Entreprises triées alphabétiquement (Name)
    func enterprisesDisplayList(forceReload: Bool = false,
                                completion: @escaping (Swift.Result<[SalesforceEnterprise], Error>) -> Void) {
        loadEnterprises(forceReload: forceReload) { result in
            switch result {
            case .success(let list):
                let sorted = list.sorted {
                    ($0.name ?? "").localizedCaseInsensitiveCompare($1.name ?? "") == .orderedAscending
                }
                completion(.success(sorted))
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }

    /// Events triés par StartDate croissant (si présent), sinon par Name
    func eventsDisplayList(for enterpriseId: String,
                           forceReload: Bool = false,
                           completion: @escaping (Swift.Result<[SalesforceEvent], Error>) -> Void) {
        loadEvents(for: enterpriseId, forceReload: forceReload) { result in
            switch result {
            case .success(let events):
                let sorted = events.sorted { lhs, rhs in
                    if let l = lhs.startDate, let r = rhs.startDate, !l.isEmpty, !r.isEmpty {
                        return l < r
                    }
                    return (lhs.name ?? "") < (rhs.name ?? "")
                }
                completion(.success(sorted))
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }

    /// Retourne le dictionnaire `genders` (clé backend -> libellé FR)
    func gendersMap(forceReload: Bool = false,
                    completion: @escaping (Swift.Result<[String: String], Error>) -> Void) {
        loadMetadata(forceReload: forceReload) { result in
            switch result {
            case .success(let meta):
                completion(.success(meta.user?.genders ?? [:]))
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }

    /// Retourne le dictionnaire `discovery_sources` (clé backend -> libellé FR)
    func discoverySourcesMap(forceReload: Bool = false,
                             completion: @escaping (Swift.Result<[String: String], Error>) -> Void) {
        loadMetadata(forceReload: forceReload) { result in
            switch result {
            case .success(let meta):
                completion(.success(meta.user?.discoverySources ?? [:]))
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }

    /// Vide le cache mémoire (si tu changes d’environnement, déconnecte l’utilisateur, etc.)
    func clearCache() {
        syncQueue.async {
            self.enterprisesCache = nil
            self.eventsCache.removeAll()
            self.metadataCache = nil
        }
    }
}
