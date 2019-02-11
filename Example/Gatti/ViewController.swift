//
//  ViewController.swift
//  Gatti
//
//  Created by z-four on
//  Copyright (c) 2019 z-four. All rights reserved.
//

import UIKit
import Gatti

final class ViewController: UIViewController {

    @IBOutlet weak var firstTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Gatti.attach(to: self, delegate: self)
    }
}

extension ViewController: UITextFieldDelegate, UITextFieldCaretDelegate {
    
    func caretWillAttach(to textField: UITextField) {
        print("will attach")
    }
    
    func caretDidDetach(from textField: UITextField) {
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("text = \(string)")
        return true
    }
}

