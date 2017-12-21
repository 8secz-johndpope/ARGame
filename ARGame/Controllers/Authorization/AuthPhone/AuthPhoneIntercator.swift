//
//  AuthPhoneIntercator.swift
//  ARGame
//
//  Created by Aleksandr on 23/11/2017.
//  Copyright © 2017 Aleksandr. All rights reserved.
//

import UIKit

protocol AuthPhoneInteractorUseCase: class {
    func validationPhone(_ phone: String?)
}

class AuthPhoneInteractor: AuthPhoneInteractorUseCase {
    
    weak var output: AuthPhoneInteractorOutput!
    
    deinit {
       
    }
    
    func validationPhone(_ phone: String?) {
        output.phoneValidation(true)
    }
}

