//
//  WarningItem.h
//  Campus Life
//
//  Created by JesnLu on 15/3/27.
//  Copyright (c) 2015年 HP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WarningItem : UIView
@property(nonatomic, strong)NSString *message;
-(instancetype)initWithFrame:(CGRect)frame message:(NSString *)message;
@end
