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
    case getPost(limit: String?, next: String?)
    case getPostByID(postID: String)
    case getPostListByUserID(limit: String?, next: String?, userID: String)
    case likePost(postID: String)
    case getLikedPostList(limit: String, next: String?)
    
    //Comment
    case createComment(model: CreateCommentRequest, postID: String)
    case deleteComment(postID: String, commentID: String)
    
    //Profile
    case getMyProfile
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
        case .createPost:
            "post"
        case .getPost:
            "post"
        case .getPostByID(let postID):
            "post/\(postID)"
        case .getPostListByUserID(_,_,let userID):
            "post/user/\(userID)"
        case .likePost(let postID):
            "post/like/\(postID)"
        case .getLikedPostList:
            "post/like/me"
        case .createComment(_, let postID):
            "post/\(postID)/comment"
        case .deleteComment(let postID, let commentID):
            "post/\(postID)/comment/\(commentID)"
        case .getMyProfile:
            "profile/me"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .signUp, .emailValidation, .login, .createPost, .likePost, .createComment:
            return .post
        case .refreshToken, .getPost, .getPostByID, .getPostListByUserID, .getLikedPostList, .getMyProfile:
            return .get
        case .deleteComment:
            return .delete
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
            let ratioData = MultipartFormData(provider: .data(model.content1.data(using: .utf8)!), name: "content1")
            let multipartData: [MultipartFormData] = [imageData, productidData, contentData, ratioData]
            
            return .uploadMultipart(multipartData)
        case .getPost(let limit, let next):
            if let limit {
                return .requestParameters(
                    parameters: ["limit": limit, "product_id": ProductID.test, "next": next ?? "0"],
                    encoding: URLEncoding.queryString
                    )
            } else {
                return .requestParameters(
                    parameters: ["product_id": ProductID.test],
                    encoding: URLEncoding.queryString
                    )
            }
        case .getPostListByUserID(let limit, let next, _):
            if let limit {
                return .requestParameters(
                    parameters: ["limit": limit, "product_id": ProductID.test, "next": next ?? "0"],
                    encoding: URLEncoding.queryString
                    )
            } else {
                return .requestParameters(
                    parameters: ["product_id": ProductID.test],
                    encoding: URLEncoding.queryString
                    )
            }
        case .getPostByID:
            return .requestPlain
        case .likePost:
            return .requestPlain
        case .getLikedPostList(let limit, let next):
            return .requestParameters(
                parameters: ["limit": limit, "next": next ?? "0"],
                encoding: URLEncoding.queryString
            )
        case .createComment(let model, _):
            return .requestJSONEncodable(model)
        case .deleteComment:
            return .requestPlain
        case .getMyProfile:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .signUp, .emailValidation, .login, .createComment:
            return ["Content-Type": "application/json",
                    "SesacKey": APIKey.sesacKey]
        case .refreshToken, .getPost, .getPostByID, .getPostListByUserID, .likePost, .getLikedPostList, .deleteComment, .getMyProfile:
            return ["SesacKey": APIKey.sesacKey]
        case .createPost:
            return ["Content-Type": "multipart/form-data",
                    "SesacKey": APIKey.sesacKey]
        }
        
    }
    
    var validationType: ValidationType {
        return .successAndRedirectCodes
    }
    
}
