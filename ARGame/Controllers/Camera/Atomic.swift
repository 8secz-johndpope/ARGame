//
//  Fire.swift
//  ARGame
//
//  Created by Aleksandr on 25.12.2017.
//  Copyright © 2017 Aleksandr. All rights reserved.
//

import UIKit

class Atomic<T> {

    fileprivate var _val: T
    fileprivate var val_mutex = pthread_mutex_t()
    
    init (value: T) {
        pthread_mutex_init(&val_mutex, nil)
        _val = value
    }
    
    var value: T {
        get {
            pthread_mutex_lock(&val_mutex)
            let result = _val
            defer {
                pthread_mutex_unlock(&val_mutex)
            }
            return result
        }
        
        set (newValue) {
            pthread_mutex_lock(&val_mutex)
            _val = newValue
            pthread_mutex_unlock(&val_mutex)
        }
    }
}
