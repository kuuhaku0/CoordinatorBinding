//
//  Coordinator.swift
//  Coordinator Binding
//
//  Created by Tyler Zhao on 4/28/23.
//

import UIKit

class Coordinator<T: UIViewController>: NSObject, CoordinatorType {

	var parentCoordinator: AnyCoordinator?

	var childCoordinators: [CoordinatorType] {
		_childCoordinators
	}

	var viewController: UIViewController {
		_viewController
	}

	fileprivate let _viewController: T
	fileprivate var _childCoordinators: [CoordinatorType] = []

	override private init() {
		self._viewController = T()
		self._childCoordinators = []
		super.init()
	}

	init(viewController: T = .init(), childCoordinators: [CoordinatorType] = []) {
		self._viewController = viewController
		self._childCoordinators = childCoordinators
		super.init()
	}

	func start() {
		fatalError("Start method must be implemented")
	}

	func addChild(_ coordinator: CoordinatorType) {
		_childCoordinators.append(coordinator)
	}

	func removeChild(_ coordinator: CoordinatorType) {
		guard let index = _childCoordinators.firstIndex(where: { $0 === coordinator }) else { return }
		_childCoordinators.remove(at: index)
	}

	func removeAllChildren() {
		_childCoordinators.removeAll()
	}

	func removeFromParent() {
		parentCoordinator?.removeChild(self)
	}

	deinit {
		removeAllChildren()
	}
}

extension NavigationCoordinator {
	var navigationController: UINavigationController {
		return _viewController
	}
}

extension TabBarCoordinator {
	var tabBarController: TabBarViewController {
		return _viewController
	}
}

