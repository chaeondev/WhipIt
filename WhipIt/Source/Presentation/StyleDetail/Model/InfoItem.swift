//
//  InfoItem.swift
//  WhipIt
//
//  Created by Chaewon on 12/12/23.
//

import Foundation

struct InfoItem: Hashable {
    let likes: [String]
    let content: String
    let comments: [Comment]
    let hashTags: [String]
}
