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

    var body: some View {
        NavigationStack {
            VStack {
                if let userName = appState.userName {
                    Text("Hello \(userName)")
                }
                List {
                    ForEach(appState.projects, id: \.self) {
                        Text($0.name)
                            .onTapGesture {}
                    }
                }
            }
            Button("Create a Project") {
                isAddingProject.toggle()
            }
        }
        .sheet(isPresented: $isAddingProject) {
            TextField("Project Name", text: $newProjectName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button("Save Project") {
                appState.createProject(with: newProjectName)
                isAddingProject = false
            }
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
