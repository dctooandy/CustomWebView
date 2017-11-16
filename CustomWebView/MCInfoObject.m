//
//  MCInfoObject.m
//  CustomWebView
//
//  Created by AndyChen on 2017/8/8.
//  Copyright © 2017年 AndyChen. All rights reserved.
//

#import "MCInfoObject.h"
#import "Constant_m.h"
@implementation MCInfoObject
+ (MCInfoObject *)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}
@end
