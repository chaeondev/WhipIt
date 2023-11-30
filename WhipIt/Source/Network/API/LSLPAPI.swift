//
//  JoinAPI.swift
//  WhipIt
//
//  Created by Chaewon on 11/16/23.
//

import Foundation
import Moya

enum LSLPAPI {
    //회원가입, 로그인
    case signUp(model: SignUpRequest)
    case emailValidation(model: EmailValidationRequest)
    case login(model: LoginRequest)
    
    //토큰 refresh
    case refreshToken
    
    //Post
    case createPost(model: CreatePostRequest)
}

extension LSLPAPI: TargetType {
    var baseURL: URL {
        guard let url = URL(string: APIKey.testURL) else {
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
        case .createPost:
            "post"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .signUp, .emailValidation, .login, .createPost:
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
        case .createPost(let model):
            let imageData = MultipartFormData(provider: .data(model.file), name: "file", fileName: "\(model.file).jpeg", mimeType: "image/jpeg")
            let productidData = MultipartFormData(provider: .data(model.product_id.data(using: .utf8)!), name: "product_id")
            let contentData = MultipartFormData(provider: .data(model.content.data(using: .utf8)!), name: "content")
            let multipartData: [MultipartFormData] = [imageData, productidData, contentData]
            
            return .uploadMultipart(multipartData)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .signUp, .emailValidation, .login:
            return ["Content-Type": "application/json",
                    "SesacKey" : APIKey.sesacKey]
        case .refreshToken:
            return ["SesacKey" : APIKey.sesacKey]
        case .createPost:
            return ["Content-Type": "multipart/form-data",
                    "SesacKey": APIKey.sesacKey]
        }
        
    }
    
    var validationType: ValidationType {
        return .successAndRedirectCodes
    }
    
}
