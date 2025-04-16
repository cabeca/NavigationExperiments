//
//  NavigationExperimentsApp.swift
//  NavigationExperiments
//
//  Created by Miguel Cabeça on 2025-04-04.
//

import SwiftUI

@main
struct NavigationExperimentsApp: App {
    @StateObject private var model = ChargeModel()
    @State var isPresented: Bool = false

    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationStack {
                    VStack {
                        Text("Hello, World!")
                        Button("Charge") {
                            isPresented = true
                        }
                    }
                    .navigationDestination(isPresented: $isPresented) {
                        ChargeView(model: model)
                    }
                    .navigationTitle("HomeView")
                }
                    .tabItem {
                        Text("Content")
                    }
                Color.red
                    .tabItem {
                        Text("red")
                    }
                Color.blue
                    .tabItem {
                        Text("blue")
                    }
            }
        }
    }
}
