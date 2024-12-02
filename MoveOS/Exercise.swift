//
//  Exercise.swift
//  MoveOS
//
//  Created by Theodore Utomo on 11/26/24.
//

import Foundation
import FirebaseFirestore


struct Set: Codable, Identifiable {
    var id: String
    var weight: Double
    var reps: Int
    var date: Date
    
    init(id: String = UUID().uuidString, weight: Double, reps: Int, date: Date) {
        self.id = id
        self.weight = weight
        self.reps = reps
        self.date = date
    }
}


class Exercise: ObservableObject, Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var sets: [Set]?
    var muscle: String
    var instructions: String
    
//    required init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.id = try container.decodeIfPresent(String.self, forKey: .id)
//        self.name = try container.decode(String.self, forKey: .name)
//        self.muscle = try container.decode(String.self, forKey: .muscle)
//        self.instructions = try container.decode(String.self, forKey: .instructions)
//        
//        // Decode `sets` directly as `[Set]` since `Set` conforms to `Codable`
//        self.sets = try container.decodeIfPresent([Set].self, forKey: .sets) ?? []
//    }
    
    init(id: String? = nil, name: String = "", sets: [Set]? = nil, muscle: String = "", instructions: String = "") {
        self.id = id
        self.name = name
        self.sets = sets
        self.muscle = muscle
        self.instructions = instructions
    }
}


struct SearchedExercise: Codable, Identifiable {
    var id = UUID().uuidString
    let name: String
    let muscle: String
    let instructions: String
    let type: String
    
    private enum CodingKeys: String, CodingKey {
        case name, muscle, instructions, type
    }
}

