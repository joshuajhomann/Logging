//
//  Log.swift
//  Logging
//
//  Created by Joshua Homann on 9/24/21.
//

import OSLog
import Foundation

enum Log {
    static let subsystem = Bundle.main.bundleIdentifier ?? ""
    static let navigation = Logger(subsystem: Self.subsystem, category: Name.navigation.rawValue)
    static let analytics = Logger(subsystem: Self.subsystem, category: Name.analytics.rawValue)
    enum Name: String, Hashable, CaseIterable {
        case analytics
        case navigation
    }
    static func entries(for names: [Name], since seconds: TimeInterval) throws -> [OSLogEntryLog] {
        let logStore = try OSLogStore(scope: .currentProcessIdentifier)
        let position = logStore.position(date: .now.addingTimeInterval(-seconds))
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates:[
            NSPredicate(format: "subsystem == %@", Self.subsystem),
            NSCompoundPredicate(orPredicateWithSubpredicates: names.map(\.rawValue).map { NSPredicate(format: "category == %@", $0) })
        ])
        let entries = try logStore.getEntries(with: [.reverse], at: position, matching: predicate)
        return entries.compactMap { $0 as? OSLogEntryLog }
    }
}
