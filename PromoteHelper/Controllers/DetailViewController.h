//
//  DetailViewController.h
//  PromoteHelper
//
//  Created by 纪宇伟 on 15/12/1.
//  Copyright © 2015年 willing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property(nonatomic,strong)NSDictionary *appContent;
@property(nonatomic)BOOL isDoing;
@property(nonatomic,strong) void (^refreshcb)();

@end
