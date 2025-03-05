//
//  Si8c_v3_1App.swift
//  Si8c_v3.1
//
//  Created by Eran on 04/03/2025.
//

import SwiftUI

@main
struct Si8c_v3_1App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 800, minHeight: 600)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}
