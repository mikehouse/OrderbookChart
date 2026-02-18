
import Foundation

actor FileService {

    static let shared = FileService()

    func read(_ name: String, searchPath: FileManager.SearchPathDirectory = .cachesDirectory) throws -> Data? {
        let url = try FileManager.default.url(for: searchPath, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(name)
        print("Reading \(name) from \(url.path)")
        if FileManager.default.fileExists(atPath: url.path) {
            return try Data(contentsOf: url)
        }
        return nil
    }

    func write(_ data: Data, name: String, searchPath: FileManager.SearchPathDirectory = .cachesDirectory) throws {
        let url = try FileManager.default.url(for: searchPath, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(name)
        print("Writing \(name) to \(url.path)")
        try data.write(to: url)
    }
}