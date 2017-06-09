//
//  WarningItem.m
//  Campus Life
//
//  Created by JesnLu on 15/3/27.
//  Copyright (c) 2015年 HP. All rights reserved.
//

#import "WarningItem.h"

@interface WarningItem ()

@property(nonatomic, strong)UILabel *messageLabel;
@property(nonatomic, strong)UIImageView *warningImg;

@end

@implementation WarningItem

-(void)setMessage:(NSString *)message
{
    _messageLabel.text = message;
}

-(instancetype)initWithFrame:(CGRect)frame message:(NSString *)message
{
    self = [super initWithFrame:frame];
    if (self) {
        [self uipartWithMsg:message frame:frame];
    }
    return self;
}

- (void)uipartWithMsg:(NSString *)msg frame:(CGRect)frame
{
//    self.windowLevel = UIWindowLevelAlert;
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.8];
    self.hidden = NO;

    _warningImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 22, 20, 20)];
    _warningImg.backgroundColor = [UIColor clearColor];
    _warningImg.image = [UIImage imageNamed:@"no-connection.png"];
    [self addSubview:_warningImg];
    _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, [[UIScreen mainScreen] bounds].size.width-25, frame.size.height)];
    _messageLabel.textAlignment = NSTextAlignmentLeft;
    _messageLabel.backgroundColor = [UIColor clearColor];
    _messageLabel.font = [UIFont boldSystemFontOfSize:14];
    _messageLabel.textColor = [UIColor redColor];
    _messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _messageLabel.numberOfLines = 0;
    _messageLabel.text = msg;
    [self addSubview:_messageLabel];
}
-(void)dealloc
{
    _messageLabel = nil;
    _warningImg = nil;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    _warningImg.frame = CGRectMake(10, 22, 20, 20);
    _messageLabel.frame = CGRectMake(35, 0, [[UIScreen mainScreen] bounds].size.width-25, rect.size.height);
}


@end
