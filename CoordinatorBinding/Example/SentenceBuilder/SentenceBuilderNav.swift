//
//  SentenceBuilderNav.swift
//  Coordinator Binding
//
//  Created by Tyler Zhao on 4/29/23.
//

import Combine
import UIKit

struct SentenceBuilderNavOutput {
	let forwardPressed = VoidPassthrough()
	let backwardPressed = VoidPassthrough()
}

// View Model for injection Demo purposes
struct SentenceBuilderNavViewModel {

}

class SentenceBuilderNav: UINavigationController {

	enum ButtonStatus {
		case forward(enable: Bool, hidden: Bool)
		case backward(enable: Bool, hidden: Bool)
	}

	private lazy var buttonStack: UIStackView = {
		let stack = UIStackView()
		stack.axis = .horizontal
		stack.addArrangedSubview(backButton)
		stack.addArrangedSubview(UIView())
		stack.addArrangedSubview(forwardButton)
		return stack
	}()

	private let outputs = SentenceBuilderNavOutput()

	private lazy var forwardButton: UIButton = {
		UIButton(type: .roundedRect, primaryAction: UIAction(
			title: "Forward", handler: { [unowned self] _ in
				outputs.forwardPressed.send()
			})
		)
	}()

	private lazy var backButton: UIButton = {
		UIButton(type: .roundedRect, primaryAction: UIAction(
			title: "Back", handler: { [unowned self] _ in
				outputs.backwardPressed.send()
			})
		)
	}()

	private var cancelBag = CancelBag()

	private let viewModel: SentenceBuilderNavViewModel

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		setNavigationBarHidden(true, animated: false)
	}

	// MARK: - Init

	init(viewModel: SentenceBuilderNavViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// Example of binding with viewController instead of viewModel
	func transform(input: SentenceBuilderActions) -> SentenceBuilderNavOutput {
		input.setNavButtonState
			.sink { [unowned self] button in
				switch button {
				case let .forward(enable, hidden):
					forwardButton.isEnabled = enable
					forwardButton.isHidden = hidden

				case let .backward(enable, hidden):
					backButton.isEnabled = enable
					backButton.isHidden = hidden
				}
			}.store(in: &cancelBag)

		return outputs
	}

	private func setupUI() {
		view.addSubview(buttonStack)
		buttonStack.snp.makeConstraints { make in
			make.leading.trailing.equalToSuperview().inset(16)
			make.top.equalToSuperview { $0.safeAreaLayoutGuide }
		}
	}
}
