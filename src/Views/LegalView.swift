import SwiftUI

struct LegalView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Copyright")
                        .scaledFont(.title2)
                        .fontWeight(.bold)
                    
                    Text("The Seventh-day Adventist Hymnal")
                        .scaledFont(.headline)
                    
                    Text("Copyright 1985 by Review and Herald Publishing Association.\n\nAll rights reserved. Used by permission of the copyright holder.")
                        .scaledFont(.body)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Notice")
                        .scaledFont(.title2)
                        .fontWeight(.bold)
                    
                    Text("This app is not an official product of the Seventh-day Adventist Church or any of its affiliated organizations. It is provided as a free service to facilitate access to hymnal content for personal worship and study.")
                        .scaledFont(.body)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("1941 Church Hymnal")
                        .scaledFont(.title2)
                        .fontWeight(.bold)
                    
                    Text("The Church Hymnal: Official Hymnal of the Seventh-day Adventist Church\n\nCopyright 1941 by Review and Herald Publishing Association.")
                        .scaledFont(.body)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("App Development")
                        .scaledFont(.title2)
                        .fontWeight(.bold)
                    
                    Text("This application was developed independently and is provided free of charge. While every effort has been made to ensure accuracy, we welcome any corrections or improvements.")
                        .scaledFont(.body)
                }
            }
            .padding()
        }
        .navigationTitle("Legal Information")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        LegalView()
    }
}
