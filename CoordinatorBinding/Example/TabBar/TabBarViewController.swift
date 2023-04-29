//
//  TabBarViewController.swift
//  Coordinator Binding
//
//  Created by Tyler Zhao on 4/28/23.
//

import UIKit

struct Word: Hashable {
	let title: String
}

struct PickedWords: Hashable {
	let words: [Word]
}

class TabBarViewController: UITabBarController {
	typealias DataSource = UICollectionViewDiffableDataSource<PickedWords, Word>

	private lazy var dataSource = makeDataSource()
	private lazy var currentSnapshot = makeSnapshot()

	private lazy var collectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		layout.itemSize = .init(width: 50, height: 50)

		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.contentInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
		collectionView.backgroundColor = .clear
		collectionView.showsHorizontalScrollIndicator = false
		return collectionView
	}()

	let viewModel: TabBarViewModel

    override func viewDidLoad() {
        super.viewDidLoad()
		setupUI()
    }

	init(viewModel: TabBarViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupUI() {
		collectionView.dataSource = dataSource

	}

	private func makeDataSource() -> DataSource {
		let cellProvider = UICollectionView.CellRegistration<WordCollectionCell, Word> { cell, indexPath, word in
			cell.configure(word: word)
		}

		return DataSource(collectionView: collectionView) { (collectionView, indexPath, word) in
			collectionView.dequeueConfiguredReusableCell(using: cellProvider, for: indexPath, item: word)
		}
	}

	private func makeSnapshot() -> NSDiffableDataSourceSnapshot<PickedWords, Word> {
		var snapshot = NSDiffableDataSourceSnapshot<PickedWords, Word>()
		viewModel.pickedWords.forEach {
			snapshot.appendSections([$0])
			snapshot.appendItems($0.words)
		}
		return snapshot
	}
}

class WordCollectionCell: UICollectionViewCell {
	let label = UILabel()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupUI() {
		contentView.addSubview(label)

	}

	func configure(word: Word) {
		label.text = word.title
	}
}
