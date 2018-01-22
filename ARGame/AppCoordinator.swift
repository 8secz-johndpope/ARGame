//
//  AppCoordinator.swift
//  ARGame
//
//  Created by Aleksandr on 21/11/2017.
//  Copyright © 2017 Aleksandr. All rights reserved.
//

import UIKit

protocol AppCoordinatorInterface: class {
    
    /// Базовый навигационный контроллер
    var navController: UINavigationController! { get set }

    /// Запускает жизненный цикл приложения
    func start()
    /// Запускает авторизацию
    func logout()
}

class AppCoordinator: Coordinator {
    
    var navController: UINavigationController!
    
    internal var childCoordinators: [AnyObject] = []
    fileprivate var tabBarController: TabBarController!
    fileprivate var locationManager: LocationManager?
    
    init() {
        configureAppUIContent()
    }
    
    /** Создает контент приложения.
        navController - базовый навигационный контроллер.
        Все контроллеры которые нужно запустить над TabBarController, например авторизацию, запускаем в navController.
        В TabBarController, если нужна навигация внутри TabBarItem, TabBarItem запускается со своим навигационным контроллером */
    fileprivate func configureAppUIContent() {
        
        configureTabBarController()
        
        navController = UINavigationController.init(rootViewController: tabBarController)
        navController.navigationBar.isHidden = true
    }
    
    fileprivate func configureTabBarController() {
        
        tabBarController = TabBarController()
        tabBarController.didSelect = { [unowned self] (vc) -> Void in
            /// Сообщим контроллеру камеры об его активности.
            /// Контроллер включит/выключит камеру.
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
            /// Сообщим контроллеру камеры о пересечении с меткой.
            /// При пересечении с меткой изменяется изображение.
            let intersect = DataPoints.shared.intersectLocation(location)
            self.cameraVC?.setFire(intersect)
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
}

extension AppCoordinator: AppCoordinatorInterface {

    func start() {
        
        if Authorization.shared.status == false {
            DispatchQueue.main.async {
                if self.canOpenAuth() {
                    self.openAuth(animated: false)
                }
            }
        }
        
        self.configureAuth()
        self.configureLocationManager()
    }
    
    func logout() {
        DispatchQueue.main.async {
            if self.canOpenAuth() {
                self.openAuth(animated: true)
            }
        }
    }
}

extension AppCoordinator {
    
    /// Запускает кейс авторизации
    fileprivate func openAuth(animated: Bool) {
        let authCoordinator: AuthCoordinatorPresentation = AuthCoordinator.init(navigationController: navController)
        authCoordinator.start(animated: animated)
        
        authCoordinator.completion = { [unowned self, unowned authCoordinator] (user) -> Void in
            self.removeChildCoordinator(authCoordinator)
        }
        
        addChildCoordinator(authCoordinator)
    }
    
    fileprivate func configureAuth() {
        /// подпишемся на изменение статуса авторизации
        Authorization.shared.addStateDidChangeListener { [unowned self] (auth) in
            if auth == false {
                self.logout()
            }
        }
    }
    
    /// Проверка на возможность запуска авторизации
    fileprivate func canOpenAuth() -> Bool {
        
        if childCoordinators.last is AuthCoordinatorPresentation {
            /// авторизация уже вызвана
            return false
        }

        return true
    }
}
