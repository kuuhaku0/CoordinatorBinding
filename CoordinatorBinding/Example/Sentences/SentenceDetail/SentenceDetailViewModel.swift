//
//  SentenceDetailViewModel.swift
//  Coordinator Binding
//
//  Created by Tyler Zhao on 4/28/23.
//

import Combine
import Foundation

struct SentenceDetailActions {
	let sentenceSelected = JustPassthrough<Sentence?>()
	let createNewSentence = VoidPassthrough()
	let sentenceDeleted = JustPassthrough<Sentence>()
}

class SentenceDetailViewModel {
	struct Reaction {
		let createNewSentence: AnyPublisher<Void, Never>
	}

	@Published private(set) var selectedSentence: Sentence? = .none

	let createNewSentence = PassthroughSubject<Void, Never>()
	private var cancelBag = CancelBag()

	func perform(action: SentenceDetailActions) -> Reaction {
		action.sentenceSelected.assign(to: &$selectedSentence)

		action.sentenceDeleted
			.drop(while: { self.selectedSentence != $0 })
			.sink { [unowned self] _ in
				selectedSentence = .none
			}
			.store(in: &cancelBag)

		return .init(
			createNewSentence: createNewSentence.eraseToAnyPublisher()
		)
	}
}
