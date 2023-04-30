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

	let dataManager = SentenceBuilderDataManager()

	init(nav: UINavigationController) {
		navigationController = nav
	}

	private let actionables = SentencesActions()
	private var cancelBag = CancelBag()

	func start() {
		navigationController.setViewControllers([rootViewController], animated: false)
	}

	func goToSentenceBuilder() {
		let vc = makeSentenceBuilderScene()
		vc.modalPresentationStyle = .fullScreen
		navigationController.present(vc, animated: true)
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

		let reactions = viewModel.perform(actions: actionables)

		reactions
			.sink {[unowned self] index in
				goToSentenceBuilder()
				actionables.onSelectWordAtIndex.send(index)
			}
			.store(in: &cancelBag)

		return tabVC
	}

	func makeSentencesScene() -> UIViewController {
		let coordinator = SentencesCoordinator(
			nav: navigationController,
			dataManager: dataManager
		)

		let behaviors = coordinator.conform(rules: actionables)

		behaviors
			.deleteSentence
			.sink { [unowned self] sentence in
				actionables.deleteSentence.send(sentence)
			}
			.store(in: &cancelBag)

		behaviors
			.selectSentence
			.sink { [unowned self] sentence in
				actionables.selectSentence.send(sentence)
			}
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
		let behaviors = coordinator.comform(rules: actionables)

		behaviors
			.createNewSentence
			.sink { [unowned self] in
				goToSentenceBuilder()
			}.store(in: &cancelBag)

		childCoordinators.append(coordinator)
		coordinator.start()

		let tabItem = UITabBarItem(title: "Builder", image: .add, tag: 1)
		let vc = coordinator.rootViewController
		vc.tabBarItem = tabItem
		return vc
	}

	func makeSentenceBuilderScene() -> UIViewController {
		let coordinator = SentenceBuilderCoordinator(dataManager: dataManager)
		let behaviors = coordinator.comform(input: actionables.onSelectWordAtIndex)

		behaviors.onTermination
			.sink { [unowned self, unowned coordinator] in
				// *** Note `unowned coordinator`
				// *** It is important we capture weak reference when using references outside of `sink`
				coordinator.rootViewController.dismiss(animated: true)
				removeChild(child: coordinator)
			}.store(in: &cancelBag)

		childCoordinators.append(coordinator)
		coordinator.start()

		return coordinator.rootViewController
	}
}
