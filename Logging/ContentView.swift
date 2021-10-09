//
//  ContentView.swift
//  Logging
//
//  Created by Joshua Homann on 9/24/21.
//

import Combine
import SwiftUI
import UIKit


struct ContentView: View {
    private let title = "Root view"
    @State private var showList = false
    @State private var showAnalytics = false
    var body: some View {
        return NavigationView {
            VStack {
                Button("Show Analytics") {
                    Log.navigation.debug("Tap show analytics")
                    showAnalytics.toggle()
                }
                Button {
                    Log.navigation.log("Tap show list")
                    showList.toggle()
                } label: {
                    Label("First Button", systemImage: "circle")
                }
                .overlay(NavigationLink("", isActive: $showList) { ListView() } )
            }
            .onAppear { Log.navigation.log("\(title) did appear")}
            .sheet(isPresented: $showAnalytics) {
                LogView()
            }
            .navigationTitle(title)
        }
    }
}

struct ListView: View {
    private let title = "List view"
    var body: some View {
        VStack {
            List (0..<1000) { number in
                NavigationLink("\(number)", destination: Text("\(number)"))
                    .onAppear { Log.navigation.log("\(number) did appear")}
            }
            .onAppear { Log.navigation.log("\(title) did appear") }
            .navigationTitle(title)
        }
    }
}

