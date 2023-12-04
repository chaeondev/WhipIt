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
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private lazy var searchBar = UISearchBar()
    
    
    var dataSource: UICollectionViewDiffableDataSource<Int, Post>!
    
    private let viewModel = StyleListViewModel()
    private lazy var disposeBag = DisposeBag()
    
    let imageListSubject = PublishSubject<[UIImage]>()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        bind()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        configureDataSource()
        
        //bind()
        
    }
    
    private func bind() {
        let input = StyleListViewModel.Input(searchButtonTap: searchBar.rx.searchButtonClicked)
        let output = viewModel.transform(input: input)
        
        output.getPostResponse
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let response):
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
        navigationItem.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "camera.fill"), style: .plain, target: self, action: #selector(postButtonClicked))
    }
    
    @objc func postButtonClicked() {
        navigationController?.pushViewController(CreatePostViewController(), animated: true)
    }
  
}

extension StyleListViewController {
    
    func configureSnapshot(_ item: GetPostResponse) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Post>()
        snapshot.appendSections([0])
        snapshot.appendItems(item.data)
        dataSource.apply(snapshot)
    }
    
    func configureDataSource() {
        
        let cellRegistration = UICollectionView.CellRegistration<StyleCollectionViewCell, Post> { cell, indexPath, itemIdentifier in
            cell.configureCell(stylePost: itemIdentifier)
            
        }
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
            
        })
        
        
    }
    
}
