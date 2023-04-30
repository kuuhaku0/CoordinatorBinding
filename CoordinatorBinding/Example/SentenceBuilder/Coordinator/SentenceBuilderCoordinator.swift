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
		let newWordAccepted: AnyPublisher<Word, Never>
	}

	@Published private(set) var allSentences: [Sentence] = prefill

	// Word Constructor
	@Published private(set) var currentWords: [Word] = []
	@Published var latestWord: Word = Word(text: "")

	let onNewWordAccepted = JustPassthrough<Word>()
	let onNewSentenceCreated = JustPassthrough<Sentence>()

	func bind() -> Output {
		return Output(newWordAccepted: onNewWordAccepted.eraseToAnyPublisher())
	}

	func constructSentence() {
		let newSentence = Sentence(words: currentWords)
		currentWords = []
		allSentences.append(newSentence)
	}

	func selectSentence(_ sentence: Sentence) {
		currentWords = sentence.words
	}

	func acceptNewWord(_ word: Word) {
		onNewWordAccepted.send(word)
	}
}

struct SentenceBuilderActions {
	let wordSelectedAtIndex = JustPassthrough<Int>()
	let setNavButtonState = JustPassthrough<SentenceBuilderNav.ButtonStatus>()
	let onTermination = VoidPassthrough()
}

protocol SentenceBuildable: AnyObject {
	var forwardPassthrough: VoidPassthrough { get }
	var backwardPassthrough: VoidPassthrough { get }
}

final class SentenceBuilderCoordinator: Coordinator {
	var childCoordinators: [Coordinator] = []
	lazy var rootViewController: UIViewController = navigationController

	private let dataManager: SentenceBuilderDataManager
	private let actionables = SentenceBuilderActions()
	private var cancelBag = CancelBag()

	lazy var navigationController = createNavigator()
	private var currentScene: SentenceBuildable? {
		navigationController.topViewController as? SentenceBuildable
	}

	init(dataManager: SentenceBuilderDataManager) {
		self.dataManager = dataManager
	}

	func start() {
		let dataBindings = dataManager.bind()

		dataBindings.newWordAccepted
			.sink { [unowned self] _ in
				prepareNextScene()
			}.store(in: &cancelBag)

		navigationController.setViewControllers([createBuildWordScene(word: nil)], animated: false)
	}

	func comform(input: JustPassthrough<Int>) -> SentenceBuilderActions {
		input
			.receive(on: DispatchQueue.main)
			.sink { [unowned self] index in
				constructNavStack(selection: index)
			}.store(in: &cancelBag)

		return actionables
	}

	func prepareNextScene() {
		if dataManager.currentWords.indices.contains(navigationController.viewControllers.count) {
			let nextWord = dataManager.currentWords[navigationController.viewControllers.count]
			let next = createBuildWordScene(word: nextWord)
			navigationController.pushViewController(next, animated: true)
		} else {
			let next = createBuildWordScene(word: nil)
			navigationController.pushViewController(next, animated: true)
		}
	}

	private func constructNavStack(selection: Int) {
		guard dataManager.currentWords.indices.contains(selection) else { return }
		let stack = dataManager
			.currentWords[0...selection]
			.map { createBuildWordScene(word: $0) }

		navigationController.setViewControllers(stack, animated: false)
	}

	func buildScenes() -> [UIViewController] {
		dataManager.currentWords.map { word in
			createBuildWordScene(word: word)
		}
	}

	func popLast() {
		if navigationController.viewControllers.count == 1 {
			navigationController.dismiss(animated: true)
			actionables.onTermination.send()
		} else {
			navigationController.popViewController(animated: true)
		}
	}

	deinit {
		print(String(describing: self), "deallocated")
	}
}

extension SentenceBuilderCoordinator {
	private func createNavigator() -> SentenceBuilderNav {
		let nav = SentenceBuilderNav()
		let outputs = nav.transform(input: actionables)

		outputs.backwardPressed
			.sink { [unowned self] in
				currentScene?.backwardPassthrough.send()
			}.store(in: &cancelBag)

		outputs.forwardPressed
			.sink { [unowned self] in
				currentScene?.forwardPassthrough.send()
			}.store(in: &cancelBag)

		return nav
	}

	private func createBuildWordScene(word: Word?) -> UIViewController {
		let startVC = WordInputViewController(word: word)
		let reactions = startVC.transform(input: actionables)
		
		reactions.textDidChange
			.sink { [unowned self] text in
				actionables.setNavButtonState.send(
					.forward(enable: !text.isEmpty, hidden: false)
				)
			}.store(in: &cancelBag)

		reactions.publishWord
			.sink(receiveValue: dataManager.acceptNewWord(_:))
			.store(in: &cancelBag)

		reactions.rewind
			.sink { [unowned self] in popLast() }
			.store(in: &cancelBag)

		return startVC
	}
}
