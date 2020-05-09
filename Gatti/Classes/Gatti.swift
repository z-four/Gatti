//
//  Gatti
//  Created by Dmitriy Zhyzhko.
//

import Foundation

public final class Gatti {
    
    private init() {}
    
    /// Updates flying caret config.
    ///
    /// - Parameters:
    ///   - vc: Current UIViewController.
    ///   - speed: Animation speed.
    ///   - color: Caret color.
    public static func update(for vc: UIViewController, speed: TimeInterval? = nil, color: UIColor? = .none) {
        if let caret = vc.view.allSubViewsOf(type: UITextFieldCaret.self).first {
            caret.color = color
            if let speed = speed {
                caret.speed = speed
            }
        }
    }
    
    /// Attachs flying caret to the UIViewController.
    ///
    /// - Parameters:
    ///   - vc: Current UIViewController.
    ///   - delegate: UITextFieldDelegate & UITextFieldCaretDelegate.
    public static func attach(to vc: UIViewController,
                              delegate: (UITextFieldDelegate & UITextFieldCaretDelegate)? = nil) {
        attach(to: vc, textFields: vc.view.allSubViewsOf(type: UITextField.self), delegate: delegate)
    }
    
    /// Attachs flying caret to the UIViewController.
    ///
    /// - Parameters:
    ///   - vc: Current UIViewController.
    ///   - textFields: Array of UITextFields that should have flying caret effect.
    ///   - delegate: UITextFieldDelegate & UITextFieldCaretDelegate.
    public static func attach(to vc: UIViewController, textFields: [UITextField],
                              delegate: (UITextFieldDelegate & UITextFieldCaretDelegate)? = nil) {
        guard vc.view.allSubViewsOf(type: UITextFieldCaret.self).count == 0 else { return }
        
        let caret = UITextFieldCaret()
        caret.delegate = delegate
        caret.setup(textFields: textFields)
        vc.view.addSubview(caret)
    }
    
    /// Detachs flying caret from the UIViewController.
    ///
    /// - Parameter vc: Current UIViewController.
    public static func detach(from vc: UIViewController) {
        vc.view.allSubViewsOf(type: UITextFieldCaret.self).forEach {
            $0.deinit()
        }
    }
}
