//
//  SentenceDataManager.swift
//  Coordinator Binding
//
//  Created by Tyler Zhao on 4/30/23.
//

import Combine

class SentenceBuilderDataManager {
	struct Output {
		let onCreateNewSentence: AnyPublisher<Void, Never>
		let newSentenceCreated: AnyPublisher<Sentence, Never>
	}

	@Published private(set) var allSentences: [Sentence] = prefill
	@Published private var currentWords: [Word] = []
	@Published private(set) var currentEdit: [Word] = []

	let onCreateNewSentence = VoidPassthrough()
	let onNewSentenceCreated = JustPassthrough<Sentence>()

	func bind() -> Output {
		// Type erased Publisher Output, erases JustPassthrough type Publisher
		Output(
			onCreateNewSentence: onCreateNewSentence.eraseToAnyPublisher(),
			newSentenceCreated: onNewSentenceCreated.eraseToAnyPublisher()
		)
	}

	func constructSentence() {
		let newSentence = Sentence(words: currentEdit)

		currentWords = currentEdit
		currentEdit = []

		allSentences.append(newSentence)
		onNewSentenceCreated.send(newSentence)
	}

	func selectSentence(_ sentence: Sentence) {
		currentWords = sentence.words
	}

	func acceptNewWord(_ word: Word) {
		guard !currentEdit.contains(word) else { return }
		currentEdit.append(word)
	}

	func shouldCreateNewSentence(new: Bool) {
		currentEdit = new ? [] : currentWords
	}

	func replaceWord(old: Word, new: Word) {
		guard let indexToReplace = currentWords.firstIndex(of: old) else { return }
		currentEdit[indexToReplace] = new
	}
}
