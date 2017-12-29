//
//  FirebasePhoneAuth.swift
//  ARGame
//
//  Created by Aleksandr on 28.12.2017.
//  Copyright © 2017 Aleksandr. All rights reserved.
//

import UIKit
import Firebase

class Authorization {
    
    static let shared = Authorization()
    private init() {}
    
    /// Статус авторизации
    var status: Bool {
        get {
            let user = Auth.auth().currentUser
            let authorized = ((user == nil) ? false : true)
            return authorized;
        }
    }
    
    /// Подписка на изменение статуса авторизации
    func addStateDidChangeListener(change: ((_ status: Bool) -> Void)?) {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            let status = ((user == nil) ? false : true)
            change?(status)
        }
    }
    
    /// Отправляет номер телефона, на этот номер приходит sms код
    func verifyPhoneNumber(_ phoneNumber: String, completion: ((_ verificationID: String?, _ error: Error?) -> Void)?) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            completion?(verificationID, error)
        }
    }
    
    /// Авторизация
    func verification(_ verificationID: String, _ verificationCode: String) {
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                // ...
                return
            }
            // User is signed in
            // ...
        }
    }
}
