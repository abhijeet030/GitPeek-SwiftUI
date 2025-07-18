//
//  HomeModel.swift
//  GitPeek-SwiftUI
//
//  Created by Abhijeet Ranjan  on 18/07/25.
//

import Foundation

struct User: Decodable, Equatable{
    let login: String
    let avatar_url: String
    var bio: String?
    var followers: Int?
    var public_repos: Int?
    
    var isBookmarked: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case login
        case avatar_url
        case bio
        case followers
        case public_repos
    }
}


