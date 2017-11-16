//
//  MCInfoObject.h
//  CustomWebView
//
//  Created by AndyChen on 2017/8/8.
//  Copyright © 2017年 AndyChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCInfoObject : NSObject
@property (nonatomic) NSInteger MCTouchDotCounts;
@property (nonatomic,strong) NSMutableArray* iSGameDotOpenArray;
@property (nonatomic) BOOL quickActionPlay;

+ (MCInfoObject *)sharedInstance;
@end
