//
//  UIView+CornerMode.h
//  PromoteHelper
//
//  Created by 纪宇伟 on 2017/6/7.
//  Copyright © 2017年 willing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (CornerMode)

-(void)openCornerMode;
-(void)openCornerModeWithRadius:(CGFloat)radius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;

@end
