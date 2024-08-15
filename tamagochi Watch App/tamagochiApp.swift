import SwiftUI
import HealthKit

enum EggState {
    case egg, chick, chicken, dead
}

class StepCounterViewModel: ObservableObject {
    private var healthStore = HKHealthStore()
    @Published var steps: Int = 0
    @Published var eggState: EggState = .egg
    @Published var message: String = "🥚 Keep Walking!"
    @Published var started: Bool = false
    
    @Published var lastHatchDate: Date?
    @Published var lastEvolutionDate: Date?

    init() {
        authorizeHealthKit()
    }

    func startTracking() {
        started = true
        fetchStepCount()
        startObservingSteps()
    }

    func simulateSteps() {
        // Scenario 1: Simulate egg hatching
        self.steps = 10000
        self.lastHatchDate = Date() // Set hatch date to today
        self.checkEggHatchOrEvolution()
        
        // Scenario 2: Simulate chick evolution (after 7 days)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in // Simulate day 8
            guard let self = self else { return }
            self.steps = 10000
            self.lastHatchDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) // Hatch date 7 days ago
            self.checkEggHatchOrEvolution()
        }
        
        // Scenario 3: Simulate chicken laying an egg (after 14 days)
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) { [weak self] in // Simulate day 15
            guard let self = self else { return }
            self.steps = 10000
            self.lastHatchDate = Calendar.current.date(byAdding: .day, value: -14, to: Date()) // Hatch date 14 days ago
            self.checkEggHatchOrEvolution()
        }
    }

    func authorizeHealthKit() {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let healthKitTypes: Set = [stepType]

        healthStore.requestAuthorization(toShare: nil, read: healthKitTypes) { (success, error) in
            if !success {
                print("Authorization failed.")
            }
        }
    }

    func startObservingSteps() {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let query = HKObserverQuery(sampleType: stepType, predicate: nil) { [weak self] _, completionHandler, error in
            if let error = error {
                print("Error in HKObserverQuery: \(error)")
                return
            }
            
            self?.fetchStepCount()
            completionHandler()
        }
        
        healthStore.execute(query)
        healthStore.enableBackgroundDelivery(for: stepType, frequency: .immediate) { success, error in
            if !success {
                print("Failed to enable background delivery of steps: \(String(describing: error))")
            }
        }
    }

    func fetchStepCount() {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let startDate = Calendar.current.startOfDay(for: Date())
        let endDate = Date()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] (_, result, error) in
            guard let self = self else { return }
            var steps = 0

            if let quantity = result?.sumQuantity() {
                steps = Int(quantity.doubleValue(for: HKUnit.count()))
            }

            DispatchQueue.main.async {
                self.steps = steps
                self.checkEggHatchOrEvolution()
            }
        }

        healthStore.execute(query)
    }

    func checkEggHatchOrEvolution() {
        let now = Date()
        let calendar = Calendar.current

        guard let lastHatchDate = lastHatchDate else {
            return
        }

        let daysSinceHatch = calendar.dateComponents([.day], from: lastHatchDate, to: now).day ?? 0

        switch eggState {
        case .egg:
            if steps >= 10000 {
                eggState = .chick
                message = "🐣 Egg Hatched into a Chick!"
            }
        case .chick:
            if daysSinceHatch == 1 {
                // Day 2 of chick phase
                if steps >= 10000 {
                    message = "🐥 Chick is Growing! Keep Going!"
                } else {
                    eggState = .dead
                    message = "💀 The Chick has died."
                }
            } else if daysSinceHatch >= 2 && daysSinceHatch <= 7 {
                // Days 3-7 of chick phase
                if steps >= 10000 {
                    message = "🐥 Chick is Growing! Keep Going!"
                } else {
                    eggState = .dead
                    message = "💀 The Chick has died."
                }
            } else if daysSinceHatch > 7 {
                // Transition to chicken phase
                if steps >= 10000 {
                    eggState = .chicken
                    message = "🐔 Chick Evolved into a Chicken!"
                } else {
                    eggState = .dead
                    message = "💀 The Chick has died."
                }
            }
        case .chicken:
            if daysSinceHatch >= 7 && daysSinceHatch < 14 {
                // Days 8-13 of chicken phase
                if steps >= 10000 {
                    message = "🐔 Chicken is Thriving! Keep Going!"
                } else {
                    eggState = .dead
                    message = "💀 The Chicken has died."
                }
            } else if daysSinceHatch >= 14 {
                // Day 14 of chicken phase
                if steps >= 10000 {
                    eggState = .egg
                    message = "🐣 Chicken laid an Egg! Start over!"
                } else {
                    eggState = .dead
                    message = "💀 The Chicken has died."
                }
            }
        case .dead:
            // Dead state, no further evolution
            break
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = StepCounterViewModel()
    
    var body: some View {
        VStack {
            if viewModel.started {
                Text(viewModel.message)
                    .font(.largeTitle)
                    .padding()
                
                Text("Steps: \(viewModel.steps)")
                    .padding()
                
                if viewModel.eggState == .dead {
                    Button(action: {
                        viewModel.eggState = .egg
                        viewModel.steps = 0
                        viewModel.message = "🚶‍♂️ Keep Walking!"
                    }) {
                        Text("Restart")
                            .font(.title)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            } else {
                Button(action: {
                    viewModel.startTracking()
                }) {
                    Text("Start")
                        .font(.largeTitle)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .onAppear {
            if viewModel.started {
                viewModel.fetchStepCount()
            }
        }
    }
}

@main
struct StepCounterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
