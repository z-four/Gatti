//
//  UITextFieldCaret+Utils.swift
//  Gatti
//
//  Created by Dmitriy Zhyzhko
//

import Foundation

public protocol UITextFieldCaretDelegate {
    func caretWillAttach(to textField: UITextField)
    func caretDidDetach(from textField: UITextField)
}

protocol UITextFieldCaretProtocol {
    var color: UIColor? { get }
    var speed: TimeInterval { get }
}
