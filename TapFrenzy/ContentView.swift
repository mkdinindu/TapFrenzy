
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
    @State private var gameTimer: Timer?

    // MARK: - Random Red Periods

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

            Spacer()

            // Timer Display

            VStack(spacing: 5) {

                Text("TIME REMAINING")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(String(format: "%.1f", timeRemaining))
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(
                        timeRemaining <= 3 && isRunning
                        ? .red : .primary
                    )
            }

            // Score Display

            HStack(spacing: 60) {

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
            }

            Spacer()

            // Main Game Button

            Button(action: {

                if !isRunning {

                    startGame()

                } else {

                    if isRed && score >= 1{
                        score -= 1
                    } else {
                        score += 1
                    }

                }

            }) {

                VStack(spacing: 8) {

                    Text(
                        isRunning
                        ? (isRed ? "DANGER!" : "TAP!")
                        : (timeRemaining == 0
                           ? "PLAY AGAIN"
                           : "START GAME")
                    )
                    .font(.title)
                    .fontWeight(.bold)

                    if !isRunning {
                        Text("10 SECOND CHALLENGE")
                            .font(.caption)
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(25)
                .background(

                    isRunning
                    ? (isRed ? Color.red : Color.green)
                    : Color.blue

                )
                .cornerRadius(20)
            }

            Spacer()

            // Game Over Message

            if timeRemaining == 0 {

                Text("GAME OVER!")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Final Score: \(score)")
                    .foregroundColor(.secondary)

                if score >= highestScore && score > 0 {
                    Text("NEW HIGH SCORE!")
                        .font(.headline)
                        .foregroundColor(.orange)
                }
            }

        }
        .padding(25)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))

        // MARK: - Timer Management

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

        // Generate 3 or 4 random red periods

        let numberOfRedPeriods = Int.random(in: 3...4)

        var selectedSlots: [Int] = []

        while selectedSlots.count < numberOfRedPeriods {

            let slot = Int.random(in: 0...9)

            if !selectedSlots.contains(slot) &&
               !selectedSlots.contains(slot - 1) &&
               !selectedSlots.contains(slot + 1) {

                selectedSlots.append(slot)
            }
        }

        // Convert slots into time ranges

        redPeriods = selectedSlots.map { slot in

            Double(slot)..<Double(slot + 1)

        }

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

            // Check random red periods

            isRed = redPeriods.contains { period in

                period.contains(elapsed)

            }

            // Game Over

            if elapsed >= 10 {

                timeRemaining = 0
                isRunning = false
                isRed = false

                // Save highest score

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
