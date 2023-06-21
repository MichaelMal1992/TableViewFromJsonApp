//
//  ConfigurableViewController.swift
//  TestTableViewFromJsonApp
//
//  Created by Mikhail Malaschenko on 21.06.23.
//

import UIKit

protocol ConfigurableViewController: UIViewController, XibLoadable {
    associatedtype ViewModelType: AssociatedViewModel
    associatedtype CoordinatorType: Coordinator
    
    init(coordinator: CoordinatorType, viewModel: ViewModelType)
}
