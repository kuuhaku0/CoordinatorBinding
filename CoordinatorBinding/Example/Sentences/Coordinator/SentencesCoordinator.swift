//
//  SentencesCoordinator.swift
//  Coordinator Binding
//
//  Created by Tyler Zhao on 4/28/23.
//

import Combine
import UIKit

final class SentencesCoordinator: Coordinator {

	var childCoordinators: [Coordinator] = []
	lazy var rootViewController: UIViewController = createSentencesScene()
	let navigationController: UINavigationController

	let actionables = SentencesActions()
	private var cancelBag = CancelBag()

	init(nav: UINavigationController) {
		navigationController = nav
	}

	func start() {

	}

	func conform(rules: SentencesActions) -> SentencesActions {
		
		return actionables
	}

	func goToSentenceDetail(sentence: Sentence) {

	}
}

extension SentencesCoordinator {
	private func createSentencesScene() -> UIViewController {
		let viewModel = SentencesViewModel()
		let sentencesVC = SentenceViewController(viewModel: viewModel)

		let reactions = viewModel.perform(action: actionables)

		reactions.deleteSentence
			.sink(receiveValue: actionables.deleteSentence.send(_:))
			.store(in: &cancelBag)

		reactions.selectSentence
			.sink(receiveValue: actionables.selectSentence.send(_:))
			.store(in: &cancelBag)

		return sentencesVC
	}
}
