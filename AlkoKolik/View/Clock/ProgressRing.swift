//
//  ProgressRing.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 23.02.2021.
//

import UIKit

@IBDesignable
@objcMembers
public class KDCircularProgress: UIView, CAAnimationDelegate {
    /*####################################################################################################################################################*/
    private var progressLayer: KDCircularProgressViewLayer {
        get {
            return layer as! KDCircularProgressViewLayer
        }
    }
    
    private var radius: CGFloat = 0.0 { didSet {
        progressLayer.radius = radius
    }
    }
    
    public var progress: Double {
        get { return angle.mod(between: 0.0, and: 360.0, byIncrementing: 360.0) / 360.0 }
        set { angle = newValue.clamp(lowerBound: 0.0, upperBound: 1.0) * 360.0 }
    }
    
    @IBInspectable public var angle: Double = 0.0 {
        didSet {
            pauseIfAnimating()
            progressLayer.angle = angle
        }
    }
    
    @IBInspectable public var endAngle: Double = 0.0 {
        didSet {
            endAngle = endAngle.mod(between: 0.0, and: 360.0, byIncrementing: 360.0)
            progressLayer.endAngle = endAngle
            progressLayer.setNeedsDisplay()
        }
    }
    
    @IBInspectable public var clockwise: Bool = false {
        didSet {
            progressLayer.clockwise = clockwise
            progressLayer.setNeedsDisplay()
        }
    }
    
    @IBInspectable public var roundedCorners: Bool = true {
        didSet {
            progressLayer.roundedCorners = roundedCorners
        }
    }
    
    @IBInspectable public var progressThickness: CGFloat = 0.4 {
        didSet {
            progressThickness = progressThickness.clamp(lowerBound: 0.0, upperBound: 1.0)
            progressLayer.progressThickness = progressThickness / 2.0
        }
    }
    
    @IBInspectable public var trackThickness: CGFloat = 0.5 {//Between 0 and 1
        didSet {
            trackThickness = trackThickness.clamp(lowerBound: 0.0, upperBound: 1.0)
            progressLayer.trackThickness = trackThickness / 2.0
        }
    }
    
    @IBInspectable public var trackColor: UIColor = .black {
        didSet {
            progressLayer.trackColor = trackColor
            progressLayer.setNeedsDisplay()
        }
    }
    
    
    private var animationCompletionBlock: ((Bool) -> Void)?
    
    /*####################################################################################################################################################*/
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setInitialValues()
        refreshValues()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        translatesAutoresizingMaskIntoConstraints = false
        setInitialValues()
        refreshValues()
    }
    
    override public class var layerClass: AnyClass {
        return KDCircularProgressViewLayer.self
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        radius = (frame.size.width / 2.0) * 0.8
    }
    
    private func setInitialValues() {
        radius = (frame.size.width / 2.0) * 0.8 //We always apply a 20% padding, stopping glows from being clipped
        backgroundColor = .clear
    }
    
    private func refreshValues() {
        progressLayer.angle = angle
        progressLayer.endAngle = endAngle
        progressLayer.clockwise = clockwise
        progressLayer.roundedCorners = roundedCorners
        progressLayer.progressThickness = progressThickness / 2.0
        progressLayer.trackColor = trackColor
        progressLayer.trackThickness = trackThickness / 2.0
    }
    
    public func animate(fromAngle: Double, toAngle: Double, duration: TimeInterval, relativeDuration: Bool = true, completion: ((Bool) -> Void)?) {
        pauseIfAnimating()
        let animationDuration: TimeInterval
        if relativeDuration {
            animationDuration = duration
        } else {
            let traveledAngle = (toAngle - fromAngle).mod(between: 0.0, and: 360.0, byIncrementing: 360.0)
            let scaledDuration = TimeInterval(traveledAngle) * duration / 360.0
            animationDuration = scaledDuration
        }
        
        let animation = CABasicAnimation(keyPath: #keyPath(KDCircularProgressViewLayer.angle))
        animation.fromValue = fromAngle
        animation.toValue = toAngle
        animation.duration = animationDuration
        animation.delegate = self
        animation.isRemovedOnCompletion = false
        angle = toAngle
        animationCompletionBlock = completion
        
        progressLayer.add(animation, forKey: "angle")
    }
    
    public func animate(toAngle: Double, duration: TimeInterval, relativeDuration: Bool = true, completion: ((Bool) -> Void)?) {
        pauseIfAnimating()
        animate(fromAngle: angle, toAngle: toAngle, duration: duration, relativeDuration: relativeDuration, completion: completion)
    }
    
    public func pauseAnimation() {
        guard let presentationLayer = progressLayer.presentation() else { return }
        
        let currentValue = presentationLayer.angle
        progressLayer.removeAllAnimations()
        angle = currentValue
    }
    
    private func pauseIfAnimating() {
        if isAnimating() {
            pauseAnimation()
        }
    }
    
    public func stopAnimation() {
        progressLayer.removeAllAnimations()
        angle = 0
    }
    
    public func isAnimating() -> Bool {
        return progressLayer.animation(forKey: "angle") != nil
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        animationCompletionBlock?(flag)
        animationCompletionBlock = nil
    }
    
    public override func didMoveToWindow() {
        window.map { progressLayer.contentsScale = $0.screen.scale }
    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil {
            pauseIfAnimating()
        }
    }
    
    public override func prepareForInterfaceBuilder() {
        setInitialValues()
        refreshValues()
        progressLayer.setNeedsDisplay()
    }
    /*####################################################################################################################################################*/
    private class KDCircularProgressViewLayer: CALayer {
        @NSManaged var angle: Double
        var radius: CGFloat = 0.0
        var endAngle: Double = 0.0
        var clockwise: Bool = false
        var roundedCorners: Bool = true
        var progressThickness: CGFloat = 0.5
        var trackThickness: CGFloat = 0.5
        var trackColor: UIColor = .black
        var progressInsideFillColor: UIColor = .clear
        
        
        override class func needsDisplay(forKey key: String) -> Bool {
            if key == #keyPath(angle) {
                return true
            }
            return super.needsDisplay(forKey: key)
        }
        
        override init(layer: Any) {
            super.init(layer: layer)
            let progressLayer = layer as! KDCircularProgressViewLayer
            radius = progressLayer.radius
            angle = progressLayer.angle
            endAngle = progressLayer.endAngle
            clockwise = progressLayer.clockwise
            roundedCorners = progressLayer.roundedCorners
            progressThickness = progressLayer.progressThickness
            trackThickness = progressLayer.trackThickness
            trackColor = progressLayer.trackColor
            progressInsideFillColor = progressLayer.progressInsideFillColor
        }
        
        override init() {
            super.init()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        override func draw(in ctx: CGContext) {
            UIGraphicsPushContext(ctx)
            
            let size = bounds.size
            let width = size.width
            let height = size.height
            
            let trackLineWidth = radius * trackThickness
            let progressLineWidth = radius * progressThickness
            let arcRadius = max(radius - trackLineWidth / 2.0, radius - progressLineWidth / 2.0)
            ctx.addArc(center: CGPoint(x: width / 2.0, y: height / 2.0),
                       radius: arcRadius,
                       startAngle: 0,
                       endAngle: CGFloat.pi * 2,
                       clockwise: false)
            ctx.setStrokeColor(trackColor.cgColor)
            ctx.setFillColor(progressInsideFillColor.cgColor)
            ctx.setLineWidth(trackLineWidth)
            ctx.setLineCap(CGLineCap.butt)
            ctx.drawPath(using: .fillStroke)
            
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            
            let imageCtx = UIGraphicsGetCurrentContext()
            let canonicalAngle = angle.mod(between: 0.0, and: 360.0, byIncrementing: 360.0)
            let fromAngle = -endAngle.radians
            let toAngle: Double
            if clockwise {
                toAngle = (-canonicalAngle - endAngle).radians
            } else {
                toAngle = (canonicalAngle - endAngle).radians
            }
            
            imageCtx?.addArc(center: CGPoint(x: width / 2.0, y: height / 2.0),
                             radius: arcRadius,
                             startAngle: CGFloat(fromAngle),
                             endAngle: CGFloat(toAngle),
                             clockwise: clockwise)
            
            let linecap: CGLineCap = roundedCorners ? .round : .butt
            imageCtx?.setLineCap(linecap)
            imageCtx?.setLineWidth(progressLineWidth)
            imageCtx?.drawPath(using: .stroke)
            
            let drawMask: CGImage = UIGraphicsGetCurrentContext()!.makeImage()!
            UIGraphicsEndImageContext()
            
            ctx.saveGState()
            ctx.clip(to: bounds, mask: drawMask)
            
            fillRect(withContext: ctx, color: .white)
            
            ctx.restoreGState()
            UIGraphicsPopContext()
        }
        
        private func fillRect(withContext context: CGContext, color: UIColor) {
            context.setFillColor(color.cgColor)
            context.fill(bounds)
        }
    }
}
/*####################################################################################################################################################*/
//Some helper extensions below
private extension Array where Element == UIColor {
    // Make sure every color in colors array is in RGB color space
    var rgbNormalized: [UIColor] {
        return map { color in
            guard color.cgColor.numberOfComponents == 2 else {
                return color
            }
            
            let white: CGFloat = color.cgColor.components![0]
            return UIColor(red: white, green: white, blue: white, alpha: 1.0)
        }
    }
    
    var componentsJoined: [CGFloat] {
        return flatMap { $0.cgColor.components ?? [] }
    }
}

private extension Comparable {
    func clamp(lowerBound: Self, upperBound: Self) -> Self {
        return min(max(self, lowerBound), upperBound)
    }
}

private extension FloatingPoint {
    var radians: Self {
        return self * .pi / Self(180)
    }
    
    func mod(between left: Self, and right: Self, byIncrementing interval: Self) -> Self {
        assert(interval > 0)
        assert(interval <= right - left)
        assert(right > left)
        
        if self >= left, self <= right {
            return self
        } else if self < left {
            return (self + interval).mod(between: left, and: right, byIncrementing: interval)
        } else {
            return (self - interval).mod(between: left, and: right, byIncrementing: interval)
        }
    }
}


class ProgressRing : UIImageView {
    
    private var diameter: CGFloat { return min(frame.width, frame.height) }
    private var radius: CGFloat {return diameter/2}
    lazy var scaleFactor = { return diameter / 277.0 }()
    
    static var trackLineWidth : CGFloat = 30
    static var progressLineWidth : CGFloat = 30
    
    var trackColor: UIColor = .appMax
    var progressRingInsideFillColor: UIColor = .clear
    
    var angle: Double = 90.0
    var endAngle: Double = 150.0
    var clockwise: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup() {
        let backgroundRing = drawRingBackground()
        let progressRing = drawProgressRing()
        self.addSubview(UIImageView(image: backgroundRing))
        self.mask = UIImageView(image: progressRing)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    private func drawRingBackground()->UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: diameter, height: diameter))
        return renderer.image { ctx in
            let cgctx = ctx.cgContext
            let arcRadius = max(radius - (ProgressRing.trackLineWidth * scaleFactor) / 2.0, radius - (ProgressRing.progressLineWidth * scaleFactor) / 2.0)
            cgctx.addArc(center: CGPoint(x: radius, y: radius),
                         radius: arcRadius,
                         startAngle: 0,
                         endAngle: CGFloat.pi * 2,
                         clockwise: false)
            cgctx.setStrokeColor(trackColor.cgColor)
            cgctx.setFillColor(progressRingInsideFillColor.cgColor)
            cgctx.setLineWidth(ProgressRing.trackLineWidth * scaleFactor)
            cgctx.setLineCap(.round)
            cgctx.drawPath(using: .fillStroke)
        }
    }
    
    private func drawProgressRing() -> UIImage {
        let renderer =  UIGraphicsImageRenderer(size: CGSize(width: diameter, height: diameter))
        return renderer.image { ctx in
            let cgctx = ctx.cgContext
            let arcRadius = max(radius - (ProgressRing.trackLineWidth*scaleFactor) / 2.0, radius - (ProgressRing.progressLineWidth*scaleFactor) / 2.0)
            let canonicalAngle = angle.mod(between: 0.0, and: 360.0, byIncrementing: 360.0)
            let fromAngle = -endAngle.radians
            let toAngle: Double
            
            cgctx.addArc(center: CGPoint(x: radius, y: radius),
                            radius: arcRadius,
                            startAngle: CGFloat(-90.0.radians),
                            endAngle: CGFloat(150.0.radians),
                            clockwise: clockwise)
            
            cgctx.setLineCap(.round)
            cgctx.setLineWidth(ProgressRing.progressLineWidth*scaleFactor)
            cgctx.drawPath(using: .stroke)
        }
    }
}
