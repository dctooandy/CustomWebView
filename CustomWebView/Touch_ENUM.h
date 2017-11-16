//
//  Touch_ENUM.h
//  ISGlobalSDK
//
//  Created by AndyChen on 2017/3/24.
//  Copyright © 2017年 AndyChen. All rights reserved.
//

// 新增功能鈕需三步
/*------第一步：註冊------*/
// 主功能放置主功能區域，子功能放置所屬子功能區域
/*
 * @brief 各功能鈕名稱
 */
typedef NS_ENUM(NSUInteger, MCTouchDotButton)
{
    /*
     * @brief 主要按鈕：展開收合
     */
    MCTouchDotButtonMain,
    
    /*------主功能區域：開始------*/
    /*
     * @brief 主功能：會員專區
     */
    MCTouchDotButtonMy,
    
    /*
     * @brief 主功能：客服回報
     */
    MCTouchDotButtonSupport,
    
    /*
     * @brief 主功能：遊戲直儲
     */
    MCTouchDotButtonPurchase,
    
    /*
     * @brief 主功能：序號兌換
     */
    MCTouchDotButtonRedeem,
    
    /*
     * @brief 主功能：遊戲資訊
     */
    MCTouchDotButtonGame,
    
    /*
     * @brief 主功能：社群分享
     */
    MCTouchDotButtonShare,
    /*------主功能區域：結束------*/
    
    /*------「我的」子功能區域：開始------*/
    /*
     * @brief 「我的」子功能：修改資料
     */
    MCTouchDotButtonMyProfile,
    
    /*
     * @brief 「我的」子功能：帳號綁定
     */
    MCTouchDotButtonMyBinding,
    
    /*
     * @brief 「我的」子功能：訊息箱
     */
    MCTouchDotButtonMyMessage,
    /*------「我的」子功能區域：結束------*/
    
    /*------「遊戲」子功能區域：開始------*/
    /*
     * @brief 「遊戲」子功能：遊戲活動
     */
    MCTouchDotButtonGameEvent,
    
    /*
     * @brief 「遊戲」子功能：遊戲公告
     */
    MCTouchDotButtonGameNotice,
    
    /*
     * @brief 「遊戲」子功能：遊戲FAQ
     */
    MCTouchDotButtonGameFaq,
    
    /*
     * @brief 「遊戲」子功能：遊戲攻略
     */
    MCTouchDotButtonGameGuide,
    
    /*
     * @brief 「遊戲」子功能：遊戲百科
     */
    MCTouchDotButtonGameData,
    /*------「遊戲」子功能區域：結束------*/
    
    /*------「分享」子功能區域：開始------*/
    /*
     * @brief 「分享」子功能：分享到Facebook
     */
    MCTouchDotButtonShareTofb,
    
    /*
     * @brief 「分享」子功能：分享到Google+
     */
    MCTouchDotButtonShareTog,
    
    /*
     * @brief 「分享」子功能：分享到LINE
     */
    MCTouchDotButtonShareToline,
    /*------「分享」子功能區域：結束------*/
    
    /*
     * @brief 「除值前準備」
     */
    MCTouchDotButtonCustomPreparePurchase,
    /*------「儲值前準備」：結束------*/
    /*
     * @brief 「除值前準備」
     */
    MCTouchDotButtonCustomBuyPurchase,
    /*------「購買動作」：結束------*/
    /*
     * @brief 「背景黑屛」
     */
    MCBGCover,
    /*------「背景黑屛」：結束------*/
    /*
     * @brief 純粹計數
     */
    MCTouchDotButtonENUM_COUNT
};

// 功能鈕各客製化屬性(說明，預設，限制：型態。沒給，超限)
/*------Button------*/
/*
 * @brief 需客製化的功能鈕名稱(必要)，限制於ENUM(MCTouchDotButton)範圍內：NSNumber by ENUM(MCTouchDotButton)。沒給就不做任何變更，超限就不做任何變更
 */
static NSString *MCTouchDotButtonCustomName = @"MCTouchDotButtonCustomName";

/*
 * @brief 需客製化的功能鈕原點，相對於以HOME鍵為下方的直立式螢幕之左上原點，限制於螢幕範圍內：NSValue by CGPoint。沒給就維持上次設定，超限就取最接近位置
 */
static NSString *MCTouchDotButtonCustomOrigin = @"MCTouchDotButtonCustomOrigin";

/*
 * @brief 需客製化的功能鈕大小，預設為50x50，icon為26x26，word為50x24，限制至少50x50，至多100x100：NSValue by CGSize。沒給就維持上次設定，超限就取最接近大小
 */
static NSString *MCTouchDotButtonCustomSize = @"MCTouchDotButtonCustomSize";

/*
 * @brief 需客製化的功能鈕背景影像，預設clearColor：UIColor 或 UIImage 或 NSString(檔名.副檔名或路徑皆可)。沒給就維持上次設定
 */
static NSString *MCTouchDotButtonCustomBackground = @"MCTouchDotButtonCustomBackground";

/*------Icon------*/
/*
 * @brief 需客製化的功能鈕是否需要圖示，預設為YES：NSNumber by BOOL。沒給就為預設
 */
static NSString *MCTouchDotButtonCustomHasIcon = @"MCTouchDotButtonCustomHasIcon";

/*
 * @brief 需客製化的功能鈕圖示原點，相對於功能鈕之左上原點，預設為(12, 0)：NSValue by CGPoint。沒給就視Button大小動態設定
 */
static NSString *MCTouchDotButtonCustomIconOrigin = @"MCTouchDotButtonCustomIconOrigin";

/*
 * @brief 需客製化的功能鈕圖示大小，預設為26x26：NSValue by CGSize。沒給就視Button大小動態設定
 */
static NSString *MCTouchDotButtonCustomIconSize = @"MCTouchDotButtonCustomIconSize";

/*
 * @brief 需客製化的功能鈕圖示背景影像：UIColor(僅支援單色) 或 UIImage 或 NSString(檔名.副檔名或路徑皆可)。沒給就為預設
 */
static NSString *MCTouchDotButtonCustomIconBackground = @"MCTouchDotButtonCustomIconBackground";

/*------Word------*/
/*
 * @brief 需客製化的功能鈕是否需要文字，預設為YES：NSNumber by BOOL。沒給就為預設
 */
static NSString *MCTouchDotButtonCustomHasWord = @"MCTouchDotButtonCustomHasWord";

/*
 * @brief 需客製化的功能鈕文字區域原點，相對於功能鈕之左上原點，預設為(0, 26)：NSValue by CGPoint。沒給就為(0, 功能鈕高 - 24)
 */
static NSString *MCTouchDotButtonCustomWordBoundOrigin = @"MCTouchDotButtonCustomWordBoundOrigin";

/*
 * @brief 需客製化的功能鈕文字區域大小，預設為50x24：NSValue by CGSize。沒給就為功能鈕寬x24
 */
static NSString *MCTouchDotButtonCustomWordBoundSize = @"MCTouchDotButtonCustomWordBoundSize";

/*
 * @brief 需客製化的功能鈕文字區域前景色即文字顏色，預設blackColor：UIColor(僅支援單色)。沒給就為預設
 */
static NSString *MCTouchDotButtonCustomWordBoundForegroundColor = @"MCTouchDotButtonCustomWordBoundForegroundColor";

/*
 * @brief 需客製化的功能鈕文字區域背景色，預設whiteColor：UIColor(僅支援單色)。沒給就為預設
 */
static NSString *MCTouchDotButtonCustomWordBoundBackgroundColor = @"MCTouchDotButtonCustomWordBoundBackgroundColor";

/*
 * @brief 需客製化的功能鈕文字內容，預設中文至多三字，英文至多8字母：NSString。沒給就為預設
 */
static NSString *MCTouchDotButtonCustomWord = @"MCTouchDotButtonCustomWord";

/*
 * @brief 需客製化的功能鈕文字大小，預設中文16，英文10，限制至少10，至多30：NSNumber by Integer。沒給就為預設，超限就取最接近大小
 */
static NSString *MCTouchDotButtonCustomWordSize = @"MCTouchDotButtonCustomWordSize";

/*
 * @brief 需客製化的功能鈕文字排列，預設NSTextAlignmentCenter，限制於ENUM(NSTextAlignment)範圍內：NSNumber by ENUM(NSTextAlignment)。沒給就為預設，超限就為預設
 */
static NSString *MCTouchDotButtonCustomWordAlignment = @"MCTouchDotButtonCustomWordAlignment";


/*
 * @brief 記錄檢查Server端設定的時間點
 */
static NSDate *serverMCTouchDotCheckTime = nil;

/*
 * @brief Server端設定的檢查時間區間(seconds)
 */
static double serverMCTouchDotTimeInterval = 30.0 * 60.0;

/*
 * @brief Server端控制微平台隱藏與否的狀態
 */
static BOOL serverMCTouchDotHiddenState = YES;

/*
 * @brief 判斷微平台是否為啟動狀態
 */
static BOOL MCTouchDotStart = NO;

/*
 * @brief 記錄微平台現在隱藏與否的狀態
 */
static BOOL saveMCTouchDotHiddenState = YES;



