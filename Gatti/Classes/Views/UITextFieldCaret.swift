//
//  UITextFieldCaret.swift
//  Gatti
//
//  Created by Dmitriy Zhyzhko
//

import Foundation
import UIKit.UIView

// MARK: - Lifecycle
internal final class UITextFieldCaret: UIView, UITextFieldCaretProtocol {
    
    ///Config
    private var width: CGFloat = 1
    private var height: CGFloat = 22
    private var delay: TimeInterval = 0.1
    internal var speed: TimeInterval = 0.55
    internal var color: UIColor? = .none
    
    ///Caret
    private var lastCaretRect: CGRect?
    private lazy var caretAttrs: [UITextField : (CGRect, UIColor)] = [:]
    
    ///Closures
    internal typealias movedClosure = (() -> Void)?
    
    ///Delegate
    public weak var delegate: (UITextFieldDelegate & UITextFieldCaretDelegate)?
    
    private lazy var isFirstTimeMoving = true //prevent cursor moving for the first time
    private lazy var queueItemCount = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public init() {
        super.init(frame: .zero)
    }
}

// MARK: - Queue
extension UITextFieldCaret {
    
    private enum Queue {
        case add
        case remove
        case reset
    }
    
    private func queue(_ action: Queue) {
        switch action {
            case .add: queueItemCount = queueItemCount + 1
            case .remove: queueItemCount = queueItemCount - 1
            case .reset: queueItemCount = 0
        }
    }
    
    private func moveWithQueue(to textField: UITextField) {
        queue(.add)
        move(to: textField, animate: !isFirstTimeMoving, completion: {
            self.queue(.remove)
            if self.queueItemCount == 0 {
                self.showNativeCaret(true, textField: textField)
                self.showCustomCaret(false)
            }
        })
    }
    
    @objc private func moveWithDelay(_ textField: UITextField) {
        let caretRect = properCaretRect(for: textField, position: textField.endOfDocument)
        let textFieldColor = color ?? (caretAttrs[textField]!.1)
        
        redraw(caretRect: caretRect, color: textFieldColor, duration: speed)
        moveWithQueue(to: textField)
    }
}

// MARK: - Move animation
extension UITextFieldCaret {
    
    func move(to textField: UITextField, animate: Bool = true,
              start: movedClosure = nil, completion: movedClosure = nil) {
        let caretRect = properCaretRect(for: textField, position: textField.endOfDocument)
        UIView.animate(withDuration: animate ? speed : 0, animations: {
            start?()
            self.move(by: CGPoint(x: caretRect.origin.x,
                                  y: caretRect.origin.y))
        }, completion: { finish in completion?() })
    }
    
    @objc private func move(by point: CGPoint) {
        self.frame = CGRect.init(x: point.x, y: point.y,
                                 width: self.frame.width, height: self.frame.height)
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
    
    @available(iOS 10.0, *)
    public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
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
        showNativeCaret(isFirstTimeMoving, textField: textField)
        showCustomCaret(!isFirstTimeMoving)
        if !isFirstTimeMoving {
            moveWithQueue(to: textField)
            perform(#selector(moveWithDelay(_:)), with: textField, afterDelay: delay)
            delegate?.caretWillAttach(to: textField)
        } else {
            redraw(caretRect: textField.caretRect(for: textField.beginningOfDocument),
                   color: color ?? textField.tintColor,
                   duration: speed)
            isFirstTimeMoving = !isFirstTimeMoving
        }
        if let textFieldDidBeginEditing = delegate?.textFieldDidBeginEditing(_:) {
            return textFieldDidBeginEditing(textField)
        }
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let selectedCaretPosition = textField.selectedTextRange?.end {
            showCustomCaret(false)
            
            //get caret rect if user moves the cursor
            let caretRect = properCaretRect(for: textField, position: selectedCaretPosition)
            lastCaretRect = caretRect
            move(by: CGPoint(x: caretRect.origin.x,
                             y: caretRect.origin.y))
        }
        delegate?.caretDidDetach(from: textField)
        if let textFieldShouldEndEditing = delegate?.textFieldShouldEndEditing(_:) {
            return textFieldShouldEndEditing(textField)
        }
        return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if self.queueItemCount >= 1 {
            perform(#selector(moveWithDelay(_:)), with: textField, afterDelay: delay)
        } else {
            redraw(caretRect: textField.caretRect(for: textField.beginningOfDocument),
                   color: color ?? textField.tintColor,
                   duration: speed)
            move(to: textField, animate: false)
        }

        if let textFieldshouldChangeCharactersIn = delegate?.textField {
            return textFieldshouldChangeCharactersIn(textField, range, string)
        }
        return true
    }
    
    @objc private func orientationChanged() {
        for attr in caretAttrs { caretAttrs[attr.key]?.0 = .zero } //clear old carets info
    }
}

// MARK: - Configure
extension UITextFieldCaret {
    
    public func setup(textFields: [UITextField]) {
        //register text fields events
        for textField in textFields {
            textField.delegate = self
            caretAttrs[textField] = (.zero, textField.tintColor)
        }
        
        //add rotation observer
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged),
                                               name: .UIDeviceOrientationDidChange,
                                               object: nil)
        
        //setup cursor and add as root child view
        backgroundColor = color
        isHidden = true
        removeFromSuperview()
        invalidate(0, color: color ?? .clear)
    }

    public func `deinit`() {
        delegate = nil
        caretAttrs.removeAll()
        NotificationCenter.default.removeObserver(self)
        removeFromSuperview()
    }
    
    private func properCaretRect(for textField: UITextField,
                                 position: UITextPosition) -> CGRect {
        //get global caret rect
        var caretGlobalRect: CGRect?
        if let caret = textField.subviews.first?.subviews.first?.subviews.first?.subviews.first {
            caretGlobalRect = caret.convert(caret.bounds, to: superview)
            
        } else if textField.subviews.count > 1,
            let caret = textField.subviews[1].subviews.first?.subviews.first?.subviews.first {
            caretGlobalRect = caret.convert(caret.bounds, to: superview)
        }
        
        //get caret rect within text field
        let caretRect = textField.caretRect(for: position)
        
        //calculate caret coordinates within textfield
        let textFieldRect = textField.convert(textField.bounds, to: superview)
        let textRect = textField.textRect(forBounds: textField.frame)
        let textLeftInset = textRect.origin.x - textFieldRect.origin.x
        let leftViewWidth = textField.leftView?.frame.width ?? 0
        
        var y = textFieldRect.midY - caretRect.height / 2
        var x = leftViewWidth + textLeftInset + textFieldRect.minX + caretRect.minX
        
        if let caretGlobalRect = caretGlobalRect {
            x = caretGlobalRect.origin.x
            y = caretGlobalRect.origin.y
        } else if let tuple = caretAttrs[textField] {
            let caretX = tuple.0.origin.x
            let caretY = tuple.0.origin.y
            x = caretX > 0 ? caretX : x
            y = caretY > 0 ? caretY : y
        } else {
            x = x + caretRect.minX
        }
        
        let properCaretRect = CGRect(x: x, y: y,
                                     width: caretRect.width, height: caretRect.height)
        caretAttrs[textField]?.0 = properCaretRect
        return properCaretRect
    }
    
    private func showNativeCaret(_ show: Bool, textField: UITextField) {
        textField.tintColor = !show ? .clear : color ?? caretAttrs[textField]!.1
    }
    
    private func showCustomCaret(_ show: Bool) { isHidden = !show }
    
    private func invalidate(_ duration: TimeInterval, color: UIColor) {
        UIView.animate(withDuration: duration - delay) {
            self.backgroundColor = color
            self.frame = CGRect.init(x: self.frame.origin.x, y: self.frame.origin.y,
                                     width: self.width, height: self.height)
        }
    }
    
    private func redraw(caretRect: CGRect, color: UIColor, duration: TimeInterval) {
        //redraw caret
        if height != caretRect.height || width != caretRect.width {
            height = caretRect.height
            width = caretRect.width
        }
        invalidate(duration, color: color)
    }
}
