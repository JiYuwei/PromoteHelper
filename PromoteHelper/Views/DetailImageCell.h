//
//  DetailImageCell.h
//  PromoteHelper
//
//  Created by 纪宇伟 on 16/2/18.
//  Copyright © 2016年 willing. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DetailImageDelegate <NSObject>

-(void)openPhotoAlbum;
-(void)submitPhotoWithImage:(UIImage *)image;

@end


@interface DetailImageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *expImgView;
@property (weak, nonatomic) IBOutlet UIButton *uploadBtn;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;

@property(nonatomic,strong)NSDictionary *appContent;
@property(nonatomic,weak) id <DetailImageDelegate> delegate;
@property(nonatomic,strong)UIImage *targetImage;
@property(nonatomic)BOOL isOpenBtn;

- (IBAction)uploadAction:(UIButton *)sender;
- (IBAction)submitAction:(UIButton *)sender;

@end
