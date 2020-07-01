//
//  Movie.swift
//  MovieGalleryAssignment
//
//  Created by Pankaj Shirodkar on 24/06/20.
//  Copyright © 2020 Pankaj Shirodkar. All rights reserved.
//

import Foundation
import RealmSwift
import Foundation

class MoviesAPIInterface: Object, Codable {
    @objc dynamic var page : RealmInt?
    dynamic var total_results : RealmInt?
    dynamic var total_pages : RealmInt?
    var results = List<Movie>()

    enum CodingKeys: String, CodingKey {
        case page = "page"
        case total_results = "total_results"
        case total_pages = "total_pages"
        case results = "results"
    }
}

import Foundation
class Movie : Object, Codable {
    @objc dynamic var poster_path : String?
    @objc dynamic var id : Int
    @objc dynamic var title : String?
    @objc dynamic var overview : String?
    @objc dynamic var release_date : String?
    var trailers: ListTrailer?
    var genres: ListGenres?
    
    override static func primaryKey() -> String? {
        return "id"
    }

    enum CodingKeys: String, CodingKey {
        case poster_path = "poster_path"
        case id = "id"
        case title = "title"
        case overview = "overview"
        case release_date = "release_date"
        case trailers = "results"
        case genres = "genres"
    }
}
class Genres : Object, Codable {
    @objc dynamic let id : RealmInt?
    @objc dynamic let name : String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
    }
}

class Trailer : Object, Codable {
    @objc dynamic var id : String?
    @objc dynamic var iso_639_1 : String?
    @objc dynamic var iso_3166_1 : String?
    @objc dynamic var key : String?
    @objc dynamic var name : String?
    @objc dynamic var site : String?
    @objc dynamic var type : String?

    enum CodingKeys: String, CodingKey {

        case id = "id"
        case iso_639_1 = "iso_639_1"
        case iso_3166_1 = "iso_3166_1"
        case key = "key"
        case name = "name"
        case site = "site"
        case type = "type"
    }
}


/*
class MoviesAPIInterface: Codable{
    let page, totalResults, totalPages: Int?
    let results: [Movie]?

    enum CodingKeys: String, CodingKey {
        case page
        case totalResults = "total_results"
        case totalPages = "total_pages"
        case results
    }
}

// MARK: - Result
struct Movie: Codable {
    let popularity: Double?
    let voteCount: Int?
    let video: Bool?
    let posterPath: String?
    let id: Int
    let adult: Bool?
    let backdropPath: String?
    var genres : [Genres]?
    let originalTitle: String?
    let genreIDS: [Int]?
    let title: String?
    let voteAverage: Double?
    let overview, releaseDate: String?
    let trailers: [Result]?

    enum CodingKeys: String, CodingKey {
        case popularity
        case voteCount = "vote_count"
        case video
        case posterPath = "poster_path"
        case id, adult, genres
        case backdropPath = "backdrop_path"
        case originalTitle = "original_title"
        case genreIDS = "genre_ids"
        case title
        case voteAverage = "vote_average"
        case overview
        case releaseDate = "release_date"
        case trailers = "results"
    }
}

struct Genres : Codable {
    let id : Int?
    let name : String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
    }
}

struct Result: Codable {
    let id, iso639_1, iso3166_1, key: String?
    let name, site: String?
    let size: Int?
    let type: String?

    enum CodingKeys: String, CodingKey {
        case id
        case iso639_1 = "iso_639_1"
        case iso3166_1 = "iso_3166_1"
        case key, name, site, size, type
    }
}
*/
