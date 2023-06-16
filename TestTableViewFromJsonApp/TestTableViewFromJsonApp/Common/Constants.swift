//
//  Constants.swift
//  TestTableViewFromJsonApp
//
//  Created by Mikhail Malaschenko on 15.06.23.
//

import Foundation

struct Constants {
    
    struct Url {
        static let loadEmployees = URL(string: "https://run.mocky.io/v3/dde54de8-08bd-45bb-ac08-331e70811f1c")
    }
    
    struct NetworkErrorMessage {
        static let invalidResponse = "Invalid response from the server."
        
        static let invalidUrl = "The URL provided is invalid."
        
        static let clientError = { (statusCode: Int) in "Client error with status code: \(statusCode)" }
        
        static let serverError = { (statusCode: Int) in "Server error with status code: \(statusCode)" }
        
        static let statusCodeError = { (statusCode: Int) in "Invalid status code \(statusCode)" }
        
        static let unexpectedError = { (errorMessage: String) in "Unexpected error occurred: \(errorMessage)"}
    }
    
    struct AppBar {
        static let hide = "Hide"
        static let show = "Show"
        static let employeesTitle = "Employees"
    }
    
    struct Number {
        static let debounceMiliseconds = 300
    }
    
    struct Alert {
        static let errorTitle = "Error"
        static let okTitle = "Ok"
    }
}
