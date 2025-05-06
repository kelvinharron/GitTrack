//
//  HomeView.swift
//  GitTrack
//
//  Created by Kelvin Harron on 26/04/2025.
//

import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) var appState: AppState

    @State private var isAddingProject = false
    @State private var newProjectName = ""
    @State private var isAddingRepositoryForProject: Project? = nil
    @State private var newRepositoryURL = ""
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var selectedProject: Project? = nil
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack {
                if let userName = appState.userName {
                    Text("Hello \(userName)")
                }
                List {
                    ForEach(appState.projects, id: \.self) { project in
                        Button {
                            navigationPath.append(project)
                        } label: {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(project.name)
                                        .font(.headline)
                                }
                                if !project.repositories.isEmpty {
                                    ForEach(project.repositories, id: \.id) { repo in
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(repo.name)
                                                .font(.subheadline)
                                            Text(repo.url.absoluteString)
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                            if let tag = repo.latestTag {
                                                Text("Latest Tag: \(tag)")
                                                    .font(.caption2)
                                                    .foregroundColor(.green)
                                            }
                                        }
                                        .padding(.vertical, 2)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationDestination(for: Project.self) { project in
                ProjectDetailView(project: project)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Create a Project") {
                        isAddingProject.toggle()
                    }
                }
            }
        }
        .sheet(isPresented: $isAddingProject) {
            VStack {
                TextField("Project Name", text: $newProjectName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Button("Save Project") {
                    let trimmedName = newProjectName.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmedName.isEmpty else { return }
                    appState.createProject(with: trimmedName)
                    newProjectName = ""
                    isAddingProject = false
                }
            }
        }
        .sheet(item: $isAddingRepositoryForProject) { project in
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
                        isAddingRepositoryForProject = nil
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
                                isAddingRepositoryForProject = nil
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

#Preview {
    let appState = AppState()
    let project = Project(
        name: "EHR",
        repositories: []
    )
    
    
    
    HomeView()
        .environment(appState)
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
