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
    
    let profileButton = {
        let view = UIButton.buttonBuilder(title: "더보기", font: UIFont(name: Suit.semiBold, size: 12)!, titleColor: .white)
        view.backgroundColor = .black.withAlphaComponent(0.4)
        return view
    }()
    
    override func setHierarchy() {
        contentView.addSubview(imageView)
        contentView.addSubview(profileButton)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        profileButton.isHidden = true
    }
    
    override func setConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        profileButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
