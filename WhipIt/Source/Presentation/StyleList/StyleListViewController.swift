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
import YPImagePicker
import Photos

class StyleListViewController: BaseViewController {
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private lazy var searchBar = UISearchBar()
    
    
    var dataSource: UICollectionViewDiffableDataSource<Int, PhotoResult>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        
        
        configureDataSource()
        
        Network.shared.requestConvertible(type: Photo.self, api: .search(query: "cat")) { response in
            switch response {
            case .success(let success):
                //데이터 + UI스냅샷
                //dump(success)
                let ratios = success.results.map { Ratio(ratio: $0.width * 0.75 / $0.height) }
                
                let layout = PinterestLayout(columnsCount: 2, itemRatios: ratios, spacing: 10, contentWidth: self.view.frame.width)
                
                self.collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(section: layout.section)
                
                self.configureSnapshot(success) // 순서에 따라서 스크롤이 최상단이 아니게 될 수 있으니 순서 주의하기!
                
                //dump(success)
            case .failure(let failure):
                print(failure.localizedDescription)
            }
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
    
    func setNavigationBar() {
        navigationItem.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "camera.fill"), style: .plain, target: self, action: #selector(postButtonClicked))
    }
    
    @objc func postButtonClicked() {
        navigationController?.pushViewController(CreatePostViewController(), animated: true)
    }
  
}

extension StyleListViewController {
    
    func configureSnapshot(_ item: Photo) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, PhotoResult>()
        snapshot.appendSections([0])
        snapshot.appendItems(item.results)
        dataSource.apply(snapshot)
    }
    
    func configureDataSource() {
        
        let cellRegistration = UICollectionView.CellRegistration<StyleCollectionViewCell, PhotoResult> { cell, indexPath, itemIdentifier in
            cell.photoImageView.kf.setImage(with: URL(string: itemIdentifier.urls.thumb)!)
            
        }
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
            
        })
        
        
    }
    
}
