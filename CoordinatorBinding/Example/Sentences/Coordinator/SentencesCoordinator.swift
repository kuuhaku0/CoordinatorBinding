//
//  SentencesCoordinator.swift
//  Coordinator Binding
//
//  Created by Tyler Zhao on 4/28/23.
//

import Combine
import UIKit

final class SentencesCoordinator: NavigationCoordinator {

	private let dataManager: SentenceBuilderDataManager
	private let actionables = SentencesActions()
	private var cancelBag = CancelBag()

	init(dataManager: SentenceBuilderDataManager) {
		self.dataManager = dataManager
	}

	override func start() {
		navigationController.setViewControllers([createSentencesScene()], animated: false)
	}

	func comform(rules: SentencesActions) -> SentencesActions {
		rules.onNewSentenceCreated
			.sink { [unowned self] in
				actionables.onNewSentenceCreated.send($0)
			}
			.store(in: &cancelBag)

		return actionables
	}
}

extension SentencesCoordinator {
	private func createSentencesScene() -> UIViewController {
		let viewModel = SentencesViewModel(sentences: dataManager.allSentences)
		let sentencesVC = SentenceViewController(viewModel: viewModel)

		let reactions = viewModel.perform(action: actionables)

		reactions.sentenceDeleted
			.sink(receiveValue: actionables.sentenceDeleted.send(_:))
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
