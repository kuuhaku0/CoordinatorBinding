//
//  SentenceDataManager.swift
//  Coordinator Binding
//
//  Created by Tyler Zhao on 4/30/23.
//

import Combine

class SentenceBuilderDataManager {
	struct Output {
		let newSentenceCreated: AnyPublisher<Sentence, Never>
	}

	@Published private(set) var allSentences: [Sentence] = prefill

	// Word Constructor
	@Published private(set) var currentWords: [Word] = []

	let onNewWordAccepted = JustPassthrough<Word>()
	let onNewSentenceCreated = JustPassthrough<Sentence>()

	func bind() -> Output {
		Output(
			newSentenceCreated: onNewSentenceCreated.eraseToAnyPublisher()
		)
	}

	func constructSentence() {
		let newSentence = Sentence(words: currentWords)
		currentWords = newSentence.words
		allSentences.append(newSentence)
		onNewSentenceCreated.send(newSentence)
	}

	func selectSentence(_ sentence: Sentence) {
		currentWords = sentence.words
	}

	func acceptNewWord(_ word: Word) {
		guard !currentWords.contains(word) else { return }
		currentWords.append(word)
		onNewWordAccepted.send(word)
	}

	func setCreateNewSentence() {
		currentWords = []
	}

	func replaceWord(old: Word, new: Word) {
		guard let indexToReplace = currentWords.firstIndex(of: old) else { return }
		currentWords[indexToReplace] = new
	}
}
