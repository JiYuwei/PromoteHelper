//
//  MainViewCell.h
//  PromoteHelper
//
//  Created by 纪宇伟 on 15/11/25.
//  Copyright © 2015年 willing. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MainViewDelegate <NSObject>

-(void)saveTaskStateWithID:(NSString *)appid andType:(NSNumber *)type andDateStr:(NSString *)oldDate;

@end

@interface MainViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *actBtn;
@property (weak, nonatomic) IBOutlet UIImageView *finishedView;

@property(nonatomic,strong)NSDictionary *appContent;
@property(nonatomic,weak) id <MainViewDelegate> delegate;

- (IBAction)onClick:(UIButton *)sender;

@end
