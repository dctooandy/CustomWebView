//
//  OverlayButton.m
//  OriginSDK
//
//  Created by brownie on 2015/4/28.
//  Copyright (c) 2015年 com.9388origin.sdk. All rights reserved.
//
#import "OverlayButton.h"

@implementation OverlayButton
+ (Class)layerClass
{
    return [CAGradientLayer class];
}
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupLayer];
    }
    return self;
}
-(void)setupLayer
{
    CAGradientLayer *layer = (CAGradientLayer *)self.layer;
    UIColor *lightColor = [UIColor clearColor];
    UIColor *middleColor = [UIColor colorWithWhite:0 alpha:0.35];
    UIColor *anotherColor = [UIColor colorWithWhite:0 alpha:0.65];
    UIColor *darkColor = [UIColor colorWithWhite:0 alpha:0.8];
    layer.colors = @[(id)lightColor.CGColor, (id)middleColor.CGColor, (id)anotherColor.CGColor, (id)darkColor.CGColor];
    layer.locations = @[@(0), @(0.2), @(0.65), @(1)];
}

- (void)setupCornerRadius:(CGFloat)cr WithBorderColor:(CGColorRef)bc WithBorderWidth:(CGFloat)bw MasksToBounds:(BOOL)mtb
{
    CAGradientLayer *layer = (CAGradientLayer *)self.layer;
    
    layer.cornerRadius = cr;
    layer.borderColor = bc;
    layer.borderWidth = bw;
    layer.masksToBounds = mtb;
}
- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
@end
