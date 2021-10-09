//
//  LogViewModel.swift
//  Logging
//
//  Created by Joshua Homann on 10/9/21.
//

import Foundation


@MainActor
final class LogViewModel: ObservableObject {

    @Published private(set) var items: Result<[Item], Error>? = nil
    @Published var logs: [Logs] = []
    var isLoaded: Bool {
        switch items {
        case.success: return true
        case .failure, .none: return false
        }
    }

    struct Item: Identifiable {
        var id: String { date + message }
        var date: String
        var message: String
    }

    struct Logs: Identifiable  {
        var id: String { title }
        var title: String
        var name: Log.Name
        var isEnabled: Bool
    }

    init() {
        logs = Log.Name.allCases.map {
            Logs(title: $0.rawValue, name: $0, isEnabled: true)
        }
    }

    func onAppear() async {
        Log.navigation.log("\(Self.self) did appear")
        await fetch()
    }

    func refresh() async {
        Log.analytics.log("Pull to refresh")
        await fetch()
    }

    func export() -> String {
        (try? items?.get().map { "\($0.date) \($0.message)" } )?.joined(separator: "\n") ?? ""
    }

    func selectLog(index: Int) {
        logs[index].isEnabled.toggle()
        items = nil
        Task.detached(priority: .userInitiated) { [weak self] in
            await self?.fetch()
        }
    }

    private nonisolated func fetch() async {
        let categories = await logs.filter(\.isEnabled).map(\.name).reduce(into: []) { $0.append($1) }
        let entries = Result { try Log.entries(for: categories, since: 60) }
        let items = entries.map {
            $0.map {
                Item(
                    date: $0.date.formatted(),
                    message: $0.composedMessage
                )
            }
        }
        DispatchQueue.main.async { [weak self] in
            self?.items = items
        }
    }
}
