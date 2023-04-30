//
//  SentenceBuilderCoordinator.swift
//  Coordinator Binding
//
//  Created by Tyler Zhao on 4/29/23.
//

import Combine
import UIKit

struct SentenceBuilderActions {
	let setNavButtonState = JustPassthrough<SentenceBuilderNav.ButtonStatus>()
	let onTermination = JustPassthrough<Sentence?>()
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

		dataBindings.newSentenceCreated
			.sink { [unowned self] sentence in
				actionables.onTermination.send(sentence)
			}.store(in: &cancelBag)

		navigationController.setViewControllers([createBuildWordScene(word: nil)], animated: false)
	}

	// Example of single input
	func comform(selectedWordAtIndex: JustPassthrough<Int>) -> SentenceBuilderActions {
		selectedWordAtIndex
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

	func popLast() {
		if navigationController.viewControllers.count == 1 {
			navigationController.dismiss(animated: true)
			actionables.onTermination.send(nil)
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
			.receive(on: DispatchQueue.main)
			.sink { [unowned self] text in
				actionables.setNavButtonState.send(
					.forward(enable: !text.isEmpty, hidden: false)
				)
			}.store(in: &cancelBag)

		reactions.publishWord
			.sink { [unowned self] newWord in
				prepareNextScene()
				guard let newWord else { return }
				dataManager.acceptNewWord(newWord)
			}
			.store(in: &cancelBag)

		reactions.replaceWord
			.sink { [unowned self] replacement in
				prepareNextScene()
				dataManager.replaceWord(old: replacement.oldWord, new: replacement.newWord)
			}
			.store(in: &cancelBag)

		reactions.buildSentence
			.sink { [unowned self] in
				dataManager.constructSentence()
			}
			.store(in: &cancelBag)

		reactions.rewind
			.sink { [unowned self] in popLast() }
			.store(in: &cancelBag)

		return startVC
	}
}
