//
//  FollowerTableCell.swift
//  WhipIt
//
//  Created by Chaewon on 12/21/23.
//

import UIKit
import RxSwift
import RxCocoa

final class FollowerTableCell: UITableViewCell {
    
    let headerView = UIView()
    let userProfileImageView = {
        let view = RoundImageView(frame: .zero)
        view.image = UIImage(systemName: "star")
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .systemGray5
        return view
    }()
    
    let userLabel = UILabel.labelBuilder(text: "macaronron", font: Font.bold16, textColor: .black)
    let userFollowerCntLabel = UILabel.labelBuilder(text: "팔로워 15명", font: Font.light12, textColor: .gray)
    let followButton = {
        let view = FollowButton(frame: .zero)
        view.titleLabel?.font = UIFont(name: Suit.semiBold, size: 12)!
        return view
    }()
    lazy var collectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.register(FollowerCollectionCell.self, forCellWithReuseIdentifier: "followerCollectionCell")
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    var userData: User?
    var userPostList: [Post] = []
    
    private var disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setHierarchy()
        setConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0))
    }
    
    func configureCell() {
        guard let userData else { return }
        userProfileImageView.setKFImage(imageUrl: userData.profile ?? "")
        userLabel.text = userData.nick
    }
    
    func setHierarchy() {
        [userProfileImageView, userLabel, userFollowerCntLabel, followButton].forEach { headerView.addSubview($0) }
        contentView.addSubview(headerView)
        contentView.addSubview(collectionView)
    }
    
    func setConstraints() {
        //headerView.backgroundColor = .blue.withAlphaComponent(0.3)
        headerView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(60)
        }
        userProfileImageView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(8)
            make.leading.equalToSuperview().offset(16)
            make.width.equalTo(userProfileImageView.snp.height)
        }
        userLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalTo(userProfileImageView.snp.trailing).offset(12)
        }
        userFollowerCntLabel.snp.makeConstraints { make in
            make.top.equalTo(userLabel.snp.bottom).offset(2)
            make.leading.equalTo(userProfileImageView.snp.trailing).offset(12)
        }
        followButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-16)
            make.width.equalTo(80)
            make.height.equalTo(30)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(200)
            make.bottom.equalToSuperview()
        }
    }
    
}

extension FollowerTableCell {
    func getUserProfile() {
        guard let userData else { return }
        APIManager.shared.requestGetUserProfile(userID: userData._id)
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let response):
                    owner.userFollowerCntLabel.text = "팔로워 \(response.followers.count)명"
                    owner.collectionView.reloadData()
                case .failure(let error):
                    print("=====user profile error======", error)
                }
            }
            .disposed(by: disposeBag)
    }
    
    func getUserPost() {
        guard let userData else { return }
        APIManager.shared.requestGetPostListByUserID(limit: 6, next: nil, userID: userData._id)
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let response):
                    owner.userPostList = response.data
                    if response.data.count >= 2 && response.data.count  < 5 {
                        owner.collectionView.collectionViewLayout = owner.twoPicCollectionViewLayout()
                    } else if response.data.count >= 5 {
                        owner.collectionView.collectionViewLayout = owner.fivePicCollectionViewLayout()
                    } else {
                        owner.collectionView.snp.remakeConstraints { make in
                            make.top.equalTo(owner.headerView.snp.bottom)
                            make.horizontalEdges.equalToSuperview()
                            make.height.equalTo(0)
                            make.bottom.equalToSuperview()
                        }
                    }
                    owner.collectionView.reloadData()
                case .failure(let error):
                    print("====== user post list refresh error======", error)
                }
            }
            .disposed(by: disposeBag)
    }
}

extension FollowerTableCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if userPostList.count < 2 {
            return 0
        } else if userPostList.count >= 2 && userPostList.count < 5 {
            return 2
        } else if userPostList.count >= 5 {
            return 5
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "followerCollectionCell", for: indexPath) as? FollowerCollectionCell else { return UICollectionViewCell() }
        
        let data = userPostList[indexPath.item]
        cell.imageView.setKFImage(imageUrl: data.image.first ?? "")
        
        return cell
    }
    
    
}

extension FollowerTableCell {
    func twoPicCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            let leadingItem = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                                  heightDimension: .fractionalHeight(1.0)))
            leadingItem.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 4)

            let trailingItem = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                                   heightDimension: .fractionalHeight(1.0)))
            trailingItem.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0)

            let nestedGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .fractionalHeight(1.0)),
                subitems: [leadingItem, trailingItem])
            let section = NSCollectionLayoutSection(group: nestedGroup)
            return section

        }
        return layout
    }
    
    func fivePicCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            let leadingItem = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                                  heightDimension: .fractionalHeight(1.0)))
            leadingItem.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 4)

            let trailingItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.5))
            let trailingItem1 = NSCollectionLayoutItem(layoutSize: trailingItemSize)
            trailingItem1.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 4)
            
            let trailingItem2 = NSCollectionLayoutItem(layoutSize: trailingItemSize)
            trailingItem2.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 4)
            
            let trailingItem3 = NSCollectionLayoutItem(layoutSize: trailingItemSize)
            trailingItem3.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0)
            
            let trailingItem4 = NSCollectionLayoutItem(layoutSize: trailingItemSize)
            trailingItem4.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 0)
            
            let trailingGroup1 = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25),
                                                  heightDimension: .fractionalHeight(1.0)),
                subitems: [trailingItem1, trailingItem2])
            let trailingGroup2 = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25),
                                                   heightDimension: .fractionalHeight(1.0)),
                subitems: [trailingItem3, trailingItem4])

            let nestedGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .fractionalHeight(1.0)),
                subitems: [leadingItem, trailingGroup1, trailingGroup2])
            let section = NSCollectionLayoutSection(group: nestedGroup)
            return section

        }
        return layout
    }
}
