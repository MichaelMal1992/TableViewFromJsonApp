//
//  DetailsViewController.swift
//  TestTableViewFromJsonApp
//
//  Created by Mikhail Malaschenko on 16.06.23.
//

import UIKit
import RxSwift

final class DetailsViewController: UIViewController, ConfigurableViewController {
    @IBOutlet private weak var idLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var genderLabel: UILabel!
    
    private let coordinator: DetailsCoordinator
    private let viewModel: DetailsViewModel
    
    init(coordinator: DetailsCoordinator, viewModel: DetailsViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        super.init(nibName: Self.nibName, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        coordinator.parentCoordinator?.finish(coordinator)
    }
    
    
}

//MARK: Configure
extension DetailsViewController {
    func configure() {
        idLabel.text = viewModel.model?.id.flatMap(String.init)
        nameLabel.text = viewModel.model?.name
        genderLabel.text = viewModel.model?.gender?.rawValue
        navigationItem.title = viewModel.model?.name
        
    }
}
