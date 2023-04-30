//
//  SentenceBuilderCoordinator.swift
//  Coordinator Binding
//
//  Created by Tyler Zhao on 4/29/23.
//

import Combine
import UIKit

class SentenceBuilderDataManager {
	struct Output {
		let newWordAccepted: AnyPublisher<Void, Never>
	}

	@Published private(set) var currentWords: [Word] = []
	@Published var latestWord: Word = Word(text: "")

	let onNewWordAccepted = JustPassthrough<Word>()

	func bind() -> Output {

		return Output(newWordAccepted: newWordAccepted)
	}

	func constructSentence() {

	}

	func acceptNewWord(_ word: Word) {
		onNewWordAccepted.send(word)
	}
}

final class SentenceBuilderCoordinator: Coordinator {
	var childCoordinators: [Coordinator] = []
	lazy var rootViewController: UIViewController = createSentenceBuilderScene()

	private let dataManager = SentenceBuilderDataManager()
	private var cancelBag = CancelBag()

	func start() {
		let dataBindings = dataManager.bind()

	}
}

extension SentenceBuilderCoordinator {
	private func createSentenceBuilderScene() -> SentenceBuilderNav {
		let nav = SentenceBuilderNav()
		let navInputs = SentenceBuilderControlEvent()
		let outputs = nav.transform(input: navInputs)

		let firstScene = createInitialBuildScene(navInputs: navInputs, input: outputs)
		nav.setViewControllers([firstScene], animated: false)
		return nav
	}

	private func createInitialBuildScene(
		navInputs: SentenceBuilderControlEvent,
		input: SentenceBuilderNavOutput
	) -> UIViewController {
		let startVC = WordInputViewController()
		let reactions = startVC.transform(input: input)

		reactions.textDidChange
			.sink { text in
				navInputs.onButtonStatus.send(
					.forward(enable: !text.isEmpty, hidden: false)
				)
			}.store(in: &cancelBag)

		reactions.publishWord
			.sink { [unowned self] word in
				dataManager.acceptNewWord(word)
			}.store(in: &cancelBag)

		return startVC
	}
}
