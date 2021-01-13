import Foundation

protocol DateValueCodableStrategy {
    associatedtype RawValue: Codable
    static func decode(_ value: RawValue) throws -> Date
    static func encode(_ date: Date) -> RawValue
}

struct ISO8601Strategy: DateValueCodableStrategy {
    typealias RawValue = String
    
    static func decode(_ value: String) throws -> Date {
        guard let date = ISO8601DateFormatter().date(from: value) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Invalid date format: \(value)"))
        }
        return date
    }
    
    static func encode(_ date: Date) -> String {
        ISO8601DateFormatter().string(from: date)
    }
}

struct YearMonthDayStrategy: DateValueCodableStrategy {
    typealias RawValue = String
    
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "y-MM-dd"
        return dateFormatter
    }()
    
    static func decode(_ value: String) throws -> Date {
        guard let date = dateFormatter.date(from: value) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Invalid date format: \(value)"))
        }
        return date
    }
    
    static func encode(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }
}

@propertyWrapper struct DateValue<Formatter: DateValueCodableStrategy>: Codable {
    private let value: Formatter.RawValue
    var wrappedValue: Date
    
    init(wrappedValue: Date) {
        self.wrappedValue = wrappedValue
        self.value = Formatter.encode(wrappedValue)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.value = try container.decode(Formatter.RawValue.self)
        self.wrappedValue = try Formatter.decode(value)
    }
}

let json = """
{
    "name": "John",
    "dob": "1973-12-04",
    "joined_at": "2012-04-12T06:29:00Z"
}
""".data(using: .utf8)!

struct User: Decodable {
    let name: String
    
    @DateValue<YearMonthDayStrategy>
    var dob: Date
    
    @DateValue<ISO8601Strategy>
    var joinedAt: Date
}

let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase

let user = try decoder.decode(User.self, from: json)
dump(user)
