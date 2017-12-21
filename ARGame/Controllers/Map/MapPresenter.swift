//
//  MapPresenter.swift
//  ARGame
//
//  Created by Aleksandr on 19.12.2017.
//  Copyright © 2017 Aleksandr. All rights reserved.
//

import UIKit

protocol MapPresentation: class {
    func refreshData()
}

protocol MapInteractorOutput: class {
    func updateData(_ data: Array<AnyObject>)
}

class MapPresenter: MapPresentation {

    var wareFrame: MapPresenterOutput?
    weak var view: MapViewController?
    var interactor: MapInteractorUseCase?
    
    func refreshData() {
        interactor?.refreshData()
    }
}

extension MapPresenter: MapInteractorOutput {
    
    func updateData(_ data: Array<AnyObject>) {
        view?.updateData(data)
    }
}
