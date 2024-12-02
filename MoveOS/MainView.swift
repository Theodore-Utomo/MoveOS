//
//  MainView.swift
//  MoveOS
//
//  Created by Theodore Utomo on 11/25/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct MainView: View {
    @FirestoreQuery(collectionPath: "weight") var workouts: [Weight]
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var weightSheetIsPresented = false
        
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    NavigationLink {
                        ExerciseListView()
                    } label: {
                        Text("My Exercises")
                    }
                    
                    Section {
                        NavigationLink {
                            WeightListView()
                        } label: {
                            Text("View All Weightlifting Workouts")
                                .bold()
                        }
                        
                        Button("Add New Workout") {
                            weightSheetIsPresented.toggle()
                        }
                        
                        ForEach(workouts) { workout in
                            NavigationLink {
                                WeightDetailView(weight: workout)
                            } label: {
                                Text(workout.workoutName)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.primary)
                            }
                        }
                        .onDelete { indexSet in
                            deleteWorkout(at: indexSet)
                        }
                    } header: {
                        Text("Workouts - Weights")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Sign Out") {
                        do {
                            try Auth.auth().signOut()
                            print("Sign out successfull")
                            dismiss()
                        } catch {
                            print("Sign out unsuccessful. ERROR: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
        .navigationTitle("Your Movements")
        .navigationBarBackButtonHidden()
        .sheet(isPresented: $weightSheetIsPresented) {
            NavigationStack {
                WeightDetailView(weight: Weight())
            }
        }
    }
    
    private func deleteWorkout(at indexSet: IndexSet) {
        indexSet.forEach { index in
            let workout = workouts[index]
            Task {
                await WeightViewModel.deleteWorkout(weight: workout)
            }
        }
    }
}


#Preview {
    NavigationStack {
        MainView()
    }
}
