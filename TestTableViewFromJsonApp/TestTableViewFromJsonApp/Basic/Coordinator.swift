//
//  Coordinator.swift
//  TestTableViewFromJsonApp
//
//  Created by Mikhail Malaschenko on 16.06.23.
//

import Foundation
import UIKit

protocol Coordinator: AnyObject {
    var parentCoordinator: Coordinator? { get set }
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get }
    
    init(navigationController: UINavigationController)
    func start()
    func goNext(_ child: Coordinator)
    func finish(_ child: Coordinator?)
}

extension Coordinator {
    func finish(_ child: Coordinator?) {
        childCoordinators.removeAll { $0 === child }
    }
    
    func goNext(_ child: Coordinator) {
        childCoordinators.append(child)
        child.parentCoordinator = self
        child.start()
    }
}
