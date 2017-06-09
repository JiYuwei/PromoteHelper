//
//  DetailTitleCell.h
//  PromoteHelper
//
//  Created by 纪宇伟 on 15/12/1.
//  Copyright © 2015年 willing. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DetailTaskDelegate <NSObject>

-(void)saveTaskState;

@end

@interface DetailTitleCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *appImgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *comLabel;
@property (weak, nonatomic) IBOutlet UILabel *otherLabel;
@property (weak, nonatomic) IBOutlet UIButton *actBtn;

@property(nonatomic,strong)NSDictionary *appContent;
@property(nonatomic,weak) id <DetailTaskDelegate> delegate;

- (IBAction)onClick:(UIButton *)sender;

@end
