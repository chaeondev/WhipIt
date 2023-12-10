//
//  StyleDetailView.swift
//  WhipIt
//
//  Created by Chaewon on 12/7/23.
//

import UIKit

final class StyleDetailView: UIView {
    var dataSource: UICollectionViewDiffableDataSource<Section, ItemIdentifiable>!
    lazy var collectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        
        configureDataSource()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension StyleDetailView {
    
    func configureDataSource() {
        let contentCell = UICollectionView.CellRegistration<ContentCell, ItemIdentifiable> { cell, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .image(let data):
                cell.dateLabel.text = data.date
                cell.userNameLabel.text = data.userName
                cell.styleImageView.image = data.image
            default:
                break
            }
        }
        
        let infoCell = UICollectionView.CellRegistration<InfoCell, ItemIdentifiable> { cell, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .info(let data):
                cell.contentLabel.text = data.content
            default:
                break
            }
        }
        
        let commentCell = UICollectionView.CellRegistration<CommentCell, ItemIdentifiable> { cell, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .comment(let data):
                cell.nicknameLabel.text = data.nickname
            default:
                break
            }
        }
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let section = Section.allCases[indexPath.section]
            switch section {
            case .content:
                return collectionView.dequeueConfiguredReusableCell(using: contentCell, for: indexPath, item: itemIdentifier)
            case .info:
                return collectionView.dequeueConfiguredReusableCell(using: infoCell, for: indexPath, item: itemIdentifier)
            case .comment:
                return collectionView.dequeueConfiguredReusableCell(using: commentCell, for: indexPath, item: itemIdentifier)
            }
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, ItemIdentifiable>()
        snapshot.appendSections(Section.allCases)
        
        snapshot.appendItems(
            [
                ItemIdentifiable.image(ImageItem(image: UIImage(systemName: "star.fill")!))
            ], toSection: Section.content)
        
        dataSource.apply(snapshot)
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
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
}
