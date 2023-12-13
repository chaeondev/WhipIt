//
//  DeleteComment.swift
//  WhipIt
//
//  Created by Chaewon on 12/13/23.
//

import Foundation

struct DeleteCommentResponse: Decodable {
    let postID: String
    let commentID: String
}
