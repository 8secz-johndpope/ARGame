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
    let db = Firestore.firestore()
    
    func refreshData() {
        createData()
    }
    
    func createData() {
        
        db.collection("Portals").getDocuments() { [weak self] (querySnapshot, err) in
            
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self?.createData(querySnapshot!.documents)
            }
        }
    }
    
    func createData(_ documents: Array<DocumentSnapshot>) {
        
        var data: Array<AnyObject> = Array()

        for document in documents {
            if let marker = self.createMarker(document.data()) {
                data.append(marker)
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.output.updateData(data)
        }
    }
    
    func createMarker(_ data: Dictionary<String, Any>) -> GMSMarker? {
        
        guard let coordinate = data["coordinate"] as? GeoPoint
            else { return nil }
        
        let position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let marker = GMSMarker(position: position)
        
        if let name = data["name"] as? String {
            marker.title = name
        }

        return marker
    }
}
