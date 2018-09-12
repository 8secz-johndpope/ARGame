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
        mapVC.tabBarItem.image = UIImage(named: "tab_bar_locate")
        
        let cameraVC = CameraViewController()
        cameraVC.tabBarItem.title = "tab_item_camera".lcd
        cameraVC.tabBarItem.image = UIImage(named: "tab_bar_camera")

        let menuVC = UIViewController()
        menuVC.tabBarItem.title = "tab_item_menu".lcd
        menuVC.tabBarItem.image = UIImage(named: "tab_bar_menu")
        
        viewControllers = [mapVC, cameraVC, menuVC]
    }
}

extension TabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        didSelect?(viewController)
    }
}

