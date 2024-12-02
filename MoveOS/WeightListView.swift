//
//  WeightListView.swift
//  MoveOS
//
//  Created by Theodore Utomo on 11/25/24.
//

import SwiftUI
import FirebaseFirestore

struct WeightListView: View {
    @FirestoreQuery(collectionPath: "weight") var workouts: [Weight]
    
    @State private var weightSheetIsPresented = false
    
    var body: some View {
        NavigationStack {
            List(workouts) { workout in
                NavigationLink {
                    WeightDetailView(weight: workout)
                } label: {
                    Text("\(workout.workoutName)")
                }
                .swipeActions {
                    Button("Delete", role: .destructive) {
                        Task {
                            await WeightViewModel.deleteWorkout(weight: workout)
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("Workouts")
        .sheet(isPresented: $weightSheetIsPresented) {
            NavigationStack {
                WeightDetailView(weight: Weight())
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add Workout") {
                    weightSheetIsPresented.toggle()
                }
            }
        }
        
    }
}

#Preview {
    NavigationStack {
        WeightListView()
    }
}
