//
//  Extensions.swift
//  WeatherApp
//
//  Created by Adam Wienconek on 04/12/2020.
//

import Foundation

extension URLRequest {
    init(url: URL, method: String) {
        self.init(url: url)
        httpMethod = method
    }
}
