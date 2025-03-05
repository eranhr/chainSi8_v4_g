//
//  ContentView.swift
//  Si8c_v3.1
//
//  Created by Eran on 04/03/2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var viewModel = MainViewModel()
    
    var body: some View {
        HSplitView {
            LeftPaneView(viewModel: viewModel)
                .frame(minWidth: 250, maxWidth: .infinity)
            
            MiddlePaneView(viewModel: viewModel)
                .frame(minWidth: 400, maxWidth: .infinity)
            
            RightPaneView(viewModel: viewModel)
                .frame(minWidth: 250, maxWidth: .infinity)
        }
        .frame(minWidth: 900, minHeight: 600)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
