
import Foundation
import Alamofire
import RxSwift

enum APIErrors: Error {
    case serverError
    var errorStr: String {
        switch self {
        default:
            return "Server error, please try after a while"
        }
    }
}

class ApiClass {
    
    public func fetchMoviesByPage(_ pageNo: Int) -> Observable<MoviesAPIInterface> {
        let apiURL = URL(string: "\(baseUrl)/popular?api_key=\(apiKey)&page=\(pageNo)")!
        return Observable.create { observer in
            AF.request(apiURL).response { response in
                switch response.result{
                case .success:
                do{
                    let moviesAPIInterface = try JSONDecoder().decode(MoviesAPIInterface.self, from: response.data!)
                    observer.onNext(moviesAPIInterface)
                } catch {
                    observer.onError(APIErrors.serverError)
                }
                case .failure:
                    observer.onError(APIErrors.serverError)
                }
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    public func fetchMovieDetailsById(_ movieId: Int) -> Observable<Movie>{
        let apiURL = URL(string: "\(baseUrl)/\(movieId)?api_key=\(apiKey)")!
        return Observable.create { observer in
            AF.request(apiURL).response { response in
                switch response.result{
                case .success:
                do{
                    let movie = try JSONDecoder().decode(Movie.self, from: response.data!)
                    observer.onNext(movie)
                } catch {
                    observer.onError(APIErrors.serverError)
                }
                case .failure:
                    observer.onError(APIErrors.serverError)
                }
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    public func fetchMovieTrailersById(_ movieId: Int) -> Observable<Movie>{
        let apiURL = URL(string: "\(baseUrl)/\(movieId)/videos?api_key=\(apiKey)")!
        return Observable.create { observer in
            AF.request(apiURL).response { response in
                switch response.result{
                case .success:
                do{
                    let movie = try JSONDecoder().decode(Movie.self, from: response.data!)
                    observer.onNext(movie)
                } catch {
                    observer.onError(APIErrors.serverError)
                }
                case .failure:
                    observer.onError(APIErrors.serverError)
                }
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
}
