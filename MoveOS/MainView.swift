//
//  MainView.swift
//  MoveOS
//
//  Created by Theodore Utomo on 11/25/24.
//

import SwiftUI
import FirebaseAuth

struct MainView: View {
    @Environment(\.dismiss) private var dismiss
    
    let cardioExercises = ["Running", "Swimming", "Jumping Jacks", "Cycling", "Rowing", "Stair Climbing", "Elliptical"]
    let weightExercises = ["Chest", "Legs", "Back", "Arms"]
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section(header: Text("Workouts - Cardio")) {
                        Button("View All Cardio Workouts") {
                            //TODO: Add Cardio Exercise Sheet
                        }
                        ForEach(cardioExercises.prefix(4), id: \.self) { exercise in
                            NavigationLink {
                                // Destination view
                            } label: {
                                Text(exercise)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.primary)
                            }
                        }
                        Button("Add Cardio Session") {
                            // TODO: Add Cardio Exercise
                        }
                    }
                    
                    Section(header: Text("Workouts - Weights")) {
                        Button("View All Weightlifting Workouts") {
                            //TODO: Add WeightList Sheet
                        }
                        ForEach(weightExercises.prefix(4), id: \.self) { exercise in
                            NavigationLink {
                                // Destination view
                            } label: {
                                Text(exercise)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.primary)
                            }
                        }
                        Button("Add Workout") {
                            // TODO: Add Weight Exercise
                        }
                    }
                    //TODO: Implement Real Data
                    NavigationLink {
                        ExerciseView()
                    } label: {
                        Text("My Exercises")
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
    }
}

#Preview {
    NavigationStack {
        MainView()
    }
}
