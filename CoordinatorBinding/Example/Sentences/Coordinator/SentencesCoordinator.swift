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
		print(String(describing: self), "Start")
	}

	func conform(rules: SentencesActions) -> SentencesActions {
		rules.onCreateSentence
			.sink { [unowned self] in
				actionables.onCreateSentence.send($0)
			}
			.store(in: &cancelBag)

		return actionables
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
			.sink { [unowned self] sentence in
				dataManager.selectSentence(sentence)
				actionables.selectSentence.send(sentence)
			}
			.store(in: &cancelBag)

		return sentencesVC
	}
}
