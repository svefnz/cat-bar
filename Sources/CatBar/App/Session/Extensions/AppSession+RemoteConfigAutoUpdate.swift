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
                let dueSubscriptions = self.remoteConfigSubscriptions.filter { $0.value.isDue() }
                if !dueSubscriptions.isEmpty {
                    for (fileName, _) in dueSubscriptions {
                        guard !Task.isCancelled else { return }
                        await self.refreshRemoteConfigFile(named: fileName)
                    }
                }

                guard !Task.isCancelled else { return }
                try? await Task.sleep(nanoseconds: 300_000_000_000)
            }
        }
    }

    func cancelRemoteConfigAutoUpdate() {
        self.remoteConfigAutoUpdateTask?.cancel()
        self.remoteConfigAutoUpdateTask = nil
    }
}
