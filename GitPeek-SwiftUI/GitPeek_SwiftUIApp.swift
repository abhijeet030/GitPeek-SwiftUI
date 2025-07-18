//
//  GitPeek_SwiftUIApp.swift
//  GitPeek-SwiftUI
//
//  Created by Abhijeet Ranjan  on 18/07/25.
//

import SwiftUI

@main
struct GitPeek_SwiftUIApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
