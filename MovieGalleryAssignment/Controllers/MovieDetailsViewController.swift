//
//  MovieDetailsViewController.swift
//  MovieGalleryAssignment
//
//  Created by Pankaj Shirodkar on 25/06/20.
//  Copyright © 2020 Pankaj Shirodkar. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class MovieDetailsViewController: UIViewController {

    @IBOutlet weak var containerStackView: UIStackView!
    @IBOutlet weak var container1: UIView!
    @IBOutlet weak var container2: UIView!
    @IBOutlet weak var buttonTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var watchTrailerButton: UIButton!
    
    @IBOutlet weak var genrelabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var overViewLabel: UILabel!
    
    @IBOutlet weak var genresContainerView: UIView!
    @IBOutlet weak var releaseDateContainerView: UIView!
    @IBOutlet weak var overviewContainerView: UIView!
    
    var viewModel = MoviesDetailsViewModel()
    
    var widthConstraint: NSLayoutConstraint?
    var buttonTitleVerticalSpacingConstraint: NSLayoutConstraint?
    var disposeBag = DisposeBag()
    
    var movieId: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavigationBar(titleName: "Movie Details")
        self.setUpObservers()
        self.viewModel.fetchMovieDetailsById(movieId)
        
    }

    private func setUpObservers() {
        viewModel.isLoadingObservable
        .subscribe(onNext: { [weak self] isLoading in
            if isLoading {
                self?.showProgressLoader()
            } else {
                self?.hideProgressLoader()
            }
        })
        .disposed(by: self.disposeBag)
        
        viewModel.dataObservable
        .subscribe(onNext: { [weak self] movie in
            self?.updatePageContents()
        })
        .disposed(by: self.disposeBag)
        
        viewModel.trailerDataObservable
        .subscribe(onNext: { [weak self] data in
            self?.playMovieTrailer()
        })
        .disposed(by: self.disposeBag)
        
        viewModel.showSnackBarObservable
        .subscribe(onNext: { [weak self] data in
            if let txt = data.message, txt != ""{
                self?.showSnackBar(timeInterval: 1, message: txt)
            }
            if !data.dataExists{
                self?.navigationController?.popViewController(animated: true)
            }
        })
        .disposed(by: self.disposeBag)
    }
    
    private func updatePageContents(){
        if let posterPath = viewModel.posterPath, posterPath != ""{
            self.container1.isHidden = false
            loadImageView(posterPath: posterPath)
            self.setupConstraints()
        } else{
            self.container1.isHidden = true
        }
        if let movieTitle = viewModel.movieTitle{
            self.movieTitleLabel.text = movieTitle
            self.container2.isHidden = false
        } else{
            self.container2.isHidden = true
        }
        
        if let genres = viewModel.genres{
            self.genresContainerView.isHidden = false
            self.genrelabel.text = genres
        } else{
            self.genresContainerView.isHidden = true
        }
        if let releaseDate = viewModel.releaseDate{
            self.releaseDateContainerView.isHidden = false
            self.releaseDateLabel.text = releaseDate
        } else{
            self.releaseDateContainerView.isHidden = true
        }
        if let overviewTxt = viewModel.overviewTxt{
            self.overviewContainerView.isHidden = false
            self.overViewLabel.text = overviewTxt
        } else{
            self.overviewContainerView.isHidden = true
        }
    }
    
    private func loadImageView(posterPath: String){
        if #available(iOS 13.0, *) {
            self.posterImageView.sd_setIndicatorStyle(.medium)
        } else {
            self.posterImageView.sd_setIndicatorStyle(.gray)
        }
        self.posterImageView.sd_setShowActivityIndicatorView(true)
        self.posterImageView.sd_setImage(with: URL(string: "\(posterBaseUrl)\(posterPath)"), placeholderImage: nil, options: [], completed: nil)
    }
    
    private func setupConstraints(){
        self.buttonTopConstraint.isActive = false
        buttonTitleVerticalSpacingConstraint = self.watchTrailerButton.topAnchor.constraint(equalTo: self.movieTitleLabel.bottomAnchor, constant: 10)
        buttonTitleVerticalSpacingConstraint?.isActive = true
        widthConstraint = container2.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.4)
        NotificationCenter.default.addObserver(self, selector: #selector(updateOrientation), name: UIDevice.orientationDidChangeNotification, object: nil)
        self.updateOrientation()
    }
    
    @objc func updateOrientation() {
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight:
            buttonTitleVerticalSpacingConstraint?.isActive = false
            widthConstraint?.isActive = true
            containerStackView.axis = .horizontal
        default:
            buttonTitleVerticalSpacingConstraint?.isActive = true
            widthConstraint?.isActive = false
            containerStackView.axis = .vertical
        }
    }
    
    @IBAction func didClickWatchTrailer(_ sender: Any) {
        self.viewModel.fetchMovieTrailersById(self.movieId)
    }
    private func playMovieTrailer(){
        if let youtubeId = self.viewModel.youtubeId{
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil) //initialise
            let videoPlayerVC = storyboard.instantiateViewController(withIdentifier: "VideoPlayerViewController") as! VideoPlayerViewController
            videoPlayerVC.youtubeId = youtubeId
            self.present(videoPlayerVC, animated: true, completion: nil)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
}
