//
//  MainCoordinator.swift
//  TestTableViewFromJsonApp
//
//  Created by Mikhail Malaschenko on 16.06.23.
//

import UIKit
import RxSwift

final class MainCoordinator: Coordinator {
    weak var parentCoordinator: Coordinator? = nil
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let service = EmployeeService()
        let viewModel = MainViewModel(employeeService: service)
        let vc = MainViewController(coordinator: self, viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }
    
}
