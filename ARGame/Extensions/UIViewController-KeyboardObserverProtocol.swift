//
//  UIViewController-KeyboardObserverProtocol.swift
//  ARGame
//
//  Created by Aleksandr on 28/11/2017.
//  Copyright © 2017 Aleksandr. All rights reserved.
//

import UIKit

@objc protocol KeyboardObserverProtocol {
    @objc optional func addKeyboardObserver()
    @objc optional func removeKeyboardObserver()
    func keyboardWillChangeFrame(notification: NSNotification)
}

extension KeyboardObserverProtocol where Self: UIViewController {
    
    func addKeyboardObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(Self.keyboardWillChangeFrame),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)
    }
    
    func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                                  object: nil)
    }

    func keyboardWillChangeFrame(notification: NSNotification) {}
}
