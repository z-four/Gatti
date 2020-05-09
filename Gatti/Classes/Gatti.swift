//
//  Gatti
//  Created by z4.
//

import Foundation

public final class Gatti {
    
    private init() {}
    
    /// Update flying caret params
    ///
    /// - Parameters:
    ///   - vc: UIViewController
    ///   - speed: animation duration
    ///   - color: caret color
    public static func update(for vc: UIViewController, speed: TimeInterval, color: UIColor? = nil) {
        if let caret = vc.view.allSubViewsOf(type: UITextFieldCaret.self).first {
            print("FIND caret")
            caret.color = color
            caret.speed = speed
        }
    }
    
    /// Attach flying caret to the UIViewController
    ///
    /// - Parameters:
    /// - vc: UIViewController
    /// - delegate: UITextFieldDelegate & UITextFieldCaretDelegate
    public static func attach(to vc: UIViewController,
                              delegate: (UITextFieldDelegate & UITextFieldCaretDelegate)? = nil) {
        attach(to: vc, textFields: vc.view.allSubViewsOf(type: UITextField.self), delegate: delegate)
    }
    
    /// Attach flying caret to the UIViewController
    ///
    /// - Parameters:
    ///   - vc: UIViewController
    ///   - textFields: set an available text field for flying caret effect
    /// - delegate: UITextFieldDelegate & UITextFieldCaretDelegate
    public static func attach(to vc: UIViewController, textFields: [UITextField],
                              delegate: (UITextFieldDelegate & UITextFieldCaretDelegate)? = nil) {
        guard vc.view.allSubViewsOf(type: UITextFieldCaret.self).count == 0 else { return }
        
        let caret = UITextFieldCaret()
        caret.delegate = delegate
        caret.setup(textFields: textFields)
        vc.view.addSubview(caret)
    }
    
    /// Detach flying caret from the UIViewController
    ///
    /// - Parameter vc: UIViewController
    public static func detach(from vc: UIViewController) {
        for caret in vc.view.allSubViewsOf(type: UITextFieldCaret.self) {
            caret.deinit()
        }
    }
}
