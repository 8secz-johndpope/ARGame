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
    func phoneVerified(_ verificationID: String)
    func phoneVerifyError(_ error: String)
}

class AuthPhonePresenter: AuthPhonePresentation {

    var wareFrame: AuthPhonePresenterOutput?
    weak var view: AuthPhoneViewController?
    var interactor: AuthPhoneInteractorUseCase?
    
    deinit {
       
    }

    func donePressed() {
        let phone = view?.getData()
        interactor?.verifyPhone(phone)
    }
}

extension AuthPhonePresenter: AuthPhoneInteractorOutput {
    
    func phoneVerified(_ verificationID: String) {
        wareFrame?.presenterCompletion(verificationID)
    }
    
    func phoneVerifyError(_ message: String) {
        view?.showAlert(message)
    }
}
