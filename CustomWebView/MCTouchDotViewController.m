//
//  MCTouchDotViewController.m
//  ISGlobalSDK
//
//  Created by AndyChen on 2017/3/24.
//  Copyright © 2017年 AndyChen. All rights reserved.
//

#import "MCTouchDotViewController.h"
#import "Constant_m.h"
#import "ViewController.h"
#import "AppDelegate.h"
#define DefaultWidth            40.0
// for iOS 8.3之後的旋轉

@interface TheRootViewController : UIViewController

@end



@implementation TheRootViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
}
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations
//{
//    NSArray *supportedOrientations = [[[NSBundle mainBundle] infoDictionary]
//                                      objectForKey:@"UISupportedInterfaceOrientations"];
//    NSString *supportedOrientationsStr = [supportedOrientations componentsJoinedByString:@" "];
//    NSRange range = [supportedOrientationsStr rangeOfString:@"Portrait"];
//    if ( range.location != NSNotFound )
//    {
//        NSLog(@"系統方法 支持 正向");
//        return UIInterfaceOrientationMaskPortrait;
//    }else
//    {
//        NSLog(@"系統方法 不支持 正向");
//        return UIInterfaceOrientationMaskLandscape;
//    }
//}
- (BOOL)shouldAutorotate
{
    return NO; // 強制取消，以解決beginIgnoringInteractionEvents overflow
}

@end

/*
 * @brief 微平台單一實例
 */
static MCTouchDotViewController *shareMCTouchDot = nil;

@interface MCTouchDotViewController ()<UIViewControllerPreviewingDelegate>
{
    /*
     * @brief 原始座標系的寬，視為X軸單位向量
     */
    float _screenWidth;
    
    /*
     * @brief 原始座標系的高，視為Y軸單位向量
     */
    float _screenHeight;
    
    /*
     * @brief 各功能鈕原點：原始座標系的X軸向量陣列
     */
    NSMutableArray *_boardWindowXVector;
    
    /*
     * @brief 各功能鈕原點：原始座標系的Y軸向量陣列
     */
    NSMutableArray *_boardWindowYVector;
    
    /*
     * @brief 記錄各功能鈕中點X座標陣列
     */
    NSMutableArray *_MCTouchDotButtonXArray;
    
    /*
     * @brief 記錄各功能鈕中點Y座標陣列
     */
    NSMutableArray *_MCTouchDotButtonYArray;
    
    /*
     * @brief Server端控制各功能是否隱藏陣列
     */
    NSMutableArray *_serverMCTouchDotButtonHiddenArray;
    
    /*
     * @brief 各功能鈕預設的圖示陣列
     */
    NSMutableArray *_MCTouchDotButtonIconArray;
    
    /*
     * @brief 各功能鈕預設的文字陣列
     */
    NSMutableArray *_MCTouchDotButtonWordArray;
    
    /*
     * @brief 各功能鈕點擊觸發後執行的方法陣列
     */
    NSMutableArray *_MCTouchDotButtonEventArray;
    
    /*
     * @brief 各功能鈕預設是否隱藏陣列
     */
    NSMutableArray *_MCTouchDotButtonDefaultHiddenArray;
    
    /*
     * @brief 判斷是否展開
     */
    BOOL _isOpen;

    /*
     * @brief 底下的黑View
     */
    UIView *dotBlackCoverView;
    
    /*
     * @brief 中點
     */
    float centerX;
    float centerY;
    
    /*
     * @brief 懸浮按鈕觸控前的點
     */
    CGPoint theSBDotCurrentPoint;
    
    /*
     * @brief 懸浮按鈕Image 點按前後畫面
     */
    NSArray *imageArray;
    
    /*
     * @brief 懸浮按鈕Image 點按前後畫面
     */
    BOOL dotIsDrag;
    // 橫屏開始兼位移判斷
    BOOL checkRotation ;
    // 直屛開始
    BOOL canPortait ;
    // 直屛位移判斷
    int currentPosition;
    NSString *initPosition;
    
#pragma mark CustomView 專用
    NSMutableArray *iSGameDotOpenArray;
    NSInteger MCTouchDotCounts;
    BOOL canSB;
}
@end
typedef NS_ENUM(NSUInteger, InitScreenOrientaion)
{
    InitPositionLandscapeLeft,
    InitPositionPortrait,
    InitPositionLandscapeRight,
};
typedef NS_ENUM(NSUInteger, CurrentScreenOrientaion)
{
    CurrentPositionLandscapeLeft,
    CurrentPositionPortrait,
    CurrentPositionLandscapeRight,
};
@implementation MCTouchDotViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    currentPosition = CurrentPositionPortrait;
    
//    [self setDotButtonArrays];
//    [self secondAction];
//    [shareMCTouchDot checkServerSet];
//    MCTouchDotStart = YES;
//    [shareMCTouchDot checkServerSet:serverMCTouchDotTimeInterval];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - public method

// 隱藏微平台
+ (void) hiddenMCTouchDot
{
    // 微平台若啟動並處於顯示狀態才需隱藏
    if (MCTouchDotStart)
    {
        MCTouchDotViewController *MCTouchDot = [MCTouchDotViewController sharedApplication];
        saveMCTouchDotHiddenState = MCTouchDot.allHiddenNow;
        if (!saveMCTouchDotHiddenState) {
            MCTouchDot.allHiddenNow = YES;
            NSLog(@"hiddenMCTouchDot 跑");
            [MCTouchDot refreshSetup];
        }
    }
}

// 顯示微平台
+ (void) showMCTouchDot
{
    // 微平台若啟動並原本處於顯示狀態才需顯示
    if (MCTouchDotStart && !saveMCTouchDotHiddenState)
    {
        MCTouchDotViewController *MCTouchDot = [MCTouchDotViewController sharedApplication];
        NSLog(@"啟動 MCTouchDotViewController");
        MCTouchDot.allHiddenNow = NO;
        NSLog(@"showMCTouchDot 跑");
        [MCTouchDot refreshSetup];
    }
}

// 統一取得微平台單一實例
+ (MCTouchDotViewController *) sharedApplication
{
    static dispatch_once_t MCTouchDotOnceToken;
    dispatch_once(&MCTouchDotOnceToken, ^
    {
        // 各功能鈕隱藏與否，初始走預設，再走Server設定，最後才Client設定
        shareMCTouchDot = [[self alloc] init];
        NSLog(@"設置 share MCTouchDotViewController");
        [shareMCTouchDot checkServerSet];
        MCTouchDotStart = YES;
    });
    [shareMCTouchDot checkServerSet:serverMCTouchDotTimeInterval];
    return shareMCTouchDot;
}
- (id) init
{
    self = [super init];
    if(self)
    {
        NSLog(@"MCTouchDot 初始設定 Init");
//        CGRect oldRect = self.view.frame;
//        oldRect.size.height = oldRect.size.width;
//        [self.view setFrame:oldRect];
//        self.view.userInteractionEnabled = YES;
        _openNow = NO;
        _isOpen = NO;
        _allHiddenNow = NO;
        _boardWindowXVector = [[NSMutableArray alloc] init];
        _boardWindowYVector = [[NSMutableArray alloc] init];
        _boardWindowArray = [[NSMutableArray alloc] init];
        _MCTouchDotButtonVaildArray = [[NSMutableArray alloc] init];
        _MCTouchDotButtonHiddenArray = [[NSMutableArray alloc] init];
        _serverMCTouchDotButtonHiddenArray = [[NSMutableArray alloc] init];
        _MCTouchDotButtonEventArray = [[NSMutableArray alloc] init];
        _MCTouchDotButtonDefaultHiddenArray = [[NSMutableArray alloc] init];
        _MCTouchDotButtonXArray = [[NSMutableArray alloc] init];
        _MCTouchDotButtonYArray = [[NSMutableArray alloc] init];
        _MCTouchDotButtonIconArray = [[NSMutableArray alloc] init];
        _MCTouchDotButtonWordArray = [[NSMutableArray alloc] init];
        iSGameDotOpenArray = [[NSMutableArray alloc] init];
        //        _MCTouchDotButtonEventArray = [[NSArray alloc] initWithObjects:MCTouchDotButtonEvent];
        //        _MCTouchDotButtonDefaultHiddenArray = [[NSArray alloc] initWithObjects:MCTouchDotButtonDefaultHidden];
        
        //        // 以HOME鍵為下方的直立式座標系為原始座標系
        //        if([[UIScreen mainScreen] bounds].size.width < [[UIScreen mainScreen] bounds].size.height) {
        //            _screenWidth = [[UIScreen mainScreen] bounds].size.width;
        //            _screenHeight = [[UIScreen mainScreen] bounds].size.height;
        //        } else {
        //            _screenWidth = [[UIScreen mainScreen] bounds].size.height;
        //            _screenHeight = [[UIScreen mainScreen] bounds].size.width;
        //        }
        
        // 初始微平台各功能鈕
        //        _MCTouchDotButtonXArray = [[NSMutableArray alloc] initWithObjects:MCTouchDotButtonX];
        //        _MCTouchDotButtonYArray = [[NSMutableArray alloc] initWithObjects:MCTouchDotButtonY];
        //        _MCTouchDotButtonIconArray = [[NSArray alloc] initWithObjects:MCTouchDotButtonIcon];
        //        _MCTouchDotButtonWordArray = [[NSArray alloc] initWithObjects:MCTouchDotButtonWord];
        [self setDotButtonArrays];
        [self secondAction];
        [self detectDotToBoardWithPan];
        //        [self setBlaclCover];
        //        for (int i = 0; i < [[MCInfoObject sharedInstance] MCTouchDotCounts]; i++) {
        //            // 初始原點之後中點
        //            NSString *_MCTouchDotButtonX = [_MCTouchDotButtonXArray objectAtIndex:i];
        //            [_MCTouchDotButtonXArray replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:_MCTouchDotButtonX.floatValue + 25.0]];
        //            NSString *_MCTouchDotButtonY = [_MCTouchDotButtonYArray objectAtIndex:i];
        //            [_MCTouchDotButtonYArray replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:_MCTouchDotButtonY.floatValue + 25.0]];
        //            UIWindow *boardWindow = [[UIWindow alloc] initWithFrame:CGRectMake(_MCTouchDotButtonX.floatValue, _MCTouchDotButtonY.floatValue, 50.0, 50.0)];
        //            boardWindow.backgroundColor = [UIColor clearColor];
        //            boardWindow.windowLevel = i == MCTouchDotButtonMain ? 3002.0 : 3000.0;
        //            boardWindow.clipsToBounds = YES;
        //            boardWindow.rootViewController = [[TheRootViewController alloc] init]; // 強制要給，不然iOS 9.0有機率crash
        //            [boardWindow makeKeyAndVisible];
        //            boardWindow.hidden = i == MCTouchDotButtonMain ? serverMCTouchDotHiddenState : YES;
        //
        //            // 手勢辨識不支援成員變數，所以使用區域變數
        //            MCTouchDotBoardView *boardView = [[MCTouchDotBoardView alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 50.0)];
        //
        //            UIGraphicsBeginImageContextWithOptions(boardView.frame.size, NO, 0.0);
        //            [[UIImage imageNamed:[LCLib getImageLocate:[_MCTouchDotButtonIconArray objectAtIndex:i]]] drawInRect:CGRectMake(12.0, 0.0, 26.0, 26.0)];
        //            NSString *localize = [[MCFunctionView sharedApplication] localize] ? [[MCFunctionView sharedApplication] localize] : [[NSLocale currentLocale] localeIdentifier];
        //            UIFont *font = [localize hasPrefix:@"zh"] || [localize isEqualToString:@"tw"] ? [UIFont boldSystemFontOfSize:10] : [UIFont boldSystemFontOfSize:10];
        //            NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        //            paragraphStyle.lineBreakMode = NSLineBreakByClipping;
        //            paragraphStyle.alignment = NSTextAlignmentCenter;
        //            NSDictionary *wordAttributes = @{ NSFontAttributeName: font,
        //                                              NSParagraphStyleAttributeName: paragraphStyle,
        //                                              NSForegroundColorAttributeName: [UIColor blackColor],
        //                                              NSBackgroundColorAttributeName: [UIColor whiteColor]};
        //            [[LCLanguage string:[_MCTouchDotButtonWordArray objectAtIndex:i]] drawInRect:CGRectIntegral(CGRectMake(0.0, 26.0, 50.0, 24.0)) withAttributes:wordAttributes];
        //            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        //            UIGraphicsEndImageContext();
        //            //原先的方式 佔用很多內存
        //            //            boardView.backgroundColor = [UIColor colorWithPatternImage:image];
        //            //新方法
        //            boardView.layer.contents = (id) image.CGImage;
        //            boardView.autoresizingMask = UIViewAutoresizingNone;
        //            boardView.tag = i;
        //            boardView.userInteractionEnabled = YES;
        //
        //            UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]
        //                                                            initWithTarget:self
        //                                                            action:@selector(mcHandlePan:)];
        //            [boardView addGestureRecognizer:panGestureRecognizer];
        //
        //            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]
        //                                                            initWithTarget:self
        //                                                            action:@selector(mcHandleTap:)];
        //            [boardView addGestureRecognizer:tapGestureRecognizer];
        //            [boardWindow addSubview:boardView];
        //
        //            [_boardWindowXVector addObject:[NSNumber numberWithFloat:boardWindow.frame.origin.x / _screenWidth]];
        //            [_boardWindowYVector addObject:[NSNumber numberWithFloat:boardWindow.frame.origin.y / _screenHeight]];
        //            [_boardWindowArray addObject:boardWindow];
        //            [_MCTouchDotButtonVaildArray addObject:[NSNumber numberWithBool:YES]];
        //
        //            // 各功能鈕預設是否隱藏
        //            [_MCTouchDotButtonHiddenArray addObject:[NSNumber numberWithBool:[[_MCTouchDotButtonDefaultHiddenArray objectAtIndex:i] boolValue]]];
        //            [_serverMCTouchDotButtonHiddenArray addObject:[NSNumber numberWithBool:[[_MCTouchDotButtonDefaultHiddenArray objectAtIndex:i] boolValue]]];
        //        }
        //        
        //        // 跟系統註冊要收到裝置方向變更完成的通知
        //        [[NSNotificationCenter defaultCenter] addObserver:self
        //                                                 selector:@selector(deviceDidRotate:)
        //                                                     name:UIDeviceOrientationDidChangeNotification
        //                                                   object:nil];
    }
    
    return self;
}
- (void) setDotButtonArrays
{
    [_boardWindowXVector removeAllObjects];
    [_boardWindowYVector removeAllObjects];
    [_boardWindowArray removeAllObjects];
    [_MCTouchDotButtonVaildArray removeAllObjects];
    [_MCTouchDotButtonHiddenArray removeAllObjects];
    [_serverMCTouchDotButtonHiddenArray removeAllObjects];
//    NSLog(@"重新設定懸浮按鈕 Arrays :%@",[[MCInfoObject sharedInstance] iSGameDotOpenArray]);
    [_MCTouchDotButtonEventArray removeAllObjects];
    [_MCTouchDotButtonDefaultHiddenArray removeAllObjects];
    [_MCTouchDotButtonIconArray removeAllObjects];
    [_MCTouchDotButtonWordArray removeAllObjects];
    
    [_MCTouchDotButtonXArray removeAllObjects];
    [_MCTouchDotButtonYArray removeAllObjects];
    [iSGameDotOpenArray removeAllObjects];
    NSMutableArray *openDotArray ;
//    openDotArray = [[NSMutableArray alloc] initWithObjects:MCTouchDotButtonDefaultHidden];
    openDotArray = [@[@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"0"] mutableCopy];
    
    
    for (int i = 0; i<openDotArray.count; i++)
    {
        if ([[openDotArray objectAtIndex:i] intValue] == 0)
        {
            [iSGameDotOpenArray addObject:[NSNumber numberWithInt:i]];
        }
        
    }
//    [iSGameDotOpenArray addObject:[NSNumber numberWithInt:20]];
    [[MCInfoObject sharedInstance] setMCTouchDotCounts:iSGameDotOpenArray.count];
    
    NSArray *pointArray = [self resetButtonXY];
    for (int i = 0; i < iSGameDotOpenArray.count; i++)
    {
        int theI = [[iSGameDotOpenArray objectAtIndex:i] intValue];
        [_MCTouchDotButtonEventArray addObject:[[[NSMutableArray alloc] initWithObjects:MCTouchDotButtonEvent] objectAtIndex:theI]];
        [_MCTouchDotButtonDefaultHiddenArray addObject:[[[NSMutableArray alloc] initWithObjects:MCTouchDotButtonDefaultHidden] objectAtIndex:theI]];
        [_MCTouchDotButtonIconArray addObject:[[[NSMutableArray alloc] initWithObjects:MCTouchDotButtonIcon] objectAtIndex:theI]];
        [_MCTouchDotButtonWordArray addObject:[[[NSMutableArray alloc] initWithObjects:MCTouchDotButtonWord] objectAtIndex:theI]];
        
        if ((i == 0)||(i == (iSGameDotOpenArray.count-1)))
        {
            [_MCTouchDotButtonXArray addObject:[NSString stringWithFormat:@"%f",centerX]];
            [_MCTouchDotButtonYArray addObject:[NSString stringWithFormat:@"%f",centerY]];
        }else
        {
            [_MCTouchDotButtonXArray addObject:[NSString stringWithFormat:@"%f",CGPointFromString([pointArray objectAtIndex:i]).x]];
            [_MCTouchDotButtonYArray addObject:[NSString stringWithFormat:@"%f",CGPointFromString([pointArray objectAtIndex:i]).y]];
        }
    }
    NSLog(@"degree count %lu",(unsigned long)pointArray.count);

    NSLog(@"_MCTouchDotButtonEventArray :%@",_MCTouchDotButtonEventArray);
    NSLog(@"_MCTouchDotButtonDefaultHiddenArray :%@",_MCTouchDotButtonDefaultHiddenArray);
    NSLog(@"_MCTouchDotButtonXArray :%@",_MCTouchDotButtonXArray);
    NSLog(@"_MCTouchDotButtonYArray :%@",_MCTouchDotButtonYArray);
    NSLog(@"_MCTouchDotButtonIconArray :%@",_MCTouchDotButtonIconArray);
    NSLog(@"_MCTouchDotButtonWordArray :%@",_MCTouchDotButtonWordArray);
    
}
- (NSArray *)resetButtonXY
{
    centerX = 0.0;
    centerY = 0.0;
    switch ([self getOrientation])
    {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            // 8.0新增
            if (CURRENT_DEV_Version<9.0)
            {
                if (CURRENT_DEV_Version<8.3)
                {
                    centerX = self.view.center.y;
                    centerY = self.view.center.x;
                }else
                {
                    centerX = self.view.center.x;
                    centerY = self.view.center.y;
                }
                
            }else
            {
                centerX = self.view.center.x;
                centerY = self.view.center.y;
            }
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            
            centerX = self.view.center.x;
            centerY = self.view.center.y;
            break;
        case UIInterfaceOrientationPortrait:
            centerX = self.view.center.x;
            centerY = self.view.center.y;
            break;
        default:
            break;
    }
    int redig = 0.0;
    if (iSGameDotOpenArray.count>10)
    {
        redig = 36;
    }else
    {
        redig = 360 / iSGameDotOpenArray.count;
    }
    
    NSMutableArray *pointArray = [[NSMutableArray alloc] init];
    for (int i = 0; i<360; i += redig)
    {
        float x = [[NSString stringWithFormat:@"%.f",((float)(75 * cos((i-130) * M_PI / 180.0)) + centerX)] floatValue];
        float y = [[NSString stringWithFormat:@"%.f",((float)(75 * sin((i-130) * M_PI / 180.0)) + centerY)] floatValue];
        
//        NNSLog(@"Degrees : %i poting :%@",i,NSStringFromCGPoint(CGPointMake(x, y)));
        [pointArray addObject:NSStringFromCGPoint(CGPointMake(x, y))];
    }
    if (iSGameDotOpenArray.count>10)
    {
        int redigTwo = 360 / (iSGameDotOpenArray.count - 10.0);
        for (int j = 0 ; j<360; j += redigTwo)
        {
            
            float x = [[NSString stringWithFormat:@"%.f",((float)(100 * cos(j * M_PI / 180.0)) + centerX)] floatValue];
            float y = [[NSString stringWithFormat:@"%.f",((float)(100 * sin(j * M_PI / 180.0)) + centerY)] floatValue];
            
//            NNSLog(@"Degrees : %i poting :%@",j,NSStringFromCGPoint(CGPointMake(x, y)));
            
            [pointArray addObject:NSStringFromCGPoint(CGPointMake(x, y))];
        }
    }
    return pointArray;
}
- (void)resetHiddenButton
{
    _MCTouchDotButtonHiddenArray = _MCTouchDotButtonDefaultHiddenArray;
    _serverMCTouchDotButtonHiddenArray = _MCTouchDotButtonDefaultHiddenArray;
}
- (void)secondAction
{
    canSB = YES;
    // 以HOME鍵為下方的直立式座標系為原始座標系
//    if([[UIScreen mainScreen] bounds].size.width < [[UIScreen mainScreen] bounds].size.height) {
        _screenWidth = [[UIScreen mainScreen] bounds].size.width;
        _screenHeight = [[UIScreen mainScreen] bounds].size.height;
//    } else {
//        _screenWidth = [[UIScreen mainScreen] bounds].size.height;
//        _screenHeight = [[UIScreen mainScreen] bounds].size.width;
//    }
//    _screenWidth = ThePortraitWidth([[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height);
//    _screenHeight = ThePortraitHeight([[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height);
    for (int i = 0; i < [[MCInfoObject sharedInstance] MCTouchDotCounts]; i++)
    {
        // 初始原點之後中點
        NSString *_MCTouchDotButtonX = [_MCTouchDotButtonXArray objectAtIndex:i];
        NSString *_MCTouchDotButtonY = [_MCTouchDotButtonYArray objectAtIndex:i];
        UIWindow *boardWindow;
//        CGRect right = CGRectMake(0, 0, 0, 0) ;
        if (i == ([[MCInfoObject sharedInstance] MCTouchDotCounts]-1))
        {
//            switch ([self getOrientation])
//            {
//                case UIInterfaceOrientationLandscapeLeft:
//                    NSLog(@"左橫");
//                case UIInterfaceOrientationLandscapeRight:
//                    NSLog(@"右橫");
//                    right = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y,ThePortraitWidth(self.view.frame.size.width, self.view.frame.size.height), ThePortraitHeight(self.view.frame.size.width, self.view.frame.size.height));
//                    break;
//                case UIInterfaceOrientationPortraitUpsideDown:
//                    NSLog(@"下直");
//                case UIInterfaceOrientationPortrait:
//                    NSLog(@"正直");
//                    right = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y,ThePortraitWidth(self.view.frame.size.width, self.view.frame.size.height), ThePortraitHeight(self.view.frame.size.width, self.view.frame.size.height));
//                    break;
//                default:
//                    break;
//            }
        
            boardWindow = [[UIWindow alloc] initWithFrame:self.view.bounds];

            boardWindow.center = CGPointMake(centerX, centerY);
            boardWindow.backgroundColor = [UIColor blackColor];
            boardWindow.windowLevel = 1994.0;
            [boardWindow setAccessibilityIdentifier:@"theBG"];
        }
        else
        {
            //            [_MCTouchDotButtonXArray replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:_MCTouchDotButtonX.floatValue + 25.0]];
            //            [_MCTouchDotButtonYArray replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:_MCTouchDotButtonY.floatValue + 25.0]];
            boardWindow = [[UIWindow alloc] initWithFrame:CGRectMake(_MCTouchDotButtonX.floatValue, _MCTouchDotButtonY.floatValue, DefaultWidth, DefaultWidth)];
            boardWindow.backgroundColor = [UIColor clearColor];
            boardWindow.windowLevel = (i == MCTouchDotButtonMain ? 1997.0 : 1995.0);
        }
        
        boardWindow.clipsToBounds = YES;
        boardWindow.rootViewController = [[TheRootViewController alloc] init]; // 強制要給，不然iOS 9.0有機率crash
        boardWindow.rootViewController.view = [[UIView alloc] initWithFrame:self.view.bounds];
        [boardWindow makeKeyAndVisible];
        
        boardWindow.hidden = (i == MCTouchDotButtonMain ? serverMCTouchDotHiddenState : YES);
        boardWindow.alpha = (i == MCTouchDotButtonMain ? 1.0 : 0.0);;
        
        // 手勢辨識不支援成員變數，所以使用區域變數
        MCTouchDotBoardView *boardView;
        
        if (i == ([[MCInfoObject sharedInstance] MCTouchDotCounts]-1))
        {
            boardView = [[MCTouchDotBoardView alloc] initWithFrame:self.view.bounds];
            [boardView setAccessibilityIdentifier:@"theBG"];
        }
        else if (i == MCTouchDotButtonMain)
        {
            [self saveButtonDownImage];
            boardView = [[MCTouchDotBoardView alloc] initWithFrame:CGRectMake(0.0, 0.0, DefaultWidth, DefaultWidth)];
            boardView.layer.contents = (id)[(UIImage *)[imageArray firstObject] CGImage];
         
        }
        else
        {
            boardView = [[MCTouchDotBoardView alloc] initWithFrame:CGRectMake(0.0, 0.0, DefaultWidth, DefaultWidth)];
            UIGraphicsBeginImageContextWithOptions(boardView.frame.size, NO, 0.0);
//            [[UIImage imageNamed:@"ShowButton.png"] drawInRect:CGRectMake(0.0, 0.0, DefaultWidth, DefaultWidth)];
            [[UIImage imageNamed:[_MCTouchDotButtonIconArray objectAtIndex:i]] drawInRect:CGRectMake(0.0, 0.0, DefaultWidth, DefaultWidth)];
            // 小球文字
            //            NSString *localize = [[MCFunctionView sharedApplication] localize] ? [[MCFunctionView sharedApplication] localize] : [[NSLocale currentLocale] localeIdentifier];
            //            UIFont *font = [localize hasPrefix:@"zh"] || [localize isEqualToString:@"tw"] ? [UIFont boldSystemFontOfSize:10] : [UIFont boldSystemFontOfSize:10];
            //            NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
            //            paragraphStyle.lineBreakMode = NSLineBreakByClipping;
            //            paragraphStyle.alignment = NSTextAlignmentCenter;
            //            NSDictionary *wordAttributes = @{ NSFontAttributeName: font,
            //                                              NSParagraphStyleAttributeName: paragraphStyle,
            //                                              NSForegroundColorAttributeName: [UIColor blackColor],
            //                                              NSBackgroundColorAttributeName: [UIColor whiteColor]};
            //            [[LCLanguage string:[_MCTouchDotButtonWordArray objectAtIndex:i]] drawInRect:CGRectIntegral(CGRectMake(0.0, 26.0, 50.0, 24.0)) withAttributes:wordAttributes];
            
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            //原先的方式 佔用很多內存
            //            boardView.backgroundColor = [UIColor colorWithPatternImage:image];
            //新方法
            boardView.layer.contents = (id) image.CGImage;
        }
        
        boardView.autoresizingMask = UIViewAutoresizingNone;
        boardView.tag = i;
        boardView.userInteractionEnabled = YES;
        
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                                        initWithTarget:self
                                                        action:@selector(mcHandlePan:)];
        panGestureRecognizer.delegate = self;
        [boardView addGestureRecognizer:panGestureRecognizer];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                        initWithTarget:self
                                                        action:@selector(mcHandleTap:)];
        tapGestureRecognizer.delegate = self;
        [boardView addGestureRecognizer:tapGestureRecognizer];
        
        [boardWindow.rootViewController.view addSubview:boardView];

        [_boardWindowXVector addObject:[NSNumber numberWithFloat:boardWindow.frame.origin.x / _screenWidth]];
        [_boardWindowYVector addObject:[NSNumber numberWithFloat:boardWindow.frame.origin.y / _screenHeight]];
        
      
        [_boardWindowArray addObject:boardWindow];
        
        [_MCTouchDotButtonVaildArray addObject:[NSNumber numberWithBool:YES]];
        
        // 各功能鈕預設是否隱藏
        [_MCTouchDotButtonHiddenArray addObject:[NSNumber numberWithBool:[[_MCTouchDotButtonDefaultHiddenArray objectAtIndex:i] boolValue]]];
        
        [_serverMCTouchDotButtonHiddenArray addObject:[NSNumber numberWithBool:[[_MCTouchDotButtonDefaultHiddenArray objectAtIndex:i] boolValue]]];
    }
    [self deviceDidRotate:nil];
    // 跟系統註冊要收到裝置方向變更完成的通知
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(deviceDidRotate:)
//                                                 name:UIDeviceOrientationDidChangeNotification
//                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceDidRotate:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    
}
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    return YES;
//}


// 功能鈕客製化
- (void) MCTouchDotButtonCustomAttributes:(NSDictionary *) attributes
{
//    if ([[attributes objectForKey:MCTouchDotButtonCustomName] isKindOfClass:[NSNumber class]] &&
//        [[attributes objectForKey:MCTouchDotButtonCustomName] integerValue] >= 0 &&
//        [[attributes objectForKey:MCTouchDotButtonCustomName] integerValue] < ([[MCInfoObject sharedInstance] MCTouchDotCounts]-1)) {
//        
//        /*------Button------*/
//        int index = [[attributes objectForKey:MCTouchDotButtonCustomName] intValue];
//        UIWindow *boardWindow = [_boardWindowArray objectAtIndex:index];
//        MCTouchDotBoardView *boardView = [boardWindow.subviews lastObject]; // 取得當前View
//        
//        CGPoint origin = [[attributes objectForKey:MCTouchDotButtonCustomOrigin] isKindOfClass:[NSValue class]] ? [[attributes objectForKey:MCTouchDotButtonCustomOrigin] CGPointValue] : boardWindow.frame.origin;
//        
//        CGSize size = [[attributes objectForKey:MCTouchDotButtonCustomSize] isKindOfClass:[NSValue class]] ? [[attributes objectForKey:MCTouchDotButtonCustomSize] CGSizeValue] : boardWindow.frame.size;
//        size.width = size.width < 50.0 ? 50.0 : size.width;
//        size.width = size.width > 100.0 ? 100.0 : size.width;
//        size.height = size.height < 50.0 ? 50.0 : size.height;
//        size.height = size.height > 100.0 ? 100.0 : size.height;
//        
//        boardWindow.frame = CGRectMake(origin.x, origin.y, size.width, size.height);
//        boardView.frame = CGRectMake(0.0, 0.0, size.width, size.height);
//        
//        if ([[attributes objectForKey:MCTouchDotButtonCustomBackground] isKindOfClass:[UIColor class]]) {
//            boardWindow.backgroundColor = [attributes objectForKey:MCTouchDotButtonCustomBackground];
//        } else if ([[attributes objectForKey:MCTouchDotButtonCustomBackground] isKindOfClass:[UIImage class]]) {
//            boardWindow.backgroundColor = [UIColor colorWithPatternImage:[attributes objectForKey:MCTouchDotButtonCustomBackground]];
//        } else if ([[attributes objectForKey:MCTouchDotButtonCustomBackground] isKindOfClass:[NSString class]]) {
//            UIGraphicsBeginImageContextWithOptions(boardWindow.frame.size, NO, 0.0);
//            if ([[NSFileManager defaultManager] fileExistsAtPath:[attributes objectForKey:MCTouchDotButtonCustomBackground]]) {
//                [[UIImage imageWithContentsOfFile:[attributes objectForKey:MCTouchDotButtonCustomBackground]] drawInRect:CGRectMake(0, 0, boardWindow.frame.size.width, boardWindow.frame.size.height)];
//            } else {
//                [[UIImage imageNamed:[attributes objectForKey:MCTouchDotButtonCustomBackground]] drawInRect:CGRectMake(0, 0, boardWindow.frame.size.width, boardWindow.frame.size.height)];
//            }
//            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//            UIGraphicsEndImageContext();
//            boardWindow.backgroundColor = [UIColor colorWithPatternImage:image];
//        }
//        
//        /*------Icon & Word------*/
//        // 動態設定
//        float wordHeight = 24.0;
//        float iconLength = (boardView.frame.size.height - wordHeight) < boardView.frame.size.width ? (boardView.frame.size.height - wordHeight) : boardView.frame.size.width;
//        
//        CGPoint iconOrigin = [[attributes objectForKey:MCTouchDotButtonCustomIconOrigin] isKindOfClass:[NSValue class]] ? [[attributes objectForKey:MCTouchDotButtonCustomIconOrigin] CGPointValue] : CGPointMake((boardView.frame.size.width - iconLength) / 2.0, 0.0);
//        
//        CGSize iconSize = [[attributes objectForKey:MCTouchDotButtonCustomIconSize] isKindOfClass:[NSValue class]] ? [[attributes objectForKey:MCTouchDotButtonCustomIconSize] CGSizeValue] : CGSizeMake(iconLength, iconLength);
//        
//        if ([[attributes objectForKey:MCTouchDotButtonCustomHasIcon] isKindOfClass:[NSNumber class]] &&
//            [[attributes objectForKey:MCTouchDotButtonCustomHasIcon] integerValue] == 0) {
//            iconSize = CGSizeMake(0.0, 0.0);
//        }
//        
//        CGPoint wordOrigin = [[attributes objectForKey:MCTouchDotButtonCustomWordBoundOrigin] isKindOfClass:[NSValue class]] ? [[attributes objectForKey:MCTouchDotButtonCustomWordBoundOrigin] CGPointValue] : CGPointMake(0.0, (boardView.frame.size.height - wordHeight));
//        
//        CGSize wordSize = [[attributes objectForKey:MCTouchDotButtonCustomWordBoundSize] isKindOfClass:[NSValue class]] ? [[attributes objectForKey:MCTouchDotButtonCustomWordBoundSize] CGSizeValue] : CGSizeMake(boardView.frame.size.width, wordHeight);
//        
//        if ([[attributes objectForKey:MCTouchDotButtonCustomHasWord] isKindOfClass:[NSNumber class]] &&
//            [[attributes objectForKey:MCTouchDotButtonCustomHasWord] integerValue] == 0) {
//            wordSize = CGSizeMake(0.0, 0.0);
//        }
//        
//        UIGraphicsBeginImageContextWithOptions(boardView.frame.size, NO, 0.0);
//        if ([[attributes objectForKey:MCTouchDotButtonCustomIconBackground] isKindOfClass:[UIColor class]]) {
//            CGContextRef context = UIGraphicsGetCurrentContext();
//            CGContextSetFillColorWithColor(context, [[attributes objectForKey:MCTouchDotButtonCustomIconBackground] CGColor]);
//            CGContextFillRect(context, CGRectMake(iconOrigin.x, iconOrigin.y, iconSize.width, iconSize.height));
//        } else if ([[attributes objectForKey:MCTouchDotButtonCustomIconBackground] isKindOfClass:[UIImage class]]) {
//            [[attributes objectForKey:MCTouchDotButtonCustomIconBackground] drawInRect:CGRectMake(iconOrigin.x, iconOrigin.y, iconSize.width, iconSize.height)];
//        } else if ([[attributes objectForKey:MCTouchDotButtonCustomIconBackground] isKindOfClass:[NSString class]]) {
//            if ([[NSFileManager defaultManager] fileExistsAtPath:[attributes objectForKey:MCTouchDotButtonCustomIconBackground]]) {
//                [[UIImage imageWithContentsOfFile:[attributes objectForKey:MCTouchDotButtonCustomIconBackground]] drawInRect:CGRectMake(iconOrigin.x, iconOrigin.y, iconSize.width, iconSize.height)];
//            } else {
//                [[UIImage imageNamed:[attributes objectForKey:MCTouchDotButtonCustomIconBackground]] drawInRect:CGRectMake(iconOrigin.x, iconOrigin.y, iconSize.width, iconSize.height)];
//            }
//        } else {
//            [[UIImage imageNamed:[LCLib getImageLocate:[_MCTouchDotButtonIconArray objectAtIndex:index]]] drawInRect:CGRectMake(iconOrigin.x, iconOrigin.y, iconSize.width, iconSize.height)];
//        }
//        
//        UIColor *wordBoundForegroundColor = [UIColor blackColor];
//        if ([[attributes objectForKey:MCTouchDotButtonCustomWordBoundForegroundColor] isKindOfClass:[UIColor class]]) {
//            wordBoundForegroundColor = [attributes objectForKey:MCTouchDotButtonCustomWordBoundForegroundColor];
//        }
//        
//        UIColor *wordBoundBackgroundColor = [UIColor whiteColor];
//        if ([[attributes objectForKey:MCTouchDotButtonCustomWordBoundBackgroundColor] isKindOfClass:[UIColor class]]) {
//            wordBoundBackgroundColor = [attributes objectForKey:MCTouchDotButtonCustomWordBoundBackgroundColor];
//        }
//        
//        NSString *word = [LCLanguage string:[_MCTouchDotButtonWordArray objectAtIndex:index]];
//        if ([[attributes objectForKey:MCTouchDotButtonCustomWord] isKindOfClass:[NSString class]]) {
//            word = [attributes objectForKey:MCTouchDotButtonCustomWord];
//        }
//        
//        NSString *localize = [[MCFunctionView sharedApplication] localize] ? [[MCFunctionView sharedApplication] localize] : [[NSLocale currentLocale] localeIdentifier];
//        UIFont *font = [localize hasPrefix:@"zh"] || [localize isEqualToString:@"tw"] ? [UIFont boldSystemFontOfSize:16] : [UIFont boldSystemFontOfSize:10];
//        if ([[attributes objectForKey:MCTouchDotButtonCustomWordSize] isKindOfClass:[NSNumber class]]) {
//            int wordSize = [[attributes objectForKey:MCTouchDotButtonCustomWordSize] intValue];
//            wordSize = wordSize < 10 ? 10 : wordSize;
//            wordSize = wordSize > 30 ? 30 : wordSize;
//            font = [UIFont boldSystemFontOfSize:wordSize];
//        }
//        
//        int wordAlignment = NSTextAlignmentCenter;
//        if ([[attributes objectForKey:MCTouchDotButtonCustomWordAlignment] isKindOfClass:[NSNumber class]] &&
//            [[attributes objectForKey:MCTouchDotButtonCustomWordAlignment] integerValue] >= 0 &&
//            [[attributes objectForKey:MCTouchDotButtonCustomWordAlignment] integerValue] <= NSTextAlignmentNatural) {
//            wordAlignment = [[attributes objectForKey:MCTouchDotButtonCustomWordAlignment] intValue];
//        }
//        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
//        paragraphStyle.lineBreakMode = NSLineBreakByClipping;
//        paragraphStyle.alignment = wordAlignment;
//        
//        NSDictionary *wordAttributes = @{ NSFontAttributeName: font,
//                                          NSParagraphStyleAttributeName: paragraphStyle,
//                                          NSForegroundColorAttributeName: wordBoundForegroundColor,
//                                          NSBackgroundColorAttributeName: wordBoundBackgroundColor};
//        [word drawInRect:CGRectIntegral(CGRectMake(wordOrigin.x, wordOrigin.y, wordSize.width, wordSize.height)) withAttributes:wordAttributes];
//        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        boardView.backgroundColor = [UIColor colorWithPatternImage:image];
//    }
}

// 更新設定
- (void) refreshSetup
{
    NSLog(@"重新設定懸浮按鈕");

    for (int i = 0; i < ([[MCInfoObject sharedInstance] MCTouchDotCounts]-1); i++)
    {
        UIWindow *boardWindow = [_boardWindowArray objectAtIndex:i];
        NSNumber *_MCTouchDotButtonX = [_MCTouchDotButtonXArray objectAtIndex:i];
        NSNumber *_MCTouchDotButtonY = [_MCTouchDotButtonYArray objectAtIndex:i];
        
        // 若隱藏微平台就無需管開合
        if (serverMCTouchDotHiddenState || _allHiddenNow) {
            boardWindow.hidden = YES;
        } else if (i == MCTouchDotButtonMain) {
            // 若顯示微平台就只需顯示主要功能，剩下交由_isOpen判斷
            boardWindow.hidden = NO;
        }
        [UIView animateWithDuration:0.3 animations:^
        {
            // 若現在處於展開狀態，更新各功能顯示與否
            if (!serverMCTouchDotHiddenState && !_allHiddenNow && _isOpen)
            {
                NSNumber *MCTouchDotButtonHidden = [_MCTouchDotButtonHiddenArray objectAtIndex:i];
                NSNumber *serverMCTouchDotButtonHidden = [_serverMCTouchDotButtonHiddenArray objectAtIndex:i];
                boardWindow.hidden = [serverMCTouchDotButtonHidden boolValue] ? YES : [MCTouchDotButtonHidden boolValue];
            }
        }];
        
        
        // 有更新座標才需做以下動作
        if ([_MCTouchDotButtonX floatValue] != boardWindow.center.x && [_MCTouchDotButtonY floatValue] != boardWindow.center.y)
        {
            continue;
        }
        // 檢查移動是否超出螢幕邊境
        
//        boardWindow.center = [self checkBoardWindowOriginX:boardWindow.frame.origin.x
//                                                   originY:boardWindow.frame.origin.y
//                                                     width:boardWindow.frame.size.width
//                                                    height:boardWindow.frame.size.height];
        
        // 更新各功能鈕中點
        [_MCTouchDotButtonXArray replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:boardWindow.center.x]];
        [_MCTouchDotButtonYArray replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:boardWindow.center.y]];
        
        // 更新各功能鈕向量，給外部設定以HOME鍵為下方的直立式座標系為主
        [_boardWindowXVector replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:boardWindow.frame.origin.x / _screenWidth]];
        [_boardWindowYVector replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:boardWindow.frame.origin.y / _screenHeight]];
    }
//    NSLog(@"調整後 _MCTouchDotButtonXArray :%@\n調整後 _MCTouchDotButtonYArray :%@",_MCTouchDotButtonXArray,_MCTouchDotButtonYArray);
    // 初始預設版面重排
    if (!MCTouchDotStart)
    {
        // 主功能區域
//        [self autoArrangeButtonFollowParent:MCTouchDotButtonMain
//                                  boundFrom:MCTouchDotButtonMy
//                                         to:MCTouchDotButtonShare
//                                     byType:@"LineWidth"];
//        // 「我的」子功能區域
//        [self autoArrangeButtonFollowParent:MCTouchDotButtonMy
//                                  boundFrom:MCTouchDotButtonMyProfile
//                                         to:MCTouchDotButtonMyMessage
//                                     byType:@"LineHeight"];
//        // 「遊戲」子功能區域
//        [self autoArrangeButtonFollowParent:MCTouchDotButtonGame
//                                  boundFrom:MCTouchDotButtonGameEvent
//                                         to:MCTouchDotButtonGameData
//                                     byType:@"LineHeight"];
//        // 「分享」子功能區域
//        [self autoArrangeButtonFollowParent:MCTouchDotButtonShare
//                                  boundFrom:MCTouchDotButtonShareTofb
//                                         to:MCTouchDotButtonCustomBuyPurchase
//                                     byType:@"LineHeight"];
    }
    
    [self setSelter];
    
    // 更新半透明
    [self MCTouchDotButtonMainTranslucent];
}
- (void)setSelter
{
    // 假如現在開合狀態不等於外部設定就立即開或合
    if (!serverMCTouchDotHiddenState && !_allHiddenNow && _isOpen != _openNow)
    {
        if (!self) { return; }
        SEL theSEL = NSSelectorFromString([_MCTouchDotButtonEventArray objectAtIndex:MCTouchDotButtonMain]);
        IMP imp = [self methodForSelector:theSEL];
        void (*func)(id, SEL) = (void *)imp;
        func(self, theSEL);
    }
}
// 主要功能鈕於收合狀態下五秒後半透明
- (void) MCTouchDotButtonMainTranslucent
{
    if (_isOpen)
    {
        return;
    }
    [UIView animateWithDuration:[UIApplication sharedApplication].statusBarOrientationAnimationDuration
                          delay:5.0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         UIWindow *boardWindow = [_boardWindowArray objectAtIndex:MCTouchDotButtonMain];
                         boardWindow.alpha = 0.5;
                     }
                     completion:^(BOOL finished){
                     }];
}

// 主要功能鈕馬上不透明
- (void) MCTouchDotButtonMainOpaque
{
    [UIView animateWithDuration:[UIApplication sharedApplication].statusBarOrientationAnimationDuration
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         UIWindow *boardWindow = [_boardWindowArray objectAtIndex:MCTouchDotButtonMain];
                         boardWindow.alpha = 1.0;
                     }
                     completion:^(BOOL finished){
                     }];
}

#pragma mark - private method

/*
 * @brief 自動排列：群組按鈕忽略隱藏按鈕後的對應位置，並可調整自身的相對位置，除byType以外參數皆為ENUM(MCTouchDotButton)
 * @param autoArrangeButtonFollowParent 此群組的父節點
 * @param boundFrom 此群組範圍開始
 * @param to 此群組範圍結束
 * @param byType 版面的排列型態，目前有LineWidth, LineHeight
 */
//- (void) autoArrangeButtonFollowParent:(int) parentButton
//                             boundFrom:(int) boundStart
//                                    to:(int) boundEnd
//                                byType:(NSString*) type
//{
//    UIWindow *parentBoardWindow = [_boardWindowArray objectAtIndex:parentButton];
//    BOOL parentBoardWindowHidden = serverMCTouchDotHiddenState || [[_serverMCTouchDotButtonHiddenArray objectAtIndex:parentButton] boolValue] ? YES : [[_MCTouchDotButtonHiddenArray objectAtIndex:parentButton] boolValue];
//    [_MCTouchDotButtonHiddenArray replaceObjectAtIndex:parentButton withObject:[NSNumber numberWithBool:parentBoardWindowHidden]];
//    if (parentBoardWindowHidden) {
//        parentBoardWindow.hidden = parentBoardWindowHidden;
//    }
//    float shiftWidth = parentBoardWindow.frame.size.width;
//    float shiftHeight = parentBoardWindow.frame.size.height;
//    
//    for (int i = boundStart; i <= boundEnd; i++) {
//        UIWindow *sonBoardWindow = [_boardWindowArray objectAtIndex:i];
//        BOOL sonBoardWindowHidden = serverMCTouchDotHiddenState || [[_serverMCTouchDotButtonHiddenArray objectAtIndex:i] boolValue] || parentBoardWindowHidden ? YES : [[_MCTouchDotButtonHiddenArray objectAtIndex:i] boolValue];
//        [_MCTouchDotButtonHiddenArray replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:sonBoardWindowHidden]];
//        if (sonBoardWindowHidden) {
//            sonBoardWindow.hidden = sonBoardWindowHidden;
//            continue;
//        }
//        
//        if ([type isEqualToString:@"LineWidth"])
//        {
//            shiftHeight = 0;
//        } else {
//            shiftWidth = 0;
//        }
//        
//        switch ([self getOrientation])
//        {
//            case UIInterfaceOrientationLandscapeLeft:
//                sonBoardWindow.center = [self checkBoardWindowOriginX:parentBoardWindow.frame.origin.x + shiftHeight
//                                                              originY:parentBoardWindow.frame.origin.y - shiftWidth
//                                                                width:sonBoardWindow.frame.size.width
//                                                               height:sonBoardWindow.frame.size.height];
//                break;
//            case UIInterfaceOrientationLandscapeRight:
//                sonBoardWindow.center = [self checkBoardWindowOriginX:parentBoardWindow.frame.origin.x - shiftHeight
//                                                              originY:parentBoardWindow.frame.origin.y + shiftWidth
//                                                                width:sonBoardWindow.frame.size.width
//                                                               height:sonBoardWindow.frame.size.height];
//                break;
//            case UIInterfaceOrientationPortraitUpsideDown:
//                sonBoardWindow.center = [self checkBoardWindowOriginX:parentBoardWindow.frame.origin.x - shiftWidth
//                                                              originY:parentBoardWindow.frame.origin.y - shiftHeight
//                                                                width:sonBoardWindow.frame.size.width
//                                                               height:sonBoardWindow.frame.size.height];
//                break;
//            case UIInterfaceOrientationPortrait:
//            default:
//                sonBoardWindow.center = [self checkBoardWindowOriginX:parentBoardWindow.frame.origin.x + shiftWidth
//                                                              originY:parentBoardWindow.frame.origin.y + shiftHeight
//                                                                width:sonBoardWindow.frame.size.width
//                                                               height:sonBoardWindow.frame.size.height];
//                break;
//        }
//        
//        [_MCTouchDotButtonXArray replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:sonBoardWindow.center.x]];
//        [_MCTouchDotButtonYArray replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:sonBoardWindow.center.y]];
//        
//        // 更新各功能鈕向量，需有方向別
//        [self updateBoardWindowVectorIndex:i
//                                   originX:sonBoardWindow.frame.origin.x
//                                   originY:sonBoardWindow.frame.origin.y
//                                     width:sonBoardWindow.frame.size.width
//                                    height:sonBoardWindow.frame.size.height];
//        
//        shiftWidth += sonBoardWindow.frame.size.width;
//        shiftHeight += sonBoardWindow.frame.size.height;
//    }
//}

/*
 * @brief Client設定替換成Server設定
 */
- (void) replaceMCTouchDotButtonHiddenArrayFromServer
{
    for (int i = 0; i < [[MCInfoObject sharedInstance] MCTouchDotCounts]; i++)
    {
        [_MCTouchDotButtonHiddenArray replaceObjectAtIndex:i withObject:[_serverMCTouchDotButtonHiddenArray objectAtIndex:i]];
    }
    NSLog(@"replaceMCTouchDotButtonHiddenArrayFromServer 跑");
}
/*
 * @brief 換按鈕圖案
 */
- (void)autoChengeButtonUpDownImageWithWindow:(UIWindow*)currentWindow
{
    if (dotIsDrag == NO)
    {
        for (MCTouchDotBoardView *subView in currentWindow.rootViewController.view.subviews)
//        for (MCTouchDotBoardView *subView in currentWindow.subviews)
        {
            if (subView.tag == MCTouchDotButtonMain)
            {
                if (_isOpen == YES)
                {
                    subView.layer.contents = (__bridge id _Nullable)([(UIImage *)[imageArray firstObject] CGImage]);
                }else
                {
                    subView.layer.contents = (__bridge id _Nullable)([(UIImage *)[imageArray lastObject] CGImage]);
                }
            }
        }
    }
}
/*
 * @brief 處理拖曳手勢
 */
- (void) mcHandlePan:(UIPanGestureRecognizer*) recognizer
{
    if (recognizer.view.tag == MCTouchDotButtonMain)
    {
        if (!_isOpen)//沒開啟時才能拖曳
        {
            UIWindow *boardWindow = [_boardWindowArray objectAtIndex:recognizer.view.tag];
            [self autoChengeButtonUpDownImageWithWindow:boardWindow];
            dotIsDrag = YES;
            CGPoint cVector = CGPointMake(0, 0);
            cVector = [self correctVectorWithCurrentPosition:[self positionFromString:initPosition]
                                                     withRecognizer:recognizer];
            boardWindow.center = [self checkBoardWindowOriginX:boardWindow.frame.origin.x + cVector.x
                                                       originY:boardWindow.frame.origin.y + cVector.y
                                                         width:boardWindow.frame.size.width
                                                        height:boardWindow.frame.size.height];
            
            [_MCTouchDotButtonXArray replaceObjectAtIndex:recognizer.view.tag withObject:[NSNumber numberWithFloat:boardWindow.center.x]];
            [_MCTouchDotButtonYArray replaceObjectAtIndex:recognizer.view.tag withObject:[NSNumber numberWithFloat:boardWindow.center.y]];
            
            // 更新各功能鈕向量，需有方向別
            [self updateBoardWindowVectorIndex:recognizer.view.tag
                                       originX:boardWindow.frame.origin.x
                                       originY:boardWindow.frame.origin.y
                                         width:boardWindow.frame.size.width
                                        height:boardWindow.frame.size.height];
            NSLog(@"Frame :%@",NSStringFromCGRect(self.view.frame));
            NSLog(@"bounds :%@",NSStringFromCGRect(self.view.bounds));
            NSLog(@"recognizer Frame :%@",NSStringFromCGRect(recognizer.view.frame));
            NSLog(@"boardWindow Frame :%@",NSStringFromCGRect(boardWindow.frame));
            NSLog(@"boardWindow bound :%@",NSStringFromCGRect(boardWindow.bounds));
            NSLog(@"recognizer Frame :%@",NSStringFromCGRect(recognizer.view.frame));
            NSLog(@"recognizer bound :%@",NSStringFromCGRect(recognizer.view.bounds));
            NSLog(@"superview Frame :%@",NSStringFromCGRect(recognizer.view.superview.frame));
            NSLog(@"superview bound :%@",NSStringFromCGRect(recognizer.view.superview.bounds));
            NSLog(@"location point :%@",NSStringFromCGPoint([recognizer locationInView:self.view]));
            NSLog(@"translation point :%@",NSStringFromCGPoint([recognizer translationInView:self.view]));
            CGPoint p = [recognizer locationInView:self.view];
            if (CGRectContainsPoint(self.view.frame, p))
            {
                NSLog(@"it's inside");
            } else {
                NSLog(@"it's outside");
            }
            [recognizer setTranslation:CGPointZero inView:self.view];
            //回應速度矢量
            NSLog(@"Velocity : %@",NSStringFromCGPoint([recognizer velocityInView:self.view]));
            
            if ([recognizer state] == UIGestureRecognizerStateEnded && recognizer.view.tag == MCTouchDotButtonMain)
            {
                dotIsDrag = NO;
                //半透明
                [self MCTouchDotButtonMainTranslucent];
                NSLog(@"拖曳完了手放開");
                _isOpen = YES;
                //換按鈕圖案
                [self autoChengeButtonUpDownImageWithWindow:boardWindow];
                _isOpen = NO;
                //彈回原先位置
                [self detectDotToBoardWithPan];
            }
        }
    }
    else
    {
        NSLog(@"非主按鈕拖曳");
    }
}

/*
 * @brief 處理點擊手勢
 */
- (void) mcHandleTap:(UITapGestureRecognizer*) recognizer
{
    NSLog(@"正在點擊");
    UIWindow *boardWindow = [_boardWindowArray objectAtIndex:recognizer.view.tag];
    NSLog(@"Frame :%@",NSStringFromCGRect(self.view.frame));
    NSLog(@"Window Frame :%@",NSStringFromCGRect(self.view.window.frame));
    NSLog(@"boardWindow Frame :%@",NSStringFromCGRect(boardWindow.frame));
    NSLog(@"boardWindow bound :%@",NSStringFromCGRect(boardWindow.bounds));
    if (![recognizer.view.accessibilityIdentifier isEqualToString:@"theBG"])
    {
        [UIView animateWithDuration:0.2 animations:^
         {
             if (recognizer.view.tag != MCTouchDotButtonMain)
             {
                 boardWindow.rootViewController.view.alpha = 0.2;
             }
         } completion:^(BOOL finished)
         {
             boardWindow.rootViewController.view.alpha = 1.0;
             
         }];
    }
    
    NSNumber *MCTouchDotButtonVaild = [_MCTouchDotButtonVaildArray objectAtIndex:recognizer.view.tag];
    NSNumber *serverMCTouchDotButtonHidden = [_serverMCTouchDotButtonHiddenArray objectAtIndex:recognizer.view.tag];
    if (![serverMCTouchDotButtonHidden boolValue] && [MCTouchDotButtonVaild boolValue]) {
        //        [self performSelector:NSSelectorFromString([_MCTouchDotButtonEventArray objectAtIndex:recognizer.view.tag])];
        if (!self) { return; }
        SEL theSEL = NSSelectorFromString([_MCTouchDotButtonEventArray objectAtIndex:recognizer.view.tag]);
        IMP imp = [self methodForSelector:theSEL];
        void (*func)(id, SEL) = (void *)imp;
        func(self, theSEL);
    }
}
- (void)detectDotToBoardWithPan
{
    if (canSB== YES)
    {
        float bX = [[_MCTouchDotButtonXArray objectAtIndex:MCTouchDotButtonMain] floatValue];
        float bY = [[_MCTouchDotButtonYArray objectAtIndex:MCTouchDotButtonMain] floatValue];
//        float sW = ThePortraitWidth(self.view.frame.size.width, self.view.frame.size.height);
//        float sH = ThePortraitHeight(self.view.frame.size.width, self.view.frame.size.height);
        // 8.0新增
        float sW = 0.0;
        float sH = 0.0;
        if (CURRENT_DEV_Version<9.0&&(![initPosition isEqualToString:@"InitPositionPortrait"]))
        {
            if (CURRENT_DEV_Version<8.3)
            {
                sW = self.view.frame.size.height;
                sH = self.view.frame.size.width;
            }else
            {
                sW = self.view.frame.size.width;
                sH = self.view.frame.size.height;
            }
        }else
        {
            sW = self.view.frame.size.width;
            sH = self.view.frame.size.height;
        }
     
        float bxp = (bX/sW)*100;
        float byp = (bY/sH)*100;
        NSLog(@"x :%f y :%f",bX,bY);
        NSLog(@"x/Screen :%f y/Screen :%f",bxp,byp);
        
        CGPoint standBoard = CGPointMake(0,0);
        
        int orienx = (bxp >50) ?((byp>50)?2:1):((byp>50)?1:0);
        int orieny = (byp >50) ?1:0;
        int allorien = orienx + orieny;
        
        switch (allorien)
        {
            case 0:
                NSLog(@"左上");
                if (byp > 15.0)
                {
                    standBoard.x = 25;
                    standBoard.y = bY;
                }else
                {
                    standBoard.x = bX;
                    standBoard.y = 25;
                }
                break;
            case 1:
                NSLog(@"右上");
                if (byp > 15.0)
                {
                    standBoard.x = (sW - 25);
                    standBoard.y = bY;
                }else
                {
                    standBoard.x = bX;
                    standBoard.y = 25;
                }
                break;
            case 2:
                NSLog(@"左下");
                if (byp < 85.0)
                {
                    standBoard.x = 25;
                    standBoard.y = bY;
                }else
                {
                    standBoard.x = bX;
                    standBoard.y = (sH - 25);
                }
                break;
            case 3:
                NSLog(@"右下");
                if (byp < 85.0)
                {
                    standBoard.x = (sW - 25);
                    standBoard.y = bY;
                }else
                {
                    standBoard.x = bX;
                    standBoard.y = (sH - 25);
                }
                
                break;
            default:
                break;
        }
        UIWindow *boardWindow = [_boardWindowArray objectAtIndex:MCTouchDotButtonMain];
        theSBDotCurrentPoint = standBoard;
//        [boardWindow setFrame:CGRectMake(standBoard.x, standBoard.y, self.view.frame.size.height, self.view.frame.size.width)];
        [UIView animateWithDuration:[UIApplication sharedApplication].statusBarOrientationAnimationDuration
                         animations:^
         {
             boardWindow.center = standBoard;
         }];
    }
}
/*
 * @brief 處理啟動後旋轉
 */
- (void) deviceDidRotate:(NSNotification *) notification
{
    NSLog(@"deviceDidRotate: 跑 autoRotateOrientation");
    [self autoRotateOrientation];
}
- (void)detectOrientationSupport
{
    // get supported screen orientations
    NSArray *supportedOrientations = [[[NSBundle mainBundle] infoDictionary]
                                      objectForKey:@"UISupportedInterfaceOrientations"];
    NSString *supportedOrientationsStr = [supportedOrientations componentsJoinedByString:@" "];
    NSRange range = [supportedOrientationsStr rangeOfString:@"Portrait"];
    if ( range.location != NSNotFound )
    {
        NSLog(@"檢測方法 支持 正向");
        canPortait = YES;
    }else
    {
        NSLog(@"檢測方法 不支持 正向");
    }
    range = [supportedOrientationsStr rangeOfString:@"Landscape"];
    if ( range.location != NSNotFound )
    {
        NSLog(@"檢測方法 支持 橫向");
    }else
    {
        NSLog(@"檢測方法 不支持 橫向");
    }
}

/*
 * @brief 自動旋轉微平台
 */
- (void) autoRotateOrientation
{
    [self detectOrientationSupport];
// 先旋轉再移動
    CGAffineTransform rotationTransform = CGAffineTransformMakeRotation([self currentRotationAngle]);

    [UIView animateWithDuration:[UIApplication sharedApplication].statusBarOrientationAnimationDuration
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         for (int i = 0; i < [[MCInfoObject sharedInstance] MCTouchDotCounts]; i++)
                         {
                             UIWindow *boardWindow = [_boardWindowArray objectAtIndex:i];
                             //                                 NSNumber *boardWindowXVector = [_boardWindowXVector objectAtIndex:i];
                             //                                 NSNumber *boardWindowYVector = [_boardWindowYVector objectAtIndex:i];
                             // iOS 8.3之後UIWindow bounds不會旋轉，而frame會，所以非正方形時，就需要更新bounds後旋轉，才會顯示正確
                             MCTouchDotBoardView *boardView = [boardWindow.subviews lastObject];
                             if  (i == ([[MCInfoObject sharedInstance] MCTouchDotCounts]-1))
                             {
                                 
                                 if ((boardWindow.bounds.size.width != boardView.bounds.size.width))
                                 {
//                                     boardWindow.bounds = CGRectMake(0, 0, boardView.bounds.size.height, boardView.bounds.size.width);
                                 }
                                 // 8.0新增
                                  if (CURRENT_DEV_Version<9.0)
                                  {
                                      if (![initPosition isEqualToString:@"InitPositionPortrait"])
                                      {
                                          if (currentPosition != CurrentPositionPortrait)
                                          {
                                              boardWindow.transform = rotationTransform;
                                              if (CURRENT_DEV_Version >8.2)
                                              {
                                                  [boardWindow setFrame:CGRectMake(0, 0, boardWindow.frame.size.width,   boardWindow.frame.size.height)];
                                              }
                                          }
                                      }
                                  }
                                 
                                 
                             }else
                             {
                                 if ((boardWindow.bounds.size.width != boardView.bounds.size.width))
                                 {
//                                     boardWindow.bounds = CGRectMake(0, 0, boardView.bounds.size.height, boardView.bounds.size.width);
                                 }
                                 
                                         boardWindow.transform = rotationTransform;
                                  
                             }
                         }
                     }
                     completion:^(BOOL finished){
                         NSLog(@"autoRotateOrientation 跑");
                         
                     }];
}
/*
 * @brief 確認微平台中心位置，檢查是否超出螢幕邊界用origin，但origin是唯讀，所以回傳center設定用
 * @return Center CGPoint
 */
- (CGPoint) checkBoardWindowOriginX:(float) x
                            originY:(float) y
                              width:(float) width
                             height:(float) height
{
    // 8.0新增
    if ((CURRENT_DEV_Version<9.0)&&(![initPosition isEqualToString:@"InitPositionPortrait"]))
    {
        if (CURRENT_DEV_Version<8.3)
        {
            x = x + width > _screenHeight ? _screenHeight - width : x;
            x = x < 0 ? 0 : x;
            y = y + height > _screenWidth ? _screenWidth - height : y;
            y = y < 0 ? 0 : y;
        }else
        {
            x = x + width > _screenWidth ? _screenWidth - width : x;
            x = x < 0 ? 0 : x;
            y = y + height > _screenHeight ? _screenHeight - height : y;
            y = y < 0 ? 0 : y;
        }
        
        
    }else
    {
        x = x + width > _screenWidth ? _screenWidth - width : x;
        x = x < 0 ? 0 : x;
        y = y + height > _screenHeight ? _screenHeight - height : y;
        y = y < 0 ? 0 : y;
    }
    return CGPointMake(x + width / 2, y + height / 2);
}

/*
 * @brief 更新功能鈕原點的向量，有方向別
 */
- (void) updateBoardWindowVectorIndex:(NSInteger) i
                              originX:(float) x
                              originY:(float) y
                                width:(float) width
                               height:(float) height
{
    switch ([self getOrientation])
    {
        case UIInterfaceOrientationLandscapeLeft:
            [_boardWindowXVector replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:1.0 - (y + height) / _screenHeight]];
            [_boardWindowYVector replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:x / _screenWidth]];
            break;
        case UIInterfaceOrientationLandscapeRight:
            [_boardWindowXVector replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:y / _screenHeight]];
            [_boardWindowYVector replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:1.0 - (x + width) / _screenWidth]];
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            [_boardWindowXVector replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:1.0 - (x + width) / _screenWidth]];
            [_boardWindowYVector replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:1.0 - (y + height) / _screenHeight]];
            break;
        case UIInterfaceOrientationPortrait:
        default:
            [_boardWindowXVector replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:x / _screenWidth]];
            [_boardWindowYVector replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:y / _screenHeight]];
            break;
    }
}
#pragma mark - http method

/*
 * @brief 取得Server端設定(最高權限):每隔時間區間才檢查
 */
- (void) checkServerSet:(double) timeInterval
{
//    if (-[serverMCTouchDotCheckTime timeIntervalSinceNow] > timeInterval)
//    {
//        NSLog(@"checkServerSet: 跑checkServerSet");
//        [self checkServerSet];
//    }
}

/*
 * @brief 取得Server端設定(最高權限):立即檢查並更新設定與時間，若連線或檢查失敗則維持原設定，而不恢復預設
 */
- (void) checkServerSet
{
//    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:[[SCOauthServer sharedApplication] clientId], @"client_id", nil];
//    NSDictionary *responseData = [SCHttpRequest synchronousUrl:[[MCInfoObject sharedInstance] isg_SDKSetURL] params:params];
//    NSLog(@"responseData :%@", responseData);
//    if (responseData && [[NSString stringWithFormat:@"%@", [responseData valueForKey:@"valid"]] isEqual:@"1"]) {
//        // 時間區間
//        if ([responseData valueForKey:@"TimeInterval"]) {
//            serverMCTouchDotTimeInterval = [[responseData valueForKey:@"TimeInterval"] doubleValue] * 60.0;
//        }
//        
//        // 微平台啟用表不隱藏
//        if ([responseData valueForKey:@"sdk_platform"]) {
//            serverMCTouchDotHiddenState = ![[responseData valueForKey:@"sdk_platform"] boolValue];
//        }
//        
//        // 各功能啟用與否
//        if ([responseData valueForKey:@"sdk_gateway"]) {
//            [_serverMCTouchDotButtonHiddenArray replaceObjectAtIndex:MCTouchDotButtonPurchase withObject:[NSNumber numberWithBool:![[responseData valueForKey:@"sdk_gateway"] boolValue]]];
//        }
//    }
//    serverMCTouchDotTimeInterval = 1800;
    serverMCTouchDotHiddenState = NO;
    NSLog(@"checkServerSet 跑");
    [self refreshSetup];
//    serverMCTouchDotCheckTime = [NSDate date];
}

#pragma mark - callback method

// 執行http request(post asynchronous)後callback
- (void) receivedData:(id) receivedData msg:(NSString *) msg event:(NSString *) event
{
    NSLog(@"\nresponse data : %@\nmsg : %@\nevent : %@", receivedData, msg, event);
}

#pragma mark - button method

/*------第三步：實作------*/
/*
 * @brief 主要按鈕：展開收合
 */
- (void) MCTouchDotButtonMainEvent
{
//    [self setBlaclCover];
    
    if (_isOpen)
    {
        [UIView animateWithDuration:[UIApplication sharedApplication].statusBarOrientationAnimationDuration
                         animations:^
         {
             NSNumber *_MCTouchDotButtonX = [_MCTouchDotButtonXArray objectAtIndex:MCTouchDotButtonMain];
             NSNumber *_MCTouchDotButtonY = [_MCTouchDotButtonYArray objectAtIndex:MCTouchDotButtonMain];
             for (int i = 0; i < [[MCInfoObject sharedInstance] MCTouchDotCounts]; i++)
             {
                 UIWindow *boardWindow = [_boardWindowArray objectAtIndex:i];
                 if (i == ([[MCInfoObject sharedInstance] MCTouchDotCounts]-1))
                 {
                     boardWindow.alpha = 0.0;
                 }else if (i == MCTouchDotButtonMain)
                 {
                     [self autoChengeButtonUpDownImageWithWindow:boardWindow];
                 }else
                 {
                     boardWindow.alpha = 0.0;
                     boardWindow.center = CGPointMake([_MCTouchDotButtonX floatValue], [_MCTouchDotButtonY floatValue]);
                 }
             }
         }
                         completion:^(BOOL finished)
         {
             if (finished == YES)
             {
                 // 隱藏各功能鈕並恢復位置以因應旋轉
                 for (int i = 0; i < [[MCInfoObject sharedInstance] MCTouchDotCounts]; i++)
                 {
                     UIWindow *boardWindow = [_boardWindowArray objectAtIndex:i];
                     boardWindow.hidden = i == MCTouchDotButtonMain ? serverMCTouchDotHiddenState : YES;
                     NSNumber *_MCTouchDotButtonX = [_MCTouchDotButtonXArray objectAtIndex:i];
                     NSNumber *_MCTouchDotButtonY = [_MCTouchDotButtonYArray objectAtIndex:i];
                     if (i == ([[MCInfoObject sharedInstance] MCTouchDotCounts]-1))
                     {
                     }else if (i == MCTouchDotButtonMain)
                     {
                         [UIView animateWithDuration:0.3 animations:^
                         {
                             boardWindow.center = theSBDotCurrentPoint;
                         }];
                     }
                     else
                     {
                         //                      boardWindow.alpha = 1.0;
                         boardWindow.center = CGPointMake([_MCTouchDotButtonX floatValue], [_MCTouchDotButtonY floatValue]);
                     }
                 }
                 _isOpen = NO;
                 _openNow = NO;
                 [self MCTouchDotButtonMainTranslucent];
             }
         }];
    } else
    {
        [_MCTouchDotButtonXArray replaceObjectAtIndex:MCTouchDotButtonMain withObject:[NSNumber numberWithFloat:centerX]];
        [_MCTouchDotButtonYArray replaceObjectAtIndex:MCTouchDotButtonMain withObject:[NSNumber numberWithFloat:centerY]];
        // 更新主功能鈕向量，需有方向別
        [self updateBoardWindowVectorIndex:MCTouchDotButtonMain
                                   originX:centerX
                                   originY:centerY
                                     width:DefaultWidth
                                    height:DefaultWidth];
        [UIView animateWithDuration:0.3 animations:^
         {
             UIWindow *boardWindow = [_boardWindowArray objectAtIndex:MCTouchDotButtonMain];
             [self autoChengeButtonUpDownImageWithWindow:boardWindow];
             boardWindow.center = CGPointMake(centerX, centerY);
             
         }
                         completion:^(BOOL finished)
         {
             
             if (finished == YES)
             {
                 [UIView animateWithDuration:0.0 animations:^
                 {
                     // 各功能鈕先移動到主鍵下再顯示後移動
                     NSNumber *_MCTouchDotButtonX = [_MCTouchDotButtonXArray objectAtIndex:MCTouchDotButtonMain];
                     NSNumber *_MCTouchDotButtonY = [_MCTouchDotButtonYArray objectAtIndex:MCTouchDotButtonMain];
                     for (int i = 0; i < [[MCInfoObject sharedInstance] MCTouchDotCounts]; i++)
                     {
                         UIWindow *boardWindow = [_boardWindowArray objectAtIndex:i];
                         NSNumber *MCTouchDotButtonHidden = [_MCTouchDotButtonHiddenArray objectAtIndex:i];
                         NSNumber *serverMCTouchDotButtonHidden = [_serverMCTouchDotButtonHiddenArray objectAtIndex:i];
                         if (i == ([[MCInfoObject sharedInstance] MCTouchDotCounts]-1))
                         {
                             boardWindow.alpha = 0.3;
                         }
                         else if (i == MCTouchDotButtonMain)
                         {
                             
//                             boardWindow.center = CGPointMake(centerX, centerY);
                         }else
                         {
                             boardWindow.center = CGPointMake(centerX, centerY);
//                             boardWindow.alpha = 1.0;
//                             boardWindow.center = CGPointMake([_MCTouchDotButtonX floatValue], [_MCTouchDotButtonY floatValue]);
                         }
                         NSLog(@"before MCTouchDotButtonX :%@\nbefore MCTouchDotButtonY :%@",_MCTouchDotButtonX,_MCTouchDotButtonY);
                         boardWindow.hidden = serverMCTouchDotHiddenState || [serverMCTouchDotButtonHidden boolValue] ? YES : [MCTouchDotButtonHidden boolValue];
                     }
                 } completion:^(BOOL finished)
                 {
                     for (int i = 0; i < [[MCInfoObject sharedInstance] MCTouchDotCounts]; i++)
                     {
                         UIWindow *boardWindow = [_boardWindowArray objectAtIndex:i];
                         
                         NSNumber *_MCTouchDotButtonX = [_MCTouchDotButtonXArray objectAtIndex:i];
                         NSNumber *_MCTouchDotButtonY = [_MCTouchDotButtonYArray objectAtIndex:i];
                         NSLog(@"after MCTouchDotButtonX :%@\nafter MCTouchDotButtonY :%@",_MCTouchDotButtonX,_MCTouchDotButtonY);
                         if (i == ([[MCInfoObject sharedInstance] MCTouchDotCounts]-1))
                         {
                             
                         }else if (i == MCTouchDotButtonMain)
                         {
                             
                         }else
                         {
                             [UIView animateWithDuration:0.1*i
                                              animations:^
                              {
                                  boardWindow.alpha = 1.0;
                                  boardWindow.center = CGPointMake([_MCTouchDotButtonX floatValue], [_MCTouchDotButtonY floatValue]);
                              }completion:nil];
                         }
                     }
                     _isOpen = YES;
                     _openNow = YES;
                     [self MCTouchDotButtonMainOpaque];
                     NSLog(@"完成");
                 }];
             }
         }];
    }
}
/*
 * @brief 主功能：會員專區
 */
- (void) MCTouchDotButtonMyEvent
{
    NSLog(@"\nButton 1 MCTouchDotButtonMyEvent");
    NSLog(@"\n網頁重整");
//    [[self returnCurrentWKWebView] reload];
    [[self returnCurrentUIWebView] reload];
    [self MCTouchDotButtonMainEvent];
}

/*
 * @brief 主功能：客服回報
 */
- (void) MCTouchDotButtonSupportEvent {
    NSLog(@"\nButton 2 MCTouchDotButtonSupportEvent");
    NSLog(@"\n上一首");
    
//    [[self returnCurrentWKWebView] evaluateJavaScript:@"prev()" completionHandler:nil];
    [[self returnCurrentUIWebView] stringByEvaluatingJavaScriptFromString:@"prev()"];
}

/*
 * @brief 主功能：遊戲直儲
 */
- (void) MCTouchDotButtonPurchaseEvent {
    NSLog(@"Button 3 MCTouchDotButtonPurchaseEvent");
    NSLog(@"\n下一首");
//    [[self returnCurrentWKWebView] evaluateJavaScript:@"next()" completionHandler:nil];
    [[self returnCurrentUIWebView] stringByEvaluatingJavaScriptFromString:@"next()"];
}

/*
 * @brief 主功能：序號兌換
 */
- (void) MCTouchDotButtonRedeemEvent {
    NSLog(@"Button 4 MCTouchDotButtonRedeemEvent");
    NSLog(@"\n隱藏歌單");
//    [[self returnCurrentWKWebView] evaluateJavaScript:@"hide()" completionHandler:nil];
    [[self returnCurrentUIWebView] stringByEvaluatingJavaScriptFromString:@"hide()"];
}

/*
 * @brief 主功能：遊戲資訊
 */
- (void) MCTouchDotButtonGameEvent {
    NSLog(@"Button 5 MCTouchDotButtonGameEvent");
    NSLog(@"\n整理並匯出歌單");
    [self MCTouchDotButtonMainEvent];
    [self performSelector:@selector(downawhile:) withObject:@"download()" afterDelay:0.5];
    
}
- (void)downawhile:(NSString *)jsString
{
    [MCTouchDotViewController hiddenMCTouchDot];
//    [[self returnCurrentWKWebView] evaluateJavaScript:jsString completionHandler:nil];
    [[self returnCurrentUIWebView] stringByEvaluatingJavaScriptFromString:jsString];
}
/*
 * @brief 主功能：社群分享
 */
- (void) MCTouchDotButtonShareEvent {
    NSLog(@"Button 6 MCTouchDotButtonShareEvent");
    NSLog(@"\n匯入歌單");
    [self MCTouchDotButtonMainEvent];
    [self performSelector:@selector(downawhile:) withObject:@"upload()" afterDelay:0.5];

}

/*
 * @brief 「我的」子功能：修改資料
 */
- (void) MCTouchDotButtonMyProfileEvent {
    NSLog(@"Button 7 MCTouchDotButtonMyProfileEvent");
    BOOL bpIsOpen =[(AppDelegate *)[[UIApplication sharedApplication] delegate] backplay];
    [self MCTouchDotButtonMainEvent];
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] setBackplay:!bpIsOpen];
    

}

/*
 * @brief 「我的」子功能：帳號綁定
 */
- (void) MCTouchDotButtonMyBindingEvent {
    NSLog(@"MCTouchDotButtonMyBindingEvent");

}

/*
 * @brief 「我的」子功能：訊息箱
 */
- (void) MCTouchDotButtonMyMessageEvent {
    NSLog(@"MCTouchDotButtonMyMessageEvent");
}

/*
 * @brief 「遊戲」子功能：遊戲活動
 */
- (void) MCTouchDotButtonGameEventEvent {
    NSLog(@"MCTouchDotButtonGameEventEvent");
}

/*
 * @brief 「遊戲」子功能：遊戲公告
 */
- (void) MCTouchDotButtonGameNoticeEvent {
    NSLog(@"MCTouchDotButtonGameNoticeEvent");
}

/*
 * @brief 「遊戲」子功能：遊戲FAQ
 */
- (void) MCTouchDotButtonGameFaqEvent {
    NSLog(@"MCTouchDotButtonGameFaqEvent");
}

/*
 * @brief 「遊戲」子功能：遊戲攻略
 */
- (void) MCTouchDotButtonGameGuideEvent {
    NSLog(@"MCTouchDotButtonGameGuideEvent");
}

/*
 * @brief 「遊戲」子功能：遊戲百科
 */
- (void) MCTouchDotButtonGameDataEvent {
    NSLog(@"MCTouchDotButtonGameDataEvent");
}

/*
 * @brief 「分享」子功能：分享到Facebook
 */
- (void) MCTouchDotButtonShareTofbEvent {
    NSLog(@"MCTouchDotButtonShareTofbEvent");
}

/*
 * @brief 「分享」子功能：分享到Google+
 */
- (void) MCTouchDotButtonShareTogEvent {
    NSLog(@"MCTouchDotButtonShareTogEvent");
}

/*
 * @brief 「分享」子功能：分享到LINE
 */
- (void) MCTouchDotButtonShareTolineEvent {
    NSLog(@"MCTouchDotButtonShareTolineEvent");
}
/*
 * @brief 「自製儲值前準備」子功能
 */
- (void) MCTouchDotButtonCustomPreparePurchase
{
    NSLog(@"MCTouchDotButtonCustomPreparePurchase");

}


/*
 * @brief 「自製儲值投錢」子功能
 */
- (void) MCTouchDotButtonCustomBuyPurchase
{
    NSLog(@"MCTouchDotButtonCustomBuyPurchase");
//    [[MCFunctionView sharedApplication] mc_BuyWithPID:@"demoapp.item.two"
//                                             withHash:@"123123"
//                                             callback:^(BOOL resoult, NSString *message)
//    {
//        if (resoult == YES)
//        {
//            NSLog(@"儲值成功");
//        }else
//        {
//            NSLog(@"儲值失敗");
//        }
//    }];
   
//    [[InAppPurchase sharedInstance]  buyButtonTappedWithPID:@"demoapp.item.two"
//                                                   callback:^(BOOL resoult, NSString *message)
//     {
//         
//         if (resoult == YES)
//         {
//             NSString *messageContent ;
//             if (message == nil)
//             {
//                 messageContent = @"Restore成功";
//             }else
//             {
//                 messageContent = @"購買成功成功";
//             }
//             
//             UIAlertView *alertView = [[UIAlertView alloc]
//                                       initWithTitle:@"server 回傳購買"
//                                       message:messageContent
//                                       delegate:nil
//                                       cancelButtonTitle:@"好"
//                                       otherButtonTitles: nil];
//             [alertView performSelectorOnMainThread:@selector(show)
//                                         withObject:nil
//                                      waitUntilDone:NO];
//             NNSLog(@"server回傳 購買成功");
//             
//             
//         }else
//         {
//             
//             UIAlertView *alertView = [[UIAlertView alloc]
//                                       initWithTitle:@"error_message"
//                                       message:message
//                                       delegate:nil
//                                       cancelButtonTitle:@"好"
//                                       otherButtonTitles: nil];
//             [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
//             //    [alertView show];
//             NNSLog(@"server回傳 購買失敗");
//             
//         }
//     }];
    
}
- (void)MCBG
{
    NSLog(@"MCBG 背景被按到了");
    if (_isOpen == YES)
    {
        
        [self MCTouchDotButtonMainEvent];
    }
}
- (void)setBlaclCover
{
    NSLog(@"set InterFace :%@\nset StatusBarOrientation :%@",[self returnCurrectOrientationString:[[UIDevice currentDevice] orientation]],[self returnCurrectStatusBarOrientationString:[[UIApplication sharedApplication] statusBarOrientation]]);
    [self autoRotateOrientation];
}

- (void)saveButtonDownImage
{
    NSLog(@"設置按鈕圖案");
    CGSize imageSize =  CGSizeMake(DefaultWidth, DefaultWidth);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    
    [[UIImage imageNamed:@"ButtonUp.png"] drawInRect:CGRectMake(0.0, 0.0, DefaultWidth, DefaultWidth)];
    UIImage *imageUp = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    [[UIImage imageNamed:@"ButtonDown.png"] drawInRect:CGRectMake(0.0, 0.0, DefaultWidth, DefaultWidth)];
    UIImage *imageDown = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    if (imageArray == nil)
    {
        imageArray = [[NSArray alloc] initWithObjects:imageUp,imageDown, nil];
        NSLog(@"按鈕圖案Array初始化");
    }
}
/*
 * @brief 返回本體Portrait與當下Device角度的差值
 */
- (CGFloat) currentRotationAngle
{
    // 旋轉量
    CGFloat rotation = 0;
    
    switch ([self getOrientation])
    {
        case UIInterfaceOrientationLandscapeLeft:
            NSLog(@"左橫");
            if (initPosition == nil)
            {
                initPosition = @"InitPositionLandscapeLeft";
            }
            
            if (canPortait == YES)
            {
                if (checkRotation == NO )
                {
                    checkRotation = YES;
                    // 8.0新增
                    if (CURRENT_DEV_Version<9.0)
                    {
                        currentPosition = CurrentPositionLandscapeLeft;
                        rotation = -M_PI_2;
                    }
                    else
                    {
                        
                    }
                }
                else
                {
                    if (CURRENT_DEV_Version<9.0)
                    {
                        currentPosition = CurrentPositionLandscapeLeft;
                        rotation = -M_PI_2;
                    }
                    else
                    {
                        rotation = [self currentRotationToDestanyRota:CurrentPositionLandscapeLeft];
                    }
                }
            }else
            {
                if (checkRotation == NO )
                {
                    checkRotation = YES;
                    // 8.0新增
                    if (CURRENT_DEV_Version<9.0)
                    {
                        currentPosition = CurrentPositionLandscapeLeft;
                        if (CURRENT_DEV_Version < 8.3)
                        {
                            rotation = -M_PI_2;
                        }
                        
                    }else
                    {
                        
                    }
                    
                }else
                {
                    checkRotation = NO;
                    // 8.0新增
                    if (CURRENT_DEV_Version<9.0)
                    {
                        currentPosition = CurrentPositionLandscapeLeft;
                        if (CURRENT_DEV_Version < 8.3)
                        {
                            rotation = -M_PI_2;
                        }else
                        {
                            rotation = -M_PI_2*2;
                        }
                        
                    }else
                    {
                        rotation = -M_PI;
                    }
                }
            }
            break;
        case UIInterfaceOrientationLandscapeRight:
            NSLog(@"右橫");
            if (initPosition == nil)
            {
                initPosition = @"InitPositionLandscapeRight";
            }
            if (canPortait == YES)
            {
                if (checkRotation == NO )
                {
                    checkRotation = YES;
                    
                    // 8.0新增
                    if (CURRENT_DEV_Version<9.0)
                    {
                        currentPosition = CurrentPositionLandscapeRight;
                        rotation = M_PI_2;
                    }else
                    {
                        
                    }
                }else
                {
                    // 8.0新增
                    if (CURRENT_DEV_Version<9.0)
                    {
                        currentPosition = CurrentPositionLandscapeRight;
                        rotation = M_PI_2;
                    }else
                    {
                        rotation = [self currentRotationToDestanyRota:CurrentPositionLandscapeRight];
                    }
                }
            }else
            {
                if (checkRotation == NO )
                {
                    checkRotation = YES;
                    // 8.0新增
                    if (CURRENT_DEV_Version<9.0)
                    {
                        currentPosition = CurrentPositionLandscapeRight;
                        if (CURRENT_DEV_Version < 8.3)
                        {
                            rotation = M_PI_2;
                        }
                        
                    }else
                    {
                        
                    }
                    
                }else
                {
                    checkRotation = NO;
                    // 8.0新增
                    if (CURRENT_DEV_Version<9.0)
                    {
                        currentPosition = CurrentPositionLandscapeRight;
                        if (CURRENT_DEV_Version < 8.3)
                        {
                            rotation = M_PI_2;
                        }else
                        {
                            rotation = M_PI_2*2;
                        }
                        
                    }else
                    {
                        rotation = -M_PI;
                    }
                }
            }
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            NSLog(@"下直");

            break;
        case UIInterfaceOrientationPortrait:
            NSLog(@"正直");
            if (checkRotation == NO )
            {
                checkRotation = YES;
                currentPosition = CurrentPositionPortrait;
                if (initPosition == nil)
                {
                    initPosition = @"InitPositionPortrait";
                }
            }else
            {
                // 8.0新增
                if (CURRENT_DEV_Version<9.0)
                {
                    currentPosition = CurrentPositionPortrait;
                    rotation = 0;
                }else
                {
                    rotation = [self currentRotationToDestanyRota:CurrentPositionPortrait];
                }
            }
        default:
            break;
    }
    return rotation;
}
/*
 * @brief 返回 由目前狀態 轉到目的狀態的正確角度
 */
- (CGFloat) currentRotationToDestanyRota:(CurrentScreenOrientaion)finalRota
{
    CGFloat finalRotation = 0;
    NSInteger theInitPosition = [self positionFromString:initPosition];
    switch (currentPosition)
    {
        case CurrentPositionPortrait:
//            //右橫
//            finalRotation = ((finalRota == 1)?-M_PI_2*2 :M_PI_2*0);
//            //直
//            finalRotation = ((finalRota == 1)?-M_PI_2*1 :M_PI_2*1);
//            //左橫
//            finalRotation = ((finalRota == 1)?-M_PI_2*0 :M_PI_2*2);
            
            finalRotation = ((finalRota == CurrentPositionLandscapeLeft)?-M_PI_2*theInitPosition:M_PI_2*(2-theInitPosition));
            break;
        case CurrentPositionLandscapeLeft:
//            finalRotation = ((finalRota == 0)?M_PI_2*3      :M_PI_2*0);
//            finalRotation = ((finalRota == 0)?M_PI_2*0      :M_PI_2*1);
//            finalRotation = ((finalRota == 0)?M_PI_2*1      :M_PI_2*2);
            
            finalRotation = ((finalRota == CurrentPositionPortrait)?M_PI_2*(1+(theInitPosition==2?theInitPosition:-1*theInitPosition)):M_PI_2*(2-theInitPosition));
            break;
        case CurrentPositionLandscapeRight:
//            finalRotation = ((finalRota == 0)?M_PI_2*3 :M_PI_2*2);
//            finalRotation = ((finalRota == 0)?M_PI_2*0 :M_PI_2*3);
//            finalRotation = ((finalRota == 0)?M_PI_2*1 :M_PI_2*0);
            
            finalRotation = ((finalRota == CurrentPositionPortrait)?M_PI_2*(1-(theInitPosition==2?-2:theInitPosition)) :M_PI_2*(theInitPosition == 1?3:theInitPosition));
            break;
            
        default:
            break;
    }
    currentPosition = finalRota;
    return finalRotation;
}
/*
 * @brief 取得方向，若裝置方向有偵測到，對任意iOS版本來講會最準，否則使用狀態列方向
 */
- (int) getOrientation
{
    NSLog(@"UIDevice InterFace :%@\nStatusBarOrientation :%@",[self returnCurrectOrientationString:[[UIDevice currentDevice] orientation]],[self returnCurrectStatusBarOrientationString:[[UIApplication sharedApplication] statusBarOrientation]]);
    
    return [[UIApplication sharedApplication] statusBarOrientation];
}
/*
 * @brief 返回 當前 DeviceOrientation 字串
 */
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
/*
 * @brief 返回 當前 StatusBarOrientation 字串
 */
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
/*
 * @brief 返回懸浮按鈕被拖曳的向量值終點
 */
- (CGPoint)correctVectorWithCurrentPosition:(CurrentScreenOrientaion)position
                             withRecognizer:(UIPanGestureRecognizer*)recognizer
{
    CGPoint thePoint = CGPointMake(0, 0);
    if (canPortait == YES)
    {// 可以直屛時 , 當前起始 statusbar 對應的 orientation
        if (position == InitPositionLandscapeLeft)
        {
            thePoint.x = -[recognizer translationInView:self.view].y;
            thePoint.y = [recognizer translationInView:self.view].x;
        }else if (position == InitPositionLandscapeRight)
        {
            thePoint.x = [recognizer translationInView:self.view].y;
            thePoint.y = -[recognizer translationInView:self.view].x;
        }else
        {
            thePoint.x = [recognizer translationInView:self.view].x;
            thePoint.y = [recognizer translationInView:self.view].y;
        }
    }else
    {// 只能橫屏時 , 當前起始 statusbar 對應的 orientation
        NSInteger theInitPositionInt = [self positionFromString:initPosition];
        thePoint.x =  [recognizer translationInView:self.view].y*(theInitPositionInt-1);
        thePoint.y =  -[recognizer translationInView:self.view].x*(theInitPositionInt-1);
    }
    return thePoint;
}
/*
 * @brief 返回當前裝置在初始化時,status bar 在左上右的狀態字串
 */
- (NSInteger)positionFromString:(NSString*)thePosition
{
    if ([thePosition isEqualToString:@"InitPositionLandscapeLeft"])
    {
        return InitPositionLandscapeLeft;
    }else if ([thePosition isEqualToString:@"InitPositionLandscapeRight"])
    {
        return InitPositionLandscapeRight;
    }else
    {
        return InitPositionPortrait;
    }
}
/*
 * @brief 返回當前UIWebview
 */
- (UIWebView *)returnCurrentUIWebView
{
    UIWindow * subWindow;
    UIWebView * currentWebview;
    for (subWindow in [[UIApplication sharedApplication] windows])
    {
        if ([subWindow.rootViewController isKindOfClass:[ViewController class]])
        {
            for (UIWebView * theWebview in subWindow.rootViewController.view.subviews)
            {
                if ([theWebview.accessibilityIdentifier isEqualToString:@"theUIWebView"])
                {
                    currentWebview = theWebview;
                    break;
                }
            }
        }
    }
    return currentWebview;
}
/*
 * @brief 返回當前WKWebview
 */
- (WKWebView *)returnCurrentWKWebView
{
    UIWindow * subWindow;
    WKWebView * currentWebview;
    for (subWindow in [[UIApplication sharedApplication] windows])
    {
        if ([subWindow.rootViewController isKindOfClass:[ViewController class]])
        {
            for (WKWebView * theWebview in subWindow.rootViewController.view.subviews)
            {
                if ([theWebview.accessibilityIdentifier isEqualToString:@"theWKWebView"])
                {
                    currentWebview = theWebview;
                    break;
                }
            }
        }
    }
    return currentWebview;
}



@end
