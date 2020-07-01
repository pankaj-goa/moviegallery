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
    var totalPages: Int?
    var topPageNo: Int = 0
    var bottomPageNo: Int = 0
    
    private var disposeBag = DisposeBag()
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
    
    func fetchMovies(pageNo: Int = 10) {
        if self.dataSource.movies.isEmpty {
            self.isLoading.onNext(true)
            let movies = Array(try!Realm().objects(Movie.self))
            if movies.count > 0{
                let status = Reach().connectionStatus()
                switch status {
                case .offline, .unknown:
                    self.isLoading.onNext(false)
                    self.data.accept((movies: movies, isOnline: false))
                    return
                default:
                    self.isLoading.onNext(true)
                }
            }
        } else {
            if pageNo > self.bottomPageNo{
                self.showBottomLoader.onNext(true)
            } else if pageNo < self.topPageNo{
                self.showTopLoader.onNext((show: true, newMoviesCount: 0))
            }
        }
        if let total = totalPages, pageNo > total{
            self.didFinishBottomPagination.onNext(true)
            self.showBottomLoader.onNext(false)
            self.isLoading.onNext(false)
            self.showSnackBar.onNext(SnackAlert.pageBottom.msg)
            return
        } else if pageNo < 1 {
            self.didFinishTopPagination.onNext(true)
            self.showTopLoader.onNext((show: false, newMoviesCount: 0))
            self.isLoading.onNext(false)
            self.showSnackBar.onNext(SnackAlert.pageTop.msg)
            return
        }
        
        self.apiCall.fetchMoviesByPage(pageNo)
        .subscribe(onNext: { [weak self] interface in
            guard let `self` = self else { return }
                self.isLoading.onNext(false)
            if let pageInterface = interface.total_pages, let pages = pageInterface.value{
                self.totalPages = pages
            }
            if self.dataSource.movies.isEmpty {
                self.topPageNo = pageNo
                self.bottomPageNo = pageNo
                var movies = self.dataSource.movies
                movies.append(contentsOf: interface.results)
                self.deleteRealmMovieData()
                self.data.accept((movies: movies, isOnline: true))
            } else if pageNo < self.topPageNo{
                self.topPageNo = pageNo
                var movies = self.dataSource.movies
                movies.insert(contentsOf: interface.results, at: 0)
                self.data.accept((movies: movies, isOnline: true))
                self.showTopLoader.onNext((show: false, newMoviesCount: interface.results.count))
            } else if pageNo > self.bottomPageNo{
                self.bottomPageNo = pageNo
                var movies = self.dataSource.movies
                movies.append(contentsOf: interface.results)
                self.data.accept((movies: movies, isOnline: true))
                self.showBottomLoader.onNext(false)
            }
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
    
    func resetDataSource(){
        self.data.accept((movies: [], isOnline: true))
    }
    
    func deleteRealmMovieData(){
        let realm = try! Realm()
        try! realm.write{
            realm.deleteAll()
        }
    }
    
    private func addMovieToRealm(movies: List<Movie>){
        let realm = try! Realm()
        try! realm.write{
            realm.add(movies)
        }
    }
    
    func searchMoviesByQuery(_ search: String) {
        let movies = self.dataSource.movies.filter({$0.title?.prefix(search.count).lowercased() == search.lowercased()})
        self.searchData.accept(movies)
    }
}
