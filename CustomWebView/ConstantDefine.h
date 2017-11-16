//
//  ConstantDefine.h
//  ISGlobalSDK
//
//  Created by AndyChen on 2016/12/27.
//  Copyright © 2016年 AndyChen. All rights reserved.
//

// Name
#define GlobalSDKVersion                    @"2.2.0"

#define FV                                  @"fv"
//#define FBFirstLoginBehavior                FBSDKLoginBehaviorSystemAccount
//#define FBSecondLoginBehavior               FBSDKLoginBehaviorWeb
#define FBFirstLoginBehavior                FBSDKLoginBehaviorBrowser
#define FBSecondLoginBehavior               FBSDKLoginBehaviorBrowser
#define AFLCompleteKeyEvent                 @"event"
#define AFLCompleteKeyISguid                @"isguid"
#define AFLCompleteKeyFB_id                 @"fb_id"
#define AFLCompleteKeyData                  @"data"
#define TPFBEventRequestUserInfoList        @"Event_RequestUserInfo"
#define TPFBEventRequestFriendListWithAuth  @"Event_RequestFriendListWithAuth"


#define TPFBEventGetInviteFndList           @"Event_GetInviteFriendList"
#define TPFBEventFetchFriendInvitableToken  @"Event_FetchFriendInvitableToken"

#define TPFBEventInviteByFndList            @"FB_inviteViaFriendList"
#define TPFBEventAutoSharing                @"FB_autoSharing"
#define TPFBEventInvitationWithToken        @"FB_sendInvitationWithToken"
#define TPFBEventSendStory                  @"FB_sendStory"

#define TPFBShareEvent                      @"shareEvent"
#define StoreFileName                       @"css.cs"

// 客服 pop視窗用的事件
#define GWPopEvent_ServiceReport            @"Event_ServiceReport"
#define GWPopEvent_ShowGameNews             @"Event_ShowGameNews"
#define GWPopEvent_ShowGameActivity         @"Event_ShowGameActivity"

// SEL
#define TPGGLoginStatusSuccess              @"GS_GGLoginSuccess:"
#define TPGGLoginStatusCancel               @"GS_GGLoginCancel"
#define TPGGLoginStatusError                @"GS_GGLoginError:"
#define TPGGLogoutSuccess                   @"GS_GGLogoutSuccess"

#define TPFBLoginStatusSuccess              @"GS_FBLoginSuccess:"
#define TPFBLoginStatusCancel               @"GS_FBLoginCancel"
#define TPFBLoginStatusError                @"GS_FBLoginError:"
#define TPFBLogoutSuccess                   @"GS_FBLogoutSuccess"
#define TPLoginStatusSuccess                @"GS_LoginSuccess:"
#define TPLoginStatusFail                   @"GS_LoginFail:message:"
#define TPBindComplete                      @"GS_BindComplete:"
#define TPBindCompleteMsg                   @"GS_BindComplete:WithMsg:"
#define TPVaildProductID                    @"GS_VaildProductID:"
#define TPPurchaseSuccess                   @"GS_PurchaseSuccess:"
#define TPPurchaseFailure                   @"GS_PurchaseFailure:"
#define TPPurchaseResendSuccess             @"GS_PurchaseResendSuccess:"
#define TPPurchaseResendFailure             @"GS_PurchaseResendFailure:"
#define TPRestorePurchaseSuccess            @"GS_RestorePurchaseSuccess:"
#define TPRestorePurchaseFailure            @"GS_RestorePurchaseFailure:"

// URL
#define URLFBBind                           @"guestbinding.html"
#define URLFBLogin                          @"fb_guest.html"
#define URLGoogleBind                       @"guestbinding_codeV2.html"
#define URLGoogleLogin                      @"google_codeGuestV2.html"
// FastLogin 初次登入,還沒有確定帳號,需打回公司OAuth索取Account
#define URLFastLogin                        @"login_sdkguest.html"
#define URLFastTrueLogin                    @"guest_firstlogin.html"
#define URLFastReLogin                      @"guest_relogin.html"
// 已登入過,拿到Key之後的登入
#define URLFastReLoginByKey                 @"login_sdkrelogin_json.html"
// 檢查是否已綁定
#define URLCheckBing                        @"guestbinding_checkbinding.html"
// 檢查是否置換裝置
#define URLCheckChangeDevice                @"login_code.html"

// 金流
#define URLCheckProductID                   @"guestbinding_checkbinding.html"


// Functions
#define SCREEN_WIDTH                [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT               [[UIScreen mainScreen] bounds].size.height
#define SINGLETON                   [MCSingleton sharedInstance]
#define SReadString(x)              [[SINGLETON si_ReadFromKeyChain] objectForKey:(x)]
#define SRestoreError               [[SINGLETON si_ReadFromKeyChain] objectForKey:@"RestoreErrorString"]
#define IS_PHONE                    (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define TPFBDelegat                 [[TPFacebook sharedApplication] fbDelegate]
#define TPGGDelegat                 [[TPGoogle sharedApplication] ggDelegate]
#define CURRENT_DEV_Version         [[[UIDevice currentDevice] systemVersion] floatValue]

#define BundleShort                 [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SDK_Settings"]
#define InfoISEasyMode              [[BundleShort objectForKey:@"ISEasyMode"] boolValue]
#define InfoISDialogMode            [[BundleShort objectForKey:@"ISDialogMode"] boolValue]
#define InfoISLandscape             [[BundleShort objectForKey:@"GSLandscape"] boolValue]
#define ISEasyMode                  [[NSUserDefaults standardUserDefaults] boolForKey:@"IS_Easy"]
#define Debug_Log_Open              [[BundleShort objectForKey:@"Debug_Log_Open"] boolValue]
// SDK Settings
#define InfoISRedirectURI           [BundleShort objectForKey:@"RedirectURI"]
#define InfoISGameClientID          [BundleShort objectForKey:@"ISGameClientID"]
#define InfoISGameClientSecret      [BundleShort objectForKey:@"ISGameClientSecret"]
#define InfoISGameLocalize          [BundleShort objectForKey:@"ISGameLocalize"]
#define InfoISGameTestApi           [[BundleShort objectForKey:@"ISGameTestApi"]boolValue]
#define GS4Icon                     [[BundleShort objectForKey:@"GS_4Icons_Vension"] boolValue]
#define InfoIconCounts              [[BundleShort objectForKey:@"ISGameIconCounts"] intValue]

// For AppsFlyer
#define AppsFlyerDevKey                         \
[BundleShort objectForKey:@"AppsFlyerDevKey"]

#define AppleAppID                              \
[BundleShort objectForKey:@"AppleAppID"]

#define AFCurrencyCode                          \
[BundleShort objectForKey:@"AFCurrencyCode"]

#define AppsFlyerReceiptValidationSandbox       \
[[BundleShort objectForKey:@"AppsFlyerReceiptValidationSandbox"] boolValue]

#define AFDeviceTrackingDisabled                \
[[BundleShort objectForKey:@"AFDeviceTrackingDisabled"] boolValue]

// For GA
#define GATrackingId                [BundleShort objectForKey:@"GATrackingId"]
#define GoogleClientId              [BundleShort objectForKey:@"GoogleClientId"]

// For ADJust
#define ADJustAppToken              [BundleShort objectForKey:@"ADJustAppToken"]

// URL
// MCPolicy
#define POLICY_URL                  @"https://oauth.is520.com/privacy/index/sdk.html"

// MCServiceRule
#define ServiceRule_URL             @"https://oauth.is520.com/privacy/license/sdk.html"

// MCAccountView
#define GUEST_ACCOUNT               @"https://oauth.is520.com/guest_account.html"
#define GUEST_EMAILCHECK            @"https://oauth.is520.com/guest_emailcheck.html"

// MCPasswordForget
#define GUEST_FORGET                @"https://oauth.is520.com/guest_forget.html"

// MCGameWebView
#define GAMENEWS_URL                @"https://www.is520.com/api-SdkRedirect.html"
//#define SERVICE_REPORT_URL        @"https://www.is520.com/mobile-servicereport.html"
#define SERVICE_REPORT_URL          @"https://iservice.is520.com/faq.html"

// SCOauthServer
//#define SITE                      @"https://stage-oauth.is520.com/"
#define SITE                        @"https://oauth.is520.com/"
#define TestSITE                    @"https://test-oauth.is520.com/"
#define TrinaSITE                   @"https://trina-oauth.is520.com/"

#define CashSITE                    @"https://api.is520.com/sdk/payment/"
#define TestCashSITE                @"https://test-api.is520.com/sdk/payment/"
#define TrianCashSITE               @"https://trina-api.is520.com/sdk/payment/"

// SCApiAuth
#define SCApiAuthSITE               @"https://api.is520.com/AuthService.html"

// SCApiLog
#define SITE_logFbAppInvite         @"https://api.is520.com/log/sdk/fbappinvite.html"

// AssistiveTouch
#define SERVERSET                   @"https://oauth.is520.com/check/sdkset.html"
#define Test_SERVERSET              @"https://test-oauth.is520.com/check/sdkset.html"
#define Trina_SERVERSET             @"https://trina-oauth.is520.com/check/sdkset.html"

// Lite MCFunctionView
#define PUSHID_URL                  @"https://oauth.is520.com/deviceinfo_PushRegister.html"
#define URLUploadDeviceTokenPushRegister                  @"deviceinfo_PushRegister.html"
// 上傳device token用
#define URLUploadDeviceTokenInfo    @"deviceinfo.html"

// CheckAPI_URI
#define CheckAPI_URI                @"https://api.is520.com/sdk/info/apiList.html"
#define Test_CheckAPI_URI           @"https://test-api.is520.com/sdk/info/apiList.html"
#define Trina_CheckAPI_URI          @"https://trina-api.is520.com/sdk/info/apiList.html"

// GetProductID
#define ProductID_URL               @"https://d3l04kcslwxuao.cloudfront.net/sdk_payment/test/ios/5977532602474682368.json"
#define Test_ProductID_URL          @"https://d3l04kcslwxuao.cloudfront.net/sdk_payment/test/ios/5977532602474682368.json"
#define Trina_ProductID_URL         @"https://d3l04kcslwxuao.cloudfront.net/sdk_payment/test/ios/5977532602474682368.json"

// GetOnceToken 註冊使用者並取得接下來欲使用之交易令牌
#define OnceToken_URL               @"https://api.is520.com/sdk/payment/userRegister.html"
#define Test_OnceToken_URL          @"https://test-api.is520.com/sdk/payment/userRegister.html"
#define Trina_OnceToken_URL         @"https://trina-api.is520.com/sdk/payment/userRegister.html"

// Token Check 完成商店交易後提供伺服器端進行明細驗證與發送點數作業用
#define TokenCheck_URL              @"https://api.is520.com/sdk/payment/tokenCheck.html"
#define Test_TokenCheck_URL         @"https://test-api.is520.com/sdk/payment/tokenCheck.html"
#define Trina_TokenCheck_URL        @"https://trina-api.is520.com/sdk/payment/tokenCheck.html"

// FackOnceToken
#define FackOnceToken               @"fackOnceToken"


// GA
#define sessionTimeoutTimeIntervalDefault @"1800" // 30 * 60

// For IAP
#define TransTID                            @"TID"
#define TransPID                            @"PID"
#define TransError                          @"Error"
#define TransReceipt                        @"Receipt"
#define DirectTo_Test_Server                [[BundleShort objectForKey:@"DirectTo_Test_Server"] boolValue]
#define DirectTo_Trina_Server               [[BundleShort objectForKey:@"ISTrinaMode"] boolValue]


#define TheURL(x,y)                         (([[MCFunctionView sharedApplication] GSDirectToTest]==NO)?x:y)
#define TheTrinaURL(x,y)                    (([[MCFunctionView sharedApplication] GSDirectToTrina]==NO)?x:y)
#define TheLandscapeWidth(x,y)              ((x>y)?x:y)
#define TheLandscapeHeight(x,y)             ((x<y)?x:y)
#define ThePortraitWidth(x,y)               ((x<y)?x:y)
#define ThePortraitHeight(x,y)              ((x>y)?x:y)

#define IsContainsString(x,y)               [[NSString stringWithFormat:@"%@",x] rangeOfString:y].location
#define IsSpaceString(x)                    [x isEqualToString:@""]

// For EventTrack
#define EventTrack_Init                     @"APP_didFinishLaunchingWithOptions"
#define EventTrack_SaveNickName             @"APP_didFinishInitialCreateRole"
#define EventTrack_SetRevenue               @"APP_didFinishPurchase"

//#define EventTrack_InitForADJ               @"z12mlf"
//#define EventTrack_SaveNickNameForADJ		@"hu1nzn"
//#define EventTrack_SetRevenueForADJ         @"zi2iif"
#define EventTrack_InitForADJ               [BundleShort objectForKey:@"ADJEventToken_Init"]
#define EventTrack_SaveNickNameForADJ		[BundleShort objectForKey:@"ADJEventToken_SaveName"]
#define EventTrack_SetRevenueForADJ         [BundleShort objectForKey:@"ADJEventToken_SetRevenue"]

//大招
#define SLog(fmt,...)           \
[[MCSingleton sharedInstance] ifLogByString:[NSString stringWithFormat:(@"[%s] %s [第%d行 ]\n=====\n" fmt), __TIME__, __FUNCTION__,__LINE__, ##__VA_ARGS__]]
#define BLOCK_SAFE_RUN(block, ...)          block ? block(__VA_ARGS__) : nil
//雜項
#define IS_OS_8_OR_LATER        ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define IS_IPAD                 (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE               (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_4_P           (IS_IPHONE && ([[UIScreen mainScreen] bounds].size.height == 480) && (IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale == [UIScreen mainScreen].scale))
#define IS_IPHONE_5_P           (IS_IPHONE && ([[UIScreen mainScreen] bounds].size.height == 568.0) && (IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale == [UIScreen mainScreen].scale))
#define IS_IPHONE_4_L           (IS_IPHONE && ([[UIScreen mainScreen] bounds].size.width == 480) && (IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale == [UIScreen mainScreen].scale))
#define IS_IPHONE_5_L           (IS_IPHONE && ([[UIScreen mainScreen] bounds].size.width == 568.0) && (IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale == [UIScreen mainScreen].scale))

#define IS_STANDARD_IPHONE_6    (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0  && IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale == [UIScreen mainScreen].scale)
#define IS_ZOOMED_IPHONE_6      (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0 && IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale > [UIScreen mainScreen].scale)
#define IS_STANDARD_IPHONE_6_PLUS (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0)
#define IS_ZOOMED_IPHONE_6_PLUS (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0 && IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale < [UIScreen mainScreen].scale)
