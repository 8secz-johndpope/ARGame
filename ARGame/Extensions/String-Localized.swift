//
//  String-Localized.swift
//  ARGame
//
//  Created by Aleksandr on 20.12.2017.
//  Copyright © 2017 Aleksandr. All rights reserved.
//

import Foundation

extension String {
    
    var lcd: String {
        return NSLocalizedString(self, comment: "")
    }
}
