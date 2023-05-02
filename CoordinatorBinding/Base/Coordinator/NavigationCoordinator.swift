//
//  NavigationCoordinator.swift
//  Coordinator Binding
//
//  Created by Tyler Zhao on 5/1/23.
//

import UIKit.UINavigationController

class NavigationCoordinator: Coordinator<UINavigationController> {

	override init(viewController: UINavigationController = .init(), childCoordinators: [CoordinatorType] = .init()) {
		super.init(viewController: viewController, childCoordinators: childCoordinators)
	}

	override func start() {
		navigationController.delegate = self
	}

	override func removeChild(_ coordinator: CoordinatorType) {
		if coordinator is UINavigationControllerDelegate {
			navigationController.delegate = self
		}
		super.removeChild(coordinator)
	}
}

extension NavigationCoordinator: UINavigationControllerDelegate {

	func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
		let childViewControllers = navigationController.viewControllers
		let transitionCoordinator = navigationController.transitionCoordinator
		let fromViewController = transitionCoordinator?.viewController(forKey: .from)
		guard let poppedViewController = fromViewController, !childViewControllers.contains(poppedViewController) else {
			return
		}
		removeFromParent()
	}
}
