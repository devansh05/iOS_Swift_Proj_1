//
//  SRSubscriptionModel.m
//
//  Created by   on 24/09/15.
//  Copyright (c) 2015 OrderOfTheLight. All rights reserved.
//

#ifdef DEBUG

#define verifyReceipt @"https://sandbox.itunes.apple.com/verifyReceipt"

#else

#define verifyReceipt @"https://buy.itunes.apple.com/verifyReceipt"

#endif


#define userDef(parameter) [[NSUserDefaults standardUserDefaults]objectForKey:parameter]


#import "SRSubscriptionModel.h"
#import <StoreKit/StoreKit.h>

NSString *const kStoreKitSecret = @"318513252bb941cb937e970329522e1c";
NSString *const kSubscriptionActive = @"com.fot.FreelanceontapSubscription.existing_subscription_isactive";
NSString *const kAppReceipt = @"com.fot.FreelanceontapSubscription.existing_app_reciept";
NSString *const kSubscriptionProduct = @"com.fot.FreelanceontapSubscription.existing_subscription_product";


 //NSString *const kSRProductPurchasedNotification = @"com.fot.FreelanceontapMonthlySubscription.PurchaseNotification";
 //NSString *const kSRProductUpdatedNotification = @"com.fot.FreelanceontapMonthlySubscription.UpdatedNotification";
 //NSString *const kSRProductRestoredNotification = @"com.fot.FreelanceontapMonthlySubscription.RestoredNotification";
// NSString *const kSRProductFailedNotification = @"com.fot.FreelanceontapMonthlySubscription.FailedNotification";
 NSString *const kSRProductLoadedNotification = @"com.fot.FreelanceontapSubscription.LoadedNotification";
 NSString *const kSRSubscriptionResultNotification = @"com.fot.FreelanceontapSubscription.ResultNotification";




@interface SRSubscriptionModel()<SKPaymentTransactionObserver,SKProductsRequestDelegate>
@property (nonatomic,strong) NSString *latestReceipt;
@end

@implementation SRSubscriptionModel {
    NSMutableDictionary *payLoad;
}

+ (instancetype)shareKit {
    static SRSubscriptionModel *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

            manager = [[SRSubscriptionModel alloc]init];
            manager.currentProduct = [[NSMutableDictionary alloc]init];
        
            manager.subscriptionPlans = [NSSet setWithObjects:[[NSUserDefaults standardUserDefaults]objectForKey:@"InAppProduct_Id"] , nil];
            manager.isFreeTrialActive = NO;
            manager.expiryDate = @"none";
            manager.purchaseDate = @"";
        
            [[SKPaymentQueue defaultQueue]addTransactionObserver:manager];
            //[manager startProductRequest];
            //[manager loadProducts];
        
    });
    return manager;
}


-(void)refreshReciept
{
    NSURL *recieptURL = [[NSBundle mainBundle]appStoreReceiptURL];
    NSError *recieptError ;
    BOOL isPresent = [recieptURL checkResourceIsReachableAndReturnError:&recieptError];
    
    if(!isPresent)
    {
        SKReceiptRefreshRequest *ref = [[SKReceiptRefreshRequest alloc]init];
        ref.delegate = self;
        [ref start];
    }
    else
    {
        [self loadProducts];
    }
}

-(void)loadProducts
{
 NSError *error;
    _currentIsActive = NO;
    
    if(!userDef(kAppReceipt))
    {
        NSURL *recieptURL = [[NSBundle mainBundle]appStoreReceiptURL];
        NSError *recieptError ;
        BOOL isPresent = [recieptURL checkResourceIsReachableAndReturnError:&recieptError];

        if(!isPresent)
        {
            SKReceiptRefreshRequest *ref = [[SKReceiptRefreshRequest alloc]init];
            ref.delegate = self;
            [ref start];
            return;
        }
        
        NSData *recieptData = [NSData dataWithContentsOfURL:recieptURL];
        if(!recieptData){
            return;
        }
       
        payLoad = [NSMutableDictionary dictionaryWithObject:[recieptData base64EncodedStringWithOptions:0] forKey:@"receipt-data"];
    }
    else
    {
        NSLog(@"------------->%@",userDef(kAppReceipt));
        [payLoad setObject:userDef(kAppReceipt) forKey:@"receipt-data"];
    }
    
    
    [payLoad setObject:kStoreKitSecret forKey:@"password"];
    
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:payLoad options:0 error:&error];
    
    NSMutableURLRequest *sandBoxReq = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:verifyReceipt]];
    [sandBoxReq setHTTPMethod:@"POST"];
    [sandBoxReq setHTTPBody:requestData];
    
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:sandBoxReq completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if(!error)
        {
            //NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            

            _latestReceipt = [jsonResponse objectForKey:@"latest_receipt"];
            
            
            if([jsonResponse objectForKey:@"latest_receipt_info"])
            {
                NSArray *array = [jsonResponse objectForKey:@"latest_receipt_info"];
                NSDictionary *latestDetails = [array lastObject];
                
                NSLog(@"%@",latestDetails);
                
                if([latestDetails objectForKey:@"cancellation_date_ms"])
                {
                    _currentIsActive = NO;
                }
                
                if([latestDetails objectForKey:@"is_trial_period"])
                {
                    if([[latestDetails objectForKey:@"is_trial_period"] isEqualToString:@"true"])
                    {
                        _isFreeTrialActive = YES;

                    }
                    else
                    {
                        _isFreeTrialActive = NO;
                    }
                }
                
                
                if([latestDetails objectForKey:@"expires_date"])
                {
                    _expiryDate =  [latestDetails objectForKey:@"expires_date"];
                }
                
                if([latestDetails objectForKey:@"product_id"])
                {
                    _productId =  [latestDetails objectForKey:@"product_id"];
                    //DK:
                    [[NSUserDefaults standardUserDefaults]setObject:[latestDetails objectForKey:@"product_id"] forKey:@"InAppProduct_Id"];
//                    [PreferencManger setInAppProductIdentifier:];
                }
                
                if([latestDetails objectForKey:@"original_purchase_date"])
                {
                    _purchaseDate =  [latestDetails objectForKey:@"original_purchase_date"];
                }

                NSLog(@"_expiryDate-->%@",_expiryDate);

                
                if([latestDetails objectForKey:@"product_id"])
                {
                    [_currentProduct setObject:[latestDetails objectForKey:@"product_id"] forKey:@"product"];
                    [userDefault setObject:_currentProduct forKey:kSubscriptionProduct];

                }
                if([latestDetails objectForKey:@"expires_date_ms"])
                {
                    [_currentProduct setObject:[latestDetails objectForKey:@"expires_date_ms"] forKey:@"expiry_time"];
                    [userDefault setBool:_currentIsActive forKey:kSubscriptionActive];
                }
                
                
                
                _currentIsActive = [self calculateCurrentSubscriptionActive];
                [_currentProduct setObject:[NSNumber numberWithBool:_currentIsActive] forKey:@"active"];
                
                
                //NSLog(@"Product active -- %hhd",_currentIsActive);

            }
            else
            {
                //_currentIsActive = YES;
                NSLog(@"no purchase done, first time user!");

            }
            [[NSNotificationCenter defaultCenter]postNotificationName:kSRSubscriptionResultNotification object:nil];
        }
        
    }] resume];
    
    
}


#pragma mark - Restore

-(void)restoreSubscriptions{
    [[SKPaymentQueue defaultQueue]restoreCompletedTransactions];
}

-(void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error{
    //Fail restoring!
    NSLog(@"Restoration of subscription failed!");
}

-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue{
    //restored!
   NSLog(@"Subscriptions restored");
    
}



#pragma mark - Transaction Observers

-(void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads{
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
                
            case SKPaymentTransactionStatePurchasing:
                break;
                
            case SKPaymentTransactionStateDeferred:{
                [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
                break;
            }
            case SKPaymentTransactionStateFailed:{
                NSLog(@"failed prod_id: %@", transaction.payment.productIdentifier);
                [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
                break;
            }
            case SKPaymentTransactionStatePurchased:{
                NSLog(@"PURCHASED!N prod_id: %@", transaction.payment.productIdentifier);
                [self saveProductPurchaseWithProduct:transaction];
                break;
            }
            case SKPaymentTransactionStateRestored: {
                NSLog(@"RESTORED");
                [self postRestoredNotification:transaction];
                break;

            }
        }
    }
}



/************* CHECK IF CURRENT SUBSCRIPTION ACTIVE OR NOT! ****************/

-(BOOL)calculateCurrentSubscriptionActive
{
    NSString *str = [_currentProduct objectForKey:@"expiry_time"];
    long long currentExpTime = [str longLongValue]/1000;
    long currentTimeStamp = [[NSDate date] timeIntervalSince1970];
    NSLog(@"%ld",currentTimeStamp);
    
    return (currentExpTime > currentTimeStamp) ? YES : NO;
    
}



/************ CALL THIS TO FETCH ALL OBJECTS IN THE IN APP ****************/

-(void)startProductRequest{
    SKProductsRequest *productRequest = [[SKProductsRequest alloc]initWithProductIdentifiers:_subscriptionPlans];
    productRequest.delegate = self;
    [productRequest start];
}

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    
    NSLog(@"SKProductsRequest didReceiveResponse--->%@",response.products);
    _availableProducts = response.products;
    [[NSNotificationCenter defaultCenter]postNotificationName:kSRProductLoadedNotification object:nil];
}


-(void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    
    NSLog(@"SKRequest didFailWithError--->%@",error.localizedDescription);
    
    //Fire notification if user is clicked on cancel buttton on Schecdule page when verifying reciept
    [[NSNotificationCenter defaultCenter]postNotificationName:kSRSubscriptionResultNotification object:nil];

}


-(void)requestDidFinish:(SKRequest *)request{
    NSLog(@"REQUEST DID FINISH");

    [self loadProducts];
}

/************ BUY SUBSCRIPTION ****************/

-(void)makePurchase:(NSString *)productIdentifier{
    
    if(_availableProducts.count == 0){
        [self startProductRequest];
        return;
    }
    
    [_availableProducts enumerateObjectsUsingBlock:^(SKProduct *thisProduct, NSUInteger idx, BOOL *stop) {
        if ([thisProduct.productIdentifier isEqualToString:productIdentifier]) {
            *stop = YES;
            SKPayment *payment = [SKPayment paymentWithProduct:thisProduct];
            [[SKPaymentQueue defaultQueue] addPayment:payment];
        }
    }];
}


/************ SAVE PRODUCT INFO WHEN SUBSCRIPTION IS OVER AND AGAIN USER BOUGHT ****************/

-(void)saveProductPurchaseWithProduct:(SKPaymentTransaction *)transaction{
    [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
    [self postNotificationPurchased:transaction.payment.productIdentifier];
}



-(void)postNotificationPurchased:(NSString *)identifier
{
    if(!self.currentIsActive)
    {
        NSDictionary *obj = @{@"product":identifier};
        self.currentIsActive = YES;
        self.currentProduct = [obj mutableCopy];
        //[[NSNotificationCenter defaultCenter]postNotificationName:kSRProductPurchasedNotification object:obj];
    }
    
}

-(void)postRestoredNotification:(SKPaymentTransaction *)transaction{
    [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
    //[[NSNotificationCenter defaultCenter]postNotificationName:kSRProductRestoredNotification object:nil];
}



@end
