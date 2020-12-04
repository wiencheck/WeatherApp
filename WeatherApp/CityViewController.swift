//
//  CityViewController.swift
//  WeatherApp
//
//  Created by Adam Wienconek on 04/12/2020.
//

import UIKit

extension Date {
    static func hour(from unixTime: Double) -> String {
        let date = Date(timeIntervalSince1970: unixTime)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "HH" //Specify your format that you want
        let strDate = dateFormatter.string(from: date)
        return strDate
    }
}

class CityViewController: UIViewController {
    
    var service: APIService!
    var city: City!
    
    private var current: WeatherForecast?
    private var forecasts = [WeatherForecast]()
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = city.name
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        service.getForecast(for: city.coordinate) { result in
                    switch result {
                    case .success(let forecast):
                        DispatchQueue.main.async {
                            self.updateData(with: forecast)
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
    }
    
    private func updateData(with forecast: LocalForecast) {
        current = forecast.current
        let nearest = Array(forecast.hourly[1..<4])
        forecasts = nearest
        tableView.reloadData()
    }
    
}

extension CityViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return forecasts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WeatherCell.identifier, for: indexPath) as? WeatherCell else {
            fatalError()
        }
        let weather: WeatherForecast
        if indexPath.section == 0, let current = current {
            weather = current
        } else if !forecasts.isEmpty {
            weather = forecasts[indexPath.row]
        } else {
            return cell
        }
        cell.temperatureLabel.text = "Temp: \(weather.temperature) F"
        cell.hourLabel.text = Date.hour(from: weather.utcTime) + ":00"
        cell.humidityLabel.text = "Humidity: \(weather.humidity)%"
        cell.windSpeedLabel.text = "Wind: \(weather.windSpeed)mph"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Current"
        }
        return "Forecast"
    }
}

class WeatherCell: UITableViewCell {
    static let identifier = "cell"
    
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    
}
