//
//  MoviesTableViewCell.swift
//  MovieGalleryAssignment
//
//  Created by Pankaj Shirodkar on 24/06/20.
//  Copyright © 2020 Pankaj Shirodkar. All rights reserved.
//

import UIKit
import SDWebImage

class MoviesTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.posterImageView.layer.borderColor = UIColor.darkGray.cgColor
        self.posterImageView.layer.borderWidth = 0.5
        
        self.containerView.layer.shadowColor = UIColor.lightGray.cgColor
        self.containerView.layer.shadowOpacity = 1
        self.containerView.layer.shadowOffset = .zero
        self.containerView.layer.shadowRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    var movie: Movie!{
        didSet{
            if #available(iOS 13.0, *) {
                self.posterImageView.sd_setIndicatorStyle(.medium)
            } else {
                self.posterImageView.sd_setIndicatorStyle(.gray)
            }
            self.posterImageView.sd_setShowActivityIndicatorView(true)
            self.posterImageView.sd_setImage(with: URL(string: "\(posterBaseUrl)\(movie.poster_path ?? "")"), placeholderImage: nil, options: [], completed: nil)
            self.titleLabel.text = "\(movie.title ?? "")"
        }
    }
    
}
