//
//  AIMemoirsApp.swift
//  AIMemoirs
//
//  Created by 贝贝 on 2025/6/19.
//

import SwiftUI

@main
struct AIMemoirsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
