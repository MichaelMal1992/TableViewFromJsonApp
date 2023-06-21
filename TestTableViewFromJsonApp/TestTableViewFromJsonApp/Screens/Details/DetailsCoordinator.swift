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
    
    private var model: EmployeeModel?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    init(navigationController: UINavigationController, model: EmployeeModel) {
        self.navigationController = navigationController
        self.model = model
    }
    
    func start() {
        let viewModel = DetailsViewModel(model: model)
        let vc = DetailsViewController(coordinator: self, viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }
    
}
