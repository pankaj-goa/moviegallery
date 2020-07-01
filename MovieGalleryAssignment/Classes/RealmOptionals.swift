//
//  OptionalInt.swift
//  MovieGalleryAssignment
//
//  Created by Pankaj Shirodkar on 30/06/20.
//  Copyright © 2020 Pankaj Shirodkar. All rights reserved.
//

import Foundation
import RealmSwift

/**
- Description:
   - RealmInt: a custom type for realm optional Int
*/
class RealmInt: Object, Codable {
    private var numeric = RealmOptional<Int>()

    required public convenience init(from decoder: Decoder) throws {
        self.init()

        let singleValueContainer = try decoder.singleValueContainer()
        if singleValueContainer.decodeNil() == false {
            let value = try singleValueContainer.decode(Int.self)
            numeric = RealmOptional(value)
        }
    }

    var value: Int? {
        return numeric.value
    }

    var zeroOrValue: Int {
        return numeric.value ?? 0
    }
}
/**
- Description:
   - ListGenres: a custom type for Realm List Genres optional for array of Genres.
*/
class ListGenres: Object, Codable {
    private var genres = List<Genres>()

    required public convenience init(from decoder: Decoder) throws {
        self.init()

        let singleValueContainer = try decoder.singleValueContainer()
        if singleValueContainer.decodeNil() == false {
            let value = try singleValueContainer.decode([Genres].self)
            for val in value{
                genres.append(val)
            }
        }
    }
    var value: List<Genres> {
        return genres
    }

}
/**
- Description:
   - ListTrailer: a custom type for Realm List Trailer optional for array of Trailer.
*/
class ListTrailer: Object, Codable {
    private var trailer = List<Trailer>()

    required public convenience init(from decoder: Decoder) throws {
        self.init()

        let singleValueContainer = try decoder.singleValueContainer()
        if singleValueContainer.decodeNil() == false {
            let value = try singleValueContainer.decode([Trailer].self)
            for val in value{
                trailer.append(val)
            }
        }
    }
    var value: List<Trailer> {
        return trailer
    }

}
