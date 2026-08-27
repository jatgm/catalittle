//
//  GameScene.swift
//  Catalittle
//
//  A complete, faithful clone of "Bearalot" / "Bear Links" built in Swift & SpriteKit.
//  Features:
//  - Smooth continuous rising stack with real-time interactive drag-up.
//  - 2-block link matching (Onet / Lianliankan pathfinding with <= 2 turns).
//  - Clear state delays allowing connection routing straight through clearing blocks.
//  - Multiplier combos (2x, 3x...), authentic custom vector characters, and HUD.
//

import SpriteKit
import GameplayKit
import CoreGraphics
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - Bear / Character Types (Matches Screenshots Exactly)

enum BearType: Int, CaseIterable {
    case pinkBear = 0     // Pink bear with round ears & cute snout
    case greenLass        // Green pill with hair ribbon & lashes
    case orangeJoy        // Orange pill with wide open laughing mouth
    case cyanPeach        // Split peach/cyan with big round nose
    case redMustache      // Red/coral pill with black mustache
    case limeFrog         // Lime green with wide-set dot eyes & smile
    case yellowStar       // Bright yellow star/cat with anime sparkle eyes
    
    var primaryColor: SKColor {
        switch self {
        case .pinkBear:     return SKColor(red: 1.0, green: 0.72, blue: 0.80, alpha: 1.0)
        case .greenLass:    return SKColor(red: 0.32, green: 0.82, blue: 0.40, alpha: 1.0)
        case .orangeJoy:    return SKColor(red: 1.0, green: 0.65, blue: 0.18, alpha: 1.0)
        case .cyanPeach:    return SKColor(red: 0.35, green: 0.85, blue: 0.95, alpha: 1.0)
        case .redMustache:  return SKColor(red: 1.0, green: 0.45, blue: 0.48, alpha: 1.0)
        case .limeFrog:     return SKColor(red: 0.62, green: 0.94, blue: 0.22, alpha: 1.0)
        case .yellowStar:   return SKColor(red: 1.0, green: 0.92, blue: 0.25, alpha: 1.0)
        }
    }
    
    /// Generates high-resolution vector texture for each character block.
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
        let cornerRadius: CGFloat = h * 0.42
        
        let bodyRect = CGRect(x: 2, y: 2, width: w - 4, height: h - 4)
        let bodyPath = CGPath(roundedRect: bodyRect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
        
        switch type {
        case .pinkBear:
            // Ears at top corners
            let earR: CGFloat = h * 0.22
            ctx.setFillColor(SKColor(red: 1.0, green: 0.65, blue: 0.75, alpha: 1.0).cgColor)
            ctx.fillEllipse(in: CGRect(x: w * 0.08, y: h * 0.60, width: earR * 2, height: earR * 2))
            ctx.fillEllipse(in: CGRect(x: w * 0.92 - earR * 2, y: h * 0.60, width: earR * 2, height: earR * 2))
            
            // Body
            ctx.setFillColor(type.primaryColor.cgColor)
            ctx.addPath(bodyPath)
            ctx.fillPath()
            
            // Eyes
            ctx.setFillColor(SKColor(red: 0.15, green: 0.1, blue: 0.15, alpha: 1.0).cgColor)
            let eyeR: CGFloat = h * 0.08
            ctx.fillEllipse(in: CGRect(x: w * 0.32 - eyeR, y: h * 0.50 - eyeR, width: eyeR * 2, height: eyeR * 2))
            ctx.fillEllipse(in: CGRect(x: w * 0.68 - eyeR, y: h * 0.50 - eyeR, width: eyeR * 2, height: eyeR * 2))
            
            // Eye gleam
            ctx.setFillColor(SKColor.white.cgColor)
            ctx.fillEllipse(in: CGRect(x: w * 0.30 - eyeR * 0.3, y: h * 0.52, width: eyeR * 0.8, height: eyeR * 0.8))
            ctx.fillEllipse(in: CGRect(x: w * 0.66 - eyeR * 0.3, y: h * 0.52, width: eyeR * 0.8, height: eyeR * 0.8))
            
            // Rosy cheeks
            ctx.setFillColor(SKColor(red: 1.0, green: 0.45, blue: 0.6, alpha: 0.45).cgColor)
            ctx.fillEllipse(in: CGRect(x: w * 0.18, y: h * 0.38, width: h * 0.22, height: h * 0.18))
            ctx.fillEllipse(in: CGRect(x: w * 0.82 - h * 0.22, y: h * 0.38, width: h * 0.22, height: h * 0.18))
            
            // Upside-down 'Y' mouth
            ctx.setStrokeColor(SKColor(red: 0.2, green: 0.1, blue: 0.2, alpha: 1.0).cgColor)
            ctx.setLineWidth(2.0)
            ctx.setLineCap(.round)
            ctx.move(to: CGPoint(x: w * 0.5, y: h * 0.45))
            ctx.addLine(to: CGPoint(x: w * 0.5, y: h * 0.34))
            ctx.move(to: CGPoint(x: w * 0.5, y: h * 0.34))
            ctx.addLine(to: CGPoint(x: w * 0.42, y: h * 0.24))
            ctx.move(to: CGPoint(x: w * 0.5, y: h * 0.34))
            ctx.addLine(to: CGPoint(x: w * 0.58, y: h * 0.24))
            ctx.strokePath()
            
        case .greenLass:
            // Body
            ctx.setFillColor(type.primaryColor.cgColor)
            ctx.addPath(bodyPath)
            ctx.fillPath()
            
            // Hair ribbon / parting at top
            ctx.setStrokeColor(SKColor(red: 0.15, green: 0.45, blue: 0.2, alpha: 1.0).cgColor)
            ctx.setLineWidth(2.2)
            ctx.move(to: CGPoint(x: w * 0.30, y: h * 0.85))
            ctx.addQuadCurve(to: CGPoint(x: w * 0.50, y: h * 0.65), control: CGPoint(x: w * 0.40, y: h * 0.75))
            ctx.addQuadCurve(to: CGPoint(x: w * 0.70, y: h * 0.85), control: CGPoint(x: w * 0.60, y: h * 0.75))
            ctx.strokePath()
            
            // Eyes with eyelashes
            ctx.setStrokeColor(SKColor(red: 0.1, green: 0.25, blue: 0.15, alpha: 1.0).cgColor)
            ctx.setLineWidth(2.0)
            ctx.move(to: CGPoint(x: w * 0.28, y: h * 0.46))
            ctx.addQuadCurve(to: CGPoint(x: w * 0.38, y: h * 0.46), control: CGPoint(x: w * 0.33, y: h * 0.56))
            ctx.move(to: CGPoint(x: w * 0.62, y: h * 0.46))
            ctx.addQuadCurve(to: CGPoint(x: w * 0.72, y: h * 0.46), control: CGPoint(x: w * 0.67, y: h * 0.56))
            ctx.move(to: CGPoint(x: w * 0.72, y: h * 0.48))
            ctx.addLine(to: CGPoint(x: w * 0.77, y: h * 0.52))
            ctx.strokePath()
            
            // Smile
            ctx.move(to: CGPoint(x: w * 0.44, y: h * 0.30))
            ctx.addQuadCurve(to: CGPoint(x: w * 0.56, y: h * 0.30), control: CGPoint(x: w * 0.50, y: h * 0.22))
            ctx.strokePath()
            
        case .orangeJoy:
            // Body
            ctx.setFillColor(type.primaryColor.cgColor)
            ctx.addPath(bodyPath)
            ctx.fillPath()
            
            // Arched happy closed eyes `^ ^`
            ctx.setStrokeColor(SKColor(red: 0.25, green: 0.12, blue: 0.05, alpha: 1.0).cgColor)
            ctx.setLineWidth(2.5)
            ctx.setLineCap(.round)
            ctx.move(to: CGPoint(x: w * 0.24, y: h * 0.58))
            ctx.addQuadCurve(to: CGPoint(x: w * 0.40, y: h * 0.58), control: CGPoint(x: w * 0.32, y: h * 0.74))
            ctx.move(to: CGPoint(x: w * 0.60, y: h * 0.58))
            ctx.addQuadCurve(to: CGPoint(x: w * 0.76, y: h * 0.58), control: CGPoint(x: w * 0.68, y: h * 0.74))
            ctx.strokePath()
            
            // Big open laughing mouth
            let mouthRect = CGRect(x: w * 0.30, y: h * 0.16, width: w * 0.40, height: h * 0.38)
            let mouthPath = CGPath(roundedRect: mouthRect, cornerWidth: h * 0.18, cornerHeight: h * 0.18, transform: nil)
            ctx.setFillColor(SKColor(red: 0.90, green: 0.22, blue: 0.15, alpha: 1.0).cgColor)
            ctx.addPath(mouthPath)
            ctx.fillPath()
            ctx.setStrokeColor(SKColor(red: 0.25, green: 0.12, blue: 0.05, alpha: 1.0).cgColor)
            ctx.setLineWidth(2.0)
            ctx.addPath(mouthPath)
            ctx.strokePath()
            
            // Tongue inside mouth
            ctx.saveGState()
            ctx.addPath(mouthPath)
            ctx.clip()
            ctx.setFillColor(SKColor(red: 1.0, green: 0.55, blue: 0.65, alpha: 1.0).cgColor)
            ctx.fillEllipse(in: CGRect(x: w * 0.35, y: h * 0.10, width: w * 0.30, height: h * 0.25))
            ctx.restoreGState()
            
        case .cyanPeach:
            // Split Body: Bottom Cyan, Top Peach
            ctx.saveGState()
            ctx.addPath(bodyPath)
            ctx.clip()
            ctx.setFillColor(SKColor(red: 1.0, green: 0.82, blue: 0.72, alpha: 1.0).cgColor)
            ctx.fill(CGRect(x: 0, y: h * 0.46, width: w, height: h * 0.54))
            ctx.setFillColor(SKColor(red: 0.30, green: 0.88, blue: 0.95, alpha: 1.0).cgColor)
            ctx.fill(CGRect(x: 0, y: 0, width: w, height: h * 0.46))
            ctx.restoreGState()
            
            // Big bulbous nose in the middle
            let noseRect = CGRect(x: w * 0.40, y: h * 0.36, width: w * 0.20, height: h * 0.26)
            ctx.setFillColor(SKColor(red: 1.0, green: 0.68, blue: 0.58, alpha: 1.0).cgColor)
            ctx.fillEllipse(in: noseRect)
            ctx.setStrokeColor(SKColor(red: 0.2, green: 0.15, blue: 0.15, alpha: 1.0).cgColor)
            ctx.setLineWidth(1.8)
            ctx.strokeEllipse(in: noseRect)
            
            // Eyes
            let eyeY = h * 0.64
            ctx.setFillColor(SKColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0).cgColor)
            ctx.fillEllipse(in: CGRect(x: w * 0.30, y: eyeY, width: 4.5, height: 4.5))
            ctx.fillEllipse(in: CGRect(x: w * 0.66, y: eyeY, width: 4.5, height: 4.5))
            
            // Raised eyebrow
            ctx.setStrokeColor(SKColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0).cgColor)
            ctx.setLineWidth(1.8)
            ctx.move(to: CGPoint(x: w * 0.26, y: eyeY + 8))
            ctx.addLine(to: CGPoint(x: w * 0.36, y: eyeY + 12))
            ctx.strokePath()
            
            // Side smirk
            ctx.move(to: CGPoint(x: w * 0.56, y: h * 0.26))
            ctx.addQuadCurve(to: CGPoint(x: w * 0.68, y: h * 0.32), control: CGPoint(x: w * 0.62, y: h * 0.24))
            ctx.strokePath()
            
        case .redMustache:
            // Body
            ctx.setFillColor(type.primaryColor.cgColor)
            ctx.addPath(bodyPath)
            ctx.fillPath()
            
            // Eyes
            ctx.setFillColor(SKColor(red: 0.15, green: 0.1, blue: 0.15, alpha: 1.0).cgColor)
            let eyeR: CGFloat = h * 0.08
            ctx.fillEllipse(in: CGRect(x: w * 0.32 - eyeR, y: h * 0.60 - eyeR, width: eyeR * 2, height: eyeR * 2))
            ctx.fillEllipse(in: CGRect(x: w * 0.68 - eyeR, y: h * 0.60 - eyeR, width: eyeR * 2, height: eyeR * 2))
            
            // Big black mustache
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
            // Body
            ctx.setFillColor(type.primaryColor.cgColor)
            ctx.addPath(bodyPath)
            ctx.fillPath()
            
            // Wide-set small black dot eyes with white gleam
            let eyeY = h * 0.54
            ctx.setFillColor(SKColor(red: 0.1, green: 0.2, blue: 0.1, alpha: 1.0).cgColor)
            ctx.fillEllipse(in: CGRect(x: w * 0.20, y: eyeY, width: 6.0, height: 6.0))
            ctx.fillEllipse(in: CGRect(x: w * 0.76, y: eyeY, width: 6.0, height: 6.0))
            ctx.setFillColor(SKColor.white.cgColor)
            ctx.fillEllipse(in: CGRect(x: w * 0.22, y: eyeY + 2.5, width: 2.5, height: 2.5))
            ctx.fillEllipse(in: CGRect(x: w * 0.78, y: eyeY + 2.5, width: 2.5, height: 2.5))
            
            // Cute gentle smile
            ctx.setStrokeColor(SKColor(red: 0.1, green: 0.25, blue: 0.1, alpha: 1.0).cgColor)
            ctx.setLineWidth(2.0)
            ctx.move(to: CGPoint(x: w * 0.38, y: h * 0.32))
            ctx.addQuadCurve(to: CGPoint(x: w * 0.62, y: h * 0.32), control: CGPoint(x: w * 0.50, y: h * 0.22))
            ctx.strokePath()
            
        case .yellowStar:
            // Pointed cat/star corners at top
            let earPath = CGMutablePath()
            earPath.move(to: CGPoint(x: w * 0.12, y: h * 0.70))
            earPath.addLine(to: CGPoint(x: w * 0.20, y: h * 0.95))
            earPath.addLine(to: CGPoint(x: w * 0.34, y: h * 0.80))
            earPath.move(to: CGPoint(x: w * 0.88, y: h * 0.70))
            earPath.addLine(to: CGPoint(x: w * 0.80, y: h * 0.95))
            earPath.addLine(to: CGPoint(x: w * 0.66, y: h * 0.80))
            ctx.setFillColor(type.primaryColor.cgColor)
            ctx.addPath(earPath)
            ctx.fillPath()
            
            // Body
            ctx.addPath(bodyPath)
            ctx.fillPath()
            
            // Anime sparkling kawaii eyes (2 gleams each)
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
            
            // Open 'o' mouth
            ctx.setFillColor(SKColor(red: 0.95, green: 0.3, blue: 0.4, alpha: 1.0).cgColor)
            ctx.fillEllipse(in: CGRect(x: w * 0.46, y: h * 0.26, width: w * 0.08, height: h * 0.14))
        }
        
        // Dark crisp border stroke around pill
        ctx.setStrokeColor(SKColor(red: 0.12, green: 0.15, blue: 0.18, alpha: 0.9).cgColor)
        ctx.setLineWidth(2.2)
        ctx.addPath(bodyPath)
        ctx.strokePath()
        
        // 3D Top Highlight
        ctx.saveGState()
        ctx.addPath(bodyPath)
        ctx.clip()
        let highlightRect = CGRect(x: 4, y: h * 0.55, width: w - 8, height: h * 0.35)
        let highlightPath = CGPath(roundedRect: highlightRect, cornerWidth: cornerRadius * 0.6, cornerHeight: cornerRadius * 0.6, transform: nil)
        ctx.setFillColor(SKColor(white: 1.0, alpha: 0.32).cgColor)
        ctx.addPath(highlightPath)
        ctx.fillPath()
        ctx.restoreGState()
        
        guard let cgImage = ctx.makeImage() else { return SKTexture() }
        return SKTexture(cgImage: cgImage)
    }
    
    /// Generates the glowing cream-yellow capsule texture used when in the Clear State!
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
        let cornerRadius: CGFloat = h * 0.42
        
        let bodyRect = CGRect(x: 2, y: 2, width: w - 4, height: h - 4)
        let bodyPath = CGPath(roundedRect: bodyRect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
        
        // Soft cream/white filling
        ctx.setFillColor(SKColor(red: 1.0, green: 0.99, blue: 0.88, alpha: 1.0).cgColor)
        ctx.addPath(bodyPath)
        ctx.fillPath()
        
        // Glowing bright golden yellow border
        ctx.setStrokeColor(SKColor(red: 1.0, green: 0.90, blue: 0.20, alpha: 1.0).cgColor)
        ctx.setLineWidth(3.5)
        ctx.addPath(bodyPath)
        ctx.strokePath()
        
        guard let cgImage = ctx.makeImage() else { return SKTexture() }
        return SKTexture(cgImage: cgImage)
    }
}

// MARK: - Physics Category Bitmasks

struct PhysicsCategory {
    static let none: UInt32      = 0
    static let block: UInt32     = 0x1 << 0
    static let wall: UInt32      = 0x1 << 1
    static let floor: UInt32     = 0x1 << 2
}

// MARK: - Grid Point Struct for Pathfinding

struct GridPoint: Hashable, CustomStringConvertible {
    var col: Int
    var row: Int
    var description: String { "(\(col), \(row))" }
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
        
        setupPhysics(size: size)
        setupSelectionBorder(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPhysics(size: CGSize) {
        let physicsSize = CGSize(width: size.width - 2.0, height: size.height - 2.0)
        let body = SKPhysicsBody(rectangleOf: physicsSize)
        body.allowsRotation = false
        body.restitution = 0.0
        body.friction = 0.15
        body.linearDamping = 0.7
        body.mass = 0.12
        
        body.categoryBitMask = PhysicsCategory.block
        body.collisionBitMask = PhysicsCategory.block | PhysicsCategory.wall | PhysicsCategory.floor
        body.contactTestBitMask = PhysicsCategory.block
        self.physicsBody = body
    }
    
    private func setupSelectionBorder(size: CGSize) {
        let border = SKShapeNode(rectOf: CGSize(width: size.width + 4, height: size.height + 4), cornerRadius: size.height * 0.42)
        border.strokeColor = SKColor.white
        border.lineWidth = 3.0
        border.fillColor = SKColor.white.withAlphaComponent(0.25)
        border.zPosition = 10
        border.isHidden = true
        
        let pulseUp = SKAction.scale(to: 1.08, duration: 0.2)
        let pulseDown = SKAction.scale(to: 0.95, duration: 0.2)
        border.run(SKAction.repeatForever(SKAction.sequence([pulseUp, pulseDown])))
        
        addChild(border)
        self.selectionBorder = border
    }
    
    /// Switches to the glowing cream capsule clear-state texture and stays solid.
    func enterClearState() {
        guard !isClearing else { return }
        isClearing = true
        isSelected = false
        self.texture = clearTexture
        self.physicsBody?.isDynamic = false
        
        let grow = SKAction.scale(to: 1.06, duration: 0.25)
        let shrink = SKAction.scale(to: 0.96, duration: 0.25)
        self.run(SKAction.repeatForever(SKAction.sequence([grow, shrink])), withKey: "clear_pulse")
    }
    
    /// Pops with scaling and removes from scene so blocks above can drop.
    func popAndRemove(completion: @escaping () -> Void) {
        self.removeAction(forKey: "clear_pulse")
        self.physicsBody = nil
        
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

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Grid & Dimensions
    private let columnsCount: Int = 7
    private var blockSize: CGSize = .zero
    private var playableRect: CGRect = .zero
    private var floorY: CGFloat = 0
    private var dangerLineY: CGFloat = 0
    private var colWidth: CGFloat = 0
    private var rowHeight: CGFloat = 0
    private var gridStartX: CGFloat = 0
    
    // MARK: - Smooth Scroll & Container Layer
    private var gameLayer = SKNode()
    private var floorNode = SKNode()
    private var spawnedBelowCount: Int = 0
    private var nextSpawnThreshold: CGFloat = 0
    private var baseRiseSpeed: Double = 14.0 // Continuous rising speed in points/sec
    private var lastUpdateTime: TimeInterval = 0
    
    // MARK: - Selection & Clear State
    private var selectedBlock: BearBlockNode? = nil
    private var clearingBlocks = Set<BearBlockNode>()
    private var clearStateEndTime: TimeInterval = 0
    private let clearDuration: TimeInterval = 1.75
    
    // MARK: - Game State & Score
    private var gameState: GameState = .ready
    private var score: Int = 0 {
        didSet {
            scoreLabel.text = String(format: "%07d", score)
        }
    }
    private var level: Int = 1 {
        didSet {
            levelLabel.text = String(format: "Lv %02d", level)
        }
    }
    private var levelProgress: CGFloat = 0.0
    private var comboCount: Int = 0
    
    // MARK: - Danger Line
    private var dangerStartTime: TimeInterval? = nil
    private let dangerGracePeriod: TimeInterval = 2.5
    
    // MARK: - Textures
    private var bearTextures: [BearType: SKTexture] = [:]
    private var clearStateTexture: SKTexture?
    
    // MARK: - UI Nodes
    private var hudNode = SKNode()
    private var scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
    private var levelLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
    private var levelProgressBar = SKShapeNode()
    private var dangerLineNode = SKShapeNode()
    private var dangerWarningLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
    private var gameOverOverlay = SKNode()
    
    // MARK: - Touch & Drag Tracking
    private var touchStartLocation: CGPoint?
    private var lastTouchLocation: CGPoint?
    private var isDraggingBoard: Bool = false
    private var totalDragDeltaY: CGFloat = 0
    
    // MARK: - Lifecycle
    
    override func didMove(to view: SKView) {
        setupPlayableArea()
        generateTextures()
        setupBackgroundArt()
        setupGameLayerAndBoundaries()
        setupHUD()
        setupDangerLine()
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -24.0)
        physicsWorld.contactDelegate = self
        
        startGame()
    }
    
    // MARK: - Geometry Setup
    
    private func setupPlayableArea() {
        let safeInsetBottom: CGFloat = 55.0
        let safeInsetTop: CGFloat = 115.0
        
        let playWidth = size.width - 24.0
        let playHeight = size.height - safeInsetBottom - safeInsetTop
        
        playableRect = CGRect(
            x: 12.0,
            y: safeInsetBottom,
            width: playWidth,
            height: playHeight
        )
        
        floorY = playableRect.minY + 35.0
        dangerLineY = playableRect.maxY - 10.0
        
        let colSpacing: CGFloat = 2.0
        colWidth = (playableRect.width - CGFloat(columnsCount - 1) * colSpacing) / CGFloat(columnsCount)
        rowHeight = colWidth * 0.72
        blockSize = CGSize(width: colWidth, height: rowHeight)
        gridStartX = playableRect.minX + colWidth / 2
    }
    
    private func generateTextures() {
        for type in BearType.allCases {
            bearTextures[type] = BearType.generateTexture(for: type, size: blockSize)
        }
        clearStateTexture = BearType.generateClearStateTexture(size: blockSize)
    }
    
    // MARK: - Background Art
    
    private func setupBackgroundArt() {
        let bgNode = SKNode()
        bgNode.zPosition = -100
        addChild(bgNode)
        
        // Sky Gradient
        let sky = SKShapeNode(rectOf: size)
        sky.position = CGPoint(x: size.width / 2, y: size.height / 2)
        sky.fillColor = SKColor(red: 0.35, green: 0.68, blue: 0.94, alpha: 1.0)
        sky.strokeColor = .clear
        bgNode.addChild(sky)
        
        // Sun rays
        for i in 0..<8 {
            let angle = (CGFloat(i) / 8.0) * CGFloat.pi
            let ray = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: size.width / 2, y: size.height))
            let x1 = size.width / 2 + cos(angle - 0.12) * size.height * 1.5
            let y1 = size.height - sin(angle - 0.12) * size.height * 1.5
            let x2 = size.width / 2 + cos(angle + 0.12) * size.height * 1.5
            let y2 = size.height - sin(angle + 0.12) * size.height * 1.5
            path.addLine(to: CGPoint(x: x1, y: y1))
            path.addLine(to: CGPoint(x: x2, y: y2))
            path.closeSubpath()
            ray.path = path
            ray.fillColor = SKColor.white.withAlphaComponent(0.06)
            ray.strokeColor = .clear
            bgNode.addChild(ray)
        }
        
        // Rainbow
        let rainbowCenter = CGPoint(x: size.width * 0.85, y: size.height * 0.45)
        let rainbowColors: [SKColor] = [
            SKColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 0.4),
            SKColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 0.4),
            SKColor(red: 0.4, green: 0.8, blue: 0.4, alpha: 0.4),
            SKColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 0.4),
            SKColor(red: 0.7, green: 0.4, blue: 0.9, alpha: 0.4)
        ]
        for (idx, color) in rainbowColors.enumerated() {
            let r = SKShapeNode(circleOfRadius: size.width * 0.55 + CGFloat(idx * 8))
            r.position = rainbowCenter
            r.strokeColor = color
            r.lineWidth = 8.0
            r.fillColor = .clear
            bgNode.addChild(r)
        }
        
        // Smiling Rolling Green Hills
        let hillPath = CGMutablePath()
        hillPath.move(to: CGPoint(x: 0, y: 0))
        hillPath.addLine(to: CGPoint(x: 0, y: size.height * 0.52))
        hillPath.addQuadCurve(to: CGPoint(x: size.width * 0.45, y: size.height * 0.56), control: CGPoint(x: size.width * 0.20, y: size.height * 0.68))
        hillPath.addQuadCurve(to: CGPoint(x: size.width, y: size.height * 0.42), control: CGPoint(x: size.width * 0.75, y: size.height * 0.46))
        hillPath.addLine(to: CGPoint(x: size.width, y: 0))
        hillPath.closeSubpath()
        let hill = SKShapeNode(path: hillPath)
        hill.fillColor = SKColor(red: 0.52, green: 0.78, blue: 0.35, alpha: 1.0)
        hill.strokeColor = SKColor(red: 0.40, green: 0.68, blue: 0.28, alpha: 1.0)
        hill.lineWidth = 3.0
        bgNode.addChild(hill)
        
        // Smiling face on the hill
        let hillFace = SKNode()
        hillFace.position = CGPoint(x: size.width * 0.24, y: size.height * 0.56)
        let leftEye = SKShapeNode(circleOfRadius: 3.5)
        leftEye.position = CGPoint(x: -12, y: 4)
        leftEye.fillColor = SKColor(red: 0.15, green: 0.35, blue: 0.15, alpha: 0.8)
        leftEye.strokeColor = .clear
        hillFace.addChild(leftEye)
        let rightEye = SKShapeNode(circleOfRadius: 3.5)
        rightEye.position = CGPoint(x: 12, y: 4)
        rightEye.fillColor = SKColor(red: 0.15, green: 0.35, blue: 0.15, alpha: 0.8)
        rightEye.strokeColor = .clear
        hillFace.addChild(rightEye)
        let smilePath = CGMutablePath()
        smilePath.move(to: CGPoint(x: -8, y: -4))
        smilePath.addQuadCurve(to: CGPoint(x: 8, y: -4), control: CGPoint(x: 0, y: -10))
        let smile = SKShapeNode(path: smilePath)
        smile.strokeColor = SKColor(red: 0.15, green: 0.35, blue: 0.15, alpha: 0.8)
        smile.lineWidth = 2.0
        hillFace.addChild(smile)
        bgNode.addChild(hillFace)
        
        // Picket Fence
        for i in 0..<7 {
            let fenceX = size.width * 0.10 + CGFloat(i) * 22.0
            let fenceY = size.height * 0.44 - CGFloat(i) * 6.0
            let post = SKShapeNode(rectOf: CGSize(width: 4, height: 16), cornerRadius: 2)
            post.position = CGPoint(x: fenceX, y: fenceY)
            post.fillColor = SKColor.white.withAlphaComponent(0.85)
            post.strokeColor = .clear
            bgNode.addChild(post)
        }
        
        // Cute floating stars
        addFloatingStar(at: CGPoint(x: size.width * 0.65, y: size.height * 0.72), scale: 0.9, in: bgNode)
        addFloatingStar(at: CGPoint(x: size.width * 0.48, y: size.height * 0.64), scale: 0.65, in: bgNode)
        addFloatingStar(at: CGPoint(x: size.width * 0.12, y: size.height * 0.62), scale: 0.55, in: bgNode)
        
        // Bottom Scalloped Bushes (Fixed foreground at floor level)
        let bushNode = SKNode()
        bushNode.position = CGPoint(x: 0, y: floorY - 18)
        bushNode.zPosition = 50
        let bushCount = 10
        let bushRadius = size.width / CGFloat(bushCount) * 0.65
        for i in 0..<bushCount {
            let cx = CGFloat(i) * (size.width / CGFloat(bushCount - 1))
            let b = SKShapeNode(circleOfRadius: bushRadius)
            b.position = CGPoint(x: cx, y: 0)
            b.fillColor = SKColor(red: 0.28, green: 0.48, blue: 0.18, alpha: 1.0)
            b.strokeColor = .clear
            bushNode.addChild(b)
        }
        let bushBottom = SKShapeNode(rect: CGRect(x: 0, y: -120, width: size.width, height: 120))
        bushBottom.fillColor = SKColor(red: 0.28, green: 0.48, blue: 0.18, alpha: 1.0)
        bushBottom.strokeColor = .clear
        bushNode.addChild(bushBottom)
        addChild(bushNode)
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
    
    // MARK: - Game Layer & Physics Boundaries
    
    private func setupGameLayerAndBoundaries() {
        gameLayer.zPosition = 10
        addChild(gameLayer)
        
        // Kinematic floor node inside gameLayer supporting the stack
        floorNode.position = CGPoint(x: size.width / 2, y: floorY)
        let floorBody = SKPhysicsBody(edgeFrom: CGPoint(x: -size.width, y: 0), to: CGPoint(x: size.width, y: 0))
        floorBody.categoryBitMask = PhysicsCategory.floor
        floorBody.collisionBitMask = PhysicsCategory.block
        floorBody.friction = 0.8
        floorBody.restitution = 0.0
        floorNode.physicsBody = floorBody
        gameLayer.addChild(floorNode)
        
        // Tall vertical side walls in gameLayer
        let leftWall = SKNode()
        leftWall.position = CGPoint(x: playableRect.minX - 2, y: 0)
        let leftBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: -size.height * 10), to: CGPoint(x: 0, y: size.height * 10))
        leftBody.categoryBitMask = PhysicsCategory.wall
        leftBody.collisionBitMask = PhysicsCategory.block
        leftBody.friction = 0.05
        leftWall.physicsBody = leftBody
        gameLayer.addChild(leftWall)
        
        let rightWall = SKNode()
        rightWall.position = CGPoint(x: playableRect.maxX + 2, y: 0)
        let rightBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: -size.height * 10), to: CGPoint(x: 0, y: size.height * 10))
        rightBody.categoryBitMask = PhysicsCategory.wall
        rightBody.collisionBitMask = PhysicsCategory.block
        rightBody.friction = 0.05
        rightWall.physicsBody = rightBody
        gameLayer.addChild(rightWall)
    }
    
    // MARK: - HUD & Danger Line
    
    private func setupHUD() {
        hudNode.zPosition = 100
        addChild(hudNode)
        
        let topY = size.height - 45.0
        
        levelLabel.text = "Lv 01"
        levelLabel.fontSize = 24
        levelLabel.fontColor = SKColor.white
        levelLabel.horizontalAlignmentMode = .left
        levelLabel.position = CGPoint(x: playableRect.minX + 2, y: topY)
        hudNode.addChild(levelLabel)
        
        scoreLabel.text = "0000000"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: playableRect.minX + 2, y: topY - 26)
        hudNode.addChild(scoreLabel)
        
        let barX = playableRect.minX + 90.0
        let barY = topY - 14.0
        let barW: CGFloat = 110.0
        let barH: CGFloat = 26.0
        
        let barBg = SKShapeNode(rect: CGRect(x: barX, y: barY, width: barW, height: barH), cornerRadius: 5)
        barBg.fillColor = SKColor(red: 0.35, green: 0.60, blue: 0.90, alpha: 0.9)
        barBg.strokeColor = SKColor.white
        barBg.lineWidth = 2.5
        hudNode.addChild(barBg)
        
        levelProgressBar = SKShapeNode(rect: CGRect(x: barX + 2, y: barY + 2, width: 0, height: barH - 4), cornerRadius: 4)
        levelProgressBar.fillColor = SKColor(red: 1.0, green: 0.78, blue: 0.05, alpha: 1.0)
        levelProgressBar.strokeColor = .clear
        hudNode.addChild(levelProgressBar)
        
        let slot1X = barX + barW + 10.0
        let slot1 = SKShapeNode(rect: CGRect(x: slot1X, y: barY, width: 44, height: barH), cornerRadius: 5)
        slot1.fillColor = SKColor(red: 0.35, green: 0.60, blue: 0.90, alpha: 0.6)
        slot1.strokeColor = SKColor.white
        slot1.lineWidth = 2.5
        hudNode.addChild(slot1)
        
        let slot2 = SKShapeNode(rect: CGRect(x: slot1X + 50.0, y: barY, width: 44, height: barH), cornerRadius: 5)
        slot2.fillColor = SKColor(red: 0.35, green: 0.60, blue: 0.90, alpha: 0.6)
        slot2.strokeColor = SKColor.white
        slot2.lineWidth = 2.5
        hudNode.addChild(slot2)
        
        let pauseBtn = SKShapeNode(circleOfRadius: 16)
        pauseBtn.position = CGPoint(x: playableRect.maxX - 16, y: barY + barH / 2)
        pauseBtn.fillColor = SKColor(red: 0.35, green: 0.60, blue: 0.90, alpha: 0.9)
        pauseBtn.strokeColor = SKColor.white
        pauseBtn.lineWidth = 2.5
        hudNode.addChild(pauseBtn)
        
        let pauseIcon = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        pauseIcon.text = "❚❚"
        pauseIcon.fontSize = 12
        pauseIcon.fontColor = SKColor.white
        pauseIcon.verticalAlignmentMode = .center
        pauseIcon.position = CGPoint(x: playableRect.maxX - 16, y: barY + barH / 2)
        hudNode.addChild(pauseIcon)
    }
    
    private func setupDangerLine() {
        let path = CGMutablePath()
        let segments = 24
        let segW = playableRect.width / CGFloat(segments)
        path.move(to: CGPoint(x: playableRect.minX, y: dangerLineY))
        for i in 1...segments {
            let x = playableRect.minX + CGFloat(i) * segW
            let y = dangerLineY + ((i % 2 == 0) ? 5.0 : -5.0)
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        dangerLineNode.path = path
        dangerLineNode.strokeColor = SKColor.white
        dangerLineNode.lineWidth = 3.5
        dangerLineNode.glowWidth = 2.0
        dangerLineNode.zPosition = 60
        
        let pulseUp = SKAction.fadeAlpha(to: 0.4, duration: 0.6)
        let pulseDown = SKAction.fadeAlpha(to: 1.0, duration: 0.6)
        dangerLineNode.run(SKAction.repeatForever(SKAction.sequence([pulseUp, pulseDown])))
        addChild(dangerLineNode)
        
        dangerWarningLabel.text = "⚠️ DANGER! ⚠️"
        dangerWarningLabel.fontSize = 16
        dangerWarningLabel.fontColor = SKColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)
        dangerWarningLabel.position = CGPoint(x: size.width / 2, y: dangerLineY - 24)
        dangerWarningLabel.alpha = 0.0
        dangerWarningLabel.zPosition = 61
        addChild(dangerWarningLabel)
    }
    
    // MARK: - Game Lifecycle & Start
    
    private func startGame() {
        for child in gameLayer.children where child is BearBlockNode {
            child.removeFromParent()
        }
        gameOverOverlay.removeFromParent()
        gameOverOverlay = SKNode()
        
        gameLayer.position = .zero
        spawnedBelowCount = 0
        let rowStep = blockSize.height + 2.0
        nextSpawnThreshold = rowStep
        floorNode.position = CGPoint(x: size.width / 2, y: floorY)
        
        score = 0
        level = 1
        levelProgress = 0.0
        comboCount = 0
        clearingBlocks.removeAll()
        selectedBlock = nil
        gameState = .playing
        lastUpdateTime = 0
        dangerStartTime = nil
        dangerWarningLabel.alpha = 0.0
        
        updateLevelProgressBar()
        
        // Spawn initial 4 rows on the board
        for row in 0..<4 {
            let rowY = floorY + blockSize.height / 2 + CGFloat(row) * rowStep
            for col in 0..<columnsCount {
                let x = gridStartX + CGFloat(col) * (colWidth + 2.0)
                guard let randomType = BearType.allCases.randomElement(),
                      let tex = bearTextures[randomType],
                      let clearTex = clearStateTexture else { continue }
                
                let block = BearBlockNode(type: randomType, size: blockSize, normalTex: tex, clearTex: clearTex)
                block.position = CGPoint(x: x, y: rowY)
                gameLayer.addChild(block)
            }
        }
    }
    
    // MARK: - Smooth Continuous Rise & Real-Time Drag-Up
    
    /// Shifts the gameLayer upward smoothly and spawns new rows emerging from below.
    private func applyRiseOffset(_ dy: CGFloat, isManualDrag: Bool = false) {
        guard gameState == .playing, dy > 0 else { return }
        
        gameLayer.position.y += dy
        
        if isManualDrag {
            // Reward manual drag-up with slight score bonus
            score += Int(dy * 0.5)
        }
        
        let rowStep = blockSize.height + 2.0
        while gameLayer.position.y >= nextSpawnThreshold {
            spawnRowBelow()
            nextSpawnThreshold += rowStep
        }
    }
    
    /// Spawns a new row right beneath the lowest row so it smoothly rises from behind the bushes.
    private func spawnRowBelow() {
        spawnedBelowCount += 1
        let rowStep = blockSize.height + 2.0
        let rowY = floorY + blockSize.height / 2 - CGFloat(spawnedBelowCount) * rowStep
        
        // Shift floor node down inside gameLayer to keep supporting the stack
        floorNode.position.y = floorY - CGFloat(spawnedBelowCount) * rowStep
        
        for col in 0..<columnsCount {
            let x = gridStartX + CGFloat(col) * (colWidth + 2.0)
            guard let randomType = BearType.allCases.randomElement(),
                  let tex = bearTextures[randomType],
                  let clearTex = clearStateTexture else { continue }
            
            let block = BearBlockNode(type: randomType, size: blockSize, normalTex: tex, clearTex: clearTex)
            block.position = CGPoint(x: x, y: rowY)
            gameLayer.addChild(block)
        }
    }
    
    // MARK: - Exact Bear Links / Lianliankan 2-Turn Pathfinding (Onet)
    
    private func gridPoint(for block: BearBlockNode) -> GridPoint {
        let col = Int(round((block.position.x - gridStartX) / (colWidth + 2.0)))
        let relativeY = block.position.y - (floorNode.position.y + blockSize.height / 2)
        let row = Int(round(relativeY / (blockSize.height + 2.0)))
        return GridPoint(col: max(0, min(columnsCount - 1, col)), row: max(0, row))
    }
    
    private func localPoint(for gp: GridPoint) -> CGPoint {
        let x: CGFloat
        if gp.col == -1 {
            x = playableRect.minX - 10
        } else if gp.col == columnsCount {
            x = playableRect.maxX + 10
        } else {
            x = gridStartX + CGFloat(gp.col) * (colWidth + 2.0)
        }
        
        let y = floorNode.position.y + blockSize.height / 2 + CGFloat(gp.row) * (blockSize.height + 2.0)
        return CGPoint(x: x, y: y)
    }
    
    /// Checks if a grid cell is free of solid obstacles.
    /// CRITICAL: Blocks currently in the Clear State are treated as free/passable space!
    private func isCellFree(grid: [GridPoint: BearBlockNode], pt: GridPoint, start: GridPoint, target: GridPoint, maxRow: Int) -> Bool {
        if pt == start || pt == target { return true }
        
        // Perimeter outside the board is always free!
        if pt.col <= -1 || pt.col >= columnsCount || pt.row <= -1 || pt.row > maxRow {
            return true
        }
        
        // Solid non-clearing blocks block the path. Clearing blocks are passable!
        if let block = grid[pt], block.parent != nil, !block.isClearing {
            return false
        }
        return true
    }
    
    private func isStraightLineClear(grid: [GridPoint: BearBlockNode], from: GridPoint, to: GridPoint, start: GridPoint, target: GridPoint, maxRow: Int) -> Bool {
        if from.col == to.col {
            let step = (to.row > from.row) ? 1 : -1
            var r = from.row + step
            while r != to.row {
                let checkPt = GridPoint(col: from.col, row: r)
                if !isCellFree(grid: grid, pt: checkPt, start: start, target: target, maxRow: maxRow) {
                    return false
                }
                r += step
            }
            return isCellFree(grid: grid, pt: to, start: start, target: target, maxRow: maxRow)
        } else if from.row == to.row {
            let step = (to.col > from.col) ? 1 : -1
            var c = from.col + step
            while c != to.col {
                let checkPt = GridPoint(col: c, row: from.row)
                if !isCellFree(grid: grid, pt: checkPt, start: start, target: target, maxRow: maxRow) {
                    return false
                }
                c += step
            }
            return isCellFree(grid: grid, pt: to, start: start, target: target, maxRow: maxRow)
        }
        return false
    }
    
    /// Finds a valid connecting path with at most 2 turns (3 segments) between two blocks.
    private func findLinkPath(from start: GridPoint, to target: GridPoint) -> [CGPoint]? {
        var gridLookup: [GridPoint: BearBlockNode] = [:]
        let activeBlocks = gameLayer.children.compactMap { $0 as? BearBlockNode }
        var maxRow = 4
        for b in activeBlocks {
            let gp = gridPoint(for: b)
            if !b.isClearing {
                gridLookup[gp] = b
            }
            maxRow = max(maxRow, gp.row)
        }
        
        // 1. Direct Straight Line (0 Turns / 1 Segment)
        if (start.col == target.col || start.row == target.row) &&
            isStraightLineClear(grid: gridLookup, from: start, to: target, start: start, target: target, maxRow: maxRow) {
            return [localPoint(for: start), localPoint(for: target)]
        }
        
        // 2. 1 Turn (2 Segments - L-Shape)
        let corner1 = GridPoint(col: start.col, row: target.row)
        if isCellFree(grid: gridLookup, pt: corner1, start: start, target: target, maxRow: maxRow) &&
            isStraightLineClear(grid: gridLookup, from: start, to: corner1, start: start, target: target, maxRow: maxRow) &&
            isStraightLineClear(grid: gridLookup, from: corner1, to: target, start: start, target: target, maxRow: maxRow) {
            return [localPoint(for: start), localPoint(for: corner1), localPoint(for: target)]
        }
        
        let corner2 = GridPoint(col: target.col, row: start.row)
        if isCellFree(grid: gridLookup, pt: corner2, start: start, target: target, maxRow: maxRow) &&
            isStraightLineClear(grid: gridLookup, from: start, to: corner2, start: start, target: target, maxRow: maxRow) &&
            isStraightLineClear(grid: gridLookup, from: corner2, to: target, start: start, target: target, maxRow: maxRow) {
            return [localPoint(for: start), localPoint(for: corner2), localPoint(for: target)]
        }
        
        // 3. 2 Turns (3 Segments - Z / U Shape)
        for col in -1...columnsCount {
            let p1 = GridPoint(col: col, row: start.row)
            let p2 = GridPoint(col: col, row: target.row)
            if isCellFree(grid: gridLookup, pt: p1, start: start, target: target, maxRow: maxRow) &&
                isCellFree(grid: gridLookup, pt: p2, start: start, target: target, maxRow: maxRow) &&
                isStraightLineClear(grid: gridLookup, from: start, to: p1, start: start, target: target, maxRow: maxRow) &&
                isStraightLineClear(grid: gridLookup, from: p1, to: p2, start: start, target: target, maxRow: maxRow) &&
                isStraightLineClear(grid: gridLookup, from: p2, to: target, start: start, target: target, maxRow: maxRow) {
                return [localPoint(for: start), localPoint(for: p1), localPoint(for: p2), localPoint(for: target)]
            }
        }
        
        for row in -1...(maxRow + 2) {
            let p1 = GridPoint(col: start.col, row: row)
            let p2 = GridPoint(col: target.col, row: row)
            if isCellFree(grid: gridLookup, pt: p1, start: start, target: target, maxRow: maxRow) &&
                isCellFree(grid: gridLookup, pt: p2, start: start, target: target, maxRow: maxRow) &&
                isStraightLineClear(grid: gridLookup, from: start, to: p1, start: start, target: target, maxRow: maxRow) &&
                isStraightLineClear(grid: gridLookup, from: p1, to: p2, start: start, target: target, maxRow: maxRow) &&
                isStraightLineClear(grid: gridLookup, from: p2, to: target, start: start, target: target, maxRow: maxRow) {
                return [localPoint(for: start), localPoint(for: p1), localPoint(for: p2), localPoint(for: target)]
            }
        }
        
        return nil
    }
    
    // MARK: - 2-Block Matching Flow & Delayed Clear State
    
    private func handleBlockSelection(_ block: BearBlockNode) {
        guard gameState == .playing, !block.isClearing else { return }
        
        guard let first = selectedBlock else {
            selectedBlock = block
            block.isSelected = true
            triggerHaptic(style: .light)
            return
        }
        
        if first == block {
            first.isSelected = false
            selectedBlock = nil
            return
        }
        
        if first.bearType != block.bearType {
            first.isSelected = false
            selectedBlock = block
            block.isSelected = true
            triggerHaptic(style: .light)
            return
        }
        
        let startGP = gridPoint(for: first)
        let targetGP = gridPoint(for: block)
        
        if let pathPoints = findLinkPath(from: startGP, to: targetGP) {
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
        
        let baseGain = 100
        let totalGain = baseGain * comboCount
        score += totalGain
        
        levelProgress += 0.08
        if levelProgress >= 1.0 {
            levelProgress = 0.0
            level += 1
            showFloatingBadge(text: "LEVEL UP!", at: CGPoint(x: size.width / 2, y: size.height * 0.55), color: SKColor.yellow)
        }
        updateLevelProgressBar()
        
        let midX = (path.first!.x + path.last!.x) / 2
        let midY = (path.first!.y + path.last!.y) / 2
        let badgePos = CGPoint(x: midX, y: midY)
        
        let scoreText = (comboCount > 1) ? "\(comboCount)x\n\(totalGain)" : "\(totalGain)"
        showFloatingBadge(text: scoreText, at: badgePos, color: (comboCount > 1) ? SKColor(red: 1.0, green: 0.85, blue: 0.1, alpha: 1.0) : SKColor.white)
        
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
        lineNode.lineWidth = 7.0
        lineNode.lineCap = .round
        lineNode.lineJoin = .round
        lineNode.glowWidth = 3.5
        lineNode.zPosition = 85
        gameLayer.addChild(lineNode)
        
        let wait = SKAction.wait(forDuration: 0.35)
        let fade = SKAction.fadeOut(withDuration: 0.25)
        lineNode.run(SKAction.sequence([wait, fade, SKAction.removeFromParent()]))
    }
    
    private func showFloatingBadge(text: String, at pos: CGPoint, color: SKColor) {
        let badge = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        badge.text = text
        badge.numberOfLines = 2
        badge.fontSize = 20
        badge.fontColor = color
        badge.position = pos
        badge.zPosition = 95
        gameLayer.addChild(badge)
        
        let pop = SKAction.scale(to: 1.25, duration: 0.1)
        let move = SKAction.moveBy(x: 0, y: 25, duration: 0.6)
        let fade = SKAction.fadeOut(withDuration: 0.6)
        let group = SKAction.group([move, fade])
        
        badge.run(SKAction.sequence([pop, group, SKAction.removeFromParent()]))
    }
    
    private func updateLevelProgressBar() {
        let barX = playableRect.minX + 90.0 + 2.0
        let barY = size.height - 45.0 - 14.0 + 2.0
        let barMaxW: CGFloat = 110.0 - 4.0
        let barH: CGFloat = 26.0 - 4.0
        let currentW = barMaxW * min(1.0, levelProgress)
        
        let path = CGMutablePath()
        path.addRoundedRect(in: CGRect(x: barX, y: barY, width: currentW, height: barH), cornerWidth: 3, cornerHeight: 3)
        levelProgressBar.path = path
    }
    
    // MARK: - Game Loop & Continuous Rise
    
    override func update(_ currentTime: TimeInterval) {
        guard gameState == .playing else { return }
        
        let dt = (lastUpdateTime > 0) ? min(currentTime - lastUpdateTime, 0.1) : (1.0 / 60.0)
        lastUpdateTime = currentTime
        
        // 1. Smooth Continuous Upward Scroll
        let currentSpeed = baseRiseSpeed + Double(level - 1) * 3.0
        let autoRise = CGFloat(currentSpeed * dt)
        applyRiseOffset(autoRise, isManualDrag: false)
        
        // 2. Check if active Clear State has expired
        if !clearingBlocks.isEmpty && CACurrentMediaTime() >= clearStateEndTime {
            finalizeClearingBlocks()
        }
        
        // 3. Danger Line Check (World Space)
        let activeBlocks = gameLayer.children.compactMap { $0 as? BearBlockNode }
        var isOverflowing = false
        for b in activeBlocks {
            let worldY = gameLayer.convert(b.position, to: self).y
            if !b.isClearing && (worldY + blockSize.height * 0.45) >= dangerLineY {
                isOverflowing = true
                break
            }
        }
        
        if isOverflowing {
            if dangerStartTime == nil {
                dangerStartTime = currentTime
                dangerWarningLabel.alpha = 1.0
            } else if let start = dangerStartTime, currentTime - start >= dangerGracePeriod {
                triggerGameOver()
            }
        } else {
            dangerStartTime = nil
            dangerWarningLabel.alpha = 0.0
        }
    }
    
    private func finalizeClearingBlocks() {
        let blocksToPop = clearingBlocks
        clearingBlocks.removeAll()
        comboCount = 0
        
        for block in blocksToPop {
            if block.parent != nil {
                createPopParticles(at: block.position, color: block.bearType.primaryColor)
                block.popAndRemove { }
            }
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
        gameState = .gameOver
        dangerWarningLabel.alpha = 0.0
        selectedBlock = nil
        triggerHaptic(style: .heavy)
        
        for b in gameLayer.children.compactMap({ $0 as? BearBlockNode }) {
            b.physicsBody?.isDynamic = false
        }
        
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
        
        let goLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        goLabel.text = "GAME OVER"
        goLabel.fontSize = 28
        goLabel.fontColor = SKColor(red: 1.0, green: 0.35, blue: 0.45, alpha: 1.0)
        goLabel.position = CGPoint(x: 0, y: 70)
        card.addChild(goLabel)
        
        let fScore = SKLabelNode(fontNamed: "AvenirNext-Bold")
        fScore.text = "FINAL SCORE: \(score)"
        fScore.fontSize = 20
        fScore.fontColor = SKColor.white
        fScore.position = CGPoint(x: 0, y: 25)
        card.addChild(fScore)
        
        let fLevel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        fLevel.text = "LEVEL: \(level)"
        fLevel.fontSize = 16
        fLevel.fontColor = SKColor(red: 1.0, green: 0.85, blue: 0.2, alpha: 1.0)
        fLevel.position = CGPoint(x: 0, y: -5)
        card.addChild(fLevel)
        
        let btn = SKShapeNode(rect: CGRect(x: -80, y: -80, width: 160, height: 44), cornerRadius: 12)
        btn.name = "restart_button"
        btn.fillColor = SKColor(red: 0.25, green: 0.75, blue: 0.45, alpha: 1.0)
        btn.strokeColor = SKColor.white
        btn.lineWidth = 1.5
        card.addChild(btn)
        
        let btnText = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        btnText.name = "restart_button"
        btnText.text = "PLAY AGAIN"
        btnText.fontSize = 15
        btnText.fontColor = SKColor.white
        btnText.verticalAlignmentMode = .center
        btnText.position = CGPoint(x: 0, y: -58)
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
        if dy > 0 { // Dragging UP
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
            // Player performed a tap! Check if a block was tapped
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
