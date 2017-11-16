//
//  ViewController.h
//  CustomWebView
//
//  Created by AndyChen on 2016/11/9.
//  Copyright © 2016年 AndyChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OverlayButton.h"
#import "TableViewController.h"
#import <WebKit/WebKit.h>
@interface ViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *theTextField;
@property (strong, nonatomic) IBOutlet OverlayButton *pushToWebView;
@property (strong, nonatomic) IBOutlet UIImageView *currentImageView;
@property (strong, nonatomic) CAShapeLayer *eyeFirstLightLayer;
@property (strong, nonatomic) CAShapeLayer *eyeSecondLightLayer;
@property (strong, nonatomic) CAShapeLayer *eyeballLayer;
@property (strong, nonatomic) CAShapeLayer *topEyesocketLayer;
@property (strong, nonatomic) CAShapeLayer *bottomEyesocketLayer;
@property (strong, nonatomic) TableViewController *tableviewcontroller;
@property (strong, nonatomic) NSMutableArray *songListArray;
@property (strong, nonatomic) WKWebView *theWkWebView;
@property (strong, nonatomic) UIWebView *theUIWebView;
@property ( nonatomic) BOOL shortCutItemCall;
+ (ViewController *) sharedApplication;
@end

