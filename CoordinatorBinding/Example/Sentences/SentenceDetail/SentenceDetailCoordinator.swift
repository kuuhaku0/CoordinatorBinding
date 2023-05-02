//
//  SentenceDetailCoordinator.swift
//  Coordinator Binding
//
//  Created by Tyler Zhao on 4/29/23.
//

import UIKit

final class SentenceDetailCoordinator: NavigationCoordinator {

	private let actionables = SentenceDetailActions()
	private var cancelBag = CancelBag()

	override func start() {
		navigationController.setViewControllers([createSentenceDetailScene()], animated: false)
	}

	func comform(rules: SentencesActions) -> SentenceDetailActions {
		rules.selectSentence
			.sink { [unowned self] sentence in
				actionables.sentenceSelected.send(sentence)
			}
			.store(in: &cancelBag)

		rules.sentenceDeleted
			.sink { [unowned self] deletion in
				actionables.sentenceDeleted.send(deletion)
			}
			.store(in: &cancelBag)

		rules.onNewSentenceCreated
			.sink { [unowned self] sentence in
				actionables.sentenceSelected.send(sentence)
			}.store(in: &cancelBag)

		return actionables
	}
}

extension SentenceDetailCoordinator {
	private func createSentenceDetailScene() -> SentenceDetailViewController {
		let vm = SentenceDetailViewModel()
		let vc = SentenceDetailViewController(viewModel: vm)

		let reactions = vm.perform(action: actionables)

		reactions.createNewSentence
			.sink { [unowned self] in
				actionables.createNewSentence.send()
			}
			.store(in: &cancelBag)

		return vc
	}
}
