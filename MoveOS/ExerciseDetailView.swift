//
//  ExerciseDetailView.swift
//  MoveOS
//
//  Created by Theodore Utomo on 11/26/24.
//

import SwiftUI

struct AddSetView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var exercise: Exercise
    
    @State private var weight = ""
    @State private var reps = ""
    @State private var showAlert = false // For input validation feedback
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Enter Weight (lbs)")
                        .font(.headline)
                    TextField("E.g., 50", text: $weight)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .keyboardType(.decimalPad)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Enter Reps")
                        .font(.headline)
                    TextField("E.g., 10", text: $reps)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .keyboardType(.numberPad)
                }
                
                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveSet()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Invalid Input", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please enter a valid weight and reps.")
        }
    }
    
    private func saveSet() {
        guard let weightValue = Double(weight), let repsValue = Int(reps), weightValue > 0, repsValue > 0 else {
            showAlert = true
            return
        }
        
        let newSet = Set(weight: weightValue, reps: repsValue, date: Date.now)
        Task {
            await ExerciseViewModel.addSet(exercise: exercise, set: newSet)
        }
    }
}



struct ExerciseDetailView: View {
    @State var exercise: Exercise
    @State private var setSheetIsPresented = false
    @State private var showInstructionsPopup = false // State for showing the instructions popup
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(exercise.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(exercise.muscle)
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Button {
                        showInstructionsPopup.toggle()
                    } label: {
                        Text("View Instructions")
                            .font(.body)
                            .foregroundColor(.blue)
                            .underline()
                            .padding(.top, 5)
                    }
                }
                .padding(.horizontal, 40)
                
                Divider()
                
                List {
                    if let sets = exercise.sets, !sets.isEmpty {
                        Section(header: Text("Sets")) {
                            ForEach(sets) { set in
                                VStack(alignment: .leading, spacing: 5) {
                                    HStack {
                                        Text("Weight:")
                                        Spacer()
                                        Text("\(set.weight, specifier: "%.1f") lbs")
                                    }
                                    .font(.body)
                                    
                                    HStack {
                                        Text("Reps:")
                                        Spacer()
                                        Text("\(set.reps)")
                                    }
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 5)
                            }
                        }
                    } else {
                        Text("No sets added yet. Tap 'Add Set' to get started.")
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
                .listStyle(.insetGrouped)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        setSheetIsPresented.toggle()
                    } label: {
                        HStack {
                            Text("Add Set")
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $setSheetIsPresented) {
                AddSetView(exercise: $exercise)
            }
            .alert("Instructions", isPresented: $showInstructionsPopup) {
                Button("Close", role: .cancel) { }
            } message: {
                Text(exercise.instructions)
            }
        }
    }
}


#Preview {
    NavigationStack {
        ExerciseDetailView(
            exercise: Exercise(
                id: "mockID",
                name: "Mock Exercise",
                sets: [
                    Set(weight: 50, reps: 10, date: Date.now)
                ],
                muscle: "Biceps",
                instructions: "Perform this exercise with proper form."
            )
        )
    }
}
