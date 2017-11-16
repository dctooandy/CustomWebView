//
//  ConstantEnumList.h
//  ISGlobalSDK
//
//  Created by AndyChen on 2017/2/10.
//  Copyright © 2017年 AndyChen. All rights reserved.
//

typedef NS_ENUM(NSInteger, GlobalLoginEvent){
    NormalLogin = 1,
    FastBindLogin ,
    CustomLogin
} ;
typedef NS_ENUM(NSInteger, HttpRequestMethod){
    UploadTask = 1,
    OldNSURLConnection ,
} ;
typedef NS_ENUM(NSInteger, ReceiptFromResoult){
    PurchaseSuccess = 1,
    PurchaseAndRestoreSuccess  ,
    RestoreSuccess  ,
    ErrorPurchase ,
} ;
