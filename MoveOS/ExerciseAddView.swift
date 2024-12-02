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
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Search Exercises", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onChange(of: searchText) {
                        Task {
                            await exerciseVM.searchExercises(query: searchText)
                        }
                    }
                List {
                    ForEach(exerciseVM.searchedExercises) { searchedExercise in
                        Button {
                            Task {
                                await ExerciseViewModel.addExerciseToFirestore(searchedExercise: searchedExercise)
                                dismiss()
                            }
                        } label: {
                            Text(searchedExercise.name)
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
            }
        }
        .navigationTitle("Select an Exercises")
        .task {
            await exerciseVM.searchExercises(query: "hammer")
        }
    }
}

#Preview {
    NavigationStack {
        ExerciseAddView()
    }
}
