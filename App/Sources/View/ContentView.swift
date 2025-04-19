import SwiftUI

struct ContentView: View {
    @State private var personalAccessToken = ""
    @State private var releases = [ReleaseResponse]()

    private let apiClient = GitHubAPIClient()

    var body: some View {
        VStack {
            List(releases, id: \.id) { release in
                Text(release.name)
                    .font(.headline)
                Text(release.body ?? "")
                    .font(.body)
    
            }
            TextField("Paste your PAT", text: $personalAccessToken)

            Button("Make a request") {
                Task {
                    do {
                        let releases = try await apiClient.fetchReleases(owner: "tuist", repo: "tuist", token: personalAccessToken)
                        await MainActor.run {
                            self.releases = releases
                        }
                    } catch {
                        if let apiError = error as? APIError {
                            print(apiError.description)
                        } else {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
            .disabled(personalAccessToken.isEmpty)
        }
    }
}

#Preview {
    ContentView()
}
