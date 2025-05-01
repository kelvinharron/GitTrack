import MarkdownUI
import SwiftUI

struct ContentView: View {
    @State private var isShowingError = false

    private let authManager = GitHubAuthManager()

    var body: some View {
        VStack {
            Text("Welcome to GitTrack")
                .font(.largeTitle)

            Button("Login to GitHub") {
                onLoginClicked()
            }
        }
    }

    private func onLoginClicked() {
        authManager.startAuthorization { result in
            switch result {
            case .success(let code):
                print("Authorization successful with code: \(code)")
            case .failure(let error):
                print("Authorization failed with error: \(error.localizedDescription)")
                isShowingError = true
            }
        }
    }
}

#Preview {
    ContentView()
}
