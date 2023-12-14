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

class MyAccountViewController: BaseViewController {
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    
    var dataSource: UICollectionViewDiffableDataSource<ProfileSection, AnyHashable>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDataSource()
        configureSnapshot()
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

private extension MyAccountViewController {
    
    struct ProfileItem: Hashable {
        let username: String
    }
    
    struct PostItem: Hashable {
        let username: String
    }
    
    func configureDataSource() {
        let profileCell = UICollectionView.CellRegistration<ProfileCollectionCell, ProfileItem> { cell, indexPath, itemIdentifier in
            cell.userNameLabel.text = itemIdentifier.username
        }
        
        let postCell = UICollectionView.CellRegistration<StyleCollectionViewCell, PostItem> { cell, indexPath, itemIdentifier in
            
        }
        
        collectionView.register(AccountHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")

        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let section = ProfileSection.allCases[indexPath.section]
            switch section {
            case .profile:
                return collectionView.dequeueConfiguredReusableCell(using: profileCell, for: indexPath, item: itemIdentifier as? ProfileItem)
            case .post:
                return collectionView.dequeueConfiguredReusableCell(using: postCell, for: indexPath, item: itemIdentifier as? PostItem)
            }
        })
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }

            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? AccountHeaderView
//            let view = collectionView.dequeueConfiguredReusableSupplementary(using: headerView, for: indexPath)

            return view
        }
    }
    
    
    func configureSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<ProfileSection, AnyHashable>()
        snapshot.appendSections(ProfileSection.allCases)
        
        let profileItem = ProfileItem(username: "dnltldl888")
        let postItem1 = PostItem(username: "fjashajhdsh")
        snapshot.appendItems([profileItem], toSection: ProfileSection.profile)
        snapshot.appendItems([postItem1], toSection: ProfileSection.post)
        
        dataSource.apply(snapshot)
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
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(70))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        sectionHeader.pinToVisibleBounds = true
        
        section.boundarySupplementaryItems = [sectionHeader]
        
        return section
    }
}
