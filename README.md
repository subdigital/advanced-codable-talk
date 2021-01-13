# Advanced Codable

This repo contains an Xcode playground of examples demonstrating customizing Codable for different scenarios.

The playground has these pages:

- 1. Basic Example

This shows the basic Codable conformance that the compiler synthesizes for you.

- 2.1 Changing Hierarchies

Taking a structured JSON response and flattening it into one level

- 2.2 Changing Hierarchies

Taking a flat JSON response and decoding into a hierarchy of types in Swift

- 3.1 Heterogeneous Arrays

Decoding a feed of various subclasses of a common FeedItem base type. This is part 1 which solves the 
problem, but is somewhat complex.

- 3.2 Heterogeneous Arrays

Refactoring the previous example to create a reusable "class family" concept and an extension on 
KeyedDecodingContainer that makes decoding heterogeneous arrays much cleaner.

- 4. Property Wrappers

An example of using property wrappers to clean up some Codable issues that would otherwise require us
to implement an entire Codable implementation just for one or two properties.

Inspiration for this comes from [BetterCodable](https://github.com/marksands/BetterCodable) by Mark Sands.


Presented to [iOS Conf SG](https://iosconf.sg) on January 21st, 2021.

