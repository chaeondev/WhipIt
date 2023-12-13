//
//  StyleDetailView.swift
//  WhipIt
//
//  Created by Chaewon on 12/7/23.
//

import UIKit

enum Section: Int, CaseIterable {
    case content
    case info
    case comment
}

final class StyleDetailView: UIView {
    var dataSource: UICollectionViewDiffableDataSource<Section, AnyHashable>!
    lazy var collectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.bottom.equalToSuperview().inset(130)
        }

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension StyleDetailView {
    
    func configureDataSource() {
        let contentCell = UICollectionView.CellRegistration<ContentCell, ContentItem> { cell, indexPath, itemIdentifier in
            cell.configureCell(itemIdentifier)
        }
        
        let infoCell = UICollectionView.CellRegistration<InfoCell, InfoItem> { cell, indexPath, itemIdentifier in
            cell.configureCell(itemIdentifier)
        }
        
        let commentCell = UICollectionView.CellRegistration<CommentCell, Comment> { cell, indexPath, itemIdentifier in
            cell.configureCell(itemIdentifier)
        }
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let section = Section.allCases[indexPath.section]
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
        var snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
        snapshot.appendSections(Section.allCases)
        
        let contentItem = ContentItem(creator: item.creator, time: item.time, image: item.image, content1: item.content1)
        let infoItem = InfoItem(likes: item.likes, content: item.content, comments: item.comments, hashTags: item.hashTags)
        
        snapshot.appendItems( [contentItem], toSection: Section.content)
        snapshot.appendItems( [infoItem], toSection: Section.info)
        snapshot.appendItems( item.comments.reversed(), toSection: Section.comment)
        
        dataSource.apply(snapshot)
    }
    
    func applySnapshot(items: [Comment]) {
        var snapshot = dataSource.snapshot()
        snapshot.appendItems(items, toSection: Section.comment)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
   
    
    
}

private extension StyleDetailView {
    func createLayout() -> UICollectionViewLayout {

        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            guard let self else { return nil }
            let section = Section.allCases[sectionIndex]
            switch section {
            case .content: return self.contentSectionLayout()
            case .info: return self.infoSectionLayout()
            case .comment: return self.commentSectionLayout()
            }
        }
        
        return layout
    }
    
    func contentSectionLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
    
    func infoSectionLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(120))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(120))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
    
    func commentSectionLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(60))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(60))
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
}
