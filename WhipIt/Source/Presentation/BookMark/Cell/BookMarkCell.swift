//
//  BookMarkCell.swift
//  WhipIt
//
//  Created by Chaewon on 12/14/23.
//

import UIKit

final class BookMarkCell: BaseCollectionViewCell {
    
    let imageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .blue
        return view
    }()
    
    override func setHierarchy() {
        super.setHierarchy()
        contentView.addSubview(imageView)
    }
    
    override func setConstraints() {
        super.setConstraints()
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
