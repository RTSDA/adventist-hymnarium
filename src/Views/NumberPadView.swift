import SwiftUI

struct NumberPadView: View {
    @State private var enteredNumber = ""
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @StateObject private var hymnalService = HymnalService.shared
    @StateObject private var readingService = ResponsiveReadingService.shared
    @State private var selectedHymn: Hymn?
    @State private var selectedReading: ResponsiveReading?
    @State private var showingSearch = false
    @State private var showingHistory = false
    
    // Get dynamic sizes based on screen
    private var buttonSize: CGFloat {
        horizontalSizeClass == .regular ? 100 : 80
    }
    
    private var spacing: CGFloat {
        horizontalSizeClass == .regular ? 25 : 20
    }
    
    private var fontSize: CGFloat {
        horizontalSizeClass == .regular ? 40 : 32
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: spacing) {
                Text(enteredNumber.isEmpty ? "Enter Number" : enteredNumber)
                    .scaledFontSize(fontSize)
                    .fontWeight(.bold)
                    .frame(height: 60)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .padding(.top)
                
                // Number pad grid
                VStack(spacing: spacing) {
                    ForEach(0..<3) { row in
                        HStack(spacing: spacing) {
                            ForEach(1...3, id: \.self) { col in
                                let number = String(row * 3 + col)
                                numberButton(number)
                            }
                        }
                    }
                    
                    // Bottom row
                    HStack(spacing: spacing) {
                        numberButton("")
                        numberButton("0")
                        deleteButton
                    }
                }
                .frame(maxWidth: .infinity)
                
                goButton
                    .padding(.vertical)
                
                // Add spacing at the bottom to account for mini player
                Color.clear.frame(height: 20)
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 24) { 
                    Button(action: { showingSearch = true }) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 22)) 
                            .frame(width: 44, height: 44) 
                    }
                    Button(action: { showingHistory = true }) {
                        Image(systemName: "clock")
                            .font(.system(size: 22)) 
                            .frame(width: 44, height: 44) 
                    }
                }
                .padding(.trailing, 8) 
            }
        }
        .navigationDestination(isPresented: Binding(
            get: { selectedHymn != nil || selectedReading != nil },
            set: { if !$0 { selectedHymn = nil; selectedReading = nil } }
        )) {
            if let hymn = selectedHymn {
                HymnDetailView(hymn: hymn)
            } else if let reading = selectedReading {
                ResponsiveReadingView(reading: reading)
            }
        }
        .fullScreenCover(isPresented: $showingSearch) {
            NavigationStack {
                SearchView()
            }
        }
        .sheet(isPresented: $showingHistory) {
            NavigationStack {
                HistoryView()
            }
        }
        .task {
            if hymnalService.currentLanguage == .english1985 {
                await readingService.loadReadings()
            }
        }
    }
    
    private var deleteButton: some View {
        Button(action: {
            if !enteredNumber.isEmpty {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                enteredNumber.removeLast()
            }
        }) {
            Image(systemName: "delete.left")
                .font(.system(size: fontSize * 0.7))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
        }
        .frame(width: buttonSize, height: buttonSize)
        .background(Color(.systemGray6))
        .cornerRadius(buttonSize / 2)
    }
    
    private var goButton: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            if let number = Int(enteredNumber) {
                // Check for responsive reading first (only in 1985 hymnal)
                if hymnalService.currentLanguage == .english1985 && number >= 696 && number <= 920,
                   let reading = readingService.reading(for: number) {
                    selectedReading = reading
                } else if let hymn = hymnalService.hymn(number: number) {
                    selectedHymn = hymn
                }
            }
        }) {
            Text("Go")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: horizontalSizeClass == .regular ? 300 : 200)
                .frame(height: 60)
                .contentShape(Rectangle())
        }
        .background(
            !enteredNumber.isEmpty && Int(enteredNumber) ?? 0 > 0
            ? Color.accentColor
            : Color.gray
        )
        .cornerRadius(30)
        .disabled(enteredNumber.isEmpty || Int(enteredNumber) == 0)
    }
    
    private func numberButton(_ number: String) -> some View {
        Button(action: {
            if !number.isEmpty && enteredNumber.count < 3 {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                enteredNumber += number
            }
        }) {
            Text(number)
                .scaledFontSize(fontSize)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
        }
        .frame(width: buttonSize, height: buttonSize)
        .background(number.isEmpty ? .clear : Color(.systemGray6))
        .cornerRadius(buttonSize / 2)
        .scaleEffect(number.isEmpty ? 0 : 1)
    }
}
