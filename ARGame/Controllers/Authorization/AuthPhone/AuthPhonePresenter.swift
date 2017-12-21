//
//  AuthPhonePresenter.swift
//  ARGame
//
//  Created by Aleksandr on 23/11/2017.
//  Copyright © 2017 Aleksandr. All rights reserved.
//

import UIKit

protocol AuthPhonePresentation: class {
    func donePressed()
}

protocol AuthPhoneInteractorOutput: class {
    func phoneValidation(_ value: Bool)
}

class AuthPhonePresenter: AuthPhonePresentation {

    var wareFrame: AuthPhonePresenterOutput?
    weak var view: AuthPhoneViewController?
    var interactor: AuthPhoneInteractorUseCase?
    
    deinit {
       
    }

    func donePressed() {
        let phone = view?.getData()
        interactor?.validationPhone(phone)
    }
}

extension AuthPhonePresenter: AuthPhoneInteractorOutput {
    
    func phoneValidation(_ value: Bool) {
        
        if value == true {
            wareFrame?.presenterCompletion()
        }
    }
}
