//
//  JoinAPI.swift
//  WhipIt
//
//  Created by Chaewon on 11/16/23.
//

import Foundation
import Moya

enum JoinAPI {
    case signUp(model: SignUpRequest)
    case emailValidation(model: EmailValidationRequest)
    case login(model: LoginRequest)
}

extension JoinAPI: TargetType {
    var baseURL: URL {
        guard let url = URL(string: APIKey.baseURL) else {
            print("URL is something wrong")
            return URL(fileURLWithPath: "")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .signUp: 
            "join"
        case .emailValidation: 
            "validation/email"
        case .login: 
            "login"
        }
    }
    
    var method: Moya.Method {
        .post
    }
    
    var task: Moya.Task {
        switch self {
        case .signUp(let model):
            return .requestJSONEncodable(model)
        case .emailValidation(let model):
            return .requestJSONEncodable(model)
        case .login(let model):
            return .requestJSONEncodable(model)
        }
    }
    
    var headers: [String : String]? {
        ["Content-Type": "application/json",
         "SesacKey" : APIKey.sesacKey]
    }
    
    
}