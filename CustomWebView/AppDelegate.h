//
//  AppDelegate.h
//  CustomWebView
//
//  Created by AndyChen on 2016/11/9.
//  Copyright © 2016年 AndyChen. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) BOOL backplay;
@property (strong, nonatomic) NSString *setingPlistPath;
@property (strong, nonatomic) NSMutableDictionary *settingPlistData;
@end

