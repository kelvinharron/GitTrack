import SwiftUI

struct ContentView: View {
    @State private var personalAccessToken = ""
    @State private var tuistReleases = ""
    private let apiClient = APIClient()
    
    var body: some View {
        TextField("Paste your PAT", text: $personalAccessToken)
        
        Button("Make a request") {
            // TODO: implement a fetch request for releases
        }
        .disabled(personalAccessToken.isEmpty)
    }
}


#Preview {
    ContentView()
}
