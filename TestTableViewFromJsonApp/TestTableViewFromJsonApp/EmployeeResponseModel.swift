//
//  EmployeeResponseModel.swift
//  TestTableViewFromJsonApp
//
//  Created by Mikhail Malaschenko on 16.06.23.
//

import Foundation

struct EmployeeResponseModel: Codable {
    let data: [EmployeeModel]?
}

struct EmployeeModel: Codable {
    let id: Int?
    let name: String?
    let gender: Gender?
}

enum Gender: String, Codable {
    case female = "Female"
    case male = "Male"
}
