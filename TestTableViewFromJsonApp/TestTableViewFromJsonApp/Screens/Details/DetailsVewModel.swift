//
//  DetailsVewModel.swift
//  TestTableViewFromJsonApp
//
//  Created by Mikhail Malaschenko on 16.06.23.
//

import RxSwift
import RxRelay

final class DetailsViewModel {
    private let dispose = DisposeBag()
    
    let model: BehaviorRelay<EmployeeModel>
    private let _model: EmployeeModel
    
    init(model: EmployeeModel) {
        self._model = model
        self.model = BehaviorRelay(value: model)
    }
    
}
