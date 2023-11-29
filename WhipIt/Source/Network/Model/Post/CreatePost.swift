//
//  CreatePost.swift
//  WhipIt
//
//  Created by Chaewon on 11/28/23.
//

import Foundation

struct CreatePostRequest: Encodable {
    let product_id: String
    let content: String
    let file: Data
}

struct CreatePostResponse: Decodable {
    let creator: Creator
    let hashTags: [String]
    let likes: [String]
    let image: [String]
    let comments: [String]
    let content: String
    let product_id: String
    let time: String
}

struct Creator: Decodable {
    let nick: String
    let profile: String
}
