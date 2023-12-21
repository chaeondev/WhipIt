//
//  StyleListViewController.swift
//  WhipIt
//
//  Created by Chaewon on 11/26/23.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class StyleListViewController: BaseViewController {
    
    private lazy var collectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.delegate = self
        view.prefetchDataSource = self
        return view
    }()
    
    var dataSource: UICollectionViewDiffableDataSource<Int, Post>!
    
    private let viewModel = StyleListViewModel()
    private lazy var disposeBag = DisposeBag()
    
    //feed post list
    var postList: [Post] = []
    var nextCursor: String = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        postList = []
        bind()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        configureDataSource()
        //bind()
        UserDefaultsManager.isLogin = true
        
    }
    
    private func bind() {
        let input = StyleListViewModel.Input()
        let output = viewModel.transform(input: input)
        output.feedResult
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let response):
                    owner.postList.append(contentsOf: response.data)
                    owner.nextCursor = response.next_cursor
                    let ratios = response.data.map {
                        let floatRatio: CGFloat = CGFloat(NSString(string: $0.content1).floatValue)
                        return Ratio(ratio: floatRatio * 0.75)
                    }
                    let layout = PinterestLayout(columnsCount: 2, itemRatios: ratios, spacing: 10, contentWidth: owner.view.frame.width)
                    
                    owner.collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(section: layout.section)
                    
                    owner.configureSnapshot(response)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
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
    
    private func setNavigationBar() {
        //navigationItem.titleView = searchBar
        title = "STYLE"
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font : UIFont(name: Suit.bold, size: 17)!
        ]
        let cameraButton = UIBarButtonItem(image: UIImage(systemName: "camera.fill"), style: .plain, target: self, action: #selector(postButtonClicked))
        cameraButton.tintColor = .black
        navigationItem.rightBarButtonItem = cameraButton
    }
    
    @objc func postButtonClicked() {
        navigationController?.pushViewController(CreatePostViewController(), animated: true)
    }
  
}

// MARK: diffable datasource collectionview
extension StyleListViewController {
    
    func configureSnapshot(_ item: GetPostResponse) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Post>()
        snapshot.appendSections([0])
        snapshot.appendItems(item.data)
        dataSource.apply(snapshot)
    }
    
    func updateSnapshot(items: [Post]) {
        var snapshot = dataSource.snapshot()
        snapshot.appendItems(items, toSection: 0)
        dataSource.apply(snapshot)
    }
    
    func configureDataSource() {
        
        let cellRegistration = UICollectionView.CellRegistration<StyleCollectionViewCell, Post> { cell, indexPath, itemIdentifier in
            cell.stylePost = itemIdentifier
            cell.delegate = self
            cell.configureCell()
        }
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
            
        })
    }
    
}

// MARK: cell 선택시 DetailView로 전환
extension StyleListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = StyleDetailViewController()
        vc.postData = postList[indexPath.item]
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

// TODO: 페이지네이션 뭔가이상한데..아직 원인을 모르겠음
// MARK: collectionview pagination
extension StyleListViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {

        for indexPath in indexPaths {

            if postList.count - 2 == indexPath.item && nextCursor != "0" {
                APIManager.shared.requestGetPost(limit: 20, next: nextCursor)
                    .asObservable()
                    .subscribe(with: self) { owner, result in
                        switch result {
                        case .success(let response):
                            print("====pagination api network====")
                            owner.postList.append(contentsOf: response.data)
                            owner.nextCursor = response.next_cursor
                            
                            let ratios = owner.postList.map {
                                let floatRatio: CGFloat = CGFloat(NSString(string: $0.content1).floatValue)
                                return Ratio(ratio: floatRatio * 0.75)
                            }
                            let layout = PinterestLayout(columnsCount: 2, itemRatios: ratios, spacing: 10, contentWidth: owner.view.frame.width)
                            
                            owner.collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(section: layout.section)
                            
                            owner.updateSnapshot(items: response.data)
                        case .failure(let error):
                            // TODO: error message
                            print(error)
                        }
                    }
                    .disposed(by: disposeBag)
            }
        }
    }
}

// TODO: 전체를 refresh시키는게 말이안되긴 함.. post만 reload해서 cell update하는 방법 찾기
// MARK: CellDelegate -> refreshData
extension StyleListViewController: StyleCellDelegate {
    
    func updateCollectionView() {
        postList = []
        bind()
    }
    
    func transitionView(accoutType: AccountType, userID: String) {
        let vc = MyAccountViewController()
        vc.accountType = accoutType
        vc.userID = userID
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
