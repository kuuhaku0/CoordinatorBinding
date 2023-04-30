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
		actions
			.onCreateSentence
			.sink { [unowned self] newSentence in
				words = newSentence.words
			}.store(in: &cancelBag)

		actions
			.selectSentence
			.map(\.words)
			.assign(to: &$words)

		actions
			.deleteSentence
			.sink { [unowned self] sentence in
				words = words == sentence.words ? [] : words
			}.store(in: &cancelBag)

		return didSelectItemAt
	}
}
