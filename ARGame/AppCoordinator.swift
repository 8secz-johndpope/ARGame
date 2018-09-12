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
    fileprivate var cameraVC: CameraViewControllerPresentable!
    fileprivate var tabBarController: TabBarController! {
        didSet {
            cameraVC = tabBarController.viewControllers?.first(where: {$0 is CameraViewControllerPresentable}) as? CameraViewControllerPresentable

            tabBarController.didSelect = { [unowned self] (vc) -> Void in
                /// Сообщим контроллеру камеры об его активности.
                /// Контроллер включит/выключит камеру.
                if vc is CameraViewControllerPresentable {
                    self.cameraVC.on()
                } else {
                    self.cameraVC.off()
                }
            }
        }
    }
    fileprivate var locationManager: LocationManager! {
        didSet {
            locationManager.updateLocation = { [unowned self] (location) -> Void in
                /// Сообщим контроллеру камеры о пересечении с меткой.
                /// При пересечении с меткой изменяется изображение.
                let intersect = DataPoints.shared.intersectLocation(location)
                self.cameraVC.setFire(intersect)
                print(location)
            }
        }
    }
    
    init() {
        configureApp()
    }

    /** Создает контент приложения.
        navController - базовый навигационный контроллер.
        Все контроллеры которые нужно запустить над TabBarController, например авторизацию, запускаем в navController.
        В TabBarController, если нужна навигация внутри TabBarItem, TabBarItem запускается со своим навигационным контроллером */
    fileprivate func configureApp() {

        tabBarController = TabBarController()

        navController = UINavigationController.init(rootViewController: tabBarController)
        navController.navigationBar.isHidden = true

        locationManager = LocationManager()
    }
}

extension AppCoordinator: AppCoordinatorInterface {

    public func start() {

//        if Authorization.shared.status == false {
//            DispatchQueue.main.async {
//                if self.canOpenAuth() {
//                    self.openAuth(animated: false)
//                }
//            }
//        }
//
//        configureAuth()
    }
    
    public func logout() {
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
        authCoordinator.completion = { [unowned self, unowned authCoordinator] (user) -> Void in
            self.removeChildCoordinator(authCoordinator)
        }
        authCoordinator.start(animated: animated)

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
        return (childCoordinators.isEmpty || !(childCoordinators.last is AuthCoordinatorPresentation))
    }
}
