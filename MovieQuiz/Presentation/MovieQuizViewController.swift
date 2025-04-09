import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var titleTextLabel: UILabel!

    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var statisticService: StaticServiceProtocol?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        let questionFactory = QuestionFactory()
        questionFactory.setup(delegate: self)
        self.questionFactory = questionFactory
        questionFactory.requestNextQuestion()

        statisticService = StatisticService()
        alertPresenter = AlertPresenter(viewController: self)
        setFonts()
    }

    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)

        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }

    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == true)
    }

    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == false)
    }

    private func setFonts() {
        textLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
        counterLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        titleTextLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        yesButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        noButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
    }

    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor =
            isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor

        if isCorrect { self.correctAnswers += 1 }
        setButtonsState(to: false)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
            self.setButtonsState(to: true)
        }
    }

    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService?
                .store(
                    correct: self.correctAnswers,
                    total: self.questionsAmount
                )

            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            let dateString = dateFormatter.string(
                from: statisticService?.bestGame.date ?? Date())

            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: """
                    Ваш результат: \(self.correctAnswers)/\(questionsAmount)
                    Количество сыгранных квизов: \(statisticService?.gamesCount ?? 0)
                    Рекорд: \(statisticService?.bestGame.correct ?? 0)/\(statisticService?.bestGame.total ?? 0) (\(dateString))
                    Средняя точность: \(String(format: "%.2f", statisticService?.totalAccuracy ?? 0))%
                    """,
                buttonText: "Сыграть ещё раз",
                completion: { [weak self] in self?.restartQuiz() }
            )
            alertPresenter?.showAlert(model: alertModel)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }

    private func convert(model: QuizQuestion) -> QuizStepModel {
        return QuizStepModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }

    private func show(quiz step: QuizStepModel) {
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        imageView.layer.borderWidth = 0
    }

    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert
        )

        let action = UIAlertAction(title: result.buttonText, style: .default) {
            [weak self] _ in

            guard let self = self else { return }

            self.restartQuiz()
        }

        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }

    private func restartQuiz() {
        self.currentQuestionIndex = 0
        self.correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }

    private func setButtonsState(to state: Bool) {
        yesButton.isEnabled = state
        noButton.isEnabled = state
    }
}
