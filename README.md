# Catalittle 🐱✨

A fast-paced link-matching puzzle game built from the ground up for iOS, iPadOS, and macOS using **Swift**, **SwiftUI**, and **SpriteKit**.

Inspired by classic *Lianliankan / Shisen-Sho / Onet* connect-link puzzle games (such as *Bearalot* / *Bear Links*), **Catalittle** features a continuous rising floor, high-stakes laser ceiling, combo clear states, and cascading gravity chain reactions.

---

## 🕹️ Gameplay & Mechanics

1. **Two-Block Link Matching (Onet / Lianliankan Pathfinding):**
   - Tap a character block to select it.
   - Tap an identical matching character block.
   - Connects if an orthogonal path with **at most 2 corners (3 line segments)** is open through empty space or along the board's perimeter.
   - Draws a glowing link line directly connecting the matching pair.

2. **The "Clear State" & Chain Combo Multipliers (2x, 3x, 4x...):**
   - Matched pairs transform into solid glowing capsules with golden borders.
   - While clearing, blocks remain physical platforms so higher blocks stay suspended.
   - **Passable Channels:** New link paths can route directly through clearing blocks!
   - Linking another pair before the timer expires increments the **Combo Multiplier** (`2x`, `3x`, `4x`...) and extends the clear window.
   - When the timer ends, clearing blocks pop into colorful particle bursts and pieces above drop under gravity.

3. **Post-Fall Cascade Chain Reactions:**
   - Falling blocks that land directly onto matching neighbors automatically trigger a cascade match, continuing your combo streak!

4. **Continuous Rising Floor & Manual Drag:**
   - Rows continuously crawl upward from the bottom grass floor.
   - Drag up anywhere on screen to manually accelerate the board for bonus score.

5. **Danger Ceiling & Electric Laser:**
   - A crackling electric laser guards the danger line at the top.
   - Touching the laser triggers game over!

6. **Procedural Vector Characters:**
   - All character art is rendered procedurally via `CoreGraphics` / `CGContext` vector paths (zero external bitmap art assets).

---

## ⚡ Performance & Features

- **120 FPS ProMotion Support:** Unlocked high-refresh rendering on ProMotion iPhones and iPads.
- **Persistent High Scores:** Stored safely via `UserDefaults`, persisting across sessions and version updates.
- **Interactive Pause & Auto-Pause:** Automatically pauses the game when minimized or backgrounded.
- **Haptics:** Pre-warmed tactile feedback for selections, links, cascades, and level-ups.

---

## 🚀 Getting Started

1. Open `Catalittle.xcodeproj` in Xcode 16+.
2. Select your device or simulator (iOS Simulator, iPhone, iPad, or Mac).
3. Press **Cmd + R** to Build & Run.

---

## 🎵 Audio Credits & Licensing

- **Background Music:**
  - *"Cipher"* by Kevin MacLeod ([incompetech.com](https://incompetech.com))
  - Licensed under **Creative Commons: By Attribution 4.0 International License**  
    [http://creativecommons.org/licenses/by/4.0/](http://creativecommons.org/licenses/by/4.0/)
- **Sound Effects:**
  - Procedurally synthesized Glockenspiel / Bell chimes, pops, and resonance via Apple `AVFoundation`.

---

## ⚖️ Legal & Non-Affiliation Disclaimer

*Catalittle* is an independent, original software implementation developed for educational and entertainment purposes. It is **not** affiliated with, sponsored by, or endorsed by Mooff Games or the creators of *Bearalot* / *Bear Links*. All registered trademarks and copyrights belong to their respective owners.

---

## 📄 License

Distributed under the **MIT License**. See [`LICENSE`](LICENSE) for details.
