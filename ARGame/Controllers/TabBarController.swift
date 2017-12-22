//
//  TabBarController.swift
//  ARGame
//
//  Created by Aleksandr on 22/11/2017.
//  Copyright © 2017 Aleksandr. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    var didSelect: ((_ viewController: UIViewController) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        configureControllers()
    }
    
    func configureControllers () {
        
        let mapVC = MapCoordinator().navController
        mapVC.tabBarItem.title = "tab_item_map".lcd
        
        let cameraVC = CameraViewController()
        cameraVC.tabBarItem.title = "tab_item_camera".lcd

        viewControllers = [mapVC, cameraVC]
    }
}

extension TabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        didSelect?(viewController)
    }
}

