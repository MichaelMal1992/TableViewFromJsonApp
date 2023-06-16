//
//  NetworkManager.swift
//  TestTableViewFromJsonApp
//
//  Created by Mikhail Malaschenko on 15.06.23.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    func fetchData<T: Decodable>(from url: URL?) async -> Result<T, NetworkError> {
        do {
            guard let url else { return .failure(.invalidUrl) }
            let (data, response) = try await URLSession.shared.data(from: url)
            if let error = statusCodeHandler(from: response) { return .failure(error) }
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            return .success(decodedData)
        } catch {
            return .failure(.unexpectedError(error.localizedDescription))
        }
    }
    
    private func statusCodeHandler(from response: URLResponse) -> NetworkError? {
        guard let httpResponse = response as? HTTPURLResponse else {
            return .invalidResponse
        }
        switch httpResponse.statusCode {
        case 200...299:
            return nil
        case 400...499:
            return .clientError(httpResponse.statusCode)
        case 500...599:
            return .serverError(httpResponse.statusCode)
        default:
            return .invalidStatus(httpResponse.statusCode)
        }
    }
}

enum NetworkError: LocalizedError {
    case invalidResponse
    case invalidUrl
    case clientError(Int)
    case serverError(Int)
    case invalidStatus(Int)
    case unexpectedError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return Constants.NetworkErrorMessage.invalidResponse
        case .invalidUrl:
            return Constants.NetworkErrorMessage.invalidUrl
        case .clientError(let statusCode):
            return Constants.NetworkErrorMessage.clientError(statusCode)
        case .serverError(let statusCode):
            return Constants.NetworkErrorMessage.serverError(statusCode)
        case .invalidStatus(let statusCode):
            return Constants.NetworkErrorMessage.statusCodeError(statusCode)
        case .unexpectedError(let errorMessage):
            return Constants.NetworkErrorMessage.unexpectedError(errorMessage)
        }
    }
}

