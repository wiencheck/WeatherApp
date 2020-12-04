//
//  City.swift
//  WeatherApp
//
//  Created by Adam Wienconek on 04/12/2020.
//

import Foundation

struct City: Codable, Hashable {
    let id: Int
    let name: String
    let coordinate: Coordinate
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
    }
}
