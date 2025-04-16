protocol StaticServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    var correctAnswers: Int { get }

    func store(correct: Int, total amount: Int)
}
