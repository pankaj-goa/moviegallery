//
//  VideoPlayerViewController.swift
//  MovieGalleryAssignment
//
//  Created by Pankaj Shirodkar on 26/06/20.
//  Copyright © 2020 Pankaj Shirodkar. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class VideoPlayerViewController: UIViewController{

    @IBOutlet weak var playerView: YTPlayerView!
    
    var youtubeId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerView.delegate = self
        playerView.backgroundColor = UIColor.black
        playerView.load(withVideoId: youtubeId)
    }
    
    private func dismiss(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didClickDone(_ sender: Any) {
        self.playerView.stopVideo()
        self.dismiss()
    }
}

extension VideoPlayerViewController: YTPlayerViewDelegate{
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        playerView.playVideo()
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        if state == .ended{
            self.dismiss()
        }
    }
}
