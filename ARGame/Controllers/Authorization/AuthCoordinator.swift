//
//  AuthCoordinator.swift
//  ARGame
//
//  Created by Aleksandr on 21/11/2017.
//  Copyright © 2017 Aleksandr. All rights reserved.
//

import UIKit

protocol AuthCoordinatorPresentation: class {
    init(navigationController: UINavigationController)
    func start(animated: Bool)
    
    var completion: ((_ authorized: Bool) -> Void)? { get set }
}

class AuthCoordinator: AuthCoordinatorPresentation {

    internal var completion: ((_ authorized: Bool) -> Void)?
    
    fileprivate var appNavController: UINavigationController!
    fileprivate var authNavController: UINavigationController?
    
    convenience required init(navigationController: UINavigationController) {
        self.init()
        self.appNavController = navigationController
    }
    
    deinit {
       
    }
    
    func start(animated: Bool) {
        openPhoneViewController(animated: animated)
    }
    
    fileprivate func openPhoneViewController(animated: Bool) {
        
        let authPhone = AuthPhoneWireFrame() as AuthPhoneWireFramePresentation
        let vc = authPhone.createModule()
        authNavController = UINavigationController.init(rootViewController: vc)
        appNavController.present(authNavController!, animated: animated, completion: nil)
       
        authPhone.moduleCompletion = { [unowned self] () -> Void in
            self.openPinViewController()
        }
    }
    
    fileprivate func openPinViewController () {
        
        /*  TODO i:
         *  Когда будет макет сделать по аналогии с AuthPhoneWireFramePresentation
         */
        
        let vc: AuthPinViewController = AuthPinViewController.loadFromNib()
        authNavController?.pushViewController(vc, animated: true)
        
        vc.completion = { [unowned self] (success) -> Void in
            self.appNavController.dismiss(animated: true, completion: {
                self.completion?(success)
            })
        }
    }
}
