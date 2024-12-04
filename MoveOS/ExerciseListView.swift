//
//  ExerciseView.swift
//  MoveOS
//
//  Created by Theodore Utomo on 11/25/24.
//

import SwiftUI
import FirebaseFirestore

struct ExerciseListView: View {
    @FirestoreQuery(collectionPath: "exercises") var exercises: [Exercise]
    @Environment(\.dismiss) private var dismiss
    
    @State private var sheetIsPresented = false
    @State private var exerciseVM = ExerciseViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Your Exercises")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    Text("Track and manage all your exercises.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }
                Divider()
                    .padding(.horizontal)
                
                List(exercises) { exercise in
                    LazyVStack {
                        NavigationLink {
                            ExerciseDetailView(exercise: exercise)
                        } label: {
                            ExerciseRowView(exercise: exercise)
                        }
                        .swipeActions {
                            Button("Delete", role: .destructive) {
                                Task {
                                    await ExerciseViewModel.deleteExercise(exercise: exercise)
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button{
                            sheetIsPresented.toggle()
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Exercise")
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $sheetIsPresented) {
            ExerciseAddView()
        }
        .navigationBarBackButtonHidden()
    }
}


struct ExerciseRowView: View {
    let exercise: Exercise
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(exercise.name)
                    .font(.headline)
                    .foregroundStyle(.black)
                
                Text(exercise.muscle.capitalized)
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                
                if let lastDate = exercise.sets?.last?.date {
                    Text("Last performed: \(formatDate(lastDate))")
                        .font(.caption)
                        .foregroundStyle(.gray)
                } else {
                    Text("No sets logged yet.")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        ExerciseListView()
    }
}
