//
//  AppCoordinator.swift
//  ARGame
//
//  Created by Aleksandr on 21/11/2017.
//  Copyright © 2017 Aleksandr. All rights reserved.
//

import UIKit

protocol AppCoordinatorInterface: class {
    
    var navController: UINavigationController! { get set }
    
    func start()
    func logout()
}

class AppCoordinator: Coordinator {
    
    var navController: UINavigationController!
    
    internal var childCoordinators: [AnyObject] = []
    fileprivate var tabBarController: TabBarController!
    fileprivate var locationManager: LocationManager?
    
    init() {
        configureAppContent()
        configureLocationManager()
    }
    
    fileprivate func configureAppContent() {
        
        configureTabBarController()
        
        navController = UINavigationController.init(rootViewController: tabBarController)
        navController.navigationBar.isHidden = true
    }
    
    fileprivate func configureTabBarController() {
        
        tabBarController = TabBarController()
        tabBarController.didSelect = { [unowned self] (vc) -> Void in
            
            /*
             *  Сообщим контроллеру камеры об его активности
             *  Контроллер включит/выключит камеру
             */
            if vc is CameraViewControllerPresentation {
                self.cameraVC?.open()
            } else {
                self.cameraVC?.close()
            }
        }
    }
    
    fileprivate func configureLocationManager() {
        
        locationManager = LocationManager()
        locationManager?.updateLocation = { [unowned self] (location) -> Void in
            
            /*
             *  Сообщим контроллеру камеры о пересечении с меткой
             */
            if self.tabBarController.selectedViewController is CameraViewControllerPresentation {
                
                let intersect = DataPoints.shared.intersectLocation(location)
                
                if intersect == true {
                    // TODO i:
                    print(intersect)
                }
            }
        }
    }
    
    fileprivate lazy var cameraVC: CameraViewControllerPresentation? = {
        var cameraVC: CameraViewControllerPresentation?
        
        if let tabBarController = navController.viewControllers.first as? TabBarController {
            
            if ((tabBarController.viewControllers) != nil) {
                
                for viewController in tabBarController.viewControllers! {

                    if let vc = viewController as? CameraViewControllerPresentation {
                        cameraVC = vc
                        break;
                    }
                }
            }
        }
        
        return cameraVC
    }()
    
    fileprivate func openAuthorization(animated: Bool) {
        
        let authCoordinator: AuthCoordinatorPresentation = AuthCoordinator.init(navigationController: navController)
        authCoordinator.start(animated: animated)
        
        authCoordinator.completion = { [unowned self, unowned authCoordinator] (auththorized) -> Void in
            self.removeChildCoordinator(authCoordinator)
        }
        
        addChildCoordinator(authCoordinator)
    }
}

extension AppCoordinator: AppCoordinatorInterface {
    
    func start() {
        DispatchQueue.main.async {
            self.openAuthorization(animated: false)
        }
    }
    
    func logout() {
        DispatchQueue.main.async {
            self.openAuthorization(animated: true)
        }
    }
}