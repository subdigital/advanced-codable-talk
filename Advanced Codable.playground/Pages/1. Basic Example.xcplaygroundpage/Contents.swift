import Foundation


struct Beer: Codable {
    let id: Int
    let name: String
    let brewery: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case brewery
    }
    
    init(from decoder: Decoder) throws {
        let container =  try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.brewery = try container.decode(String.self, forKey: .brewery)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(brewery, forKey: .brewery)
    }
}

let beerJSON = """
{
    "id": 123,
    "name": "Endeavor",
    "brewery": "Saint Arnold"
}
""".data(using: .utf8)!

let decoder = JSONDecoder()
let beer = try decoder.decode(Beer.self, from: beerJSON)

dump(beer)
