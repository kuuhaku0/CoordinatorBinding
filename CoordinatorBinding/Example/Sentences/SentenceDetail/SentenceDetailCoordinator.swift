//
//  SentenceDetailCoordinator.swift
//  Coordinator Binding
//
//  Created by Tyler Zhao on 4/29/23.
//

import UIKit

final class SentenceDetailCoordinator: Coordinator {

	var childCoordinators: [Coordinator] = []
	lazy var rootViewController: UIViewController = createSentenceDetailScene()

	private let actionables = SentenceDetailActions()
	private var cancelBag = CancelBag()

	func start() {
		print("Scene Detail Tab Start")
	}

	func comform(rules: SentencesActions) -> SentenceDetailActions {
		rules.selectSentence
			.sink { [unowned self] sentence in
				actionables.sentenceSelected.send(sentence)
			}
			.store(in: &cancelBag)

		rules.deleteSentence
			.sink { [unowned self] deletion in
				actionables.sentenceDeleted.send(deletion)
			}
			.store(in: &cancelBag)

		rules.onCreateSentence
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
