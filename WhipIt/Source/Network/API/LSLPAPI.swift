//
//  JoinAPI.swift
//  WhipIt
//
//  Created by Chaewon on 11/16/23.
//

import Foundation
import Moya

enum LSLPAPI {
    case signUp(model: SignUpRequest)
    case emailValidation(model: EmailValidationRequest)
    case login(model: LoginRequest)
    case refreshToken
}

extension LSLPAPI: TargetType {
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
        case .refreshToken:
            "refresh"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .signUp, .emailValidation, .login:
            return .post
        case .refreshToken:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .signUp(let model):
            return .requestJSONEncodable(model)
        case .emailValidation(let model):
            return .requestJSONEncodable(model)
        case .login(let model):
            return .requestJSONEncodable(model)
        case .refreshToken:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .signUp, .emailValidation, .login:
            return ["Content-Type": "application/json",
                    "SesacKey" : APIKey.sesacKey]
        case .refreshToken:
            return ["SesacKey" : APIKey.sesacKey]
        }
        
    }
    
    var validationType: ValidationType {
        return .successAndRedirectCodes
    }
    
}
