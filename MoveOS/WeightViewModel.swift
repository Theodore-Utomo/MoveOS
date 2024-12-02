//
//  WeightViewModel.swift
//  MoveOS
//
//  Created by Theodore Utomo on 11/26/24.
//

import Foundation
import FirebaseFirestore

@Observable
class WeightViewModel {
    static func saveWorkout(weight: Weight) async -> Weight? {
        let exercisePath = "weight"
        let db = Firestore.firestore()
        
        do {
            if let id = weight.id {
                // Update existing workout
                try db.collection(exercisePath).document(id).setData(from: weight)
                print("Workout updated successfully")
                return weight
            } else {
                // Add a new workout
                let docRef = try db.collection(exercisePath).addDocument(from: weight)
                print("New workout added successfully with ID: \(docRef.documentID)")
                let updatedWeight = weight
                updatedWeight.id = docRef.documentID // Assign Firestore ID to the weight
                return updatedWeight
            }
        } catch {
            print("Error saving workout: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func deleteWorkout(weight: Weight) async {
        let db = Firestore.firestore()
        guard let id = weight.id else {
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
}
