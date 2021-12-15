//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import UIKit

/// Adds helper functionality to any `UIView` instance through the `adyen` property.
/// :nodoc:
extension AdyenScope where Base: UIView {

    /// Attaches top, bottom, left and right anchors of this view to the corresponding anchors inside the specified view.
    /// - IMPORTANT: Both views should be in the same hierarchy.
    /// - Parameter view: Container view
    /// - Parameter padding: Padding values for each edge. Default is 0 on all edges.
    /// - Parameter edges: Edges on which the views should be anchored. Defaults to all 4 edge anchors.
    @discardableResult
    public func anchor(inside view: UIView, with padding: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        let edges: Set<AnchorEdge> = [.top(padding.top),
                                      .left(padding.left),
                                      .bottom(padding.bottom),
                                      .right(padding.right)]
        return anchor(inside: .view(view), onEdges: edges)
    }

    /// Attaches top, bottom, left and right anchors of this view to the corresponding anchors inside the specified layout guide.
    /// - IMPORTANT: Both views should be in the same hierarchy.
    /// - Parameter margins: The layout guide to constraint to.
    /// - Parameter padding: Padding values for each edge. Default is 0 on all edges.
    /// - Parameter edges: Edges on which the views should be anchored. Defaults to all 4 edge anchors.
    @discardableResult
    public func anchor(inside margins: UILayoutGuide, with padding: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        let edges: Set<AnchorEdge> = [.top(padding.top),
                                      .left(padding.left),
                                      .bottom(padding.bottom),
                                      .right(padding.right)]
        return anchor(inside: .layoutGuide(margins), onEdges: edges)
    }
    
    /// Attaches the given edges of this view to coresponding anchors inside the specified layout guide.
    /// - Parameters:
    ///   - anchorSource: The anchor source to contain this view.
    ///   - edges: Edges with inset values on which the views should be anchored. Defaults to all 4 edges with 0 inset each.
    @discardableResult
    public func anchor(inside anchorSource: LayoutAnchorSource,
                       onEdges edges: Set<AnchorEdge> = [.top(0),
                                                         .left(0),
                                                         .bottom(0),
                                                         .right(0)]) -> [NSLayoutConstraint] {
        base.translatesAutoresizingMaskIntoConstraints = false
        
        let topAnchor: NSLayoutYAxisAnchor
        let leadingAnchor: NSLayoutXAxisAnchor
        let bottomAnchor: NSLayoutYAxisAnchor
        let trailingAnchor: NSLayoutXAxisAnchor
        
        switch anchorSource {
        case let .view(view):
            topAnchor = view.topAnchor
            leadingAnchor = view.leadingAnchor
            bottomAnchor = view.bottomAnchor
            trailingAnchor = view.trailingAnchor
        case let .layoutGuide(uILayoutGuide):
            topAnchor = uILayoutGuide.topAnchor
            leadingAnchor = uILayoutGuide.leadingAnchor
            bottomAnchor = uILayoutGuide.bottomAnchor
            trailingAnchor = uILayoutGuide.trailingAnchor
        }
        
        var constraints: [NSLayoutConstraint] = []
        for edge in edges {
            switch edge {
            case let .top(padding):
                constraints.append(base.topAnchor.constraint(equalTo: topAnchor, constant: padding))
            case let .left(padding):
                constraints.append(base.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding))
            case let .bottom(padding):
                constraints.append(base.bottomAnchor.constraint(equalTo: bottomAnchor, constant: padding))
            case let .right(padding):
                constraints.append(base.trailingAnchor.constraint(equalTo: trailingAnchor, constant: padding))
            }
        }
        NSLayoutConstraint.activate(constraints)
        return constraints
    }

    /// Wrap the view inside a container view with certain edge insets
    ///
    /// - Parameter insets: The insets inside the container view.
    public func wrapped(with insets: UIEdgeInsets = .zero) -> UIView {
        let containerView = UIView()
        containerView.addSubview(base)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        base.translatesAutoresizingMaskIntoConstraints = false
        anchor(inside: containerView, with: insets)
        return containerView
    }
}

/// Edges combined with their inset values.
/// :nodoc:
public enum AnchorEdge: Hashable {
    
    /// Top edge with its inset value.
    case top(CGFloat)
    
    /// Left edge with its inset value.
    case left(CGFloat)
    
    /// Bottom edge with its inset value.
    case bottom(CGFloat)
    
    /// Right edge with its inset value.
    case right(CGFloat)
}

/// An enum to specify an anchor source
/// :nodoc:
public enum LayoutAnchorSource {
    
    /// Regular `UIView` object
    case view(UIView)
    
    /// Specified layout guide such as Layout Margins or Safe Area.
    case layoutGuide(UILayoutGuide)
}
