//
//  GetPost.swift
//  WhipIt
//
//  Created by Chaewon on 11/30/23.
//

import Foundation

struct GetPostResponse: Decodable, Hashable {
    let data: [Post]
    let next_cursor: String
}

struct Post: Decodable, Hashable {
    let likes: [String]
    let image: [String]
    let hashTags: [String]
    let comments: [Comment]
    let _id: String
    let creator: Creator
    let time: String
    let content: String
    let product_id: String
}

