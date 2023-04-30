//
//  AppCoordinator.swift
//  Coordinator Binding
//
//  Created by Tyler Zhao on 4/28/23.
//

import UIKit

class AppCoordinator: Coordinator {


	let window: UIWindow
	var childCoordinators = [Coordinator]()
	lazy var rootViewController: UIViewController = createRootScene()

	init(window: UIWindow) {
		self.window = window
	}

	func start() {
		window.rootViewController = rootViewController
	}

	func createRootScene() -> UIViewController {
		let rootNav = UINavigationController()
		let mainTabBarCoordinator = TabBarCoordinator(nav: rootNav)
		mainTabBarCoordinator.start()
		
		childCoordinators.append(mainTabBarCoordinator)
		rootNav.setViewControllers([mainTabBarCoordinator.rootViewController], animated: false)
		return rootNav
	}
}
