
import Foundation

@Observable final class AppContext {

    let binance: ApiInterface
    let bybit: ApiInterface
    let userDefaults: UserDefaults
    let recordingsService: RecordingsService

    init(
        binance: ApiInterface,
        bybit: ApiInterface,
        userDefaults: UserDefaults,
        recordingsService: RecordingsService
    ) {
        self.binance = binance
        self.bybit = bybit
        self.userDefaults = userDefaults
        self.recordingsService = recordingsService
    }
}
