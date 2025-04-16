import Foundation

final class StatisticService: StatisticServiceProtocol {
    private let storage: UserDefaults = .standard

    private enum Keys: String {
        case correct
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
        case gamesCount
        case totalAccuracy
        case correctAnswers
    }

    init() {
        self.gamesCount = gamesCount
        self.bestGame = bestGame
        self.totalAccuracy = totalAccuracy
        self.correctAnswers = correctAnswers
    }

    var gamesCount: Int {
        get {
            return storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }

    var correctAnswers: Int {
        get {
            return storage.integer(forKey: Keys.correctAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.correctAnswers.rawValue)
        }
    }

    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date =
                storage.object(forKey: Keys.bestGameDate.rawValue) as? Date
                ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }

    var totalAccuracy: Double {
        get {
            return storage.double(forKey: Keys.totalAccuracy.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalAccuracy.rawValue)
        }
    }

    func store(correct: Int, total amount: Int) {
        gamesCount += 1
        correctAnswers += correct

        let newGame = GameResult(correct: correct, total: amount, date: Date())

        if newGame.total > 0 {
            totalAccuracy =
                (Double(correctAnswers) / Double(gamesCount * 10)) * 100
        }

        if !bestGame.isBetterThan(newGame) {
            bestGame = newGame
        }
    }

}
