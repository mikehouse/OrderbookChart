
import Foundation

actor FileService {

    static let shared = FileService()

    func read(
        _ name: String,
        maxAge: TimeInterval? = nil,
        searchPath: FileManager.SearchPathDirectory = .cachesDirectory
    ) throws -> Data? {
        let url = try FileManager.default.url(for: searchPath, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(name)
        print("Reading \(name) from \(url.path)")
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }

        if let maxAge {
            let values = try url.resourceValues(forKeys: [.contentModificationDateKey])
            guard let modificationDate = values.contentModificationDate else {
                print("Cache \(name) has no modification date, fetching from API.")
                return nil
            }
            if Date().timeIntervalSince(modificationDate) > maxAge {
                print("Cache \(name) is stale, fetching from API.")
                return nil
            }
        }

        return try Data(contentsOf: url)
    }

    func write(_ data: Data, name: String, searchPath: FileManager.SearchPathDirectory = .cachesDirectory) throws {
        let url = try FileManager.default.url(for: searchPath, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(name)
        print("Writing \(name) to \(url.path)")
        try data.write(to: url)
    }
}
