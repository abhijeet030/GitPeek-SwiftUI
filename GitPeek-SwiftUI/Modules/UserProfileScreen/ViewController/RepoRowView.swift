//
//  RepoRowView.swift
//  GitPeek-SwiftUI
//
//  Created by Abhijeet Ranjan  on 18/07/25.
//

import SwiftUI

struct RepoRowView: View {
    let repo: RepositoryModel

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(repo.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Text(repo.description ?? "No description available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .truncationMode(.tail)

                HStack(spacing: 16) {
                    Label("\(repo.stargazers_count)", systemImage: "star.fill")
                    Label("\(repo.forks_count)", systemImage: "tuningfork")
                    Label("\(repo.watchers_count)", systemImage: "eye.fill")
                }
                .font(.caption)
                .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal)
        .padding(.bottom, 4)
    }
}
