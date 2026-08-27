//
//  ContentView.swift
//  Catalittle
//
//  Created by Jason Zhou on 8/26/26.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    var body: some View {
        GeometryReader { geometry in
            SpriteView(
                scene: makeGameScene(size: geometry.size),
                preferredFramesPerSecond: 60,
                options: [.allowsTransparency]
            )
            .ignoresSafeArea()
            .background(Color(red: 0.10, green: 0.12, blue: 0.18))
        }
    }
    
    private func makeGameScene(size: CGSize) -> SKScene {
        let validSize = CGSize(
            width: max(size.width, 320),
            height: max(size.height, 480)
        )
        let scene = GameScene(size: validSize)
        scene.scaleMode = .resizeFill
        return scene
    }
}

#Preview {
    ContentView()
}

