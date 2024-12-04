//
//  WeightDetailView.swift
//  MoveOS
//
//  Created by Theodore Utomo on 11/26/24.
//

import SwiftUI
import FirebaseFirestore

struct WorkoutDetailView: View {
    @FirestoreQuery(collectionPath: "exercises") var exerciseQuery: [Exercise]
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var exerciseSheet = false
    @State private var workoutName: String = ""
    @State var workout: Workout
    @State private var exercises: [String] = []
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Workout Name")
                        .font(.headline)
                    
                    TextField("Enter workout name", text: $workoutName)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                        .frame(height: 20)
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Exercises")
                            .font(.headline)
                        
                        Spacer()
                        Button {
                            exerciseSheet.toggle()
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Exercise")
                            }
                            .foregroundStyle(.blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    if exercises.isEmpty {
                        Text("No exercises added yet.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                            .padding(.top, 10)
                    } else {
                        ExerciseList(exercises: exerciseQuery.filter { exercises.contains($0.id ?? "") }, workout: $workout)
                    }
                }
                
                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Back") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        workout.workoutName = workoutName
                        Task {
                            if let updatedWorkout = await WorkoutViewModel.saveWorkout(workout: workout) {
                                workout = updatedWorkout
                            }
                            dismiss()
                        }
                    }
                }
            }
            .onChange(of: workout.exerciseIDs) {
                exercises = workout.exerciseIDs
            }
            .onAppear {
                workoutName = workout.workoutName
                exercises = workout.exerciseIDs
            }
            .sheet(isPresented: $exerciseSheet) {
                NavigationStack {
                    ExerciseListViewForAddingToWorkout(workout: $workout)
                }
            }
            .navigationBarBackButtonHidden()
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        }
    }
}

struct ExerciseList: View {
    let exercises: [Exercise]
    @Binding var workout: Workout
    @State private var selectedExercise: Exercise?
    var body: some View {
        List(exercises) { exercise in
            LazyVStack(alignment: .leading){
                NavigationLink {
                    ExerciseDetailView(exercise: exercise)
                } label: {
                    ExerciseRowView(exercise: exercise)
                }
                .swipeActions {
                    Button("Delete", role: .destructive) {
                        Task {
                            if let updatedWorkout = await WorkoutViewModel.deleteExerciseFromWorkout(workout: workout, exerciseID: exercise.id!) {
                                workout = updatedWorkout
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}
#Preview {
    NavigationStack {
        WorkoutDetailView(workout: Workout())
    }
}
