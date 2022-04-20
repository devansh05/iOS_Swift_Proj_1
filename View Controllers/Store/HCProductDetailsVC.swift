//
//  HCProductDetailsVCViewController.swift
//   
//
//    29/05/19.
//  Copyright © 2019  . All rights reserved.
//

import UIKit
import SwiftyJSON
import DropDown

class HCProductDetailsTVC : UITableViewCell{
    @IBOutlet weak var productImageView: UIImageView!
}

class HCProductDetailsVC: UIViewController, SelectMenuOption ,SelectAviatorImage,TopHeaderViewDelegate{
    
    @IBOutlet weak var view_HeaderView: HCHeaderView!
    @IBOutlet weak var targetVw: UIView!
    @IBOutlet weak var tbl_Items: UITableView!
    @IBOutlet weak var addToCartButton: UIButton!
    @IBOutlet weak var img_Product: UIImageView!
    @IBOutlet weak var lbl_ProductName: UILabel!
    @IBOutlet weak var lbl_ProductPrice: UILabel!
    @IBOutlet weak var txt_ProductDesc: UITextView!
    @IBOutlet weak var txt_Sizes: UITextField!
    @IBOutlet weak var txt_Colors: UITextField!
    @IBOutlet weak var view_SizesWidth: NSLayoutConstraint!
    @IBOutlet weak var view_ColorsWidth: NSLayoutConstraint!
    
    var viewController : MenuDrawerController?
    var product:Product!
    var arr_CartProducts:[Product] = []
    
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
        self.addToCartButton.layer.cornerRadius = self.addToCartButton.frame.height/8
        self.addToCartButton.layer.borderWidth = 1.5
        self.addToCartButton.layer.borderColor = AppInfo.PlaceHolderPurplColor.cgColor
        // Update data
        self.updateProduct()
    }
    
    func updateProduct() {
        if product != nil {
            self.lbl_ProductName.text! = self.product.title
            self.lbl_ProductPrice.text! = "$" + self.product.price
            //            self.txt_ProductDesc.attributedText = self.product.desc.htmlToAttributedString
            
            DispatchQueue.main.async {
                self.img_Product.sd_setImage(with: URL.init(string: self.product.images[0]["product_Image"].stringValue),placeholderImage: #imageLiteral(resourceName: "Group 12-1"), completed: nil)
                self.tbl_Items.reloadData()
            }
        }
        
        makeTextfieldsResponsive()
    }
    
    @IBAction func selectSizes(sender:UIButton) {
        self.implementDropDown(view: txt_Sizes, arr_List: ["22", "34", "45"])
    }
    
    @IBAction func selectColors(sender:UIButton) {
        self.implementDropDown(view: txt_Colors, arr_List: ["BLACK", "WHITE", "DARK GRAY"])
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
    
    //MARK:- Button Actions
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addToCartButtonAction(_ sender: UIButton) {
        self.showToast(message: "Product is added to cart!", font: UIFont.systemFont(ofSize: 21))
//        UserDefaults.standard.removeObject(forKey: "Product")
        do {
            if getSavedProducts().count > 0 {
                self.arr_CartProducts = []
                self.arr_CartProducts = getSavedProducts()
            }
            self.arr_CartProducts.append(self.product)
            let product = try JSONEncoder().encode(self.arr_CartProducts)
            UserDefaults.standard.set(product, forKey: "Product")
        } catch {
            print(error)
        }
        sleep(2)
        Proxy.shared.pushToNextVC(identifier: "HCCartScreenVC", isAnimate: true, currentViewController: self)
    }
    
    
    // Get rest of the products
    func getSavedProducts() -> [Product] {
        guard let data = UserDefaults.standard.data(forKey: "Product") else {
            self.arr_CartProducts = []
            return []
        }
        do {
            self.arr_CartProducts = try JSONDecoder().decode([Product].self, from: data)
        } catch {
            print(error)
            self.arr_CartProducts = []
        }
        return self.arr_CartProducts
    }
    
}

//MARK:- TableView Delegates
extension HCProductDetailsVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.product.images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HCProductDetailsTVC", for: indexPath) as! HCProductDetailsTVC
        
        cell.productImageView.layer.borderColor = UIColor.black.cgColor
        cell.productImageView.layer.borderWidth = 1.5
        cell.productImageView.layer.masksToBounds = true
        cell.selectionStyle = .none
        
        let image = self.product.images[indexPath.row]["product_Image"].stringValue
        
        DispatchQueue.main.async {
            cell.productImageView.sd_setImage(with: URL.init(string: image),placeholderImage: #imageLiteral(resourceName: "Group 12-1"), completed: nil)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (tableView.frame.height/3)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedImage = (tableView.cellForRow(at: indexPath) as! HCProductDetailsTVC).productImageView.image
        self.img_Product.image = selectedImage
    }
}

//MARK:- Delegates
extension HCProductDetailsVC:UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
}

//MARK:- User Defined Function
extension HCProductDetailsVC  {
    
    //Called when avatar is selected
    func selectedImage(index: Int) { viewWillAppear(false) }
    
    func setBackToHome() { }
    
    func makeTextfieldsResponsive() {
        
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "dropdown"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        button.frame = CGRect(x: CGFloat(txt_Sizes.frame.size.width - 25), y: CGFloat(5), width: CGFloat(17), height: CGFloat(17))
        txt_Sizes.rightView = button
        txt_Sizes.rightViewMode = .always
        
        let button1 = UIButton(type: .custom)
        button1.setImage(UIImage(named: "dropdown"), for: .normal)
        button1.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        button1.frame = CGRect(x: CGFloat(txt_Colors.frame.size.width - 25), y: CGFloat(5), width: CGFloat(17), height: CGFloat(17))
        txt_Colors.rightView = button1
        txt_Colors.rightViewMode = .always
    }
    
    
    //Present DropDown
    func implementDropDown(view:UITextField,arr_List:Array<Any>) {
        let dropDown = DropDown()
        
        // The view to which the drop down will appear on
        dropDown.anchorView = view // UIView or UIBarButtonItem
        
        // The list of items to display. Can be changed dynamically
        dropDown.dataSource = arr_List as! [String]
        
        // Action triggered on selection
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            view.text! = item
        }
        dropDown.direction = .bottom
        
        // Will set a custom width instead of the anchor view width
        dropDown.show()
    }
    
}
