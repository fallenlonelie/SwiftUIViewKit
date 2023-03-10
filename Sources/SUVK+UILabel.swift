//
//  SUVK+UILabel.swift
//  SwiftUIViewKit
//
//  Created by LONELiE on 2023/02/09.
//

import UIKit

extension UILabel {
    private static var lineHeight: [UILabel: CGFloat] = [:]
    
    public var lineHeight: CGFloat? {
        get {
            if let lineHeight = Self.lineHeight[self] {
                return lineHeight
            } else {
                let style = self.getStyle()
                if style.minimumLineHeight > 0.0, style.maximumLineHeight > 0.0,
                   style.minimumLineHeight == style.maximumLineHeight {
                    Self.lineHeight[self] = style.maximumLineHeight
                    return style.maximumLineHeight
                }
            }
            return nil
        }
        set {
            Self.lineHeight[self] = newValue
            if let newValue = newValue {
                _ = self.lineHeight(newValue)
            } else {
                Self.lineHeight.removeValue(forKey: self)
            }
        }
    }
    
    public convenience init(_ text: String?) {
        self.init(frame: .zero)
        self.text = text
    }
    
    public convenience init(attributed text: NSAttributedString) {
        self.init(frame: .zero)
        self.attributedText = text
    }
    
    public convenience init(image: UIImage?, padding: UIEdgeInsets = .zero) {
        self.init(frame: .zero)
        if let image = image {
            let attachment = NSTextAttachment()
            attachment.image  = image
            attachment.bounds = CGRect(x:      -padding.left + padding.right,
                                       y:      -padding.top  + padding.bottom,
                                       width:  image.size.width  - padding.right,
                                       height: image.size.height - padding.bottom)
            self.attributedText = NSAttributedString(attachment: attachment)
        }
    }
    
    public convenience init(image named: String, padding: UIEdgeInsets = .zero) {
        self.init(image: UIImage(named: named), padding: padding)
    }
    
    public convenience init(_ group: UILabel...) {
        self.init(group: group)
    }
    public convenience init(group: [UILabel]) {
        self.init(frame: .zero)
        
        let attributedText = NSMutableAttributedString(string: "")
        group.forEach {
            if let text = $0.attributedText, !$0.isHidden {
                attributedText.append(text)
            } else if let text = $0.text, !$0.isHidden {
                attributedText.append(
                    NSAttributedString(string: text,
                                       attributes: [:])
                )
            }
        }
        self.attributedText = attributedText
    }
    
    @discardableResult
    public func underLine(_ flag: Bool = true) -> Self {
        let attributedText: NSMutableAttributedString = {
            if let value = self.attributedText { return NSMutableAttributedString(attributedString: value) }
            return NSMutableAttributedString(string: self.text ?? "")
        }()
        
        if flag {
            attributedText.addAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue],
                                         range: .init(location: 0, length: attributedText.length))
        } else {
            attributedText.addAttributes([.underlineStyle: /*NSUnderlineStyleNone=*/0x0],
                                         range: .init(location: 0, length: attributedText.length))
        }
        
        self.attributedText = attributedText
        
        return self
    }
    
    private func getAttriburedText() -> NSMutableAttributedString {
        if let value = self.attributedText {
            return NSMutableAttributedString(attributedString: value)
        } else {
            return NSMutableAttributedString(string: self.text ?? "")
        }
    }
    
    private func getStyle() -> NSMutableParagraphStyle {
        let attributedText = self.getAttriburedText()
        
        var style: NSMutableParagraphStyle?
        attributedText
            .enumerateAttributes(in: NSRange(location: 0, length: attributedText.length),
                                 using: {value, _, _ in
                value.forEach {
                    guard $0.key == .paragraphStyle else { return }
                    if let value = $0.value as? NSMutableParagraphStyle {
                        style = value
                    }
                }
            })
        
        return style ?? NSMutableParagraphStyle()
    }
    
    @discardableResult
    public func lineHeight(_ value: CGFloat) -> Self {
        guard let font = self.font else { return self }
        
        let attributedText = self.getAttriburedText()
        let style = self.getStyle()
        
        style.alignment         = self.textAlignment
        style.maximumLineHeight = value
        style.minimumLineHeight = value
        style.lineBreakMode     = self.lineBreakMode
        
        let attributes: [NSAttributedString.Key: Any] = [.paragraphStyle: style,
                                                         .baselineOffset: (value - font.lineHeight) / 4.0]
        
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.addAttributes(attributes, range: range)
        self.attributedText = attributedText
        
        if self.lineHeight != value {
            self.lineHeight = value
        }
        
        return self
    }
    
    @discardableResult
    public func lineSpacing(_ value: CGFloat) -> Self {
        let attributedText = self.getAttriburedText()
        let style = self.getStyle()
        
        style.alignment          = self.textAlignment
        style.lineSpacing        = value
        style.lineHeightMultiple = 0.0
        style.lineBreakMode      = self.lineBreakMode
        
        let attributes: [NSAttributedString.Key: Any] = [.paragraphStyle: style]
        
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.addAttributes(attributes, range: range)
        self.attributedText = attributedText
        
        return self
    }
    
    @discardableResult
    public func lineBreak(_ value: NSLineBreakMode = .byTruncatingTail) -> Self {
        let attributedText = self.getAttriburedText()
        let style = self.getStyle()
        
        style.alignment = self.textAlignment
        
        let attributes: [NSAttributedString.Key: Any] = [.paragraphStyle: style]
        
        attributedText.addAttributes(attributes, range: .init(location: 0, length: attributedText.length))
        self.attributedText = attributedText
        
        self.lineBreakMode = value
        if #available(iOS 14.0, *) {
            switch value {
            case .byWordWrapping: self.lineBreakStrategy = .hangulWordPriority
            case .byCharWrapping: self.lineBreakStrategy = .standard
            case .byClipping:     self.lineBreakStrategy = .pushOut
            default:              break
            }
        }
        
        return self
    }
    
    @discardableResult
    public func font(_ font: UIFont?) -> Self {
        self.font = font
        return self
    }
    
    @discardableResult
    public func alignment(_ textAlignment: NSTextAlignment) -> Self {
        self.textAlignment = textAlignment
        return self
    }
    
    @discardableResult
    public func lineLimit(_ numberOfLines: Int?) -> Self {
        self.numberOfLines = numberOfLines ?? 0
        return self
    }
    
    @discardableResult
    public func size(_ textSize: CGFloat) -> Self {
        self.font = self.font?.withSize(textSize)
        return self
    }
}

extension UILabel {
    public static func + (lhs: UILabel, rhs: UILabel) -> UILabel {
        UILabel(lhs, rhs)
    }
    
    public static func += (lhs: inout UILabel, rhs: UILabel) {
        lhs = UILabel(lhs, rhs)
    }
}
