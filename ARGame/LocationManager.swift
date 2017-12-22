//
//  LocationManager.swift
//  ARGame
//
//  Created by Aleksandr on 21.12.2017.
//  Copyright © 2017 Aleksandr. All rights reserved.
//

import UIKit
import GoogleMaps

class LocationManager: NSObject {

    var updateLocation: ((_ location: CLLocation) -> Void)?
    fileprivate let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
            updateLocation?(location)
        }
    }
}
