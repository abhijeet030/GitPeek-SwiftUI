//
//  UserRowView.swift
//  GitPeek-SwiftUI
//
//  Created by Abhijeet Ranjan  on 18/07/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct UserRowView: View {
    let user: User

    var body: some View {
        HStack(spacing: 16) {
            WebImage(url: URL(string: user.avatar_url))
                .resizable()
                .indicator(.activity)
                .scaledToFill()
                .frame(width: 48, height: 48)
                .clipShape(Circle())
                .shadow(radius: 2)

            VStack(alignment: .leading, spacing: 4) {
                Text(user.login)
                    .font(.headline)
                    .foregroundColor(.primary)

                if !user.login.isEmpty {
                    Text(user.login)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
