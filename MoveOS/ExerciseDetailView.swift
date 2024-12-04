//
//  ExerciseDetailView.swift
//  MoveOS
//
//  Created by Theodore Utomo on 11/26/24.
//

import SwiftUI
import SwiftData

struct AddSetView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var exercise: Exercise
    @Binding var weightUnit: WeightUnit
    
    @State private var weight = ""
    @State private var reps = ""
    @State private var showAlert = false // For input validation feedback
    
    var setToEdit: Set? // Is nil if adding new set, not nil if editing existing set
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Enter Weight (\(weightUnit.rawValue))")
                        .font(.headline)
                    TextField("E.g., 50", text: $weight)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                        .keyboardType(.decimalPad)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Enter Reps")
                        .font(.headline)
                    TextField("E.g., 10", text: $reps)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
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
            .onAppear {
                if let set = setToEdit {
                    weight = "\(set.weight)"
                    reps = "\(set.reps)"
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
        var convertedValue = weightValue
        if weightUnit == .kg {
            convertedValue *= 2.2046
        }
        
        Task {
            if let existingSet = setToEdit {
                // Editing an existing set
                if let index = exercise.sets?.firstIndex(where: { $0.id == existingSet.id }) {
                    exercise.sets?[index].weight = convertedValue
                    exercise.sets?[index].reps = repsValue
                }
            } else {
                // Adding a new set
                let newSet = Set(weight: convertedValue, reps: repsValue, date: Date.now)
                exercise.sets?.append(newSet)
            }
            
            let _ = await ExerciseViewModel.saveExercise(exercise: exercise)
        }
    }
}



struct ExerciseDetailView: View {
    @State var exercise: Exercise
    @State private var setSheetIsPresented = false // State for adding new set
    @State private var showInstructionsPopup = false // State for showing the instructions
    @State private var showGraphSheet = false // State for showing the graph
    @State private var setToEdit: Set? = nil
    @State private var weightUnit: WeightUnit = .lbs
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(exercise.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(exercise.muscle)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    
                    Button {
                        showInstructionsPopup.toggle()
                    } label: {
                        Text("View Instructions")
                            .font(.body)
                            .foregroundStyle(.blue)
                            .underline()
                            .padding(.top, 5)
                    }
                    Button {
                        toggleWeightUnit()
                    } label: {
                        Text("Change Unit: \(weightUnit.rawValue)")
                            .font(.body)
                            .foregroundStyle(.blue)
                            .padding(.top, 5)
                    }
                }
                .padding(.horizontal, 40)
                
                Divider()
                
                List(exercise.sets?.reversed() ?? []) { set in
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text("Weight:")
                            Spacer()
                            Text("\(formatWeight(set.weight)) \(weightUnit.rawValue)")
                        }
                        .font(.body)
                        
                        HStack {
                            Text("Reps:")
                            Spacer()
                            Text("\(set.reps)")
                        }
                        .font(.body)
                        .foregroundStyle(.secondary)
                        
                        HStack {
                            Text("Date:")
                            Spacer()
                            Text(formatDate(set.date))
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 5)
                    .swipeActions {
                        Button("Edit", role: .none) {
                            setToEdit = set
                            setSheetIsPresented.toggle()
                        }
                        .tint(.blue)
                    }
                }
                .listStyle(.insetGrouped)
                VStack {
                    Spacer()
                    Button {
                        showGraphSheet.toggle()
                    } label: {
                        Text("View Progress Graph")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                }
                .frame(height: 50)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        setToEdit = nil
                        setSheetIsPresented.toggle()
                    } label: {
                        HStack {
                            Text("Add Set")
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showGraphSheet) {
                GraphView(exercise: exercise)
            }
            .sheet(isPresented: $setSheetIsPresented) {
                AddSetView(exercise: $exercise, weightUnit: $weightUnit, setToEdit: setToEdit)
            }
            .alert("Instructions", isPresented: $showInstructionsPopup) {
                Button("Close", role: .cancel) { }
            } message: {
                Text(exercise.instructions)
            }
        }
        
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium 
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func toggleWeightUnit() {
        weightUnit = (weightUnit == .lbs) ? .kg : .lbs
    }
    
    private func formatWeight(_ weight: Double) -> String {
        if weightUnit == .lbs {
            return String(format: "%.1f", weight)
        } else {
            let weightInKg = weight * 0.453592
            return String(format: "%.1f", weightInKg)
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
