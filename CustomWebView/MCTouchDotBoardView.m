//
//  MCTouchDotBoardView.m
//  CustomWebView
//
//  Created by AndyChen on 2017/8/23.
//  Copyright © 2017年 AndyChen. All rights reserved.
//

#import "MCTouchDotBoardView.h"
#import "MCTouchDotViewController.h"
#import "Constant_m.h"
@implementation MCTouchDotBoardView
{
    UIBezierPath* aPath;
}

- (id) initWithFrame:(CGRect) frame
{
    self = [super initWithFrame:frame];
    //    [self setupAnimation];
    return self;
}

//- (void)setupAnimation
//{
//    self.eyeFirstLightLayer.lineWidth = 0.f;
//    self.eyeSecondLightLayer.lineWidth = 0.f;
//    self.eyeballLayer.opacity = 0.f;
//    _bottomEyesocketLayer.strokeStart = 0.5f;
//    _bottomEyesocketLayer.strokeEnd = 0.5f;
//    _topEyesocketLayer.strokeStart = 0.5f;
//    _topEyesocketLayer.strokeEnd = 0.5f;
//    [self.layer addSublayer:_eyeFirstLightLayer];
//    [self.layer addSublayer:_eyeSecondLightLayer];
//    [self.layer addSublayer:_eyeballLayer];
//    [self.layer addSublayer:_bottomEyesocketLayer];
//    [self.layer addSublayer:_topEyesocketLayer];
//}
//- (void)animationWith:(CGFloat)y
//{
//    CGFloat flag = self.frame.origin.y * 2.f - 20.f;
//    if (y < flag) {
//        if (self.eyeFirstLightLayer.lineWidth < 5.f) {
//            self.eyeFirstLightLayer.lineWidth += 1.f;
//            self.eyeSecondLightLayer.lineWidth += 1.f;
//        }
//    }
//
//    if(y < flag - 20) {
//        if (self.eyeballLayer.opacity <= 1.0f) {
//            self.eyeballLayer.opacity += 0.1f;
//        }
//
//    }
//
//    if (y < flag - 40) {
//        if (self.topEyesocketLayer.strokeEnd < 1.f && self.topEyesocketLayer.strokeStart > 0.f) {
//            self.topEyesocketLayer.strokeEnd += 0.1f;
//            self.topEyesocketLayer.strokeStart -= 0.1f;
//            self.bottomEyesocketLayer.strokeEnd += 0.1f;
//            self.bottomEyesocketLayer.strokeStart -= 0.1f;
//        }
//    }
//
//    if (y > flag - 40) {
//        if (self.topEyesocketLayer.strokeEnd > 0.5f && self.topEyesocketLayer.strokeStart < 0.5f) {
//            self.topEyesocketLayer.strokeEnd -= 0.1f;
//            self.topEyesocketLayer.strokeStart += 0.1f;
//            self.bottomEyesocketLayer.strokeEnd -= 0.1f;
//            self.bottomEyesocketLayer.strokeStart += 0.1f;
//        }
//    }
//
//    if (y > flag - 20) {
//        if (self.eyeballLayer.opacity >= 0.0f) {
//            self.eyeballLayer.opacity -= 0.1f;
//        }
//    }
//
//    if (y > flag) {
//        if (self.eyeFirstLightLayer.lineWidth > 0.f) {
//            self.eyeFirstLightLayer.lineWidth -= 1.f;
//            self.eyeSecondLightLayer.lineWidth -= 1.f;
//        }
//    }
//}



- (void)drawRect:(CGRect)rect
{
    if ([self.accessibilityIdentifier isEqualToString:@"theBG"])
    {
        [self drawHead];
        //        [self setupAnimation];
    }
}
- (void)drawHead
{
    [[UIColor lightGrayColor] set];
    
    aPath = [UIBezierPath bezierPath];
    //    switch ([[self mcs_TopViewController] supportedInterfaceOrientations])
    //    {
    //        case UIInterfaceOrientationMaskLandscape:
    //            NSLog(@"只能橫屏");
    //            [aPath addArcWithCenter:self.center radius:75.0 startAngle:0.0 endAngle:180.0 clockwise:YES];
    //            break;
    //        case UIInterfaceOrientationMaskAll:
    //        case UIInterfaceOrientationMaskAllButUpsideDown:
    //        case UIInterfaceOrientationMaskPortrait:
    //            NSLog(@"包含直屏");
    //            [aPath addArcWithCenter:self.center radius:75.0 startAngle:0.0 endAngle:180.0 clockwise:YES];
    ////            [aPath addArcWithCenter:CGPointMake(self.center.y, self.center.x) radius:75.0 startAngle:0.0 endAngle:180.0 clockwise:YES];
    //            break;
    //        default:
    //            break;
    //    }
    
    [aPath addArcWithCenter:self.center radius:75.0 startAngle:0.0 endAngle:180.0 clockwise:YES];
    [aPath setLineWidth:50];
    
    //畫出線條
    [aPath stroke];
}
// 點下瞬間
- (void) touchesBegan:(NSSet *) touches withEvent:(UIEvent *) event
{
    MCTouchDotViewController *MCTouchDot = [MCTouchDotViewController sharedApplication];
    if (self.tag == MCTouchDotButtonMain)
    {
        [MCTouchDot MCTouchDotButtonMainOpaque];
        return;
    }
    
    // 被點選者往上顯示，但不超過主要功能鈕
    for (int i = 0; i < [[MCInfoObject sharedInstance] MCTouchDotCounts]; i++)
    {
        UIWindow *boardWindow = [MCTouchDot.boardWindowArray objectAtIndex:i];
        if (i == ([[MCInfoObject sharedInstance] MCTouchDotCounts]-1))
        {
            boardWindow.windowLevel = 1994.0;
        }else
        {
            boardWindow.windowLevel = i == MCTouchDotButtonMain ? 1997.0 : 1995.0;
        }
    }
    if (![self.window.accessibilityIdentifier isEqualToString:@"theBG"])
    {
        self.window.windowLevel = 1996.0;
    }
    NSLog(@"點下 windowLevel :%f",self.window.windowLevel);
}

// 久按放開
- (void) touchesEnded:(NSSet *) touches withEvent:(UIEvent *) event
{
    if (self.tag == MCTouchDotButtonMain)
    {
        MCTouchDotViewController *MCTouchDot = [MCTouchDotViewController sharedApplication];
        [MCTouchDot MCTouchDotButtonMainTranslucent];
    }
    NSLog(@"放開");
}
- (int) getOrientation
{
    return [[UIApplication sharedApplication] statusBarOrientation];
}


//- (CAShapeLayer *)eyeFirstLightLayer
//{
//    if (!_eyeFirstLightLayer) {
//        _eyeFirstLightLayer = [CAShapeLayer layer];
//        CGPoint center = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2);
//        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center
//                                                            radius:CGRectGetWidth(self.frame) * 0.2
//                                                        startAngle:(230.f / 180.f) * M_PI
//                                                          endAngle:(265.f / 180.f) * M_PI
//                                                         clockwise:YES];
//        _eyeFirstLightLayer.borderColor = [UIColor blackColor].CGColor;
//        _eyeFirstLightLayer.lineWidth = 5.f;
//        _eyeFirstLightLayer.path = path.CGPath;
//        _eyeFirstLightLayer.fillColor = [UIColor clearColor].CGColor;
//        _eyeFirstLightLayer.strokeColor = [UIColor whiteColor].CGColor;
//    }
//    return _eyeFirstLightLayer;
//}
//
//- (CAShapeLayer *)eyeSecondLightLayer
//{
//    if (!_eyeSecondLightLayer) {
//        _eyeSecondLightLayer = [CAShapeLayer layer];
//        CGPoint center = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2);
//        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center
//                                                            radius:CGRectGetWidth(self.frame) * 0.2
//                                                        startAngle:(211.f / 180.f) * M_PI
//                                                          endAngle:(220.f / 180.f) * M_PI
//                                                         clockwise:YES];
//        _eyeSecondLightLayer.borderColor = [UIColor blackColor].CGColor;
//        _eyeSecondLightLayer.lineWidth = 5.f;
//        _eyeSecondLightLayer.path = path.CGPath;
//        _eyeSecondLightLayer.fillColor = [UIColor clearColor].CGColor;
//        _eyeSecondLightLayer.strokeColor = [UIColor whiteColor].CGColor;
//
//    }
//    return _eyeSecondLightLayer;
//}
//
//- (CAShapeLayer *)eyeballLayer
//{
//    if (!_eyeballLayer) {
//        _eyeballLayer = [CAShapeLayer layer];
//        CGPoint center = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2);
//        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center
//                                                            radius:CGRectGetWidth(self.frame) * 0.3
//                                                        startAngle:(0.f / 180.f) * M_PI
//                                                          endAngle:(360.f / 180.f) * M_PI
//                                                         clockwise:YES];
//        _eyeballLayer.borderColor = [UIColor blackColor].CGColor;
//        _eyeballLayer.lineWidth = 1.f;
//        _eyeballLayer.path = path.CGPath;
//        _eyeballLayer.fillColor = [UIColor clearColor].CGColor;
//        _eyeballLayer.strokeColor = [UIColor whiteColor].CGColor;
//        _eyeballLayer.anchorPoint = CGPointMake(0.5, 0.5);
//
//    }
//    return _eyeballLayer;
//}
//
//- (CAShapeLayer *)topEyesocketLayer
//{
//    if (!_topEyesocketLayer) {
//        _topEyesocketLayer = [CAShapeLayer layer];
//        CGPoint center = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2);
//        UIBezierPath *path = [UIBezierPath bezierPath];
//        [path moveToPoint:CGPointMake(0, CGRectGetHeight(self.frame) / 2)];
//        [path addQuadCurveToPoint:CGPointMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) / 2)
//                     controlPoint:CGPointMake(CGRectGetWidth(self.frame) / 2, center.y - center.y - 20)];
//        _topEyesocketLayer.borderColor = [UIColor blackColor].CGColor;
//        _topEyesocketLayer.lineWidth = 1.f;
//        _topEyesocketLayer.path = path.CGPath;
//        _topEyesocketLayer.fillColor = [UIColor clearColor].CGColor;
//        _topEyesocketLayer.strokeColor = [UIColor whiteColor].CGColor;
//    }
//    return _topEyesocketLayer;
//}
//
//- (CAShapeLayer *)bottomEyesocketLayer
//{
//    if (!_bottomEyesocketLayer) {
//        _bottomEyesocketLayer = [CAShapeLayer layer];
//        CGPoint center = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2);
//        UIBezierPath *path = [UIBezierPath bezierPath];
//        [path moveToPoint:CGPointMake(0, CGRectGetHeight(self.frame) / 2)];
//        [path addQuadCurveToPoint:CGPointMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) / 2)
//                     controlPoint:CGPointMake(CGRectGetWidth(self.frame) / 2, center.y + center.y + 20)];
//        _bottomEyesocketLayer.borderColor = [UIColor blackColor].CGColor;
//        _bottomEyesocketLayer.lineWidth = 1.f;
//        _bottomEyesocketLayer.path = path.CGPath;
//        _bottomEyesocketLayer.fillColor = [UIColor clearColor].CGColor;
//        _bottomEyesocketLayer.strokeColor = [UIColor whiteColor].CGColor;
//        
//    }
//    return _bottomEyesocketLayer;
//}

@end
