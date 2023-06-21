//
//  DetailsVewModel.swift
//  TestTableViewFromJsonApp
//
//  Created by Mikhail Malaschenko on 16.06.23.
//

import Foundation

final class DetailsViewModel: AssociatedViewModel {
    
    let model: EmployeeModel?
    
    init(model: EmployeeModel?) {
        self.model = model
    }
    
    func loadData() { }
}
