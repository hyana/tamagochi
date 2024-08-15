import XCTest
@testable import tamagochi_Watch_App

class StepCounterViewModelTests: XCTestCase {

    var viewModel: StepCounterViewModel!

    override func setUp() {
        super.setUp()
        viewModel = StepCounterViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func testInitialState() {
        XCTAssertEqual(viewModel.eggState, .egg)
        XCTAssertEqual(viewModel.message, "🥚 Keep Walking!")
        XCTAssertFalse(viewModel.started)
    }

    func testEggHatching() {
        viewModel.steps = 10000
        viewModel.lastHatchDate = Date()
        viewModel.checkEggHatchOrEvolution()
        
        XCTAssertEqual(viewModel.eggState, .chick)
        XCTAssertEqual(viewModel.message, "🐣 Egg Hatched into a Chick!")
    }

    func testChickPhaseProgression() {
        // Setup for chick phase
        viewModel.eggState = .chick
        viewModel.lastHatchDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        
        // Day 2
        viewModel.steps = 10000
        viewModel.checkEggHatchOrEvolution()
        XCTAssertEqual(viewModel.eggState, .chick)
        XCTAssertEqual(viewModel.message, "🐥 Chick is Growing! Keep Going!")

        // Day 3 to Day 7 (All should progress without death)
        for day in 3...7 {
            viewModel.lastHatchDate = Calendar.current.date(byAdding: .day, value: -day, to: Date())
            viewModel.checkEggHatchOrEvolution()
            XCTAssertEqual(viewModel.eggState, .chick)
            XCTAssertEqual(viewModel.message, "🐥 Chick is Growing! Keep Going!")
        }

        // Day 8: Transition to Chicken
        viewModel.lastHatchDate = Calendar.current.date(byAdding: .day, value: -8, to: Date())
        viewModel.checkEggHatchOrEvolution()
        XCTAssertEqual(viewModel.eggState, .chicken)
        XCTAssertEqual(viewModel.message, "🐔 Chick Evolved into a Chicken!")
    }
    
    func testChickDeath() {
        viewModel.eggState = .chick
        viewModel.lastHatchDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        viewModel.steps = 5000
        viewModel.checkEggHatchOrEvolution()
        
        XCTAssertEqual(viewModel.eggState, .dead)
        XCTAssertEqual(viewModel.message, "💀 The Chick has died.")
    }

    func testChickenPhaseProgression() {
        // Setup for chicken phase
        viewModel.eggState = .chicken
        viewModel.lastHatchDate = Calendar.current.date(byAdding: .day, value: -8, to: Date())
        
        // Days 8-13
        for day in 8...13 {
            viewModel.lastHatchDate = Calendar.current.date(byAdding: .day, value: -day, to: Date())
            viewModel.steps = 10000
            viewModel.checkEggHatchOrEvolution()
            XCTAssertEqual(viewModel.eggState, .chicken)
            XCTAssertEqual(viewModel.message, "🐔 Chicken is Thriving! Keep Going!")
        }
    }

    func testChickenDeath() {
        viewModel.eggState = .chicken
        viewModel.lastHatchDate = Calendar.current.date(byAdding: .day, value: -10, to: Date())
        viewModel.steps = 5000
        viewModel.checkEggHatchOrEvolution()
        
        XCTAssertEqual(viewModel.eggState, .dead)
        XCTAssertEqual(viewModel.message, "💀 The Chicken has died.")
    }

    func testCycleCompletion() {
        viewModel.eggState = .chicken
        viewModel.lastHatchDate = Calendar.current.date(byAdding: .day, value: -14, to: Date())
        viewModel.steps = 10000
        viewModel.checkEggHatchOrEvolution()
        
        XCTAssertEqual(viewModel.eggState, .egg)
        XCTAssertEqual(viewModel.message, "🐣 Chicken laid an Egg! Start over!")
    }
   
    func testRestart() {
        viewModel.eggState = .dead
        viewModel.steps = 5000
        viewModel.lastHatchDate = nil // Resetting the hatch date
        viewModel.checkEggHatchOrEvolution()
        
        viewModel.eggState = .egg
        viewModel.steps = 0
        viewModel.message = "🚶‍♂️ Keep Walking!"
    }

    func testStartTracking() {
        viewModel.startTracking()
        
        XCTAssertTrue(viewModel.started)
    }
}
