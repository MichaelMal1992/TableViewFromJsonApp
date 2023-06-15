//
//  Constants.swift
//  TestTableViewFromJsonApp
//
//  Created by Mikhail Malaschenko on 15.06.23.
//

import Foundation

struct Constants {
    struct NetworkErrorMessage {
        
        static let invalidResponse = "Invalid response from the server."
        
        static let clientError = { (statusCode: Int) in "Client error with status code: \(statusCode)" }
        
        static let serverError = { (statusCode: Int) in "Server error with status code: \(statusCode)" }
        
        static let statusCodeError = { (statusCode: Int) in "Invalid status code \(statusCode)" }
        
        static let unexpectedError = { (errorMessage: String) in "Unexpected error occurred: \(errorMessage)"}
    }
}
