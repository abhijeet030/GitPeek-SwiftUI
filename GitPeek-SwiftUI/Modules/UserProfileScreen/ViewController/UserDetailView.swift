//
//  UserDetailView.swift
//  GitPeek-SwiftUI
//
//  Created by Abhijeet Ranjan  on 18/07/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct UserDetailView: View {
    @StateObject private var viewModel: UserDetailViewModel

    init(user: User) {
        _viewModel = StateObject(wrappedValue: UserDetailViewModel(user: user))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(alignment: .center, spacing: 16) {
                WebImage(url: URL(string: viewModel.avatarURL))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray.opacity(0.5), lineWidth: 1))

                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.username)
                        .font(.title)
                        .fontWeight(.bold)

                    if !viewModel.bio.isEmpty {
                        Text(viewModel.bio)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                    }

                    HStack(spacing: 16) {
                        Label("\(viewModel.followers) followers", systemImage: "person.2.fill")
                        Label("\(viewModel.publicReposCount) repos", systemImage: "folder.fill")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            .padding()

            Divider()

            // Repositories List
            Text("Repositories")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top)

            List(viewModel.repositories, id: \.name) { repo in
                RepoRowView(repo: repo)
                    .onAppear {
                        if repo == viewModel.repositories.last {
                            viewModel.fetchPublicRepositories()
                        }
                    }
            }
            .listStyle(.plain)
        }
        .onAppear {
            viewModel.fetchUserData()
            viewModel.fetchPublicRepositories()
        }
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.toggleBookmark()
                }) {
                    Image(systemName: viewModel.user.isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.title3)
                }
            }
        }
    }
}
