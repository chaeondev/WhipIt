//
//  SignUp.swift
//  WhipIt
//
//  Created by Chaewon on 11/16/23.
//

import Foundation

struct SignUpRequest: Encodable {
    let email: String
    let password: String
    let nick: String
    let phoneNum: String?
}

struct SignUpResponse: Decodable {
    let email: String
    let nick: String
}
