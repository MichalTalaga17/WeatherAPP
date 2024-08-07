import Foundation
import SwiftData

@Model
final class City {
    @Attribute(.unique) var name: String
    var temperature: Double? = nil
    var weatherIcon: String? = nil

    init(name: String) {
        self.name = name
    }
}
