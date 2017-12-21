//
//  MapCoordinator.swift
//  ARGame
//
//  Created by Aleksandr on 19.12.2017.
//  Copyright © 2017 Aleksandr. All rights reserved.
//

import UIKit

class MapCoordinator {

    lazy var navController: UIViewController = {
        
        let map = MapWireFrame() as MapWireFramePresentation
        let mapVC = map.createModule()
        let navController = UINavigationController.init(rootViewController: mapVC)

        return navController
    }()
}
