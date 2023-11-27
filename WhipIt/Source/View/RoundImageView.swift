//
//  RoundImageView.swift
//  WhipIt
//
//  Created by Chaewon on 11/26/23.
//

import UIKit
import SnapKit

final class RoundImageView: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.width / 2
    }
    
    func configureView() {
        clipsToBounds = true
        
    }
}
