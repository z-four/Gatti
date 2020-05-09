//
//  UITextFieldCaret.swift
//  Gatti
//
//  Created by Dmitriy Zhyzhko
//

import Foundation
import UIKit.UIView

public protocol UITextFieldCaretDelegate {
    func caretWillAttach(to textField: UITextField)
    func caretDidDetach(from textField: UITextField)
}

protocol UITextFieldCaretProtocol {
    var color: UIColor? { get }
    var speed: TimeInterval { get }
}

// MARK: - Lifecycle
internal final class UITextFieldCaret: UIView, UITextFieldCaretProtocol {
      
    /// Delegate
    public weak var delegate: (UITextFieldDelegate & UITextFieldCaretDelegate)?
    
    /// Movement closure
    internal typealias movedClosure = (() -> Void)?
    
    /// Config
    internal var speed: TimeInterval = Constants.Anim.speed
    internal var color: UIColor? = .none
    private var width: CGFloat = Constants.Size.caretWidth
    private var height: CGFloat = Constants.Size.caretHeight
    private var delay: TimeInterval = Constants.Anim.delay
    
    /// Last rect and attrs
    private var lastCaretRect: CGRect?
    private lazy var caretAttrs: [UITextField : (rect: CGRect, color: UIColor)] = [:]
    
    private lazy var isFirstTimeMoving = true // Prevent cursor moving for the first time
    private lazy var queueItemCount = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public init() {
        super.init(frame: .zero)
    }
}

// MARK: - Movement & queue
extension UITextFieldCaret {
    
    private enum Queue {
        case add
        case remove
        case reset
    }
    
    
    /// Makes operation to the queue.
    /// - Parameter action: Action type to be executed.
    private func queue(_ action: Queue) {
        switch action {
            case .add: queueItemCount = queueItemCount + 1
            case .remove: queueItemCount = queueItemCount - 1
            case .reset: queueItemCount = 0
        }
    }
    
    
    /// Moves caret and adding operation to the queue.
    /// - Parameter textField: Move to UITextField.
    private func moveWithQueue(to textField: UITextField) {
        // Add operation to the queue
        queue(.add)
         // Move caret to the text field
        move(to: textField,
             animate: !isFirstTimeMoving,
             completion: {
            
            // Remove operation from the queue
            self.queue(.remove)
            if self.queueItemCount == 0 {
                // Hide custom caret and show native one
                self.showNativeCaret(true, textField: textField)
                self.showCustomCaret(false)
            }
        })
    }
    
    /// Moves caret with delay.
    /// - Parameter textField: Move to UITextField.
    @objc private func moveWithDelay(_ textField: UITextField) {
        let caretRect = properCaretRect(for: textField, position: textField.endOfDocument)
        // Get text field color if default caret color is not specified
        let textFieldColor = color ?? (caretAttrs[textField]!.color)
        
        // Redraws caret color and size if needed
        redraw(caretRect: caretRect, color: textFieldColor, duration: speed)
        // Moves and adds caret to the queue
        moveWithQueue(to: textField)
    }
    
    /// Moves caret to the specific UITextField with animation.
    /// - Parameters:
    ///   - textField: Move to UITextField.
    ///   - animate: Boolean the represents animate movement or not.
    ///   - start: Start closure.
    ///   - completion: Completion closure.
    func move(to textField: UITextField,
              animate: Bool = true,
              start: movedClosure = nil,
              completion: movedClosure = nil) {
        // Get caret rect
        let caretRect = properCaretRect(for: textField, position: textField.endOfDocument)
        // Animates caret movement
        UIView.animate(withDuration: animate ? speed : 0, animations: {
            // Notifies animation has been started
            start?()
            // Moves caret to specific point
            self.move(by: CGPoint(x: caretRect.origin.x, y: caretRect.origin.y))
        }, completion: { finish in completion?() })
    }
       
    
    /// Updates caret frame
    /// - Parameter point: The new coordinates of the caret view.
    @objc private func move(by point: CGPoint) {
        frame = CGRect.init(x: point.x, y: point.y,
                            width: frame.width, height: frame.height)
    }
}

// MARK: - Delegate
extension UITextFieldCaret: UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let textFieldShouldReturn = delegate?.textFieldShouldReturn(_:) {
            return textFieldShouldReturn(textField)
        }
        return true
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if let textFieldShouldClear = delegate?.textFieldShouldClear(_:) {
            return textFieldShouldClear(textField)
        }
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        delegate?.textFieldDidEndEditing?(textField, reason: reason)
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.textFieldDidEndEditing?(textField)
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let textFieldShouldBeginEditing = delegate?.textFieldShouldBeginEditing(_:) {
            return textFieldShouldBeginEditing(textField)
        }
        return true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        // Show native caret if it is first time when caret is became active
        showNativeCaret(isFirstTimeMoving, textField: textField)
        // Show native caret if it is not the first time when caret is active
        showCustomCaret(!isFirstTimeMoving)
        // If it is not the first time when caret is active then make caret movement
        if !isFirstTimeMoving {
            // Move caret with queue
            moveWithQueue(to: textField)
            // Permorms some delay to prevent animation issues
            perform(#selector(moveWithDelay(_:)), with: textField, afterDelay: delay)
            // Notifies that caret has been attached
            delegate?.caretWillAttach(to: textField)
        } else {
            // Redraws caret size and color
            redraw(caretRect: textField.caretRect(for: textField.beginningOfDocument),
                   color: color ?? textField.tintColor,
                   duration: speed)
            // Update flag
            isFirstTimeMoving = !isFirstTimeMoving
        }
        if let textFieldDidBeginEditing = delegate?.textFieldDidBeginEditing(_:) {
            return textFieldDidBeginEditing(textField)
        }
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let selectedCaretPosition = textField.selectedTextRange?.end {
            // Hide custom caret, so we don't need it because native one should be presented
            showCustomCaret(false)
            
            // Get caret rect if user moves the cursor
            let caretRect = properCaretRect(for: textField, position: selectedCaretPosition)
            lastCaretRect = caretRect
            // Update caret position
            move(by: CGPoint(x: caretRect.origin.x,
                             y: caretRect.origin.y))
        }
        // Notifies caret has been detached
        delegate?.caretDidDetach(from: textField)
        if let textFieldShouldEndEditing = delegate?.textFieldShouldEndEditing(_:) {
            return textFieldShouldEndEditing(textField)
        }
        return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Helps to move caret while user typung text
        if self.queueItemCount >= 1 {
            // Moves caret with delay
            perform(#selector(moveWithDelay(_:)), with: textField, afterDelay: delay)
        } else {
            // Redraws caret size and color to fit text fild native caret config
            redraw(caretRect: textField.caretRect(for: textField.beginningOfDocument),
                   color: color ?? textField.tintColor,
                   duration: speed)
            // Moves caret to text field wihout animation
            // since there are no operations in the queue
            move(to: textField, animate: false)
        }

        if let textFieldshouldChangeCharactersIn = delegate?.textField {
            return textFieldshouldChangeCharactersIn(textField, range, string)
        }
        return true
    }
    
    
    /// Fires when orientation has been changed.
    @objc private func orientationChanged() {
        // Clear last caret attrs
        for attr in caretAttrs {
            caretAttrs[attr.key]?.rect = .zero
        }
    }
}

// MARK: - Setup & deinit
extension UITextFieldCaret {
    
    
    /// Makes a first caret view setup.
    /// - Parameter textFields: Array of UITextFields.
    public func setup(textFields: [UITextField]) {
        for textField in textFields {
            // Registers for UITextField events
            textField.delegate = self
            // Sets default caret attrs
            caretAttrs[textField] = (.zero, textField.tintColor)
        }
        
        // Add rotation observer
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
        
        // Sets up caret
        backgroundColor = color
        isHidden = true
        removeFromSuperview()
        // Sets default caret color and position
        invalidate(0, color: color ?? .clear)
    }
    
    /// Clear everything that can leads to memory leak
    public func `deinit`() {
        delegate = nil
        caretAttrs.removeAll()
        NotificationCenter.default.removeObserver(self)
        removeFromSuperview()
    }
}

// MARK: - Configure
extension UITextFieldCaret {
    
    /// Calculate and returns proper caret rect.
    /// - Parameters:
    ///   - textField: UITextField to get caret rect for.
    ///   - position: UITextField text position.
    /// - Returns: Relevant carect rect.
    private func properCaretRect(for textField: UITextField,
                                 position: UITextPosition) -> CGRect {
        // Get caret view
        let caretView = textField.getCaretView()
        // Get global caret rect
        let caretGlobalRect = caretView?.convert(caretView?.bounds ?? .zero, to: superview)
        
        // Get caret rect within text field
        let caretRect = textField.caretRect(for: position)
        
        // Calculate caret coordinates within textfield
        let textFieldRect = textField.convert(textField.bounds, to: superview)
        let textRect = textField.textRect(forBounds: textField.frame)
        let textLeftInset = textRect.origin.x - textFieldRect.origin.x
        let leftViewWidth = textField.leftView?.frame.width ?? 0
        
        // Determinate possible caret coords
        var y = textFieldRect.midY - caretRect.height / 2
        var x = leftViewWidth + textLeftInset + textFieldRect.minX + caretRect.minX
        
        // If global rect was not found then use already saved attrs
        // or default text field origin x
        if let caretGlobalRect = caretGlobalRect {
            x = caretGlobalRect.origin.x
            y = caretGlobalRect.origin.y
        } else if let tuple = caretAttrs[textField] {
            let caretX = tuple.rect.origin.x
            let caretY = tuple.rect.origin.y
            x = caretX > 0 ? caretX : x
            y = caretY > 0 ? caretY : y
        } else {
            x = x + caretRect.minX
        }
        
        // Init final caret rect
        let properCaretRect = CGRect(x: x, y: y,
                                     width: caretRect.width, height: caretRect.height)
        // Save caret rect to the dict
        caretAttrs[textField]?.rect = properCaretRect
        // Returns final caret rect
        return properCaretRect
    }
    
    
    /// Interacts with native caret visibility.
    /// - Parameters:
    ///   - show: Boolean that represents should be caret hidden or not.
    ///   - textField: UITextField applies for.
    private func showNativeCaret(_ show: Bool, textField: UITextField) {
        textField.tintColor = !show ? .clear : color ?? caretAttrs[textField]!.color
    }
    
    
    /// Interacts with custom caret visibility.
    /// - Parameter show: Boolean that represents should be caret hidden or not.
    private func showCustomCaret(_ show: Bool) {
        isHidden = !show
    }
    
    
    /// Invalidates caret color and frame.
    /// - Parameters:
    ///   - duration: Animation duration.
    ///   - color: Caret color.
    private func invalidate(_ duration: TimeInterval, color: UIColor) {
        UIView.animate(withDuration: duration - delay) {
            self.backgroundColor = color
            self.frame = CGRect.init(x: self.frame.origin.x, y: self.frame.origin.y,
                                     width: self.width, height: self.height)
        }
    }
    
    /// Redraws caret.
    /// - Parameters:
    ///   - caretRect: Desired caret rect.
    ///   - color: Caret color.
    ///   - duration: Animation duration.
    private func redraw(caretRect: CGRect, color: UIColor, duration: TimeInterval) {
        // Find correct caret size
        if height != caretRect.height || width != caretRect.width {
            height = caretRect.height
            width = caretRect.width
        }
        // Invalidate caret
        invalidate(duration, color: color)
    }
}
