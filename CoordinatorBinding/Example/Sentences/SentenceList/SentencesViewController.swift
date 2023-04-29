//
//  SentenceViewController.swift
//  Coordinator Binding
//
//  Created by Tyler Zhao on 4/28/23.
//

import Combine
import UIKit

struct SentencesViewInputs {
	let didSelectSentenceAt = PassthroughSubject<Int, Never>()
	let deleteSentenceAt = PassthroughSubject<Int, Never>()
}

class SentenceViewController: UIViewController {

	class DataSource: UITableViewDiffableDataSource<Int, Sentence> {
		override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
			return true
		}
	}

	private lazy var tableView: UITableView = {
		let table = UITableView()
		table.register(SentenceTableCell.self, forCellReuseIdentifier: "SentenceTableCell")
		table.delegate = self
		return table
	}()

	private let events = SentencesViewInputs()

	private let viewModel: SentencesViewModel
	private var cancelBag = CancelBag()

	private lazy var dataSource = createDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
		view.backgroundColor = .white
		setupUI()
		bindViewModel()
    }

	init(viewModel: SentencesViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func bindViewModel() {
		let outputs = viewModel.transform(input: events)

		Publishers.Merge(
			outputs.selectSentence,
			outputs.deleteSentence
		)
		.sink { [unowned self] _ in
			dataSource.apply(createSnapshot())
		}.store(in: &cancelBag)
	}

	private func setupUI() {
		view.addSubview(tableView)
		tableView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}

		tableView.dataSource = dataSource
		dataSource.apply(createSnapshot())
	}

	private func createDataSource() -> DataSource {
		DataSource(tableView: tableView) { tableView, indexPath, sentence in
			let cell = tableView.dequeueReusableCell(withIdentifier: "SentenceTableCell", for: indexPath) as! SentenceTableCell
			cell.label.text = sentence.words.map(\.text).joined(separator: " ")
			return cell
		}
	}

	private func createSnapshot() -> NSDiffableDataSourceSnapshot<Int, Sentence> {
		var snapshot = NSDiffableDataSourceSnapshot<Int, Sentence>()
		snapshot.appendSections([0])
		snapshot.appendItems(viewModel.sentences)
		return snapshot
	}
}

extension SentenceViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		events.didSelectSentenceAt.send(indexPath.row)
	}

	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
	-> UISwipeActionsConfiguration? {
		let deleteAction = UIContextualAction(style: .destructive, title: nil) { [unowned self] _, _, completion in
			events.deleteSentenceAt.send(indexPath.row)
			completion(true)
		}
		deleteAction.image = UIImage(systemName: "trash")
		deleteAction.backgroundColor = .systemRed
		let config = UISwipeActionsConfiguration(actions: [deleteAction])
		return config
	}
}

class SentenceTableCell: UITableViewCell {
	let label = UILabel()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupUI() {
		label.numberOfLines = 0
		contentView.addSubview(label)
		label.snp.makeConstraints { make in
			make.leading.trailing.equalToSuperview().inset(16)
			make.top.greaterThanOrEqualToSuperview().offset(12)
			make.bottom.lessThanOrEqualToSuperview().inset(12)
			make.centerY.equalToSuperview()
		}
	}
}
