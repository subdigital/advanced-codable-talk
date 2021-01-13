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
        var itemsContainer = try container.nestedUnkeyedContainer(forKey: .items)
        var itemsContainerCopy = itemsContainer
        
        var items: [FeedItem] = []
        
        while !itemsContainer.isAtEnd {
            // peek at the type
            let typeContainer = try itemsContainer.nestedContainer(keyedBy: AnyCodingKey.self)
            let type = try typeContainer.decode(String.self, forKey: "type")
            switch type {
            case "text":
                let textFeedItem = try itemsContainerCopy.decode(TextFeedItem.self)
                items.append(textFeedItem)
            case "image":
                let imageFeedItem = try itemsContainerCopy.decode(ImageFeedItem.self)
                items.append(imageFeedItem)
            default: fatalError()
            }
        }
        
        self.items = items
    }
}

let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase
decoder.dateDecodingStrategy = .iso8601

let feed = try! decoder.decode(Feed.self, from: json)

dump(feed)
