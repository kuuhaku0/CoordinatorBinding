//
//  AnyCoordinator.swift
//  Coordinator Binding
//
//  Created by Tyler Zhao on 5/1/23.
//

import Foundation

struct AnyCoordinator {

	private let base: CoordinatorType

	init(_ base: CoordinatorType) {
		self.base = base
	}

	func removeChild(_ coordinator: CoordinatorType) {
		base.removeChild(coordinator)
	}
}
