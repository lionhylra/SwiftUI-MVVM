//
//  TVShowModel.swift
//  TVMazeBrowser
//
//  Created by Yilei He on 31/8/19.
//  Copyright © 2019 Yilei He. All rights reserved.
//

import Foundation

struct TVShowModel: Decodable, Identifiable {
    let id: Int
    let name: String
    let premiered: String?
    let schedule: Schedule
    let genres: [String]
    let summary: String?
    let rating: Rating
    let image: Image?
}

extension TVShowModel {
    struct Schedule: Decodable {
        let time: String
        let days: [String]
    }
    struct Rating: Decodable {
        let average: Double?
    }
    struct Image: Decodable {
        let original: URL
        let medium: URL
    }
}

extension TVShowModel {
    static func exampleListingData() -> [TVShowModel] {
        return try! [TVShowModel].init(fromJSONFile: "listing.json")!
    }
}
