//
//  CoordinatorType.swift
//  Coordinator Binding
//
//  Created by Tyler Zhao on 5/1/23.
//

import UIKit.UIViewController

protocol ChildCoordinatorType {
	var parentCoordinator: AnyCoordinator? { get }
}

protocol CoordinatorType: AnyObject {
	var childCoordinators: [CoordinatorType] { get }
	var viewController: UIViewController { get }
	func start()
	func addChild(_ coordinator: CoordinatorType)
	func removeChild(_ coordinator: CoordinatorType)
}

extension CoordinatorType {
	func eraseToAnyCoordinator() -> AnyCoordinator {
		AnyCoordinator(self)
	}
}
