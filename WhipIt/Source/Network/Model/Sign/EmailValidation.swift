//
//  EmailValidation.swift
//  WhipIt
//
//  Created by Chaewon on 11/16/23.
//

import Foundation

struct EmailValidationRequest: Encodable {
    let email: String
}

struct EmailValidationResponse: Decodable {
    let message: String
}
