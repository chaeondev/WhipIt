//
//  StyleDetailViewController.swift
//  WhipIt
//
//  Created by Chaewon on 12/6/23.
//

import UIKit
import RxSwift
import RxCocoa

class StyleDetailViewController: BaseViewController {

    private let mainView = StyleDetailView()
    
    private let commentView = CommentView()
    
    var postData: Post?
    
    var isfollowing = BehaviorSubject(value: false)
    
    private let viewModel = StyleDetailViewModel()
    
    private var disposeBag = DisposeBag()
    
    var dataSource: UICollectionViewDiffableDataSource<PostSection, AnyHashable>!
    
    override func loadView() {
        view = mainView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let postData else { return }
        configureDataSource()
        configureSnapshot(item: postData)

        
        bind()
    }
    
    private func bind() {
        
        guard let postData else { return }
        
        let input = StyleDetailViewModel.Input(
            //commentText: commentView.commentTextField.rx.observe(String.self, "text"),
            commentText: commentView.commentTextField.rx.text.orEmpty,
            registerButtonTap: commentView.commentTextField.registerButton.rx.tap,
            post: postData
        )
        let output = viewModel.transform(input: input)
        
        output.commentValidation
            .bind(with: self) { owner, value in
                owner.commentView.commentTextField.registerButton.isEnabled = value
                owner.commentView.commentTextField.registerButton.setTitleColor(value ? .black : .gray, for: .normal)
            }
            .disposed(by: disposeBag)
        
        output.commentResponse
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let response):
                    owner.applySnapshotForCreateComment(items: [response])
                    owner.updatePost(postID: postData._id)
                    owner.commentView.commentTextField.text = ""
                    owner.commentView.commentTextField.sendActions(for: .valueChanged)
                case .failure(let error):
                    var message: String {
                        switch error {
                        case .wrongRequest:
                            return "댓글 내용을 작성해주세요!"
                        case .notFound:
                            return "댓글을 추가할 게시글을 찾을 수 없습니다."
                        default:
                            return "네트워크 서버 장애로 댓글이 작성되지 않았습니다. 다시 시도해주세요"
                        }
                    }
                    owner.showAlertMessage(title: "댓글 등록 오류", message: message)
                }
            }
            .disposed(by: disposeBag)
        
        output.profile
            .subscribe(with: self) { owner, profile in
                owner.commentView.profileImageView.setKFImage(imageUrl: profile ?? "")
            }
            .disposed(by: disposeBag)
        
        output.creator
            .map { $0.followers.map { $0._id } }
            .map { $0.contains(KeyChainManager.shared.userID) }
            .bind(to: isfollowing)
            .disposed(by: disposeBag)

    }
    
    override func setHierarchy() {
        super.setHierarchy()
        view.addSubview(commentView)
    }
    
    override func setConstraints() {
        super.setConstraints()
        commentView.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalToSuperview()
            make.height.greaterThanOrEqualTo(130)
        }
        
    }
}

extension StyleDetailViewController {
    
    
    func configureDataSource() {
        let contentCell = UICollectionView.CellRegistration<ContentCell, ContentItem> { cell, indexPath, itemIdentifier in
            
            guard let postData = self.postData else { return }
            if postData.creator._id == KeyChainManager.shared.userID {
                cell.followButton.isHidden = true
            }
            
            self.isfollowing
                .bind(with: self) { owner, bool in
                    cell.followButton.isSelected = bool
                }
                .disposed(by: self.disposeBag)
            
            cell.headerButton.addTarget(self, action: #selector(self.userButtonClicked), for: .touchUpInside)
            cell.followButton.addTarget(self, action: #selector(self.followButtonClicked), for: .touchUpInside)
            cell.configureCell(itemIdentifier)
            self.setMenuButton(cell.menuButton)
            cell.menuButton.showsMenuAsPrimaryAction = true
        }
        
        let infoCell = UICollectionView.CellRegistration<InfoCell, InfoItem> { cell, indexPath, itemIdentifier in
            cell.configureCell(itemIdentifier)
            cell.contentTextView.delegate = self
            cell.contentTextView.resolveHashTags()
            cell.bookmarkButton.addTarget(self, action: #selector(self.bookmarkButtonClicked), for: .touchUpInside)
            guard let userID = KeyChainManager.shared.userID else { return }
            cell.bookmarkButton.isSelected = itemIdentifier.likes.contains(userID)
        }
        
        let commentCell = UICollectionView.CellRegistration<CommentCell, Comment> { cell, indexPath, itemIdentifier in
            cell.configureCell(itemIdentifier)
            cell.menuButton.menu = self.setupMenu(comment: itemIdentifier)
            cell.menuButton.showsMenuAsPrimaryAction = true
        }
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: mainView.collectionView) { collectionView, indexPath, itemIdentifier in
            let section = PostSection.allCases[indexPath.section]
            switch section {
            case .content:
                return collectionView.dequeueConfiguredReusableCell(using: contentCell, for: indexPath, item: itemIdentifier as? ContentItem)
            case .info:
                return collectionView.dequeueConfiguredReusableCell(using: infoCell, for: indexPath, item: itemIdentifier as? InfoItem)
            case .comment:
                return collectionView.dequeueConfiguredReusableCell(using: commentCell, for: indexPath, item: itemIdentifier as? Comment)
            }
        }
        
    }
    
    func configureSnapshot(item: Post) {
        var snapshot = NSDiffableDataSourceSnapshot<PostSection, AnyHashable>()
        snapshot.appendSections(PostSection.allCases)
        
        let contentItem = ContentItem(creator: item.creator, time: item.time, image: item.image, content1: item.content1)
        let infoItem = InfoItem(likes: item.likes, content: item.content, comments: item.comments, hashTags: item.hashTags)
        
        snapshot.appendItems( [contentItem], toSection: PostSection.content)
        snapshot.appendItems( [infoItem], toSection: PostSection.info)
        snapshot.appendItems( item.comments, toSection: PostSection.comment)
        
        dataSource.apply(snapshot)
    }
    
    func applySnapshotForCreateComment(items: [Comment]) {
        var snapshot = dataSource.snapshot()
        if let first = snapshot.itemIdentifiers(inSection: PostSection.comment).first {
            snapshot.insertItems(items, beforeItem: first)
        } else {
            snapshot.appendItems(items, toSection: PostSection.comment)
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func applySnapshotForDeleteComment(items: [Comment]) {
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems(items)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
       
}

extension StyleDetailViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        guard let contentTextView = textView as? HashtagTextView  else { return false }
        print("====url scheme====", URL.absoluteString)
        let url = URL.absoluteString
        let arrId = Int(url)
        
        let vc = SearchViewController()
        vc.hashtag = contentTextView.hashtagArr![arrId!]
        
        self.navigationController?.pushViewController(vc, animated: true)
          
        return false
    }
}

// MARK: 댓글 삭제
extension StyleDetailViewController {
    private func setupMenu(comment: Comment) -> UIMenu {
        let commentDelete = UIAction(title: "삭제하기", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
            self.showAlertMessageWithCancel(title: "댓글 삭제", message: "댓글을 삭제하시겠습니까?") {
                guard let post = self.postData else { return }
                APIManager.shared.requestDeleteComment(postID: post._id, commentID: comment._id)
                    .subscribe(with: self) { owner, result in
                        switch result {
                        case .success:
                            print("====댓글 삭제 성공=====")
                            owner.updatePost(postID: post._id)
                            owner.applySnapshotForDeleteComment(items: [comment])
                        case .failure(let error):
                            var message: String {
                                switch error {
                                case .notFound:
                                    return "삭제할 댓글을 찾을 수 없습니다."
                                case .permissionDenied:
                                    return "댓글 삭제 권한이 없습니다."
                                default:
                                    return "네트워크 오류로 댓글 삭제가 실행되지 않았습니다. 다시 시도해주세요"
                                }
                            }
                            owner.showAlertMessage(title: "댓글 삭제 오류", message: message)
                        }
                    }
                    .disposed(by: self.disposeBag)
   
            }
        }
        return UIMenu(children: [commentDelete])
    }
}


extension StyleDetailViewController {
    
    // MARK: 북마크(좋아요) toggle -> post refresh
    @objc func bookmarkButtonClicked(_ sender: UIButton) {
        guard let post = postData else { return }
        APIManager.shared.requestLikePost(postID: post._id)
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let response):
                    sender.isSelected = response.like_status
                    owner.updatePost(postID: post._id)
                case .failure(let error):
                    print("=====북마크 에러======", error)
                }
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: 게시글 삭제 버튼
    func setMenuButton(_ sender: UIButton) {
        
        guard let postData else { return }
        
        if postData.creator._id == KeyChainManager.shared.userID {
            let postShare = UIAction(title: "게시물 공유") { action in
                print(action)
            }
            
            let postDelete = UIAction(title: "게시물 삭제", attributes: .destructive) { action in
                self.showAlertMessageWithCancel(title: "게시물을 삭제하시겠습니까?", handler: {
                    APIManager.shared.requestDeletePost(postID: postData._id)
                        .subscribe(with: self) { owner, result in
                            switch result {
                            case .success:
                                owner.navigationController?.popViewController(animated: true)
                            case .failure(let error):
                                var message: String {
                                    switch error {
                                    case .notFound: return "이미 삭제된 게시글입니다."
                                    case .permissionDenied: return "본인이 작성한 글에 한해서만 삭제가 가능합니다."
                                    default: return "네트워크 오류로 인해 게시글이 삭제되지 않았습니다. 다시 시도해주세요"
                                    }
                                }
                                
                                owner.showAlertMessage(title: "게시글 삭제 오류", message: message)
                            }
                        }
                        .disposed(by: self.disposeBag)
                })
            }
            sender.menu = UIMenu(children: [postShare, postDelete])
        } else {
            let postShare = UIAction(title: "게시글 공유") { action in
                print(action)
            }
            sender.menu = UIMenu(children: [postShare])
        }
    }
    
    // MARK: 팔로우 버튼 클릭
    @objc func followButtonClicked(_ sender: UIButton) {
        
        guard let postData else { return }
        
        if !sender.isSelected {
            APIManager.shared.requestFollow(userID: postData.creator._id)
                .asObservable()
                .subscribe(with: self) { owner, result in
                    switch result {
                    case .success(let response):
                        sender.isSelected = response.following_status
                        owner.updatePost(postID: postData._id)
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
            APIManager.shared.requestUnFollow(userID: postData.creator._id)
                .asObservable()
                .subscribe(with: self) { owner, result in
                    switch result {
                    case .success(let response):
                        sender.isSelected = response.following_status
                        owner.updatePost(postID: postData._id)
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
    
    // MARK: User Profile button 클릭
    @objc func userButtonClicked() {
        guard let postData else { return }
        let vc = MyAccountViewController()
        vc.accountType = postData.creator._id == KeyChainManager.shared.userID ? .me : .user
        vc.userID = postData.creator._id
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func updatePost(postID: String) {
        APIManager.shared.requestGetPostByID(postID: postID)
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let response):
                    owner.configureSnapshot(item: response)
                case .failure(let error):
                    print("====post refresh error====", error)
                }
            }
            .disposed(by: disposeBag)
    }
}
