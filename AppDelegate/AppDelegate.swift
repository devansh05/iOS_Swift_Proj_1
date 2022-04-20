import UIKit
import StoreKit
import IQKeyboardManagerSwift
import Alamofire
import AVKit
import SDWebImage
import DropDown

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var storyBoradVal =  UIStoryboard()
    let receiptURL = Bundle.main.appStoreReceiptURL
    var isHomeScreenCalled:Bool = false
    var isGradiantShown:Bool = false
    var isGradiantShownForHome:Bool = false
    var isGradiantShownForSubCategory:Bool = false
    var isGradiantShownForCampfire:Bool = false
    var isGradiantShownForSubEpisodes:Bool = false
    
    var isWebSeriesTabSelected:Bool = false
    var isCampfireTabSelected:Bool = false
    
    var isVideoNeedsToPlay:Bool = false
    var sessionManager: SessionManager!
    var activityIndicator = UIActivityIndicatorView()
    var UserModelObj = UserModel()
    let loginAuth = Proxy.shared.authNil()
    var globalNavigation = UINavigationController()
    let myGroup = DispatchGroup()
//    let storyBoradVal =  UIStoryboard(name: "Main", bundle: nil)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //        UIApplication.shared.statusBarStyle = .lightContent
        
        if UIDevice.current.userInterfaceIdiom != .pad {
            if let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView {
                //            statusBar.backgroundColor = UIColor.init(red: 72/255, green: 49/255, blue: 115/255, alpha: 1.0)
                //            statusBar.backgroundColor = UIColor.init(red: 111/255, green: 87/255, blue: 167/255, alpha: 1.0)
                statusBar.backgroundColor = UIColor.init(red: 106/255, green: 79/255, blue: 158/255, alpha: 1.0)
                //            statusBar.backgroundColor = UIColor.init(red: 115/255, green: 85/255, blue: 173/255, alpha: 1.0)
            }
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        
        //SKPaymentQueue.default().add(self)
        //SubscriptionService.shared.loadSubscriptionOptions()
        
        //IQKeyboardManager.shared.enableAutoToolbar = true
        //IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.enable = true
        
        addActivityIndicator()
        checkStoryBoard()
        
        DropDown.startListeningToKeyboard()

        return true
    }
    
    func addActivityIndicator() {
        activityIndicator.style = .gray
        activityIndicator.transform = CGAffineTransform(scaleX: 3, y: 3)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        window?.rootViewController?.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: (window?.rootViewController?.view.centerXAnchor)!),
            activityIndicator.centerYAnchor.constraint(equalTo: (window?.rootViewController?.view.centerYAnchor)!),
            ])
    }
    
    func checkStoryBoard() {
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            print("iPad")
            storyBoradVal =  UIStoryboard(name: "Main", bundle: nil)
        }else{
            print("not iPad")
            setMainDrawer()
            
        /*    storyBoradVal =  UIStoryboard(name: "iPhone", bundle: nil)
            let leftMenuController = storyBoradVal.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as! UISideMenuNavigationController
            SideMenuManager.default.menuLeftNavigationController = leftMenuController
            
            //             this line is important
            self.window = UIWindow(frame: UIScreen.main.bounds)
            
            // controller identifier sets up in storyboard utilities
            // panel (on the right), it called Storyboard ID
            let viewController = storyBoradVal.instantiateViewController(withIdentifier: "TabbarViewController") as! TabbarViewController
            self.window?.rootViewController = viewController
            self.window?.makeKeyAndVisible()
 */
        }
    }
    
    
    // Main Drawer Controller
    func setMainDrawer() {

        storyBoradVal =  UIStoryboard(name: "iPhone", bundle: nil)
        let redViewController = storyBoradVal.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        redViewController.setup(type: 6)
        redViewController.leftViewWidth = UIScreen.main.bounds.width-70

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let nav = UINavigationController.init(rootViewController: redViewController)
        globalNavigation = appDelegate.window?.rootViewController as! UINavigationController
        appDelegate.window?.rootViewController = nav
        nav.setNavigationBarHidden(true, animated: false)
    }
    
    
    //Set Root Controller
//    func setMainDrawevr() {
//        storyBoradVal =  UIStoryboard(name: "iPhone", bundle: nil)
//        let viewController = storyBoradVal.instantiateViewController(withIdentifier: "TabbarViewController") as! TabbarViewController
//        let sideMenuController = MainViewController.init(rootViewController: viewController)
//        sideMenuController.setup(type: 6)
//        sideMenuController.leftViewWidth = UIScreen.main.bounds.width-70
////        sideMenuController.leftViewBackgroundColor = .purple
////        let leftControlelr = LeftViewController()
////        sideMenuController.leftView?.addSubview(leftControlelr.tbl_List)
////        self.window = UIWindow(frame: UIScreen.main.bounds)
////
////        self.window?.rootViewController = sideMenuController
////        self.window?.makeKeyAndVisible()
//        
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        let nav = UINavigationController.init(rootViewController: sideMenuController)
//        appDelegate.window?.rootViewController = nav
//    }
    
    // Manage device orientation for both iPad and iPhone
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .all
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //Notify When deep linking getting returned from web end
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let str = url.absoluteString
        if str.contains(" ") {
            
            var obj = ["type":"ipad-signup"]
            
            if str.contains("community") {
                obj = ["type":"community"]
            }
            
              if str.contains("ipadstore") {
                obj = ["type":"ipadstore"]
            }
            
            if str.contains("web-series") {
                obj = ["type":"web-series"]
            }
            
            if str.contains("360") {
                obj = ["type":"360"]
            }
            
            if str.contains("campfire") {
                obj = ["type":"campfire"]
            }
            
            if str.contains("nearbycamp") {
                obj = ["type":"nearbycamp"]
            }
            
            if str.contains("home") {
                obj = ["type":"home"]
            }
            
            NotificationCenter.default.post(name: Notification.Name("campfire_url"), object: nil, userInfo: obj)
        }
        return true
    }
    
    func checkAuthcode() {
        let auth = Proxy.shared.authNil()
        if auth == "" {
            // RootControllerProxy.shared.rootWithoutDrawer("WelcomeVC")
        } else {
//            checkApiMethodWithoutNotification {
//                Proxy.shared.rootWithoutDrawer("TabbarViewController")
//            }
        }
    }
    
    //MARK:--> SIGN UP API FUNCTION
    func checkApiMethodWithoutNotification(_ completion:@escaping() -> Void) {
        let param = [
            "accessToken" : "\(Proxy.shared.authNil())"
            ] as [String:AnyObject]
        
        WebServiceProxy.shared.postData("\(Apis.KServerUrl)\(Apis.KCheck)", params: param, showIndicator: true, completion: { (JSON) in
            var appResponse = Int()
            appResponse = JSON["app_response"] as? Int ?? 0
            
            if appResponse == 200 {
                if let userDetail = JSON["userdetails"] as? NSDictionary {
                    let UserModelObj = UserModel()
                    UserModelObj.getUserDetail(dict: userDetail)
                    KAppDelegate.UserModelObj = UserModelObj
                }
                
                // Check if Subscription detail not empty
                if let scription = JSON["sub_scriptiondetails"] as? NSDictionary  {
                    
//                    SRSubscriptionModel.shareKit().loadProducts()
//                    if(SRSubscriptionModel.shareKit().currentIsActive) {
                        if scription["status"] as? String != "active" {
                            if (scription["barintree_customerId"] as? String) != nil {
                                // Got Payment from
                                let payemtFrom = scription["payment_from"] as? String
                                if payemtFrom == "IPAD" {
                                    let plan = scription["payment_from"] as? String
                                    
                                    var APi_Data = [String: String]()
                                    APi_Data["API"] = "in-app"
                                    APi_Data["plan"] = plan
                                    
                                    // Open subscription page
                                    NotificationCenter.default.post(name: Notification.Name("checkSubscription"), object: APi_Data)
                                }
                            } else {  }
                        } else {
                            NotificationCenter.default.post(name: Notification.Name("checkSubscription"), object: ["API":""])
                    }
            //        }
                    
                } else {
                     // Open subscription page
                    let APi_Data:[String: String] = ["API": "API"]
                    NotificationCenter.default.post(name: Notification.Name("checkSubscription"), object: APi_Data)
                    kisSubscribed=false
                }
            }
            Proxy.shared.hideActivityIndicator()
            completion()
        })
    }}
