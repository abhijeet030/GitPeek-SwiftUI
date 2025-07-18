//
//  GitPeek_SwiftUIApp.swift
//  GitPeek-SwiftUI
//
//  Created by Abhijeet Ranjan  on 18/07/25.
//

import SwiftUI

@main
struct GitPeekApp: App {
    let coreDataManager = CoreDataManager.shared

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, coreDataManager.container.viewContext)
        }
    }
}
