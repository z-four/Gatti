//
//  UIView+Extensions.swift
//  Gatti
//
//  Created by Dmitriy Zhyzhko
//

import Foundation

extension UIView {

    /// Recursively finds all the subviews inside the view.
    ///
    /// - Returns: Array of subviews.
    func subviewsRecursive() -> [UIView] {
        return subviews + subviews.flatMap { $0.subviewsRecursive() }
    }
}
