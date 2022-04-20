//
//  HCCartScreenVC.swift
//   
//
//    29/05/19.
//  Copyright © 2019  . All rights reserved.
//

import UIKit
import MobileBuySDK

enum PaymentType {
    case applePay
    case webCheckout
}


class HCCartScreenVC: UIViewController, SelectMenuOption ,SelectAviatorImage,TopHeaderViewDelegate{
    
    private let newClient: Graph.Client = Graph.Client(shopDomain: Client.shopDomain, apiKey: Client.apiKey)
    @IBOutlet weak var view_HeaderView: HCHeaderView!
    @IBOutlet weak var targetVw: UIView!
    @IBOutlet weak var itemsTableView: UITableView!
    @IBOutlet weak var lbl_SubTotal: UILabel!
    
    var arr_Products:[Product] = []
    var viewController : MenuDrawerController?
    var plusPrice:(Double, Double) -> Double = (+)
    var minusPrice:(Double, Double) -> Double = (-)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            loadProducts()
            
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
    
    //Decrease Product Quantity value
    @objc func decreaseQuantity(_ sender: UIButton) {
        self.countQuantity(row: sender.tag, plus: false)
    }
    
    //Increase Product Quantity value
    @objc func increaseQuantity(_ sender: UIButton) {
        self.countQuantity(row: sender.tag, plus: true)
    }
    
    //MARK:- ButtonActions
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

//MARK:- User Defined Functions
extension HCCartScreenVC {
    
    // Get product
    func loadProducts() {
        guard let data = UserDefaults.standard.data(forKey: "Product") else {
            self.arr_Products = []
            return
        }
        do {
            self.arr_Products = try JSONDecoder().decode([Product].self, from: data)
            self.updateData()
            DispatchQueue.main.async {
                self.itemsTableView.reloadData()
            }
        } catch {
            print(error)
            self.arr_Products = []
        }
    }
    
    func countQuantity(row:Int,plus:Bool) {
        if self.arr_Products.count > 0 {
            var subTotal_Price:Double = 0
            //Get Cell
            //            _ = itemsTableView.dequeueReusableCell(withIdentifier: "Cell", for: IndexPath.init(row: row, section: 0)) as! HCCartScreenTVC
            for i in 0..<self.arr_Products.count {
                //Check if selected row is that
                var single_Product:Product!
                single_Product = self.arr_Products[i]
                if i == row {
                    var totalPrice:Double = 0
                    //Increase count of product quantity
                    if plus {
                        single_Product.quantity += 1
                        let alreadyPrice_Total = single_Product.total_Price
                        //Get Total price acc to quantity
                        totalPrice = plusPrice(Double(alreadyPrice_Total)!, Double(single_Product.price)!)
                        single_Product.total_Price = "\(totalPrice.string(maximumFractionDigits: 3))"
                    } else {
                        //Decrease count of product quantity
                        if single_Product.quantity >= 2 {
                            single_Product.quantity -= 1
                            //Get Total price acc to quantity
                            totalPrice = minusPrice(Double(single_Product.total_Price)!, Double(single_Product.price)!)
                            single_Product.total_Price = "\(totalPrice.string(maximumFractionDigits: 3))"
                        }
                    }
                    //Replace Array index
                    self.arr_Products.remove(at: row)
                    self.arr_Products.insert(single_Product, at: row)
                }
                
                subTotal_Price += Double(single_Product.total_Price)!
                
            }
            
            //Update Cart List in local storage
            do {
                UserDefaults.standard.removeObject(forKey: "Product")
                let product = try JSONEncoder().encode(self.arr_Products)
                UserDefaults.standard.set(product, forKey: "Product")
            } catch {
                print(error)
            }
            
            self.lbl_SubTotal.text! = "SubTotal " + "$" + "\(subTotal_Price.string(maximumFractionDigits: 3))" + "USD"
            DispatchQueue.main.async {
                self.itemsTableView.reloadData()
            }
        }
    }
    
    
    @objc func deleteCartProduct(sender:UIButton) {
        let index = sender.tag
        let indexPath = NSIndexPath.init(row: index, section: 0)
        if self.arr_Products.count > 0 {
            self.arr_Products.remove(at: indexPath.row)
            self.itemsTableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
            self.itemsTableView.reloadData()
            //Update Cart List in local storage
            do {
                UserDefaults.standard.removeObject(forKey: "Product")
                let product = try JSONEncoder().encode(self.arr_Products)
                UserDefaults.standard.set(product, forKey: "Product")
            } catch {
                print(error)
            }
            if self.arr_Products.count <= 0 {
                self.lbl_SubTotal.text! = "SubTotal " + "$" + "0" + "USD"
                UserDefaults.standard.removeObject(forKey: "Product")
            }
            UserDefaults.standard.synchronize()
            self.updateData()
        }
    }
    
    @IBAction func createCheckout(sender:UIButton) {
        self.createNewCheckOut()
        //        self.totalsController(didRequestPaymentWith: .webCheckout)
    }
    
    func createNewCheckOut()  { //-> Storefront.MutationQuery
        Proxy.shared.showActivityIndicator()
        let lineItems = self.arr_Products.map { item in
            Storefront.CheckoutLineItemInput.create(quantity: Int32(item.quantity), variantId: GraphQL.ID(rawValue: item.variantId)) //item.variant.id
        }
        
        let checkoutInput = Storefront.CheckoutCreateInput.create(
            lineItems: .value(lineItems),
            allowPartialAddresses: .value(true)
        )
        
        let mutation = Storefront.buildMutation { $0
            .checkoutCreate(input: checkoutInput) { $0
                .checkout { $0
                    .webUrl()
                    .fragmentForCheckout()
                }
                
                .checkoutUserErrors { $0
                    .field()
                    .message()
                }
            }
        }
        
        let task  = self.newClient.mutateGraphWith(mutation) { response, error in
            print(response?.checkoutCreate?.checkout?.webUrl as Any)
            Proxy.shared.hideActivityIndicator()
            let webController = KAppDelegate.storyBoradVal.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            webController.url = (response?.checkoutCreate?.checkout?.webUrl)!
            webController.accessToken = "AccountController.shared.accessToken"
//            let webController = WebViewController(url: (response?.checkoutCreate?.checkout?.webUrl)!, accessToken: "AccountController.shared.accessToken")
            webController.navigationItem.title = "Checkout"
            self.navigationController?.pushViewController(webController, animated: true)
        }
        task.resume()
        
    }
    
    func totalsController(didRequestPaymentWith type: PaymentType) {
        _ = self.arr_Products
        
        Client.shared.createCheckout(with: self.arr_Products) { checkout in
            guard checkout != nil else {
                //                let webController = WebViewController(url: checkout.webURL, accessToken: "AccountController.shared.accessToken")
                //        webController.navigationItem.title = "Checkout"
                //        self.navigationController?.pushViewController(webController, animated: true)
                print("Failed to create checkout.")
                return
            }
            
            //            let completeCreateCheckout: (CheckoutViewModel) -> Void = { checkout in
            //                switch type {
            //                case .webCheckout:
            //                    self.openSafariFor(checkout)
            //
            //                case .applePay:
            ////                    Client.shared.fetchShopName { shopName in
            //                        guard let shopName = shopName else {
            //                            print("Failed to fetch shop name.")
            //                            return
            //                        }
            //
            //                        self.authorizePaymentFor(shopName, in: checkout)
            //                    }
            //                }
            //            }
            
            /* ----------------------------------------
             ** Use "HALFOFF" discount code for a 50%
             ** discount in the graphql.myshopify.com
             ** store (the test shop).
             */
            /*         self.promptForCodes { (discountCode, giftCard) in
             var updatedCheckout = checkout
             
             let queue     = DispatchQueue.global(qos: .userInitiated)
             let group     = DispatchGroup()
             let semaphore = DispatchSemaphore(value: 1)
             
             if let discountCode = discountCode {
             group.enter()
             queue.async {
             semaphore.wait()
             
             print("Applying discount code: \(discountCode)")
             Client.shared.applyDiscount(discountCode, to: checkout.id) { checkout in
             if let checkout = checkout {
             updatedCheckout = checkout
             } else {
             print("Failed to apply discount to checkout")
             }
             semaphore.signal()
             group.leave()
             }
             }
             }
             
             if let giftCard = giftCard {
             group.enter()
             queue.async {
             semaphore.wait()
             
             print("Applying gift card: \(giftCard)")
             Client.shared.applyGiftCard(giftCard, to: checkout.id) { checkout in
             if let checkout = checkout {
             updatedCheckout = checkout
             } else {
             print("Failed to apply gift card to checkout")
             }
             semaphore.signal()
             group.leave()
             }
             }
             }
             
             group.notify(queue: .main) {
             if let accessToken = AccountController.shared.accessToken {
             
             print("Associating checkout with customer: \(accessToken)")
             Client.shared.updateCheckout(updatedCheckout.id, associatingCustomer: accessToken) { associatedCheckout in
             if let associatedCheckout = associatedCheckout {
             completeCreateCheckout(associatedCheckout)
             } else {
             print("Failed to associate checkout with customer.")
             completeCreateCheckout(updatedCheckout)
             }
             }
             
             } else {
             completeCreateCheckout(updatedCheckout)
             }
             }
             }
             */
        }
    }
    
    //    func openSafariFor(_ checkout: CheckoutViewModel) {
    //        let webController = WebViewController(url: checkout.webURL, accessToken: "AccountController.shared.accessToken")
    //        webController.navigationItem.title = "Checkout"
    //        self.navigationController?.pushViewController(webController, animated: true)
    //    }
    
    //Called when avatar is selected
    func selectedImage(index: Int) { viewWillAppear(false) }
    
    func setBackToHome() { }
    
    func updateData() {
        var sub_TotalPrice:Double = 0
        for i in 0..<self.arr_Products.count {
            //Check if selected row is that
            //            var single_Product:Product!
            //            single_Product = self.arr_Products[i]
            sub_TotalPrice += Double(self.arr_Products[i].total_Price)!
            self.lbl_SubTotal.text! = "SubTotal " + "$" + "\(sub_TotalPrice.string(maximumFractionDigits: 3))" + "USD"
        }
    }
    
}

extension HCCartScreenVC:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections: Int = 1
        var lbl_Empty:UILabel!
        if tableView == itemsTableView {
            if self.arr_Products.count > 0 {
                numOfSections            = 1
                tableView.backgroundView = nil
            } else {
                // Set activity indicator
                lbl_Empty = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: itemsTableView.bounds.width, height: itemsTableView.bounds.height))
                lbl_Empty.textColor = UIColor.darkGray
                lbl_Empty.center = itemsTableView.center
                lbl_Empty.text = "Cart Empty"
                lbl_Empty.textAlignment = .center
                itemsTableView.backgroundView  = lbl_Empty
            }
        }
        return numOfSections
    }
    
    // MARK - UITableView Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_Products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! HCCartScreenTVC
        
        if indexPath.row != 0 {
            cell.view_Heading.isHidden=true
        }
        cell.lbl_ProductTitle.text! = self.arr_Products[indexPath.row].title
        cell.lbl_Price.text! = "$" + self.arr_Products[indexPath.row].price + "USD"
        cell.lbl_TotalPrice.text! = "$" + self.arr_Products[indexPath.row].total_Price + "USD"
        
        cell.btn_QuantityValue.setTitle("\(self.arr_Products[indexPath.row].quantity)", for: .normal)
        
        cell.btn_Minus.tag = indexPath.row
        cell.btn_Minus.addTarget(self, action: #selector(decreaseQuantity(_:)), for: .touchUpInside)
        
        cell.btn_Plus.tag = indexPath.row
        cell.btn_Plus.addTarget(self, action: #selector(increaseQuantity(_:)), for: .touchUpInside)
        
        cell.btn_Remove.tag = indexPath.row
        cell.btn_Remove.addTarget(self, action: #selector(deleteCartProduct(sender:)), for: .touchUpInside)
        
        
        let image = self.arr_Products[indexPath.row].images[0]["product_Image"].stringValue
        DispatchQueue.main.async {
            cell.img_Product.sd_setImage(with: URL.init(string: image),placeholderImage: #imageLiteral(resourceName: "Group 12-1"), completed: nil)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
}

extension Double {
    func string(maximumFractionDigits: Int = 2) -> String {
        let s = String(format: "%.\(maximumFractionDigits)f", self)
        var offset = -maximumFractionDigits - 1
        for i in stride(from: 0, to: -maximumFractionDigits, by: -1) {
            if s[s.index(s.endIndex, offsetBy: i - 1)] != "0" {
                offset = i
                break
            }
        }
        return String(s[..<s.index(s.endIndex, offsetBy: offset)])
    }
}
