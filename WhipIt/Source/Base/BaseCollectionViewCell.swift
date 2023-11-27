//
//  BaseCollectionViewCell.swift
//  WhipIt
//
//  Created by Chaewon on 11/26/23.
//

import UIKit
import SnapKit

class BaseCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setHierarchy()
        setConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setHierarchy() { }
    func setConstraints() { }
}
