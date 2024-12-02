//
//  ExerciseView.swift
//  MoveOS
//
//  Created by Theodore Utomo on 11/25/24.
//

import SwiftUI

struct ExerciseListView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List {
                Text("Implement Exercises")
                //TODO: Get list of exercises from exercise API
            }
        }
    }
}

#Preview {
    NavigationStack {
        ExerciseListView()
    }
}
