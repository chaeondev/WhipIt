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
    let content1: String
    let file: Data
}

struct CreatePostResponse: Decodable {
    let likes: [String]
    let image: [String]
    let hashTags: [String]
    let comments: [Comment]
    let _id: String
    let creator: Creator
    let time: String
    let content: String
    let content1: String
    let product_id: String

}

struct Creator: Decodable, Hashable {
    let _id: String
    let nick: String
    let profile: String?
}

struct Comment: Decodable, Hashable {
    let _id: String
    let content: String
    let time: String
    let creator: Creator
}
