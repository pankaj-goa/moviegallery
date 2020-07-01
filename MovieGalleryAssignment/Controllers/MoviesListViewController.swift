//
//  MoviesListViewController.swift
//  MovieGalleryAssignment
//
//  Created by Pankaj Shirodkar on 24/06/20.
//  Copyright © 2020 Pankaj Shirodkar. All rights reserved.
//

import UIKit
import PullToRefresh
import TTGSnackbar
import RxSwift
import RxCocoa

class MoviesListViewController: UIViewController {
    
    @IBOutlet weak var searchBarBottom: NSLayoutConstraint!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var moviesTableView: UITableView!
    @IBOutlet weak var internetStatusLabel: UILabel!
    let moviesCellIdentifier = "MoviesTableViewCell"
    
    var disposeBag = DisposeBag()
    var viewModel = MoviesListViewModel()
    
    var footerIndicator = UIActivityIndicatorView(style: .medium)
    var headerIndicator = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavigationBar(titleName: "Movie Catalog")
        
        self.searchBar.delegate = self
        self.searchBar.searchTextField.clearButtonMode = .whileEditing
        self.searchBar.searchTextField.textAlignment = .center
        let placeholderParagraphStyle = NSMutableParagraphStyle()
        placeholderParagraphStyle.alignment = .center
        self.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search movies",
            attributes: [
                NSAttributedString.Key.paragraphStyle: placeholderParagraphStyle
            ]
        )
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.configActivityIndicator(spinner: footerIndicator)
        self.configActivityIndicator(spinner: headerIndicator)
        
        self.moviesTableView.tableHeaderView = nil
        self.moviesTableView.delegate = self
        self.moviesTableView.dataSource = self
        self.moviesTableView.estimatedRowHeight = 160.0
        self.moviesTableView.tableFooterView = nil
        
        self.viewModel.fetchMovies()
        
        self.moviesTableView.register(UINib(nibName: moviesCellIdentifier, bundle: nil), forCellReuseIdentifier: moviesCellIdentifier)
        
        self.setUpObservers()
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
        
        viewModel.showTopLoaderObservable
        .subscribe(onNext: { [weak self] data in
            self?.showIndicatorAtTop(data.show)
            if data.show == false, data.newMoviesCount > 0 {
                self?.moviesTableView.scrollToRow(at: IndexPath(row: data.newMoviesCount, section: 0), at: .top, animated: false)
            }
        })
        .disposed(by: self.disposeBag)
        
        viewModel.showBottomLoaderObservable
        .subscribe(onNext: { [weak self] isLoading in
            self?.showIndicatorAtBottom(isLoading)
        })
        .disposed(by: self.disposeBag)

        viewModel.dataObservable
        .subscribe(onNext: { [weak self] data in
            if data.isOnline{
                self?.internetStatusLabel.text = nil
            } else{
                self?.internetStatusLabel.text = "No Internet Connection: Offline Data"
                if self?.moviesTableView.topPullToRefresh == nil{ self?.setupPullToRefresh(on: (self?.moviesTableView)!) }
            }
            self?.moviesTableView.reloadData()
        })
        .disposed(by: self.disposeBag)
        
        viewModel.searchDataObservable
        .subscribe(onNext: { [weak self] _ in
            self?.moviesTableView.reloadData()
        })
        .disposed(by: self.disposeBag)
        
        viewModel.didFinishTopPaginationObservable
        .subscribe(onNext: { [weak self] _ in
            self?.setupPullToRefresh(on: (self?.moviesTableView)!)
        })
        .disposed(by: self.disposeBag)
        
        viewModel.didFinishBottomPaginationObservable
        .subscribe(onNext: { [weak self] _ in
            if let _ = self?.moviesTableView.topPullToRefresh, (self?.viewModel.dataSource.isOnline)!{ self?.moviesTableView.removeAllPullToRefresh() }
        })
        .disposed(by: self.disposeBag)
        
        viewModel.showSnackBarObservable
        .subscribe(onNext: { [weak self] message in
            if let txt = message, txt != ""{
                self?.showSnackBar(timeInterval: 1, message: txt)
            }
        })
        .disposed(by: self.disposeBag)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification){
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.searchBarBottom.constant = keyboardHeight
            UIView.animate(withDuration: 0.1, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    @objc private func keyboardWillHide(notification: NSNotification){
        if !self.isViewLoaded || self.view.window == nil{
            return
        }
        if let _ = notification.userInfo{
            self.searchBarBottom.constant = 5.0
            UIView.animate(withDuration: 0.1, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func showIndicatorAtTop(_ value: Bool){
        if value{
            self.headerIndicator.startAnimating()
            self.moviesTableView.tableHeaderView = self.headerIndicator
        } else{
            self.headerIndicator.stopAnimating()
            self.moviesTableView.tableHeaderView = nil
        }
    }
    
    func showIndicatorAtBottom(_ value: Bool){
        if value{
            self.footerIndicator.startAnimating()
            self.moviesTableView.tableFooterView = self.footerIndicator
        } else{
            self.footerIndicator.stopAnimating()
            self.moviesTableView.tableFooterView = nil
        }
    }
    
    func configActivityIndicator(spinner: UIActivityIndicatorView){
        let indicator = spinner
        spinner.color = UIColor.darkGray
        indicator.hidesWhenStopped = true
        indicator.frame = CGRect(x: 0, y: 0, width: moviesTableView.bounds.width, height: CGFloat(40))
    }
    
    func setupPullToRefresh(on scrollView: UIScrollView) {
        scrollView.addPullToRefresh(PullToRefresh()) {
            DispatchQueue.main.async() { [weak self, weak scrollView] in
                scrollView?.endRefreshing(at: .top)
                self?.viewModel.resetDataSource()
                self?.viewModel.fetchMovies(pageNo: 1)
                self?.view.layoutIfNeeded()
            }
        }
        scrollView.addPullToRefresh(PullToRefresh(position: .bottom)) {
            DispatchQueue.main.async() { [weak self, weak scrollView] in
            scrollView?.endRefreshing(at: .top)
            self?.view.layoutIfNeeded()
        }}
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

extension MoviesListViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.searchBar.isEmpty()) ? self.viewModel.dataSource.movies.count : self.viewModel.searchDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let movie = (self.searchBar.isEmpty()) ? self.viewModel.dataSource.movies[indexPath.row] : self.viewModel.searchDataSource[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: moviesCellIdentifier) as! MoviesTableViewCell
        cell.movie = movie
        return cell
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if self.searchBar.isEmpty() && self.viewModel.dataSource.isOnline{
            if indexPath.row == 0, !self.headerIndicator.isAnimating{
                self.showIndicatorAtTop(true)
                self.viewModel.fetchMovies(pageNo: self.viewModel.topPageNo - 1)
            }
            let lastIndex = self.viewModel.dataSource.movies.count - 1
            if indexPath.row == lastIndex{
                if let _ = tableView.topPullToRefresh{ tableView.removeAllPullToRefresh()}
                self.showIndicatorAtBottom(true)
                self.viewModel.fetchMovies(pageNo: self.viewModel.bottomPageNo + 1)
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = self.searchBar.isEmpty() ? self.viewModel.dataSource.movies[indexPath.row] : self.viewModel.searchDataSource[indexPath.row]
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil) //initialise
        let movieDetailsVC = storyboard.instantiateViewController(withIdentifier: "MovieDetailsViewController") as! MovieDetailsViewController
        movieDetailsVC.movieId = movie.id
        let backButtonTitle = self.navigationItem.title
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: backButtonTitle, style: .plain, target: nil, action: nil)
        self.navigationController?.pushViewController(movieDetailsVC, animated: true)
    }
}

extension MoviesListViewController: UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.rx.text.orEmpty
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] text in
                self?.viewModel.searchMoviesByQuery(text)
            })
            .disposed(by: self.disposeBag)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
}
