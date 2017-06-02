//
//  JSONDecodable.swift
//  NewsAPIReader
//
//  Created by Colin Ferris on 6/1/17.
//  Copyright © 2017 Colin Ferris. All rights reserved.
//

import UIKit


public enum JSONDeserializationError: Error {
    case missingAttribute(String)
    case invalidType(key: String, expectedType: Any.Type, receivedValue: Any)
}

public typealias JSON = [String: Any]

public protocol JSONDeserializable {
    init(jsonRepresentation: JSON) throws
}

public func get<T>(_ json: JSON, key: String) throws -> T {
    guard let value = json[key] else {
        throw JSONDeserializationError.missingAttribute(key)
    }
    guard let typedItem = value as? T else {
        throw JSONDeserializationError.invalidType(key: key,
                                                   expectedType: T.self,
                                                   receivedValue: value)
    }
    return typedItem
}

public func get<T: JSONDeserializable>(_ json: JSON, key: String) throws -> T {
    let value: JSON = try get(json, key: key)
    return try get(value)
}

public func get<T: JSONDeserializable>(_ json: JSON, key: String) throws -> [T] {
    let values: [JSON] = try get(json, key: key)
    return values.flatMap { try? get($0) }
}

public func get<T: JSONDeserializable>(_ json: JSON) throws -> T {
    return try T.init(jsonRepresentation: json)
}
