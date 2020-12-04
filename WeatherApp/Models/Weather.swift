//
//  Weather.swift
//  WeatherApp
//
//  Created by Adam Wienconek on 04/12/2020.
//

import Foundation

struct Weather: Codable {
    let temperature: Double
    let humidity: Int
    let windSpeed: Double
    let city: City
    
    private enum RootCodingKeys: String, CodingKey {
        case main, wind
        case coordinate = "coord"
        case cityId = "id"
        case cityName = "name"
    }
    
    private enum MainCodingKeys: String, CodingKey {
        case temperature = "temp"
        case humidity
    }
    
    private enum WindCodingKeys: String, CodingKey {
        case speed
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootCodingKeys.self)
        // Decode temperature
        let mainContainer = try container.nestedContainer(keyedBy: MainCodingKeys.self, forKey: .main)
        temperature = try mainContainer.decode(Double.self, forKey: .temperature)
        humidity = try mainContainer.decode(Int.self, forKey: .humidity)
        
        // Wind
        let windContainer = try container.nestedContainer(keyedBy: WindCodingKeys.self, forKey: .wind)
        windSpeed = try windContainer.decode(Double.self, forKey: .speed)
        
        // Coordinates
        let coordinate = try container.decode(Coordinate.self, forKey: .coordinate)
        
        // City
        let cityId = try container.decode(Int.self, forKey: .cityId)
        let cityName = try container.decode(String.self, forKey: .cityName)
        city = City(id: cityId, name: cityName, coordinate: coordinate)
    }
}
