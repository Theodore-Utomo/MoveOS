//
//  WeightDetailView.swift
//  MoveOS
//
//  Created by Theodore Utomo on 11/26/24.
//

import SwiftUI
import FirebaseFirestore

struct WeightDetailView: View {
    @FirestoreQuery(collectionPath: "exercises") var exerciseQuery: [Exercise]
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var exerciseSheet = false
    @State private var workoutName: String = ""
    @State var weight: Weight
    @State private var exercises: [String] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Workout name", text: $workoutName)
                List {
                    Section {
                        Button("Add Exercise") {
                            exerciseSheet.toggle()
                        }
                        ForEach(exerciseQuery) { exercise in
                            if let exerciseID = exercise.id, exercises.contains(exerciseID) {
                                NavigationLink {
                                    ExerciseDetailView(exercise: exercise)
                                } label: {
                                    Text("\(exercise.name)")
                                }
                            }
                        }
                    } header: {
                        Text("Exercises")
                    }
                }
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        weight.workoutName = workoutName
                        Task {
                            if let updatedWeight = await WeightViewModel.saveWorkout(weight: weight) {
                                weight = updatedWeight
                            }
                            dismiss()
                        }
                    }
                }
            }
            .onChange(of: weight.exerciseIDs) {
                exercises = weight.exerciseIDs
            }
            .onAppear {
                workoutName = weight.workoutName
                exercises = weight.exerciseIDs
            }
            .sheet(isPresented: $exerciseSheet) {
                NavigationStack {
                    ExerciseListViewForAddingToWorkout(weight: $weight)
                }
            }
            .navigationBarBackButtonHidden()
        }
    }
}

#Preview {
    NavigationStack {
        WeightDetailView(weight: Weight())
    }
}
