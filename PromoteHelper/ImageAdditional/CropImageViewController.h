//
//  CropImageViewController.h
//  Camera
//
//  Created by carbon on 13-10-25.
//  Copyright (c) 2013年 Carbon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CropImageView.h"
#import "MBProgressHUD.h"
@class CropImageViewController;

@protocol CropImageViewControllerDelegate <NSObject>

@optional
- (void)CropImageViewController:(CropImageViewController *)cropVC DidCropSuccessfully:(UIImage*)image;

@end

@interface CropImageViewController : UIViewController <UIScrollViewDelegate,MBProgressHUDDelegate>
{
    UIScrollView *filtersScrollView;
    CropImageView *cropImageView;
    UIImageView *imageView;
}

@property (nonatomic,assign) id <CropImageViewControllerDelegate> delegate;

@property (nonatomic,assign) CGSize cropSize;
@property (nonatomic) BOOL isNoFilter;
@property (nonatomic,retain) UIImage *cropImage;

@end
