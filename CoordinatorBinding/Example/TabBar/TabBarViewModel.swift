//
//  TabBarViewModel.swift
//  Coordinator Binding
//
//  Created by Tyler Zhao on 4/28/23.
//

import Combine
import Foundation

class TabBarViewModel {
	@Published private(set) var words: [Word] = []
	private var cancelBag = CancelBag()

	let didSelectItemAt = JustPassthrough<Int>()

	func perform(actions: SentencesActions) -> JustPassthrough<Int> {
		actions.onCreateSentence
			.map { [] }
			.assign(to: &$words)

		Publishers
			.Merge(actions.onNewSentenceCreated,
				   actions.selectSentence
			)
			.map(\.words)
			.assign(to: &$words)

		actions
			.sentenceDeleted
			.sink { [unowned self] sentence in
				words = words == sentence.words ? [] : words
			}.store(in: &cancelBag)

		return didSelectItemAt
	}
}
