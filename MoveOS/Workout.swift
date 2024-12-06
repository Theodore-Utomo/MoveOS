//
//  Weight.swift
//  MoveOS
//
//  Created by Theodore Utomo on 11/26/24.
//

import Foundation
import FirebaseFirestore

// IMPORTANT DO NOT CHANGE INTO STRUCT, DOES NOT WORK FOR SOME REASON
class Workout: ObservableObject, Codable, Identifiable {
    @DocumentID var id: String?
    var workoutName: String = ""
    var exerciseIDs: [String] = []
    
    init(id: String? = nil, workoutName: String = "", exerciseIDs: [String] = []) {
        self.id = id
        self.workoutName = workoutName
        self.exerciseIDs = exerciseIDs
    }
}
