//
//  ExerciseAddView.swift
//  MoveOS
//
//  Created by Theodore Utomo on 11/27/24.
//

import SwiftUI
import FirebaseFirestore

struct ExerciseAddView: View {
    @FirestoreQuery(collectionPath: "exercises") var exercises: [Exercise]
    @Environment(\.dismiss) private var dismiss
    @State private var exerciseVM = ExerciseViewModel()
    @State private var searchText = ""
    @State private var showCreateExerciseSheet = false
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Search Exercises")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    TextField("Search for an exercise (e.g., Squat)", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                        .padding(.bottom)
                        .onChange(of: searchText) {
                            Task {
                                await exerciseVM.searchExercises(query: searchText)
                            }
                        }
                }
                .padding(.top)
                
                if exerciseVM.searchedExercises.isEmpty {
                    VStack {
                        Spacer()
                        Text("No exercises found.")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                } else {
                    List(exerciseVM.searchedExercises) { searchedExercise in
                        LazyVStack(alignment: .leading) {
                            Button {
                                Task {
                                    await ExerciseViewModel.addExerciseToFirestore(searchedExercise: searchedExercise)
                                    dismiss()
                                }
                            } label: {
                                Text("\(searchedExercise.name)")
                                    .font(.headline)
                            }
                            .foregroundStyle(.primary)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
                
                Button {
                    showCreateExerciseSheet.toggle()
                } label: {
                    Text("Don't see the exercise you want? \nCreate a new exercise")
                        .font(.headline)
                        .foregroundStyle(.blue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor.systemGroupedBackground))
                        .cornerRadius(8)
                }
                .padding(.horizontal)
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundStyle(.blue)
                }
            }
        }
        .navigationTitle("Add Exercise")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showCreateExerciseSheet) {
            CreateExerciseView()
        }
        .task {
            await exerciseVM.searchExercises(query: "bench")
        }
    }
}

struct CreateExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var muscle: String = ""
    @State private var instructions: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Exercise Name", text: $name)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.words)
                        .autocorrectionDisabled()
                        .keyboardType(.default)
                        .padding(.vertical, 5)
                    TextField("Muscle Group", text: $muscle)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.words)
                        .autocorrectionDisabled()
                        .keyboardType(.default)
                        .padding(.vertical, 5)
                    TextField("Instructions", text: $instructions)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.sentences)
                        .autocorrectionDisabled()
                        .keyboardType(.default)
                        .padding(.vertical, 5)
                } header: {
                    Text("Exercise Details")
                }
            }
            .navigationTitle("Create Exercise")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        Task {
                            await saveCustomExercise()
                            dismiss()
                        }
                    }
                }
            }
        }
    }
    
    private func saveCustomExercise() async {
        let newExercise = SearchedExercise(
            name: name,
            muscle: muscle,
            instructions: instructions,
            type: "Custom"
        )
        await ExerciseViewModel.addExerciseToFirestore(searchedExercise: newExercise)
    }
}

#Preview {
    NavigationStack {
        ExerciseAddView()
    }
}
