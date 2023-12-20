//
//  GetMyProfile.swift
//  WhipIt
//
//  Created by Chaewon on 12/14/23.
//

import Foundation

struct GetProfileResponse: Decodable, Hashable {
    let posts: [String]
    let followers: [User]
    let following: [User]
    let _id: String
    let email: String?
    let nick: String
    let phoneNum: String?
    let profile: String?
}
