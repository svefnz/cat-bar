import AppKit
import SwiftUI

final class ProxyGroupIconCache: @unchecked Sendable {
    static var shared: ProxyGroupIconCache {
        guard let _shared else { fatalError("Call configure(iconDirectory:) before use") }
        return _shared
    }

    private nonisolated(unsafe) static var _shared: ProxyGroupIconCache?

    static func configure(iconDirectory: URL) {
        self._shared = ProxyGroupIconCache(iconDirectory: iconDirectory)
    }

    private let cache = NSCache<NSURL, NSImage>()
    private let diskDir: URL
    private let tasksLock = NSLock()
    private var inFlightTasks: [URL: Task<NSImage?, Never>] = [:]

    private init(iconDirectory: URL) {
        self.diskDir = iconDirectory
        self.cache.countLimit = 50
        try? FileManager.default.createDirectory(at: iconDirectory, withIntermediateDirectories: true)
    }

    func image(for url: URL) async -> NSImage? {
        let cacheKey = url as NSURL
        if let img = self.cache.object(forKey: cacheKey) { return img }

        let path = self.diskDir.appendingPathComponent(url.cacheKey)
        if let data = try? Data(contentsOf: path), let img = NSImage(data: data) {
            self.cache.setObject(img, forKey: cacheKey)
            return img
        }

        let task: Task<NSImage?, Never> = self.tasksLock.withLock {
            if let existing = self.inFlightTasks[url] {
                return existing
            }
            let newTask = Task<NSImage?, Never> {
                guard let (data, _) = try? await URLSession.shared.data(from: url),
                      let img = NSImage(data: data)
                else { return nil }
                self.cache.setObject(img, forKey: cacheKey)
                try? data.write(to: path)
                return img
            }
            self.inFlightTasks[url] = newTask
            return newTask
        }

        let img = await task.value

        self.tasksLock.withLock {
            _ = self.inFlightTasks.removeValue(forKey: url)
        }

        return img
    }
}

extension URL {
    fileprivate var cacheKey: String {
        self.absoluteString.data(using: .utf8)!.base64EncodedString()
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "-")
    }
}

struct ProxyGroupIconView: View {
    let url: URL
    @State private var nsImage: NSImage?

    var body: some View {
        Group {
            if let nsImage {
                Image(nsImage: nsImage)
                    .resizable()
                    .interpolation(.high)
                    .antialiased(true)
                    .aspectRatio(contentMode: .fit)
            }
        }
        .task(id: self.url) {
            self.nsImage = await ProxyGroupIconCache.shared.image(for: self.url)
        }
    }
}
