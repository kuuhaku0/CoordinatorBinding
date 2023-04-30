//
//  Coordinator.swift
//  Coordinator Binding
//
//  Created by Tyler Zhao on 4/28/23.
//

import UIKit

protocol Coordinator: AnyObject {
	func start()
	var childCoordinators: [Coordinator] { get set }
	var rootViewController: UIViewController { get set }
}

extension Coordinator {
	func removeChild(child: Coordinator) {
		childCoordinators.removeAll { $0 === child }
		print(childCoordinators.description)
	}
}
