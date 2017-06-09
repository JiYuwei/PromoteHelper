//
//  MainListView.h
//  PromoteHelper
//
//  Created by 纪宇伟 on 15/11/26.
//  Copyright © 2015年 willing. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShowPersonalityDelegate <NSObject>

-(void)openPersonalPage;

@end

@interface MainListView : UIView

@property(nonatomic,strong) UIImageView *userView;
@property(nonatomic,strong) UILabel *userLabel;
@property(nonatomic,strong) UIButton *codeBtn;
@property(nonatomic,strong) UIActivityIndicatorView *loadingView;

@property(nonatomic,weak) id <ShowPersonalityDelegate> delegate;

@end
