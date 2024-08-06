import Foundation
import SwiftData

@Model
final class City {
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

