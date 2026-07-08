import Foundation

@MainActor
extension AppSession {
    func scheduleRemoteConfigAutoUpdateIfNeeded() {
        self.remoteConfigAutoUpdateTask?.cancel()

        let hasAutoUpdate = remoteConfigSubscriptions.values.contains { $0.autoUpdateEnabled }
        guard hasAutoUpdate else { return }

        self.remoteConfigAutoUpdateTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 300_000_000_000)
                guard !Task.isCancelled else { return }

                let dueSubscriptions = self.remoteConfigSubscriptions.filter { $0.value.isDue() }
                guard !dueSubscriptions.isEmpty else { continue }

                for (fileName, _) in dueSubscriptions {
                    guard !Task.isCancelled else { return }
                    await self.refreshRemoteConfigFile(named: fileName)
                }
            }
        }
    }

    func cancelRemoteConfigAutoUpdate() {
        self.remoteConfigAutoUpdateTask?.cancel()
        self.remoteConfigAutoUpdateTask = nil
    }
}
