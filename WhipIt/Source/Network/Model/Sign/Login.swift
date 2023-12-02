//
//  Login.swift
//  WhipIt
//
//  Created by Chaewon on 11/16/23.
//

import Foundation

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct LoginResponse: Decodable {
    let _id: String
    let token: String
    let refreshToken: String
}
