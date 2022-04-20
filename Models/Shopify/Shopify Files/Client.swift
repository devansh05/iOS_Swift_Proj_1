//
//  Client.swift
//  BoothCamp
//
//  Created by   on 01/11/18.
//  Copyright © 2018 iOS. All rights reserved.
//

import Foundation
import MobileBuySDK

final class Client {
    
    static let shopDomain = "happy-camper-live.myshopify.com"
    static let apiKey     = "2f80c240688fb8c4183b3e4ed0e96106"
    
    static let shared = Client()
    
    private let client: Graph.Client = Graph.Client(shopDomain: Client.shopDomain, apiKey: Client.apiKey)
    
    
    func fetchCollections(limit: Int = 20, productLimit: Int = 20,collectionTitle:String, completion: @escaping (NSMutableDictionary) -> Void)
        //-> Task
    {
        let dictionary : NSMutableDictionary! = NSMutableDictionary()
        let array : NSMutableArray! = NSMutableArray()
        
        let query = ClientQuery.queryForCollections(limit: limit, productLimit: productLimit)
        var collectionName = ""
        let task = client.queryGraphWith(query) { response, error in
            
            let collections  = response?.shop.collections.edges.map { $0.node }
            
            collections?.forEach { collection in
                if(collection.title.lowercased() == collectionTitle.lowercased()) {
                    collectionName = collection.title
                    dictionary.setValue(collectionName, forKey: "collection_Name")
                    
                    let collection = collection
                    let products = collection.products.edges.map { $0.node }
                    //   print(products)
                    products.forEach { item in
                        
                        let dict : NSMutableDictionary! = NSMutableDictionary()
                        let arrImages : NSMutableArray! = NSMutableArray()
                        dict.setValue(item.id.rawValue, forKey: "product_Id")
                        //                        dict.setValue(item.productType, forKey: "productType")
                        dict.setValue(item.description, forKey: "product_Description")
                        dict.setValue(item.title, forKey: "product_Name")
                        let images = item.images.edges.map { $0.node }
                        images.forEach { item in
                            
                            let dictImage = NSMutableDictionary()
                            let image = item.originalSrc
                            let id = item.id
                            if(image.absoluteString != "") {
                                dictImage.setValue(id, forKey: "image_Id")
                                dictImage.setObject(image.absoluteString, forKey: "product_Image" as NSCopying)
                            }else{
                                dictImage.setObject("", forKey: "product_Image" as NSCopying)
                            }
                            arrImages.add(dictImage)
                        }
                        dict.setValue(arrImages, forKey: "product_Images")
                        
                        let variants = item.variants.edges.map{ $0.node }
                        variants.forEach{ item in
                            let price = item.price
                            let variantId = item.id.rawValue
                            dict.setValue(price, forKey: "product_Price")
                            dict.setValue(variantId, forKey: "variant_Id")
                        }
                        
                        // GET Options data
                        _ = item.options.drop(while: { (item) -> Bool in
                            dict.setValue(item.values, forKey: "product_Values")
                            dict.setValue(item.id, forKey: "product_OptionId")
                            return true
                        })
                        
                        let hee = item.options
                        hee.forEach { item in   }
                        
                        array.add(dict)
                    }
                    
                   dictionary.setValue(array, forKey: "All_Products")
                    completion(dictionary)
                }
            }
        }
        task.resume()
        //     return task
    }
    
    func fetchProductDetail(limit: Int = 20, productLimit: Int = 20, productID : GraphQL.ID, completion: @escaping (NSMutableDictionary) -> Void) -> Task {
      
        let query = ClientQuery.queryForProductDetail(limit: limit, productLimit: productLimit, productID: productID)
     
        let task = client.queryGraphWith(query) { response, error in
            print(response)
            
            let dictionary = NSMutableDictionary()
            let product  = response?.node as? Storefront.Product
            let images   = product?.images.edges.map { $0.node }
            let arrImages : NSMutableArray! = NSMutableArray()
            images?.forEach{ item in
                
                let dictImage = NSMutableDictionary()
                let image = item.originalSrc
                let id = item.id
                if(image.absoluteString != ""){
                    dictImage.setValue(id, forKey: "id")
                    dictImage.setObject(image.absoluteString, forKey: "image" as NSCopying)
                }else{
                    dictImage.setObject("", forKey: "image" as NSCopying)
                }
                arrImages.add(dictImage)
            }
            dictionary.setValue(arrImages, forKey: "images")
            
            let description = product?.description
            let id = product?.id
            let name = product?.title
            dictionary.setValue(description, forKey: "productDescription")
            dictionary.setValue(id, forKey: "productId")
            dictionary.setValue(name, forKey: "ProductTitle")
            completion(dictionary)
        }

        task.resume()
        return task
    }
    
    
    
    // ----------------------------------
    //  MARK: - Checkout -
    //
//    @discardableResult
    func createCheckout(with cartItems: [Product], completion: @escaping (NSString?) -> Void) { ///**/
        let mutation = ClientQuery.mutationForCreateCheckout(with: cartItems)
        let task     = self.client.mutateGraphWith(mutation) { response, error in
//            error.debugPrint()
            print(response?.checkoutCreate?.checkout?.webUrl)
//            completion(response?.checkoutCreate?.checkout?.viewModel)
        }
        
        task.resume()
//        return task
    }
    
}
