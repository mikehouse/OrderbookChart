
import SwiftUI

@MainActor
@Observable
final class RecordingsService {

    private(set) var recordings: [Ticker: (Date, Timer)] = [:]

    func recording(for ticker: Ticker) -> (Date, Timer)? {
        return recordings[ticker]
    }

    func saveRecording(_ ticker: Ticker, date: (Date, Timer)) {
        recordings[ticker] = date
    }

    func removeRecording(_ ticker: Ticker) {
        recordings.removeValue(forKey: ticker)?.1.invalidate()
    }

    func clearRecordings() {
        recordings.forEach { $0.value.1.invalidate() }
        recordings.removeAll()
    }
}
