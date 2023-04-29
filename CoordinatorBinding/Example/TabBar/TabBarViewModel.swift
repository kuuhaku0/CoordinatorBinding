//
//  TabBarViewModel.swift
//  Coordinator Binding
//
//  Created by Tyler Zhao on 4/28/23.
//

import Foundation

class TabBarViewModel {
	var pickedWords: [PickedWords] {
		_pickedWords
	}

	private var _pickedWords: [PickedWords] = []
}
