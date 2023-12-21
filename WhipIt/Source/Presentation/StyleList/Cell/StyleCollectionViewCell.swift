//
//  StyleCollectionViewCell.swift
//  WhipIt
//
//  Created by Chaewon on 11/26/23.
//

import UIKit
import Kingfisher
import RxSwift
import RxCocoa

protocol StyleCellDelegate: AnyObject {
    func updateCollectionView()
    func transitionView(accoutType: AccountType, userID: String)
}

final class StyleCollectionViewCell: BaseCollectionViewCell {
    
    private lazy var photoImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .blue
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        return view
    }()
    
    private lazy var userImageView: UIImageView = {
        let view = RoundImageView(frame: .zero)
        view.image = UIImage(systemName: "star")
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .systemGray5
        return view
    }()
    
    private lazy var userNickLabel: UILabel = UILabel.labelBuilder(text: "위핏이620", font: Font.light12, textColor: .darkGray)
    
    lazy var userButton = UIButton()
    
    lazy var bookMarkButton: UIButton = BookmarkButton()
    
    private lazy var bookMarkCntLabel: UILabel = UILabel.labelBuilder(text: "168", font: Font.light12, textColor: .gray)
    
    private lazy var contentLabel: UILabel = {
        let view = UILabel.labelBuilder(text: "#코지챌린지 \n 궂은 날씨에도 포근하게 감싸줄 아우터!", font: UIFont(name: Suit.medium, size: 12)!, textColor: .black, numberOfLines: 2)
        view.lineBreakMode = .byWordWrapping //말줄임표 X
        view.sizeToFit()
        return view
    }()
    
    var stylePost: Post!
    
    var delegate: StyleCellDelegate?
    
    var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
        
        photoImageView.kf.cancelDownloadTask()
        photoImageView.image = nil
        
        userImageView.kf.cancelDownloadTask()
        userImageView.image = nil
    }
    
    func configureCell() {
        let imageUrl = stylePost.image[0]
        let profileUrl = stylePost.creator.profile
        photoImageView.setKFImage(imageUrl: imageUrl)
        userImageView.setKFImage(imageUrl: profileUrl ?? "")
        userNickLabel.text = stylePost.creator.nick
        bookMarkCntLabel.text = "\(stylePost.likes.count)"
        contentLabel.text = stylePost.content
        
        guard let userID = KeyChainManager.shared.userID else { return }
        bookMarkButton.isSelected = stylePost.likes.contains(userID)
    }
    
    @objc func bookmarkButtonClicked() {
        APIManager.shared.requestLikePost(postID: stylePost._id)
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let response):
                    print("===북마크 실행===")
                    owner.bookMarkButton.isSelected = response.like_status
                    owner.delegate?.updateCollectionView()
                case .failure(let error):
                    print("=====북마크 에러======", error)
                }
            }
            .disposed(by: disposeBag)
            
            
    }
    
    @objc func userButtonClicked() {

        let accountType: AccountType = stylePost.creator._id == KeyChainManager.shared.userID ? .me : .user
        delegate?.transitionView(accoutType: accountType, userID: stylePost.creator._id)
        
    }
    
    override func setHierarchy() {
        [photoImageView, userImageView, userNickLabel, userButton, bookMarkCntLabel, bookMarkButton, contentLabel].forEach { contentView.addSubview($0) }
        
        bookMarkButton.addTarget(self, action: #selector(bookmarkButtonClicked), for: .touchUpInside)
        userButton.addTarget(self, action: #selector(userButtonClicked), for: .touchUpInside)
    }
    
    override func setConstraints() {
        photoImageView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(contentView)
        }
        
        userImageView.snp.makeConstraints { make in
            make.top.equalTo(photoImageView.snp.bottom).offset(8)
            make.leading.equalTo(contentView).offset(4)
            make.size.equalTo(20)
        }
        //userNickLabel.backgroundColor = .blue
        userNickLabel.snp.makeConstraints { make in
            make.centerY.equalTo(userImageView)
            make.leading.equalTo(userImageView.snp.trailing).offset(8)
            make.width.lessThanOrEqualTo(photoImageView).multipliedBy(0.5)
        }
        
        userButton.snp.makeConstraints { make in
            make.top.equalTo(photoImageView.snp.bottom).offset(4)
            make.leading.equalToSuperview()
            make.trailing.equalTo(userNickLabel)
            make.height.equalTo(25)
        }
        
        bookMarkCntLabel.snp.makeConstraints { make in
            make.centerY.equalTo(userImageView)
            make.trailing.equalToSuperview().inset(8)
        }
        
        bookMarkButton.snp.makeConstraints { make in
            make.centerY.equalTo(userImageView)
            make.trailing.equalTo(bookMarkCntLabel.snp.leading).offset(-4)
            make.size.equalTo(20)
        }
      
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(userImageView.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(contentView).inset(4)
            make.height.greaterThanOrEqualTo(20)
            make.bottom.equalTo(contentView).inset(8)
        }
    }
}
