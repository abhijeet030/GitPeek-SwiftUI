//
//  UserDetailModel.swift
//  GitPeek-SwiftUI
//
//  Created by Abhijeet Ranjan  on 18/07/25.
//

import Foundation

struct RepositoryModel: Decodable, Equatable, Hashable {
    let name: String
    let html_url: String
    let description: String?
    let language: String?
    let stargazers_count: Int
    let forks_count: Int
    let watchers_count: Int
}
