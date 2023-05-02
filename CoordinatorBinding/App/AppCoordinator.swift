//
//  AppCoordinator.swift
//  Coordinator Binding
//
//  Created by Tyler Zhao on 4/28/23.
//

import UIKit

final class AppCoordinator: CoordinatorType {

	let window: UIWindow

	var viewController: UIViewController {
		guard let rootVC = window.rootViewController else {
			fatalError("Window's `rootViewController` must be set first by calling `start` method")
		}
		return rootVC
	}

	private(set) var childCoordinators: [CoordinatorType]

	init(window: UIWindow) {
		self.window = window
		self.childCoordinators = []
	}

	func start() {
		let coordinator = MainTabBarCoordinator()
		addChild(coordinator)

		coordinator.parentCoordinator = self.eraseToAnyCoordinator()
		coordinator.start()

		let rootVC = coordinator.viewController
		self.window.rootViewController = rootVC
		self.window.makeKeyAndVisible()
	}

	func addChild(_ coordinator: CoordinatorType) {
		childCoordinators.append(coordinator)
	}

	func removeChild(_ coordinator: CoordinatorType) {
		guard let index = childCoordinators.firstIndex(where: { $0 === coordinator }) else { return }
		childCoordinators.remove(at: index)
	}
}

