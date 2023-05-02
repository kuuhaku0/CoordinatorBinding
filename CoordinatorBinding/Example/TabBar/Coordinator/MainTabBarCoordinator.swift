//
//  TabBarCoordinator.swift
//  Coordinator Binding
//
//  Created by Tyler Zhao on 4/28/23.
//

import Combine
import UIKit

final class MainTabBarCoordinator: TabBarCoordinator {
	fileprivate enum Tab {
		case sentences
		case createNew
	}

	private let dataManager = SentenceBuilderDataManager()
	private let actionables = SentencesActions()
	private var cancelBag = CancelBag()

	override func start() {
		[.sentences, .createNew].forEach(createTab)
		setupTabController()
	}

	private func setupTabController() {
		let viewModel = TabBarViewModel()
		let reactions = viewModel.perform(actions: actionables)
		let viewControllers = childCoordinators.map { $0.viewController }

		reactions
			.sink {[unowned self] index in
				goToSentenceBuilder(createNew: false)
				actionables.onSelectWordAtIndex.send(index)
			}
			.store(in: &cancelBag)

		tabBarController.bind(viewModel: viewModel)
		tabBarController.setViewControllers(viewControllers, animated: false)
	}

	private func createTab(_ tab: Tab) {
		let coordinator = createCoordinator(forTab: tab)
		addChild(coordinator)
		coordinator.start()
		coordinator.viewController.tabBarItem = tab.tabBarItem
	}

	private func createCoordinator(forTab tab: Tab) -> CoordinatorType {
		switch tab {
		case .sentences:
			return makeSentencesScene()
		case .createNew:
			return makeCreateSentenceScene()
		}
	}

	// Perform navigations in class body
	private func goToSentenceBuilder(createNew: Bool) {
		dataManager.shouldCreateNewSentence(new: createNew)

		let scene = makeSentenceBuilderScene()
		addChild(scene)
		scene.start()

		tabBarController.present(scene.viewController, animated: true)
	}
}

// Build Coordinators in extensions
private extension MainTabBarCoordinator {

	func makeSentenceBuilderScene() -> CoordinatorType {
		let coordinator = SentenceBuilderCoordinator(dataManager: dataManager)
		let behaviors = coordinator.comform(selectedWordAtIndex: actionables.onSelectWordAtIndex)

		behaviors.onTermination
			.sink { [unowned self, unowned coordinator] sentence in
				// *** Note the `unowned coordinator`
				// *** It is important we capture weak reference when using references outside of `sink`
				if let sentence {
					actionables.onNewSentenceCreated.send(sentence)
				}
				removeChild(coordinator)
			}.store(in: &cancelBag)
		
		return coordinator
	}

	func makeSentencesScene() -> CoordinatorType {
		let coordinator = SentencesCoordinator(dataManager: dataManager)
		let behaviors = coordinator.comform(rules: actionables)

		behaviors
			.sentenceDeleted
			.sink { [unowned self] in
				actionables.sentenceDeleted.send($0)
			}
			.store(in: &cancelBag)

		behaviors
			.selectSentence
			.sink { [unowned self] in
				actionables.selectSentence.send($0)
			}
			.store(in: &cancelBag)

		return coordinator
	}

	func makeCreateSentenceScene() -> CoordinatorType {
		let coordinator = SentenceDetailCoordinator()
		let behaviors = coordinator.comform(rules: actionables)

		behaviors
			.createNewSentence
			.sink { [unowned self] in
				goToSentenceBuilder(createNew: true)
			}.store(in: &cancelBag)

		return coordinator
	}
}

private extension MainTabBarCoordinator.Tab {
	var tabBarItem: UITabBarItem {
		switch self {
		case .sentences:
			return UITabBarItem(title: "List", image: .strokedCheckmark, selectedImage: nil)
		case .createNew:
			return UITabBarItem(title: "Create", image: .add, selectedImage: nil)
		}
	}
}
