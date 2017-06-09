//
//  SectionHeaderCatgoryView.h
//  Campus Life
//
//  Created by xy on 14-7-6.
//  Copyright (c) 2014年 HP. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SectionHeaderCatgoryDelegate

-(void)indexSelected:(int)index;

@end

@interface SectionHeaderCatgoryView : UIView<UIScrollViewDelegate>

@property (strong, nonatomic) id<SectionHeaderCatgoryDelegate> delegate;

- (void)setSectionHeaderCategories:(NSArray *)categories;
- (void)setSectionHeaderCategories:(NSArray *)categories edgeInsets:(UIEdgeInsets)insets;

- (void)moveSelectedView:(int)index;


@end
