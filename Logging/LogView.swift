//
//  LogView.swift
//  Logging
//
//  Created by Joshua Homann on 10/9/21.
//

import SwiftUI

struct LogView: View {

    @StateObject private var viewModel = LogViewModel()
    @State private var showShare = false
    // MARK: - View
    var body: some View {
        NavigationView  {
            VStack {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach (viewModel.logs.indices) { index in
                            Toggle(viewModel.logs[index].title, isOn: .init(
                                get: { viewModel.logs[index].isEnabled },
                                set: { _ in viewModel.selectLog(index: index)}
                            ))
                                .background(Color(.systemGray6))
                                .toggleStyle(.button)
                        }
                    }
                    .padding()
                }
                .toolbar {
                    Button(action: { showShare.toggle() }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                .disabled(!viewModel.isLoaded)
                Spacer()
                switch viewModel.items {
                case let .success(items):
                    List(items) { item in
                        VStack(alignment: .leading) {
                            Text(item.date).font(.caption2)
                            Text(item.message)
                        }
                    }
                case let .failure(error):
                    Text(error.localizedDescription)
                case .none:
                    ProgressView()
                    Text("Loading...")
                }
                Spacer()
            }
            .task { await viewModel.onAppear() }
            .refreshable { await viewModel.refresh() }
            .navigationBarTitle("Logs", displayMode: .inline)
            .sheet(isPresented: $showShare) {
                ShareSheet(activityItems: [viewModel.export()])
            }
        }
    }
}
