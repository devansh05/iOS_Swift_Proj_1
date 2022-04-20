//
//  SubscriptionDetailVIew.swift
//   
//
//  Created by   on 28/03/19.
//  Copyright © 2019  . All rights reserved.
//

import UIKit
import StoreKit

class ConstanTVC1: UITableViewCell {
    //MARK:--> IBOUTLETS
    @IBOutlet weak var lblTitle: UILabel!
}

class SubscriptionDetailVIew: UIViewController {
    
    @IBOutlet weak var col_Vw: UICollectionView!
    @IBOutlet weak var tbltwo: UITableView!
    @IBOutlet weak var tblOne: UITableView!
    @IBOutlet weak var btn_Logout: UIButton!

    var packDuration = ["1 MONTH", "3 MONTHS", "1 YEAR"]
    var packCost = ["$8.99", "$24.99", "$89.99"]
    var packBilling = ["Billed One Month", "Billed 3 Months", "Billed Annually"]
    var packMonthlyBilling = ["Billed One Month", "Billed Six Month", "Billed Annually"]
    var priceAmountAry = NSMutableArray()
    var demoText = ["Unlimited access to 100's camp activities","First 3 days free.","Chances to appear on Happy Camper Live.","Live and On Demand.","Explore camp in 360"]
    
    var demoTextTwo = ["Exclusive premiere of the Happy Camper Live original web series.","Special discounts in the camp store.","Watch from your laptop,iphone,or iPad","Earn coins to redeem in the canteen.","Cancel Anytime."]
    
    var options: [Subscription]?
    var index = 0
    
    var isFromManageSubscription = Bool()
    
    var subscrionObj = SubscriptionModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SKPaymentQueue.default().add(self)
        
        //CHECK SUBSCRIPTIONS PACKAGES
        SubscriptionService.shared.loadSubscriptionOptions()
        //        SubscriptionService.shared.delegate = self
        
        //PLAN PURCHASED
        options = SubscriptionService.shared.options
        
        self.tabBarController?.tabBar.isHidden = true
        
        
        if isFromManageSubscription
        {
            self.getSubscriptionDetail()
        }
        if kisSubscribed {
            self.btn_Logout.isHidden=true
            self.btn_Logout.isEnabled=false
        }
        
        self.title  = "MANAGE SUBSCRIPTION"
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func backBtn(_ sender : AnyObject)
    {
        if kisSubscribed
        {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}

extension SubscriptionDetailVIew:UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,PurchasedDidFinishDelegate,SKPaymentTransactionObserver
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.packDuration.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = col_Vw.dequeueReusableCell(withReuseIdentifier: "SelectSubscriptionCVC", for: indexPath) as! SelectSubscriptionCVC
        cell.lblDays.text        = packDuration[indexPath.item]
        cell.lblPrice.text       = packCost[indexPath.item]
        cell.btnSelect.tag       = indexPath.item
        
        cell.lblBillingType.text = "*" + packBilling[indexPath.item]

        
        if UIDevice.current.userInterfaceIdiom == .pad {
            if indexPath.row == self.packDuration.count-1 {
                cell.img_BestValue.isHidden=false
                cell.lbl_CutPrice.isHidden=false
            } else {
                cell.img_BestValue.isHidden=true
                cell.lbl_CutPrice.isHidden=true
            }
            
            if packCost[indexPath.item].contains(subscrionObj.amount)
            {
                cell.view_Content.backgroundColor = UIColor.init(red: 61.0/255.0, green: 163.0/255.0, blue: 225.0/255.0, alpha: 1.0)
                
                cell.lblDays.backgroundColor = UIColor.init(red: 77.0/255.0, green: 46.0/255.0, blue: 124.0/255.0, alpha: 1.0)
                cell.btnSelect.backgroundColor = UIColor.init(red: 77.0/255.0, green: 46.0/255.0, blue: 124.0/255.0, alpha: 1.0)
                cell.lblBillingType.textColor = UIColor.white
                cell.lblPrice.textColor = UIColor.white
                
            } else{
                cell.btnSelect.tag = indexPath.item
                cell.btnSelect.addTarget(self, action: #selector(selectedPlanAction), for: .touchUpInside)
            }
        }else{
            
            if packCost[indexPath.item].contains(subscrionObj.amount) {
                cell.view_Content.backgroundColor = UIColor.init(red: 77.0/255.0, green: 46.0/255.0, blue: 124.0/255.0, alpha: 1.0)
            } else{
                cell.view_Content.backgroundColor = #colorLiteral(red: 0.2398236096, green: 0.6409819126, blue: 0.8809617162, alpha: 1)
                cell.btnSelect.tag = indexPath.item
                cell.btnSelect.addTarget(self, action: #selector(selectedPlanAction), for: .touchUpInside)
            }
        }
        
        return cell
    }
    
    //varinder
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            return CGSize(width:210, height: 280)
        }
        
        let width = (self.view.frame.size.width ) - 4
        return CGSize(width:width-10, height: 60)
    }
    
    @objc func selectedPlanAction(sender: UIButton) {
        //varinder21
        if subscrionObj.planType == "web"{//web
            Proxy.shared.presentAlert(withTitle: "", message: "Subscription done from web.", currentViewController: self)
            return
        }
        
        //PLAN PURCHASED
        options = SubscriptionService.shared.options
        
        if sender.tag == 0 {
            if options != nil {
                guard let option = options?[sender.tag] else { return }
                index = 0
                SubscriptionService.shared.delegate = self
                
                Proxy.shared.showActivityIndicator()
                DispatchQueue.main.async {
                SubscriptionService.shared.purchase(subscription: option)
                }
            }
        } else if sender.tag == 1 {
            if options != nil {
                guard let option = options?[sender.tag] else { return }
                index = 1
                SubscriptionService.shared.delegate = self
                
                Proxy.shared.showActivityIndicator()
                DispatchQueue.main.async {
                    SubscriptionService.shared.purchase(subscription: option)
                }
            }
        } else {
            if options != nil {
                guard let option = options?[sender.tag] else { return }
                index = 2
                SubscriptionService.shared.delegate = self
                
                Proxy.shared.showActivityIndicator()
                DispatchQueue.main.async {
                SubscriptionService.shared.purchase(subscription: option)
                }
            }
        }
    }
    
    func purchaseDidFinish()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK:--> PAYMENTS  DELEGATE FUNCTION
    func paymentQueue(_ queue: SKPaymentQueue,
                      updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                handlePurchasingState(for: transaction, in: queue)
            case .purchased:
//                PreferencManger.setInAppProductIdentifier((((transaction as! SKPaymentTransaction).payment).productIdentifier))
                UserDefaults.standard.set((((transaction).payment).productIdentifier), forKey: "InAppProduct_Id")
                UserDefaults.standard.synchronize()
                handlePurchasedState(for: transaction, in: queue)
            case .restored:
                Proxy.shared.hideActivityIndicator()
                handleRestoredState(for: transaction, in: queue)
            case .failed:
                Proxy.shared.hideActivityIndicator()
                handleFailedState(for: transaction, in: queue)
            case .deferred:
                Proxy.shared.hideActivityIndicator()
                handleDeferredState(for: transaction, in: queue)
            }
        }
    }
    
    func handlePurchasingState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("User is attempting to purchase product id: \(transaction.payment.productIdentifier)")
    }
    
    func handlePurchasedState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("User purchased product id: \(transaction.payment.productIdentifier)")
        
        queue.finishTransaction(transaction)
        
        SubscriptionService.shared.uploadReceipt { (success, subscription,details) in
            
            let url = Apis.KServerUrl + Apis.KSubscriptionDetail
            
            if subscription != nil
            {
                if success
                {
                    let transactionID = subscription?.transaction_id
                    
                    let pack_Cost = self.packCost[self.index]
                    
                    let amount = pack_Cost.replacingOccurrences(of: "$", with: "")
                    
                    let endDate = self.convertDateToStr(date: subscription?.expiresDate ?? Date())
                    
                    let dateFormatter : DateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MMM-dd HH:mm:ss"
                    let date = Date()
                    let start_Date = dateFormatter.string(from: date)
                    
                    let param = [
                        "user_name"  :  "\(KAppDelegate.UserModelObj.userName)" as AnyObject,
                        "last_name" : "\(KAppDelegate.UserModelObj.userName)" as AnyObject,
                        "user_email"  :  "\(KAppDelegate.UserModelObj.userEmail)" as AnyObject,
                        "user_id"  :  "\(KAppDelegate.UserModelObj.userId)" as AnyObject,
                        "chargedAmount"  :  "\(amount)" as AnyObject,
                        "barintree_customerId"  :  "\(transactionID!)" as AnyObject,
                        "subscription_id"  :  "\(transactionID!)" as AnyObject,
                        "receipt_id"  :  details["latest_receipt"]! as AnyObject,
                        "plan"  :  "\(self.packDuration[self.index])" as AnyObject,
                        "subscriptionstart_date"  :  start_Date as AnyObject,
                        "nextBillingDate"  :  "\(endDate)" as AnyObject,
                        "billingFrequency"  :  "0" as AnyObject,
                        "status"  :  "active" as AnyObject,
                        "payment_from"  :  "IPAD" as AnyObject,
                        ] as [String:AnyObject]
                    
                    WebServiceProxy.shared.postData(url, params: param, showIndicator: false, completion: { (JSON) in
                        
                        var appResponse = Int()
                        appResponse = JSON["app_response"] as? Int ?? 0
                        if appResponse == 200 {
                            
                            //baltej30//varinder30
                            Proxy.shared.hideActivityIndicator()
                            if self.isFromManageSubscription {
                                self.getSubscriptionDetail()
                            } else  {
                                kisSubscribed = true
                                Proxy.shared.rootWithoutDrawer("TabbarViewController")
                            }
                        }
                    })
                }
                else
                {
                    Proxy.shared.hideActivityIndicator()
                }
            }
            else
            {
                Proxy.shared.hideActivityIndicator()
            }
        }
    }
    
    func handleRestoredState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("Purchase restored for product id: \(transaction.payment.productIdentifier)")
        queue.finishTransaction(transaction)
        
        SubscriptionService.shared.uploadReceipt { (success, subscription,details) in
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: SubscriptionService.restoreSuccessfulNotification, object: nil)
            }
        }
    }
    
    func handleFailedState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("Purchase failed for product id: \(transaction.payment.productIdentifier)")
    }
    
    func handleDeferredState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("Purchase deferred for product id: \(transaction.payment.productIdentifier)")
    }
}


extension SubscriptionDetailVIew {
    
    func getSubscriptionDetail() {
        let url = Apis.KServerUrl + Apis.manageSubscription
        
        let param = [
            "user_id"  :  "\(KAppDelegate.UserModelObj.userId)" as AnyObject
            ] as [String:AnyObject]
        
        
        DispatchQueue.main.async {
            Proxy.shared.showActivityIndicator()
        }
        
        WebServiceProxy.shared.postData(url, params: param, showIndicator: true) { (JSON) in
            
            var appResponse = Int()
            appResponse = JSON["app_response"] as? Int ?? 0
            if appResponse == 200 {
                
                let sub_scriptiondetails = JSON["sub_scriptiondetails"] as? NSDictionary
                if sub_scriptiondetails?.count != nil {
                    let subscriptionDetail = SubscriptionModel()
                    subscriptionDetail.getSubscriptionDetail(dict: sub_scriptiondetails!)
                    self.subscrionObj = subscriptionDetail
                }
                self.setData()
            } else {
                Proxy.shared.hideActivityIndicator()
            }
        }
    }
    
    func setData() {
        Proxy.shared.hideActivityIndicator()
        col_Vw.reloadData()
    }
    
    
    func convertDateToStr(date:Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let myString = formatter.string(from: date)
        let yourDate: Date? = formatter.date(from: myString)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let updatedString = formatter.string(from: yourDate!)
        return updatedString
    }
}

extension SubscriptionDetailVIew:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblOne {
            return demoText.count
        } else {
            return demoTextTwo.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tbltwo.dequeueReusableCell(withIdentifier: "ConstanTVC1", for: indexPath) as! ConstanTVC1
        if tableView == tblOne {
            cell.lblTitle.text = demoText[indexPath.row]
            return cell
        } else {
            cell.lblTitle.text = demoTextTwo[indexPath.row]
            return cell
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == tblOne {
            return 55
        }
        else
        {
            return 55
        }
    }
}

extension SubscriptionDetailVIew {
    @IBAction func logout(sender:UIButton) {
        Proxy.shared.logout {
            KAppDelegate.isGradiantShownForHome=false
            kisSubscribed=true
            Proxy.shared.rootWithoutDrawer("TabbarViewController")
        }
    }
}
