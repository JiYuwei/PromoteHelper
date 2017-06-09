//
//  CropImageView.h
//
//  Created by carbon on 13-10-25.
//  Copyright (c) 2013年 Carbon. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIImage (filter)


+ (UIImage*)image_rotate:(UIImage*)image_ orientation:(UIImageOrientation)orientation;

//乐么
-(UIImage*)lomo;
//黑白
-(UIImage*)blackWhite;
//怀旧
-(UIImage*)missOld;
//歌特
-(UIImage*)geTe;
//锐化
-(UIImage*)ruiHuai;
//淡雅
-(UIImage*)danYa;
//酒红
-(UIImage*)jiuHong;
//青柠
-(UIImage*)qingNing;
//浪漫
-(UIImage*)langMan;
//光晕
-(UIImage*)guangYun;
//蓝调
-(UIImage*)lanDiao;
//梦幻
-(UIImage*)mengHuan;
//夜色
-(UIImage*)yeSe;
@end


@interface UIImage (tools)

/*垂直翻转*/
- (UIImage *)flipVertical;

/*水平翻转*/
- (UIImage *)flipHorizontal;

/*改变size*/
- (UIImage *)resizeToWidth:(CGFloat)width height:(CGFloat)height;

/*裁切*/
- (UIImage *)cropImageWithX:(CGFloat)x y:(CGFloat)y width:(CGFloat)width height:(CGFloat)height;

/*将UIView转化为按照RECT裁剪*/
+ (UIImage*)transformViewToImage:(UIView *)view rect:(CGRect)rect;

@end




typedef enum CropImageEnum
{
    CropImageFillRect = 0,  //调整图片平铺
    CropImageAutoSpread,    //根据图片的SIZE计算放大缩小比例，取平均值平铺
    CropImageMin,           //裁剪区域大小与图片大小比例因子，取最小的
    CropImageMax            //裁剪区域大小与图片大小比例因子，取最大的
}CropImageEnum;

@class MaskLayerView;
@interface CropImageView : UIView <UIScrollViewDelegate>
{
    CropImageEnum cropType;
    UIScrollView *scrollView;
}

//传入需要处理的UIImage 
- (void)setImage:(UIImage *)image cropType:(CropImageEnum)cropEnumType size:(CGSize)size;

//最终裁剪出来的UIImage
- (UIImage *)cropImage;
@end



@interface MaskLayerView : UIView
{
    CGRect  cropRect;
}
- (void)setCropSize:(CGSize)size;
@end