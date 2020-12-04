//
//  ViewController.swift
//  WeatherApp
//
//  Created by Adam Wienconek on 04/12/2020.
//

import UIKit

class ViewController: UIViewController {
    
    let service = APIService()
    
    private var searchedCities = [City: WeatherForecast]()
    private var cityNames: [String] {
        return searchedCities.keys.map {
            $0.name
        }.sorted()
    }
    
    private var selectedCity: City?
    
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.backgroundView = {
                let image = UIImage(named: "sky")
                let i = UIImageView(image: image)
                i.contentMode = .scaleAspectFill
                return i
            }()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "WeatherApp"
        reloadData()
    }
    
    private func reloadData() {
        service.searchedCitiesWeather { cities in
            self.searchedCities = cities
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    @IBAction private func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Weather", message: "Enter zip-code, to show current weather", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "zip-code"
        }
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(.init(title: "Search", style: .default, handler: { _ in
            guard let textField = alert.textFields?.first,
                  let text = textField.text else {
                return
            }
            self.getWeather(zipCode: text)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func getWeather(zipCode: String) {
        service.getWeather(for: zipCode) { result in
            let title: String
            let message: String
            switch result {
            case .success(let weather):
                title = weather.city.name
                message = "Temperature: \(weather.temperature)F\nHumidity: \(weather.humidity)\nWind speed: \(weather.windSpeed)\n"
            case .failure(let error):
                title = "Error ocurred"
                message = error.localizedDescription
            }
            DispatchQueue.main.async {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(.init(title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: {
                    self.reloadData()
                })
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let destination = segue.destination as? CityViewController {
            destination.service = service
            destination.city = selectedCity
        }
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cityNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CityCell.identifier, for: indexPath) as? CityCell else {
            fatalError()
        }
        let cityName = cityNames[indexPath.row]
        guard let city = searchedCities.keys.first(where: {$0.name == cityName}) else {
            fatalError()
        }
        cell.nameLabel.text = city.name
        cell.temperatureLabel.text = "\(searchedCities[city]?.temperature ?? 0) F"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let cityName = cityNames[indexPath.row]
        guard let city = searchedCities.keys.first(where: {$0.name == cityName}) else {
            fatalError()
        }
        selectedCity = city
        performSegue(withIdentifier: "city", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let parentWidth = collectionView.frame.width
        var insets = UIEdgeInsets.zero
        var spacing: CGFloat = 0
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            insets = flowLayout.sectionInset
            spacing = flowLayout.minimumInteritemSpacing
        }
        
        let cellWidth = (parentWidth - (insets.left + insets.right) - (2 * spacing)) / 3
        return CGSize(width: cellWidth, height: 96)
    }
}

class CityCell: UICollectionViewCell {
    static let identifier = "cityCell"
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 8
    }
}
