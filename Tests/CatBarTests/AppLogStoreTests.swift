import XCTest
@testable import CatBar

final class AppLogStoreTests: XCTestCase {
    private var tempDirectory: URL!
    private var logFileURL: URL!

    override func setUp() {
        super.setUp()
        self.tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try! FileManager.default.createDirectory(at: self.tempDirectory, withIntermediateDirectories: true)
        self.logFileURL = self.tempDirectory.appendingPathComponent("test.log", isDirectory: false)
    }

    override func tearDown() {
        if FileManager.default.fileExists(atPath: self.tempDirectory.path) {
            try? FileManager.default.removeItem(at: self.tempDirectory)
        }
        super.setUp() // Wait, calling super.tearDown() is correct.
        super.tearDown()
    }

    func testAppendUnderLimitDoesNotRotate() {
        let policy = AppLogRotationPolicy(maxFileSizeBytes: 1000, maxBackupCount: 2)
        let store = AppLogStore(logFileURL: self.logFileURL, rotationPolicy: policy)

        let entry = AppErrorLogEntry(source: .catbar, level: "info", message: "Hello World")
        store.append(entries: [entry])

        XCTAssertTrue(FileManager.default.fileExists(atPath: self.logFileURL.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: self.logFileURL.appendingPathExtension("1").path))

        let content = try! String(contentsOf: self.logFileURL, encoding: .utf8)
        XCTAssertTrue(content.contains("Hello World"))
    }

    func testAppendOverLimitRotates() {
        // 使用非常小的限制 (50 字节) 以强制触发滚动
        let policy = AppLogRotationPolicy(maxFileSizeBytes: 50, maxBackupCount: 2)
        let store = AppLogStore(logFileURL: self.logFileURL, rotationPolicy: policy)

        // 写入第一条日志
        let entry1 = AppErrorLogEntry(source: .catbar, level: "info", message: "First message")
        store.append(entries: [entry1])

        // 验证文件存在且未轮转
        XCTAssertTrue(FileManager.default.fileExists(atPath: self.logFileURL.path))
        let backup1URL = self.logFileURL.appendingPathExtension("1")
        XCTAssertFalse(FileManager.default.fileExists(atPath: backup1URL.path))

        // 写入第二条日志，触发滚动
        let entry2 = AppErrorLogEntry(source: .catbar, level: "info", message: "Second message that is quite long")
        store.append(entries: [entry2])

        // 验证已发生轮转
        XCTAssertTrue(FileManager.default.fileExists(atPath: self.logFileURL.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: backup1URL.path))

        // 第一条日志应该被挪到备份文件 test.log.1
        let backupContent = try! String(contentsOf: backup1URL, encoding: .utf8)
        XCTAssertTrue(backupContent.contains("First message"))

        // 第二条日志应该在最新的 test.log 中
        let mainContent = try! String(contentsOf: self.logFileURL, encoding: .utf8)
        XCTAssertTrue(mainContent.contains("Second message"))
        XCTAssertFalse(mainContent.contains("First message"))
    }

    func testRotationCapping() {
        // 最大备份数为 2，单文件限制 50 字节
        let policy = AppLogRotationPolicy(maxFileSizeBytes: 50, maxBackupCount: 2)
        let store = AppLogStore(logFileURL: self.logFileURL, rotationPolicy: policy)

        let entries = [
            AppErrorLogEntry(source: .catbar, level: "info", message: "Msg 1"),
            AppErrorLogEntry(source: .catbar, level: "info", message: "Msg 2"),
            AppErrorLogEntry(source: .catbar, level: "info", message: "Msg 3"),
            AppErrorLogEntry(source: .catbar, level: "info", message: "Msg 4"),
        ]

        // 每次写入一条以强行触发多次滚动检查
        for entry in entries {
            store.append(entries: [entry])
        }

        let backup1URL = self.logFileURL.appendingPathExtension("1")
        let backup2URL = self.logFileURL.appendingPathExtension("2")
        let backup3URL = self.logFileURL.appendingPathExtension("3")

        XCTAssertTrue(FileManager.default.fileExists(atPath: self.logFileURL.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: backup1URL.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: backup2URL.path))
        // 备份上限是 2，所以 test.log.3 不应当存在（Msg 1 应该被丢弃）
        XCTAssertFalse(FileManager.default.fileExists(atPath: backup3URL.path))

        let mainContent = try! String(contentsOf: self.logFileURL, encoding: .utf8)
        let backup1Content = try! String(contentsOf: backup1URL, encoding: .utf8)
        let backup2Content = try! String(contentsOf: backup2URL, encoding: .utf8)

        XCTAssertTrue(mainContent.contains("Msg 4"))
        XCTAssertTrue(backup1Content.contains("Msg 3"))
        XCTAssertTrue(backup2Content.contains("Msg 2"))
    }

    func testClear() {
        let store = AppLogStore(logFileURL: self.logFileURL)
        let entry = AppErrorLogEntry(source: .catbar, level: "info", message: "To Be Cleared")
        store.append(entries: [entry])

        XCTAssertTrue(FileManager.default.fileExists(atPath: self.logFileURL.path))
        XCTAssertTrue((try! String(contentsOf: self.logFileURL, encoding: .utf8)).contains("To Be Cleared"))

        store.clear()

        XCTAssertTrue(FileManager.default.fileExists(atPath: self.logFileURL.path))
        let contentAfterClear = try! String(contentsOf: self.logFileURL, encoding: .utf8)
        XCTAssertTrue(contentAfterClear.isEmpty)
    }
}
