//
//  HomeViewModel.swift
//  GitPeek-SwiftUI
//
//  Created by Abhijeet Ranjan  on 18/07/25.
//

import Foundation
import Combine

final class HomeViewModel: ObservableObject {
    
    // MARK: - Public Properties
    
    @Published var secondaryTitleText: String = "Bookmarks"
    @Published var users: [User] = []

    // MARK: - Private Properties
    
    private var debounceWorkItem: DispatchWorkItem?
    private let debounceDelay: TimeInterval = 0.5

    // MARK: - Initialization & Deinitialization
    
    deinit {
        debounceWorkItem?.cancel()
    }

    // MARK: - Public Methods
    
    func filterContent(with query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedQuery.isEmpty {
            secondaryTitleText = "Bookmarks"
            loadBookmarkedUsers()
        } else {
            secondaryTitleText = "Searching..."
            initiateOnlineSearch(for: trimmedQuery)
        }
    }

    // MARK: - Private Search Logic
    
    private func initiateOnlineSearch(for query: String) {
        debounceWorkItem?.cancel()

        let task = DispatchWorkItem { [weak self] in
            self?.performSearch(query: query)
        }

        debounceWorkItem = task
        DispatchQueue.main.asyncAfter(deadline: .now() + debounceDelay, execute: task)
    }

    private func performSearch(query: String) {
        guard !query.isEmpty else {
            self.users = fetchBookmarkedUsers()
            secondaryTitleText = "Bookmarks"
            return
        }

        let escapedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.github.com/search/users?q=\(escapedQuery)"
        let bookmarkedUsers = fetchBookmarkedUsers()

        NetworkManager.shared.request(urlString: urlString) { [weak self] (result: Result<SearchResult, NetworkManager.NetworkError>) in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch result {
                case .success(let searchResult):
                    let enrichedUsers = searchResult.items.map { user -> User in
                        if let savedUser = bookmarkedUsers.first(where: { $0.login == user.login }) {
                            return savedUser
                        } else {
                            return user
                        }
                    }
                    self.users = enrichedUsers.sorted { $0.login.lowercased() < $1.login.lowercased() }

                case .failure(let error):
                    print("Search failed with error: \(error.localizedDescription)")
                    self.users = bookmarkedUsers.filter {
                        $0.login.lowercased().contains(query.lowercased())
                    }.sorted { $0.login.lowercased() < $1.login.lowercased() }
                }
            }
        }
    }

    // MARK: - Bookmark Management
    
    func loadBookmarkedUsers() {
        let bookmarked = fetchBookmarkedUsers()
        DispatchQueue.main.async {
            self.users = bookmarked.sorted { $0.login.lowercased() < $1.login.lowercased() }
            print("Loaded Bookmarked Users: \(bookmarked.map { $0.login })")
        }
    }

    private func fetchBookmarkedUsers() -> [User] {
        let bookmarks = CoreDataManager.shared.fetchAllBookmarks()
        return bookmarks.map { bookmarkedUser in
            User(
                login: bookmarkedUser.login ?? "",
                avatar_url: bookmarkedUser.avatar_url ?? "",
                bio: bookmarkedUser.bio,
                followers: Int(bookmarkedUser.followers),
                public_repos: Int(bookmarkedUser.public_repos),
                isBookmarked: true
            )
        }
    }

    // MARK: - Network Response Models
    
    private struct SearchResult: Decodable {
        let items: [User]
    }
}
