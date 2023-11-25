//
//  ImageViewBuilder.swift
//  WhipIt
//
//  Created by Chaewon on 11/25/23.
//

import UIKit

extension UIImageView {
    static func imageViewBuilder(tintColor: UIColor, image: UIImage) -> UIImageView {
        let view = UIImageView()
        view.image = image
        view.tintColor = tintColor
        view.contentMode = .scaleAspectFill
        return view
    }
    
}
