//
//  TabBarCoordinator.swift
//  Coordinator Binding
//
//  Created by Tyler Zhao on 4/28/23.
//

import Combine
import UIKit

final class TabBarCoordinator: Coordinator {

	var childCoordinators: [Coordinator] = []
	lazy var rootViewController: UIViewController = createTabBarController()
	let navigationController: UINavigationController

	init(nav: UINavigationController) {
		navigationController = nav
	}

	private let actionables = SentencesActions()
	private var cancelBag = CancelBag()

	func start() {
		navigationController.setViewControllers([rootViewController], animated: false)
	}
}

extension TabBarCoordinator {

	func createTabBarController() -> UIViewController {
		let viewModel = TabBarViewModel()
		let tabVC = TabBarViewController(viewModel: viewModel)

		tabVC.setViewControllers([
			makeSentencesScene(),
			makeSentenceDetailScene()
		], animated: false)

		viewModel.perform(actions: actionables)
		return tabVC
	}

	func makeSentencesScene() -> UIViewController {
		let coordinator = SentencesCoordinator(nav: navigationController)
		let behaviors = coordinator.conform(rules: actionables)

		behaviors
			.deleteSentence
			.sink(receiveValue: actionables.deleteSentence.send(_:))
			.store(in: &cancelBag)

		behaviors
			.selectSentence
			.sink(receiveValue: actionables.selectSentence.send(_:))
			.store(in: &cancelBag)

		childCoordinators.append(coordinator)
		coordinator.start()

		let tabItem = UITabBarItem(title: "Sentences", image: .checkmark, tag: 0)
		let vc = coordinator.rootViewController
		vc.tabBarItem = tabItem
		return vc
	}

	func makeSentenceDetailScene() -> UIViewController {
		let coordinator = SentenceDetailCoordinator()

		childCoordinators.append(coordinator)
		coordinator.start()

		let tabItem = UITabBarItem(title: "Builder", image: .add, tag: 1)
		let vc = coordinator.rootViewController
		vc.tabBarItem = tabItem
		return vc
	}

	func makeSentenceBuilderScene() -> UIViewController {
		let coordinator = SentenceBuilderCoordinator()

		childCoordinators.append(coordinator)
		coordinator.start()

		return coordinator.rootViewController
	}
}
