//
//  SUVK+UILabel.swift
//  SwiftUIViewKit
//
//  Created by LONELiE on 2023/02/09.
//

import UIKit

extension UILabel {
    public convenience init(_ text: String?) {
        self.init(frame: .zero)
        self.text = text
    }
    
    public convenience init(attributed text: NSAttributedString?) {
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
}

extension UILabel {
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
    @discardableResult
    public func underLine(_ flag: Bool) -> Self {
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
}

extension UILabel {
    private func getAttriburedText() -> NSMutableAttributedString {
        if let value = self.attributedText {
            return NSMutableAttributedString(attributedString: value)
        } else if let text = self.text, let font = self.font, let color = self.textColor,
                  let value = UILabel(text).font(font).color(color).attributedText {
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
}

extension UILabel {
    private struct LineHeightStore {
        static var key = "lineHeight"
    }
    
    public var lineHeight: CGFloat? {
        get {
            return objc_getAssociatedObject(self, &LineHeightStore.key) as? CGFloat
        }
        set {
            objc_setAssociatedObject(self, &LineHeightStore.key, newValue, .OBJC_ASSOCIATION_RETAIN)
            if let newValue = newValue {
                self.lineHeight(newValue)
            }
        }
    }
    
    @discardableResult
    public func lineHeight(_ value: CGFloat) -> Self {
        guard let font = self.font else { return self }
        
        if self.lineHeight != value {
            self.lineHeight = value
        } else {
            let attributedText = self.getAttriburedText()
            let style = self.getStyle()
            style.alignment         = self.textAlignment
            style.maximumLineHeight = value
            style.minimumLineHeight = value
            style.lineBreakMode     = self.lineBreakMode
            
            let offset: CGFloat = {
                if #available(iOS 16.0, *) {
                    return 0.5
                } else {
                    return 0.25
                }
            }()
            let attributes: [NSAttributedString.Key: Any] = [.paragraphStyle: style,
                                                             .baselineOffset: (value - font.lineHeight) * offset]
            
            let range = NSRange(location: 0, length: attributedText.length)
            attributes.forEach {
                attributedText.removeAttribute($0.key, range: range)
                attributedText.addAttribute($0.key, value: $0.value, range: range)
            }
            self.attributedText = attributedText
        }
        
        return self
    }
}

extension UILabel {
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
}

extension UILabel {
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
}

extension UILabel {
    public static func + (lhs: UILabel, rhs: UILabel) -> UILabel {
        UILabel(lhs, rhs)
    }
    
    public static func += (lhs: inout UILabel, rhs: UILabel) {
        lhs = UILabel(lhs, rhs)
    }
}
