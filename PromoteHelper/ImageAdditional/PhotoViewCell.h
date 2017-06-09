//
//  PhotoViewCell.h
//  Campus Life
//
//  Created by 纪宇伟 on 14/12/4.
//  Copyright (c) 2014年 HP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetRepresentation.h>

/*
typedef NS_ENUM(NSInteger, ChooseImageType){
    chooseImageTypeDefault          =0,
    chooseImageTypeMutable          =1,
};
*/

@protocol CellSelectDelegate <NSObject>

@optional
-(void)cleanAllArrows;
-(void)enableNextBtn;
-(BOOL)saveSelectedAsset:(ALAsset *)result;

@end

@interface PhotoViewCell : UITableViewCell

//@property(nonatomic, assign)ChooseImageType chooseType;

@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UIImageView *imageView3;

@property (strong, nonatomic) NSArray *imageViewArray;
@property (strong, nonatomic) NSArray *assetsArray;
@property (strong, nonatomic) NSArray *photoArray;
@property (strong, nonatomic) ALAsset *selectResult;
@property (assign, nonatomic) id <CellSelectDelegate> delegate;

-(void)fillData;
-(void)clearArrow;
-(void)checkStatusWithArray:(NSArray *)asArray;

@end
