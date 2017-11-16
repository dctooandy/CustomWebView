//
//  MCTouchDotViewController.h
//  ISGlobalSDK
//
//  Created by AndyChen on 2017/3/24.
//  Copyright © 2017年 AndyChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Touch_ENUM.h"
#import "Touch_Define.h"
//#import "ConstantDelegate.h"
#import "MCTouchDotBoardView.h"
@interface MCTouchDotViewController : UIViewController<UIGestureRecognizerDelegate>
/*
 * @brief 置頂微平台：陣列
 */
@property (strong, nonatomic) NSMutableArray *boardWindowArray;

/*
 * @brief 各功能鈕是否啟用：陣列
 */
@property (strong, nonatomic) NSMutableArray *MCTouchDotButtonVaildArray;

/*
 * @brief 各功能鈕是否隱藏：陣列
 */
@property (strong, nonatomic) NSMutableArray *MCTouchDotButtonHiddenArray;

/*
 * @brief 是否立即展開微平台
 */
@property BOOL openNow;

/*
 * @brief 是否立即隱藏微平台
 */
@property BOOL allHiddenNow;


//@property (nonatomic,weak) id<IsvDelegate>delegate;

/*
 * @brief 隱藏微平台：微平台若啟動並處於顯示狀態才需隱藏(會記錄微平台隱藏與否的狀態)
 */
+ (void) hiddenMCTouchDot;

/*
 * @brief 顯示微平台：微平台若啟動並「原本」處於顯示狀態才需顯示
 */
+ (void) showMCTouchDot;

/*
 * @brief 統一取得微平台單一實例：新產生或取得已產生過的 MCTouchDot 物件實例
 * @return MCTouchDot instance
 */
+ (MCTouchDotViewController*) sharedApplication;

/*
 * @brief 功能鈕客製化
 * @param MCTouchDotButtonCustomAttributes 客製化屬性
 */
- (void) MCTouchDotButtonCustomAttributes:(NSDictionary *) attributes;

/*
 * @brief 更新微平台設定：會自動判斷邊界等狀態
 */
- (void) refreshSetup;

/*
 * @brief 主要功能鈕於收合狀態下五秒後半透明
 */
- (void) MCTouchDotButtonMainTranslucent;

/*
 * @brief 主要功能鈕馬上不透明
 */
- (void) MCTouchDotButtonMainOpaque;

- (void) setDotButtonArrays;
- (void) secondAction;
- (void) resetHiddenButton;
@property (strong, nonatomic) CAShapeLayer *eyeFirstLightLayer;
@end

//// 為了使用UITouch
//@interface MCTouchDotBoardView : UIView
////@property (strong, nonatomic) CAShapeLayer *eyeFirstLightLayer;
////@property (strong, nonatomic) CAShapeLayer *eyeSecondLightLayer;
////@property (strong, nonatomic) CAShapeLayer *eyeballLayer;
////@property (strong, nonatomic) CAShapeLayer *topEyesocketLayer;
////@property (strong, nonatomic) CAShapeLayer *bottomEyesocketLayer;
//
//@end
