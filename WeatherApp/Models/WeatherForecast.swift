//
//  WeatherForecast.swift
//  WeatherApp
//
//  Created by Adam Wienconek on 04/12/2020.
//

import Foundation

struct WeatherForecast: Codable {
    let utcTime: Double
    let temperature: Double
    let humidity: Int
    let windSpeed: Double
    
    private enum CodingKeys: String, CodingKey {
        case utcTime = "dt"
        case temperature = "temp"
        case humidity
        case windSpeed = "wind_speed"
    }
}
