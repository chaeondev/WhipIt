//
//  FollowResponse.swift
//  WhipIt
//
//  Created by Chaewon on 12/19/23.
//

import Foundation

struct FollowResponse: Decodable {
    let user: String
    let following: String
    let following_status: Bool
}
