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
        
//        let q_one = DispatchQueue(label: "one")
//        let q_two = DispatchQueue(label: "two")
//        let group = DispatchGroup()
//        
//        var counter = 0
//        var mutex = pthread_mutex_t()
//        pthread_mutex_init(&mutex, nil)
//        
//        func operation() {
//            for _ in 0 ..< 800 {
//                pthread_mutex_lock(&mutex)
//                counter += 1
//                print(Thread.current, counter)
//                pthread_mutex_unlock(&mutex)
//            }
//            print("finished")
//        }
//
//        q_one.async(execute: operation)
//        q_two.async(execute: operation)
//
//        print(counter)
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
        
        var intersect = false
        
        queue.sync {
            for point in points {
                let locationPoint: CLLocation = CLLocation(latitude: point.marker.position.latitude,
                                                           longitude: point.marker.position.longitude)
                let distance = location.distance(from: locationPoint)
                
                if distance <= point.radius {
                    intersect = true
                    break;
                }
            }
        }
        
        return intersect
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
        
        self.removePoints()
        
        for document in documents {
            if let point = self.createPoint(document.data()) {
                self.addPoint(point)
            }
        }
        
        completion?()
    }
    
    func createPoint(_ data: Dictionary<String, Any>) -> ARPoint? {
        
        guard let coordinate = data["coordinate"] as? GeoPoint
            else { return nil }
        
        guard let radius = data["radius"] as? Double
            else { return nil }
        
        let position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let marker = GMSMarker(position: position) // GMSMarker создается на main thread, иначе краш
        
        if let name = data["name"] as? String {
            marker.title = name
        }
        
        let address = data["address"] as? String
        let point = ARPoint(marker: marker, radius: radius, address: address)

        return point
    }
}
