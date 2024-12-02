//
//  CardioDetailView.swift
//  MoveOS
//
//  Created by Theodore Utomo on 11/26/24.
//

import SwiftUI

struct CardioDetailView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            Text("This is the Cardio Detail View")
            Text("Implement User Interface for editing a cardio session")
            //TODO: Implement Cardio Session
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Save") {
                            
                        }
                    }
                }
        }
    }
}

#Preview {
    CardioDetailView()
}
