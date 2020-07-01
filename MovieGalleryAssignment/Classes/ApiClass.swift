
import Foundation
import Alamofire
import RxSwift

///API Errors: Defined enum for server errors
enum APIErrors: Error {
    case serverError
    var errorStr: String {
        switch self {
        default:
            return "Server error, please try after a while"
        }
    }
}
///ApiClass: All network methods are defined within this class.
class ApiClass {
    /**
    Call this function fetching movies by page no.
    - Parameters:
       - pageNo: Pass your page number in Int.
    */
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
    /**
    Call this function to get movie details for a movie id.
    - Parameters:
       - movieId: Pass the movie id for which the details are to be fetched from server
    */
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
    /**
    Call this function to get movie videos URLs for a movie id.
    - Parameters:
       - movieId: Pass the movie id for which the videos are to be fetched from server
    */
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
