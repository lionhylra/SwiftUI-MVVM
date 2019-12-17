//
//  Copyright © 2019 Carsales Ltd. All rights reserved.
//

import Foundation

extension URL {

    /// This method add query items to url.
    ///
    /// - Parameter queryItems: query items you want to add
    public mutating func appendQueryItems(_ queryItems: [URLQueryItem]) {
        self = appendingQueryItems(queryItems)
    }

    /// This method add query items to url.
    ///
    /// - Parameter queryItems: query items you want to add in the format of array of tupples.
    public mutating func appendQueryItems(_ queryItems: (String, String?)...) {
        appendQueryItems(queryItems.map {URLQueryItem(name: $0, value: $1)})
    }

    /// This method add query items to url.
    ///
    /// - Parameter queryItems: query items you want to add in the format of Dictionary
    public mutating func appendQueryItems(_ queryItems: [String: String?]) {
        appendQueryItems(queryItems.map {URLQueryItem(name: $0, value: $1)})
    }

    /// Returns a new URL by appending query items
    ///
    /// - Parameter queryItems: query items you want to add
    /// - Returns: a new url
    public func appendingQueryItems(_ queryItems: [URLQueryItem]) -> URL {
        return updatingComponents({ (urlComponents) in
            urlComponents.queryItems = (urlComponents.queryItems ?? []) + queryItems
        })

    }

    /// This method returns a new URL by adding query items
    ///
    /// - Parameter queryItems: query items you want to add
    /// - Returns: a new url
    public func appendingQueryItems(_ queryItems: (String, String?)...) -> URL {
        return appendingQueryItems(queryItems.map {URLQueryItem(name: $0, value: $1)})
    }

    /// This method returns a new URL by adding query items
    ///
    /// - Parameter queryItems: query items you want to add
    /// - Returns: a new url
    public func appendingQueryItems(_ queryItems: [String: String?]) -> URL {
        return appendingQueryItems(queryItems.map {URLQueryItem(name: $0, value: $1)})
    }
}
