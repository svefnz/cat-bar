import Foundation

@MainActor
extension AppSession {
    private var coreUpgradeStateResolver: CoreUpgradeStateResolver {
        CoreUpgradeStateResolver(unknownMessage: tr("ui.common.unknown"))
    }

    private func maintenanceRepository() throws -> MaintenanceRepository {
        try DefaultMaintenanceRepository(transport: self.clientOrThrow())
    }

    private func upgradeCoreUseCase() throws -> UpgradeCoreUseCase {
        try UpgradeCoreUseCase(repository: self.maintenanceRepository())
    }

    private func flushFakeIPCacheUseCase() throws -> FlushFakeIPCacheUseCase {
        try FlushFakeIPCacheUseCase(repository: self.maintenanceRepository())
    }

    private func flushDNSCacheUseCase() throws -> FlushDNSCacheUseCase {
        try FlushDNSCacheUseCase(repository: self.maintenanceRepository())
    }

    private func fetchVersionUseCase() throws -> FetchVersionUseCase {
        try FetchVersionUseCase(repository: self.maintenanceRepository())
    }

    func upgradeCore() async {
        guard self.beginPresentedCoreUpgrade() else { return }

        self.coreUpgradeFeedbackClearTask?.cancel()
        self.coreUpgradeFeedbackClearTask = nil

        let state: CoreUpgradeState
        do {
            let response = try await self.upgradeCoreUseCase().execute()
            state = self.coreUpgradeState(from: response)
        } catch {
            state = self.coreUpgradeState(from: error)
        }

        self.applyCoreUpgradeState(state)
        await self.performCoreUpgradeFollowUpIfNeeded(state)
    }

    func flushFakeIPCache() async {
        guard self.flushFakeIPState != .loading else { return }

        self.flushFakeIPState = .loading
        do {
            try await self.flushFakeIPCacheUseCase().execute()
            self.applyFlushFakeIPState(.succeeded)
        } catch {
            self.applyFlushFakeIPState(.failed(message: error.localizedDescription))
        }
    }

    private func applyFlushFakeIPState(_ state: MaintenanceActionState) {
        self.flushFakeIPState = state

        switch state {
        case .idle, .loading:
            return
        case .succeeded:
            self.appendLog(level: "info", message: tr("log.action.success", tr("log.action_name.flush_fakeip_cache")))
        case let .failed(message):
            self.appendLog(level: "error", message: tr("log.action.failed", tr("log.action_name.flush_fakeip_cache"), message))
        }

        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 4_000_000_000)
            guard let self else { return }
            if self.flushFakeIPState != .loading {
                self.flushFakeIPState = .idle
            }
        }
    }

    func flushDNSCache() async {
        guard self.flushDNSState != .loading else { return }

        self.flushDNSState = .loading
        do {
            try await self.flushDNSCacheUseCase().execute()
            self.applyFlushDNSState(.succeeded)
        } catch {
            self.applyFlushDNSState(.failed(message: error.localizedDescription))
        }
    }

    private func applyFlushDNSState(_ state: MaintenanceActionState) {
        self.flushDNSState = state

        switch state {
        case .idle, .loading:
            return
        case .succeeded:
            self.appendLog(level: "info", message: tr("log.action.success", tr("log.action_name.flush_dns_cache")))
        case let .failed(message):
            self.appendLog(level: "error", message: tr("log.action.failed", tr("log.action_name.flush_dns_cache"), message))
        }

        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 4_000_000_000)
            guard let self else { return }
            if self.flushDNSState != .loading {
                self.flushDNSState = .idle
            }
        }
    }

    func refreshActiveTab() async {
        await refreshForActivatedTab(activeMenuTab)
    }

    var isCoreUpgradeInFlight: Bool {
        self.isPresentedCoreUpgradeInFlight
    }

    private func applyCoreUpgradeState(_ state: CoreUpgradeState) {
        self.applyPresentedCoreUpgradeState(state)

        switch state {
        case .idle, .running:
            return
        case .succeeded:
            self.appendLog(level: "info", message: tr("log.core_upgrade.updated"))
        case let .alreadyLatest(version):
            if let version, !version.isEmpty {
                self.version = AppSemanticVersion.normalizedDisplayVersion(from: version)
                self.appendLog(level: "info", message: tr("log.core_upgrade.latest_version", self.version))
            } else {
                self.appendLog(level: "info", message: tr("log.core_upgrade.latest"))
            }
        case let .failed(message):
            self.appendLog(level: "error", message: tr("log.core_upgrade.failed", message))
        }

        self.scheduleCoreUpgradeFeedbackAutoClear()
    }

    private func performCoreUpgradeFollowUpIfNeeded(_ state: CoreUpgradeState) async {
        guard case .succeeded = state else { return }

        await self.restartCore()
        await self.refreshCoreVersionAfterUpgradeIfPossible()
    }

    private func scheduleCoreUpgradeFeedbackAutoClear() {
        self.coreUpgradeFeedbackClearTask?.cancel()
        self.coreUpgradeFeedbackClearTask = Task { [weak self] in
            do {
                try await Task.sleep(nanoseconds: 4_000_000_000)
            } catch {
                return
            }

            guard let self else { return }
            guard !self.isCoreUpgradeInFlight else { return }
            self.applyPresentedCoreUpgradeState(.idle)
        }
    }

    private func refreshCoreVersionAfterUpgradeIfPossible() async {
        do {
            try await Task.sleep(nanoseconds: 750_000_000)
        } catch {
            return
        }

        guard !Task.isCancelled else { return }

        do {
            let versionInfo = try await self.fetchVersionUseCase().execute()
            guard !Task.isCancelled else { return }
            self.version = versionInfo.version
        } catch {
            // Best effort only. The core may be restarting briefly after an upgrade request.
        }
    }

    func upgradeGeo() async {
        guard !self.isGeoUpdateInFlight else { return }

        self.geoUpdateFeedbackClearTask?.cancel()
        self.geoUpdateFeedbackClearTask = nil
        self.geoUpdateState = .updating

        do {
            try await self.maintenanceRepository().upgradeGeo()
            self.applyGeoUpdateState(.succeeded)
        } catch {
            self.applyGeoUpdateState(.failed(message: self.geoUpdateFailureMessage(from: error)))
        }
    }

    var isGeoUpdateInFlight: Bool {
        if case .updating = self.geoUpdateState {
            return true
        }
        return false
    }

    private func applyGeoUpdateState(_ state: GeoUpdateState) {
        self.geoUpdateState = state

        switch state {
        case .idle, .updating:
            return
        case .succeeded:
            self.appendLog(level: "info", message: tr("log.geo_update.updated"))
        case let .failed(message):
            self.appendLog(level: "error", message: tr("log.geo_update.failed", message))
        }

        self.scheduleGeoUpdateFeedbackAutoClear()
    }

    private func scheduleGeoUpdateFeedbackAutoClear() {
        self.geoUpdateFeedbackClearTask?.cancel()
        self.geoUpdateFeedbackClearTask = Task { [weak self] in
            do {
                try await Task.sleep(nanoseconds: 4_000_000_000)
            } catch {
                return
            }

            guard let self else { return }
            guard !self.isGeoUpdateInFlight else { return }
            self.geoUpdateState = .idle
        }
    }

    private func geoUpdateFailureMessage(from error: Error) -> String {
        let raw: String = if let apiError = error as? APIError,
                             case let .statusCode(_, responseBody) = apiError
        {
            responseBody
        } else {
            error.localizedDescription
        }

        let trimmed = raw.trimmedNonEmpty ?? ""
        return trimmed.isEmpty ? tr("ui.common.unknown") : trimmed
    }

    private func coreUpgradeState(from response: CoreUpgradeResponse) -> CoreUpgradeState {
        self.coreUpgradeStateResolver.resolve(response: response)
    }

    private func coreUpgradeState(from error: Error) -> CoreUpgradeState {
        self.coreUpgradeStateResolver.resolve(error: error)
    }

    private func coreUpgradeState(fromMessage message: String) -> CoreUpgradeState {
        self.coreUpgradeStateResolver.resolve(message: message)
    }
}
