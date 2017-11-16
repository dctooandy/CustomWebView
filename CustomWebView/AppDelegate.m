//
//  AppDelegate.m
//  CustomWebView
//
//  Created by AndyChen on 2016/11/9.
//  Copyright © 2016年 AndyChen. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <WebKit/WebKit.h>
#import "Constant_m.h"
#import "Firebase.h"
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

@import UserNotifications;
#endif
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
//@interface AppDelegate ()<UNUserNotificationCenterDelegate,FIRMessagingDelegate>
@interface AppDelegate ()<UNUserNotificationCenterDelegate>
@end
#endif
#ifndef NSFoundationVersionNumber_iOS_9_x_Max
#define NSFoundationVersionNumber_iOS_9_x_Max 1299
#endif
@implementation AppDelegate
NSString *const kGCMMessageIDKey = @"gcm.message_id";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [application setStatusBarHidden:YES];
    if (launchOptions[@"UIApplicationLaunchOptionsShortcutItemKey"])
    {
        [self quickActionSet];
    }
    
    NSLog(@"Device Name :%@",[[UIDevice currentDevice] name]);
    BOOL result =YES;
    [self loadSetting];
    [self setNotification];
    [self setAudioSession];
    
    [FIRApp configure];
//    [FIRMessaging messaging].delegate = self;
//    FIRCrashLog(@"Cause Crash button clicked");
    
#if defined(__IPHONE_9_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
    
    if (CURRENT_DEV_Version >=9.0)
    {
        NSArray* items = [UIApplication sharedApplication].shortcutItems;
        
        if(items.count==0)
        {
            [self setShortCutItem];
        }
        if (launchOptions[@"UIApplicationLaunchOptionsShortcutItemKey"] == nil)
        {
            result = YES;
        }
        else
        {
            result = NO;
        }
        return result;
    }else
    {
        return result;
    }
#else
    
    return result;
    
#endif
    
    
    
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window
{
//    NSUInteger orientations = UIInterfaceOrientationMaskAllButUpsideDown;

//    if(self.window.rootViewController)
//    {
//        UIViewController *presentedViewController = [[(UINavigationController *)self.window.rootViewController viewControllers] lastObject];
//        orientations = [presentedViewController supportedInterfaceOrientations];
//    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        return UIInterfaceOrientationMaskAll;
    else
        return UIInterfaceOrientationMaskAllButUpsideDown;


//    return orientations;
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    NSLog(@"applicationWillResignActive");
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"applicationDidEnterBackground");
    //    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:NULL];
    //    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    NSLog(@"applicationWillEnterForeground");
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"applicationDidBecomeActive");
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"applicationWillTerminate");
}

- (void)setAudioSession
{
    //    NSError *error;
    //    BOOL isAudioOK = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
    //                                                      withOptions:AVAudioSessionCategoryOptionMixWithOthers
    //                                                            error:&error];
    //    if (!isAudioOK)
    //    {
    //        NSLog(@"Cause Error :%@",error.description);
    //    }
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    BOOL ok;
    NSError *setCategoryError = nil;
    NSError *activationError = nil;
    ok =[audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
    //    ok =[audioSession setCategory:AVAudioSessionCategoryMultiRoute mode:AVAudioSessionModeDefault options:AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers error:&setCategoryError];
    //     [audioSession setCategory:AVAudioSessionCategoryAmbient withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&setCategoryError];
    [audioSession setActive: YES error: &activationError];
    if (!ok) {
        NSLog(@"%s setCategoryError=%@", __PRETTY_FUNCTION__, setCategoryError);
    }
    //    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioDidChangeStatus:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:audioSession];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioDidChangeStatus:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:audioSession];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioDidChangeStatus:)
                                                 name:AVAudioSessionMediaServicesWereLostNotification
                                               object:audioSession];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioDidChangeStatus:)
                                                 name:AVAudioSessionMediaServicesWereResetNotification
                                               object:audioSession];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playWebAudio)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioDidChangeStatus:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
}

-(void)audioDidChangeStatus:(NSNotification *)notification
{
    NSLog(@"allKeys :%@",[notification userInfo]);
    //    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    AVAudioSessionInterruptionType type = [notification.userInfo[AVAudioSessionInterruptionTypeKey] intValue];
    if (type == AVAudioSessionInterruptionTypeBegan)
    {
        //        [self.player pause];
    } else
    {
        //        [self.player play];
    }
    
}
- (void)playWebAudio
{
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:NULL];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    if (self.backplay == YES)
    {
        UIWindow * subWindow;
        //    UIWebView * currentWebview;
        for (subWindow in [[UIApplication sharedApplication] windows])
        {
            if ([subWindow.rootViewController isKindOfClass:[ViewController class]])
            {
                for (UIWebView * theWebview in subWindow.rootViewController.view.subviews)
                {
                    if ([theWebview.accessibilityIdentifier isEqualToString:@"theUIWebView"])
                    {
                        //                    currentWebview = theWebview;
                        if ([[AVAudioSession sharedInstance] isOtherAudioPlaying] == YES)
                        {
                            NSLog(@"正在播放");
                        }else
                        {
                            NSLog(@"沒有播放");
                        }
                        
                        [theWebview stringByEvaluatingJavaScriptFromString:@"play()"];
                        break;
                    }
                }
                //                for (WKWebView * theWebview in subWindow.rootViewController.view.subviews)
                //                {
                //                    if ([theWebview.accessibilityIdentifier isEqualToString:@"theWKWebView"])
                //                    {
                //                        //                    currentWebview = theWebview;
                //                        if ([[AVAudioSession sharedInstance] isOtherAudioPlaying] == YES)
                //                        {
                //                            NSLog(@"正在播放");
                //                        }else
                //                        {
                //                            NSLog(@"沒有播放");
                //                        }
                //                        [theWebview evaluateJavaScript:@"play()" completionHandler:nil];
                //                        break;
                //                    }
                //                }
            }
        }
    }
    
}
- (void)setNotification
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
        UIUserNotificationType allNotificationTypes =
        (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    } else {
        // iOS 10 or later
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
        // For iOS 10 display notification (sent via APNS)
        //        [NSNotificationCenter currentNotificationCenter].delegate = self;
        //        UNAuthorizationOptions authOptions =
        //        UNAuthorizationOptionAlert
        //        | UNAuthorizationOptionSound
        //        | UNAuthorizationOptionBadge;
        //        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError * _Nullable error) {
        //        }];
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
        UNAuthorizationOptions authOptions =
        UNAuthorizationOptionAlert
        | UNAuthorizationOptionSound
        | UNAuthorizationOptionBadge;
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError * _Nullable error) {
        }];
#endif
    }
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}
// [START receive_message]
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    
    // With swizzling disabled you must let Messaging know about the message, for Analytics
    //    [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
    //
    //    // Print message ID.
    //    if (userInfo[kGCMMessageIDKey]) {
    //        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    //    }
    
    // Print full message.
    NSLog(@"%@", userInfo);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    
    // With swizzling disabled you must let Messaging know about the message, for Analytics
    //    [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
    //
    //    // Print message ID.
    //    if (userInfo[kGCMMessageIDKey]) {
    //        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    //    }
    
    // Print full message.
    NSLog(@"\nuserInfo 0 \n%@", userInfo);
    
    //    completionHandler(UIBackgroundFetchResultNewData);
}
// [END receive_message]

// [START ios_10_message_handling]
// Receive displayed notifications for iOS 10 devices.
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
// Handle incoming notification messages while app is in the foreground.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    NSDictionary *userInfo = notification.request.content.userInfo;
    
    // With swizzling disabled you must let Messaging know about the message, for Analytics
    //    [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
    //
    //    // Print message ID.
    //    if (userInfo[kGCMMessageIDKey]) {
    //        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    //    }
    
    // Print full message.
    NSLog(@"\nuserInfo 1 \n%@", userInfo);
    
    // Change this to your preferred presentation option
    completionHandler(UNNotificationPresentationOptionNone);
}

// Handle notification messages after display notification is tapped by the user.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)())completionHandler
{
    //    NSDictionary *userInfo = response.notification.request.content.userInfo;
    //    if (userInfo[kGCMMessageIDKey]) {
    //        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    //    }
    //
    //    // Print full message.
    //    NSLog(@"%@", userInfo);
    
    completionHandler();
}
#endif
// [END ios_10_message_handling]

// [START refresh_token]
- (void)messaging:(nonnull FIRMessaging *)messaging didRefreshRegistrationToken:(nonnull NSString *)fcmToken
{
//    // Note that this callback will be fired everytime a new token is generated, including the first
//    // time. So if you need to retrieve the token as soon as it is available this is where that
//    // should be done.
    NSLog(@"FCM registration token: %@", fcmToken);
//
    // TODO: If necessary send token to application server.
}
// [END refresh_token]

// [START ios_10_data_message]
// Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
// To enable direct data messages, you can set [Messaging messaging].shouldEstablishDirectChannel to YES.
//- (void)messaging:(FIRMessaging *)messaging didReceiveMessage:(FIRMessagingRemoteMessage *)remoteMessage
//{
//    NSLog(@"Received data message: %@", remoteMessage.appData);
//}
// [END ios_10_data_message]

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Unable to register for remote notifications: %@", error);
}

// This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
// If swizzling is disabled then this function must be implemented so that the APNs device token can be paired to
// the FCM registration token.
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"APNs device token retrieved: %@", deviceToken);
    
    // With swizzling disabled you must set the APNs device token here.
//    FIRCrashLog(@"Cause Crash button clicked");
//    assert(NO);
        [FIRMessaging messaging].APNSToken = deviceToken;
}
- (void)loadSetting
{
    //模擬 client 存入 relogin key 的方式
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
    NSString *documentsDirectory = [paths objectAtIndex:0]; //2
    self.setingPlistPath = [documentsDirectory stringByAppendingPathComponent:@"setting.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: self.setingPlistPath]) //4
    {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"setting" ofType:@"plist"]; //5
        
        [fileManager copyItemAtPath:bundle toPath:self.setingPlistPath error:&error]; //6
    }
    
    self.settingPlistData = [[NSMutableDictionary alloc] initWithContentsOfFile: self.setingPlistPath];
    if(self.settingPlistData)
    {
        NSLog(@"settingData Initial ok!!");
        self.backplay = [[self.settingPlistData objectForKey:@"BackPlay"] boolValue];
    }
}
- (void)setBackplay:(BOOL)backplay
{
    _backplay = backplay;
    [self writeDataToDocu];
}
- (void)writeDataToDocu
{
    if(self.settingPlistData)
    {
        [self.settingPlistData setObject:[NSNumber numberWithBool:self.backplay] forKey:@"BackPlay"];
        [self.settingPlistData writeToFile:self.setingPlistPath atomically:YES];
        
        
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"背景執行開關"
                                      message:[NSString stringWithFormat:@"背景播放 :%@",(!self.backplay?@"關閉":@"開啟")]
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action)
                                   {
                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                   }];
        [alert addAction:okAction];
        
        [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
    }
}
#if defined(__IPHONE_9_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
- (void)setShortCutItem
{
    UIApplicationShortcutItem * item = [[UIApplicationShortcutItem alloc] initWithType:@"directPlay"
                                                                        localizedTitle:@"直接播放"
                                                                     localizedSubtitle:@"免點畫面"
                                                                                  icon:[UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypePlay] userInfo:nil];
    
    [UIApplication sharedApplication].shortcutItems = @[item];
}
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void(^)(BOOL succeeded))completionHandler
{
    [self quickActionSet];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Notice3DTouch"
                                                        object:self
                                                      userInfo:@{ @"type" : shortcutItem.type }];
}
- (void)quickActionSet
{
    [[MCInfoObject sharedInstance] setQuickActionPlay:YES];
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"背景直接播放"
                                  message:@"正要打開"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action)
                               {
                                   [alert dismissViewControllerAnimated:YES completion:nil];
                               }];
    [alert addAction:okAction];
    
    [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
}
#endif
@end
