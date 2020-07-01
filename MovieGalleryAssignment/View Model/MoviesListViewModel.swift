//
//  MoviesListViewModel.swift
//  MovieGalleryAssignment
//
//  Created by Pankaj Shirodkar on 24/06/20.
//  Copyright © 2020 Pankaj Shirodkar. All rights reserved.
//



import UIKit
import RxSwift
import RxCocoa
import RealmSwift
import Connectivity

class MoviesListViewModel {
    let apiCall = ApiClass()
    var topPageNo: Int = 0
    var bottomPageNo: Int = 0
    
    let offlineDataTitleText = "Displaying Offline Data, Pull To Refresh"
    let navigationTitleText = "Movie Catalog"
    let moviesCellIdentifier = "MoviesTableViewCell"
    let searchBarPlaceholderText = "Search movies"
    
    private var disposeBag = DisposeBag()
    
    private var interfaceAPIMovies: MoviesAPIInterface?
    
    private let data = BehaviorRelay<(movies: [Movie], isOnline: Bool)>(value: ([], true))
    var dataObservable: Observable<(movies: [Movie], isOnline: Bool)> {
        return data.asObservable()
    }
    var dataSource: (movies: [Movie], isOnline: Bool) {
        return data.value
    }
    private let searchData = BehaviorRelay<[Movie]>(value: [])
    var searchDataObservable: Observable<[Movie]> {
        return searchData.asObservable()
    }
    var searchDataSource: [Movie] {
        return searchData.value
    }
    private let isLoading = PublishSubject<Bool>()
    var isLoadingObservable: Observable<Bool> {
        return isLoading.asObservable()
    }
    private let showTopLoader = PublishSubject<(show: Bool, newMoviesCount: Int)>()
    var showTopLoaderObservable: Observable<(show: Bool, newMoviesCount: Int)> {
        return showTopLoader.asObservable()
    }
    private let showBottomLoader = PublishSubject<Bool>()
    var showBottomLoaderObservable: Observable<Bool> {
        return showBottomLoader.asObservable()
    }
    private let didFinishTopPagination = PublishSubject<Bool>()
    var didFinishTopPaginationObservable: Observable<Bool> {
        return didFinishTopPagination.asObservable()
    }
    private let didFinishBottomPagination = PublishSubject<Bool>()
    var didFinishBottomPaginationObservable: Observable<Bool> {
        return didFinishBottomPagination.asObservable()
    }
    private let showSnackBar = PublishSubject<String?>()
    var showSnackBarObservable: Observable<String?> {
        return showSnackBar.asObservable()
    }
    
    /**
    Call this function to fetch list of movies from server for a page and insert or append data. ie top or bottom also sets the observable values for subscribers and also checks for offline data incase of not connection.
    - Parameters:
       - pageNo: Pass your page no for fetching movies in Int
    
    ### Usage Example: ###
    ````
     fetchMovies(pageNo: 1)
     
    ````
    */
    func fetchMovies(pageNo: Int = 10) {
        if !self.shouldFetchDataAndShowLoaderForPageNo(pageNo){ return }
        
        self.apiCall.fetchMoviesByPage(pageNo)
        .subscribe(onNext: { [weak self] interface in
            guard let `self` = self else { return }
            self.isLoading.onNext(false)
            if self.dataSource.movies.isEmpty {
                var movies = self.dataSource.movies
                movies.append(contentsOf: interface.results)
                self.deleteRealmMovieData()
                self.data.accept((movies: movies, isOnline: true))
                self.topPageNo = pageNo
                self.bottomPageNo = pageNo
            } else if let interfaceMovie = self.interfaceAPIMovies, let page = interfaceMovie.page?.value, page > pageNo{
                self.topPageNo = pageNo
                var movies = self.dataSource.movies
                movies.insert(contentsOf: interface.results, at: 0)
                self.data.accept((movies: movies, isOnline: true))
                self.showTopLoader.onNext((show: false, newMoviesCount: interface.results.count))
            } else {
                self.bottomPageNo = pageNo
                var movies = self.dataSource.movies
                movies.append(contentsOf: interface.results)
                self.data.accept((movies: movies, isOnline: true))
                self.showBottomLoader.onNext(false)
            }
            self.interfaceAPIMovies = interface
            self.addMovieToRealm(movies: interface.results)
            }, onError: { [weak self] error in
                let error = (error as? APIErrors)?.errorStr
                self?.showSnackBar.onNext(error)
                self?.isLoading.onNext(false)
                self?.showTopLoader.onNext((show: false, newMoviesCount: 0))
                self?.showBottomLoader.onNext(false)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func shouldFetchDataAndShowLoaderForPageNo(_ pageNo: Int) -> Bool{
        if let movieInterface = self.interfaceAPIMovies, !self.dataSource.movies.isEmpty{
            if let page = movieInterface.page?.value, page > pageNo{
                self.showTopLoader.onNext((show: true, newMoviesCount: 0))
            } else{
                self.showBottomLoader.onNext(true)
            }
            if !self.checkIfMoreRecordsExits(movieInterface: movieInterface, pageNo: pageNo){
                return false
            }
        } else{ //NO DATA PRESENT
            if let movies = checkIfOffline(){
                self.data.accept((movies: movies, isOnline: false))
                return false
            }
            else{
                self.isLoading.onNext(true) //try to fetch data
            }
        }
        return true
    }
    
    private func checkIfMoreRecordsExits(movieInterface: MoviesAPIInterface, pageNo: Int) -> Bool{
        if let total = movieInterface.total_pages?.value, pageNo > total{
            self.didFinishBottomPagination.onNext(true)
            self.showBottomLoader.onNext(false)
            self.isLoading.onNext(false)
            self.showSnackBar.onNext(SnackAlert.pageBottom.msg)
            return false
        } else if pageNo < 1 {
            self.didFinishTopPagination.onNext(true)
            self.showTopLoader.onNext((show: false, newMoviesCount: 0))
            self.isLoading.onNext(false)
            self.showSnackBar.onNext(SnackAlert.pageTop.msg)
            return false
        } else{
            return true
        }
    }
    
    private func checkIfOffline() -> [Movie]?{
        let movies = Array(try!Realm().objects(Movie.self))
        if movies.count > 0, !Reach().isConnectedToInternet(){
            return movies
        } else {
            return nil
        }
    }
    
    ///Call this function to remove all the records from the datasource.
    func resetDataSource(){
        self.topPageNo = 0
        self.bottomPageNo = 0
        self.interfaceAPIMovies = nil
        self.data.accept((movies: [], isOnline: true))
    }
    
    //Call this function to remove all the records from the realm database.
    func deleteRealmMovieData(){
        let realm = try! Realm()
        try! realm.write{
            realm.deleteAll()
        }
    }
    
    /**
    Call this function to add data to the realm db.
    - Parameters:
       - movies: Pass list of movies to be added to the realm database.
    */
    private func addMovieToRealm(movies: List<Movie>){
        let realm = try! Realm()
        try! realm.write{
            realm.add(movies)
        }
    }
    
    /**
    Call this function to filter the datasource.movies array and set searchArray from the search string with prefix characters in datasource.movies
    - Parameters:
       - search: Pass search keyword.
    */
    func searchMoviesByQuery(_ search: String) {
        let movies = self.dataSource.movies.filter({$0.title?.prefix(search.count).lowercased() == search.lowercased()})
        self.searchData.accept(movies)
    }
}
