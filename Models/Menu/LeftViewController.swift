//
//  LeftViewController.swift
//  LGSideMenuControllerDemo

import UIKit

class MIMenuCell: UITableViewCell {
    
    @IBOutlet weak var images: UIImageView!
    @IBOutlet weak var lbl_Title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

class LeftViewController: UIViewController {
    
    @IBOutlet weak var tbl_Menu: UITableView!
    
    @IBOutlet weak var heightConstraints: NSLayoutConstraint!
    @IBOutlet weak var img_User: UIImageView!
    @IBOutlet weak var lbl_Name: UILabel!
    @IBOutlet weak var lbl_Email: UILabel!
    
    @IBOutlet weak var SignInBtn: UIButton!
    @IBOutlet weak var view_Back: UIView!
    
    @IBOutlet weak var viewHeightConstraints: NSLayoutConstraint!
    
    
    let menuArray = ["HOME","LIVE", "WEB SERISE", "360˚", "STORE", "CAMPFIRE", "CAMP STAFF", "COMMUNITY", "FAQ", "CONTACT US", "TERMS AND CONDITIONS", "PRIVACY POLICY", "INVITE FRIENDS", "JOIN CAMP"]
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        tbl_Menu.separatorStyle = .singleLine
        self.tbl_Menu.tableFooterView = UIView()
        
        //        let tap = UITapGestureRecognizer.init(target: self, action: #selector(goToProfileScreen(gesture:)))
        //        view_Back.addGestureRecognizer(tap)
        
        
        let auth = Proxy.shared.authNil()
        if auth != "" {
            //            getAccessButton.isHidden = true
            //            btn_HeightConstaint.constant = 0
            SignInBtn.isHidden = true
            let userName = Proxy.shared.selectedUserName()
            let user_Email = Proxy.shared.selectedUserEmail()
            
            if KAppDelegate.UserModelObj.userName == "" {
                lbl_Name.text! = userName
            } else {
                lbl_Name.text! = KAppDelegate.UserModelObj.userName
            }
            
            if KAppDelegate.UserModelObj.userEmail == "" {
                lbl_Email.text! = user_Email
            } else {
                lbl_Email.text! = KAppDelegate.UserModelObj.userEmail
            }
            
            let slectedAviator = Proxy.shared.selectedAviatorImage()
            if slectedAviator != "" && !slectedAviator.contains("false") {
                img_User.sd_setImage(with: URL.init(string: "\(slectedAviator)"),placeholderImage: #imageLiteral(resourceName: "Group 12-1"), completed: nil)
            }
        } else {
            //  btn_HeightConstaint.constant = 30
            //  getAccessButton.isHidden = false
            self.lbl_Name.text = ""
            self.lbl_Email.text = ""
            viewHeightConstraints.constant  = 120
            SignInBtn.layer.cornerRadius = 5
            SignInBtn.clipsToBounds = true
            img_User.sd_setImage(with: URL.init(string: ""),placeholderImage: nil, completed: nil)
        }
        
        
    }
    
    @IBAction func SignInBtnAction(_ sender: Any) {
        let nav = StoryboardChnage.iPhoneStoryboard.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
        // nav.comeFromSideMenu = true
        self.navigationController?.pushViewController(nav, animated: true)
        
    }
    @IBAction func ProfileBtnAction(_ sender: Any) {
        
        let auth = Proxy.shared.authNil()
        if auth != ""{
            let nav = StoryboardChnage.iPhoneStoryboard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            //            nav.comeFromSideMenu = true
            self.navigationController?.pushViewController(nav, animated: true)
            //comeFromSideMenu
            // Proxy.shared.pushToNextVC(identifier: "ProfileVC", isAnimate: true, currentViewController: self)
        } else {
            Proxy.shared.presentAlert(withTitle: "", message: "\(AlertValue.login)", currentViewController: self)
        }
        let mainViewController = sideMenuController!
        mainViewController.hideLeftView(animated: true, completionHandler: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //        lbl_Name.text = MILocalStorage.shared.username
        //        lbl_Email.text = MILocalStorage.shared.email
        //
        //        img_User.sd_setImage(with: URL(string: "\(MILocalStorage.shared.userImage)"), placeholderImage: UIImage(named: "icon_Coll1"))
        
    }
    
    //    @objc func goToProfileScreen(gesture:UITapGestureRecognizer) {
    //        goToViewController(identifier:"MIProfileVC")
    //    }
    //
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func crossAction(_ sender: UIButton) {
        
        sideMenuController?.hideLeftView(animated: true, completionHandler: {  })
    }
    
    func goToViewController(identifier:String) {
        let mainViewController = sideMenuController!
        //mainViewController.hideLeftView(animated: true, completionHandler: nil)
        
        let vc = UIStoryboard.init(name: "iPhone", bundle: nil).instantiateViewController(withIdentifier: identifier)
        navigationController?.pushViewController(vc, animated: true)
        
    }
}

//MARK:- UITableView Delegates and Data Sources

extension LeftViewController:UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MIMenuCell
        
        cell.selectionStyle = .default
        
        let view = UIView()
        view.backgroundColor = .white
        cell.selectedBackgroundView = view
        
        //        cell.images.image = UIImage.init(named: self.arr_Image[indexPath.row] as! String)
        cell.lbl_Title.text = self.menuArray[indexPath.row]
        
        //        if cell.isSelected {
        //            cell.images.image = cell.images.image!.withRenderingMode(.alwaysTemplate)
        //            cell.images.tintColor = UIColor.white
        //        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainViewController = sideMenuController!
        print("DidSelect:",indexPath.row)
        
        if let cell = tableView.cellForRow(at: indexPath) as? MIMenuCell   {
            //            cell.images.image = cell.images.image!.withRenderingMode(.alwaysTemplate)
            //            cell.images.tintColor = .blue
            cell.lbl_Title.textColor = .black
            cell.contentView.backgroundColor = .lightGray
        }
        
        //        if indexPath.row == 0 {
        //            targetVw.isHidden = true
        //        }
        
        
        
        //varinder8
        if indexPath.row == 0 {
            //Home
            NotificationCenter.default.post(name: NSNotification.Name("GOTO_HomePage"), object: nil)
        }else   if indexPath.row == 1 {
            //mainViewController.hideLeftView(animated: true, completionHandler: nil)
            //live
        }else   if indexPath.row == 2 {
            
            //Web Serise
            Proxy.shared.pushToNextVC(identifier: "WebSeriesVC", isAnimate: true, currentViewController: self)
        }else   if indexPath.row == 3 {
            
            //360
            let nav = StoryboardChnage.iPhoneStoryboard.instantiateViewController(withIdentifier: "AboutUsVC") as! AboutUsVC
            nav.fromCont = "360"
            nav.comeFromSideMenu = true
            nav.comeFromAboutUs = true
            self.navigationController?.pushViewController(nav, animated: true)
        }else   if indexPath.row == 4 {
            //mainViewController.hideLeftView(animated: true, completionHandler: nil)
            //store
        }else   if indexPath.row == 5 {
            
            //camp fire
            Proxy.shared.pushToNextVC(identifier: "CampfireVC", isAnimate: true, currentViewController: self)
        }else   if indexPath.row == 6 {
            
            //camp staff
            let nav = StoryboardChnage.iPhoneStoryboard.instantiateViewController(withIdentifier: "AboutUsVC") as! AboutUsVC
            nav.comeFromSideMenu = true
            nav.fromCont = "CampStaff"
            nav.comeFromAboutUs = true
            self.navigationController?.pushViewController(nav, animated: true)
        }else   if indexPath.row == 7 {
            
            //community
            let nav = StoryboardChnage.iPhoneStoryboard.instantiateViewController(withIdentifier: "AboutUsVC") as! AboutUsVC
            nav.fromCont = "Community"
            nav.comeFromSideMenu = true
            nav.comeFromAboutUs = true
            self.navigationController?.pushViewController(nav, animated: true)
        }else   if indexPath.row == 8 {
            
            //faq
            let nav = StoryboardChnage.iPhoneStoryboard.instantiateViewController(withIdentifier: "AboutUsVC") as! AboutUsVC
            nav.fromCont = "FAQs"
            nav.comeFromSideMenu = true
            nav.comeFromAboutUs = true
            self.navigationController?.pushViewController(nav, animated: true)
        }else   if indexPath.row == 9 {
            
            //contact us
            let nav = StoryboardChnage.iPhoneStoryboard.instantiateViewController(withIdentifier: "AboutUsVC") as! AboutUsVC
            nav.comeFromSideMenu = true
            nav.fromCont = "ContactUs"
            nav.comeFromAboutUs = true
            self.navigationController?.pushViewController(nav, animated: true)
        }else   if indexPath.row == 10 {
            
            //terms and conditions
            let nav = StoryboardChnage.iPhoneStoryboard.instantiateViewController(withIdentifier: "AboutUsVC") as! AboutUsVC
            nav.comeFromSideMenu = true
            nav.fromCont = "Terms & Conditions"
            nav.comeFromAboutUs = true
            self.navigationController?.pushViewController(nav, animated: true)
        }else   if indexPath.row == 11 {
            
            //privacy policy
            let nav = StoryboardChnage.iPhoneStoryboard.instantiateViewController(withIdentifier: "AboutUsVC") as! AboutUsVC
            nav.comeFromSideMenu = true
            nav.fromCont = "Privacy Policies"
            nav.comeFromAboutUs = true
            self.navigationController?.pushViewController(nav, animated: true)
        } else   if indexPath.row == 12 {
            
            //Invite Freinds
            Proxy.shared.pushToNextVC(identifier: "InviteAFriendVC", isAnimate: true, currentViewController: self)
        }else   if indexPath.row == 13 {
            
            //Join Camp
            Proxy.shared.pushToNextVC(identifier: "JoinOurTeamVC", isAnimate: true, currentViewController: self)
        }
        
        mainViewController.hideLeftView(animated: true, completionHandler: nil)
        
        
        //        if indexPath.row == 0 {
        //            goToViewController(identifier:"MIExploreTC")
        //        } else if indexPath.row == 1 {
        //            goToViewController(identifier:"MIAddCollFolderVC")
        //        } else if indexPath.row == 2 {
        //            goToViewController(identifier:"MIAddFileVC")
        //        } else if indexPath.row == 3 {
        //            goToViewController(identifier:"MIMyCollectionVC")
        //        } else if indexPath.row == 4 {
        //            goToViewController(identifier:"MISharedCollectionVC")
        //        } else if indexPath.row == 5 {
        //            goToViewController(identifier:"CampfireVC")
        //        }else if indexPath.row == 6 {
        //
        //            let mainViewController = sideMenuController!
        //
        //            //                        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MIDownloadsVC") as! MIDownloadsVC
        //            //                        vc.screen_Type = "Downloads"
        //            //                        navigationController?.pushViewController(vc, animated: true)
        //            //                        //mainViewController.hideLeftView(animated: true, completionHandler: nil)
        //
        //        }  else {
        //            //mainViewController.hideLeftView(animated: true, completionHandler: nil)
        //        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("Deselect:",indexPath.row)
        
        if let cell = tableView.cellForRow(at: indexPath) as? MIMenuCell  {
            //            cell.images.image = cell.images.image!.withRenderingMode(.alwaysTemplate)
            //            cell.images.tintColor = .gray
            cell.lbl_Title.textColor = .black
            cell.contentView.backgroundColor = UIColor.clear
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
}
