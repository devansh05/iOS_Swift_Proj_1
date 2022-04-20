//
//  ClientQuery.swift
//  BoothCamp
//
//  Created by   on 01/11/18.
//  Copyright © 2018 iOS. All rights reserved.
//

import Foundation
import MobileBuySDK

final class ClientQuery{

    static func queryForCollections(limit: Int, productLimit: Int = 10)-> Storefront.QueryRootQuery{
        let query = Storefront.buildQuery { $0
            .shop { $0
                .collections(first: Int32(limit)) { $0
                    .edges { $0
                        .node { $0
                            .id()
                            .title()
                  .products(first: Int32(productLimit)) { $0
                                .edges { $0
                                    .node { $0
                                        .id()
                                        .title()
                                        .productType()
                                        .description()
                                        .images(first: 10) { $0
                                            .edges { $0
                                                .node { $0
                                                    .id()
                                                    .originalSrc()
                                                }
                                            }
                                        }
                                
                                        .variants(first: 10) { $0
                                            .edges { $0
                                                .node { $0
                                                    .id()
                                                    .price()
                                                    .title()
                                                }
                                            }
                                        }
                                        
                                     
                                        
                                        .options(first: 10) { $0
                                            .id()
                                            .values()
                                            
                                        }
                                        
                                    }
                                }
                            }
 
                        }
                    }
                }
            }
        }
       return query
    }
    
    static func queryForProductDetail(limit: Int, productLimit: Int = 10, productID : GraphQL.ID)-> Storefront.QueryRootQuery{
        let query = Storefront.buildQuery { $0
            .node(id: productID) { $0
                .onProduct { $0
                    .id()
                    .title()
                    .description()
                    .images(first: 10) { $0
                        .edges { $0
                            .node { $0
                                .id()
                                .originalSrc()
                            }
                        }
                    }
                    .variants(first: 10) { $0
                        .edges { $0
                            .node { $0
                                .id()
                                .price()
                                .title()
                                .availableForSale()
                            }
                        }
                    }
                }
            }
        }
        return query
    }
    
    // ----------------------------------
    //  MARK: - Checkout -
    //
    static func mutationForCreateCheckout(with cartItems: [Product]) -> Storefront.MutationQuery {
        let lineItems = cartItems.map { item in
            Storefront.CheckoutLineItemInput.create(quantity: Int32(item.quantity), variantId: GraphQL.ID(rawValue: item.variantId)) //item.variant.id
        }
        
        let checkoutInput = Storefront.CheckoutCreateInput.create(
            lineItems: .value(lineItems),
            allowPartialAddresses: .value(true)
        )
        
        return Storefront.buildMutation { $0
            .checkoutCreate(input: checkoutInput) { $0
                .checkout { $0
                    .fragmentForCheckout()
                }
            }
        }
    }
    
}

extension Storefront.CheckoutQuery {
    
    @discardableResult
    func fragmentForCheckout() -> Storefront.CheckoutQuery { return self
        .id()
        .ready()
        .requiresShipping()
        .taxesIncluded()
        .email()
        
        .discountApplications(first: 250) { $0
            .edges { $0
                .node { $0
                    .fragmentForDiscountApplication()
                }
            }
        }
        
        .shippingDiscountAllocations { $0
            .fragmentForDiscountAllocation()
        }
        
        .appliedGiftCards { $0
            .id()
            .balance()
            .amountUsed()
            .lastCharacters()
        }
        
        .shippingAddress { $0
            .firstName()
            .lastName()
            .phone()
            .address1()
            .address2()
            .city()
            .country()
            .countryCodeV2()
            .province()
            .provinceCode()
            .zip()
        }
        
        .shippingLine { $0
            .handle()
            .title()
            .price()
        }
        
        .note()
        .lineItems(first: 250) { $0
            .edges { $0
                .cursor()
                .node { $0
                    .variant { $0
                        .id()
                        .price()
                    }
                    .title()
                    .quantity()
                    .discountAllocations { $0
                        .fragmentForDiscountAllocation()
                    }
                }
            }
        }
        .webUrl()
        .currencyCode()
        .subtotalPrice()
        .totalTax()
        .totalPrice()
        .paymentDue()
    }
}

//
extension Storefront.DiscountAllocationQuery {
    
    @discardableResult
    func fragmentForDiscountAllocation() -> Storefront.DiscountAllocationQuery { return self
        .allocatedAmount { $0
            .amount()
            .currencyCode()
        }
        .discountApplication { $0
            .fragmentForDiscountApplication()
        }
    }
}

//
extension Storefront.DiscountApplicationQuery {
    
    @discardableResult
    func fragmentForDiscountApplication() -> Storefront.DiscountApplicationQuery { return self
        .onDiscountCodeApplication { $0
            .applicable()
            .code()
        }
        .onManualDiscountApplication { $0
            .title()
        }
        .onScriptDiscountApplication { $0
            .description()
        }
    }
}
