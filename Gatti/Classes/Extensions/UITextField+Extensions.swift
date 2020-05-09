//
//  UITextField+Extensions.swift
//  Gatti
//
//  Created by Dmitriy Zhyzhko.
//

import Foundation
import UIKit

extension UITextField {
    
    /// Finds parent of the caret and if he is exist gets caret view as subview.
    ///
    /// - Returns: Caret view or nil.
    func getCaretView() -> UIView? {
        // Finds caret parent and if exist get caret view as subview
        return subviewsRecursive().first(where: {
            $0.classForCoder.description() == "UITextSelectionView"
        })?.subviews.first
    }
}
