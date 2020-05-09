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
    
    /// Finds all the desired parent's subviews .
    ///
    /// - Returns: Array with UIViews.
    func allSubViewsOf<T : UIView>(type : T.Type) -> [T] {
        var allSubviews = [T]()
        func getSubview(view: UIView) {
            if let subview = view as? T {
                allSubviews.append(subview)
            }
            guard view.subviews.count > 0 else { return }
            view.subviews.forEach{ getSubview(view: $0) }
        }
        getSubview(view: self)
        return allSubviews
    }
}
