//
//  UIImage+CornerExtension.h
//  PromoteHelper
//
//  Created by 纪宇伟 on 2017/6/8.
//  Copyright © 2017年 willing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CornerExtension)

-(UIImage *)roundedImageWithRect:(CGRect)rect;
-(UIImage *)roundedWithRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth borderColor:(UIColor*)borderColor;

@end
