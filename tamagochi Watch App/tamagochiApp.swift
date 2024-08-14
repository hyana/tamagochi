import SwiftUI
import HealthKit

enum EggState {
    case egg, chick, chicken, dead
}

class StepCounterViewModel: ObservableObject {
    private var healthStore = HKHealthStore()
    @Published var steps: Int = 0
    @Published var eggState: EggState = .egg
    @Published var message: String = "🚶‍♂️ Keep Walking!"
    
    private var lastHatchDate: Date?
    private var lastEvolutionDate: Date?
    
    init() {
        #if DEBUG
        simulateSteps() // Simulate steps in debug mode
        #else
        authorizeHealthKit()
        fetchStepCount()
        #endif
    }

    func simulateSteps() {
        // Scenario 1: Simulate egg hatching
        self.steps = 10000
        self.lastHatchDate = Date() // Set hatch date to today
        self.checkEggHatchOrEvolution()
        
        // Scenario 2: Simulate chick evolution (next day)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in // Simulate another next day
          guard let self = self else { return }
          self.steps = 10000
          self.lastHatchDate = Calendar.current.date(byAdding: .day, value: -1, to: Date()) // Hatch date remains same
          self.checkEggHatchOrEvolution()
      }
        
        // Scenario 3: Simulate chick death (next day without enough steps)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 6) { [weak self] in // Simulate another next day
//            guard let self = self else { return }
//            self.steps = 5000
//            self.lastHatchDate = Calendar.current.date(byAdding: .day, value: -1, to: Date()) // Hatch date remains same
//            self.checkEggHatchOrEvolution()
//        }
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
        switch eggState {
        case .egg:
            if steps >= 10000 {
                eggState = .chick
                lastHatchDate = Date()
                message = "🐣 Egg Hatched into a Chick!"
            }
        case .chick:
            if let lastDate = lastHatchDate, Calendar.current.isDateInToday(lastDate) {
                if steps >= 10000 {
                    eggState = .chicken
                    lastEvolutionDate = Date()
                    message = "🐔 Chick Evolved into a Chicken!"
                }
            } else if let lastDate = lastHatchDate, Calendar.current.isDateInYesterday(lastDate) {
                if steps < 10000 {
                    eggState = .dead
                    message = "💀 The Chick has died."
                }
            }
        case .chicken, .dead:
            // Chick is already evolved or dead, no further evolution
            break
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = StepCounterViewModel()
    
    var body: some View {
        VStack {
            Text(viewModel.message)
                .font(.largeTitle)
                .padding()
            
            Text("Steps: \(viewModel.steps)")
                .padding()
        }
        .onAppear {
            viewModel.fetchStepCount()
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
