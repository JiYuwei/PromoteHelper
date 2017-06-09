//
//  ChangeHeaderController.h
//  Campus Life
//
//  Created by 纪宇伟 on 14/12/3.
//  Copyright (c) 2014年 HP. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OpenCameraDelegate <NSObject>

-(void)openCamera;

@optional
-(void)imageSelectedSuccessful:(UIImage *)image;

@end

@interface ChangeHeaderController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property(assign,nonatomic) id <OpenCameraDelegate> delegate;
@property(nonatomic)CGSize cropSize;
@property(nonatomic)BOOL isChoosePic;

@end
