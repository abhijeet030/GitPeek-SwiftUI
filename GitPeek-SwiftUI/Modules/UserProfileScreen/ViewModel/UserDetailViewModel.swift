//
//  UserDetailViewModel.swift
//  GitPeek-SwiftUI
//
//  Created by Abhijeet Ranjan  on 18/07/25.
//

import Foundation
import Combine

class UserDetailViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published private(set) var user: User
    @Published private(set) var repositories: [RepositoryModel] = []

    // MARK: - Computed Properties
    
    var username: String { user.login }
    var bio: String { user.bio ?? Constants.noBioAvailable }
    var avatarURL: String { user.avatar_url }
    var followers: Int { user.followers ?? 0 }
    var publicReposCount: Int { user.public_repos ?? 0 }

    // MARK: - Pagination & State
    
    private var currentPage = 1
    private var isLoadingMore = false
    private var canLoadMore = true
    private var isFetchingUserData = false

    // MARK: - Initialization
    
    init(user: User) {
        self.user = user
    }

    // MARK: - Bookmark Management
    
    func toggleBookmark() {
        user.isBookmarked.toggle()
        if user.isBookmarked {
            CoreDataManager.shared.saveBookmark(user, repositories: repositories)
        } else {
            CoreDataManager.shared.removeBookmark(login: user.login)
        }
    }

    // MARK: - Fetch User Details
    
    func fetchUserData() {
        guard !isFetchingUserData, NetworkMonitor.shared.isConnected else { return }
        isFetchingUserData = true

        let detailURL = Constants.githubUsersBaseURL + user.login
        NetworkManager.shared.request(urlString: detailURL) { [weak self] (result: Result<User, NetworkManager.NetworkError>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isFetchingUserData = false

                switch result {
                case .success(var fullUser):
                    if self.user.isBookmarked {
                        fullUser.isBookmarked = true
                        CoreDataManager.shared.saveBookmark(fullUser)
                    }
                    self.user = fullUser

                case .failure(let error):
                    print("❌ Failed to fetch user data: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Fetch Public Repositories (Online or Offline)
    
    func fetchPublicRepositories(reset: Bool = false) {
        guard !isLoadingMore else { return }
        isLoadingMore = true

        if reset {
            currentPage = 1
            canLoadMore = true
            repositories = []
        }

        if NetworkMonitor.shared.isConnected {
            fetchRepositoriesOnline()
        } else {
            fetchRepositoriesOffline()
        }
    }

    private func fetchRepositoriesOffline() {
        defer { isLoadingMore = false }

        guard let bookmarkedUser = CoreDataManager.shared.fetchBookmarkedUser(by: user.login),
              let storedRepos = bookmarkedUser.repositories as? Set<Repository> else {
            print("⚠️ No local data found for user: \(user.login)")
            return
        }

        let repoModels = storedRepos.map { repo in
            RepositoryModel(
                name: repo.name ?? "",
                html_url: repo.html_url ?? "",
                description: repo.repoDescription,
                language: repo.language,
                stargazers_count: Int(repo.stargazers_count),
                forks_count: Int(repo.forks_count),
                watchers_count: Int(repo.watchers_count)
            )
        }

        DispatchQueue.main.async {
            self.repositories = repoModels.sorted { $0.name.lowercased() < $1.name.lowercased() }
        }
    }

    private func fetchRepositoriesOnline() {
        guard canLoadMore else {
            isLoadingMore = false
            return
        }

        let urlString = "\(Constants.githubUsersBaseURL)\(user.login)/repos?page=\(currentPage)&per_page=\(Constants.reposPerPage)"

        NetworkManager.shared.request(urlString: urlString) { [weak self] (result: Result<[RepositoryModel], NetworkManager.NetworkError>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoadingMore = false

                switch result {
                case .success(let repos):
                    if repos.isEmpty {
                        self.canLoadMore = false
                    } else {
                        let combinedSet = Set(self.repositories + repos)
                        self.repositories = Array(combinedSet).sorted { $0.name.lowercased() < $1.name.lowercased() }
                        self.currentPage += 1

                        if self.user.isBookmarked {
                            CoreDataManager.shared.saveBookmark(self.user, repositories: self.repositories)
                        }
                    }

                case .failure(let error):
                    print("❌ Pagination error: \(error.localizedDescription)")
                    self.canLoadMore = false
                }
            }
        }
    }

    // MARK: - Constants
    
    private struct Constants {
        static let noBioAvailable = "No bio available"
        static let githubUsersBaseURL = "https://api.github.com/users/"
        static let reposPerPage = 20
    }
}
