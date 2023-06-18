//
//  DetailsViewController.swift
//  TestTableViewFromJsonApp
//
//  Created by Mikhail Malaschenko on 16.06.23.
//

import UIKit
import RxSwift

final class DetailsViewController: UIViewController, XibLoadable {
    @IBOutlet private weak var idLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var genderLabel: UILabel!
    
    var viewModel: DetailsViewModel?
    var coordinator: DetailsCoordinator?
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        coordinator?.finish()
    }
    
    private func bindViewModel() {
        guard let viewModel else { return }
        
        viewModel.model.bind(onNext: { [weak self] model in
            guard let self else { return }
            self.idLabel.text = String(describing: model.id)
            self.nameLabel.text = model.name
            self.genderLabel.text = model.gender?.rawValue
            self.navigationItem.title = model.name
        }).disposed(by: disposeBag)
        
    }
}
