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
        if let caret = allCarets(of: vc.view, onlyFirst: true).first {
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
        attach(to: vc, textFields: allTextFields(of: vc.view), delegate: delegate)
    }
    
    /// Attach flying caret to the UIViewController
    ///
    /// - Parameters:
    ///   - vc: UIViewController
    ///   - textFields: set an available text field for flying caret effect
    /// - delegate: UITextFieldDelegate & UITextFieldCaretDelegate
    public static func attach(to vc: UIViewController, textFields: [UITextField],
                              delegate: (UITextFieldDelegate & UITextFieldCaretDelegate)? = nil) {
        guard allCarets(of: vc.view, onlyFirst: true).count == 0 else { return }
        
        let caret = UITextFieldCaret()
        caret.delegate = delegate
        caret.setup(textFields: textFields)
        vc.view.addSubview(caret)
    }
    
    /// Detach flying caret from the UIViewController
    ///
    /// - Parameter vc: UIViewController
    public static func detach(from vc: UIViewController) {
        for caret in allCarets(of: vc.view) {
            caret.deinit()
        }
    }
    
    /// Find all text fields of a root view
    ///
    /// - Parameter view: Root view
    /// - Returns: array with text fields
    private static func allTextFields(of view: UIView) -> [UITextField] {
        var textFields = [UITextField]()
        for subview in view.subviews {
            textFields += allTextFields(of: subview)
            
            if subview is UITextField {
                textFields.append(subview as! UITextField)
            }
        }
        return textFields
    }
    
    /// Find all caret on the screen
    ///
    /// - Parameter view: Root view
    /// - Returns: array with carets
    private static func allCarets(of view: UIView, onlyFirst: Bool = false) -> [UITextFieldCaret] {
        var carets = [UITextFieldCaret]()
        for subview in view.subviews {
            carets += allCarets(of: subview)
            
            if subview is UITextFieldCaret {
                let caret = subview as! UITextFieldCaret
                if onlyFirst {
                    return [caret]
                }
                carets.append(caret)
            }
        }
        return carets
    }
}
