//
//  Badge.swift
//  entourage
//

import Foundation

struct Badge: Codable {
    var name: String
    var date: String?
    var progression: Int?

    enum CodingKeys: String, CodingKey {
        case name
        case date
        case progression
    }

    init(from decoder: Decoder) throws {
        if let container = try? decoder.singleValueContainer(), let str = try? container.decode(String.self) {
            self.name = str
            self.date = nil
            self.progression = nil
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            // Some backends might return a dictionary right away. Let's try to get name
            // If name is not present as a key, maybe it's just strings.
            // But we requested it to be "name", "date", "progression".
            self.name = (try? container.decode(String.self, forKey: .name)) ?? "unknown"
            self.date = try? container.decode(String.self, forKey: .date)
            self.progression = try? container.decode(Int.self, forKey: .progression)
        }
    }

    init(name: String, date: String? = nil, progression: Int? = nil) {
        self.name = name
        self.date = date
        self.progression = progression
    }
}
