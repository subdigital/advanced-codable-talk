import Foundation

let json = """
    {
        "items": [
            {
                "type": "text",
                "id": 55,
                "date": "2021-01-08T14:38:24Z",
                "text": "This is a text feed item"
            },
            {
                "type": "image",
                "id": 56,
                "date": "2021-01-08T14:39:24Z",
                "image_url": "http://placekitten.com/200/300"
            }
        ]
    }
    """.data(using: .utf8)!

protocol DecodableClassFamily: Decodable {
    associatedtype BaseType: Decodable
    static var discriminator: AnyCodingKey { get }
    func getType() -> BaseType.Type
}

enum FeedItemClassFamily: String, DecodableClassFamily {
    case text
    case image
    
    typealias BaseType = FeedItem
    static var discriminator: AnyCodingKey = "type"
    
    func getType() -> FeedItem.Type {
        switch self {
        case .text: return TextFeedItem.self
        case .image: return ImageFeedItem.self
        }
    }
}

extension KeyedDecodingContainer {
    func decodeHeterogeneousArray<Family: DecodableClassFamily>(family: Family.Type, forKey key: K) throws -> [Family.BaseType] {
        var itemsContainer = try nestedUnkeyedContainer(forKey: key)
        var itemsContainerCopy = itemsContainer
        
        var items: [Family.BaseType] = []
        
        while !itemsContainer.isAtEnd {
            // peek at the type
            let typeContainer = try itemsContainer.nestedContainer(keyedBy: AnyCodingKey.self)
            let family = try typeContainer.decode(Family.self, forKey: Family.discriminator)
            let type = family.getType()
            let item = try itemsContainerCopy.decode(type)
            items.append(item)
        }
        
        return items
    }
}

class FeedItem: Decodable {
    let type: String
    let id: Int
    let date: Date
}

class TextFeedItem: FeedItem {
    let text: String
    
    enum CodingKeys: String, CodingKey {
        case text
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decode(String.self, forKey: .text)
        try super.init(from: decoder)
    }
}

class ImageFeedItem: FeedItem {
    let imageUrl: URL
    
    enum CodingKeys: String, CodingKey {
        case imageUrl
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        imageUrl = try container.decode(URL.self, forKey: .imageUrl)
        try super.init(from: decoder)
    }
}

struct AnyCodingKey: CodingKey {
    var stringValue: String
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    var intValue: Int?
    init?(intValue: Int) {
        stringValue = String(intValue)
    }
}

extension AnyCodingKey: ExpressibleByStringLiteral {
    init(stringLiteral value: StringLiteralType) {
        self.init(stringValue: value)!
    }
}

struct Feed: Decodable {
    let items: [FeedItem]
    
    enum CodingKeys: String, CodingKey {
        case items
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        items = try container.decodeHeterogeneousArray(family: FeedItemClassFamily.self, forKey: .items)
    }
}

let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase
decoder.dateDecodingStrategy = .iso8601

let feed = try! decoder.decode(Feed.self, from: json)

dump(feed)
