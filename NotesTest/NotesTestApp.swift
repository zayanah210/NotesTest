//
//  NotesTestApp.swift
//  NotesTest
//
//  Created by Tuhin Mahmud on 3/10/24.
//

import SwiftUI

@main
struct NotesTestApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
