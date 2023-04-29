//
//  Coordinator.swift
//  Coordinator Binding
//
//  Created by Tyler Zhao on 4/28/23.
//

import UIKit

protocol Coordinator {
	func start()
	var rootViewController: UIViewController { get set }
}
