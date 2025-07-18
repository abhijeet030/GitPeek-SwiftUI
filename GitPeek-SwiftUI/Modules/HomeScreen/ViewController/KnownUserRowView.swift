//
//  KnownUserRowView.swift
//  GitPeek-SwiftUI
//
//  Created by Abhijeet Ranjan  on 18/07/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct KnownUserRowView: View {
    let user: User

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .foregroundColor(.gray.opacity(0.3))
                    .frame(width: 48, height: 48)

                WebImage(url: URL(string: user.avatar_url))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(user.login)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(user.bio?.isEmpty == false ? user.bio! : "—")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                HStack(spacing: 12) {
                    Label("\(user.followers ?? 0)", systemImage: "person.2.fill")
                    Label("\(user.public_repos ?? 0)", systemImage: "shippingbox.fill")
                }
                .font(.caption)
                .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}
