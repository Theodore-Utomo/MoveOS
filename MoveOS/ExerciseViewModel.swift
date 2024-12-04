//
//  ExerciseViewModel.swift
//  MoveOS
//
//  Created by Theodore Utomo on 11/26/24.
//

import Foundation
import FirebaseFirestore


@Observable
class ExerciseViewModel {
    var searchedExercises: [SearchedExercise] = []
    var isLoading = false
    var urlString = ""
    
    static func saveExercise(exercise: Exercise) async -> String? {
        let exercisePath = "exercises"
        let db = Firestore.firestore()
        
        if let id = exercise.id { //If true the place exists
            do {
                try db.collection(exercisePath).document(id).setData(from: exercise)
                print("Cool emoji. Exercise updated successfully")
                return id
            } catch {
                print("Angry emoji. Error: \(error.localizedDescription)")
                return id
            }
        } else { //If place doesn't exist - new document to be added to the places collection
            do {
                let docRef = try db.collection(exercisePath).addDocument(from: exercise)
                print("Happy emoji. Data added successfully")
                print(docRef.documentID)
                return docRef.documentID
            } catch {
                print("Angry Emoji. Error, could not create a new exercise: \(error.localizedDescription)")
                return nil
            }
        }
    }
    
    static func deleteExercise(exercise: Exercise) async {
        let db = Firestore.firestore()
        guard let id = exercise.id else {
            print("No exercise id")
            return
        }
        
        Task {
            do {
                try await db.collection("exercises").document(id).delete()
            } catch {
                print("Error: Could not delete exercise \(error.localizedDescription)")
            }
        }
    }
    
    static func addExerciseToFirestore(searchedExercise: SearchedExercise) async {
        let db = Firestore.firestore()
        let exerciseCollection = db.collection("exercises")
        
        // Check if an exercise with the same name already exists
        do {
            let querySnapshot = try await exerciseCollection
                .whereField("name", isEqualTo: searchedExercise.name)
                .getDocuments()
            
            if !querySnapshot.isEmpty {
                print("An exercise with the name '\(searchedExercise.name)' already exists in the database.")
                return
            }
        } catch {
            print("Error checking for existing exercise: \(error.localizedDescription)")
            return
        }
        
        let newExercise = Exercise(
            id: nil,
            name: searchedExercise.name,
            sets: [],
            muscle: searchedExercise.muscle,
            instructions: searchedExercise.instructions
        )
        
        let _ = await saveExercise(exercise: newExercise)
        print("Exercise successfully added to Firestore!")
    }
    
    func searchExercises(query: String) async {
        isLoading = true
        urlString = "https://api.api-ninjas.com/v1/exercises?name=\(query)"
        print("We are accessing the URL")
        
        guard let url = URL(string: urlString) else {
            print("Could not create a URL from \(urlString)\n")
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("78TjuTUcugi4mUfazdmsMQ==TSWQ5aF7IEHjXFkq", forHTTPHeaderField: "X-Api-Key")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("Raw Response: \(responseString)")
            }
            
            let newExercises = try JSONDecoder().decode([SearchedExercise].self, from: data)
            
            await MainActor.run {
                self.searchedExercises = newExercises
                self.isLoading = false
            }
            
            print("JSON Returned\n")
            
        } catch {
            print("Could not decode data from \(urlString): \(error.localizedDescription)")
            
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
    
    static func addSet(exercise: Exercise, set: Set) async {
        let newExercise = exercise
        if newExercise.sets == nil {
            newExercise.sets = []
        }
        newExercise.sets?.append(set)
        let _ = await saveExercise(exercise: newExercise)
    }
    
    struct GraphDataPoint: Identifiable {
        let id = UUID() // Generate a unique ID for each data point
        let x: Int
        let y: Double
    }
    
    static func generateGraphDataForVolume(for exercise: Exercise) -> [GraphDataPoint] {
        guard let sets = exercise.sets else { return [] }
        return sets.enumerated().map { (index, set) in
            let totalVolume = set.weight * Double(set.reps)
            return GraphDataPoint(x: index, y: totalVolume)
        }
    }
    
    static func generateAverageRepsData(for exercise: Exercise) -> [GraphDataPoint] {
        guard let sets = exercise.sets else { return [] }

        // Group sets by weight
        let groupedByWeight = Dictionary(grouping: sets, by: { $0.weight })

        var averageRepsPerWeight: [GraphDataPoint] = []
        for (weight, sets) in groupedByWeight {
            let totalReps = sets.reduce(0) { $0 + $1.reps }
            let averageReps = Double(totalReps) / Double(sets.count)
            averageRepsPerWeight.append(GraphDataPoint(x: Int(weight), y: averageReps))
        }

        let sortedData = averageRepsPerWeight.sorted { $0.x < $1.x }
        
        let limitedData = sortedData.prefix(5)
        
        return Array(limitedData)
    }
}

