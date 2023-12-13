//
//  CommentView.swift
//  WhipIt
//
//  Created by Chaewon on 12/12/23.
//

import UIKit

final class CommentView: UIView {
    
    private lazy var borderView = UIView.barViewBuilder(color: .systemGray4)
    
    private lazy var button1 = {
        let view = UIButton.buttonBuilder(title: "좋아요 🩶", font: UIFont(name: Suit.light, size: 14)!, titleColor: .gray)
        view.addTarget(self, action: #selector(autoCommentButtonClicked), for: .touchUpInside)
        return view
    }()
    private lazy var button2 = {
        let view = UIButton.buttonBuilder(title: "맞팔해요 ☺️", font: UIFont(name: Suit.light, size: 14)!, titleColor: .gray)
        view.addTarget(self, action: #selector(autoCommentButtonClicked), for: .touchUpInside)
        return view
    }()
    private lazy var button3 = {
        let view = UIButton.buttonBuilder(title: "정보 부탁해요 🙏", font: UIFont(name: Suit.light, size: 14)!, titleColor: .gray)
        view.addTarget(self, action: #selector(autoCommentButtonClicked), for: .touchUpInside)
        return view
    }()
    private lazy var button4 = {
        let view = UIButton.buttonBuilder(title: "평소 사이즈가 궁금해요 👀", font: UIFont(name: Suit.light, size: 14)!, titleColor: .gray)
        view.addTarget(self, action: #selector(autoCommentButtonClicked), for: .touchUpInside)
        return view
    }()
    
    private lazy var buttonStackView = UIStackView.stackViewBuilder(axis: .horizontal, distribution: .equalSpacing, spacing: 8, alignment: .fill)
    
    private lazy var scrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    
    lazy var profileImageView = {
        let view = RoundImageView(frame: .zero)
        view.image = UIImage(systemName: "star")
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .systemGray5
        return view
    }()
    
    lazy var commentTextField = CommentTextField()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        setHierarchy()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func autoCommentButtonClicked(_ sender: UIButton) {
        guard let autoText = sender.titleLabel?.text else { return }
        if let originalText = commentTextField.text {
            commentTextField.text = originalText + autoText
        } else {
            commentTextField.text = autoText
        }
        
    }
    
}

extension CommentView {
    func setHierarchy() {
        [button1, button2, button3, button4].forEach { buttonStackView.addArrangedSubview($0) }
        scrollView.addSubview(buttonStackView)
        [borderView, scrollView, profileImageView, commentTextField].forEach { self.addSubview($0) }
        
        
    }
    
    func setConstraints() {
        
        borderView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(1)
        }

        button1.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.width.greaterThanOrEqualTo(70)
        }
        button2.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(80)
        }
        button3.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(100)
        }
        button4.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(160)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(50)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.height.equalTo(scrollView.snp.height)
            make.horizontalEdges.equalTo(scrollView)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(20)
            make.size.equalTo(35)
        }
        
        commentTextField.snp.makeConstraints { make in
            make.centerY.equalTo(profileImageView)
            make.leading.equalTo(profileImageView.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
       
    }
}
