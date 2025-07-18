//
//  HomeView.swift
//  GitPeek-SwiftUI
//
//  Created by Abhijeet Ranjan  on 18/07/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var searchText = ""

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 8) {
                // Search Bar
                SearchBar(text: $searchText, placeholder: "Search GitHub Users")
                    .onChange(of: searchText) {
                        viewModel.filterContent(with: searchText)
                    }
                    .padding(.horizontal)

                Text(viewModel.secondaryTitleText)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.horizontal)
                    .padding(.top, 4)

                List(viewModel.users, id: \.login) { user in
                    NavigationLink(destination: UserDetailView(user: user)) {
                        if user.isBookmarked {
                            KnownUserRowView(user: user)
                        } else {
                            UserRowView(user: user)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("GitPeek")
            .onAppear {
                viewModel.filterContent(with: searchText)
            }
        }
    }
}
