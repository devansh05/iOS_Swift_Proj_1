//
//  HCProductsListVC.swift
//   
//
//    28/05/19.
//  Copyright © 2019  . All rights reserved.
//

import UIKit
import SwiftyJSON
import DropDown

class HCProductsListVC: UIViewController , SelectMenuOption ,SelectAviatorImage,TopHeaderViewDelegate,UITextFieldDelegate{
    
    @IBOutlet weak var view_HeaderView: HCHeaderView!
    @IBOutlet weak var targetVw: UIView!
    @IBOutlet weak var lbl_CollectionTitle: UILabel!
    @IBOutlet weak var coll_Products: UICollectionView!
    @IBOutlet weak var tbl_LeftCollection: UITableView!
    @IBOutlet weak var collProduct_HeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var txt_Filter: UITextField!

    var viewController : MenuDrawerController?
    var arr_Products:[JSON] = []
    var arr_LeftCollections:[String:JSON] = [:]
    var str_CollectionName:String = ""
    
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
        case "store": Proxy.shared.pushToNextVC(identifier: "HCShopifyHomeVC", isAnimate: true, currentViewController: self)
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
        }else if index == 10 {
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
        
        self.arr_LeftCollections = ["CAMP CLOTHING":["Summer 2019","Babies And Toddlers","Girls","Boys","Women","Men","Charity T-shirts"],"CAMP GEAR":["Camp Gear","Bed And Bath","Socks And Shoes"],"EQUIPMENT":["Sports Equipment","So Danca™ Dancewear and Dance Shoes"]]
        
        //Get Products
        self.reloadProducts(collectionName: str_CollectionName, reload: false)
        if str_CollectionName == "Clothing" {
            self.lbl_CollectionTitle.text = "SUMMER 2019".uppercased()
        tbl_LeftCollection.selectRow(at: NSIndexPath.init(row: 0, section: 0) as IndexPath, animated: true, scrollPosition: .none)
        } else if str_CollectionName == "Camp Gear" {
            self.lbl_CollectionTitle.text = str_CollectionName.uppercased()
            tbl_LeftCollection.selectRow(at: NSIndexPath.init(row: 0, section: 1) as IndexPath, animated: true, scrollPosition: .none)
        } else {
            self.lbl_CollectionTitle.text = str_CollectionName.uppercased()
            tbl_LeftCollection.selectRow(at: NSIndexPath.init(row: 0, section: 2) as IndexPath, animated: true, scrollPosition: .none)
        }

        if  UIDevice.current.userInterfaceIdiom == .pad {
            self.coll_Products.addObserver(self, forKeyPath: "contentSize", options: [], context: nil)
            self.tbl_LeftCollection.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        }

        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "dropdown"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        button.frame = CGRect(x: CGFloat(txt_Filter.frame.size.width - 25), y: CGFloat(5), width: CGFloat(17), height: CGFloat(17))
        txt_Filter.rightView = button
        txt_Filter.rightViewMode = .always
    }
    
    @IBAction func selectFilter(sender:UIButton) {
        self.implementDropDown()
    }
    
    //Present DropDown
    func implementDropDown() {
        let dropDown = DropDown()
        
        // The view to which the drop down will appear on
        dropDown.anchorView = txt_Filter // UIView or UIBarButtonItem

        // The list of items to display. Can be changed dynamically
        dropDown.dataSource = ["A to Z", "Z to A", "Price (High to Low)", "Price (Low to High)"]
        
        // Action triggered on selection
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.txt_Filter.text! = item
        }
        dropDown.direction = .bottom

        // Will set a custom width instead of the anchor view width
       dropDown.show()
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
        }
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        Proxy.shared.popToBackVC(isAnimate: true, currentViewController: self)
    }
}

//MARK:- UICollection Delegates and Data Sources
extension HCProductsListVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.arr_LeftCollections.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return addHeadersView(title: "CAMP CLOTHING")
        }  else if section == 1 {
            return addHeadersView(title: "CAMP GEAR")
        } else {
            return addHeadersView(title: "EQUIPMENT")
        }
    }
    
    func addHeadersView(title:String) -> UIView {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tbl_LeftCollection.frame.width, height: 60))
        
        let label = UILabel()
        label.frame = CGRect.init(x: 3, y: 5, width: headerView.frame.width+15, height: headerView.frame.height-10)
        label.text = title
        label.textAlignment = .left
        //        label.backgroundColor = UIColor(red:0.32, green:0.12, blue:0.52, alpha:1.0)
        label.font = UIFont.boldSystemFont(ofSize: 23) // my custom font
        label.textColor = UIColor(red:0.32, green:0.12, blue:0.52, alpha:1.0)
        headerView.addSubview(label)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.arr_LeftCollections["CAMP CLOTHING"]!.arrayValue.count
        } else if section == 1 {
            return self.arr_LeftCollections["CAMP GEAR"]!.arrayValue.count
        } else {
            return self.arr_LeftCollections["EQUIPMENT"]!.arrayValue.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = UIColor.groupTableViewBackground
        cell.textLabel?.textColor = .darkGray
        if indexPath.section == 0 {
            cell.textLabel?.text = self.arr_LeftCollections["CAMP CLOTHING"]![indexPath.row].stringValue
        } else  if indexPath.section == 1 {
            cell.textLabel?.text = self.arr_LeftCollections["CAMP GEAR"]![indexPath.row].stringValue
        } else {
            cell.textLabel?.text = self.arr_LeftCollections["EQUIPMENT"]![indexPath.row].stringValue
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let collectionName = tableView.cellForRow(at: indexPath)?.textLabel?.text!
        //Get Products
        self.lbl_CollectionTitle.text = collectionName!.uppercased()
        self.reloadProducts(collectionName: collectionName!, reload: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arr_Products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellProduct", for: indexPath) as! HCShopifyProductCell
        
        let image = self.arr_Products[indexPath.row]["product_Images"][0]["product_Image"].stringValue
        DispatchQueue.main.async {
            cell.img_Product.sd_setImage(with: URL.init(string: image),placeholderImage: #imageLiteral(resourceName: "Group 12-1"), completed: nil)
        }
        
        cell.lbl_Name.text = self.arr_Products[indexPath.row]["product_Name"].stringValue
        cell.lbl_Price.text! = "$" + "\(self.arr_Products[indexPath.row]["product_Price"].numberValue)"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //If array is empty
        if self.arr_Products.count < 0 {
            return
        }
        // Open that product info
        let vc = KAppDelegate.storyBoradVal.instantiateViewController(withIdentifier: "HCProductDetailsVC") as! HCProductDetailsVC
        vc.product = Product.init(_id: self.arr_Products[indexPath.row]["product_Id"].stringValue, _title: self.arr_Products[indexPath.row]["product_Name"].stringValue, _desc: self.arr_Products[indexPath.row]["product_Description"].stringValue, _price:"\(self.arr_Products[indexPath.row]["product_Price"].numberValue)", _images: self.arr_Products[indexPath.row]["product_Images"].arrayValue,_quantity:1,_total_Price:"\(self.arr_Products[indexPath.row]["product_Price"].numberValue)",_variantId:self.arr_Products[indexPath.row]["variant_Id"].stringValue)
        
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: coll_Products.bounds.width/5, height: 240)
    }
}

//MARK:- User Defined Functions
extension HCProductsListVC {
    
    //Called when avatar is selected
    func selectedImage(index: Int) { viewWillAppear(false) }
    
    func setBackToHome() { }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        // Content Size for Left Stuff Tableview
        if let obj = object as? UICollectionView {
            if obj == self.coll_Products && keyPath == "contentSize" {
                DispatchQueue.main.async {
                    self.collProduct_HeightConstraints.constant = self.coll_Products.contentSize.height
                }
            }
        }
    }
}

//MARK:- Delegates
extension HCProductsListVC {
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        return false
//    }
}

