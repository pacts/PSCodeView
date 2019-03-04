//
//  PSCodeView.swift
//  PSCodeView
//
//  Created by Aaron on 2018/12/25.
//  Copyright © 2018 Pacts. All rights reserved.
//

import UIKit

enum PSCodeViewType {
    case rect
    case circle
    case line
}

class PSCodeView: UIView {
    // MARK: Properties
    
    
    /// the length defaults 6
    var length:Int32 = 6 {
        didSet {
            if length == 4 || length == 6
            {
                setNeedsDisplay()
            }
        }
    }
    
    /// the hightligtht color
    var selectedColor: UIColor = .blue {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// the normal color
    var normalColor: UIColor = .lightGray {
        didSet {
            setNeedsDisplay()
        }
    }
    /// the text color
    var textColor: UIColor = .darkText {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// the current text value
    var textStore:String = "" {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// indicates input finished
    private(set) var isCompleted:Bool?
    
    /// inputview type
    var type:PSCodeViewType = .rect{
        didSet {
            setNeedsDisplay()
        }
    }
        //    var autocorrectionType: UITextAutocorrectionType = .no
    var keyboardType: UIKeyboardType = .numberPad
    
    /// support secureTextEntry
    var isSecureTextEntry: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // MARK: Lifecycle
    override init(frame: CGRect) {
        super.init(frame:frame)
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let w = rect.size.width
        let h = rect.size.height
        
        /// the space left without itemSpace
        var itemWidth:CGFloat = scaleTo6s(40)
        if length == 4
        {
            itemWidth = scaleTo6s(45)
        }
        let safeSpace:CGFloat = 1 //left safe space for rect&circle

        let itemSpace = (w - CGFloat(length)*itemWidth - 2*safeSpace) / CGFloat(length - 1)
        let context:CGContext = UIGraphicsGetCurrentContext()!
        context.setLineWidth(1)
        switch type {
        case .line:
            var x:CGFloat = safeSpace
            let y:CGFloat = (h + itemWidth)/2 - 1
            for i in 0...length - 1
            {
                context.setStrokeColor(color4Index(i))
                x = CGFloat(i)*(itemWidth + itemSpace)
                context.move(to: CGPoint(x: x,
                                         y: y))
                x = x + itemWidth
                context.addLine(to: CGPoint(x: x,
                                            y: y))
                context.strokePath()
                
            }
            break
        case .rect:
            for i in 0...length - 1
            {
                context.setStrokeColor(color4Index(i))
                context.addRect(CGRect(x: CGFloat(i) * (itemWidth + itemSpace) + safeSpace,
                                       y: (h - itemWidth)/2,
                                       width: itemWidth,
                                       height: itemWidth))
                context.drawPath(using: .stroke)
                context.strokePath()
                
            }
            break
        case .circle:
            for i in 0...length - 1
            {
                context.setStrokeColor(color4Index(i))
                context.addArc(
                    center: CGPoint(x: CGFloat(i)*(itemWidth + itemSpace) + itemWidth/2 + safeSpace, y: h/2),
                    radius: itemWidth/2,
                    startAngle: 0,
                    endAngle: CGFloat(2*Double.pi), clockwise: false)
                context.drawPath(using: .stroke)
                context.strokePath()
                
            }
            break
        }
        if textStore.count > 0
        {
            if isSecureTextEntry
            {
                for i in 0...textStore.count - 1
                {
                    context.setStrokeColor(textColor.cgColor)
                    context.addArc(
                        center: CGPoint(x: CGFloat(i)*(itemWidth + itemSpace) + itemWidth/2 + safeSpace, y: h/2),
                        radius: itemWidth/8,
                        startAngle: 0,
                        endAngle: CGFloat(2*Double.pi), clockwise: false)
                    context.drawPath(using: .fill)
                    context.strokePath()
                    
                }
                return
            }
            for i in 0...textStore.count - 1
            {
                let start:String.Index = textStore.index(textStore.startIndex,
                                                         offsetBy: i)
                let string:String = String(textStore[start...start])
                let style:NSMutableParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
                style.alignment = .center
                string.draw(
                    in: CGRect(x: CGFloat(i)*(itemSpace + itemWidth) + safeSpace,
                               y: (h - itemWidth)/2,
                               width: itemWidth,
                               height: itemWidth),
                    withAttributes:
                    [NSAttributedString.Key.font : UIFont(name: "Arial", size: itemWidth*0.8)!,
                     NSAttributedString.Key.paragraphStyle:style,
                     NSAttributedString.Key.foregroundColor:textColor])
            }
        }
    }
    // MARK: Private Methods
    private func color4Index(_ index:Int32) -> CGColor {
        if isFirstResponder && (index == textStore.count)
        {
            return selectedColor.cgColor
        }
        return normalColor.cgColor
    }
    
    private func scaleTo6s(_ num:CGFloat) -> CGFloat {
        let screenW = UIScreen.main.bounds.width
        let screenH = UIScreen.main.bounds.height
        return num*((screenW < screenH) ? screenW : screenH)/375
    }
    // MARK: Override UIResponser Methods
    override func becomeFirstResponder() -> Bool {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.setNeedsDisplay()
        }
        return super.becomeFirstResponder()
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isFirstResponder
        {
            super.becomeFirstResponder()
            setNeedsDisplay()
        }
    }
    
    override func resignFirstResponder() -> Bool {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.setNeedsDisplay()
        }
        return super.resignFirstResponder()
    }
}

extension PSCodeView:UIKeyInput
{
    var hasText: Bool {
        return textStore.count > 0
    }
    
    func insertText(_ text: String) {
        if textStore.count < length
        {
            textStore.append(text)
            setNeedsDisplay()
        }
    }
    
    func deleteBackward() {
        if textStore.count == 0
        {
            return
        }
        let end:String.Index = textStore.index(textStore.endIndex,
                                               offsetBy: -1)
        textStore.remove(at: end)
        setNeedsDisplay()
    }
    
}


