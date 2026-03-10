<div align="center">
  <img src="assets/logo.png" alt="Neon Snake Logo" width="150" height="150" />
  <h1>Neon Snake</h1>
  <p>A premium, neon-styled Snake game built with Flutter.</p>
</div>

Experience the classic arcade gameplay with modern visuals, smooth animations, and immersive audio.

## 🚀 Features

- **Neon Aesthetics**: Vibrant, glow-based graphics that bring a modern feel to a classic game.
- **Classic Mode**: The traditional snake experience you know and love with Agar.io-style mechanics using AI bots.
- **Vertical Runner**: A unique vertical twist on the snake formula.
- **Immersive Audio**: Custom soundtrack and sound effects for an engaging experience.
- **Smooth Gameplay**: Optimized for 60 FPS with fluid animations and responsive gesture controls.
- **High Score Tracking**: Compete with yourself to beat your personal best.

## 🎨 How It's Made

Neon Snake is built entirely with **Flutter**, showcasing what's possible with custom 2D rendering and animations:

- **Custom Painters**: The game heavily utilizes Flutter's `CustomPaint` and `Canvas` APIs to draw snakes, food, obstacles, and neon grid backgrounds dynamically on each frame.
- **State Management**: The core game logic runs independently from the UI and utilizes robust state classes to model multiple AI snakes, player movement, collisions, and size-based mechanics (Agar.io style).
- **Animations**: Using `AnimationController`s, the game achieves smooth movement, glowing neon pulses, screen shakes, swallow effects, and UI transitions.
- **Audio Integration**: Using `audioplayers`, the app layers custom SFX over continuous background tracks.

##  previews
<div align="center">
  <img src="assets/preview/snake.png" alt="Neon Snake Logo" width="150" height="150" />
 <img src="assets/preview/snake2.png" alt="Neon Snake Logo" width="150" height="150" />
</div>

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- A mobile emulator or physical device

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   ```
2. Navigate to the project directory:
   ```bash
   cd game
   ```
3. Get dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

