//
//  TabBarViewController.swift
//  Coordinator Binding
//
//  Created by Tyler Zhao on 4/28/23.
//

import SnapKit
import UIKit

struct Word: Hashable {
	let id: UUID = UUID()
	let text: String
}

struct Sentence: Hashable {
	let id: UUID = UUID()
	let words: [Word]
}

class TabBarViewController: UITabBarController {
	typealias DataSource = UICollectionViewDiffableDataSource<Int, Word>

	private lazy var dataSource = makeDataSource()
	private lazy var currentSnapshot = makeSnapshot(words: [])

	private lazy var collectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize

		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.contentInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.delegate = self
		return collectionView
	}()

	private var viewModel: TabBarViewModel!
	private var cancelBag = CancelBag()

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
	}

	// Setting view model first approach
	// Force `bind` call by force unwrapping viewModel
	func bind(viewModel: TabBarViewModel) {
		self.viewModel = viewModel

		collectionView.dataSource = dataSource
		dataSource.apply(currentSnapshot)

		viewModel.$words
			.receive(on: DispatchQueue.main)
			.sink { [unowned self] words in
				currentSnapshot = makeSnapshot(words: words)
				dataSource.apply(currentSnapshot)
			}.store(in: &cancelBag)
	}

	private func setupUI() {
		view.addSubview(collectionView)

		collectionView.snp.makeConstraints { make in
			make.height.equalTo(60)
			make.leading.trailing.equalToSuperview()
			make.bottom.equalToSuperview { $0.safeAreaLayoutGuide }.inset(48)
		}
	}

	private func makeDataSource() -> DataSource {
		let cellProvider = UICollectionView.CellRegistration<WordCollectionCell, Word> { cell, indexPath, word in
			cell.configure(word: word)
		}

		return DataSource(collectionView: collectionView) { (collectionView, indexPath, word) in
			collectionView.dequeueConfiguredReusableCell(using: cellProvider, for: indexPath, item: word)
		}
	}

	private func makeSnapshot(words: [Word]) -> NSDiffableDataSourceSnapshot<Int, Word> {
		var snapshot = NSDiffableDataSourceSnapshot<Int, Word>()
		snapshot.appendSections([0])
		snapshot.appendItems(viewModel.words)
		return snapshot
	}
}

extension TabBarViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		viewModel.didSelectItemAt.send(indexPath.row)
	}
}

class WordCollectionCell: UICollectionViewCell {
	let label = UILabel()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
		layer.cornerRadius = 12
		clipsToBounds = true
		backgroundColor = .white
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupUI() {
		label.textColor = .black
		label.setContentHuggingPriority(.required, for: .vertical)
		contentView.addSubview(label)
		label.snp.makeConstraints { make in
			make.leading.trailing.equalToSuperview().inset(12)
			make.centerY.equalToSuperview()
		}
	}

	func configure(word: Word) {
		label.text = word.text
	}
}
