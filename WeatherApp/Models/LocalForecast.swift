//
//  LocalForecast.swift
//  WeatherApp
//
//  Created by Adam Wienconek on 04/12/2020.
//

import Foundation

struct LocalForecast: Codable {
    let current: WeatherForecast
    let hourly: [WeatherForecast]
    
    private enum CodingKeys: String, CodingKey {
        case current, hourly
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        current = try container.decode(WeatherForecast.self, forKey: .current)
        hourly = try container.decode([WeatherForecast].self, forKey: .hourly)
    }
}
