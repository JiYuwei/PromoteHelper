//
//  UIView+CornerMode.m
//  PromoteHelper
//
//  Created by 纪宇伟 on 2017/6/7.
//  Copyright © 2017年 willing. All rights reserved.
//

#import "UIView+CornerMode.h"

@implementation UIView (CornerMode)

-(void)openCornerMode
{
    return [self openCornerModeWithRadius:self.bounds.size.width/4 borderWidth:0 borderColor:nil];
}


/*
 给UIView加圆角和边框
 
 radius         圆角半径
 borderwidth    边框厚度
 borderColor    边框颜色
 */

-(void)openCornerModeWithRadius:(CGFloat)radius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor
{
    UIBezierPath *maskPath=[UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:radius];
    
    CAShapeLayer *maskLayer=[CAShapeLayer layer];
    maskLayer.frame=self.bounds;
    maskLayer.path=maskPath.CGPath;

    self.layer.mask=maskLayer;
    
    if (borderWidth>0) {
        CAShapeLayer *borderLayer = [CAShapeLayer layer];
        CGFloat halfWidth = borderWidth;
        CGRect f =CGRectMake(halfWidth, halfWidth,CGRectGetWidth(self.bounds) - borderWidth*2,CGRectGetHeight(self.bounds) - borderWidth*2);
        
        borderLayer.path = [UIBezierPath bezierPathWithRoundedRect:f cornerRadius:radius].CGPath;
        borderLayer.fillColor = [UIColor clearColor].CGColor;
        borderLayer.strokeColor = borderColor.CGColor;
        borderLayer.lineWidth = borderWidth;
        borderLayer.frame = CGRectMake(0,0,CGRectGetWidth(f),CGRectGetHeight(f));
        [self.layer addSublayer:borderLayer];
    }
}

@end
