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
    @FirestoreQuery(collectionPath: "weight") var workouts: [Workout]
    @Environment(\.dismiss) private var dismiss
    @State private var workoutSheetIsPresented = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Your Movements")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    Text("Track your progress and keep improving.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }
                List {
                    
                    Section {
                        NavigationLink {
                            ExerciseListView()
                        } label: {
                            HStack {
                                Image(systemName: "figure.walk")
                                    .foregroundStyle(.blue)
                                Text("View My Exercises")
                                    .font(.body)
                            }
                        }
                    } header: {
                        Text("My Exercises")
                            .font(.headline)
                            .foregroundStyle(.primary)
                    }
                    
                    Section {
                        NavigationLink {
                            WorkoutListView()
                        } label: {
                            HStack {
                                Image(systemName: "dumbbell")
                                    .foregroundStyle(.green)
                                Text("View All Workouts")
                                    .font(.body)
                                    .bold()
                            }
                        }
                        Button {
                            workoutSheetIsPresented.toggle()
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(.orange)
                                Text("Add New Workout")
                                    .font(.body)
                            }
                        }
                        
                        ForEach(workouts) { workout in
                            LazyVStack(alignment: .leading) {
                                NavigationLink {
                                    WorkoutDetailView(workout: workout)
                                } label: {
                                    
                                    Text(workout.workoutName)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                }
                            }
                        }
                        .onDelete { index in
                            deleteWorkout(at: index)
                        }
                        
                    } header: {
                        Text("Workouts - Weights")
                            .font(.headline)
                            .foregroundStyle(.primary)
                    }
                }
                .listStyle(.insetGrouped)
            }
            .padding(.top, 20)
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        do {
                            try Auth.auth().signOut()
                            print("Sign out successfull")
                            dismiss()
                        } catch {
                            print("Sign out unsuccessful. ERROR: \(error.localizedDescription)")
                        }
                    } label: {
                        Text("Sign Out")
                            .foregroundStyle(.red)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden()
        .sheet(isPresented: $workoutSheetIsPresented) {
            NavigationStack {
                WorkoutDetailView(workout: Workout())
            }
        }
    }
    
    private func deleteWorkout(at index: IndexSet) {
        index.forEach { index in
            let workout = workouts[index]
            Task {
                await WorkoutViewModel.deleteWorkout(workout: workout)
            }
        }
    }
}


#Preview {
    NavigationStack {
        MainView()
    }
}
