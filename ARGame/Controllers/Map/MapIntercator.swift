//
//  MapIntercator.swift
//  ARGame
//
//  Created by Aleksandr on 19.12.2017.
//  Copyright © 2017 Aleksandr. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase

protocol MapInteractorUseCase: class {
    func refreshData()
}

class MapIntercator: MapInteractorUseCase {

    weak var output: MapInteractorOutput!
    var markers: Array<GMSMarker> = Array()
    
    func refreshData() {
        createData()
    }
    
    func createData() {
        DataPoints.shared.download { [weak self] (points) in
            guard let strongSelf = self
                else { return }
            
            if let points = points {
                strongSelf.createMarkers(points)
            }
            
            strongSelf.output.updateData(strongSelf.markers)
        }
    }
    
    func createMarkers(_ points: Array<ARPoint>) {
        markers.removeAll()

        for point in points {
            markers.append(point.marker)
        }
    }
}
