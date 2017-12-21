//
//  MapWireFrame.swift
//  ARGame
//
//  Created by Aleksandr on 19.12.2017.
//  Copyright © 2017 Aleksandr. All rights reserved.
//

import UIKit

protocol MapWireFramePresentation: class {
    func createModule() -> UIViewController
}

protocol MapPresenterOutput: class {

}

class MapWireFrame: MapWireFramePresentation {

    deinit {
        
    }
    
    func createModule() -> UIViewController {
        
        let viewController: MapViewController = MapViewController.loadFromNib()
        let presenter = MapPresenter()
        let interactor = MapIntercator()
        
        presenter.view = viewController
        presenter.interactor = interactor
        presenter.wareFrame = self
        
        viewController.presenter = presenter
        
        interactor.output = presenter
        
        return viewController
    }
}

extension MapWireFrame: MapPresenterOutput {

}
