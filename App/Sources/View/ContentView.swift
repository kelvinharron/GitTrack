import SwiftUI
import MarkdownUI

struct ContentView: View {
    @State private var personalAccessToken = ""
    @State private var releases = [ReleaseResponse]()

    private let apiClient = GitHubAPIClient()

    var body: some View {
        VStack {
            List(releases, id: \.id) { release in
                HStack {
                    Text(release.name)
                        .font(.headline)
                    Spacer()
                    Text(release.createdAt.formatted())
                        .font(.callout)
                }
                if let releaseText = release.body {
                    Markdown(releaseText)
                }
            }
            TextField("Paste your PAT", text: $personalAccessToken)

            Button("Make a request") {
                Task {
                    do {
                        let releases = try await apiClient.fetchReleases(
                            owner: "tuist",
                            repo: "tuist",
                            token: personalAccessToken
                        )
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
