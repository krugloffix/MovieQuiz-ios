import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []

    init(
        moviesLoader: MoviesLoading,
        delegate: QuestionFactoryDelegate? = nil
    ) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }

    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }

    func setup(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
    }

    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0

            guard let movie = self.movies[safe: index] else { return }

            var imageData = Data()

            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    let error = NSError(
                        domain: "com.quizapp.image",
                        code: -1,
                        userInfo: [
                            NSLocalizedDescriptionKey:
                                "Не удалось загрузить постер фильма"
                        ]
                    )
                    self.delegate?.didFailToLoadData(with: error)
                }
                return
            }

            let rating = Float(movie.rating) ?? 0

            let randomNumber = (1...10).randomElement() ?? 1
            let randomComparison = (0...10).randomElement() ?? 0 % 2 == 0
            let text =
                "Рейтинг этого фильма "
                + (randomComparison ? "больше" : "меньше")
                + " чем \(randomNumber)?"

            let correctAnswer =
                randomComparison
                ? Int(
                    rating
                ) > randomNumber : Int(rating) < randomNumber

            let question = QuizQuestion(
                image: imageData,
                text: text,
                correctAnswer: correctAnswer)

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}
