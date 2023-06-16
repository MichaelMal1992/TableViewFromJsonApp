//
//  MainCoordinator.swift
//  TestTableViewFromJsonApp
//
//  Created by Mikhail Malaschenko on 16.06.23.
//

import UIKit
import RxSwift

class MainCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var disposeBag = DisposeBag()
    
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
    
    func goToDetails(with employee: EmployeeModel) { }
    
    func didFinish(_ child: Coordinator?) {
        guard let child, let index = childCoordinators.firstIndex(where: { $0 === child }) else { return }
        childCoordinators.remove(at: index)
    }
    
}

