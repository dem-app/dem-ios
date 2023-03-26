//
//  FeedTableViewCell.swift
//  Dem
//
//  Created by Vishnu Prem on 29/06/22.
//

import UIKit
import FlexiblePageControl
//import Lottie
import WebKit
import AVFoundation
import AVKit

class FeedTableViewCell: UITableViewCell, WKNavigationDelegate {

    @IBOutlet weak var profileSectionView: UIView!
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var userIdLbl: UILabel!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var cv_images: UICollectionView!
    @IBOutlet weak var border_view: UIView!
    @IBOutlet weak var web_view: WKWebView!

    var isLikeClicked: Bool = false
    var isplayBtnClicked: Bool = false
//    var imagArray = ["apple1", "dks3331", "dks3332", "dks3333", "dks3334", "dks3335", "dks3336", "facebookapp1", "github1", "github2", "instagram1", "instagram2"]
    var imagArray = [Any]()
    var selectedIndex: Int!
//    var imagArray = [["apple1"], ["dks3331", "dks3332"], ["dks3333"], ["dks3334", "dks3335", "dks3336"], ["facebookapp1", "github1"],[ "github2"], ["instagram1", "instagram2"]]
//
//    var section0 = ["apple1"]
//    var section1 = ["dks3331", "dks3332"]
//    var section2 = ["dks3333"]
//    var section3 = ["dks3334", "dks3335", "dks3336"]
//    var section4 = ["facebookapp1", "github1"]
//    var section5 = ["github2"]
//    var section6 = ["instagram1", "instagram2"]

    @IBOutlet weak var likeBtn: UIButton! {
        didSet {
            likeBtn.addTarget(self, action: #selector(self.likePost), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var pageControl: FlexiblePageControl! {
        didSet {
            pageControl.numberOfPages = imagArray.count
            pageControl.pageIndicatorTintColor = UIColor(red: 200/255, green: 204/255, blue: 208/255, alpha: 1)
            pageControl.currentPageIndicatorTintColor = UIColor(red: 255/255, green: 94/255, blue: 58/255, alpha: 1)
        }
    }
    
    @IBOutlet weak var bookMarkBtn: UIButton!
    @IBOutlet weak var likeView: UIView!
    @IBOutlet weak var likeLbl: UILabel!
    @IBOutlet weak var tv_caption: UITextView!
    @IBOutlet weak var commentLbl: UILabel!
    @IBOutlet weak var commentTextLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
//    var animationView = AnimationView(name: "heart")
    @IBOutlet weak var view_delete: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        view_delete.isHidden = true
        cv_images.register(UINib(nibName: "FeedImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FeedImageCollectionViewCell")
        web_view.navigationDelegate = self
        
        cv_images.register(UINib(nibName: "DocumentAttachmentCell", bundle: nil), forCellWithReuseIdentifier: "DocumentAttachmentCell")
        cv_images.register(UINib(nibName: "VideoPlayerCell", bundle: nil), forCellWithReuseIdentifier: "VideoPlayerCell")

        // Initialization code
//        animationView = AnimationView(name: "heart")
//        animationView.animationSpeed = 1.7
//        animationView.loopMode = .playOnce
//        self.border_view.addSubview(animationView)
//        animationView.snp.makeConstraints({ make in
//            make.height.width.equalTo(110)
//            make.center.equalTo(imageCollectionView)
//        })

        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.animateHeart))
        doubleTap.numberOfTapsRequired = 2
        cv_images.addGestureRecognizer(doubleTap)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func animateHeart() {
        UIImpactFeedbackGenerator.init(style: .light).impactOccurred()
//        animationView.play()
        likeBtn.setBackgroundImage(UIImage(systemName: "heart.fill"), for: .normal)
        likeBtn.tintColor = .systemRed
        isLikeClicked = true
    }
    
    @objc func likePost() {
        if isLikeClicked {
            likeBtn.setBackgroundImage(UIImage(systemName: "heart.fill"), for: .normal)
            likeBtn.tintColor = .systemRed
        } else {
            likeBtn.setBackgroundImage(UIImage(systemName: "heart"), for: .normal)
            likeBtn.tintColor = UIColor.black
        }
        isLikeClicked = !isLikeClicked
    }
    
}

extension FeedTableViewCell:  UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
           return imagArray.count

     }
     
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedImageCollectionViewCell", for: indexPath) as! FeedImageCollectionViewCell
         
//             cell.imgView.image = UIImage(named: imagArray[indexPath.row])
  
         
         let key = imagArray[indexPath.row] as! MCOAttachment
 //            for key in dict as! [MCOAttachment] {
//                 print(key)
                 if key.mimeType == "image/jpeg" || key.mimeType == "image/jpg" {
//                     let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AttachmentCell", for: indexPath) as! AttachmentCell

                     cell.imgView.image = UIImage(data: key.data)

//                     return cell
                 } else if key.mimeType == "video/mp4" {
                     let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoPlayerCell", for: indexPath) as! VideoPlayerCell

//                     cell.lbl_title.text = key.filename
                     

                     cell.btn_play.tag = indexPath.row
                     cell.btn_play.addTarget(self, action: #selector(buttonClick(sender:)), for: .touchUpInside)
                     return cell
                 }
         
         if imagArray.count == 1 {
             pageControl.numberOfPages = 0

         } else {
             pageControl.numberOfPages = imagArray.count

         }

        return cell
     }
     
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.border_view.bounds.width, height: 303)
    }
    
    
    @objc func buttonClick(sender: UIButton) {
        
        let ind = IndexPath(row: sender.tag, section: 0)
        let cell = cv_images.cellForItem(at: ind) as? VideoPlayerCell
        let key = imagArray[ind.row] as! MCOAttachment

        if key.mimeType == "video/mp4" {
            
            let data = key.data
            let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("video.mp4")
            do {
                try data?.write(to: cacheURL, options: .atomicWrite)
            } catch let err {
                print("Failed with error:", err.localizedDescription)
            }
            
            let player = AVPlayer(url: cacheURL)
            let vcPlayer = AVPlayerLayer(player: player)
            vcPlayer.frame = (cell?.view_player.bounds)!
            cell?.view_player.layer.addSublayer(vcPlayer)
            
            if isplayBtnClicked == false {
                vcPlayer.player?.play()
                isplayBtnClicked = true
                cell?.btn_play.setImage(UIImage(named: "pause"), for: .normal)
            } else {
                vcPlayer.player?.pause()
                isplayBtnClicked = false
                cell?.btn_play.setImage(UIImage(named: "play-button"), for: .normal)
            }
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        let key = imagArray[indexPath.row] as! MCOAttachment
//
//        if key.mimeType == "video/mp4" {
//
//
//
//
//        }
//    }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//
//        let key = imagArray[indexPath.row] as! MCOAttachment
//
//        if key.mimeType == "video/mp4" {
////            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoPlayerCell", for: indexPath) as! VideoPlayerCell
//            let ind = IndexPath(row: indexPath.row, section: 0)
//            let cell = collectionView.cellForItem(at: ind) as? VideoPlayerCell
////                     cell.lbl_title.text = key.filename
//            let data = key.data
//            let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("video.mp4")
//            do {
//                try data?.write(to: cacheURL, options: .atomicWrite)
//            } catch let err {
//                print("Failed with error:", err.localizedDescription)
//            }
//
//            let player = AVPlayer(url: cacheURL)
//            let vcPlayer = AVPlayerLayer(player: player)
//            vcPlayer.frame = (cell?.view_player.bounds)!
//            cell!.view_player.layer.addSublayer(vcPlayer)
//            vcPlayer.player?.play()
//
////            cell!.view_player.layer.addSublayer(vcPlayer)
//        }
//    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.setCurrentPage(at: Int(scrollView.contentOffset.x  / self.border_view.frame.width))
    }
    
}
