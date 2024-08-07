import Foundation
import SwiftData

@Model
final class City {
    @Attribute(.unique) var name: String 
    
    init(name: String) {
        self.name = name
    }
}

