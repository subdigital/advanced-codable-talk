import Foundation

let json = """
    {
        "id": 123,
        "name": "Endeavor",
        "brewery_id": "sa001",
        "brewery_name": "Saint Arnold"
    }
    """.data(using: .utf8)!

struct Brewery: Decodable {
    let id: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case id = "brewery_id"
        case name = "brewery_name"
    }
}

struct Beer: Decodable {
    let id: Int
    let name: String
    let brewery: Brewery
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        brewery = try Brewery(from: decoder)
    }
}

let decoder = JSONDecoder()
let beer = try! decoder.decode(Beer.self, from: json)

dump(beer)
