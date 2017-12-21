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

class AppCoordinator: NSObject, Coordinator {
    
    var navController: UINavigationController!
    internal var childCoordinators: [AnyObject] = []
    
    override init() {
        super.init()
        configureAppContent()
    }
    
    fileprivate func configureAppContent() {
        
        let tabBarController = TabBarController()
        tabBarController.delegate = self
        
        navController = UINavigationController.init(rootViewController: tabBarController)
        navController.navigationBar.isHidden = true
    }
    
    lazy var cameraVC: CameraViewControllerPresentation? = {
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
        
        authCoordinator.completion = { [weak self, weak authCoordinator] (auththorized) -> Void in
            self?.removeChildCoordinator(authCoordinator!)
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

extension AppCoordinator: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        /*
         *  Сообщим контроллеру камеры об его активности
         */
        
        if viewController is CameraViewControllerPresentation {
            cameraVC?.open()
        } else {
            cameraVC?.close()
        }
    }
}
