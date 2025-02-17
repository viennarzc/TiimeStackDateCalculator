//
//  TimeStackDateCalculatorApp.swift
//  TimeStackDateCalculator
//
//  Created by Viennarz Curtiz on 2/17/25.
//

import SwiftUI

@main
struct TimeStackDateCalculatorApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
