//
//  ViewController.m
//  CustomWebView
//
//  Created by AndyChen on 2016/11/9.
//  Copyright © 2016年 AndyChen. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "MCTouchDotViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MCInfoObject.h"
#import "Firebase.h"
#define Height       [[UIScreen mainScreen] bounds].size.height
#define Width        [[UIScreen mainScreen] bounds].size.width
#define TheWidth(x,y) ((x>y)?y:x)
#define TheHeight(x,y) ((x>y)?x:y)
#define CURRENT_DEV_Version         [[[UIDevice currentDevice] systemVersion] floatValue]

@interface ViewController ()<UITextFieldDelegate,UIWebViewDelegate,UIGestureRecognizerDelegate,UIScrollViewDelegate,WKNavigationDelegate>
{
    BOOL neverShowAlert;
}
@end

@implementation ViewController
@synthesize tableviewcontroller,songListArray,theWkWebView,theUIWebView,shortCutItemCall;
// 統一取得微平台單一實例
+ (ViewController *) sharedApplication
{
    static ViewController *theViewController = nil;
    static dispatch_once_t OnceToken;
    dispatch_once(&OnceToken, ^{
        theViewController = [[self alloc] init];
        NSLog(@"設置 ViewController");
    });
    return theViewController;
}
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations
//{
//
//    return UIInterfaceOrientationMaskLandscape; // 強制直立，因為其他方向只有iOS 8.3之後的初始旋轉有用，所以乾脆全部自己轉
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpView];
    [self setupAnimation];
    [self setNotification];
    
    //    [self setAudioSession];
    
    //    [self setUpView];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    
    if (songListArray == nil)
    {
        songListArray = [[NSMutableArray alloc] init];
    }
    if (songListArray.count >0)
    {
        [songListArray removeAllObjects];
        [self callSOPAlert];
    }
    [MCTouchDotViewController sharedApplication];
    [MCTouchDotViewController showMCTouchDot];
//    assert(false);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpView
{
    if ([self si_IsAvailableNetworkWithCompleteBlock:nil])
    {
        if (theWkWebView == nil)
        {
            [self createWKWebView];
        }
        if (theUIWebView == nil)
        {
            [self createUIWebView];
        }
        
        [self pushNavagationbar];
        if ( tableviewcontroller == nil)
        {
            tableviewcontroller = [[TableViewController alloc] initWithNibName:@"TableViewController" bundle:nil];
        }
    }else
    {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Message"
                                      message:@"網路異常"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action)
                                   {
                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                   }];
        [alert addAction:okAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}
- (void)setupAnimation
{
    self.eyeFirstLightLayer.lineWidth = 0.f;
    self.eyeSecondLightLayer.lineWidth = 0.f;
    self.eyeballLayer.opacity = 0.f;
    self.bottomEyesocketLayer.strokeStart = 0.5f;
    self.bottomEyesocketLayer.strokeEnd = 0.5f;
    self.topEyesocketLayer.strokeStart = 0.5f;
    self.topEyesocketLayer.strokeEnd = 0.5f;
    [theWkWebView.layer addSublayer:_topEyesocketLayer];
    [theWkWebView.layer addSublayer:_eyeFirstLightLayer];
    [theWkWebView.layer addSublayer:_eyeSecondLightLayer];
    [theWkWebView.layer addSublayer:_eyeballLayer];
    [theWkWebView.layer addSublayer:_bottomEyesocketLayer];
    
}
- (void)setNotification
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidChangeFrame:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeStatusbarOrientation)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeDeviceOrientation)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    // 3D Touch
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotoDetailVc:)
                                                 name:@"Notice3DTouch"
                                               object:nil];
}
- (void)setAudioSession
{
    //    NSError *error;
    //    BOOL isAudioOK = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
    //                                     withOptions:AVAudioSessionCategoryOptionMixWithOthers
    //                                           error:&error];
    //    if (!isAudioOK)
    //    {
    //        NSLog(@"Cause Error :%@",error.description);
    //    }
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    BOOL ok;
    NSError *setCategoryError = nil;
    NSError *activationError = nil;
    ok =[audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
    //     [audioSession setCategory:AVAudioSessionCategoryAmbient withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&setCategoryError];
    [audioSession setActive: YES error: &activationError];
    if (!ok) {
        NSLog(@"%s setCategoryError=%@", __PRETTY_FUNCTION__, setCategoryError);
    }
}
- (void)pushNavagationbar
{
    NSString * webMode = @"webview";
        NSString *deviceName = [NSString stringWithFormat:@"%s",[[[UIDevice currentDevice] name] UTF8String]];
        NSString *url = [NSString stringWithFormat:@"http://211.23.68.247/?mode=%@&device_name=%@",webMode,[self urlencode:deviceName]];
//    NSString *url = [NSString stringWithFormat:@"http://211.23.68.247/?mode=%@",webMode];
    
    NSURL *nsUrl = [NSURL URLWithString:url];
    //    NSURLRequest *request = [NSURLRequest requestWithURL:nsUrl cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:nsUrl];
    
    //    theUIWebView.alpha = 0.0;
    theWkWebView.alpha = 0.0;
    [theUIWebView loadRequest:request];
    //    [theWkWebView loadRequest:request];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSLog(@"改變:%ld",(long)fromInterfaceOrientation);
}

//- (UIImageView *)createGIFBG
//{
//    NSMutableArray *gifArray = [[NSMutableArray alloc] init];
//    for (int i = 1; i<5; i++)
//    {
//        [gifArray addObject:[UIImage imageNamed:[NSString stringWithFormat:@"blackp%i.tiff",i]]];
//    }
//    currentImageView.animationImages = gifArray;
//    currentImageView.animationDuration = 0.7f;
//    currentImageView.animationRepeatCount = 0;
//    [currentImageView startAnimating];
//    [self.view addSubview:currentImageView];
//    [self.view sendSubviewToBack:currentImageView];
//    return currentImageView;
//}

- (void)panDrop
{
    if ([[MCTouchDotViewController sharedApplication] allHiddenNow] == YES)
    {
        [MCTouchDotViewController showMCTouchDot];
    }
    
}
- (void)tapAction:(UITapGestureRecognizer *)sender
{
    NSLog(@"touched");
    [self sendFirebaseEvent];
    if ([[MCTouchDotViewController sharedApplication] allHiddenNow] != YES)
    {
        [MCTouchDotViewController hiddenMCTouchDot];
    }
    
    //    [theWkWebView evaluateJavaScript:@"document.activeElement.blur()" completionHandler:nil];
    [theUIWebView stringByEvaluatingJavaScriptFromString:@"document.activeElement.blur()"];
    NSLog(@"UIDevice InterFace :%@\nStatusBarOrientation :%@",[self returnCurrectOrientationString:[[UIDevice currentDevice] orientation]],[self returnCurrectStatusBarOrientationString:[[UIApplication sharedApplication] statusBarOrientation]]);
    
    
    CGPoint point = [sender locationInView:self.view];
    NSLog(@"point :%@",NSStringFromCGPoint(point));
    NSLog(@"window level :%f",self.view.window.windowLevel);
}
- (void)keyboardDidChangeFrame:(NSNotification *)aNotification
{
    CGRect keyboardFrames = [[[aNotification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSLog(@"keyboardDidChange Frame :%@",NSStringFromCGRect(keyboardFrames));
    
}
- (void)keyboardDidHide:(NSNotification *)aNotification
{
    CGRect keyboardFrames = [[[aNotification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSLog(@"keyboardDidHide Frames :%@",NSStringFromCGRect(keyboardFrames));
}

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    CGRect keyboardFrame = [[[aNotification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect convertedFrame = [self.view convertRect:keyboardFrame fromView:self.view.window];
    NSLog(@"keyboardFrame :%@",NSStringFromCGRect(keyboardFrame));
    NSLog(@"convertedFrame :%@",NSStringFromCGRect(convertedFrame));
    [self changeStatusbarOrientation];
}
- (void)keyboardDidShow:(NSNotification *)aNotification
{
    
}
- (void)changeDeviceOrientation
{
    NSLog(@"\nchangeDeviceOrientation");
    //    [theWkWebView stringByEvaluatingJavaScriptFromString:@"document.activeElement.blur()"];
    //    if ([[MCTouchDotViewController sharedApplication] allHiddenNow] == YES)
    //    {
    //        [MCTouchDotViewController showMCTouchDot];
    //    }
    [self changeStatusbarOrientation2];
}
- (void)changeStatusbarOrientation
{
    
    NSLog(@"\nchangeStatusbarOrientation");
    
    [self changeStatusbarOrientation2];
}
- (void)changeStatusbarOrientation2
{
    NSLog(@"\nchangeStatusbarOrientation2");
    //    NSString *currentOrient = [self returnCurrectSupportInterface:[self.view.window.rootViewController supportedInterfaceOrientations]];
    NSString *currentOrient = [self returnCurrectStatusBarOrientationString:[[UIApplication sharedApplication] statusBarOrientation]];
    NSString *currentDeviceOri = [self returnCurrectOrientationString:[[UIDevice currentDevice] orientation]];
    NSLog(@"\nCurrentInterFace :%@\nCurrentDeviceOri :%@",currentOrient,currentDeviceOri);
    if ([currentOrient isEqualToString:@"UIInterfaceOrientationPortrait"]|
        ([currentOrient isEqualToString:@"UIInterfaceOrientationUnknown"])|
        ([currentOrient isEqualToString:@"UIInterfaceOrientationPortraitUpsideDown"]))
    {
        //        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    }
    //    else if ([currentOrient isEqualToString:@"UIInterfaceOrientationMaskPortraitUpsideDown"])
    //    {
    //        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortraitUpsideDown animated:NO];
    //    }
    else if ([currentOrient isEqualToString:@"UIInterfaceOrientationLandscapeLeft"]
             //             |([currentOrient isEqualToString:@"UIInterfaceOrientationMaskLandscape"])
             )
    {
        
        //        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];
        if ([currentDeviceOri isEqualToString:@"UIDeviceOrientationLandscapeLeft"])
        {
            //            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft  animated:NO];
            [[UIDevice currentDevice] setValue:@(UIDeviceOrientationLandscapeLeft) forKey:@"orientation"];
        }else
        {
            //            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight  animated:NO];
            [[UIDevice currentDevice] setValue:@(UIDeviceOrientationLandscapeRight) forKey:@"orientation"];
        }
        
        //        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight  animated:NO];
        
        //        [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    }
    else if ([currentOrient isEqualToString:@"UIInterfaceOrientationLandscapeRight"])
    {
        //        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft  animated:NO];
        //        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeRight] forKey:@"orientation"];
        if ([currentDeviceOri isEqualToString:@"UIDeviceOrientationLandscapeRight"])
        {
            //            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight  animated:NO];
            [[UIDevice currentDevice] setValue:@(UIDeviceOrientationLandscapeRight) forKey:@"orientation"];
        }else
        {
            //            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft  animated:NO];
            [[UIDevice currentDevice] setValue:@(UIDeviceOrientationLandscapeLeft) forKey:@"orientation"];
        }
        
    }
    
}
- (NSString *)returnCurrectSupportInterface:(UIInterfaceOrientationMask)orientation
{
    switch (orientation)
    {
        case UIInterfaceOrientationMaskPortrait:
            return @"UIInterfaceOrientationMaskPortrait";
            break;
        case UIInterfaceOrientationMaskLandscapeLeft:
            return @"UIInterfaceOrientationMaskLandscapeLeft";
            break;
        case UIInterfaceOrientationMaskLandscapeRight:
            return @"UIInterfaceOrientationMaskLandscapeRight";
            break;
        case UIInterfaceOrientationMaskPortraitUpsideDown:
            return @"UIInterfaceOrientationMaskPortraitUpsideDown";
            break;
        case UIInterfaceOrientationMaskLandscape:
            return @"UIInterfaceOrientationMaskLandscape";
            break;
        case UIInterfaceOrientationMaskAll:
            return @"UIInterfaceOrientationMaskAll";
            break;
        case UIInterfaceOrientationMaskAllButUpsideDown:
            return @"UIInterfaceOrientationMaskAllButUpsideDown";
            break;
            
        default:
            return @"UIDeviceOrientationUnknown";
            break;
    }
}
- (NSString *)returnCurrectOrientationString:(UIDeviceOrientation)orientation
{
    switch (orientation)
    {
        case UIDeviceOrientationUnknown:
            return @"UIDeviceOrientationUnknown";
            break;
        case UIDeviceOrientationPortrait:
            return @"UIDeviceOrientationPortrait";
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            return @"UIDeviceOrientationPortraitUpsideDown";
            break;
        case UIDeviceOrientationLandscapeLeft:
            return @"UIDeviceOrientationLandscapeLeft";
            break;
        case UIDeviceOrientationLandscapeRight:
            return @"UIDeviceOrientationLandscapeRight";
            break;
        case UIDeviceOrientationFaceUp:
            return @"UIDeviceOrientationFaceUp";
            break;
        case UIDeviceOrientationFaceDown:
            return @"UIDeviceOrientationFaceDown";
            break;
            
        default:
            return @"UIDeviceOrientationUnknown";
            break;
    }
}
- (NSString *)returnCurrectStatusBarOrientationString:(UIInterfaceOrientation)orientation
{
    switch (orientation)
    {
        case UIInterfaceOrientationUnknown:
            return @"UIInterfaceOrientationUnknown";
            break;
        case UIInterfaceOrientationPortrait:
            return @"UIInterfaceOrientationPortrait";
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            return @"UIInterfaceOrientationPortraitUpsideDown";
            break;
        case UIInterfaceOrientationLandscapeLeft:
            return @"UIInterfaceOrientationLandscapeLeft";
            break;
        case UIInterfaceOrientationLandscapeRight:
            return @"UIInterfaceOrientationLandscapeRight";
            break;
            
        default:
            return @"UIInterfaceOrientationUnknown";
            break;
    }
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
- (void)createWKWebView
{
    
    WKWebViewConfiguration *newConfiguration = [[WKWebViewConfiguration alloc] init];
    if (CURRENT_DEV_Version>=8.0)
    {
        BOOL quackActionPlay;
        if ([[MCInfoObject sharedInstance] quickActionPlay] == YES)
        {
            quackActionPlay = YES;
            [newConfiguration setMediaPlaybackRequiresUserAction:NO];
        }
        else
        {
            quackActionPlay = NO;
            [newConfiguration setMediaPlaybackRequiresUserAction:YES];
        }
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 100000
        [newConfiguration setMediaTypesRequiringUserActionForPlayback:WKAudiovisualMediaTypeAll];
#elif __IPHONE_OS_VERSION_MIN_REQUIRED >= 90000
        [newConfiguration setAllowsPictureInPictureMediaPlayback:YES];
        //        [newConfiguration setRequiresUserActionForMediaPlayback:YES];
        [newConfiguration setAllowsAirPlayForMediaPlayback:YES];
#else
        //        [newConfiguration setMediaPlaybackRequiresUserAction:YES];
        [newConfiguration setMediaPlaybackAllowsAirPlay:YES];
#endif
        
        //#endif
    }
    [newConfiguration setAllowsInlineMediaPlayback:YES];
    
    theWkWebView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:newConfiguration];
    theWkWebView.navigationDelegate = self;
    theWkWebView.allowsBackForwardNavigationGestures = YES;
    [[theWkWebView scrollView] setDelegate:self];
    UITapGestureRecognizer *webViewTapped = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self
                                             action:@selector(tapAction:)];
    webViewTapped.numberOfTapsRequired = 1;
    webViewTapped.delegate = self;
    [theWkWebView addGestureRecognizer:webViewTapped];
    
    UIPanGestureRecognizer *panDrop = [[UIPanGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(panDrop)];
    [theWkWebView addGestureRecognizer:panDrop];
    
    theWkWebView.alpha = 1.0;
    [theWkWebView setAccessibilityIdentifier:@"theWKWebView"];
    [self.view addSubview:theWkWebView];
}
- (void)createUIWebView
{
    theUIWebView = [[UIWebView alloc] initWithFrame:self.view.frame];
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 90000
    theUIWebView.allowsPictureInPictureMediaPlayback = YES;
#else
    
#endif
    
    if ([[MCInfoObject sharedInstance] quickActionPlay] == YES)
    {
        
        [theUIWebView setMediaPlaybackRequiresUserAction:NO];
    }else
    {
        
        [theUIWebView setMediaPlaybackRequiresUserAction:YES];
    }
    
    theUIWebView.allowsInlineMediaPlayback = YES;
    theUIWebView.delegate = self;
    UITapGestureRecognizer *webViewTapped = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self
                                             action:@selector(tapAction:)];
    webViewTapped.numberOfTapsRequired = 1;
    webViewTapped.delegate = self;
    [theUIWebView addGestureRecognizer:webViewTapped];
    
    UIPanGestureRecognizer *panDrop = [[UIPanGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(panDrop)];
    [theUIWebView addGestureRecognizer:panDrop];
    
    theUIWebView.alpha = 1.0;
    [theUIWebView setAccessibilityIdentifier:@"theUIWebView"];
    
    [self.view addSubview:theUIWebView];
}
- (NSString *)urlencode:(NSString *)theString
{
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[theString UTF8String];
    unsigned long sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

- (BOOL) si_IsAvailableNetworkWithCompleteBlock:(void (^)(bool is3GActive))completeBlock
{
    // 0.0.0.0
#if (defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __IPHONE_OS_VERSION_MIN_REQUIRED >= 90000) || (defined(__MAC_OS_X_VERSION_MIN_REQUIRED) && __MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)
    struct sockaddr_in6 zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin6_len = sizeof(zeroAddress);
    zeroAddress.sin6_family = AF_INET6;
#else
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
#endif
    // Reachability flag
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr*)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    if (!didRetrieveFlags) {
        NSLog(@"Error");
        return 0;
    }
    
    // ネットワークフラグ
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    BOOL nonWifi = flags & kSCNetworkReachabilityFlagsTransientConnection;
    BOOL is3G = flags & kSCNetworkReachabilityFlagsIsWWAN;
    if (((isReachable && !needsConnection) || nonWifi) ? YES : NO)
    {
        NSLog(@"NetConnectionSuccess");
        if (completeBlock)
        {
            if (is3G == YES)
            {
                completeBlock(YES);
            }else
            {
                completeBlock(NO);
            }
        }
        
    }else
    {
        NSLog(@"NetConnectionFailure");
    }
    
    return ((isReachable && !needsConnection) || nonWifi) ? YES : NO;
}
- (void) touchesBegan:(NSSet *) touches withEvent:(UIEvent *) event
{
    NSLog(@"ViewController 開始點");
}
- (void) touchesEnded:(NSSet *) touches withEvent:(UIEvent *) event
{
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //    NSLog(@"theWkWebView Y :%f",[[theWkWebView scrollView] contentOffset].y);
    //    NSLog(@"scrollView Y :%f",[scrollView contentOffset].y);
    [self animationWith:[scrollView contentOffset].y*4];
}
- (void)animationWith:(CGFloat)y
{
    CGFloat flag = theWkWebView.frame.origin.y * 2.f - 20.f;
    if (y < flag)
    {
        if (self.eyeFirstLightLayer.lineWidth < 5.f)
        {
            NSLog(@"1");
            self.eyeFirstLightLayer.lineWidth += 1.f;
            self.eyeSecondLightLayer.lineWidth += 1.f;
        }
    }
    
    if(y < flag - 20)
    {
        if (self.eyeballLayer.opacity <= 1.0f)
        {
            NSLog(@"2");
            self.eyeballLayer.opacity += 0.1f;
        }
        
    }
    
    if (y < flag - 40)
    {
        if (self.topEyesocketLayer.strokeEnd < 1.f && self.topEyesocketLayer.strokeStart > 0.f)
        {
            NSLog(@"3");
            self.topEyesocketLayer.strokeEnd += 0.1f;
            self.topEyesocketLayer.strokeStart -= 0.1f;
            self.bottomEyesocketLayer.strokeEnd += 0.1f;
            self.bottomEyesocketLayer.strokeStart -= 0.1f;
        }
    }
    
    if (y > flag - 40)
    {
        if (self.topEyesocketLayer.strokeEnd > 0.5f && self.topEyesocketLayer.strokeStart < 0.5f)
        {
            NSLog(@"4");
            self.topEyesocketLayer.strokeEnd -= 0.1f;
            self.topEyesocketLayer.strokeStart += 0.1f;
            self.bottomEyesocketLayer.strokeEnd -= 0.1f;
            self.bottomEyesocketLayer.strokeStart += 0.1f;
        }
    }
    
    if (y > flag - 20)
    {
        if (self.eyeballLayer.opacity >= 0.0f)
        {
            NSLog(@"5");
            self.eyeballLayer.opacity -= 0.1f;
        }
    }
    
    if (y > flag)
    {
        if (self.eyeFirstLightLayer.lineWidth > 0.f)
        {
            NSLog(@"6");
            self.eyeFirstLightLayer.lineWidth -= 1.f;
            self.eyeSecondLightLayer.lineWidth -= 1.f;
        }
    }
}

- (CAShapeLayer *)eyeFirstLightLayer
{
    if (!_eyeFirstLightLayer) {
        _eyeFirstLightLayer = [CAShapeLayer layer];
        CGPoint center = CGPointMake(CGRectGetWidth(theWkWebView.frame) / 2, CGRectGetHeight(theWkWebView.frame) / 2);
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center
                                                            radius:CGRectGetWidth(theWkWebView.frame) * 0.05
                                                        startAngle:(230.f / 180.f) * M_PI
                                                          endAngle:(265.f / 180.f) * M_PI
                                                         clockwise:YES];
        _eyeFirstLightLayer.borderColor = [UIColor blackColor].CGColor;
        _eyeFirstLightLayer.lineWidth = 5.f;
        _eyeFirstLightLayer.path = path.CGPath;
        _eyeFirstLightLayer.fillColor = [UIColor clearColor].CGColor;
        _eyeFirstLightLayer.strokeColor = [UIColor whiteColor].CGColor;
    }
    return _eyeFirstLightLayer;
}

- (CAShapeLayer *)eyeSecondLightLayer
{
    if (!_eyeSecondLightLayer) {
        _eyeSecondLightLayer = [CAShapeLayer layer];
        CGPoint center = CGPointMake(CGRectGetWidth(theWkWebView.frame) / 2, CGRectGetHeight(theWkWebView.frame) / 2);
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center
                                                            radius:CGRectGetWidth(theWkWebView.frame) * 0.05
                                                        startAngle:(211.f / 180.f) * M_PI
                                                          endAngle:(220.f / 180.f) * M_PI
                                                         clockwise:YES];
        _eyeSecondLightLayer.borderColor = [UIColor blackColor].CGColor;
        _eyeSecondLightLayer.lineWidth = 5.f;
        _eyeSecondLightLayer.path = path.CGPath;
        _eyeSecondLightLayer.fillColor = [UIColor clearColor].CGColor;
        _eyeSecondLightLayer.strokeColor = [UIColor whiteColor].CGColor;
        
    }
    return _eyeSecondLightLayer;
}

- (CAShapeLayer *)eyeballLayer
{
    if (!_eyeballLayer) {
        _eyeballLayer = [CAShapeLayer layer];
        CGPoint center = CGPointMake(CGRectGetWidth(theWkWebView.frame) / 2, CGRectGetHeight(theWkWebView.frame) / 2);
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center
                                                            radius:CGRectGetWidth(theWkWebView.frame) * 0.075
                                                        startAngle:(0.f / 180.f) * M_PI
                                                          endAngle:(360.f / 180.f) * M_PI
                                                         clockwise:YES];
        _eyeballLayer.borderColor = [UIColor blackColor].CGColor;
        _eyeballLayer.lineWidth = 1.f;
        _eyeballLayer.path = path.CGPath;
        _eyeballLayer.fillColor = [UIColor clearColor].CGColor;
        _eyeballLayer.strokeColor = [UIColor whiteColor].CGColor;
        _eyeballLayer.anchorPoint = CGPointMake(0.5, 0.5);
        
    }
    return _eyeballLayer;
}

- (CAShapeLayer *)topEyesocketLayer
{
    if (!_topEyesocketLayer) {
        _topEyesocketLayer = [CAShapeLayer layer];
        CGPoint center = CGPointMake(CGRectGetWidth(theWkWebView.frame) / 2, CGRectGetHeight(theWkWebView.frame) / 2);
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(0, CGRectGetHeight(theWkWebView.frame) / 2)];
        [path addQuadCurveToPoint:CGPointMake(CGRectGetWidth(theWkWebView.frame), CGRectGetHeight(theWkWebView.frame) / 2)
                     controlPoint:CGPointMake(CGRectGetWidth(theWkWebView.frame) / 2, center.y - center.y - 20)];
        
        _topEyesocketLayer.borderColor = [UIColor blackColor].CGColor;
        _topEyesocketLayer.lineWidth = 1.f;
        _topEyesocketLayer.path = path.CGPath;
        _topEyesocketLayer.fillColor = [UIColor clearColor].CGColor;
        _topEyesocketLayer.strokeColor = [UIColor whiteColor].CGColor;
    }
    return _topEyesocketLayer;
}

- (CAShapeLayer *)bottomEyesocketLayer
{
    if (!_bottomEyesocketLayer) {
        _bottomEyesocketLayer = [CAShapeLayer layer];
        CGPoint center = CGPointMake(CGRectGetWidth(theWkWebView.frame) / 2, CGRectGetHeight(theWkWebView.frame) / 2);
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(0, CGRectGetHeight(theWkWebView.frame) / 2)];
        [path addQuadCurveToPoint:CGPointMake(CGRectGetWidth(theWkWebView.frame), CGRectGetHeight(theWkWebView.frame) / 2)
                     controlPoint:CGPointMake(CGRectGetWidth(theWkWebView.frame) / 2, center.y + center.y + 20)];
        _bottomEyesocketLayer.borderColor = [UIColor blackColor].CGColor;
        _bottomEyesocketLayer.lineWidth = 1.f;
        _bottomEyesocketLayer.path = path.CGPath;
        _bottomEyesocketLayer.fillColor = [UIColor clearColor].CGColor;
        _bottomEyesocketLayer.strokeColor = [UIColor whiteColor].CGColor;
        
    }
    return _bottomEyesocketLayer;
}
- (NSString *)prepareToUpload
{
    NSString *jsonStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:songListArray options:kNilOptions error:nil] encoding:NSUTF8StringEncoding];
    // 转JSON的过程中，会遇到字符转义方面的问题，很恶心。多亏了看到这篇文章，才得以解决问题
    // http://blog.csdn.net/robotech_er/article/details/40260377
    jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"\\n" withString:@"<br>"];
    jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\\\\\""];
    // vm._getContent:拿到JS方法，上传jsonStr
    NSString *textJS = [NSString stringWithFormat:@"'%@'",jsonStr];
    
    NSLog(@"看看歌單裡面有什麼:\n%@",textJS);
    return textJS;
}
#pragma mark WKWebview
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSLog(@"decidePolicyForNavigationAction");
    
    if (!webView.tag)
    {
        webView.tag = 1;
        
    }else
    {
        webView.tag += 1;
    }
    NSLog(@"wwkebView.tag :%ld",(long)webView.tag);
    NSLog(@"request :%@",navigationAction.request);
    NSError *error;
    NSString *responseString = [NSString stringWithContentsOfURL:navigationAction.request.URL
                                                        encoding:NSUTF8StringEncoding
                                                           error:&error];
    NSLog(@"responseString :%@",responseString);
    
    if (responseString)
    {
        NSArray *responseData = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        NSLog(@"responseData json :%@",responseData);
        if ([[[responseData firstObject] allKeys] containsObject:@"lists"])
        {
            //利用 webview 的執行方法
            NSLog(@"responseData allkey :%@",[[responseData firstObject] allKeys]);
            tableviewcontroller.responseDataFormWeb = [responseData mutableCopy];
            [self presentViewController:tableviewcontroller animated:YES completion:nil];
            decisionHandler(WKNavigationActionPolicyCancel);
        }else if (([responseData count] <1 ) && ([responseString isEqualToString:@"[]"]))
        {
            
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Message"
                                          message:@"歌單為空"
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction *action)
                                       {
                                           [alert dismissViewControllerAnimated:YES completion:nil];
                                       }];
            [alert addAction:okAction];
            
            [self presentViewController:alert animated:YES completion:nil];
            
            decisionHandler(WKNavigationActionPolicyCancel);
        }
        
        
    }
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated)
    {
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    NSLog(@"didStartProvisionalNavigation");
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    NSLog(@"didCommitNavigation");
}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    NSLog(@"didFinishNavigation");
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation
{
    NSLog(@"didFailProvisionalNavigation");
}
#pragma mark UIWebview
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (!webView.tag)
    {
        webView.tag = 1;
        
    }else
    {
        webView.tag += 1;
    }
    NSLog(@"完成 shouldStartLoadWithRequest");
    NSLog(@"webView.tag :%ld",(long)webView.tag);
    NSLog(@"webView request :%@",request);
    NSError *error;
    NSString *responseString = [NSString stringWithContentsOfURL:request.URL
                                                        encoding:NSUTF8StringEncoding
                                                           error:&error];
    
    NSLog(@"webView responseString :%@",responseString);
    NSArray *responseData = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    NSLog(@"webView responseData json :%@",responseData);
    if ([[[responseData firstObject] allKeys] containsObject:@"lists"])
    {
        // 利用javescript
        //        JSContext *jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
        //        jsContext.exceptionHandler = ^(JSContext* context, JSValue* exceptionValue) {
        //            context.exception = exceptionValue;
        //            NSLog(@"异常信息：%@", exceptionValue);
        //        };
        //
        //
        //        [jsContext evaluateScript:[self prepareToUpload]];
        
        tableviewcontroller.responseDataFormWeb = [responseData mutableCopy];
        [self presentViewController:tableviewcontroller animated:YES completion:nil];
        return NO;
    }
    else if (([responseData count] <1 ) && ([responseString isEqualToString:@"[]"]))
    {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Message"
                                      message:@"歌單為空"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action)
                                   {
                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                   }];
        [alert addAction:okAction];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"開始 StartLoad :%ld",(long)webView.tag);
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //    NSString* jsString = @"localStorage.removeItem('play_list');";
    //    NSString* someKeyValue = [webView stringByEvaluatingJavaScriptFromString: jsString];
    //    if(someKeyValue == nil || [someKeyValue isEqual: @""]){
    //        NSString *str = @"hogehoge";
    //        [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@.setItem('%@', '%@');", @"localStorage", @"key", str]];
    //        [_webView reload];
    //    }
    
    NSLog(@"完成 DidFinishLoad :%ld",(long)webView.tag);
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"下載失敗 didFailLoadWithError");
}
#pragma mark SOP Alert
- (void)callSOPAlert
{
    if (!neverShowAlert)
    {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"歌單儲存完成"
                                      message:@"匯入歌單流程\n1.請點擊右上角匯入歌單\n2.選擇 iCloud Drive\n3.選擇iCDlist 資料夾\n4.選擇最接近當前時間的檔案\n格式為PL_hhmmss.txt\n5.如欲刪除,請至主畫面iCloud Drive App內動作"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action)
                                   {
                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                   }];
        UIAlertAction *nerverShowAction = [UIAlertAction actionWithTitle:@"不再顯示"
                                                                   style:UIAlertActionStyleDestructive
                                                                 handler:^(UIAlertAction *action)
                                           {
                                               neverShowAlert = YES;
                                               [alert dismissViewControllerAnimated:YES completion:nil];
                                           }];
        UIAlertAction *downloadAction = [UIAlertAction actionWithTitle:@"iCloud下載"
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction *action)
                                         {
                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                             [theUIWebView stringByEvaluatingJavaScriptFromString:@"upload()"];
                                             //                                                [theWkWebView evaluateJavaScript:@"upload()" completionHandler:nil];
                                         }];
        [alert addAction:okAction];
        [alert addAction:downloadAction];
        [alert addAction:nerverShowAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
- (void)gotoDetailVc:(NSNotification *)aNotification
{
    shortCutItemCall = YES;
    NSLog(@"\ntype :%@",[[aNotification userInfo] objectForKey:@"type"]);
    
    [self setUpView];
    
    [theUIWebView setMediaPlaybackRequiresUserAction:NO];
    [theUIWebView reload];
    
    //    theWkWebView.configuration.mediaPlaybackRequiresUserAction = NO;
    //    [theWkWebView reload];
}
- (UIViewController*) mcs_TopViewController
{
    return [self mcs_TopViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController*) mcs_TopViewControllerWithRootViewController:(UIViewController*)rootViewController
{
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self mcs_TopViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self mcs_TopViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self mcs_TopViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}
- (void)sendFirebaseEvent
{
    [FIRAnalytics logEventWithName:kFIREventSelectContent
                        parameters:@{
                                     kFIRParameterItemID:[NSString stringWithFormat:@"id-%@", @"123"],
                                     kFIRParameterItemName:@"網頁被點擊",
                                     kFIRParameterContentType:@"webview"
                                     }];
}
@end
