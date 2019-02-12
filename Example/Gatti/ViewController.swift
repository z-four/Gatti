//
//  ViewController.swift
//  Gatti
//
//  Created by z-four on
//  Copyright (c) 2019 z-four. All rights reserved.
//

import UIKit
import Gatti

// MARK: - Lifecycle
final class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Gatti.attach(to: self, delegate: self)
    }
    
    deinit {
        Gatti.detach(from: self)
    }
}

// MARK: - UITextFieldDelegate, UITextFieldCaretDelegate
extension ViewController: UITextFieldDelegate, UITextFieldCaretDelegate {
    
    func caretWillAttach(to textField: UITextField) {
        print("Will attach to = \(textField)")
    }
    
    func caretDidDetach(from textField: UITextField) {
        print("Did detach from = \(textField)")
    }
}
