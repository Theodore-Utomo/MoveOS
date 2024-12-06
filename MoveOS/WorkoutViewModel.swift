//
//  WeightViewModel.swift
//  MoveOS
//
//  Created by Theodore Utomo on 11/26/24.
//

import Foundation
import FirebaseFirestore

@MainActor //DO NOT REMOVE
@Observable
class WorkoutViewModel {
    static func saveWorkout(workout: Workout) async -> Workout? {
        let exercisePath = "weight"
        let db = Firestore.firestore()
        
        do {
            if let id = workout.id {
                // Update existing workout
                try db.collection(exercisePath).document(id).setData(from: workout)
                print("Workout updated successfully")
                return workout
            } else {
                // Add a new workout
                let docRef = try db.collection(exercisePath).addDocument(from: workout)
                print("New workout added successfully with ID: \(docRef.documentID)")
                let updatedWeight = workout
                updatedWeight.id = docRef.documentID // Assign Firestore ID to the weight
                return updatedWeight
            }
        } catch {
            print("Error saving workout: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func deleteWorkout(workout: Workout) async {
        let db = Firestore.firestore()
        guard let id = workout.id else {
            print("No workout id")
            return
        }
        
        Task {
            do {
                try await db.collection("weight").document(id).delete()
            } catch {
                print("Error: Could not delete document \(error.localizedDescription)")
            }
        }
    }
    
    static func deleteExerciseFromWorkout(workout: Workout, exerciseID: String) async -> Workout? {
        guard workout.id != nil else {
            print("No workout id found.")
            return nil
        }
        
        // Remove the exerciseID from the list of exerciseIDs
        if let index = workout.exerciseIDs.firstIndex(of: exerciseID) {
            workout.exerciseIDs.remove(at: index)
        } else {
            print("Exercise ID not found in the workout.")
            return nil
        }
        
        return await saveWorkout(workout: workout)
    }
    
    static func generateWorkoutFromSelectedMuscleGroups(muscleGroups: [String]) async -> Workout? {
        guard !muscleGroups.isEmpty else {
            print("No muscle groups selected.")
            return nil
        }
        
        let db = Firestore.firestore()
        let exercisesRef = db.collection("exercises")
        
        do {
            let querySnapshot = try await exercisesRef.getDocuments()
            var filteredExercises: [Exercise] = []
            
            for document in querySnapshot.documents {
                if let exercise = try? document.data(as: Exercise.self),
                   muscleGroups.contains(exercise.muscle.capitalized) {
                    filteredExercises.append(exercise)
                }
            }
            
            if filteredExercises.isEmpty {
                print("No exercises found for the selected muscle groups.") // Shouldn't ever come to this
                return nil
            }
            
            // Makes it more likely to choose exercise with higher number of sets
            var weightedExercises: [Exercise] = []
            for exercise in filteredExercises {
                let weight = max(exercise.sets?.count ?? 1, 1)
                for _ in 0..<weight {
                    weightedExercises.append(exercise)
                }
            }
            
            if weightedExercises.isEmpty {
                print("No weighted exercises available.")
                return nil
            }
            
            // Chooses first 5 random exercises
            let shuffledExercises = weightedExercises.shuffled()
            let groupedExercises = Dictionary(grouping: shuffledExercises, by: { $0.id }) // Remove duplicates to ensure workout is properly populated
            var uniqueExercises: [Exercise] = []
            for group in groupedExercises.values {
                if let firstExercise = group.first {
                    uniqueExercises.append(firstExercise)
                }
            }

            let selectedExercises = Array(uniqueExercises).prefix(5)
            let exerciseIDs = selectedExercises.compactMap { $0.id } // Make sure to get exercise ID, not exercise data type
            
            return Workout(
                workoutName: "Custom Workout",
                exerciseIDs: exerciseIDs
            )
        } catch {
            print("Error fetching exercises: \(error.localizedDescription)")
            return nil
        }
    }
}
