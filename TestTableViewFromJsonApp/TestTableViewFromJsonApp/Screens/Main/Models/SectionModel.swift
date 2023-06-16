//
//  SectionModel.swift
//  TestTableViewFromJsonApp
//
//  Created by Mikhail Malaschenko on 16.06.23.
//

import RxDataSources
struct SectionModel {
    var header: String?
    var items: [EmployeeModel]
}

extension SectionModel: SectionModelType {
    
    init(original: SectionModel, items: [EmployeeModel]) {
        self = original
        self.items = items
    }
}
