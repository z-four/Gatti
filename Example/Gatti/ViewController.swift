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
    @IBOutlet weak var button: UIButton!
    
    @IBAction func some(_ sender: Any) {
        let vc = UIViewController()
        navigationController?.setViewControllers([vc], animated: true)
    }
    
    @IBOutlet weak var textFF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Gatti.attach(to: self, delegate: self)
        var imageView = UIImageView();
        var image = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        image.backgroundColor = UIColor.blue
        var image1 = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
              image1.backgroundColor = UIColor.blue
        textFF.leftView = image;
        textFF.leftViewMode = .always
          textFF.rightViewMode = .always
        textFF.rightView = image1
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
