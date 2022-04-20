//
//  HCOpenVideoIphoneVC.swift
//   
//
//    23/04/19.
//  Copyright © 2019  . All rights reserved.
//


import UIKit
import SwiftyJSON
import AVKit
import AVFoundation

//typealias CompletionWithImage = (_ image:UIImage) -> Void
//
//protocol ManagePlyersDelegte{
//    func didPlayVideo(status:Bool)
//
//}
//var playDelegate : ManagePlyersDelegte?

class HCOpenVideoIphoneVC: UIViewController {
    
    @IBOutlet weak var tbl_HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var view_Video: UIView!
    @IBOutlet weak var view_GradiantBottom: UIView!
    @IBOutlet weak var view_GradiantLeft: UIView!
    @IBOutlet weak var view_GradiantRight: UIView!
    @IBOutlet weak var btnView: UIButton!
    @IBOutlet weak var btnLikedRef: UIButton!
    @IBOutlet weak var img_Like: UIImageView!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var addToMyListButton: UIButton!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var img_Thumb: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var tblVw: UITableView!
    var SubCategoriesVideoVMObj =  SubCategoriesVideoVM()
    var SubCategoryViewAllTopModelAry = [SubCategoryViewAllTopModel]()
    var activityIndicator: UIActivityIndicatorView!
    
    var likeState = Int()
    var str_ActivityType : String!
    var str_CategoryValue : String!
    var str_VideoId : String!
    var str_VideoUrl : String!
    var str_FromController : String!
    
    var player : AVPlayer?
    var playerController  : AVPlayerViewController?
    var count_Time = 5
    var lbl_CountDown:UILabel!
    var lbl_PlayNext:UILabel!
    var arr_AllVideos = [VideoModel]()
    var openPlayer : AVPlayer?
    var currentItem : AVPlayerItem!
    var timerCountDown = Timer()
    var VideoIndexx = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.addToMyListButton.layer.cornerRadius = self.addToMyListButton.frame.height/2
        self.perform(#selector(self.getData), with: nil, afterDelay: 2)
        self.tblVw.addObserver(self, forKeyPath: "contentSize", options: [], context: nil)
        
        // Register for notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: nil) // Add observer
    }
    
    // Notification Handling
    @objc func playerItemDidReachEnd(notification: NSNotification) {
        
        
        VideoIndexx = VideoIndexx+1
        
        print("play next video  ---- \(VideoIndexx)")
        
        if VideoIndexx >= arr_AllVideos.count {
            VideoIndexx = 0
        }
        
        count_Time = 5
        self.lbl_CountDown?.text  = "5"
        self.lbl_CountDown?.isHidden = false
        self.lbl_PlayNext?.isHidden = false
        timerCountDown.invalidate()
        self.timerCountDown =     Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update) , userInfo: nil, repeats: true)
        
    }
    
    @objc func update() {
        //     if(count_Time > 0) {
        
        self.lbl_CountDown?.text = "\(count_Time)"
        self.lbl_CountDown?.textColor =  UIColor.white //colorArray[count_Time]
        count_Time -= 1
        
        //UIColor(red: CGFloat(Double(arc4random() % 256) / 256.0), green: CGFloat(Double(arc4random() % 256) / 256.0), blue: CGFloat(Double(arc4random() % 256) / 256.0), alpha: 1.0)
        
        if self.lbl_CountDown?.text == "0" {
            self.lbl_CountDown?.isHidden = true
            self.lbl_PlayNext?.isHidden = true
            if arr_AllVideos.count > 0 {
                
                
                let VideoModelAryObj = arr_AllVideos[VideoIndexx]
                
                self.str_VideoId = VideoModelAryObj.videoId
                let videoURL = URL(string: "\(Apis.KVideoURl)\(VideoModelAryObj.videoUrl)")
                str_VideoUrl = videoURL?.absoluteString
                
                self.currentItem = AVPlayerItem.init(url: videoURL!)
                self.openPlayer?.replaceCurrentItem(with: self.currentItem)
                self.openPlayer?.play()
                timerCountDown.invalidate()
                
            }
        }
        
        //        } else {
        //            let VideoModelAryObj = arr_AllVideos[1]
        //
        //            self.str_VideoId = VideoModelAryObj.videoId
        //            let videoURL = URL(string: "\(Apis.KVideoURl)\(VideoModelAryObj.videoUrl)")
        //            str_VideoUrl = videoURL?.absoluteString
        //
        //            self.currentItem = AVPlayerItem.init(url: videoURL!)
        //            self.openPlayer?.replaceCurrentItem(with: self.currentItem)
        //            self.openPlayer?.play()
        //            //            self.playVideo(UIButton())
        //        }
    }
    
    // Remove Observer
    deinit {
        print("dealloc playerr")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        DispatchQueue.main.async {
            if !(self.tblVw.contentSize.height >= 70) {
                self.tbl_HeightConstraint.constant = 70
            } else {
                self.tbl_HeightConstraint.constant = self.tblVw.contentSize.height
            }
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        SelectedVideoObj = self
    }
    
    @objc func getData() {
        getCategoryDetailData()
    }
    
    override func viewDidAppear(_ animated: Bool)  {
        
        if view_GradiantLeft != nil{
            
            if !KAppDelegate.isGradiantShown {
                let gradientLayer:CAGradientLayer = CAGradientLayer()
                gradientLayer.frame.size = view_GradiantBottom.frame.size
                gradientLayer.colors =
                    [UIColor.black.withAlphaComponent(0).cgColor,UIColor.black.withAlphaComponent(1).cgColor]
                //        Use diffrent colors
                view_GradiantBottom.layer.sublayers=nil
                view_GradiantBottom.layer.addSublayer(gradientLayer)
                
                let gradientLayer1:CAGradientLayer = CAGradientLayer()
                gradientLayer1.frame.size = view_GradiantLeft.frame.size
                gradientLayer1.startPoint = CGPoint(x: 0.0, y: 0.5) //x = left to right
                gradientLayer1.endPoint = CGPoint(x: 1.0, y: 0.5) // x = right to left
                gradientLayer1.colors =
                    [UIColor.black.withAlphaComponent(1).cgColor,UIColor.black.withAlphaComponent(0).cgColor]
                //        Use diffrent colors
                view_GradiantLeft.layer.sublayers=nil
                view_GradiantLeft.layer.addSublayer(gradientLayer1)
                KAppDelegate.isGradiantShown=true
            }
        }
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        KAppDelegate.isGradiantShown=false
        self.viewDidAppear(false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if playerController != nil {
            if self.player?.timeControlStatus == .playing {
                self.player?.pause()
            }
              self.timerCountDown.invalidate()
            
            self.player = nil
            self.playerController?.player = nil
            self.playerController = nil
            self.playerController?.willMove(toParent: self)
            self.playerController?.view.removeFromSuperview()
            self.playerController?.removeFromParent()
        }
    }
    
    @IBAction func buttonCross(_ sender: Any) {
        
        playDelegate?.didPlayVideo(status: true)
        self.tblVw.removeObserver(self, forKeyPath: "contentSize", context: nil)
        if playerController != nil {
            if self.player?.timeControlStatus == .playing {
                self.player?.pause()
            }
            self.player = nil
            self.playerController?.player = nil
            self.playerController = nil
            self.playerController?.willMove(toParent: self)
            self.playerController?.view.removeFromSuperview()
            self.playerController?.removeFromParent()
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func playVideo(_ sender: Any) {
        if (str_VideoUrl != nil) {
            if str_VideoUrl != "" {
                let videoURL = URL(string: str_VideoUrl)
                self.openPlayer = AVPlayer(url: videoURL!)
                let playerViewController = AVPlayerViewController()
                playerViewController.allowsPictureInPicturePlayback=true
                playerViewController.player = self.openPlayer
                
                if arr_AllVideos.count > 0 {
                    
                    for i in 0..<arr_AllVideos.count {
                        let VideoModelAryObj = arr_AllVideos[i]
                        if VideoModelAryObj.videoId == str_VideoId {
                            VideoIndexx = i
                        }
                    }
                }
                
                self.present(playerViewController, animated: true) {
                    self.count_Time=5
                    playerViewController.player!.play()
                    
                    
                    //   if (self.lbl_CountDown == nil) {
                    self.lbl_CountDown = nil
                    self.lbl_PlayNext = nil
                    
                    self.lbl_CountDown = UILabel()
                    self.lbl_CountDown.frame = CGRect.init(x: 0, y: 0, width: 80, height: 60)
                    
                    self.lbl_CountDown.textColor = .red
                    self.lbl_CountDown.font = UIFont.boldSystemFont(ofSize: 45)
                    self.lbl_CountDown.textAlignment = .center
                    self.lbl_CountDown.center = CGPoint.init(x: playerViewController.view.center.x, y: playerViewController.view.center.y)
                    self.lbl_CountDown.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.9)
                    self.lbl_CountDown.layer.cornerRadius = 5
                    self.lbl_CountDown.clipsToBounds =  true
                    playerViewController.view.addSubview(self.lbl_CountDown)
                    self.lbl_CountDown.isHidden = true
                    
                    self.lbl_PlayNext = UILabel()
                    self.lbl_PlayNext.frame = CGRect.init(x: self.lbl_CountDown.frame.origin.x-40, y: self.lbl_CountDown.frame.origin.y+self.lbl_CountDown.frame.size.height, width: 180, height: 60)
                    self.lbl_PlayNext.font = UIFont.boldSystemFont(ofSize: 19)
                    self.lbl_PlayNext.text = "Playing next video"
                    self.lbl_PlayNext.textColor = .white
                    //  self.lbl_PlayNext.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.1)
                    playerViewController.view.addSubview(self.lbl_PlayNext)
                    self.lbl_PlayNext.isHidden = true
                    // }
                    
                    self.count_Time = 0
                    self.update()
                    
                }
            }
        }
    }
    
    @IBAction func btnLikedAction(_ sender: Any) {
        
        if Proxy.shared.userId() != "" || Proxy.shared.authNil() != ""{
            if self.likeState == 0 {
                self.videoLikeApi { }
            } else {
                self.videoDislikeApi {  }
            }
        } else {
            Proxy.shared.presentAlert(withTitle: "", message: "Please login", currentViewController: self)
        }
    }
    
    @IBAction func btnAddToCampVideo(_ sender: Any) {
        if Proxy.shared.userId() != "" || Proxy.shared.authNil() != ""{
            self.addToMyCampApi { }
        }
        else{
            Proxy.shared.presentAlert(withTitle: "", message: "Please login", currentViewController: self)
        }
    }
}

//MARK:- Get Categories
extension HCOpenVideoIphoneVC {
    func getCategoryDetailData() {
        self.SubCategoryViewAllTopModelAry.removeAll()
        
        if Proxy.shared.userId() != "" || Proxy.shared.authNil() != "" {
            self.getSubCategoriesApi (completion: {(bannerData) -> Void in
                
                self.videoPlayerPlay(Url: bannerData[0]["video"].stringValue,thumbURL: URL.init(string: "\(Apis.KVideosThumbURL)\(bannerData[0]["image_thumbnail"].stringValue)"))
                self.btnView.setTitle("\(bannerData[0]["views"].arrayValue.count)", for: .normal)
                self.lblTitle.text! = bannerData[0]["video_title"].stringValue
                let string =  bannerData[0]["video_description"].stringValue
                self.lblDescription.text! = string.htmlToString
                
                self.postHomeScreenApiWithActivityType(type: self.str_ActivityType, categoryValue: self.str_CategoryValue, completionHandler: {(success) -> Void in
                    if success {
                        DispatchQueue.main.async {
                            self.tblVw.reloadData()
                        }
                        
                    } else {
                        
                    }
                    Proxy.shared.hideActivityIndicator()
                })
            })
        } else {
            Proxy.shared.presentAlert(withTitle: "", message: "Please Login", currentViewController: self)
        }
    }
    
    //MARK:--> PLAY VIDEO  FUNCTION
    func videoPlayerPlay(Url: String,thumbURL:URL!) {
        
        let videoURL = URL(string: "\(Apis.KVideoURl)\(Url)")
        str_VideoUrl = videoURL?.absoluteString
        if playerController  != nil {
            //            let thumbnail = UIImageView( )
            //            thumbnail.frame = view_Video.bounds
            //            thumbnail.sd_setImage(with: thumbURL,placeholderImage: #imageLiteral(resourceName: "Group 12-1"), completed: nil)
            img_Thumb.sd_setImage(with: thumbURL,placeholderImage: #imageLiteral(resourceName: "Group 12-1"), completed: nil)
            //            self.playerController?.contentOverlayView?.addSubview(img_Thumb)
            //            let currentItem = AVPlayerItem.init(url:... videoURL!)
            //            player?.replaceCurrentItem(with: currentItem)
            //            player?.play()
            
        } else {
            
            playerController  = AVPlayerViewController()
            //            player = AVPlayer(url: videoURL!)
            playerController?.videoGravity = .resizeAspectFill
            //            playerController?.player = player
            playerController?.view = view_Video
            
            playerController?.view.frame = view_Video.bounds
            playerController?.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            playerController?.showsPlaybackControls=false
            playerController?.view.backgroundColor = .black
            //            let thumbnail = UIImageView( )
            //            thumbnail.frame = playerController!.view.frame
            
            img_Thumb.sd_setImage(with: thumbURL,placeholderImage: #imageLiteral(resourceName: "Group 12-1"), completed: nil)
            //            self.playerController?.contentOverlayView?.addSubview(img_Thumb)
            self.addChild(playerController!)
            playerController?.didMove(toParent: self)
            view_Video.addSubview(playerController!.view )
            //            player?.actionAtItemEnd = .none
            //            player?.play()
            
        }
    }
    
}


//MARK:- JSON
extension HCOpenVideoIphoneVC {
    
    //MARK:--> SIGN UP API FUNCTION
    func getSubCategoriesApi(completion: @escaping Completion) {
        let param = [
            "video_id"     :  "\(String(describing: str_VideoId!))",
            "udid"         :  "\(Proxy.shared.userId())",//"\(Proxy.shared.userId())",
            "ip"           :  "12421351sdgwe4t324543"
            ] as [String:AnyObject]
        
        WebServiceProxy.shared.postData("\(Apis.KServerUrl)\(Apis.KGetVideoDetail)", params: param, showIndicator: false, completion: { (jsonResults) in
            
            //            self.VideoLiked = jsonResults["is_video_liked"] as? Int ?? 0
            //            self.totalLike = jsonResults["totallikes"] as? Int ?? 0
            //image_thumbnail
            self.likeState = jsonResults["is_video_liked"] as? Int ?? 0
            if self.likeState == 0 {
                self.img_Like.image = UIImage(named: "like")
            } else{
                self.img_Like.image = UIImage(named: "like")
            }
            self.setLikeButtonStatus(status: self.likeState)
            self.btnLikedRef.setTitle("  \(jsonResults["totallikes"] as? Int ?? 0)", for: .normal)
            
            var jsonObj = JSON()
            
            // Get results in SwiftyJSON
            if let results = jsonResults["results"] as? NSArray {
                jsonObj = JSON(results)
            }
            completion(jsonObj)
            Proxy.shared.hideActivityIndicator()
        })
    }
    
    //MARK:--> GET HOME SCREEN API
    func postHomeScreenApiWithActivityType(type:String!,categoryValue:String!,completionHandler: @escaping CompletionHandler) {
        
        let param = [
            "activity_type": "\(String(describing: type!))",
            "all_videos": "1",
            "form_search_key": "",
            "page_no": "1",
            "page_size": "100",
            "sub_category": "\(String(describing: categoryValue!))",
            "user_id"     :  "\(Proxy.shared.userId())"
            ] as [String:AnyObject]
        
        var url:String = ""
        if str_FromController == "FavVideos" {
            url = Apis.KFavouritesVideo
        } else if str_FromController == "RecentVideos" {
            url = Apis.KRecentVideos
        } else {
            url = Apis.KGetCategoriesItems
        }
        
        WebServiceProxy.shared.postData("\(Apis.KServerUrl)\(url)", params: param, showIndicator: false, completion: { (jsonResults) in
            
            var appResponse = Int()
            
            appResponse = jsonResults["app_response"] as? Int ?? 0
            
            if appResponse == 200 {
                self.SubCategoryViewAllTopModelAry.removeAll()
                
                if let dictBanAry = jsonResults["categories_with_images"] as? NSArray
                {
                    if dictBanAry.count > 0
                    {
                        for i in 0..<dictBanAry.count
                        {
                            if let bnrDict = dictBanAry[i] as? NSDictionary {
                                let SubCategoryViewAllTopModelObj = SubCategoryViewAllTopModel()
                                SubCategoryViewAllTopModelObj.getTopBanner(dict: bnrDict)
                                self.SubCategoryViewAllTopModelAry.append(SubCategoryViewAllTopModelObj)
                            }
                            
                        }
                    }
                    completionHandler(true)
                    return;
                }
                
                if let dictBanAry = jsonResults["categories_with_images_ipad"] as? NSArray {
                    if dictBanAry.count > 0 {
                        for i in 0..<dictBanAry.count {
                            if let bnrDict = dictBanAry[i] as? NSDictionary {
                                let SubCategoryViewAllTopModelObj = SubCategoryViewAllTopModel()
                                SubCategoryViewAllTopModelObj.getTopBanner(dict: bnrDict)
                                self.SubCategoryViewAllTopModelAry.append(SubCategoryViewAllTopModelObj)
                                
                            }
                        }
                    }
                }
                completionHandler(true)
            } else {
                completionHandler(false)
            }
            Proxy.shared.hideActivityIndicator()
        })
    }
    
    //MARK:--> VIDEO LIKE
    func videoLikeApi(_ completion:@escaping() -> Void) {
        
        let param = [
            "udid"      :   "\(Proxy.shared.userId())",
            "video_id"  :   "\(String(describing: str_VideoId!))"
            ] as [String:Any]
        
        WebServiceProxy.shared.postData("\(Apis.KServerUrl)\(Apis.KPostLike)", params: param, showIndicator: true, completion: { (JSON) in
            Proxy.shared.displayStatusCodeAlert(JSON["message"] as? String ?? "")
            self.likeState = JSON["video_liked"] as? Int ?? 0
            self.setLikeButtonStatus(status: self.likeState)
            self.btnLikedRef.setTitle("  \(JSON["totallikes"] as? Int ?? 0)", for: .normal)
            Proxy.shared.hideActivityIndicator()
            completion()
        })
    }
    
    //MARK:--> VIDEO LIKE
    func videoDislikeApi(_ completion:@escaping() -> Void) {
        
        let param = [
            "udid"      :   "\(Proxy.shared.userId())",
            "video_id"  :   "\(String(describing: str_VideoId!))"
            ] as [String:Any]
        
        WebServiceProxy.shared.postData("\(Apis.KServerUrl)\(Apis.KDeleteVideolike)", params: param, showIndicator: true, completion: { (JSON) in
            self.likeState = JSON["video_liked"] as? Int ?? 0
            self.setLikeButtonStatus(status: self.likeState)
            self.btnLikedRef.setTitle("  \(JSON["totallikes"] as? Int ?? 0)", for: .normal)
            Proxy.shared.hideActivityIndicator()
            completion()
        })
    }
    
    func setLikeButtonStatus(status:Int) {
        if status == 0 {
            let image = UIImage(named: "like")?.withRenderingMode(.alwaysTemplate)
            self.img_Like.image = image
            self.img_Like.tintColor = .gray
        } else {
            let image = UIImage(named: "like")?.withRenderingMode(.alwaysTemplate)
            self.img_Like.image = image
            self.img_Like.tintColor = .blue
        }
    }
    
    //MARK:--> ADD TO MY CAMP API
    func addToMyCampApi(_ completion:@escaping() -> Void) {
        let param = [
            "udid"      :   "\(Proxy.shared.userId())",
            "video_id"  :   "\(String(describing: str_VideoId!))"
            ] as [String:Any]
        
        WebServiceProxy.shared.postData("\(Apis.KServerUrl)\(Apis.KAddToMyCamp)", params: param, showIndicator: true, completion: { (JSON) in
            Proxy.shared.hideActivityIndicator()
            Proxy.shared.displayStatusCodeAlert(JSON["message"] as? String ?? "")
            completion()
        })
    }
    
}


extension HCOpenVideoIphoneVC: UITableViewDataSource, UITableViewDelegate,SelectedVideo {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections: Int = 0
        if self.SubCategoryViewAllTopModelAry.count > 0 {
            tableView.separatorStyle = .none
            numOfSections            = 1
            tableView.backgroundView = nil
            activityIndicator.stopAnimating()
        } else {
            // Set activity indicator
            activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
            activityIndicator.color = UIColor.darkGray
            activityIndicator.center = tableView.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.startAnimating()
            tableView.backgroundView  = activityIndicator
            tableView.separatorStyle  = .none
        }
        return numOfSections
    }
    
    //MARK:--> TABLE VIEW DELEGATE
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.SubCategoryViewAllTopModelAry.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblVw.dequeueReusableCell(withIdentifier: "SubCategoryDetailTVC", for: indexPath) as! SubCategoryDetailTVC
        
        if self.SubCategoryViewAllTopModelAry.count != 0 {
            let SubVideoCategoryModelAryObj = self.SubCategoryViewAllTopModelAry[indexPath.row]
            cell.lblheader.text = SubVideoCategoryModelAryObj.categoryTitle
            if SubVideoCategoryModelAryObj.categoryTitle == "MORE EPISODES" {
                cell.btnViewAll.isHidden = true
            }
            
        }
        if self.SubCategoryViewAllTopModelAry[indexPath.row].VideoModelAry.count != 0 {
            let SubCategoryViewAllTopModelAryObj =  self.SubCategoryViewAllTopModelAry[indexPath.row]
            cell.VideoModelAry = SubCategoryViewAllTopModelAryObj.VideoModelAry
            self.arr_AllVideos = SubCategoryViewAllTopModelAryObj.VideoModelAry
        }
        
        //        cell.btnLeftAction.tag = indexPath.row
        cell.colVw.tag = indexPath.row
        //        cell.btnLeftAction.addTarget(self, action: #selector(leftSlideAction(_:)), for: .touchUpInside)
        //
        //        cell.btnRightAction.tag = indexPath.row
        //        cell.btnRightAction.addTarget(self, action: #selector(rightSlideAction(_:)), for: .touchUpInside)
        //
        //        cell.btnViewAll.tag = indexPath.row
        //        cell.btnViewAll.addTarget(self, action: #selector(btnViewAllAction), for: .touchUpInside)
        cell.colVw.reloadData()
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 220
    }
    
    
    //MARK:--> PROTOCOAL FUNCTION
    func didSelected(selectedVideoId: String, videoUrl: String,videoindex: Int,catindex: Int)
    {
        let indexpath = catindex
        VideoIndexx = videoindex
        let SubCategoryViewAllTopModelAryObj =  self.SubCategoryViewAllTopModelAry[indexpath ]
        //  cell.VideoModelAry = SubCategoryViewAllTopModelAryObj.VideoModelAry
        self.arr_AllVideos = SubCategoryViewAllTopModelAryObj.VideoModelAry
        
        self.str_VideoId = selectedVideoId
        let videoURL = URL(string: "\(Apis.KVideoURl)\(videoUrl)")
        str_VideoUrl = videoURL?.absoluteString
        
        self.playVideo(UIButton())
        //      getCategoryDetailData()
    }
//    {
//        self.str_VideoId = selectedVideoId
//        let videoURL = URL(string: "\(Apis.KVideoURl)\(videoUrl)")
//        str_VideoUrl = videoURL?.absoluteString
//        let indexpath = catindex
//        let SubCategoryViewAllTopModelAryObj =  self.SubCategoryViewAllTopModelAry[indexpath ]
//        self.arr_AllVideos = SubCategoryViewAllTopModelAryObj.VideoModelAry
//
//        self.playVideo(UIButton())
//        //        getCategoryDetailData()
//    }
    
}
