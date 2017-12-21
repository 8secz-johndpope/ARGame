//
//  AuthPinViewController.swift
//  ARGame
//
//  Created by Aleksandr on 21/11/2017.
//  Copyright © 2017 Aleksandr. All rights reserved.
//

import UIKit

class AuthPinViewController: UIViewController {

    var completion: ((_ success: Bool) -> Void)?

    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    deinit {
        print(" ")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "sms code"
        view.backgroundColor = .yellow
     
        codeLabel.text = "328556"
        codeLabel.textAlignment = .center
        
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(donePressed), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc func donePressed () {
        completion?(true)
    }
}
