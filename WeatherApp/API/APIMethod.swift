//
//  APIMethod.swift
//  WeatherApp
//
//  Created by Adam Wienconek on 04/12/2020.
//

import Foundation

protocol APIMethod {
    static var apiKey: String { get }
    static var countryCode: String? { get }
    var path: String { get }
    var httpMethod: String { get }
    func request(with params: [String: String]?) -> URLRequest?
}

extension APIMethod {
    static var apiKey: String {
        return APIService.apiKey
    }
    
    static var scheme: String {
        return "https"
    }
    
    static var root: String {
        return "api.openweathermap.org"
    }
    
    static var rootExtension: String {
        return "/data/2.5/"
    }
    
    static var countryCode: String? {
        return APIService.countryCode
    }
    
    var httpMethod: String {
        return "GET"
    }
}

extension APIMethod where Self: RawRepresentable, RawValue == String {
    func request(with params: [String: String]?) -> URLRequest? {
        var components = URLComponents()
        components.scheme = Self.scheme
        components.host = Self.root
        components.path = Self.rootExtension + path
        
        var items = params?.compactMap { key, value in
            URLQueryItem(name: key, value: value)
        } ?? []
        items.append(URLQueryItem(name: "appId", value: Self.apiKey))
        components.queryItems = items
        
        guard let url = components.url else {
            return nil
        }
        return URLRequest(url: url, method: httpMethod)
    }
}

