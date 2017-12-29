//
//  MapViewController.swift
//  ARGame
//
//  Created by Aleksandr on 19.12.2017.
//  Copyright © 2017 Aleksandr. All rights reserved.
//

import UIKit
import GoogleMaps

protocol MapViewPresentation: class {
    func updateData(_ data: Array<AnyObject>)
}

class MapViewController: UIViewController, MapViewPresentation {

    var presenter: MapPresentation?
    
    let mapView = GMSMapView()
    let locationManager = CLLocationManager()
    
    override func loadView() {
        configureMap()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "tab_item_map".lcd
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.refreshData()
    }
    
    // MARK: - Map
    func configureMap() {
        
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        view = mapView
        
        /// при старте карты нацелимся на текущую локацию
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - Data
    func updateData(_ data: Array<AnyObject>) {
        updateMapMarkers(data)
    }
  
    func updateMapMarkers(_ data: Array<AnyObject>) {
        
        mapView.clear()
        
        for obj in data {
            if let marker = obj as? GMSMarker {
                marker.map = mapView
            }
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last
            else { return }
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 17.0)
        mapView.animate(to: camera)

        locationManager.stopUpdatingLocation()
    }
}
