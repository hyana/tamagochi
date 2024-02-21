//
//  ContentView.swift
//  tamagochi Watch App
//
//  Created by Hyana Kang on 2/20/24.
//

import SwiftUI
import CoreMotion


struct InteractiveView: View {
    @ObservedObject var viewModel: TamagotchiViewModel
    let maxLevel = 100
    let minLevel = 0
    let timerInterval = 10.0

    var body: some View {
        VStack {
            Text("tama")
                .font(.title)
                .padding()
            
            Spacer()
            
            VStack {
                Text("Hunger: \(viewModel.hungerLevel)")
                Text("Happiness: \(viewModel.happinessLevel)")
                Text("Cleanliness: \(viewModel.cleanlinessLevel)")
            }
            
            Spacer()
            
            HStack {
                Button(action: {
                    feed()
                }) {
                    Text("Feed")
                }
                
                Spacer()
                
                Button(action: {
                    play()
                }) {
                    Text("Play")
                }
                
                Spacer()
                                
                Button(action: {
                    clean()
                }) {
                    Text("Clean")
                }
            }
            .padding()
        }
        .onAppear {
           startTimer()
       }
    }
    
    func feed() {
        if viewModel.hungerLevel < maxLevel {
            viewModel.hungerLevel += 10
            if viewModel.happinessLevel > minLevel {
                viewModel.happinessLevel -= 5
            }
        }
    }
    
    func play() {
        if viewModel.happinessLevel < maxLevel {
            viewModel.happinessLevel += 10
            if viewModel.hungerLevel > minLevel {
                viewModel.hungerLevel -= 5
            }
        }
    }
    
    func clean() {
        if viewModel.cleanlinessLevel < maxLevel {
            viewModel.cleanlinessLevel += 10
            }
        }

    
  func startTimer() {
      Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { timer in
          decreaseLevels()
      }
  }
  
  func decreaseLevels() {
      if viewModel.hungerLevel > minLevel {
          viewModel.hungerLevel -= 5
      }
      
      if viewModel.happinessLevel > minLevel {
          viewModel.happinessLevel -= 5
      }
      
      if viewModel.cleanlinessLevel > minLevel {
          viewModel.cleanlinessLevel -= 5
      }
  }
}


class TamagotchiViewModel: ObservableObject {
    @Published var totalSteps: Int = 0
    @Published var isEggHatched: Bool = false
    @Published var showInteractiveView: Bool = false
    
    @Published var happinessLevel: Int = 50
    @Published var cleanlinessLevel: Int = 50
    @Published var hungerLevel: Int = 50
    
    private var pedometer: CMPedometer?
    
    init() {
        pedometer = CMPedometer()
    }
    
    func startStepCounting() {
//        guard CMPedometer.isStepCountingAvailable() else {
//            print("Step counting is not available on this device.")
//            return
//        }
        
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: Date())
        
//        pedometer?.startUpdates(from: startDate) { [weak self] (pedometerData, error) in
//            let self = self, error == nil, let pedometerData = pedometerData
//            guard let self = self, error == nil, let pedometerData = pedometerData else {
//                print("Error retrieving pedometer data: \(error?.localizedDescription ?? "Unknown error")")
//                return
//            }
            
            let totalSteps = 10000
//            let totalSteps = pedometerData.numberOfSteps.intValue
            print("Total steps: \(totalSteps)")
            self.totalSteps = totalSteps

            // Check if total steps reach 10000
            if totalSteps == 10000 && !self.isEggHatched {
                // Hatching the egg
                self.isEggHatched = true
        }
    }
}

struct HatchingView: View {
    @ObservedObject var viewModel: TamagotchiViewModel

    var body: some View {
        VStack {
            if viewModel.isEggHatched {
                Text("Your egg has hatched!")
                    .font(.headline)
                    .padding()

                Button("Start") {
                    viewModel.showInteractiveView = true
                }
                .padding()
            } else {
                StepCountView(viewModel: viewModel)
            }
        }
        .onAppear {
            viewModel.startStepCounting() // Call startStepCounting when HatchingView appears
        }
    }
}

struct StepCountView: View {
    @ObservedObject var viewModel: TamagotchiViewModel
    
    var body: some View {
        Text("Step Count View: \(viewModel.totalSteps)")
            .padding()
    }
}
