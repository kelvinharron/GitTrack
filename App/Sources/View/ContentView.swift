import MarkdownUI
import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState: AppState
    @State private var isShowingError = false

    private let authManager = GitHubAuthManager()

    var body: some View {
        VStack {
            Text("Welcome to GitTrack")
                .font(.largeTitle)

            switch appState.authState {
            case .idle:
                Button("Login with GitHub") {
                    onLoginClicked()
                }
            case .waitingForCode(let response):
                VStack(spacing: 8) {
                    Text("1. Visit GitHub to authorize:")

                    Link("https://github.com/login/device", destination: URL(string: "https://github.com/login/device")!)
                        .foregroundColor(.blue)
                        .font(.body)

                    Text("2. Enter this code:")
                    HStack(spacing: 8) {
                        Text(response.userCode)
                            .font(.headline)
                            .padding(.horizontal)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(5)

                        Button(action: {
                            let pasteboard = NSPasteboard.general
                            pasteboard.clearContents()
                            pasteboard.setString(response.userCode, forType: .string)
                        }) {
                            Image(systemName: "doc.on.doc")
                            Text("Copy")
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    .onAppear {
                        subscribeForAuthentication(from: response)
                    }
                }
            case .authenticated:
                HomeView()
            default:
                EmptyView()
            }
        }
        .animation(.default, value: appState.authState)
    }

    private func onLoginClicked() {
        Task {
            do {
                let response = try await authManager.startDeviceAuthorization()
                appState.authState = .waitingForCode(response)
            } catch {
                print("Authentication error: \(error)")
                isShowingError = true
            }
        }
    }

    private func subscribeForAuthentication(from response: DeviceResponse) {
        Task {
            do {
                let response = try await authManager.pollForAccessToken(from: response)
                try await appState.exchangeCodeForToken(with: response)
            } catch {
                print("Polling error: \(error)")
                isShowingError = true
            }
        }
    }
}

#Preview {
    ContentView()
}
