//
//  EmployeeResponseModel.swift
//  TestTableViewFromJsonApp
//
//  Created by Mikhail Malaschenko on 16.06.23.
//

import CoreData

struct EmployeeResponseModel: Codable {
    let data: [EmployeeModel]?
}

struct EmployeeModel: Codable, CoreDataConvertible {
    var uniqueId: String?
    let id: Int?
    let name: String?
    let gender: Gender?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(Int.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.gender = try container.decodeIfPresent(Gender.self, forKey: .gender)
        self.uniqueId = "\(id ?? 0)\(name ?? "")\(gender?.rawValue ?? "")"
    }
    
    init?(from entity: Employee) {
        self.id = entity.id.flatMap { Int($0) }
        self.name = entity.name
        self.gender = Gender(rawValue: entity.gender ?? "")
        self.uniqueId = entity.uniqueId
    }
    
    func toEntity(in context: NSManagedObjectContext) -> Employee {
        let employeeEntity = Employee(context: context)
        employeeEntity.id = id.flatMap { String($0) }
        employeeEntity.name = name
        employeeEntity.gender = gender?.rawValue
        employeeEntity.uniqueId = uniqueId
        return employeeEntity
    }
}

enum CodingKeys: String, CodingKey {
    case id, name, gender
}

enum Gender: String, Codable {
    case female = "Female"
    case male = "Male"
}

