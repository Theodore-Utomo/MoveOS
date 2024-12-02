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
            List(exercises) { exercise in
                NavigationLink {
                    ExerciseDetailView(exercise: exercise)
                } label: {
                    Text(exercise.name)
                }
                .swipeActions {
                    Button("Delete", role: .destructive) {
                        
                    }
                }
            }
            .listStyle(.plain)
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
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    NavigationStack {
        ExerciseListView()
    }
}
