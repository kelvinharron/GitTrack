import SwiftUI

struct ProjectDetailView: View {
    @Environment(AppState.self) var appState: AppState
    let sproject: Project

    @State private var isAddingRepository = false
    @State private var newRepositoryURL = ""
    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(project.name)
                .font(.largeTitle)
                .padding(.top)
            Divider()

            HStack {
                Text("Repositories")
                    .font(.title2)
                Spacer()
                Button(action: {
                    isAddingRepository = true
                }) {
                    Label("Add Repository", systemImage: "plus.circle.fill")
                }
            }

            if project.repositories.isEmpty {
                Text("No repositories yet.")
                    .foregroundColor(.secondary)
            } else {
                List {
                    ForEach(project.repositories, id: \.id) { repo in
                        VStack(alignment: .leading) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(repo.name)
                                        .font(.headline)
                                    Text(repo.url.absoluteString)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    if let tag = repo.latestTag {
                                        Text("Latest Tag: \(tag)")
                                            .font(.caption2)
                                            .foregroundColor(.green)
                                    }
                                }
                                Spacer()
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
                .listStyle(.inset)
            }
            Spacer()
        }
        .padding()
        .sheet(isPresented: $isAddingRepository) {
            VStack(spacing: 16) {
                Text("Add Repository to \(project.name)")
                    .font(.headline)
                TextField("GitHub URL (https://github.com/owner/repo)", text: $newRepositoryURL)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }
                HStack {
                    Button("Cancel") {
                        isAddingRepository = false
                    }
                    Spacer()
                    if isLoading {
                        ProgressView()
                    } else {
                        Button("Add") {
                            errorMessage = nil
                            let trimmedURL = newRepositoryURL.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmedURL.isEmpty else {
                                errorMessage = "Repository URL cannot be empty."
                                return
                            }
                            guard isValidGitHubURL(trimmedURL) else {
                                errorMessage = "Please enter a valid GitHub repository URL (https://github.com/owner/repo) or owner/repo."
                                return
                            }
                            isLoading = true
                            Task {
                                await appState.addRepository(to: project, fromGitHubURL: trimmedURL)
                                isLoading = false
                                isAddingRepository = false
                                newRepositoryURL = ""
                            }
                        }
                        .disabled(newRepositoryURL.isEmpty || isLoading)
                    }
                }
                .padding(.horizontal)
            }
            .padding()
            .frame(width: 400)
        }
    }
}

private func isValidGitHubURL(_ urlString: String) -> Bool {
    // Accepts https://github.com/owner/repo or owner/repo
    let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.isEmpty { return false }
    if let url = URL(string: trimmed), url.host == "github.com" {
        let comps = url.path.split(separator: "/")
        return comps.count == 2 && !comps.contains(where: { $0.isEmpty })
    } else if trimmed.contains("/") {
        let parts = trimmed.split(separator: "/")
        return parts.count == 2 && !parts.contains(where: { $0.isEmpty })
    }
    return false
}

#Preview {
    let appState = AppState()
    let project = Project(name: "Sample Project", repositories: [])
    return ProjectDetailView(project: project)
        .environment(appState)
}
