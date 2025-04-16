import XCTest

final class MovieQuizUITests: XCTestCase {
    // swiftlint:disable:next implicitly_unwrapped_optional
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    func testYesButton() {
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }

    func testNoButton() {
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }
    
    func testAlertIsShownAfterRoundEnds() {
        sleep(3)

        for _ in 1...10 {
            app.buttons["Yes"].tap()
            sleep(2)
        }

        let alert = app.alerts["Этот раунд окончен!"]
        XCTAssertTrue(alert.exists, "Алерт не появился по окончании раунда")

        let alertButton = alert.buttons["Сыграть ещё раз"]
        XCTAssertTrue(alertButton.exists, "Кнопка 'Сыграть ещё раз' отсутствует в алерте")
    }
    
    func testAlertDismissedAndGameRestarted() {
        sleep(3)

        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }

        let alert = app.alerts["Этот раунд окончен!"]
        XCTAssertTrue(alert.exists, "Алерт не появился по окончании раунда")

        alert.buttons["Сыграть ещё раз"].tap()
        sleep(2)

        XCTAssertFalse(app.alerts["Этот раунд окончен!"].exists, "Алерт не исчез после нажатия на кнопку")

        let indexLabel = app.staticTexts["Index"]
        XCTAssertTrue(indexLabel.exists)
        XCTAssertEqual(indexLabel.label, "1/10", "Счётчик не сбросился к 1/10")
    }
    
}
