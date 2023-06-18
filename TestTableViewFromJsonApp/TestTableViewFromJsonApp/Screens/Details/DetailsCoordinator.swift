//
//  DetailsCoordinator.swift
//  TestTableViewFromJsonApp
//
//  Created by Mikhail Malaschenko on 16.06.23.
//

import UIKit

final class DetailsCoordinator: Coordinator {
    weak var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    private let model: EmployeeModel
    
    
    init(navigationController: UINavigationController, model: EmployeeModel) {
        self.navigationController = navigationController
        self.model = model
    }
    
    func start() {
        let vc = DetailsViewController.instantiate()
        vc.coordinator = self
        vc.viewModel = DetailsViewModel(model: model)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func finish() {
        parentCoordinator?.didFinish(self)
    }
    
}
