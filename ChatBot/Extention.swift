//
//  Extention.swift
//  ChatBot
//
//  Created by Quang Bao on 06/07/2023.
//

import Foundation

enum NetworkError: Error {
    case invalidResponse
    case badResponse(int: Int)
    
    var description: String {
        switch self {
        case .invalidResponse:
            return "Invalid response"
        case .badResponse(int: let int):
            return "Bad Response: \(int)"
        }
    }
}

extension String: Error {}
