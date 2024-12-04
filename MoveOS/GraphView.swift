import SwiftUI
import Charts

struct GraphView: View {
    @Environment(\.dismiss) private var dismiss
    let exercise: Exercise
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Progression Metrics")
                    .font(.largeTitle)
                    .padding()
                List {
                    LazyVStack {
                        Text("Volume Over Time")
                        Chart(ExerciseViewModel.generateGraphDataForVolume(for: exercise)) { dataPoint in
                            LineMark(
                                x: .value("Set Index", dataPoint.x),
                                y: .value("Volume", dataPoint.y)
                            )
                        }
                        .chartXAxisLabel("Set Index", position: .bottom)
                        .chartYAxisLabel("Volume", position: .leading)
                        .frame(width: 300, height: 300)
                        .padding(.bottom)
                        
                        Text("Weight Progression Over Time")
                        Chart(Array(exercise.sets ?? []).enumerated().map { $0 }, id: \.offset) { index, set in
                            LineMark(
                                x: .value("Set Index", index),
                                y: .value("Weight", set.weight)
                            )
                        }
                        .chartXAxisLabel("Set Index", position: .bottom)
                        .chartYAxisLabel("Weight", position: .leading)
                        .frame(width: 300, height: 300)
                        .padding(.bottom)
                        
                        Text("Average Reps Per Weight")
                        Chart(ExerciseViewModel.generateAverageRepsData(for: exercise)) { dataPoint in
                            BarMark(
                                x: .value("Weight", dataPoint.x),
                                y: .value("Average Reps", dataPoint.y)
                            )
                        }
                        .chartXAxisLabel("Weight(Lbs)", position: .bottom)
                        .chartXScale(domain: getBarDataMinimumForXAxis(exercise: exercise)...getBarDataMaximumForXAxis(exercise: exercise))
                        .chartYAxisLabel("Average Reps", position: .leading)
                        .frame(width: 300, height: 300)
                        .padding(.bottom)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Dismiss") { dismiss() }
                    }
                }
            }
        }
    }
    
    private func getBarDataMinimumForXAxis(exercise: Exercise) -> Double {
        let barData = ExerciseViewModel.generateAverageRepsData(for: exercise)
        let barWeights = barData.map { $0.x }
        let xAxisLowerBoundForBarData = Double(barWeights.min() ?? 0) - 5 // Lower bound
        return xAxisLowerBoundForBarData
    }
    
    private func getBarDataMaximumForXAxis(exercise: Exercise) -> Double {
        let barData = ExerciseViewModel.generateAverageRepsData(for: exercise)
        let barWeights = barData.map { $0.x }
        let xAxisUpperBoundForBarData = Double(barWeights.max() ?? 0) + 5 // Upper bound
        return xAxisUpperBoundForBarData
    }
    
    
}

#Preview {
    GraphView(exercise: Exercise())
}
