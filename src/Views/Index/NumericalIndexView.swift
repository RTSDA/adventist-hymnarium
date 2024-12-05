import SwiftUI

struct NumericalIndexView: View {
    @StateObject private var viewModel = IndexViewModel()
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.error {
                ErrorView(error: error)
            } else {
                List(viewModel.sortedHymns) { hymn in
                    NavigationLink(destination: HymnDetailView(hymn: hymn)) {
                        HStack {
                            Text("#\(hymn.number)")
                                .font(AppTheme.standardFont)
                                .foregroundColor(AppTheme.accentColor)
                                .frame(width: 50, alignment: .trailing)
                            
                            Text(hymn.title)
                                .font(AppTheme.standardFont)
                                .foregroundColor(AppTheme.textColor)
                        }
                    }
                }
                .navigationTitle("Numerical Index")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .onAppear {
            viewModel.loadData()
        }
    }
}

#Preview {
    NavigationView {
        NumericalIndexView()
    }
}
