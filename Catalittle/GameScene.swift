//
//  GameScene.swift
//  Catalittle
//
//  A complete, faithful clone of "Bearalot" / "Bear Links" built in Swift & SpriteKit.
//  - Deterministic column-stack grid engine: blocks NEVER drift or scroll out of grid.
//  - Relative drop falling: spawning new rows NEVER causes existing blocks to drop or twitch.
//  - Pre-buffered deep floor spawning with zero visible pop-in.
//  - Perfectly aligned connecting lines pathing directly through sprite centers.
//  - Full-width seamless laser beam with instant-kill collision.
//  - Horizontal X-axis scrolling panoramic background and infinite grass floor.
//  - Cohesive Glockenspiel / Bell chimes with 16x+ Prestige sparkle crown.
//

import SpriteKit
import GameplayKit
import CoreGraphics
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - Bear / Character Types (Authentic Bearalot Pill Art - Strictly Bounded)

enum BearType: Int, CaseIterable {
    case pinkBear = 0     // Pink bear with round ears & cute snout
    case greenLass        // Green pill with hair ribbon & lashes
    case orangeJoy        // Orange pill with wide open laughing mouth
    case cyanPeach        // Split peach/cyan with big round nose
    case redMustache      // Red/coral pill with black mustache
    case limeFrog         // Lime green with wide-set dot eyes & smile
    case yellowStar       // Bright yellow star/cat with anime sparkle eyes
    case pandaBear        // Panda with white face, black eye patches & ears
    
    var primaryColor: SKColor {
        switch self {
        case .pinkBear:     return SKColor(red: 1.0, green: 0.72, blue: 0.80, alpha: 1.0)
        case .greenLass:    return SKColor(red: 0.32, green: 0.82, blue: 0.40, alpha: 1.0)
        case .orangeJoy:    return SKColor(red: 1.0, green: 0.65, blue: 0.18, alpha: 1.0)
        case .cyanPeach:    return SKColor(red: 0.35, green: 0.85, blue: 0.95, alpha: 1.0)
        case .redMustache:  return SKColor(red: 1.0, green: 0.45, blue: 0.48, alpha: 1.0)
        case .limeFrog:     return SKColor(red: 0.62, green: 0.94, blue: 0.22, alpha: 1.0)
        case .yellowStar:   return SKColor(red: 1.0, green: 0.92, blue: 0.25, alpha: 1.0)
        case .pandaBear:    return SKColor(red: 0.96, green: 0.97, blue: 1.0, alpha: 1.0)
        }
    }
    
    static func generateTexture(for type: BearType, size: CGSize) -> SKTexture {
        let scale: CGFloat = 2.0
        let pixelWidth = max(Int(size.width * scale), 1)
        let pixelHeight = max(Int(size.height * scale), 1)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        
        guard let ctx = CGContext(
            data: nil,
            width: pixelWidth,
            height: pixelHeight,
            bitsPerComponent: 8,
            bytesPerRow: pixelWidth * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return SKTexture()
        }
        
        ctx.scaleBy(x: scale, y: scale)
        let w = size.width
        let h = size.height
        let cornerRadius: CGFloat = h * 0.44
        
        let bodyRect = CGRect(x: 2, y: 2, width: w - 4, height: h - 4)
        let bodyPath = CGPath(roundedRect: bodyRect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
        
        ctx.saveGState()
        ctx.addPath(bodyPath)
        ctx.clip()
        
        ctx.setFillColor(type.primaryColor.cgColor)
        ctx.fill(CGRect(x: 0, y: 0, width: w, height: h))
        
        switch type {
        case .pinkBear:
            let earR: CGFloat = h * 0.20
            ctx.setFillColor(SKColor(red: 1.0, green: 0.65, blue: 0.75, alpha: 1.0).cgColor)
            ctx.fillEllipse(in: CGRect(x: w * 0.10, y: h * 0.58, width: earR * 2, height: earR * 2))
            ctx.fillEllipse(in: CGRect(x: w * 0.90 - earR * 2, y: h * 0.58, width: earR * 2, height: earR * 2))
            
            let eyeR: CGFloat = h * 0.08
            ctx.setFillColor(SKColor(red: 0.15, green: 0.1, blue: 0.15, alpha: 1.0).cgColor)
            ctx.fillEllipse(in: CGRect(x: w * 0.32 - eyeR, y: h * 0.50 - eyeR, width: eyeR * 2, height: eyeR * 2))
            ctx.fillEllipse(in: CGRect(x: w * 0.68 - eyeR, y: h * 0.50 - eyeR, width: eyeR * 2, height: eyeR * 2))
            
            ctx.setFillColor(SKColor.white.cgColor)
            ctx.fillEllipse(in: CGRect(x: w * 0.30 - eyeR * 0.3, y: h * 0.52, width: eyeR * 0.8, height: eyeR * 0.8))
            ctx.fillEllipse(in: CGRect(x: w * 0.66 - eyeR * 0.3, y: h * 0.52, width: eyeR * 0.8, height: eyeR * 0.8))
            
            ctx.setFillColor(SKColor(red: 1.0, green: 0.45, blue: 0.6, alpha: 0.45).cgColor)
            ctx.fillEllipse(in: CGRect(x: w * 0.18, y: h * 0.38, width: h * 0.22, height: h * 0.18))
            ctx.fillEllipse(in: CGRect(x: w * 0.82 - h * 0.22, y: h * 0.38, width: h * 0.22, height: h * 0.18))
            
            ctx.setStrokeColor(SKColor(red: 0.2, green: 0.1, blue: 0.2, alpha: 1.0).cgColor)
            ctx.setLineWidth(2.2)
            ctx.setLineCap(.round)
            ctx.move(to: CGPoint(x: w * 0.5, y: h * 0.45))
            ctx.addLine(to: CGPoint(x: w * 0.5, y: h * 0.34))
            ctx.move(to: CGPoint(x: w * 0.5, y: h * 0.34))
            ctx.addLine(to: CGPoint(x: w * 0.42, y: h * 0.24))
            ctx.move(to: CGPoint(x: w * 0.5, y: h * 0.34))
            ctx.addLine(to: CGPoint(x: w * 0.58, y: h * 0.24))
            ctx.strokePath()
            
        case .pandaBear:
            let earR: CGFloat = h * 0.20
            ctx.setFillColor(SKColor(red: 0.15, green: 0.18, blue: 0.25, alpha: 1.0).cgColor)
            ctx.fillEllipse(in: CGRect(x: w * 0.10, y: h * 0.58, width: earR * 2, height: earR * 2))
            ctx.fillEllipse(in: CGRect(x: w * 0.90 - earR * 2, y: h * 0.58, width: earR * 2, height: earR * 2))
            
            let patchW = w * 0.24
            let patchH = h * 0.44
            ctx.fillEllipse(in: CGRect(x: w * 0.18, y: h * 0.30, width: patchW, height: patchH))
            ctx.fillEllipse(in: CGRect(x: w * 0.82 - patchW, y: h * 0.30, width: patchW, height: patchH))
            
            ctx.setFillColor(SKColor.white.cgColor)
            let eyeR: CGFloat = h * 0.09
            ctx.fillEllipse(in: CGRect(x: w * 0.30 - eyeR, y: h * 0.52 - eyeR, width: eyeR * 2, height: eyeR * 2))
            ctx.fillEllipse(in: CGRect(x: w * 0.70 - eyeR, y: h * 0.52 - eyeR, width: eyeR * 2, height: eyeR * 2))
            
            ctx.setFillColor(SKColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0).cgColor)
            ctx.fillEllipse(in: CGRect(x: w * 0.30 - eyeR * 0.6, y: h * 0.52 - eyeR * 0.6, width: eyeR * 1.2, height: eyeR * 1.2))
            ctx.fillEllipse(in: CGRect(x: w * 0.70 - eyeR * 0.6, y: h * 0.52 - eyeR * 0.6, width: eyeR * 1.2, height: eyeR * 1.2))
            ctx.setFillColor(SKColor.white.cgColor)
            ctx.fillEllipse(in: CGRect(x: w * 0.30 - eyeR * 0.3, y: h * 0.54, width: eyeR * 0.5, height: eyeR * 0.5))
            ctx.fillEllipse(in: CGRect(x: w * 0.70 - eyeR * 0.3, y: h * 0.54, width: eyeR * 0.5, height: eyeR * 0.5))
            
            ctx.setFillColor(SKColor(red: 0.2, green: 0.2, blue: 0.25, alpha: 1.0).cgColor)
            ctx.fillEllipse(in: CGRect(x: w * 0.46, y: h * 0.32, width: w * 0.08, height: h * 0.09))
            
        case .greenLass:
            ctx.setStrokeColor(SKColor(red: 0.15, green: 0.45, blue: 0.2, alpha: 1.0).cgColor)
            ctx.setLineWidth(2.2)
            ctx.move(to: CGPoint(x: w * 0.30, y: h * 0.85))
            ctx.addQuadCurve(to: CGPoint(x: w * 0.50, y: h * 0.65), control: CGPoint(x: w * 0.40, y: h * 0.75))
            ctx.addQuadCurve(to: CGPoint(x: w * 0.70, y: h * 0.85), control: CGPoint(x: w * 0.60, y: h * 0.75))
            ctx.strokePath()
            
            ctx.setStrokeColor(SKColor(red: 0.1, green: 0.25, blue: 0.15, alpha: 1.0).cgColor)
            ctx.setLineWidth(2.0)
            ctx.move(to: CGPoint(x: w * 0.28, y: h * 0.46))
            ctx.addQuadCurve(to: CGPoint(x: w * 0.38, y: h * 0.46), control: CGPoint(x: w * 0.33, y: h * 0.56))
            ctx.move(to: CGPoint(x: w * 0.62, y: h * 0.46))
            ctx.addQuadCurve(to: CGPoint(x: w * 0.72, y: h * 0.46), control: CGPoint(x: w * 0.67, y: h * 0.56))
            ctx.move(to: CGPoint(x: w * 0.72, y: h * 0.48))
            ctx.addLine(to: CGPoint(x: w * 0.77, y: h * 0.52))
            ctx.strokePath()
            
            ctx.move(to: CGPoint(x: w * 0.44, y: h * 0.30))
            ctx.addQuadCurve(to: CGPoint(x: w * 0.56, y: h * 0.30), control: CGPoint(x: w * 0.50, y: h * 0.22))
            ctx.strokePath()
            
        case .orangeJoy:
            ctx.setStrokeColor(SKColor(red: 0.25, green: 0.12, blue: 0.05, alpha: 1.0).cgColor)
            ctx.setLineWidth(2.5)
            ctx.setLineCap(.round)
            ctx.move(to: CGPoint(x: w * 0.24, y: h * 0.58))
            ctx.addQuadCurve(to: CGPoint(x: w * 0.40, y: h * 0.58), control: CGPoint(x: w * 0.32, y: h * 0.74))
            ctx.move(to: CGPoint(x: w * 0.60, y: h * 0.58))
            ctx.addQuadCurve(to: CGPoint(x: w * 0.76, y: h * 0.58), control: CGPoint(x: w * 0.68, y: h * 0.74))
            ctx.strokePath()
            
            let mouthRect = CGRect(x: w * 0.30, y: h * 0.16, width: w * 0.40, height: h * 0.38)
            let mouthPath = CGPath(roundedRect: mouthRect, cornerWidth: h * 0.18, cornerHeight: h * 0.18, transform: nil)
            ctx.setFillColor(SKColor(red: 0.90, green: 0.22, blue: 0.15, alpha: 1.0).cgColor)
            ctx.addPath(mouthPath)
            ctx.fillPath()
            ctx.setStrokeColor(SKColor(red: 0.25, green: 0.12, blue: 0.05, alpha: 1.0).cgColor)
            ctx.setLineWidth(2.0)
            ctx.addPath(mouthPath)
            ctx.strokePath()
            
            ctx.saveGState()
            ctx.addPath(mouthPath)
            ctx.clip()
            ctx.setFillColor(SKColor(red: 1.0, green: 0.55, blue: 0.65, alpha: 1.0).cgColor)
            ctx.fillEllipse(in: CGRect(x: w * 0.35, y: h * 0.10, width: w * 0.30, height: h * 0.25))
            ctx.restoreGState()
            
        case .cyanPeach:
            ctx.setFillColor(SKColor(red: 1.0, green: 0.82, blue: 0.72, alpha: 1.0).cgColor)
            ctx.fill(CGRect(x: 0, y: h * 0.46, width: w, height: h * 0.54))
            ctx.setFillColor(SKColor(red: 0.30, green: 0.88, blue: 0.95, alpha: 1.0).cgColor)
            ctx.fill(CGRect(x: 0, y: 0, width: w, height: h * 0.46))
            
            let noseRect = CGRect(x: w * 0.40, y: h * 0.36, width: w * 0.20, height: h * 0.26)
            ctx.setFillColor(SKColor(red: 1.0, green: 0.68, blue: 0.58, alpha: 1.0).cgColor)
            ctx.fillEllipse(in: noseRect)
            ctx.setStrokeColor(SKColor(red: 0.2, green: 0.15, blue: 0.15, alpha: 1.0).cgColor)
            ctx.setLineWidth(1.8)
            ctx.strokeEllipse(in: noseRect)
            
            let eyeY = h * 0.64
            ctx.setFillColor(SKColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0).cgColor)
            ctx.fillEllipse(in: CGRect(x: w * 0.30, y: eyeY, width: 4.5, height: 4.5))
            ctx.fillEllipse(in: CGRect(x: w * 0.66, y: eyeY, width: 4.5, height: 4.5))
            
            ctx.setStrokeColor(SKColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0).cgColor)
            ctx.setLineWidth(1.8)
            ctx.move(to: CGPoint(x: w * 0.26, y: eyeY + 8))
            ctx.addLine(to: CGPoint(x: w * 0.36, y: eyeY + 12))
            ctx.strokePath()
            
            ctx.move(to: CGPoint(x: w * 0.56, y: h * 0.26))
            ctx.addQuadCurve(to: CGPoint(x: w * 0.68, y: h * 0.32), control: CGPoint(x: w * 0.62, y: h * 0.24))
            ctx.strokePath()
            
        case .redMustache:
            let eyeR: CGFloat = h * 0.08
            ctx.setFillColor(SKColor(red: 0.15, green: 0.1, blue: 0.15, alpha: 1.0).cgColor)
            ctx.fillEllipse(in: CGRect(x: w * 0.32 - eyeR, y: h * 0.60 - eyeR, width: eyeR * 2, height: eyeR * 2))
            ctx.fillEllipse(in: CGRect(x: w * 0.68 - eyeR, y: h * 0.60 - eyeR, width: eyeR * 2, height: eyeR * 2))
            
            ctx.setFillColor(SKColor(red: 0.12, green: 0.15, blue: 0.25, alpha: 1.0).cgColor)
            let stachePath = CGMutablePath()
            stachePath.move(to: CGPoint(x: w * 0.5, y: h * 0.44))
            stachePath.addCurve(to: CGPoint(x: w * 0.25, y: h * 0.38), control1: CGPoint(x: w * 0.42, y: h * 0.50), control2: CGPoint(x: w * 0.30, y: h * 0.48))
            stachePath.addQuadCurve(to: CGPoint(x: w * 0.48, y: h * 0.28), control: CGPoint(x: w * 0.32, y: h * 0.32))
            stachePath.addLine(to: CGPoint(x: w * 0.5, y: h * 0.34))
            stachePath.addLine(to: CGPoint(x: w * 0.52, y: h * 0.28))
            stachePath.addQuadCurve(to: CGPoint(x: w * 0.75, y: h * 0.38), control: CGPoint(x: w * 0.68, y: h * 0.32))
            stachePath.addCurve(to: CGPoint(x: w * 0.5, y: h * 0.44), control1: CGPoint(x: w * 0.70, y: h * 0.48), control2: CGPoint(x: w * 0.58, y: h * 0.50))
            ctx.addPath(stachePath)
            ctx.fillPath()
            
        case .limeFrog:
            let eyeY = h * 0.54
            ctx.setFillColor(SKColor(red: 0.1, green: 0.2, blue: 0.1, alpha: 1.0).cgColor)
            ctx.fillEllipse(in: CGRect(x: w * 0.20, y: eyeY, width: 6.0, height: 6.0))
            ctx.fillEllipse(in: CGRect(x: w * 0.76, y: eyeY, width: 6.0, height: 6.0))
            ctx.setFillColor(SKColor.white.cgColor)
            ctx.fillEllipse(in: CGRect(x: w * 0.22, y: eyeY + 2.5, width: 2.5, height: 2.5))
            ctx.fillEllipse(in: CGRect(x: w * 0.78, y: eyeY + 2.5, width: 2.5, height: 2.5))
            
            ctx.setStrokeColor(SKColor(red: 0.1, green: 0.25, blue: 0.1, alpha: 1.0).cgColor)
            ctx.setLineWidth(2.0)
            ctx.move(to: CGPoint(x: w * 0.38, y: h * 0.32))
            ctx.addQuadCurve(to: CGPoint(x: w * 0.62, y: h * 0.32), control: CGPoint(x: w * 0.50, y: h * 0.22))
            ctx.strokePath()
            
        case .yellowStar:
            let earPath = CGMutablePath()
            earPath.move(to: CGPoint(x: w * 0.14, y: h * 0.65))
            earPath.addLine(to: CGPoint(x: w * 0.22, y: h * 0.90))
            earPath.addLine(to: CGPoint(x: w * 0.34, y: h * 0.76))
            earPath.move(to: CGPoint(x: w * 0.86, y: h * 0.65))
            earPath.addLine(to: CGPoint(x: w * 0.78, y: h * 0.90))
            earPath.addLine(to: CGPoint(x: w * 0.66, y: h * 0.76))
            ctx.setFillColor(SKColor(red: 1.0, green: 0.82, blue: 0.15, alpha: 1.0).cgColor)
            ctx.addPath(earPath)
            ctx.fillPath()
            
            let eyeR: CGFloat = h * 0.11
            let eyeY = h * 0.54
            ctx.setFillColor(SKColor(red: 0.15, green: 0.12, blue: 0.05, alpha: 1.0).cgColor)
            ctx.fillEllipse(in: CGRect(x: w * 0.30 - eyeR, y: eyeY - eyeR, width: eyeR * 2, height: eyeR * 2))
            ctx.fillEllipse(in: CGRect(x: w * 0.70 - eyeR, y: eyeY - eyeR, width: eyeR * 2, height: eyeR * 2))
            ctx.setFillColor(SKColor.white.cgColor)
            ctx.fillEllipse(in: CGRect(x: w * 0.28, y: eyeY + 1.0, width: eyeR * 0.7, height: eyeR * 0.7))
            ctx.fillEllipse(in: CGRect(x: w * 0.68, y: eyeY + 1.0, width: eyeR * 0.7, height: eyeR * 0.7))
            ctx.fillEllipse(in: CGRect(x: w * 0.34, y: eyeY - eyeR * 0.5, width: eyeR * 0.4, height: eyeR * 0.4))
            ctx.fillEllipse(in: CGRect(x: w * 0.74, y: eyeY - eyeR * 0.5, width: eyeR * 0.4, height: eyeR * 0.4))
            
            ctx.setFillColor(SKColor(red: 0.95, green: 0.3, blue: 0.4, alpha: 1.0).cgColor)
            ctx.fillEllipse(in: CGRect(x: w * 0.46, y: h * 0.26, width: w * 0.08, height: h * 0.14))
        }
        
        ctx.restoreGState()
        
        ctx.setStrokeColor(SKColor(red: 0.12, green: 0.15, blue: 0.18, alpha: 0.95).cgColor)
        ctx.setLineWidth(2.5)
        ctx.addPath(bodyPath)
        ctx.strokePath()
        
        guard let cgImage = ctx.makeImage() else { return SKTexture() }
        return SKTexture(cgImage: cgImage)
    }
    
    static func generateClearStateTexture(size: CGSize) -> SKTexture {
        let scale: CGFloat = 2.0
        let pixelWidth = max(Int(size.width * scale), 1)
        let pixelHeight = max(Int(size.height * scale), 1)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        
        guard let ctx = CGContext(
            data: nil,
            width: pixelWidth,
            height: pixelHeight,
            bitsPerComponent: 8,
            bytesPerRow: pixelWidth * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return SKTexture()
        }
        
        ctx.scaleBy(x: scale, y: scale)
        let w = size.width
        let h = size.height
        let cornerRadius: CGFloat = h * 0.44
        
        let bodyRect = CGRect(x: 2, y: 2, width: w - 4, height: h - 4)
        let bodyPath = CGPath(roundedRect: bodyRect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
        
        ctx.setFillColor(SKColor(red: 1.0, green: 0.99, blue: 0.88, alpha: 1.0).cgColor)
        ctx.addPath(bodyPath)
        ctx.fillPath()
        
        ctx.setStrokeColor(SKColor(red: 1.0, green: 0.90, blue: 0.20, alpha: 1.0).cgColor)
        ctx.setLineWidth(3.5)
        ctx.addPath(bodyPath)
        ctx.strokePath()
        
        guard let cgImage = ctx.makeImage() else { return SKTexture() }
        return SKTexture(cgImage: cgImage)
    }
}

// MARK: - BearBlockNode Class

class BearBlockNode: SKSpriteNode {
    let bearType: BearType
    var isClearing: Bool = false
    var isSelected: Bool = false {
        didSet {
            selectionBorder?.isHidden = !isSelected
        }
    }
    
    private var selectionBorder: SKShapeNode?
    private var defaultTexture: SKTexture
    private var clearTexture: SKTexture
    
    init(type: BearType, size: CGSize, normalTex: SKTexture, clearTex: SKTexture) {
        self.bearType = type
        self.defaultTexture = normalTex
        self.clearTexture = clearTex
        super.init(texture: normalTex, color: .clear, size: size)
        self.name = "bear_block"
        
        setupSelectionBorder(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSelectionBorder(size: CGSize) {
        let border = SKShapeNode(rectOf: CGSize(width: size.width + 4, height: size.height + 4), cornerRadius: size.height * 0.44)
        border.strokeColor = SKColor.white
        border.lineWidth = 3.5
        border.fillColor = SKColor.white.withAlphaComponent(0.25)
        border.zPosition = 10
        border.isHidden = true
        
        let pulseUp = SKAction.scale(to: 1.08, duration: 0.2)
        let pulseDown = SKAction.scale(to: 0.95, duration: 0.2)
        border.run(SKAction.repeatForever(SKAction.sequence([pulseUp, pulseDown])))
        
        addChild(border)
        self.selectionBorder = border
    }
    
    func enterClearState() {
        guard !isClearing else { return }
        isClearing = true
        isSelected = false
        self.texture = clearTexture
        
        let grow = SKAction.scale(to: 1.06, duration: 0.25)
        let shrink = SKAction.scale(to: 0.96, duration: 0.25)
        self.run(SKAction.repeatForever(SKAction.sequence([grow, shrink])), withKey: "clear_pulse")
    }
    
    func popAndRemove(completion: @escaping () -> Void) {
        self.removeAction(forKey: "clear_pulse")
        
        let pop = SKAction.scale(to: 1.25, duration: 0.05)
        let vanish = SKAction.group([
            SKAction.scale(to: 0.0, duration: 0.12),
            SKAction.fadeOut(withDuration: 0.12)
        ])
        
        self.run(SKAction.sequence([pop, vanish, SKAction.removeFromParent()])) {
            completion()
        }
    }
}

// MARK: - Game State Enum

enum GameState {
    case ready
    case playing
    case gameOver
}

// MARK: - GameScene

class GameScene: SKScene {
    
    // MARK: - Safe Area Inset
    var safeAreaTopInset: CGFloat = 59.0
    
    // 6 Columns across
    private let columnsCount: Int = 6
    private var blockSize: CGSize = .zero
    private var playableRect: CGRect = .zero
    private var floorY: CGFloat = 0
    private var dangerLineY: CGFloat = 0
    private var topHUD_Y: CGFloat = 0
    private var colWidth: CGFloat = 0
    private var rowHeight: CGFloat = 0
    private var gridStartX: CGFloat = 0
    
    // MARK: - Deterministic Column Matrix Engine
    private var columns: [[BearBlockNode]] = Array(repeating: [], count: 6)
    
    // MARK: - Layers & Scrolling
    private var gameLayer = SKNode()
    private var nextSpawnThreshold: CGFloat = 0
    private var baseRiseSpeed: Double = 4.5
    private var lastUpdateTime: TimeInterval = 0
    
    // MARK: - Panoramic Horizontal X-Axis Scrolling Background
    private var bgContainer = SKNode()
    private var bgStrip1 = SKNode()
    private var bgStrip2 = SKNode()
    private var bgStripWidth: CGFloat = 0
    private let bgScrollSpeed: CGFloat = 12.0
    
    // MARK: - Horizontal X-Axis Scrolling Grass Floor
    private var grassContainer = SKNode()
    private var grassStrip1 = SKNode()
    private var grassStrip2 = SKNode()
    private var grassStripWidth: CGFloat = 0
    private let grassScrollSpeed: CGFloat = 26.0
    
    // MARK: - Selection & Clear State
    private var selectedBlock: BearBlockNode? = nil
    private var clearingBlocks = Set<BearBlockNode>()
    private var clearStateEndTime: TimeInterval = 0
    private let clearDuration: TimeInterval = 1.75
    
    // MARK: - Game State & Score
    private var gameState: GameState = .ready
    private var score: Int = 0 {
        didSet { updateScoreLabel() }
    }
    private var level: Int = 1 {
        didSet { updateLevelLabel() }
    }
    private var levelProgress: CGFloat = 0.0
    private var comboCount: Int = 0
    
    // MARK: - Electric Laser Danger Line (Full-Width, Instant Kill)
    private var laserGlowNode = SKShapeNode()
    private var laserCoreNode = SKShapeNode()
    private var lastLaserJitterTime: TimeInterval = 0
    
    // MARK: - Pre-Warmed Texture Cache
    private static var cachedBearTextures: [BearType: SKTexture] = [:]
    private static var cachedClearTexture: SKTexture? = nil
    
    // MARK: - UI Nodes
    private var hudNode = SKNode()
    private var scoreLabel = SKLabelNode()
    private var levelLabel = SKLabelNode()
    private var levelProgressBar = SKShapeNode()
    private var gameOverOverlay = SKNode()
    
    // MARK: - Touch Tracking
    private var touchStartLocation: CGPoint?
    private var lastTouchLocation: CGPoint?
    private var isDraggingBoard: Bool = false
    private var totalDragDeltaY: CGFloat = 0
    
    // MARK: - Scene Lifecycle
    
    override func didMove(to view: SKView) {
        _ = SoundManager.shared
        
        setupPlayableArea()
        generateTextures()
        setupHorizontalPanoramicBackground()
        setupGameLayer()
        setupHorizontalScrollingGrass()
        setupHUD()
        setupElectricLaserLine()
        
        startGame()
    }
    
    // MARK: - Geometry Setup
    
    private func setupPlayableArea() {
        let safeTop = max(safeAreaTopInset, 60.0)
        topHUD_Y = size.height - safeTop - 45.0
        dangerLineY = topHUD_Y - 65.0
        
        floorY = 88.0
        
        let playWidth = size.width - 24.0
        playableRect = CGRect(
            x: 12.0,
            y: floorY,
            width: playWidth,
            height: dangerLineY - floorY
        )
        
        let colSpacing: CGFloat = 3.0
        colWidth = (playableRect.width - CGFloat(columnsCount - 1) * colSpacing) / CGFloat(columnsCount)
        rowHeight = colWidth * 0.65
        blockSize = CGSize(width: colWidth, height: rowHeight)
        gridStartX = playableRect.minX + colWidth / 2
    }
    
    private func generateTextures() {
        if GameScene.cachedBearTextures.isEmpty {
            for type in BearType.allCases {
                GameScene.cachedBearTextures[type] = BearType.generateTexture(for: type, size: blockSize)
            }
            GameScene.cachedClearTexture = BearType.generateClearStateTexture(size: blockSize)
        }
    }
    
    // MARK: - Horizontal X-Axis Panoramic Background
    
    private func setupHorizontalPanoramicBackground() {
        bgContainer.zPosition = -100
        addChild(bgContainer)
        
        let sky = SKShapeNode(rectOf: CGSize(width: size.width * 4, height: size.height * 2))
        sky.position = CGPoint(x: size.width / 2, y: size.height / 2)
        sky.fillColor = SKColor(red: 0.35, green: 0.68, blue: 0.94, alpha: 1.0)
        sky.strokeColor = .clear
        bgContainer.addChild(sky)
        
        bgStripWidth = size.width * 2.2
        
        func makeBackgroundStrip(offsetX: CGFloat) -> SKNode {
            let strip = SKNode()
            strip.position = CGPoint(x: offsetX, y: 0)
            
            let hillPath = CGMutablePath()
            hillPath.move(to: CGPoint(x: 0, y: floorY))
            hillPath.addLine(to: CGPoint(x: 0, y: size.height * 0.52))
            hillPath.addQuadCurve(to: CGPoint(x: bgStripWidth * 0.45, y: size.height * 0.58), control: CGPoint(x: bgStripWidth * 0.20, y: size.height * 0.70))
            hillPath.addQuadCurve(to: CGPoint(x: bgStripWidth, y: size.height * 0.45), control: CGPoint(x: bgStripWidth * 0.75, y: size.height * 0.48))
            hillPath.addLine(to: CGPoint(x: bgStripWidth, y: floorY))
            hillPath.closeSubpath()
            let hill = SKShapeNode(path: hillPath)
            hill.fillColor = SKColor(red: 0.52, green: 0.78, blue: 0.35, alpha: 1.0)
            hill.strokeColor = SKColor(red: 0.40, green: 0.68, blue: 0.28, alpha: 1.0)
            hill.lineWidth = 3.0
            strip.addChild(hill)
            
            let hillFace = SKNode()
            hillFace.position = CGPoint(x: bgStripWidth * 0.24, y: size.height * 0.58)
            let leftEye = SKShapeNode(circleOfRadius: 4.0)
            leftEye.position = CGPoint(x: -14, y: 5)
            leftEye.fillColor = SKColor(red: 0.15, green: 0.35, blue: 0.15, alpha: 0.85)
            leftEye.strokeColor = .clear
            hillFace.addChild(leftEye)
            let rightEye = SKShapeNode(circleOfRadius: 4.0)
            rightEye.position = CGPoint(x: 14, y: 5)
            rightEye.fillColor = SKColor(red: 0.15, green: 0.35, blue: 0.15, alpha: 0.85)
            rightEye.strokeColor = .clear
            hillFace.addChild(rightEye)
            let smilePath = CGMutablePath()
            smilePath.move(to: CGPoint(x: -10, y: -4))
            smilePath.addQuadCurve(to: CGPoint(x: 10, y: -4), control: CGPoint(x: 0, y: -12))
            let smile = SKShapeNode(path: smilePath)
            smile.strokeColor = SKColor(red: 0.15, green: 0.35, blue: 0.15, alpha: 0.85)
            smile.lineWidth = 2.2
            hillFace.addChild(smile)
            strip.addChild(hillFace)
            
            for i in 0..<10 {
                let fenceX = bgStripWidth * 0.08 + CGFloat(i) * 24.0
                let fenceY = size.height * 0.46 - CGFloat(i) * 5.0
                let post = SKShapeNode(rectOf: CGSize(width: 4.5, height: 18), cornerRadius: 2)
                post.position = CGPoint(x: fenceX, y: fenceY)
                post.fillColor = SKColor.white.withAlphaComponent(0.85)
                post.strokeColor = .clear
                strip.addChild(post)
            }
            
            addFloatingStar(at: CGPoint(x: bgStripWidth * 0.30, y: size.height * 0.74), scale: 0.9, in: strip)
            addFloatingStar(at: CGPoint(x: bgStripWidth * 0.65, y: size.height * 0.68), scale: 0.7, in: strip)
            addFloatingStar(at: CGPoint(x: bgStripWidth * 0.85, y: size.height * 0.76), scale: 0.8, in: strip)
            
            return strip
        }
        
        bgStrip1 = makeBackgroundStrip(offsetX: 0)
        bgContainer.addChild(bgStrip1)
        
        bgStrip2 = makeBackgroundStrip(offsetX: bgStripWidth)
        bgContainer.addChild(bgStrip2)
    }
    
    private func addFloatingStar(at pos: CGPoint, scale: CGFloat, in parent: SKNode) {
        let star = SKShapeNode()
        let path = CGMutablePath()
        let points = 5
        let rOuter: CGFloat = 22.0 * scale
        let rInner: CGFloat = 11.0 * scale
        for i in 0..<(points * 2) {
            let angle = (CGFloat(i) / CGFloat(points * 2)) * CGFloat.pi * 2 - CGFloat.pi / 2
            let r = (i % 2 == 0) ? rOuter : rInner
            let pt = CGPoint(x: cos(angle) * r, y: sin(angle) * r)
            if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
        }
        path.closeSubpath()
        star.path = path
        star.fillColor = SKColor(red: 0.88, green: 0.92, blue: 0.40, alpha: 0.85)
        star.strokeColor = SKColor(red: 0.75, green: 0.82, blue: 0.25, alpha: 0.9)
        star.lineWidth = 1.5
        star.position = pos
        
        let eyeL = SKShapeNode(circleOfRadius: 2 * scale)
        eyeL.position = CGPoint(x: -4 * scale, y: 2 * scale)
        eyeL.fillColor = SKColor(red: 0.3, green: 0.4, blue: 0.1, alpha: 0.9)
        eyeL.strokeColor = .clear
        star.addChild(eyeL)
        let eyeR = SKShapeNode(circleOfRadius: 2 * scale)
        eyeR.position = CGPoint(x: 4 * scale, y: 2 * scale)
        eyeR.fillColor = SKColor(red: 0.3, green: 0.4, blue: 0.1, alpha: 0.9)
        eyeR.strokeColor = .clear
        star.addChild(eyeR)
        
        let up = SKAction.moveBy(x: 0, y: 6, duration: 1.5)
        let down = SKAction.moveBy(x: 0, y: -6, duration: 1.5)
        star.run(SKAction.repeatForever(SKAction.sequence([up, down])))
        parent.addChild(star)
    }
    
    private func updateHorizontalBackground(dt: TimeInterval) {
        let dx = bgScrollSpeed * CGFloat(dt)
        bgStrip1.position.x -= dx
        bgStrip2.position.x -= dx
        
        if bgStrip1.position.x <= -bgStripWidth {
            bgStrip1.position.x = bgStrip2.position.x + bgStripWidth
        }
        if bgStrip2.position.x <= -bgStripWidth {
            bgStrip2.position.x = bgStrip1.position.x + bgStripWidth
        }
    }
    
    // MARK: - Game Layer Setup
    
    private func setupGameLayer() {
        gameLayer.zPosition = 10
        addChild(gameLayer)
    }
    
    // MARK: - Horizontal X-Axis Infinite Scrolling Grass
    
    private func setupHorizontalScrollingGrass() {
        grassContainer.position = CGPoint(x: 0, y: floorY)
        grassContainer.zPosition = 150
        
        let bushCount = 10
        let bushRadius: CGFloat = 28.0
        grassStripWidth = CGFloat(bushCount) * (bushRadius * 1.6)
        
        func makeBushStrip() -> SKNode {
            let strip = SKNode()
            for i in 0..<bushCount {
                let b = SKShapeNode(circleOfRadius: bushRadius)
                b.position = CGPoint(x: CGFloat(i) * (bushRadius * 1.6), y: 0)
                b.fillColor = SKColor(red: 0.28, green: 0.48, blue: 0.18, alpha: 1.0)
                b.strokeColor = .clear
                strip.addChild(b)
            }
            return strip
        }
        
        grassStrip1 = makeBushStrip()
        grassStrip1.position = CGPoint(x: 0, y: 0)
        grassContainer.addChild(grassStrip1)
        
        grassStrip2 = makeBushStrip()
        grassStrip2.position = CGPoint(x: grassStripWidth, y: 0)
        grassContainer.addChild(grassStrip2)
        
        let grassSkirt = SKShapeNode(rect: CGRect(x: -100, y: -500, width: size.width + 200, height: 500))
        grassSkirt.fillColor = SKColor(red: 0.28, green: 0.48, blue: 0.18, alpha: 1.0)
        grassSkirt.strokeColor = .clear
        grassContainer.addChild(grassSkirt)
        
        addChild(grassContainer)
    }
    
    private func updateHorizontalGrassScroll(dt: TimeInterval) {
        let dx = grassScrollSpeed * CGFloat(dt)
        grassStrip1.position.x -= dx
        grassStrip2.position.x -= dx
        
        if grassStrip1.position.x <= -grassStripWidth {
            grassStrip1.position.x = grassStrip2.position.x + grassStripWidth
        }
        if grassStrip2.position.x <= -grassStripWidth {
            grassStrip2.position.x = grassStrip1.position.x + grassStripWidth
        }
    }
    
    // MARK: - Safe-Area Aware HUD & Bubble Font Styling
    
    private func setupHUD() {
        hudNode.zPosition = 120
        addChild(hudNode)
        
        let hudY = topHUD_Y
        
        levelLabel.horizontalAlignmentMode = .left
        levelLabel.position = CGPoint(x: playableRect.minX + 2, y: hudY)
        hudNode.addChild(levelLabel)
        updateLevelLabel()
        
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: playableRect.minX + 2, y: hudY - 30)
        hudNode.addChild(scoreLabel)
        updateScoreLabel()
        
        let barX = playableRect.minX + 104.0
        let barY = hudY - 16.0
        let barW: CGFloat = 98.0
        let barH: CGFloat = 28.0
        
        let barBg = SKShapeNode(rect: CGRect(x: barX, y: barY, width: barW, height: barH), cornerRadius: 7)
        barBg.fillColor = SKColor(red: 0.35, green: 0.60, blue: 0.90, alpha: 0.9)
        barBg.strokeColor = SKColor.white
        barBg.lineWidth = 3.0
        hudNode.addChild(barBg)
        
        levelProgressBar = SKShapeNode(rect: CGRect(x: barX + 2, y: barY + 2, width: 0, height: barH - 4), cornerRadius: 5)
        levelProgressBar.fillColor = SKColor(red: 1.0, green: 0.78, blue: 0.05, alpha: 1.0)
        levelProgressBar.strokeColor = .clear
        hudNode.addChild(levelProgressBar)
        
        let slot1X = barX + barW + 8.0
        let slot1 = SKShapeNode(rect: CGRect(x: slot1X, y: barY, width: 38, height: barH), cornerRadius: 7)
        slot1.fillColor = SKColor(red: 0.35, green: 0.60, blue: 0.90, alpha: 0.6)
        slot1.strokeColor = SKColor.white
        slot1.lineWidth = 3.0
        hudNode.addChild(slot1)
        
        let slot2 = SKShapeNode(rect: CGRect(x: slot1X + 44.0, y: barY, width: 38, height: barH), cornerRadius: 7)
        slot2.fillColor = SKColor(red: 0.35, green: 0.60, blue: 0.90, alpha: 0.6)
        slot2.strokeColor = SKColor.white
        slot2.lineWidth = 3.0
        hudNode.addChild(slot2)
        
        let pauseBtn = SKShapeNode(circleOfRadius: 16)
        pauseBtn.position = CGPoint(x: playableRect.maxX - 16, y: barY + barH / 2)
        pauseBtn.fillColor = SKColor(red: 0.35, green: 0.60, blue: 0.90, alpha: 0.9)
        pauseBtn.strokeColor = SKColor.white
        pauseBtn.lineWidth = 3.0
        hudNode.addChild(pauseBtn)
        
        let pauseIcon = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        pauseIcon.text = "❚❚"
        pauseIcon.fontSize = 12
        pauseIcon.fontColor = SKColor.white
        pauseIcon.verticalAlignmentMode = .center
        pauseIcon.position = CGPoint(x: playableRect.maxX - 16, y: barY + barH / 2)
        hudNode.addChild(pauseIcon)
    }
    
    private func updateLevelLabel() {
        let text = String(format: "Lv %02d", level)
        levelLabel.attributedText = makeOutlinedBubbleString(text: text, fontSize: 26, fillColor: .white, strokeColor: SKColor(red: 0.08, green: 0.12, blue: 0.28, alpha: 1.0))
    }
    
    private func updateScoreLabel() {
        let text = String(format: "%07d", score)
        scoreLabel.attributedText = makeOutlinedBubbleString(text: text, fontSize: 26, fillColor: .white, strokeColor: SKColor(red: 0.08, green: 0.12, blue: 0.28, alpha: 1.0))
    }
    
    private func makeOutlinedBubbleString(text: String, fontSize: CGFloat, fillColor: SKColor, strokeColor: SKColor) -> NSAttributedString {
        #if os(iOS)
        let font = UIFont(name: "AvenirNext-Heavy", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .black)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: fillColor,
            .strokeColor: strokeColor,
            .strokeWidth: -6.0
        ]
        return NSAttributedString(string: text, attributes: attrs)
        #else
        let font = NSFont(name: "AvenirNext-Heavy", size: fontSize) ?? NSFont.systemFont(ofSize: fontSize, weight: .black)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: fillColor,
            .strokeColor: strokeColor,
            .strokeWidth: -6.0
        ]
        return NSAttributedString(string: text, attributes: attrs)
        #endif
    }
    
    // MARK: - Electric Laser Danger Line (Full-Width, Instant Kill)
    
    private func setupElectricLaserLine() {
        laserGlowNode.strokeColor = SKColor(red: 0.0, green: 0.95, blue: 1.0, alpha: 1.0)
        laserGlowNode.lineWidth = 10.0
        laserGlowNode.glowWidth = 10.0
        laserGlowNode.zPosition = 60
        addChild(laserGlowNode)
        
        laserCoreNode.strokeColor = SKColor.white
        laserCoreNode.lineWidth = 4.5
        laserCoreNode.zPosition = 61
        addChild(laserCoreNode)
        
        updateElectricLaserPath(jitter: false)
    }
    
    private func updateElectricLaserPath(jitter: Bool) {
        let path = CGMutablePath()
        let segments = 26
        let startX: CGFloat = -40.0
        let totalW = size.width + 80.0
        let segW = totalW / CGFloat(segments)
        path.move(to: CGPoint(x: startX, y: dangerLineY))
        
        for i in 1...segments {
            let x = startX + CGFloat(i) * segW
            let amp: CGFloat = (i % 2 == 0) ? 6.5 : -6.5
            let jitterDelta = jitter ? CGFloat.random(in: -3.0...3.0) : 0.0
            let y = dangerLineY + amp + jitterDelta
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        laserGlowNode.path = path
        laserCoreNode.path = path
    }
    
    // MARK: - Game Lifecycle & Start
    
    private func startGame() {
        gameLayer.removeAllChildren()
        gameOverOverlay.removeFromParent()
        gameOverOverlay = SKNode()
        
        for c in 0..<columnsCount {
            columns[c].removeAll()
        }
        
        gameLayer.position = .zero
        let rowStep = blockSize.height + 2.0
        nextSpawnThreshold = rowStep
        
        score = 0
        level = 1
        levelProgress = 0.0
        comboCount = 0
        clearingBlocks.removeAll()
        selectedBlock = nil
        gameState = .playing
        lastUpdateTime = 0
        
        updateLevelProgressBar()
        
        // Spawn 3 buffer rows below (-3, -2, -1) + 4 visible rows (0, 1, 2, 3)
        for r in -3..<4 {
            let y = floorY + blockSize.height / 2 + CGFloat(r) * rowStep
            for c in 0..<columnsCount {
                let x = gridStartX + CGFloat(c) * (colWidth + 3.0)
                guard let randomType = BearType.allCases.randomElement(),
                      let tex = GameScene.cachedBearTextures[randomType],
                      let clearTex = GameScene.cachedClearTexture else { continue }
                
                let block = BearBlockNode(type: randomType, size: blockSize, normalTex: tex, clearTex: clearTex)
                block.position = CGPoint(x: x, y: y)
                gameLayer.addChild(block)
                columns[c].append(block)
            }
        }
    }
    
    // MARK: - Smooth Continuous Rise & Pre-Buffered Deep Spawning (Zero Drop/Twitch)
    
    private func applyRiseOffset(_ dy: CGFloat, isManualDrag: Bool = false) {
        guard gameState == .playing, dy > 0 else { return }
        gameLayer.position.y += dy
        
        if isManualDrag {
            score += Int(dy * 0.5)
        }
        
        let rowStep = blockSize.height + 2.0
        while gameLayer.position.y >= nextSpawnThreshold {
            spawnRowDeepBelow()
            nextSpawnThreshold += rowStep
        }
    }
    
    /// Spawns a new row deep below without modifying any existing blocks' positions!
    private func spawnRowDeepBelow() {
        let rowStep = blockSize.height + 2.0
        
        for c in 0..<columnsCount {
            guard let lowest = columns[c].first else { continue }
            let newY = lowest.position.y - rowStep
            let x = lowest.position.x
            
            guard let randomType = BearType.allCases.randomElement(),
                  let tex = GameScene.cachedBearTextures[randomType],
                  let clearTex = GameScene.cachedClearTexture else { continue }
            
            let block = BearBlockNode(type: randomType, size: blockSize, normalTex: tex, clearTex: clearTex)
            block.position = CGPoint(x: x, y: newY)
            gameLayer.addChild(block)
            columns[c].insert(block, at: 0)
        }
    }
    
    // MARK: - Deterministic Column-Stack Pathfinding (100% Mathematically Solid)
    
    private func findBlockCoordinates(_ block: BearBlockNode) -> (col: Int, row: Int)? {
        for c in 0..<columnsCount {
            if let r = columns[c].firstIndex(of: block) {
                return (c, r)
            }
        }
        return nil
    }
    
    private func isCellFree(col: Int, row: Int, startCol: Int, startRow: Int, targetCol: Int, targetRow: Int) -> Bool {
        if col == startCol && row == startRow { return true }
        if col == targetCol && row == targetRow { return true }
        
        // Perimeter (left, right, bottom, or above column stack) is 100% open
        if col < 0 || col >= columnsCount || row < 0 {
            return true
        }
        if row >= columns[col].count {
            return true
        }
        
        let block = columns[col][row]
        return block.isClearing
    }
    
    private func isStraightLineClear(fromCol: Int, fromRow: Int, toCol: Int, toRow: Int, startCol: Int, startRow: Int, targetCol: Int, targetRow: Int) -> Bool {
        if fromCol == toCol {
            let minR = min(fromRow, toRow)
            let maxR = max(fromRow, toRow)
            if minR + 1 < maxR {
                for r in (minR + 1)..<maxR {
                    if !isCellFree(col: fromCol, row: r, startCol: startCol, startRow: startRow, targetCol: targetCol, targetRow: targetRow) {
                        return false
                    }
                }
            }
            return isCellFree(col: toCol, row: toRow, startCol: startCol, startRow: startRow, targetCol: targetCol, targetRow: targetRow)
        } else if fromRow == toRow {
            let minC = min(fromCol, toCol)
            let maxC = max(fromCol, toCol)
            if minC + 1 < maxC {
                for c in (minC + 1)..<maxC {
                    if !isCellFree(col: c, row: fromRow, startCol: startCol, startRow: startRow, targetCol: targetCol, targetRow: targetRow) {
                        return false
                    }
                }
            }
            return isCellFree(col: toCol, row: toRow, startCol: startCol, startRow: startRow, targetCol: targetCol, targetRow: targetRow)
        }
        return false
    }
    
    private func findLinkPath(from startBlock: BearBlockNode, to targetBlock: BearBlockNode) -> [CGPoint]? {
        guard let (sC, sR) = findBlockCoordinates(startBlock),
              let (tC, tR) = findBlockCoordinates(targetBlock) else { return nil }
        
        let pStart = startBlock.position
        let pTarget = targetBlock.position
        
        var maxStackRow = 4
        for c in 0..<columnsCount {
            maxStackRow = max(maxStackRow, columns[c].count)
        }
        
        // 1. Direct Straight Line (0 Turns)
        if (sC == tC || sR == tR) &&
            isStraightLineClear(fromCol: sC, fromRow: sR, toCol: tC, toRow: tR, startCol: sC, startRow: sR, targetCol: tC, targetRow: tR) {
            return [pStart, pTarget]
        }
        
        // 2. 1 Turn (2 Segments - L-Shape)
        if isCellFree(col: sC, row: tR, startCol: sC, startRow: sR, targetCol: tC, targetRow: tR) &&
            isStraightLineClear(fromCol: sC, fromRow: sR, toCol: sC, toRow: tR, startCol: sC, startRow: sR, targetCol: tC, targetRow: tR) &&
            isStraightLineClear(fromCol: sC, fromRow: tR, toCol: tC, toRow: tR, startCol: sC, startRow: sR, targetCol: tC, targetRow: tR) {
            let pCorner = CGPoint(x: pStart.x, y: pTarget.y)
            return [pStart, pCorner, pTarget]
        }
        
        if isCellFree(col: tC, row: sR, startCol: sC, startRow: sR, targetCol: tC, targetRow: tR) &&
            isStraightLineClear(fromCol: sC, fromRow: sR, toCol: tC, toRow: sR, startCol: sC, startRow: sR, targetCol: tC, targetRow: tR) &&
            isStraightLineClear(fromCol: tC, fromRow: sR, toCol: tC, toRow: tR, startCol: sC, startRow: sR, targetCol: tC, targetRow: tR) {
            let pCorner = CGPoint(x: pTarget.x, y: pStart.y)
            return [pStart, pCorner, pTarget]
        }
        
        // 3. 2 Turns (3 Segments - Z / U Shape along vertical channels)
        for col in -1...columnsCount {
            if isCellFree(col: col, row: sR, startCol: sC, startRow: sR, targetCol: tC, targetRow: tR) &&
                isCellFree(col: col, row: tR, startCol: sC, startRow: sR, targetCol: tC, targetRow: tR) &&
                isStraightLineClear(fromCol: sC, fromRow: sR, toCol: col, toRow: sR, startCol: sC, startRow: sR, targetCol: tC, targetRow: tR) &&
                isStraightLineClear(fromCol: col, fromRow: sR, toCol: col, toRow: tR, startCol: sC, startRow: sR, targetCol: tC, targetRow: tR) &&
                isStraightLineClear(fromCol: col, fromRow: tR, toCol: tC, toRow: tR, startCol: sC, startRow: sR, targetCol: tC, targetRow: tR) {
                
                let channelX: CGFloat
                if col == -1 {
                    channelX = playableRect.minX - 12
                } else if col == columnsCount {
                    channelX = playableRect.maxX + 12
                } else {
                    channelX = gridStartX + CGFloat(col) * (colWidth + 3.0)
                }
                
                let pt1 = CGPoint(x: channelX, y: pStart.y)
                let pt2 = CGPoint(x: channelX, y: pTarget.y)
                return [pStart, pt1, pt2, pTarget]
            }
        }
        
        // 4. 2 Turns (3 Segments - Z / U Shape along horizontal channels / over the top)
        let rowStep = blockSize.height + 2.0
        let topOverY = max(pStart.y, pTarget.y) + rowStep
        for row in -1...(maxStackRow + 2) {
            if isCellFree(col: sC, row: row, startCol: sC, startRow: sR, targetCol: tC, targetRow: tR) &&
                isCellFree(col: tC, row: row, startCol: sC, startRow: sR, targetCol: tC, targetRow: tR) &&
                isStraightLineClear(fromCol: sC, fromRow: sR, toCol: sC, toRow: row, startCol: sC, startRow: sR, targetCol: tC, targetRow: tR) &&
                isStraightLineClear(fromCol: sC, fromRow: row, toCol: tC, toRow: row, startCol: sC, startRow: sR, targetCol: tC, targetRow: tR) &&
                isStraightLineClear(fromCol: tC, fromRow: row, toCol: tC, toRow: tR, startCol: sC, startRow: sR, targetCol: tC, targetRow: tR) {
                
                let channelY: CGFloat
                if row > maxStackRow {
                    channelY = topOverY
                } else {
                    channelY = startBlock.position.y + CGFloat(row - sR) * rowStep
                }
                
                let pt1 = CGPoint(x: pStart.x, y: channelY)
                let pt2 = CGPoint(x: pTarget.x, y: channelY)
                return [pStart, pt1, pt2, pTarget]
            }
        }
        
        return nil
    }
    
    // MARK: - 2-Block Matching Flow & Authentic Combo Badges
    
    private func handleBlockSelection(_ block: BearBlockNode) {
        guard gameState == .playing, !block.isClearing else { return }
        
        guard let first = selectedBlock else {
            selectedBlock = block
            block.isSelected = true
            SoundManager.shared.playSelect()
            triggerHaptic(style: .light)
            return
        }
        
        if first == block {
            first.isSelected = false
            selectedBlock = nil
            SoundManager.shared.playSelect()
            return
        }
        
        if first.bearType != block.bearType {
            first.isSelected = false
            selectedBlock = block
            block.isSelected = true
            SoundManager.shared.playSelect()
            triggerHaptic(style: .light)
            return
        }
        
        if let pathPoints = findLinkPath(from: first, to: block) {
            first.isSelected = false
            selectedBlock = nil
            executeMatchLink(first: first, second: block, path: pathPoints)
        } else {
            let shake = SKAction.sequence([
                SKAction.moveBy(x: -4, y: 0, duration: 0.04),
                SKAction.moveBy(x: 8, y: 0, duration: 0.08),
                SKAction.moveBy(x: -4, y: 0, duration: 0.04)
            ])
            block.run(shake)
            SoundManager.shared.playError()
            triggerHaptic(style: .rigid)
        }
    }
    
    private func executeMatchLink(first: BearBlockNode, second: BearBlockNode, path: [CGPoint]) {
        let now = CACurrentMediaTime()
        
        drawConnectingLine(path: path)
        
        first.enterClearState()
        second.enterClearState()
        clearingBlocks.insert(first)
        clearingBlocks.insert(second)
        
        if now < clearStateEndTime && !clearingBlocks.isEmpty {
            comboCount += 1
        } else {
            comboCount = 1
        }
        
        clearStateEndTime = now + clearDuration
        
        // Pop sound + Glockenspiel/Prestige sound
        SoundManager.shared.playPop()
        SoundManager.shared.playCombo(index: comboCount)
        
        let baseGain = 100
        let totalGain = baseGain * comboCount
        score += totalGain
        
        levelProgress += 0.08
        if levelProgress >= 1.0 {
            levelProgress = 0.0
            level += 1
            showFloatingLevelUpBadge()
        }
        updateLevelProgressBar()
        
        let midX = (path.first!.x + path.last!.x) / 2
        let midY = (path.first!.y + path.last!.y) / 2
        showAuthenticComboBadge(combo: comboCount, scoreGain: totalGain, at: CGPoint(x: midX, y: midY))
        
        triggerHaptic(style: .medium)
    }
    
    private func drawConnectingLine(path points: [CGPoint]) {
        guard points.count >= 2 else { return }
        
        let linePath = CGMutablePath()
        linePath.move(to: points.first!)
        for pt in points.dropFirst() {
            linePath.addLine(to: pt)
        }
        
        let lineNode = SKShapeNode(path: linePath)
        lineNode.strokeColor = SKColor.white
        lineNode.lineWidth = 7.5
        lineNode.lineCap = .round
        lineNode.lineJoin = .round
        lineNode.glowWidth = 4.0
        lineNode.zPosition = 85
        gameLayer.addChild(lineNode)
        
        let wait = SKAction.wait(forDuration: 0.35)
        let fade = SKAction.fadeOut(withDuration: 0.25)
        lineNode.run(SKAction.sequence([wait, fade, SKAction.removeFromParent()]))
    }
    
    private func showAuthenticComboBadge(combo: Int, scoreGain: Int, at pos: CGPoint) {
        let badgeContainer = SKNode()
        badgeContainer.position = pos
        badgeContainer.zPosition = 95
        
        let strokeNavy = SKColor(red: 0.08, green: 0.12, blue: 0.28, alpha: 1.0)
        
        if combo > 1 {
            let comboLabel = SKLabelNode()
            comboLabel.attributedText = makeOutlinedBubbleString(
                text: "\(combo)x",
                fontSize: 34,
                fillColor: SKColor(red: 1.0, green: 0.78, blue: 0.05, alpha: 1.0),
                strokeColor: strokeNavy
            )
            comboLabel.position = CGPoint(x: 0, y: 14)
            badgeContainer.addChild(comboLabel)
            
            let scoreGainLabel = SKLabelNode()
            scoreGainLabel.attributedText = makeOutlinedBubbleString(
                text: "\(scoreGain)",
                fontSize: 26,
                fillColor: SKColor.white,
                strokeColor: strokeNavy
            )
            scoreGainLabel.position = CGPoint(x: 0, y: -18)
            badgeContainer.addChild(scoreGainLabel)
        } else {
            let singleLabel = SKLabelNode()
            singleLabel.attributedText = makeOutlinedBubbleString(
                text: "\(scoreGain)",
                fontSize: 28,
                fillColor: SKColor.white,
                strokeColor: strokeNavy
            )
            singleLabel.position = CGPoint(x: 0, y: 0)
            badgeContainer.addChild(singleLabel)
        }
        
        gameLayer.addChild(badgeContainer)
        
        badgeContainer.setScale(0.5)
        let popIn = SKAction.scale(to: 1.25, duration: 0.12)
        popIn.timingMode = .easeOut
        let settle = SKAction.scale(to: 1.0, duration: 0.08)
        let floatUp = SKAction.moveBy(x: 0, y: 35, duration: 0.65)
        let fadeOut = SKAction.fadeOut(withDuration: 0.65)
        
        badgeContainer.run(SKAction.sequence([
            SKAction.sequence([popIn, settle]),
            SKAction.group([floatUp, fadeOut]),
            SKAction.removeFromParent()
        ]))
    }
    
    private func showFloatingLevelUpBadge() {
        let badge = SKLabelNode()
        badge.attributedText = makeOutlinedBubbleString(
            text: "LEVEL UP!",
            fontSize: 32,
            fillColor: SKColor(red: 1.0, green: 0.90, blue: 0.20, alpha: 1.0),
            strokeColor: SKColor(red: 0.08, green: 0.12, blue: 0.28, alpha: 1.0)
        )
        badge.position = CGPoint(x: size.width / 2, y: size.height * 0.55)
        badge.zPosition = 96
        gameLayer.addChild(badge)
        
        let pop = SKAction.scale(to: 1.3, duration: 0.15)
        let move = SKAction.moveBy(x: 0, y: 30, duration: 0.7)
        let fade = SKAction.fadeOut(withDuration: 0.7)
        badge.run(SKAction.sequence([pop, SKAction.group([move, fade]), SKAction.removeFromParent()]))
    }
    
    private func updateLevelProgressBar() {
        let barX = playableRect.minX + 104.0 + 2.0
        let barY = topHUD_Y - 16.0 + 2.0
        let barMaxW: CGFloat = 98.0 - 4.0
        let barH: CGFloat = 28.0 - 4.0
        let currentW = barMaxW * min(1.0, levelProgress)
        
        let path = CGMutablePath()
        path.addRoundedRect(in: CGRect(x: barX, y: barY, width: currentW, height: barH), cornerWidth: 4, cornerHeight: 4)
        levelProgressBar.path = path
    }
    
    // MARK: - Game Loop
    
    override func update(_ currentTime: TimeInterval) {
        guard gameState == .playing else { return }
        
        let dt = (lastUpdateTime > 0) ? min(currentTime - lastUpdateTime, 0.1) : (1.0 / 60.0)
        lastUpdateTime = currentTime
        
        // 1. Horizontal Panoramic Background & Grass Scrolling (X-Axis)
        updateHorizontalBackground(dt: dt)
        updateHorizontalGrassScroll(dt: dt)
        
        // 2. Continuous Upward Rise (PAUSED during active Clear State!)
        let isClearing = !clearingBlocks.isEmpty
        if !isClearing {
            let currentSpeed = baseRiseSpeed + Double(level - 1) * 1.5
            let autoRise = CGFloat(currentSpeed * dt)
            applyRiseOffset(autoRise, isManualDrag: false)
        }
        
        // 3. Animate Crackling Laser Danger Line
        if currentTime - lastLaserJitterTime > 0.06 {
            lastLaserJitterTime = currentTime
            updateElectricLaserPath(jitter: true)
        }
        
        // 4. Clear State Expiration -> Pop particles & smooth downward fall!
        if isClearing && CACurrentMediaTime() >= clearStateEndTime {
            finalizeClearingBlocks()
        }
        
        // 5. Instant Kill on Laser Line Contact
        for c in 0..<columnsCount {
            for b in columns[c] {
                if !b.isClearing {
                    let worldY = gameLayer.convert(b.position, to: self).y
                    if (worldY + blockSize.height * 0.45) >= dangerLineY {
                        triggerGameOver()
                        return
                    }
                }
            }
        }
    }
    
    private func finalizeClearingBlocks() {
        let blocksToPop = clearingBlocks
        clearingBlocks.removeAll()
        comboCount = 0
        
        SoundManager.shared.playPop()
        
        for block in blocksToPop {
            createPopParticles(at: block.position, color: block.bearType.primaryColor)
            block.popAndRemove { }
        }
        
        let rowStep = blockSize.height + 2.0
        
        // Smoothly drop only the blocks situated above the popped gaps!
        for c in 0..<columnsCount {
            var clearedBelowCount = 0
            var newColumn: [BearBlockNode] = []
            
            for block in columns[c] {
                if blocksToPop.contains(block) {
                    clearedBelowCount += 1
                } else {
                    newColumn.append(block)
                    if clearedBelowCount > 0 {
                        let targetY = block.position.y - CGFloat(clearedBelowCount) * rowStep
                        let fall = SKAction.moveTo(y: targetY, duration: 0.16)
                        fall.timingMode = .easeIn
                        let bounce = SKAction.sequence([
                            SKAction.moveBy(x: 0, y: -2.5, duration: 0.04),
                            SKAction.moveBy(x: 0, y: 2.5, duration: 0.04)
                        ])
                        block.run(SKAction.sequence([fall, bounce]))
                    }
                }
            }
            columns[c] = newColumn
        }
    }
    
    private func createPopParticles(at pos: CGPoint, color: SKColor) {
        for i in 0..<8 {
            let angle = (CGFloat(i) / 8.0) * CGFloat.pi * 2.0
            let shard = SKShapeNode(rectOf: CGSize(width: 8, height: 8), cornerRadius: 2)
            shard.fillColor = color
            shard.strokeColor = SKColor.white
            shard.lineWidth = 1.0
            shard.position = pos
            shard.zPosition = 80
            gameLayer.addChild(shard)
            
            let dx = cos(angle) * 35.0
            let dy = sin(angle) * 35.0 + 15.0
            let move = SKAction.moveBy(x: dx, y: dy, duration: 0.25)
            let fade = SKAction.fadeOut(withDuration: 0.25)
            let scale = SKAction.scale(to: 0.1, duration: 0.25)
            
            shard.run(SKAction.sequence([SKAction.group([move, fade, scale]), SKAction.removeFromParent()]))
        }
    }
    
    // MARK: - Game Over
    
    private func triggerGameOver() {
        guard gameState == .playing else { return }
        gameState = .gameOver
        selectedBlock = nil
        triggerHaptic(style: .heavy)
        SoundManager.shared.playError()
        
        gameOverOverlay = SKNode()
        gameOverOverlay.zPosition = 200
        addChild(gameOverOverlay)
        
        let dim = SKShapeNode(rectOf: size)
        dim.position = CGPoint(x: size.width / 2, y: size.height / 2)
        dim.fillColor = SKColor.black.withAlphaComponent(0.75)
        dim.strokeColor = .clear
        gameOverOverlay.addChild(dim)
        
        let card = SKShapeNode(rectOf: CGSize(width: playableRect.width * 0.88, height: 260), cornerRadius: 20)
        card.position = CGPoint(x: size.width / 2, y: size.height / 2)
        card.fillColor = SKColor(red: 0.16, green: 0.20, blue: 0.32, alpha: 0.95)
        card.strokeColor = SKColor(red: 1.0, green: 0.35, blue: 0.45, alpha: 0.9)
        card.lineWidth = 3.0
        gameOverOverlay.addChild(card)
        
        let goLabel = SKLabelNode()
        goLabel.attributedText = makeOutlinedBubbleString(text: "GAME OVER", fontSize: 32, fillColor: SKColor(red: 1.0, green: 0.35, blue: 0.45, alpha: 1.0), strokeColor: .black)
        goLabel.position = CGPoint(x: 0, y: 70)
        card.addChild(goLabel)
        
        let fScore = SKLabelNode()
        fScore.attributedText = makeOutlinedBubbleString(text: "FINAL SCORE: \(score)", fontSize: 22, fillColor: .white, strokeColor: .black)
        fScore.position = CGPoint(x: 0, y: 25)
        card.addChild(fScore)
        
        let fLevel = SKLabelNode()
        fLevel.attributedText = makeOutlinedBubbleString(text: "LEVEL: \(level)", fontSize: 18, fillColor: SKColor(red: 1.0, green: 0.85, blue: 0.2, alpha: 1.0), strokeColor: .black)
        fLevel.position = CGPoint(x: 0, y: -8)
        card.addChild(fLevel)
        
        let btn = SKShapeNode(rect: CGRect(x: -85, y: -82, width: 170, height: 46), cornerRadius: 14)
        btn.name = "restart_button"
        btn.fillColor = SKColor(red: 0.25, green: 0.75, blue: 0.45, alpha: 1.0)
        btn.strokeColor = SKColor.white
        btn.lineWidth = 2.0
        card.addChild(btn)
        
        let btnText = SKLabelNode()
        btnText.name = "restart_button"
        btnText.attributedText = makeOutlinedBubbleString(text: "PLAY AGAIN", fontSize: 18, fillColor: .white, strokeColor: SKColor(red: 0.1, green: 0.35, blue: 0.15, alpha: 1.0))
        btnText.position = CGPoint(x: 0, y: -65)
        card.addChild(btnText)
    }
    
    // MARK: - Touch Handling & Interactive Drag-Up
    
    private func handleTouchBegan(at location: CGPoint) {
        if gameState == .gameOver {
            let tapped = nodes(at: location)
            if tapped.contains(where: { $0.name == "restart_button" }) || location.y < size.height * 0.65 {
                startGame()
            }
            return
        }
        touchStartLocation = location
        lastTouchLocation = location
        isDraggingBoard = false
        totalDragDeltaY = 0
    }
    
    private func handleTouchMoved(at location: CGPoint) {
        guard gameState == .playing, let last = lastTouchLocation else { return }
        let dy = location.y - last.y
        if dy > 0 {
            totalDragDeltaY += dy
            if totalDragDeltaY > 8.0 {
                isDraggingBoard = true
                applyRiseOffset(dy, isManualDrag: true)
            }
        }
        lastTouchLocation = location
    }
    
    private func handleTouchEnded(at location: CGPoint) {
        guard gameState == .playing else { return }
        
        if !isDraggingBoard {
            let localPoint = convert(location, to: gameLayer)
            let tappedNodes = gameLayer.nodes(at: localPoint)
            if let block = tappedNodes.compactMap({ $0 as? BearBlockNode }).first {
                handleBlockSelection(block)
            }
        }
        
        touchStartLocation = nil
        lastTouchLocation = nil
        isDraggingBoard = false
        totalDragDeltaY = 0
    }
    
    #if os(iOS) || os(tvOS) || os(visionOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        handleTouchBegan(at: touch.location(in: self))
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        handleTouchMoved(at: touch.location(in: self))
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        handleTouchEnded(at: touch.location(in: self))
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchStartLocation = nil
        lastTouchLocation = nil
        isDraggingBoard = false
    }
    #elseif os(macOS)
    override func mouseDown(with event: NSEvent) {
        handleTouchBegan(at: event.location(in: self))
    }
    override func mouseDragged(with event: NSEvent) {
        handleTouchMoved(at: event.location(in: self))
    }
    override func mouseUp(with event: NSEvent) {
        handleTouchEnded(at: event.location(in: self))
    }
    #endif
    
    // MARK: - Haptic Helper
    
    enum HapticStyle { case light, medium, heavy, rigid }
    private func triggerHaptic(style: HapticStyle) {
        #if os(iOS)
        let uiStyle: UIImpactFeedbackGenerator.FeedbackStyle
        switch style {
        case .light: uiStyle = .light
        case .medium: uiStyle = .medium
        case .heavy: uiStyle = .heavy
        case .rigid: uiStyle = .rigid
        }
        let generator = UIImpactFeedbackGenerator(style: uiStyle)
        generator.prepare()
        generator.impactOccurred()
        #endif
    }
}
