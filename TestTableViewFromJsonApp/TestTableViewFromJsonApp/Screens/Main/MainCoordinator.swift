//
//  MainCoordinator.swift
//  TestTableViewFromJsonApp
//
//  Created by Mikhail Malaschenko on 16.06.23.
//

import UIKit
import RxSwift

class MainCoordinator: Coordinator {
    var parentCoordinator: Coordinator? = nil
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = MainViewController.instantiate()
        let service = EmployeeService()
        vc.coordinator = self
        vc.viewModel = MainViewModel(employeeService: service)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func goToDetails(with employee: EmployeeModel) {
        let child = DetailsCoordinator(navigationController: navigationController, model: employee)
        childCoordinators.append(child)
        child.parentCoordinator = self
        child.start()
    }
    
}

