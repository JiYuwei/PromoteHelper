//
//  UIImage+ColorImage.h
//  PromoteHelper
//
//  Created by 纪宇伟 on 16/3/3.
//  Copyright © 2016年 willing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ColorImage)

+(UIImage *)createImageWithColor:(UIColor *)color;
-(UIImage *)cornerImage;

@end
