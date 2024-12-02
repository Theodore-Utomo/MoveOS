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
    @Binding var weight: Weight
    
    @State private var sheetIsPresented = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(exercises) { exercise in
                    Button {
                        if let exerciseID = exercise.id, !weight.exerciseIDs.contains(exerciseID) {
                            Task {
                                weight.exerciseIDs.append(exerciseID)
                                if let updatedWeight = await WeightViewModel.saveWorkout(weight: weight) {
                                    weight = updatedWeight
                                }
                                dismiss()
                            }
                        }
                    } label: {
                        Text(exercise.name)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Exercise") {
                        sheetIsPresented.toggle()
                    }
                }
            }
        }
        .sheet(isPresented: $sheetIsPresented) {
            ExerciseAddView()
        }
        .navigationTitle("Your Exercises")
    }
}

#Preview {
    ExerciseListViewForAddingToWorkout(weight: .constant(Weight()))
}
