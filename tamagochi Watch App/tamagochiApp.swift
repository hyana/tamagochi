//
//  tamagochiApp.swift
//  tamagochi Watch App
//
//  Created by Hyana Kang on 2/20/24.
//

import SwiftUI

@main
struct tamagochi_Watch_App: App {

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}
    

struct MainTabView: View {
    @StateObject private var viewModel = TamagotchiViewModel()

    var body: some View {
        TabView {
        if !viewModel.showInteractiveView {
            HatchingView(viewModel: viewModel)
                .tabItem {
                    Label("Step Count", systemImage: "figure.walk")
                }
        }
        InteractiveView(viewModel: viewModel)
            .tabItem {
                Label("Interactive", systemImage: "gamecontroller")
            }
        }
    }
}
