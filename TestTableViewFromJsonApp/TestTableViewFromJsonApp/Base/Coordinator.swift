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
    var navigationController: UINavigationController { get set }
    
    func start()
    
    func didFinish(_ child: Coordinator?)
}

extension Coordinator {
    func didFinish(_ child: Coordinator?) {
        childCoordinators.removeAll { $0 === child }
    }
}
