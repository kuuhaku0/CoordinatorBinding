//
//  SentencesViewModel.swift
//  Coordinator Binding
//
//  Created by Tyler Zhao on 4/28/23.
//

import Combine

struct SentencesActions {
	let selectSentence = JustPassthrough<Sentence>()
	let sentenceDeleted = JustPassthrough<Sentence>()
	let onCreateSentence = VoidPassthrough()
	let onNewSentenceCreated = JustPassthrough<Sentence>()
	let onSelectWordAtIndex = JustPassthrough<Int>()
}

class SentencesViewModel {
	@Published private(set) var sentences: [Sentence]

	private let actions = SentencesActions()
	private var cancelBag = CancelBag()

	init(sentences: [Sentence]) {
		self.sentences = sentences
	}

	func perform(action: SentencesActions) -> SentencesActions {
		action.onNewSentenceCreated
			.sink { [unowned self] newSentence in
				sentences.append(newSentence)
			}.store(in: &cancelBag)

		return actions
	}

	func transform(input: SentencesViewInputs) -> SentencesActions {
		input.didSelectSentenceAt
			.map { index in self.sentences[index] }
			.sink { [unowned self] sentence in
				actions.selectSentence.send(sentence)
			}
			.store(in: &cancelBag)

		input.deleteSentenceAt
			.sink { [unowned self] shouldDelete in
				let indexToDelete = shouldDelete.0
				let callback = shouldDelete.1

				guard sentences.indices.contains(indexToDelete) else {
					callback(false)
					return
				}
				
				let deletedSentence = sentences.remove(at: indexToDelete)
				callback(true)

				actions.sentenceDeleted.send(deletedSentence)
			}.store(in: &cancelBag)

		return actions
	}
}
