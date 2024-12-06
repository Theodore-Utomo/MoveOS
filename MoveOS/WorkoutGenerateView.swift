//
//  WorkoutGenerateView.swift
//  MoveOS
//
//  Created by Theodore Utomo on 12/5/24.
//

import SwiftUI
import FirebaseFirestore

struct WorkoutGenerateView: View {
    @FirestoreQuery(collectionPath: "exercises") var exercises: [Exercise]
    @Environment(\.dismiss) private var dismiss
    @State private var muscleGroups: [String] = []
    @State private var selectedMuscleGroups: [String] = []
    @State private var generatedWorkout: Workout?
    @State private var workoutDetailSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Select up to 3 Muscle Groups")
                    .font(.headline)
                    .padding()
                
                List(muscleGroups, id: \.self) { muscleGroup in
                    HStack {
                        Text(muscleGroup)
                        
                        Spacer()
                        
                        if selectedMuscleGroups.contains(muscleGroup) {
                            Image(systemName: "checkmark.square")
                                .foregroundStyle(.primary)
                        } else {
                            Image(systemName: "square")
                                .foregroundStyle(.primary)
                        }
                    }
                    .clipShape(Rectangle())
                    .onTapGesture {
                        toggleMuscleGroupSelection(muscleGroup)
                    }
                }
                .listStyle(.plain)
                Spacer()
                Button("Generate Workout With Selected Exercises") {
                    Task {
                        if let workout = await WorkoutViewModel.generateWorkoutFromSelectedMuscleGroups(muscleGroups: selectedMuscleGroups) {
                            generatedWorkout = workout
                        } else {
                            print("Workout generation failed.")
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .disabled(selectedMuscleGroups.isEmpty)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .sheet(item: $generatedWorkout) { workout in
            WorkoutDetailView(workout: workout)
        }
        .task {
            populateMuscleGroupsWithUserExerciseData()
        }
    }
    
    private func populateMuscleGroupsWithUserExerciseData() {
        var uniqueMuscleGroups = Swift.Set<String>()
        for exercise in exercises {
            uniqueMuscleGroups.insert(exercise.muscle.capitalized)
        }
        muscleGroups = Array(uniqueMuscleGroups).sorted()
    }
    private func toggleMuscleGroupSelection(_ muscleGroup: String) {
        if selectedMuscleGroups.contains(muscleGroup) {
            selectedMuscleGroups.removeAll { $0 == muscleGroup }
        } else if selectedMuscleGroups.count < 3 {
            selectedMuscleGroups.append(muscleGroup)
        }
    }
}

#Preview {
    WorkoutGenerateView()
}
