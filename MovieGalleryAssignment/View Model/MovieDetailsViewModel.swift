//
//  MovieDetailsViewModel.swift
//  MovieGalleryAssignment
//
//  Created by Pankaj Shirodkar on 26/06/20.
//  Copyright © 2020 Pankaj Shirodkar. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RealmSwift

class MoviesDetailsViewModel{
    let apiCall = ApiClass()
    
    let navigationTitleText = "Movie Details"
    
    private var disposeBag = DisposeBag()
    
    private let data = BehaviorRelay<Movie?>(value: nil)
    var dataObservable: Observable<Movie?> {
        return data.asObservable()
    }
    
    var dataSource: Movie? {
        return data.value
    }
    
    private let trailerData = BehaviorRelay<Movie?>(value: nil)
    var trailerDataObservable: Observable<Movie?> {
        return trailerData.asObservable()
    }
    
    var trailerDataSource: Movie? {
        return trailerData.value
    }
    
    private let showSnackBar = PublishSubject<(message: String?, dataExists: Bool)>()
    var showSnackBarObservable: Observable<(message: String?, dataExists: Bool)> {
        return showSnackBar.asObservable()
    }
    
    private let isLoading = PublishSubject<Bool>()
    var isLoadingObservable: Observable<Bool> {
        return isLoading.asObservable()
    }
    
    var movieTitle: String?{
        guard let movie = dataSource else { return nil }
        if let titleTxt = movie.title, titleTxt != ""{
            return titleTxt
        } else {
            return nil
        }
    }
    
    var posterPath: String?{
        guard let movie = dataSource else { return nil }
        if let posterUrl = movie.poster_path, posterUrl != ""{
            return posterUrl
        } else{
            return nil
        }
    }
    
    var overviewTxt: String?{
        guard let movie = dataSource else { return nil }
        if let overviewStr = movie.overview, overviewStr != ""{
            return overviewStr
        } else{
            return nil
        }
    }
    
    var releaseDate: String?{
        guard let movie = dataSource else { return nil }
        if let releaseDate = movie.release_date, releaseDate != ""{
            return releaseDate.changeDateFormat(from: "yyyy-MM-dd", to: "dd.MM.yyyy")
        } else{
            return nil
        }
    }
    
    var genres: String?{
        guard let movie = dataSource else { return nil }
        if let genres = movie.genres?.value, genres.count > 0{
            let val = genres.filter({$0.name != nil})
            return (val.count > 0) ? val.map({$0.name! }).joined(separator: ", ") : nil
        } else{
            return nil
        }
    }
    
    var youtubeId: String?{
        if let movie = self.trailerDataSource, let trailers = movie.trailers?.value, trailers.count > 0, let youtubeId = trailers.first?.key, youtubeId != ""{
            return youtubeId
        } else{
            return nil
        }
    }
    /**
    Call this function to fetch movie details from server and for a particular movie id.
    - Parameters:
       - movieId: Pass movie id for fetching movie details in Int
    
    ### Usage Example: ###
    ````
     fetchMovieDetailsById(movieId: 2131)
     
    ````
    */
    func fetchMovieDetailsById(_ movieId: Int){
        if Reach().isConnectedToInternet(){
            self.isLoading.onNext(true)
            self.apiCall.fetchMovieDetailsById(movieId)
            .subscribe(onNext: { [weak self] movieDetail in
                guard let `self` = self else { return }
                self.isLoading.onNext(false)
                self.data.accept(movieDetail)
            }, onError: { [weak self] error in
                let error = (error as? APIErrors)?.errorStr
                self?.showSnackBar.onNext((message: error, dataExists: false))
                self?.isLoading.onNext(false)
            })
            .disposed(by: self.disposeBag)
        } else{
            let error = APIErrors.serverError.errorStr
            let movieForId = try!Realm().objects(Movie.self).filter("id == %@", movieId)
            if let movie = movieForId.first{
                self.data.accept(movie)
                self.showSnackBar.onNext((message: error, dataExists: true))
            } else{
                self.showSnackBar.onNext((message: error, dataExists: false))
            }
        }
    }
    
    /**
    Call this function to fetch movie videos from server and for a particular movie id.
    - Parameters:
       - movieId: Pass movie id for fetching movie videos in Int
    
    ### Usage Example: ###
    ````
     fetchMovieTrailersById(movieId: 2131)
     
    ````
    */
    func fetchMovieTrailersById(_ movieId: Int){
        self.isLoading.onNext(true)
        self.apiCall.fetchMovieTrailersById(movieId)
            .subscribe(onNext: { [weak self] movieDetail in
            guard let `self` = self else { return }
            self.isLoading.onNext(false)
                self.trailerData.accept(movieDetail)
            }, onError: { [weak self] error in
                let error = (error as? APIErrors)?.errorStr
                self?.showSnackBar.onNext((message: error, dataExists: true))
                self?.isLoading.onNext(false)
            })
            .disposed(by: self.disposeBag)
    }
}
