//
//  OverlayButton.h
//  sdk
//
//  Created by AndyChen on 2017/3/1.
//  Copyright © 2017年 sdk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OverlayButton : UIButton
- (instancetype)initWithFrame:(CGRect)frame;
- (void)setupCornerRadius:(CGFloat)cr WithBorderColor:(CGColorRef)bc WithBorderWidth:(CGFloat)bw MasksToBounds:(BOOL)mtb;
- (UIImage *)imageWithColor:(UIColor *)color;
@end
