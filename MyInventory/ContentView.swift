//
//  ContentView.swift
//  MyInventory
//
//  Created by Muhammad Faruuq Qayyum on 07/01/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    enum Tab {
        case inventory
        case laundry
    }
    
    @State private var tab: Tab = .inventory

    var body: some View {
        TabView(selection: $tab) {
            InventoryView()
                .tabItem {
                    Label("My Inventory", systemImage: "tray.2.fill")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
