//
//  Si8c_v3_1App.swift
//  Si8c_v3.1
//
//  Created by Eran on 04/03/2025.
//

import SwiftUI

@main
struct Si8c_v3_1App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
