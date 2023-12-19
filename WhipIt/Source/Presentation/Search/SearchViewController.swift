//
//  SearchViewController.swift
//  WhipIt
//
//  Created by Chaewon on 12/19/23.
//

import UIKit
import RxSwift
import RxCocoa

final class SearchViewController: BaseViewController {
    
    private lazy var collectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.delegate = self
        return view
    }()
    
    var dataSource: UICollectionViewDiffableDataSource<Int, Post>!
    
    var postList: [Post] = []
    var nextCursor: String = ""
    
    var hashtag = ""
    
    private let viewModel = SearchViewModel()
    
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        configureDataSource()
        bind()
    }
    
    private func bind() {
        let input = SearchViewModel.Input(
            hashtag: hashtag
        )
        let output = viewModel.transform(input: input)
        
        output.hashResult
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
                    
                    owner.collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(section: layout.section)
                    
                    owner.configureSnapshot(response)
                case .failure(let error):
                    print("=====hashtag list error=====", error)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func setNavigationBar() {
        title = "#" + hashtag
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font : UIFont(name: Suit.bold, size: 17)!
        ]
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

extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = StyleDetailViewController()
        vc.postData = postList[indexPath.item]
        navigationController?.pushViewController(vc, animated: true)
    }
}


extension SearchViewController: StyleCellDelegate {
    
    func updateCollectionView() {
        postList = []
        bind()
    }
    
    
}


private extension SearchViewController {
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
