//
//  ContentView.swift
//  Catalittle
//
//  Created by Jason Zhou on 8/26/26.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var isLoading: Bool = true
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Sky Blue base eliminates any black screen flash during launch
                Color(red: 0.35, green: 0.68, blue: 0.94)
                    .ignoresSafeArea()
                
                // High-Performance Metal SpriteKit View with 120 FPS ProMotion Support
                CustomSpriteView(
                    scene: makeGameScene(
                        size: geometry.size,
                        topInset: geometry.safeAreaInsets.top
                    )
                )
                .ignoresSafeArea()
                .opacity(isLoading ? 0.0 : 1.0)
                
                // Cheerful Animated Splash/Loading Screen
                if isLoading {
                    VStack(spacing: 16) {
                        Spacer()
                        
                        // Kawaii Bear / Cat Icon
                        ZStack {
                            Circle()
                                .fill(Color(red: 1.0, green: 0.92, blue: 0.40))
                                .frame(width: 90, height: 90)
                                .shadow(color: Color.black.opacity(0.15), radius: 10, y: 6)
                            
                            VStack(spacing: 4) {
                                HStack(spacing: 20) {
                                    Circle().fill(Color(red: 0.2, green: 0.15, blue: 0.15)).frame(width: 8, height: 8)
                                    Circle().fill(Color(red: 0.2, green: 0.15, blue: 0.15)).frame(width: 8, height: 8)
                                }
                                Text("ω")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.15))
                            }
                        }
                        .scaleEffect(isLoading ? 1.05 : 0.95)
                        .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: isLoading)
                        
                        Text("CATALITTLE")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.25), radius: 4, y: 3)
                        
                        Text("LOADING...")
                            .font(.system(size: 14, weight: .heavy, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.85))
                            .padding(.top, 4)
                        
                        Spacer()
                    }
                    .transition(.opacity)
                }
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .inactive || newPhase == .background {
                    NotificationCenter.default.post(name: NSNotification.Name("Catalittle_AutoPauseGame"), object: nil)
                }
            }
            .onAppear {
                // Pre-warm audio and smoothly fade in game
                _ = SoundManager.shared
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    withAnimation(.easeOut(duration: 0.35)) {
                        isLoading = false
                    }
                }
            }
        }
    }
    
    private func makeGameScene(size: CGSize, topInset: CGFloat) -> SKScene {
        let validSize = CGSize(
            width: max(size.width, 320),
            height: max(size.height, 480)
        )
        let scene = GameScene(size: validSize)
        scene.safeAreaTopInset = max(topInset, 50.0)
        scene.scaleMode = .resizeFill
        return scene
    }
}

// MARK: - High-Performance 120 FPS ProMotion SpriteView

#if os(iOS)
struct CustomSpriteView: UIViewRepresentable {
    let scene: SKScene
    
    func makeUIView(context: Context) -> SKView {
        let skView = SKView()
        skView.ignoresSiblingOrder = true
        skView.shouldCullNonVisibleNodes = true
        skView.preferredFramesPerSecond = 120
        if #available(iOS 15.0, *) {
            skView.preferredFrameRateRange = CAFrameRateRange(minimum: 80, maximum: 120, preferred: 120)
        }
        skView.allowsTransparency = true
        skView.presentScene(scene)
        return skView
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {}
}
#elseif os(macOS)
struct CustomSpriteView: NSViewRepresentable {
    let scene: SKScene
    
    func makeNSView(context: Context) -> SKView {
        let skView = SKView()
        skView.ignoresSiblingOrder = true
        skView.shouldCullNonVisibleNodes = true
        skView.preferredFramesPerSecond = 120
        skView.allowsTransparency = true
        skView.presentScene(scene)
        return skView
    }
    
    func updateNSView(_ nsView: SKView, context: Context) {}
}
#endif

#Preview {
    ContentView()
}
