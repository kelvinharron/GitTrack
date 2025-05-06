import SwiftUI

struct ProjectDetailView: View {
    let project: Project
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(project.name)
                .font(.largeTitle)
                .padding(.top)
            Divider()
            Text("Repositories")
                .font(.title2)
            if project.repositories.isEmpty {
                Text("No repositories yet.")
                    .foregroundColor(.secondary)
            } else {
                List(project.repositories, id: \.id) { repo in
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
                    .padding(.vertical, 2)
                }
                .listStyle(.inset)
            }
            Spacer()
        }
        .padding()
    }
}

#Preview {
    let project = Project(name: "Sample Project", repositories: [])
    ProjectDetailView(project: project)
} 