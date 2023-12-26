//
//  MyAccountViewController.swift
//  WhipIt
//
//  Created by Chaewon on 11/26/23.
//

import UIKit
import RxSwift
import RxCocoa

enum ProfileSection: Int, CaseIterable {
    case profile
    case post
}

enum AccountType {
    case me
    case user
}

class MyAccountViewController: BaseViewController {
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    
    var accountType: AccountType!
    var userID: String?
    
    var dataSource: UICollectionViewDiffableDataSource<ProfileSection, AnyHashable>!
    
    //headerView Data
    var postCnt: Int! = 0 {
        didSet {
            self.applyNewSnapshot()
        }
    }
    var bookCnt: Int! = 0 {
        didSet {
            self.applyNewSnapshot()
        }
    }
    
    var profile: GetProfileResponse!
    var postList: [Post] = []
    var nextCursor: String = ""
    
    var isFollowing = BehaviorSubject(value: false)
    
    var disposeBag = DisposeBag()
    
    private let viewModel = MyAccountViewModel()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        configureDataSource()
        configureSnapshot()
        bind()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        
        collectionView.delegate = self
    }
    
    private func bind() {
        guard let userID else { return }
        let input = MyAccountViewModel.Input(
            accountType: self.accountType,
            userID: userID
        )
        let output = viewModel.transform(input: input)

        output.profileResult
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let response):
                    let isFollowing = response.followers.map { $0._id }.contains(KeyChainManager.shared.userID)
                    owner.isFollowing.onNext(isFollowing)
                    owner.profile = response
                    owner.postCnt = response.posts.count
                    owner.configureSnapshotForProfile(profile: response)
                case .failure(let error):
                    print("=====profile error======", error)
                }
            }
            .disposed(by: self.disposeBag)

        
        output.postResult
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let response):
                    owner.postList = response.data
                    owner.nextCursor = response.next_cursor
                    let ratios = response.data.map {
                        let floatRatio: CGFloat = CGFloat(NSString(string: $0.content1).floatValue)
                        return Ratio(ratio: floatRatio * 0.75)
                    }
                    let layout = PinterestLayout(columnsCount: 2, itemRatios: ratios, spacing: 10, contentWidth: owner.view.frame.width)
                    owner.collectionView.collectionViewLayout = owner.updateLayout(section: layout.section)
                    owner.configureSnapshotForPosts(posts: response.data)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
        
        output.likeCnt
            .bind(with: self) { owner, cnt in
                owner.bookCnt = cnt
            }
            .disposed(by: disposeBag)
        

    }
    
    func setNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont(name: Suit.bold, size: 17)!,
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        appearance.configureWithOpaqueBackground()
        appearance.shadowColor = .clear
        appearance.backgroundColor = .white
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .black
        navigationItem.backButtonDisplayMode = .minimal
        
        if accountType == .me {
            navigationItem.title = "내 프로필"
        } else {
            navigationItem.title = ""
        }
        
    }
    
    override func setHierarchy() {
        super.setHierarchy()
        view.addSubview(collectionView)
    }
    
    override func setConstraints() {
        super.setConstraints()
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension MyAccountViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if collectionView.contentOffset.y >= 80 {
            navigationItem.title = profile.nick
        } else {
            navigationItem.title = accountType == .me ? "내 프로필" : ""
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            let vc = StyleDetailViewController()
            vc.postData = postList[indexPath.item]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

private extension MyAccountViewController {

    func configureDataSource() {
        let profileCell = UICollectionView.CellRegistration<ProfileCollectionCell, GetProfileResponse> { cell, indexPath, itemIdentifier in
            
            cell.configureCell(profile: itemIdentifier, accountType: self.accountType)
            cell.followerButton.addTarget(self, action: #selector(self.followerButtonClicked), for: .touchUpInside)
            cell.followingButton.addTarget(self, action: #selector(self.followingButtonClicked), for: .touchUpInside)
            cell.profileSettingButton.addTarget(self, action: #selector(self.settingButtonClicked), for: .touchUpInside)
            if self.accountType == .user {
                self.isFollowing
                    .bind(with: self) { owner, bool in
                        cell.followButton.isSelected = bool
                    }
                    .disposed(by: self.disposeBag)
                cell.followButton.addTarget(self, action: #selector(self.followButtonClicked), for: .touchUpInside)
            }
        }
        
        let postCell = UICollectionView.CellRegistration<StyleCollectionViewCell, Post> { cell, indexPath, itemIdentifier in
            cell.stylePost = itemIdentifier
            cell.configureCell()
        }
        
        collectionView.register(AccountHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")

        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let section = ProfileSection.allCases[indexPath.section]
            switch section {
            case .profile:
                return collectionView.dequeueConfiguredReusableCell(using: profileCell, for: indexPath, item: itemIdentifier as? GetProfileResponse)
            case .post:
                return collectionView.dequeueConfiguredReusableCell(using: postCell, for: indexPath, item: itemIdentifier as? Post)
            }
        })
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }

            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? AccountHeaderView
            view?.remakeConstraints(accountType: self.accountType)
            view?.configureView(postCnt: self.postCnt, bookCnt: self.bookCnt)
            view?.bookmarkButton.addTarget(self, action: #selector(self.bookmarkButtonClicked), for: .touchUpInside)

            return view
        }
        
        
    }
    
    @objc func settingButtonClicked() {
        let vc = ProfileSettingViewController()
        vc.profile = profile
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func bookmarkButtonClicked() {
        tabBarController?.selectedIndex = 1
    }
    
    @objc func followerButtonClicked() {
        let vc = FollowerViewController()
        vc.followType = .follower
        vc.profile = profile
        vc.accountType = accountType
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func followingButtonClicked() {
        let vc = FollowerViewController()
        vc.followType = .following
        vc.profile = profile
        vc.accountType = accountType
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func followButtonClicked(_ sender: UIButton) {
        
        if !sender.isSelected {
            APIManager.shared.requestFollow(userID: profile._id)
                .asObservable()
                .subscribe(with: self) { owner, result in
                    switch result {
                    case .success(let response):
                        sender.isSelected = response.following_status
                        owner.updateProfile()
                    case .failure(let error):
                        var message: String {
                            switch error {
                            case .serverConflict: return "이미 팔로윙된 계정입니다."
                            case .notFound: return "알 수 없는 계정입니다."
                            default: return "네트워크 오류로 팔로우가 되지 않았습니다. 다시 시도해주세요"
                            }
                        }
                        owner.showAlertMessage(title: "팔로우 오류", message: message)
                    }
                }
                .disposed(by: disposeBag)
        } else {
            APIManager.shared.requestUnFollow(userID: profile._id)
                .asObservable()
                .subscribe(with: self) { owner, result in
                    switch result {
                    case .success(let response):
                        sender.isSelected = response.following_status
                        owner.updateProfile()
                    case .failure(let error):
                        var message: String {
                            switch error {
                            case .notFound: return "알 수 없는 계정입니다."
                            default: return "네트워크 오류로 언팔로우가 되지 않았습니다. 다시 시도해주세요"
                            }
                        }
                        owner.showAlertMessage(title: "언팔로우 오류", message: message)
                    }
                }
                .disposed(by: disposeBag)
        }
    }
    
    func configureSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<ProfileSection, AnyHashable>()
        snapshot.appendSections(ProfileSection.allCases)
        dataSource.apply(snapshot)
    }
    
    
    func configureSnapshotForProfile(profile: GetProfileResponse) {
        var snapshot = dataSource.snapshot()
        
        snapshot.appendItems([profile], toSection: ProfileSection.profile)
        
        dataSource.apply(snapshot)
    }
    
    func updateSnapshotForProfile(profile: GetProfileResponse) {
        var snapshot = dataSource.snapshot()
        let previousItem = snapshot.itemIdentifiers(inSection: .profile)
        snapshot.deleteItems(previousItem)
        snapshot.appendItems([profile], toSection: ProfileSection.profile)
        dataSource.apply(snapshot)
    }
    
    func configureSnapshotForPosts(posts: [Post]) {
        var snapshot = dataSource.snapshot()
        snapshot.appendItems(posts, toSection: ProfileSection.post)
        dataSource.apply(snapshot)
    }
    
    func applyNewSnapshot() {
        let snapshot = dataSource.snapshot()
        dataSource.applySnapshotUsingReloadData(snapshot)
    }

}

private extension MyAccountViewController {
    
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            guard let self else { return nil }
            let section = ProfileSection.allCases[sectionIndex]
            switch section {
            case .profile: return self.profileSectionLayout()
            case .post: return self.postSectionLayout()
            }
        }
        
        return layout
    }
    
    func updateLayout(section: NSCollectionLayoutSection) -> UICollectionViewLayout {
        let postSection = section
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(60))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        sectionHeader.pinToVisibleBounds = true
        
        postSection.boundarySupplementaryItems = [sectionHeader]
        
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            guard let self else { return nil }
            let section = ProfileSection.allCases[sectionIndex]
            switch section {
            case .profile: return self.profileSectionLayout()
            case .post: return postSection
            }
        }
        
        return layout
    }
    
    func profileSectionLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
    
    func postSectionLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(60))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        sectionHeader.pinToVisibleBounds = true
        
        section.boundarySupplementaryItems = [sectionHeader]
        
        return section
    }
}

extension MyAccountViewController {
    func updateProfile() {
        APIManager.shared.requestGetUserProfile(userID: profile._id)
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let response):
                    let bool = response.followers.map { $0._id }.contains(KeyChainManager.shared.userID)
                    owner.isFollowing.onNext(bool)
                    owner.updateSnapshotForProfile(profile: response)
                case .failure(let error):
                    print("====profile refresh error====", error)
                }
            }
            .disposed(by: disposeBag)
    }
}

