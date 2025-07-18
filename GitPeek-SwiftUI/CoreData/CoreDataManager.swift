//
//  CoreDataManager.swift
//  GitPeek-SwiftUI
//
//  Created by Abhijeet Ranjan  on 18/07/25.
//

import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()
    
    let container: NSPersistentContainer
    
    private init() {
        container = NSPersistentContainer(name: "GitPeek_SwiftUI")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func saveBookmark(_ user: User, repositories: [RepositoryModel] = []) {
        container.performBackgroundTask { context in
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

            let bookmark: BookmarkedUser
            
            if let existing = self.fetchBookmarkedUser(by: user.login, in: context) {
                bookmark = existing
            } else {
                bookmark = BookmarkedUser(context: context)
                bookmark.login = user.login
            }
            
            bookmark.avatar_url = user.avatar_url
            bookmark.bio = user.bio
            bookmark.followers = Int64(user.followers ?? 0)
            bookmark.public_repos = Int64(user.public_repos ?? 0)

            if !repositories.isEmpty {
                if let existingRepos = bookmark.repositories as? Set<Repository> {
                    existingRepos.forEach { context.delete($0) }
                }

                repositories.forEach { repoModel in
                    let repo = Repository(context: context)
                    repo.name = repoModel.name
                    repo.html_url = repoModel.html_url
                    repo.repoDescription = repoModel.description
                    repo.language = repoModel.language
                    repo.stargazers_count = Int64(repoModel.stargazers_count)
                    repo.forks_count = Int64(repoModel.forks_count)
                    repo.watchers_count = Int64(repoModel.watchers_count)
                    repo.user = bookmark
                }
            }
            
            self.save(context: context)
        }
    }

    func removeBookmark(login: String) {
        container.performBackgroundTask { context in
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            let fetchRequest: NSFetchRequest<BookmarkedUser> = BookmarkedUser.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "login == %@", login)
            fetchRequest.fetchLimit = 1
            if let result = try? context.fetch(fetchRequest), let object = result.first {
                context.delete(object)
                self.save(context: context)
            }
        }
    }

    func isBookmarked(login: String) -> Bool {
        return fetchBookmarkedUser(by: login, in: container.viewContext) != nil
    }

    func fetchAllBookmarks() -> [BookmarkedUser] {
        let fetchRequest: NSFetchRequest<BookmarkedUser> = BookmarkedUser.fetchRequest()
        do {
            return try container.viewContext.fetch(fetchRequest)
        } catch {
            print("Failed to fetch all bookmarks: \(error)")
            return []
        }
    }
    
    func fetchBookmarkedUser(by login: String) -> BookmarkedUser? {
        return fetchBookmarkedUser(by: login, in: container.viewContext)
    }

    private func fetchBookmarkedUser(by login: String, in context: NSManagedObjectContext) -> BookmarkedUser? {
        let fetchRequest: NSFetchRequest<BookmarkedUser> = BookmarkedUser.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "login == %@", login)
        fetchRequest.fetchLimit = 1
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Fetch failed for \(login): \(error)")
            return nil
        }
    }

    private func save(context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
}
