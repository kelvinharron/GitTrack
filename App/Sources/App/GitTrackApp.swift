import AppKit
import SwiftUI

@main
struct GitTrackApp: App {
    @State private var appState = AppState()
    @State private var personalAccessToken = ""
    @State private var isAddingPersonalAccessToken = false
    private let apiClient = GitHubAPIClient()
    
    var body: some Scene {
        MenuBarExtra("GitTrack", systemImage: "star") {
            Group {
                VStack {
                    if !appState.isAuthenticated {
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
                                            let _ = try await apiClient.fetchUser(with: personalAccessToken)
                                            // save PAT
                                            // save user
                                        } catch {
                                            print(error) // FIXME: handle error with popover state
                                        }
                                    }
                                }
                                .disabled($personalAccessToken.wrappedValue.isEmpty)
                            }
                            .padding()
                        }
                        .padding()
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
        }
        .menuBarExtraStyle(.window)
    }
}
