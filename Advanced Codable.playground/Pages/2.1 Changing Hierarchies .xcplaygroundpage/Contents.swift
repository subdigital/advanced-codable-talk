import Foundation

let json = """
    {
        "id": 123,
        "name": "Endeavor",
        "brewery": {
            "id": "sa001",
            "name": "Saint Arnold"
        }
    }
    """.data(using: .utf8)!

struct Beer: Decodable {
    let id: Int
    let name: String
    let breweryId: String
    let breweryName: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case brewery
    }
    
    enum BreweryCodingKeys: String, CodingKey {
        case id
        case name
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        
        let breweryContainer = try container.nestedContainer(keyedBy: BreweryCodingKeys.self, forKey: .brewery)
        breweryId = try breweryContainer.decode(String.self, forKey: .id)
        breweryName = try breweryContainer.decode(String.self, forKey: .name)
    }
}

let decoder = JSONDecoder()
let beer = try! decoder.decode(Beer.self, from: json)

dump(beer)
