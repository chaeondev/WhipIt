//
//  FollowerCollectionCell.swift
//  WhipIt
//
//  Created by Chaewon on 12/21/23.
//

import UIKit

final class FollowerCollectionCell: BaseCollectionViewCell {
    
    let imageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.backgroundColor = .blue
        return view
    }()
    
    override func setHierarchy() {
        contentView.addSubview(imageView)
    }
    
    override func setConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
