//
//  UserHeaderView.h
//  PromoteHelper
//
//  Created by 纪宇伟 on 15/11/26.
//  Copyright © 2015年 willing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserHeaderView : UIView

@property(nonatomic,strong)UIImageView *userView;
@property(nonatomic,strong)UILabel *userLabel;
@property(nonatomic,strong)UILabel *proLabel;
@property(nonatomic,strong)UIButton *codeBtn;

@property(nonatomic,strong)UIButton *downPeoBtn;
@property(nonatomic,strong)UIButton *finishBtn;

@property(nonatomic,strong)NSDictionary *userContent;
@property(nonatomic,strong)NSDictionary *dataContent;

@end
