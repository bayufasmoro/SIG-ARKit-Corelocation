//
//  MainViewController.swift
//  ARKit+CoreLocation
//
//  Created by MF839 on 20/06/19.
//  Copyright © 2019 Project Dent. All rights reserved.
//

import CoreLocation
import MapKit
import UIKit

@available(iOS 11.0, *)
class MainViewController: UIViewController {
    
    @IBOutlet weak var showMapSwitch: UISwitch!
    @IBOutlet weak var addressText: UITextField!
    @IBOutlet weak var searchResultTable: UITableView!
    @IBOutlet weak var refreshControl: UIActivityIndicatorView!
    
    var locationManager = CLLocationManager()
    
    var mapSearchResults: [MKMapItem]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.headingFilter = kCLHeadingFilterNone
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.delegate = self
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
        
        locationManager.requestWhenInUseAuthorization()
        
        addressText.delegate = self
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @IBAction func tappedPoi(_ sender: Any) {
        let vc = createARVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func tappedSearch(_ sender: Any) {
        guard let text = addressText.text, !text.isEmpty else {
            return
        }
        
        searchForLocation()
    }
}

// MARK: - UITextFieldDelegate

@available(iOS 11.0, *)
extension MainViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string == "\n" {
            DispatchQueue.main.async { [weak self] in
                self?.searchForLocation()
            }
        }
        
        return true
    }
    
}

// MARK: - DataSource

@available(iOS 11.0, *)
extension MainViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let mapSearchResults = mapSearchResults else {
            return 0
        }
        
        return mapSearchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
        guard let mapSearchResults = mapSearchResults,
            indexPath.row < mapSearchResults.count,
            let locationCell = cell as? LocationCell else {
                return cell
        }
        locationCell.locationManager = locationManager
        locationCell.mapItem = mapSearchResults[indexPath.row]
        
        return locationCell
    }
}

// MARK: - UITableViewDelegate

@available(iOS 11.0, *)
extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let mapSearchResults = mapSearchResults, indexPath.row < mapSearchResults.count else {
            return
        }
        let selectedMapItem = mapSearchResults[indexPath.row]
        getDirections(to: selectedMapItem)
    }
    
}

// MARK: - CLLocationManagerDelegate

@available(iOS 11.0, *)
extension MainViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
}

// MARK: - Implementation

@available(iOS 11.0, *)
extension MainViewController {
    
    func createARVC() -> POIViewController {
        let arclVC = POIViewController.loadFromStoryboard()
        arclVC.showMap = showMapSwitch.isOn
        
        return arclVC
    }
    
    func getDirections(to mapLocation: MKMapItem) {
        refreshControl.startAnimating()
        
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = mapLocation
        request.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: request)
        
        directions.calculate(completionHandler: { response, error in
            defer {
                DispatchQueue.main.async { [weak self] in
                    self?.refreshControl.stopAnimating()
                }
            }
            if let error = error {
                return print("Error getting directions: \(error.localizedDescription)")
            }
            guard let response = response else {
                return assertionFailure("No error, but no response, either.")
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                
                let arclVC = self.createARVC()
                arclVC.routes = response.routes
                self.navigationController?.pushViewController(arclVC, animated: true)
            }
        })
    }
    
    /// Searches for the location that was entered into the address text
    func searchForLocation() {
        guard let addressText = addressText.text, !addressText.isEmpty else {
            return
        }
        
        refreshControl.startAnimating()
        defer {
            self.addressText.resignFirstResponder()
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = addressText
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            defer {
                DispatchQueue.main.async { [weak self] in
                    self?.refreshControl.stopAnimating()
                }
            }
            if let error = error {
                return assertionFailure("Error searching for \(addressText): \(error.localizedDescription)")
            }
            guard let response = response, response.mapItems.count > 0 else {
                return assertionFailure("No response or empty response")
            }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                self.mapSearchResults = response.sortedMapItems(byDistanceFrom: self.locationManager.location)
                self.searchResultTable.reloadData()
            }
        }
    }
}

extension MKLocalSearch.Response {
    
    func sortedMapItems(byDistanceFrom location: CLLocation?) -> [MKMapItem] {
        guard let location = location else {
            return mapItems
        }
        
        return mapItems.sorted { (first, second) -> Bool in
            guard let d1 = first.placemark.location?.distance(from: location),
                let d2 = second.placemark.location?.distance(from: location) else {
                    return true
            }
            
            return d1 < d2
        }
    }
    
}
