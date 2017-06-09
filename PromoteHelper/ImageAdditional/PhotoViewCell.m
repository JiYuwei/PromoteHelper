//
//  PhotoViewCell.m
//  Campus Life
//
//  Created by 纪宇伟 on 14/12/4.
//  Copyright (c) 2014年 HP. All rights reserved.
//

#import "PhotoViewCell.h"


@implementation PhotoViewCell

/*
-(void)setChooseType:(ChooseImageType)chooseType
{
    _chooseType = chooseType;
}
 */

-(void)setSelectResult:(ALAsset *)selectResult
{
    if (_selectResult!=selectResult) {
        _selectResult=selectResult;
    }
    
    for (int i=0;i<_assetsArray.count;i++) {
        ALAsset *dResult=_assetsArray[i];
        UIImageView *imageView=_imageViewArray[i];
        UIImageView *subView=imageView.subviews.firstObject;
        
        if ([_selectResult isEqual:dResult]) {
            imageView.alpha=0.75;
            subView.hidden=NO;
            break;
        }
        else{
            imageView.alpha=1;
            subView.hidden=YES;
        }
        
    }
}

- (void)awakeFromNib {
    // Initialization code
    _imageViewArray=@[_imageView1,_imageView2,_imageView3];
    CGFloat viewWidth=([[UIScreen mainScreen] bounds].size.width-8)/3;
    for (UIImageView *imgView in _imageViewArray) {
        UIImageView *selectedImgView=[[UIImageView alloc] initWithFrame:CGRectMake(viewWidth-34, 4, 30, 30)];
        selectedImgView.image=[UIImage imageNamed:@"ne_check"];
        selectedImgView.hidden=YES;
        [imgView addSubview:selectedImgView];
        
        [imgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addArrowAction:)]];
    }
}

-(void)fillData
{
    for (int i=0; i<_photoArray.count; i++) {
        UIImageView *view=_imageViewArray[i];
        UIImage *image=_photoArray[i];
        view.image=image;
        view.userInteractionEnabled=YES;
    }
}

- (void)addArrowAction:(UITapGestureRecognizer *)recognizer
{
    [self.delegate cleanAllArrows];

    NSInteger num=recognizer.view.tag-50;
    ALAsset *result=_assetsArray[num];
    BOOL changeView=[self.delegate saveSelectedAsset:result];
    
    if (changeView) {
        UIImageView *selectView=recognizer.view.subviews.firstObject;
        selectView.hidden=!selectView.hidden;
        recognizer.view.alpha = selectView.hidden?1:.75;
        [self.delegate enableNextBtn];
    }
}

-(void)clearArrow
{
    for (UIImageView *imageView in _imageViewArray) {
        imageView.alpha=1;
        UIImageView *subView=imageView.subviews.firstObject;
        subView.hidden=YES;
    }
}

-(void)checkStatusWithArray:(NSArray *)asArray
{
    for (int i=0;i<_assetsArray.count;i++) {
        ALAsset *dResult=_assetsArray[i];
        UIImageView *imageView=_imageViewArray[i];
        UIImageView *subView=imageView.subviews.firstObject;
        for (ALAsset *sResult in asArray) {
            if ([sResult isEqual:dResult]) {
                imageView.alpha=0.75;
                subView.hidden=NO;
                break;
            }
            else{
                imageView.alpha=1;
                subView.hidden=YES;
            }
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
