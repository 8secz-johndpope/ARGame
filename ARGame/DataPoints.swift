//
//  DataMarkers.swift
//  ARGame
//
//  Created by Aleksandr on 21.12.2017.
//  Copyright © 2017 Aleksandr. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps

class DataPoints {

    fileprivate let queue = DispatchQueue(label: "DataPointsQueue", attributes: .concurrent)
    fileprivate var points: Array<ARPoint> = Array()
    fileprivate let db = Firestore.firestore()
    
    static let shared = DataPoints()
    private init() {
    }
    
    func download(completion: @escaping ((Array<ARPoint>)?) -> Void) {
        
        func downloadCompletion() {
            DispatchQueue.main.async {
                completion(self.getPoints())
            }
        }
        
        db.collection("Portals").getDocuments() { [unowned self] (querySnapshot, err) in
            
            if let err = err {
                print("Error getting documents: \(err)")
                downloadCompletion()
            } else {
                self.createPoints(querySnapshot!.documents, completion: {
                    downloadCompletion()
                })
            }
        }
    }
    
    func intersectLocation(_ location: CLLocation) -> Bool {
        
        if let points = getPoints() {
            
            for point in points {
                let locationPoint: CLLocation = CLLocation(latitude: point.marker.position.latitude,
                                                           longitude: point.marker.position.longitude)
                let distance = location.distance(from: locationPoint)
                
                if distance <= point.radius {
                    return true
                }
            }
        }

        return false
    }
}

struct ARPoint {
    let marker: GMSMarker
    let radius: Double
    let address: String?
}

extension DataPoints {
    
    func addPoint(_ point: ARPoint) {
        queue.async(flags: .barrier) {
            self.points.append(point)
        }
    }
    
    func getPoints() -> Array<ARPoint>? {
        var result: Array<ARPoint>?
        queue.sync {
            result = points
        }
        return result
    }
    
    func removePoints() {
        queue.async(flags: .barrier) {
            self.points.removeAll()
        }
    }
    
    func createPoints(_ documents: Array<DocumentSnapshot>, completion: (()->())?) {
        
       // let queue = DispatchQueue(label: "DataPoints.createPoints.queue")
        
       // queue.async() { [unowned self] in
            
            self.removePoints()
            
            for document in documents {
                if let point = self.createPoint(document.data()) {
                    self.addPoint(point)
                }
            }
            
            completion?()
       // }
    }
    
    func createPoint(_ data: Dictionary<String, Any>) -> ARPoint? {
        
        guard let coordinate = data["coordinate"] as? GeoPoint
            else { return nil }
        
        guard let radius = data["radius"] as? Double
            else { return nil }
        
        let position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let marker = GMSMarker(position: position)
        
        if let name = data["name"] as? String {
            marker.title = name
        }
        
        let address = data["address"] as? String
        
        let point = ARPoint(marker: marker, radius: radius, address: address)

        return point
    }
}
