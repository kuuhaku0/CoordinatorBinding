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
	var rootViewController: UIViewController

	init(window: UIWindow) {
		self.rootViewController = UINavigationController()
		self.window = window
	}

	func start() {
//		let mainTabBarCoordinator = TabBarCoordinator(nav: UINavigationController())
//		self.childCoordinators = [mainTabBarCoordinator]
		window.rootViewController = rootViewController
	}
}
