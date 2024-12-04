//
//  ExerciseListViewForAddingToWorkout.swift
//  MoveOS
//
//  Created by Theodore Utomo on 12/1/24.
//

import SwiftUI
import FirebaseFirestore

struct ExerciseListViewForAddingToWorkout: View {
    @FirestoreQuery(collectionPath: "exercises") var exercises: [Exercise]
    @Environment(\.dismiss) private var dismiss
    @Binding var workout: Workout
    @State private var sheetIsPresented = false
    
    var body: some View {
            NavigationStack {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Your Exercises")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        Text("Select exercises to add to your workout.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                    }
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Exercise List
                    if exercises.isEmpty {
                        VStack {
                            Spacer()
                            Text("No exercises available.")
                                .font(.headline)
                                .foregroundStyle(.gray)
                                .multilineTextAlignment(.center)
                            Spacer()
                        }
                    } else {
                        List {
                            ForEach(exercises) { exercise in
                                Button {
                                    if let exerciseID = exercise.id, !workout.exerciseIDs.contains(exerciseID) {
                                        Task {
                                            workout.exerciseIDs.append(exerciseID)
                                            if let updatedWeight = await WorkoutViewModel.saveWorkout(workout: workout) {
                                                workout = updatedWeight
                                            }
                                            dismiss()
                                        }
                                    }
                                } label: {
                                    ExerciseRowView(exercise: exercise)
                                }
                                .foregroundStyle(.primary)
                            }
                        }
                        .listStyle(.insetGrouped)
                    }
                }
                .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
                .toolbar {
                    // Cancel Button
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") { dismiss() }
                            .font(.headline)
                            .foregroundStyle(.red)
                    }
                    // Add New Exercise Button
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            sheetIsPresented.toggle()
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Exercise")
                            }
                            .font(.headline)
                        }
                    }
                }
                .sheet(isPresented: $sheetIsPresented) {
                    ExerciseAddView()
                }
            }
            .navigationTitle("Add to Workout")
            .navigationBarTitleDisplayMode(.inline)
        }

}

#Preview {
    ExerciseListViewForAddingToWorkout(workout: .constant(Workout()))
}
