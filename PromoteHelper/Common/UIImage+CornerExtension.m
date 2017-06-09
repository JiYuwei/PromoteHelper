//
//  UIImage+CornerExtension.m
//  PromoteHelper
//
//  Created by 纪宇伟 on 2017/6/8.
//  Copyright © 2017年 willing. All rights reserved.
//

#import "UIImage+CornerExtension.h"

@implementation UIImage (CornerExtension)

-(UIImage *)roundedImageWithRect:(CGRect)rect
{
    return [self roundedWithRect:rect cornerRadius:self.size.width/4 borderWidth:0.5 borderColor:[UIColor lightGrayColor]];
}

-(UIImage *)roundedWithRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth borderColor:(UIColor*)borderColor {
    CGFloat inset =1;
    CGFloat width =rect.size.width;
    CGFloat height =rect.size.height;
    
    UIBezierPath*maskShape;
    if(width > height) {
        cornerRadius = height / 2.0- inset;
        maskShape = [UIBezierPath bezierPathWithRoundedRect:CGRectMake((width-height)/2.0+ inset,0+ inset, height-2*inset, height-2*inset) cornerRadius:cornerRadius];
    }else{
        cornerRadius = width / 2.0- inset;
        maskShape = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0+inset, (height-width)/2.0+inset, width-2*inset, width-2*inset) cornerRadius:cornerRadius];
    }
    
    UIGraphicsBeginImageContextWithOptions(self.size,NO, [UIScreen mainScreen].scale);
    CGContextRef ctx =UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(ctx);
    CGContextAddPath(ctx, maskShape.CGPath);
    CGContextClip(ctx);
    
    CGContextTranslateCTM(ctx,0, height);
    CGContextScaleCTM(ctx,1.0,-1.0);
    CGContextDrawImage(ctx,CGRectMake(0,0, width, height),self.CGImage);
    CGContextRestoreGState(ctx);
    
    if(borderWidth >0) {
        [borderColor setStroke];
        CGFloat halfWidth = borderWidth /2.0;
        UIBezierPath*border = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(halfWidth, halfWidth,self.size.width - borderWidth ,self.size.width - borderWidth)];
        CGContextSetShouldAntialias(ctx,YES);
        CGContextSetAllowsAntialiasing(ctx,YES);
        CGContextSetLineWidth(ctx, borderWidth);
        CGContextAddPath(ctx, border.CGPath);
        CGContextStrokePath(ctx);
    }
    
    UIImage*resultingImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultingImage;
}

@end
