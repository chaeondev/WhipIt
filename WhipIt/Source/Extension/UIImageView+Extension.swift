//
//  UIImageView+Extension.swift
//  WhipIt
//
//  Created by Chaewon on 12/1/23.
//

import UIKit
import Kingfisher

extension UIImageView {
    
    func setKFImage(imageUrl: String, errorImage: UIImage? = nil) {
        let modifier = AnyModifier { request in
            var requestBody = request
            requestBody.setValue(KeyChainManager.shared.accessToken, forHTTPHeaderField: "Authorization")
            requestBody.setValue(APIKey.sesacKey, forHTTPHeaderField: "SesacKey")
            return requestBody
        }
        
        let url = URL(string: APIKey.baseURL + imageUrl)
        
        self.kf.indicatorType = .activity
        self.kf.setImage(with: url, placeholder: UIImage(resource: .user), options: [.requestModifier(modifier)])
    }
}
