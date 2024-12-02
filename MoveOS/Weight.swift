//
//  Weight.swift
//  MoveOS
//
//  Created by Theodore Utomo on 11/26/24.
//

import Foundation
import FirebaseFirestore


class Weight: ObservableObject, Codable, Identifiable {
    @DocumentID var id: String?
    var workoutName: String = ""
    var exerciseIDs: [String] = []
    
    init(id: String? = nil, workoutName: String = "", exerciseIDs: [String] = []) {
        self.id = id
        self.workoutName = workoutName
        self.exerciseIDs = exerciseIDs
    }
}
