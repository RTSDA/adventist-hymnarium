import SwiftUI

struct FavoriteReadingsView: View {
    @StateObject private var readingService = ResponsiveReadingService.shared
    
    var body: some View {
        List {
            if readingService.sortedFavoriteReadings.isEmpty {
                Text("No favorite readings yet")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(readingService.sortedFavoriteReadings) { reading in
                    NavigationLink {
                        ResponsiveReadingView(reading: reading)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(reading.number). \(reading.title)")
                                .fontWeight(.medium)
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Favorite Readings")
    }
}

#Preview {
    NavigationStack {
        FavoriteReadingsView()
    }
}
