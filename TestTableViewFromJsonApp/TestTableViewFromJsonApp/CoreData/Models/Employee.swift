//
//  Employee.swift
//  TestTableViewFromJsonApp
//
//  Created by Mikhail Malaschenko on 17.06.23.
//

import CoreData

@objc(Employee)
public class Employee: NSManagedObject {
    
    @NSManaged public var id: NSNumber?
    @NSManaged public var name: String?
    @NSManaged public var gender: String?
}
