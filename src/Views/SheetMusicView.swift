import SwiftUI

struct SheetMusicView: View {
    let hymn: Hymn
    @StateObject private var sheetMusicService = SheetMusicService.shared
    @State private var currentPage = 0
    
    var body: some View {
        Group {
            if sheetMusicService.isLoading {
                ProgressView()
            } else if let images = sheetMusicService.currentSheetMusic, !images.isEmpty {
                GeometryReader { geometry in
                    ZStack(alignment: .bottom) {
                        TabView(selection: $currentPage) {
                            ForEach(0..<images.count, id: \.self) { index in
                                ZoomableView {
                                    Image(uiImage: images[index])
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                }
                                .tag(index)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        
                        // Custom page indicator
                        if images.count > 1 {
                            HStack(spacing: 8) {
                                ForEach(0..<images.count, id: \.self) { index in
                                    Circle()
                                        .fill(currentPage == index ? Color.accentColor : Color.gray.opacity(0.5))
                                        .frame(width: 8, height: 8)
                                }
                            }
                            .padding(.bottom, 20)
                        }
                    }
                }
            } else {
                Text("Sheet music not available")
                    .foregroundColor(.secondary)
            }
        }
        .navigationBarTitle("Sheet Music - Hymn \(hymn.number)", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if let images = sheetMusicService.currentSheetMusic, images.count > 1 {
                    HStack(spacing: 16) {
                        Button(action: {
                            withAnimation {
                                currentPage = max(0, currentPage - 1)
                            }
                        }) {
                            Image(systemName: "chevron.left")
                        }
                        .disabled(currentPage == 0)
                        
                        Text("\(currentPage + 1) of \(images.count)")
                            .font(.subheadline)
                        
                        Button(action: {
                            withAnimation {
                                currentPage = min(images.count - 1, currentPage + 1)
                            }
                        }) {
                            Image(systemName: "chevron.right")
                        }
                        .disabled(currentPage == images.count - 1)
                    }
                }
            }
        }
        .task {
            do {
                _ = try await sheetMusicService.getSheetMusic(for: hymn.number)
            } catch {
                print("Error loading sheet music: \(error)")
            }
        }
    }
}

struct ZoomableView<Content: View>: View {
    let content: () -> Content
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @GestureState private var magnifyState: CGFloat = 1.0
    @GestureState private var dragState: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            content()
                .scaleEffect(scale)
                .offset(x: offset.width + dragState.width, y: offset.height + dragState.height)
                .gesture(
                    MagnificationGesture()
                        .updating($magnifyState) { value, state, _ in
                            state = value
                        }
                        .onChanged { value in
                            let delta = value / lastScale
                            lastScale = value
                            scale = min(max(1, scale * delta), 4)
                        }
                        .onEnded { _ in
                            lastScale = 1.0
                            scale = min(max(1, scale), 4)
                            
                            // Reset offset if zooming out completely
                            if scale <= 1 {
                                withAnimation {
                                    offset = .zero
                                    lastOffset = .zero
                                }
                            }
                        }
                )
                .simultaneousGesture(
                    DragGesture()
                        .updating($dragState) { value, state, _ in
                            // Only allow dragging if zoomed in
                            if scale > 1 {
                                state = value.translation
                            }
                        }
                        .onEnded { value in
                            // Only update offset if zoomed in
                            if scale > 1 {
                                offset.width = lastOffset.width + value.translation.width
                                offset.height = lastOffset.height + value.translation.height
                                lastOffset = offset
                                
                                // Constrain the offset to prevent moving the image too far
                                let maxOffset = (scale - 1) * geometry.size.width / 2
                                offset.width = min(maxOffset, max(-maxOffset, offset.width))
                                offset.height = min(maxOffset, max(-maxOffset, offset.height))
                            }
                        }
                )
                .onTapGesture(count: 2) {
                    withAnimation {
                        if scale > 1 {
                            scale = 1
                            offset = .zero
                            lastOffset = .zero
                        } else {
                            scale = 2
                        }
                    }
                }
        }
    }
}
