//
//  SentenceDetailViewController.swift
//  Coordinator Binding
//
//  Created by Tyler Zhao on 4/28/23.
//

import Combine
import UIKit

class SentenceDetailViewController: UIViewController {

	private lazy var stackView: UIStackView = {
		let stack = UIStackView()
		stack.axis = .vertical
		stack.spacing = 12
		stack.addArrangedSubview(label)
		stack.addArrangedSubview(createButton)
		return stack 
	}()

	private let label = UILabel()
	private lazy var createButton = UIButton(
		type: .roundedRect, primaryAction: .init(
			title: "Create New Sentence",
			handler: { [unowned self] _ in
				createNewSentence()
			}))

	private let viewModel: SentenceDetailViewModel
	private var cancelBag = CancelBag()

    override func viewDidLoad() {
        super.viewDidLoad()
		setupUI()
		bindViewModel()
    }

	init(viewModel: SentenceDetailViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func bindViewModel() {
		// Ideally we have publishers for UI events
		// In this case UI event publisher for tap events of `createButton`

		viewModel.$selectedSentence
			.sink { [unowned self] sentence in
				if let sentence {
					label.text = sentence.words.map(\.text).joined(separator: " ")
				} else {
					label.text = "No sentence selected"
				}
			}.store(in: &cancelBag)
	}

	private func setupUI() {
		label.numberOfLines = 0
		label.textAlignment = .center
		
		view.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.leading.trailing.equalToSuperview().inset(16)
			make.center.equalToSuperview()
		}
	}

	private func createNewSentence() {
		// Alternative case without publisher
		viewModel.createNewSentence.send()
	}
}
