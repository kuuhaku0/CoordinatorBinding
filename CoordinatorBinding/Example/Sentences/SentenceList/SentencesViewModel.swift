//
//  SentencesViewModel.swift
//  Coordinator Binding
//
//  Created by Tyler Zhao on 4/28/23.
//

import Combine

struct SentencesActions {
	let selectSentence = JustPassthrough<Sentence>()
	let deleteSentence = JustPassthrough<Sentence>()
	let onCreateSentence = JustPassthrough<Sentence>()
	let onSelectWordAtIndex = JustPassthrough<Int>()
}

class SentencesViewModel {
	@Published private(set) var sentences: [Sentence] = prefill

	let actions = SentencesActions()

	private var cancelBag = CancelBag()

	func perform(action: SentencesActions) -> SentencesActions {
		action.onCreateSentence
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
			.sink { [unowned self] indexToDelete in
				guard sentences.indices.contains(indexToDelete) else { return }
				let deletedSentence = sentences[indexToDelete]
				sentences.remove(at: indexToDelete)
				actions.deleteSentence.send(deletedSentence)
			}.store(in: &cancelBag)

		return actions
	}
}

