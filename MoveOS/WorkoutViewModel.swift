//
//  WeightViewModel.swift
//  MoveOS
//
//  Created by Theodore Utomo on 11/26/24.
//

import Foundation
import FirebaseFirestore

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
}
