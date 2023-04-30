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
	let dataManager: SentenceBuilderDataManager

	let actionables = SentencesActions()
	private var cancelBag = CancelBag()

	init(nav: UINavigationController, dataManager: SentenceBuilderDataManager) {
		self.dataManager = dataManager
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
			.sink { [unowned self] sentence in
				actionables.deleteSentence.send(sentence)
			}
			.store(in: &cancelBag)

		reactions.selectSentence
			.sink { [unowned self] sentence in
				dataManager.selectSentence(sentence)
				actionables.selectSentence.send(sentence)
			}
			.store(in: &cancelBag)

		return sentencesVC
	}
}
