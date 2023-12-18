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
    
    private let viewModel = StyleDetailViewModel()
    
    private var disposeBag = DisposeBag()
    
    var dataSource: UICollectionViewDiffableDataSource<PostSection, AnyHashable>!
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let postData else { return }
        configureDataSource()
        configureSnapshot(item: postData)
        
        tabBarController?.tabBar.isHidden = true
        
        bind()
    }
    
    private func bind() {
        
        guard let postData else { return }
        
        let input = StyleDetailViewModel.Input(
            //commentText: commentView.commentTextField.rx.observe(String.self, "text"),
            commentText: commentView.commentTextField.rx.text.orEmpty,
            registerButtonTap: commentView.commentTextField.registerButton.rx.tap,
            postID: postData._id
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
            cell.configureCell(itemIdentifier)
        }
        
        let infoCell = UICollectionView.CellRegistration<InfoCell, InfoItem> { cell, indexPath, itemIdentifier in
            cell.configureCell(itemIdentifier)
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

// MARK: 북마크(좋아요) toggle -> post refresh
extension StyleDetailViewController {
    
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
