
import SwiftUI

struct ContentView: View {

    // MARK: - Game Data

    @State private var score = 0

    @AppStorage("highestScore")
    private var highestScore = 0

    // MARK: - Timer

    @State private var timeRemaining = 10.0
    @State private var isRunning = false
    @State private var startTime = Date()
    @State private var lastClickTime = Date()
    
    @State private var comboNum = 0
    @State private var gameTimer: Timer?
    
    @State var redDuration = 0.0
    @State var redStart = 0.0

    // MARK: - Random Red Period

    @State private var redPeriods: [Range<Double>] = []
    @State private var isRed = false

    // MARK: - UI

    var body: some View {

        VStack(spacing: 25) {

            // Header

            Text("Tap Frenzy")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Beat your highest score!")
                .foregroundColor(.secondary)

            // Timer Display

            VStack(spacing: 5) {

                Text("TIME REMAINING")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(String(format: "%.1f", timeRemaining))
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(
                        timeRemaining <= 3 ? .red : .primary
                    )
            }

            // Score Display

            HStack(spacing: 40) {

                VStack {
                    Text("SCORE")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("\(score)")
                        .font(.largeTitle)
                        .bold()
                }

                VStack {
                    Text("BEST")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("\(highestScore)")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.orange)
                }
                VStack {
                    Text("Combo")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("x\(comboNum)")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.red)
                }
            }

            Spacer()
            Text("Press the button with 300 miliseconds to achieve combos!!")
                .foregroundColor(.secondary)
            Spacer()
            // Main Game Button

            Button(action: {

                if isRunning {
                    let currentTime = Date()
                    let timeDifference = currentTime.timeIntervalSince(lastClickTime)
                    lastClickTime = currentTime

                    if isRed && score >= 1{
                        score -= 1
                        
                            
                    } else {
                        score += 1
                        print((timeDifference))
                        if timeDifference < 0.3 {
                            comboNum += 1
                        }
                    }

                }else {
                    startGame()
                }

            }) {

                Text(isRed ? "DANGER!" : "TAP!")
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(25)
                    .background(
                        isRed ? Color.red : Color.green
                    )
                    .cornerRadius(20)
            }
            //.disabled(!isRunning)

            Spacer()

            // Start / Restart Button

            Button(
                isRunning ? "Game Running..." :
                timeRemaining == 0 ? "Play Again" : "Start Game"
            ) {

                startGame()

            }
            .disabled(isRunning)
            .font(.headline)

            // Game Over Message

            if timeRemaining == 0 {

                Text("Game Over!")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Final Score: \(score)")
                    .foregroundColor(.secondary)
            }

        }
        .padding(25)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))

        // Timer Management

        .onChange(of: isRunning) { oldValue, newValue in

            if newValue {
                startTimer()
            } else {
                stopTimer()
            }
        }

        .onDisappear {
            stopTimer()
        }
    }

    // MARK: - Start Game

    func startGame() {

        score = 0
        timeRemaining = 10
        comboNum = 0

        // Generate random red period

        redDuration = Double(Int.random(in: 1...4))

        redStart = Double(
            Int.random(in: 0...(10 - Int(redDuration)))
        )

        isRed = false

        startTime = Date()

        isRunning = true
    }

    // MARK: - Start Timer

    func startTimer() {

        gameTimer?.invalidate()

        gameTimer = Timer.scheduledTimer(
            withTimeInterval: 0.05,
            repeats: true
        ) { _ in

            let elapsed = Date().timeIntervalSince(startTime)

            // Update countdown

            timeRemaining = max(0, 10 - elapsed)

            // Change button colour

            isRed = elapsed >= redStart &&
                    elapsed < redStart + redDuration

            // Game Over

            if elapsed >= 10 {

                timeRemaining = 0
                isRunning = false
                isRed = false

                // Update highest score

                if score > highestScore {
                    highestScore = score
                }
            }
        }
    }

    // MARK: - Stop Timer

    func stopTimer() {

        gameTimer?.invalidate()
        gameTimer = nil
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
