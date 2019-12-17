//
//  Decodable.swift
//  SwiftUI MVVM
//
//  Created by Yilei He on 9/9/19.
//  Copyright © 2019 Yilei He. All rights reserved.
//

import Foundation

extension Decodable {
    init?(fromJSONFile fileName: String, bundle: Bundle = Bundle.main, decodedBy jsonDecoder: JSONDecoder = JSONDecoder()) throws {
        var fileName = fileName
        if fileName.hasSuffix(".json") {
            let range = fileName.range(of: ".json")!
            fileName = String(fileName[..<range.lowerBound])
        }

        guard let path = bundle.path(forResource: fileName, ofType: "json") else {
            return nil
        }

        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        self = try jsonDecoder.decode(Self.self, from: data)
    }
}
