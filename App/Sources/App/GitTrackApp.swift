import AppKit
import SwiftUI

@main
struct GitTrackApp: App {
    @State private var appState = AppState()
    @State private var personalAccessToken = ""
    @State private var isShowingError = false
    @State private var isAddingPersonalAccessToken = false
    private let apiClient = GitHubAPIClient()
    
    var body: some Scene {
        MenuBarExtra("GitTrack", systemImage: "star") {
            Group {
                VStack {
                    switch appState.authState {
                    case .idle:
                        welcomeView
                    case .authenticated(let username):
                        Text("Hello, \(username)!")
                            .font(.largeTitle)
                            .padding()
                    case .error(let message):
                        Text("Error: \(message)")
                            .font(.headline)
                            .foregroundColor(.red)
                            .padding()
                    default: Text("Not implemented")
                    }
                    
                    Spacer()
                    Button("Quit") {
                        NSApplication.shared.terminate(nil)
                    }
                    .keyboardShortcut("q")
                }
            }
            .padding()
            .frame(minWidth: 300, minHeight: 400)
            .alert("Failed to verify PAT", isPresented: $isShowingError, actions: {
                Text("Oh no! Something went wrong.")
            })
        }
        .menuBarExtraStyle(.window)
    }
    
    @ViewBuilder
    private var welcomeView: some View {
        Text("Welcome to GitTrack")
            .font(.largeTitle)
            
        Button("Login to GitHub") {
            isAddingPersonalAccessToken.toggle()
        }
        .popover(isPresented: $isAddingPersonalAccessToken) {
            VStack {
                Text("Add Personal Access Token")
                    .font(.headline)
                if let url = URL(string: "https://github.com/settings/personal-access-tokens/new") {
                    Link("Generate a Personal Access Token with the 'Public repositories' access or 'Repo scope'.", destination: url)
                }
                
                TextField("Paste your Personal Access Token", text: $personalAccessToken)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("Verify Token") {
                    Task {
                        do {
                            try await appState.verifyAuthentication(using: personalAccessToken)
                        } catch {
                            isAddingPersonalAccessToken.toggle()
                            isShowingError.toggle()
                        }
                    }
                }
                .disabled($personalAccessToken.wrappedValue.isEmpty)
            }
            .padding()
        }
        .padding()
    }
}
