//
//  SectionHeaderCatgoryView.m
//  Campus Life
//
//  Created by xy on 14-7-6.
//  Copyright (c) 2014年 HP. All rights reserved.
//

#import "SectionHeaderCatgoryView.h"
//#import "EventScrollView.h"

static int selectedViewHeight = 3;

@interface SectionHeaderCatgoryView()

@property(strong, nonatomic) NSMutableArray *categoryLabels;
@property(strong, nonatomic) NSArray *categories;
@property(assign, nonatomic) UIEdgeInsets insets;

@property(strong, nonatomic) UIImageView *selectedView;
@property(strong, nonatomic) UIView *separatorView;

@property(strong, nonatomic) UIScrollView *scrollView;

@property(nonatomic) int categoryWidth;


@end

@implementation SectionHeaderCatgoryView
{
    CGRect _frame;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    _frame = frame;
    self.backgroundColor = [UIColor whiteColor];
    self.layer.shadowColor=[UIColor lightGrayColor].CGColor;
    self.layer.shadowOffset=CGSizeMake(0, 0.5);
    self.layer.shadowOpacity=0.5;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    _scrollView.backgroundColor=[UIColor colorWithRed:240/255.f green:240/255.f blue:240/255.f alpha:1];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.delegate = self;
    //    _scrollView.backgroundColor = [UIColor redColor];
    [self addSubview:_scrollView];
    
    _selectedView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 64, 8)];
    _selectedView.tag = 11111;
    _selectedView.image=[UIImage imageNamed:@"ac_arrowdown"];
    _selectedView.contentMode=UIViewContentModeCenter;
    //_selectedView.backgroundColor = [UIColor yellowColor];
    
    _separatorView =  [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 0.5, self.frame.size.width, 0.5)];
    _separatorView.backgroundColor = [UIColor clearColor];
    _separatorView.tag = 22222;
    [self addSubview:_separatorView];
    
    
    [_scrollView addSubview:_selectedView];
    
    return self;
}

- (void)setSectionHeaderCategories:(NSArray *)categories
{
    [self setSectionHeaderCategories:categories edgeInsets:UIEdgeInsetsZero];
}

- (void)setSectionHeaderCategories:(NSArray *)categories edgeInsets:(UIEdgeInsets)insets
{
    if (categories == nil)
        return;
    
    _insets = insets;
    
    if (_categoryLabels == nil)
        _categoryLabels = [[NSMutableArray alloc] init];
    
    [_categoryLabels removeAllObjects];
    _categories = categories;
    
    for(UILabel *LB in _scrollView.subviews){
        if (LB.tag !=11111 && LB.tag != 22222) {
            [LB removeFromSuperview];
        }
    }
    self.categoryWidth = _frame.size.width / MIN([categories count], 5);

    for (int i = 0; i < [categories count]; i++)
    {
        UILabel *categoryLabel = [[UILabel alloc] init];
        categoryLabel.text = [categories objectAtIndex:i];
        categoryLabel.backgroundColor = [UIColor clearColor];
        categoryLabel.textColor=[UIColor grayColor];
        categoryLabel.font = [UIFont systemFontOfSize:14];
        categoryLabel.frame = CGRectMake(i * self.categoryWidth, selectedViewHeight, self.categoryWidth, _frame.size.height - selectedViewHeight);
        categoryLabel.textAlignment = NSTextAlignmentCenter;
        categoryLabel.tag = 1000 + i;
        categoryLabel.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(categorySelected:)];
        
        [categoryLabel addGestureRecognizer:tapGesture];
        //[categoryLabel sizeToFit];
        
        [_categoryLabels addObject:categoryLabel];
        
        [_scrollView addSubview:categoryLabel];
    }
    
    if (_categoryLabels.count>=5) {
        for (int i=0; i<_categoryLabels.count; i++) {
            UILabel *label=_categoryLabels[i];
            if (i==0) {
                label.frame=CGRectMake(0, selectedViewHeight, self.categoryWidth+(label.text.length-2)*16, _frame.size.height - selectedViewHeight);
            }
            else{
                label.frame=CGRectMake(((UILabel *)_categoryLabels[i-1]).frame.origin.x+((UILabel *)_categoryLabels[i-1]).frame.size.width, selectedViewHeight, self.categoryWidth+(label.text.length-2)*16, _frame.size.height - selectedViewHeight);
            }
        }
    }
}

- (void)drawRect:(CGRect)rect
{
    if (_categoryLabels == nil)
        return;
    
    NSUInteger count = [_categoryLabels count];
    if (count == 0)
        return;
    
    _scrollView.frame = rect;
    
    self.categoryWidth = rect.size.width / MIN(count, 5);
    
    if (count<5) {
        _scrollView.contentSize = CGSizeMake(self.categoryWidth*count, rect.size.height);
    }
    else{
        _scrollView.contentSize = CGSizeMake(((UILabel *)_categoryLabels.lastObject).frame.origin.x+((UILabel *)_categoryLabels.lastObject).frame.size.width, rect.size.height);
    }
    for (int i = 0; i < count; i++)
    {
//        UILabel *categroyLabel = [_categoryLabels objectAtIndex:i];
//        
//        categroyLabel.frame = CGRectMake(i * self.categoryWidth  + _insets.left, selectedViewHeight, self.categoryWidth - _insets.right-10, rect.size.height - selectedViewHeight);
    }
    
    [self moveSelectedView:0];
}

#pragma mark category change
- (void)categorySelected:(UITapGestureRecognizer *)sender
{
    [self moveSelectedView:(int)sender.view.tag - 1000];
    
    if (_delegate != nil)
        [_delegate indexSelected:(int)sender.view.tag - 1000];
}

- (void)moveSelectedView:(int)index
{
    CGRect rect = self.frame;
    
    for (UILabel *label in _categoryLabels) {
        label.textColor=[UIColor grayColor];
    }

    UILabel *categroyLabel = [_categoryLabels objectAtIndex:index];
    categroyLabel.textColor=[UIColor colorWithRed:0.2706 green:0.7294 blue:0.9373 alpha:1];
    
    CGRect categroyLabelFrame = categroyLabel.frame;
    
    if ([_categories count] >5 && index >= 2){
        CGRect rect = _scrollView.frame;
        rect.origin.x = self.categoryWidth * (index - 2);
        
        [_scrollView scrollRectToVisible:rect animated:YES];
    }
    
    if (index == 1){
        [_scrollView scrollRectToVisible:rect animated:YES];
        
    }
    
    [UIView animateWithDuration:0.4 animations:^{
        _selectedView.frame = CGRectMake(categroyLabelFrame.origin.x, 0, categroyLabelFrame.size.width, 8);
    }];
}



@end
