//
//  APIError.swift
//  WeatherApp
//
//  Created by Adam Wienconek on 04/12/2020.
//

import Foundation

enum APIError: Int, LocalizedError {
    case invalidUrl, noData, statusCode
    
    var errorDescription: String? {
        switch self {
        case .invalidUrl:
            return "Invalid URL"
        case .noData:
            return "Data was corrupted or empty"
        case .statusCode:
            return "Invalid server response"
        }
    }
}
