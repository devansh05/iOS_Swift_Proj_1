//
//  HCShopifyHomeVC.swift
//   
//
//    23/05/19.
//  Copyright © 2019  . All rights reserved.
//

import UIKit
import SwiftyJSON

class HCShopifyBannerCell: UICollectionViewCell {
    @IBOutlet weak var img_Banner: UIImageView!
    
}

class HCShopifyProductCell: UICollectionViewCell {
    @IBOutlet weak var img_Product: UIImageView!
    @IBOutlet weak var lbl_Name: UILabel!
    @IBOutlet weak var lbl_Price: UILabel!
    
}

class HCShopifyHomeVC: UIViewController, SelectMenuOption ,SelectAviatorImage,TopHeaderViewDelegate {
    
    @IBOutlet weak var view_HeaderView: HCHeaderView!
    @IBOutlet weak var targetVw: UIView!
    @IBOutlet weak var coll_Banner: UICollectionView!
    @IBOutlet weak var coll_Collections: UICollectionView!
    @IBOutlet weak var coll_Products: UICollectionView!
    @IBOutlet weak var lbl_Product: UILabel!
    @IBOutlet weak var btn_ShopNow: UIButton!
    @IBOutlet weak var collProduct_HeightConstraints: NSLayoutConstraint!
    var activityIndicator: UIActivityIndicatorView!
    var viewController : MenuDrawerController?
    var arr_CollectionImages:[JSON] = [ ]
    var arr_BannerImages:[JSON] = [ ]
    var arr_Products:[JSON] = [ ]
    
    //MARK:- Select Options
    func selectOptionByName(name: String!) {
        switch name {
        case "live":
            //            Proxy.shared.pushToNextVC(identifier: "CampDetailVC", isAnimate: true, currentViewController: self)
            break
        case "series":
            Proxy.shared.pushToNextVC(identifier: "WebSeriesVC", isAnimate: true, currentViewController: self)
            break
        case "360":
            if Proxy.shared.authNil() == "" {
                Proxy.shared.pushToNextVC(identifier: "SignUpVC", isAnimate: true, currentViewController: self)
                return
            }
            let vc = KAppDelegate.storyBoradVal.instantiateViewController(withIdentifier: "HCStaticLinkVC") as! HCStaticLinkVC
            vc.str_URL = Apis.K360Camp
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case "campFire":
            Proxy.shared.pushToNextVC(identifier: "CampfireVC", isAnimate: true, currentViewController: self)
            break
        case "store": 
            break
        case "profilePic":
            Proxy.shared.presentToVC(identifier: "SelectColorVC", isAnimate: false, currentViewController: self)
            break
        case "Options":
            if targetVw.isHidden == true {
                targetVw.isHidden = false
            }else{
                targetVw.isHidden = true
            }
            break
        case "SignIn":
            Proxy.shared.pushToNextVC(identifier: "SignInVC", isAnimate: true, currentViewController: self)
            break
        case "getAccess":
            Proxy.shared.pushToNextVC(identifier: "SignUpVC", isAnimate: true, currentViewController: self)
            break
        default:
            break
        }
    }
    
    //MARK:--> PROTOCOL FUNCTIONS
    func didSelected(index: Int) {
        if index == 0 {
            targetVw.isHidden = true
        } else if index == 1 {
            let auth = Proxy.shared.authNil()
            if auth != ""{
                Proxy.shared.pushToNextVC(identifier: "ProfileVC", isAnimate: true, currentViewController: self)
            } else {
                Proxy.shared.presentAlert(withTitle: "", message: "\(AlertValue.login)", currentViewController: self)
            }
        }else if index == 2 {
            //            Proxy.shared.pushToNextVC(identifier: "CamperStaffVC", isAnimate: true, currentViewController: self)
            let nav = StoryboardChnage.mainStoryboard.instantiateViewController(withIdentifier: "AboutUsVC") as! AboutUsVC
            nav.fromCont = "CampStaff"
            self.navigationController?.pushViewController(nav, animated: true)
        }
        else if index == 3 {
            let nav = StoryboardChnage.mainStoryboard.instantiateViewController(withIdentifier: "AboutUsVC") as! AboutUsVC
            nav.fromCont = "Community"
            self.navigationController?.pushViewController(nav, animated: true)
        } else if index == 4 {
            let auth = Proxy.shared.authNil()
            if auth != ""{
                Proxy.shared.pushToNextVC(identifier: "InviteAFriendVC", isAnimate: true, currentViewController: self)
            } else {
                Proxy.shared.pushToNextVC(identifier: "SignUpVC", isAnimate: true, currentViewController: self)
            }
        } else if index == 5 {
            let vc = KAppDelegate.storyBoradVal.instantiateViewController(withIdentifier: "HCStaticLinkVC") as! HCStaticLinkVC
            vc.str_URL = Apis.KBlog
            self.navigationController?.pushViewController(vc, animated: true)
        } else if index == 6 {
            let nav = StoryboardChnage.mainStoryboard.instantiateViewController(withIdentifier: "AboutUsVC") as! AboutUsVC
            nav.fromCont = "FAQs"
            self.navigationController?.pushViewController(nav, animated: true)
        } else if index == 7 {
            let nav = StoryboardChnage.mainStoryboard.instantiateViewController(withIdentifier: "AboutUsVC") as! AboutUsVC
            nav.fromCont = "ContactUs"
            self.navigationController?.pushViewController(nav, animated: true)
        } else if index == 8 {
            Proxy.shared.pushToNextVC(identifier: "JoinOurTeamVC", isAnimate: true, currentViewController: self)
        } else if index == 9 {
            // Register Camp
        } else if index == 10 {
            let nav = StoryboardChnage.mainStoryboard.instantiateViewController(withIdentifier: "AboutUsVC") as! AboutUsVC
            nav.fromCont = "Terms & Conditions"
            self.navigationController?.pushViewController(nav, animated: true)
        } else if index == 11 {
            let nav = StoryboardChnage.mainStoryboard.instantiateViewController(withIdentifier: "AboutUsVC") as! AboutUsVC
            nav.fromCont = "Privacy Policies"
            self.navigationController?.pushViewController(nav, animated: true)
        } else if index == 12 {
            let nav = StoryboardChnage.mainStoryboard.instantiateViewController(withIdentifier: "AboutUsVC") as! AboutUsVC
            nav.fromCont = "Disclaimer"
            self.navigationController?.pushViewController(nav, animated: true)
        } else  if index == 101 {
            Proxy.shared.pushToNextVC(identifier: "CoinCanteenVC", isAnimate: true, currentViewController: self)
        } else {
            Proxy.shared.rootWithoutDrawer("TabbarViewController")
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.reloadData()
        
        if  UIDevice.current.userInterfaceIdiom == .pad {
            view_HeaderView.btn_Store.setTitleColor(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), for: .normal)
            for view in view_HeaderView.subviews {
                if let lbl = view.viewWithTag(104) as? UILabel { lbl.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)  }
            }
            
            self.coll_Products.addObserver(self, forKeyPath: "contentSize", options: [], context: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            
            // Called Delegates for Avatars and Top Header
            SelectAviatorImageObj = self
            headerDelegate = self
            
            // Get Profile Image
            let slectedAviator = Proxy.shared.selectedAviatorImage()
            if slectedAviator != "" && !slectedAviator.contains("false") {
                view_HeaderView.imgVwAviator.sd_setImage(with: URL.init(string: "\(slectedAviator)"),placeholderImage: #imageLiteral(resourceName: "defaultImg"), completed: nil)
            }
            
            targetVw.isHidden = true
            viewController = (StoryboardChnage.mainStoryboard.instantiateViewController(withIdentifier: "MenuDrawerController") as! MenuDrawerController)
            viewController?.delegate = self
            
            targetVw.addSubview(viewController!.view)
            viewController?.tblVw.delegate = viewController
            viewController?.tblVw.dataSource = viewController
            
            if isMovingToParent{ } else {
                print("poppp")
                // Reset UI
                DispatchQueue.main.async {
                    self.coll_Collections.reloadData()
                    self.coll_Banner.reloadData()
                }
            }
        }
    }
    

    @IBAction func btnBackAction(_ sender: Any) {
        Proxy.shared.popToBackVC(isAnimate: true, currentViewController: self)
    }
    
    @IBAction func shopNow(_ sender: Any) {
        // Open that Collection info
        let vc = KAppDelegate.storyBoradVal.instantiateViewController(withIdentifier: "HCProductsListVC") as! HCProductsListVC
        vc.str_CollectionName = "Babies And Toddlers"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // Function to get currect Orientation
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        
        // Reset UI
        DispatchQueue.main.async {
            self.coll_Collections.reloadData()
            self.coll_Banner.reloadData()
            self.coll_Products.reloadData()
        }
        self.view.layoutIfNeeded()
    }
}

//MARK:- JSON
extension HCShopifyHomeVC {
    
    func get_Products(_ completion:@escaping() -> Void) {
        
        WebServiceProxy.shared.getData("\(Apis.KServerUrl)" + "allcollection/89827639385", showIndicator: true, completion: { (jsonData) in
            
            //            var appResponse = Int()
            //            appResponse = jsonData["app_response"] as? Int ?? 0
            
            //            if appResponse == 200 {
            
            let result = self.convertToDictionary(text: jsonData["products"] as! String) // ["name": "James"]
            guard let jsonResult = JSON.init(result).dictionary else {
                return
            }
            
            //            if let product = jsonResult["products"]?.dictionary {
            if let arr_Products = jsonResult["products"]?.arrayValue {
                
                if arr_Products.count > 0 {
                    for i in 0..<arr_Products.count {
                        if let product = arr_Products[i].dictionary {
                            self.arr_Products.append(JSON.init(product))
                        }
                    }
                    DispatchQueue.main.async {
                        self.coll_Products.reloadData()
                    }
                }
            }
            //            }
        })
    }
    
    func get_Collections(_ completion:@escaping() -> Void) {
        let param = [
            :] as [String:AnyObject]
        
        WebServiceProxy.shared.postData("\(Apis.KServerUrl)\(Apis.KStore_Settings)", params: param, showIndicator: true, completion: { (jsonData) in
            
            //            var appResponse = Int()
            //            appResponse = jsonData["app_response"] as? Int ?? 0
            
            //            if appResponse == 200 {
            guard let jsonResult = JSON.init(jsonData).dictionary else {
                return
            }
            
            self.arr_CollectionImages.removeAll()
            
            if let arr_coll = jsonResult["data"]?.arrayValue {
                if arr_coll.count > 0 {
                    for i in 0..<arr_coll.count {
                        if let collection = arr_coll[i].dictionary {
                            
                            var str_Shopify_section1 = ""
                            var str_Shopify_section2 = ""
                            var str_Shopify_section3 = ""
                            if collection["shopify_section1"]?.stringValue != "" {
                                str_Shopify_section1 = collection["shopify_section1"]!.stringValue
                            }
                            self.arr_CollectionImages.append(JSON.init(str_Shopify_section1))
                            
                            if collection["shopify_section2"]?.stringValue != "" {
                                str_Shopify_section2 = collection["shopify_section2"]!.stringValue
                                
                            }
                            self.arr_CollectionImages.append(JSON.init(str_Shopify_section2))
                            
                            if collection["shopify_section3"]?.stringValue != "" {
                                str_Shopify_section3 = collection["shopify_section3"]!.stringValue
                                
                            }
                            self.arr_CollectionImages.append(JSON.init(str_Shopify_section3))
                            
                            if let arr_Banner = collection["shopify_top_banner"]?.arrayValue {
                                if arr_Banner.count > 0 {
                                    for i in 0..<arr_Banner.count {
                                        if let banners = arr_Banner[i].string {
                                            self.arr_BannerImages.append(JSON.init(banners))
                                        }
                                    }
                                    DispatchQueue.main.async {
                                        self.coll_Banner.reloadData()
                                    }
                                }
                            }
                            
                        }
                    }
                    DispatchQueue.main.async {
                        self.coll_Collections.reloadData()
                    }
                }
            }
            
            completion()
            //            }
            Proxy.shared.hideActivityIndicator()
        })
    }
    
}

//MARK:- UICollection Delegates and Data Sources
extension HCShopifyHomeVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        var numOfSections: Int = 1
        if collectionView == coll_Products {
            if self.arr_Products.count > 0 {
                numOfSections            = 1
                coll_Products.backgroundView = nil
                activityIndicator.stopAnimating()
            } else {
                // Set activity indicator
                activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
                activityIndicator.color = UIColor.darkGray
                activityIndicator.center = coll_Products.center
                activityIndicator.hidesWhenStopped = true
                activityIndicator.startAnimating()
                coll_Products.backgroundView  = activityIndicator
            }
        }
        return numOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == coll_Banner {
            return self.arr_BannerImages.count
        } else if collectionView == coll_Collections {
            return self.arr_CollectionImages.count
        } else {
            return self.arr_Products.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView != coll_Products {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! HCShopifyBannerCell
            if collectionView == coll_Banner {
                // Banner Images
                DispatchQueue.main.async {
                    cell.img_Banner.sd_setImage(with: URL.init(string: "\(Apis.KShopifyBanner)\(self.arr_BannerImages[indexPath.row].stringValue)"),placeholderImage: #imageLiteral(resourceName: "Group 12-1"), completed: nil)
                }
            } else {
                // Collection Images
                DispatchQueue.main.async {
                    cell.img_Banner.sd_setImage(with: URL.init(string: "\(Apis.KShopifyBanner)\(self.arr_CollectionImages[indexPath.row].stringValue)"),placeholderImage: #imageLiteral(resourceName: "Group 12-1"), completed: nil)
                }
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellProduct", for: indexPath) as! HCShopifyProductCell
            
            let image = self.arr_Products[indexPath.row]["product_Images"][0]["product_Image"].stringValue
            DispatchQueue.main.async {
                cell.img_Product.sd_setImage(with: URL.init(string: image),placeholderImage: #imageLiteral(resourceName: "Group 12-1"), completed: nil)
            }
            
            cell.lbl_Name.text = self.arr_Products[indexPath.row]["product_Name"].stringValue
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == coll_Collections {
            var collection = ""
            if indexPath.row == 0 {
                collection = "Clothing"
            } else if indexPath.row == 1 {
                collection = "Camp Gear"
            } else {
                collection = "Sports Equipment"
            }
            
            // Open that Collection info
            let vc = KAppDelegate.storyBoradVal.instantiateViewController(withIdentifier: "HCProductsListVC") as! HCProductsListVC
            vc.str_CollectionName = collection
            self.navigationController?.pushViewController(vc, animated: true)

        } else if collectionView == coll_Banner {
            // Open that Collection info
            let vc = KAppDelegate.storyBoradVal.instantiateViewController(withIdentifier: "HCProductsListVC") as! HCProductsListVC
            vc.str_CollectionName = "Clothing"
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            //If array is empty
            if self.arr_Products.count < 0 {
                return
            }
            // Open that product info
            let vc = KAppDelegate.storyBoradVal.instantiateViewController(withIdentifier: "HCProductDetailsVC") as! HCProductDetailsVC
            vc.product = Product.init(_id: self.arr_Products[indexPath.row]["product_Id"].stringValue, _title: self.arr_Products[indexPath.row]["product_Name"].stringValue, _desc: self.arr_Products[indexPath.row]["product_Description"].stringValue, _price: "\(self.arr_Products[indexPath.row]["product_Price"].numberValue)", _images: self.arr_Products[indexPath.row]["product_Images"].arrayValue,_quantity:1,_total_Price:"\(self.arr_Products[indexPath.row]["product_Price"].numberValue)",_variantId:self.arr_Products[indexPath.row]["variant_Id"].stringValue)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == coll_Banner {
            return CGSize.init(width: coll_Banner.bounds.width, height: coll_Banner.bounds.height)
        } else if collectionView == coll_Collections {
            return CGSize.init(width: coll_Collections.bounds.width/3-5, height: coll_Collections.bounds.height)
        } else {
            return CGSize.init(width: coll_Collections.bounds.width/5, height: 240)
        }
    }
}

//MARK:- User Defined Functions
extension HCShopifyHomeVC {
    
    //Called when avatar is selected
    func selectedImage(index: Int) { viewWillAppear(false) }
    
    func setBackToHome() { }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        // Content Size for Left Stuff Tableview
        if let obj = object as? UICollectionView {
            if obj == self.coll_Products && keyPath == "contentSize" {
                DispatchQueue.main.async {
                    if !(self.coll_Products.contentSize.height >= 70) {
                        self.collProduct_HeightConstraints.constant = 70
                    } else {
                        self.collProduct_HeightConstraints.constant = self.coll_Products.contentSize.height
                    }
                }
            }
        }
    }
    
    // Convert String to Dictionary
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}

//MARK:- Data
extension HCShopifyHomeVC {
    // Function to get Data
    func reloadData() {
        self.get_Collections {
            //            self.get_Products {  }
        }
        
        //Get Products
        self.reloadProducts(collectionName: "CAMP TRENDS", reload: true)
    }
    
    // Get Products from shopify
    func reloadProducts(collectionName:String,reload:Bool) {
        Proxy.shared.showActivityIndicator()
        Client.shared.fetchCollections(collectionTitle: collectionName) { collections in
            guard let jsonResult = JSON.init(collections).dictionary else {
                return
            }
            if jsonResult["All_Products"]!.arrayValue.count < 0 {
                return
            }
            self.arr_Products = jsonResult["All_Products"]!.arrayValue
            
            DispatchQueue.main.async {
                if !reload {
                    self.coll_Products.delegate=self
                    self.coll_Products.dataSource=self
                } else {
                    self.coll_Products.reloadData()
                }
            }
            sleep(1)
            Proxy.shared.hideActivityIndicator()
        }
    }
}
