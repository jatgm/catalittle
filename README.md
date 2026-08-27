# Bearalot (Bear Links) 🐻🎮

A complete, faithful Swift and SpriteKit clone of the classic puzzle game **Bearalot** (also known as *Bear Links* by Mooff Games). Built for iOS, iPadOS, and macOS using **SwiftUI** and **SpriteKit**.

---

## 🕹️ Gameplay & Mechanics

1. **Two-Block Link Matching (Lianliankan / Onet Pathfinding):**
   - Tap a block to select it.
   - Tap another matching character block.
   - Connects if an orthogonal path with **at most 2 corners (3 line segments)** is open through empty space or along the board's perimeter.
   - Draws a glowing white link line between the matching pair!

2. **The "Clear State" & Chain Combo Multipliers (2x, 3x...):**
   - Matched pairs transform into **glowing cream-yellow capsules with a golden border**.
   - During the ~1.75s Clear State, blocks **remain solid platforms** to keep pieces above suspended in the air.
   - **Passable Paths:** New link paths can route directly through clearing blocks!
   - Linking another pair before the timer ends increases the **Combo Multiplier** (`2x`, `3x`, `4x`...) and refreshes the timer.
   - When the timer ends, clearing blocks pop into colorful particles and pieces above fall naturally under gravity.

3. **Push-Up / Swipe Spawning:**
   - Rows automatically push up from the bottom bush floor on a timer.
   - Swipe **UP** anywhere on screen to manually force a new row to push up (+25 bonus score).

4. **Danger Ceiling & Game Over:**
   - Animated wavy water line at the top.
   - 2.5-second grace period when blocks touch the danger ceiling before Game Over.

5. **Authentic Custom Vector Characters:**
   - 🌸 Pink Bear (with round ears & 'Y' snout)
   - 🌿 Green Lass (with lashes & hair parting)
   - 🍊 Orange Joy (with wide open laughing mouth)
   - 🍑 Cyan & Peach Man (with round bulbous nose)
   - 🧔 Red Mustache (with black handlebar mustache)
   - 🐸 Lime Frog (with wide-set dot eyes)
   - ⭐ Yellow Star/Cat (with anime sparkle eyes)

---

## 🚀 Getting Started

1. Open `Catalittle.xcodeproj` in Xcode.
2. Select your device or simulator (iOS Simulator, iPhone, iPad, or Mac).
3. Press **Cmd + R** to Build & Run.
