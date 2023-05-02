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

final class SentenceBuilderCoordinator: NavigationCoordinator {

	private let dataManager: SentenceBuilderDataManager
	private let actionables = SentenceBuilderActions()
	private var cancelBag = CancelBag()

	private var currentScene: SentenceBuildable? {
		navigationController.topViewController as? SentenceBuildable
	}

	init(dataManager: SentenceBuilderDataManager) {
		self.dataManager = dataManager

		// Initialize with a custom navigation controller w/ viewModel
		let viewModel = SentenceBuilderNavViewModel()
		let nav = SentenceBuilderNav(viewModel: viewModel)

		// init super passing in custom nav
		super.init(viewController: nav, childCoordinators: [])

		// Perform setup code
		nav.modalPresentationStyle = .fullScreen
		setupNavigationController(nav: nav)
	}

	override func start() {
		// Example showing possible bindings with dataManager
		let dataBindings = dataManager.bind()

		dataBindings.newSentenceCreated
			.sink { [unowned self] sentence in
				navigationController.dismiss(animated: true)
				actionables.onTermination.send(sentence)
			}.store(in: &cancelBag)

		navigationController.setViewControllers([createBuildWordScene(word: nil)], animated: false)
	}

	private func setupNavigationController(nav: SentenceBuilderNav) {
		let outputs = nav.transform(input: actionables)

		outputs.backwardPressed
			.sink { [unowned self] in
				currentScene?.backwardPassthrough.send()
			}.store(in: &cancelBag)

		outputs.forwardPressed
			.sink { [unowned self] in
				currentScene?.forwardPassthrough.send()
			}.store(in: &cancelBag)
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
		if dataManager.currentEdit.indices.contains(navigationController.viewControllers.count) {
			let nextWord = dataManager.currentEdit[navigationController.viewControllers.count]
			let next = createBuildWordScene(word: nextWord)
			navigationController.pushViewController(next, animated: true)
		} else {
			let next = createBuildWordScene(word: nil)
			navigationController.pushViewController(next, animated: true)
		}
	}

	private func constructNavStack(selection: Int) {
		guard dataManager.currentEdit.indices.contains(selection) else { return }
		let stack = dataManager
			.currentEdit[0...selection]
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
				dataManager.replaceWord(
					old: replacement.oldWord,
					new: replacement.newWord
				)
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
