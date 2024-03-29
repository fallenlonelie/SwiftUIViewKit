//
//  SUVK+GroupView.swift
//  SwiftUIViewKit
//
//  Created by LONELiE on 2023/02/27.
//

import UIKit

open class UIGroupView: UIStackView {
    private let emptyView = UIView(frame: .zero)
    
    private var isPassthroughHit = false
    
    public convenience init(_ views: UIView...) {
        self.init(views: views)
    }
    
    public convenience init(views: [UIView]) {
        self.init(frame: .zero)
        
        self.addArrangedSubview(self.emptyView)
        
        if !views.isEmpty {
            self.subviews.forEach { $0.removeFromSuperview() }
            views.forEach { self.addArrangedSubview($0) }
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if let superView = self.superview as? UIStackView {
            self.axis         = superView.axis
            self.spacing      = superView.spacing
            self.alignment    = superView.alignment
            self.distribution = superView.distribution
        }
        
        if let superview = self.superview as? UIVStackView {
            self.isPassthroughHit = superview.isPassthroughHit
        }
        if let superview = self.superview as? UIHStackView {
            self.isPassthroughHit = superview.isPassthroughHit
        }
        
        self.emptyView.frame.size = .zero
        self.emptyView.snp.remakeConstraints {
            switch self.axis {
            case .vertical:   $0.width.equalTo(0.0)
            case .horizontal: $0.height.equalTo(0.0)
            @unknown default: break
            }
        }
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else { return nil }
        
        if view == self, self.isPassthroughHit, let color = self.color(of: point), color.cgColor.alpha <= 0.0 {
            return nil
        }
        
        return view
    }
}
