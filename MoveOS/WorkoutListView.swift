//
//  WeightListView.swift
//  MoveOS
//
//  Created by Theodore Utomo on 11/25/24.
//

import SwiftUI
import FirebaseFirestore

struct WorkoutListView: View {
    @FirestoreQuery(collectionPath: "weight") var workouts: [Workout]
    @State private var workoutSheetIsPresented = false
    @State private var generateWorkoutSheetIsPresented = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Workouts")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    Text("Track your weightlifting workouts and progress.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }
                
                Divider()
                    .padding(.horizontal)
                
                // List Section
                if workouts.isEmpty {
                    VStack {
                        Spacer()
                        Text("No workouts available.")
                            .font(.headline)
                            .foregroundStyle(.gray)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(workouts) { workout in
                            NavigationLink {
                                WorkoutDetailView(workout: workout)
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(workout.workoutName)
                                        .font(.headline)
                                }                            }
                            .swipeActions {
                                Button("Delete", role: .destructive) {
                                    Task {
                                        await WorkoutViewModel.deleteWorkout(workout: workout)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
                
                Spacer()
                HStack {
                    Spacer()
                    Button("Generate Workout") {
                        generateWorkoutSheetIsPresented.toggle()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    Spacer()
                }
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .toolbar {
                // Add Workout Button
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        workoutSheetIsPresented.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Workout")
                        }
                        .font(.headline)
                    }
                }
            }
            .sheet(isPresented: $workoutSheetIsPresented) {
                NavigationStack {
                    WorkoutDetailView(workout: Workout())
                }
            }
            .sheet(isPresented: $generateWorkoutSheetIsPresented) {
                NavigationStack {
                    WorkoutGenerateView()
                }
            }
        }
    }
}


#Preview {
    NavigationStack {
        WorkoutListView()
    }
}
