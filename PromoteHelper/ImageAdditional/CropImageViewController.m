//
//  CropImageViewController.m
//  Camera
//
//  Created by carbon on 13-10-25.
//  Copyright (c) 2013年 Carbon. All rights reserved.
//

#import "CropImageViewController.h"
#import "NetworkRequest.h"
#import "DataBase.h"

@interface CropImageViewController ()
{
    UIButton *_doneBtn;
//    UILabel *_titleLabel;
}

@property (nonatomic,retain) UIImage *originalImage;

@end

@implementation CropImageViewController
@synthesize cropImage,cropSize,delegate,originalImage;

- (void)cropImageDoneAndBaceButtonDidPressed
{
    UIImage *image=[imageView image];
    
    if ([self.delegate respondsToSelector:@selector(CropImageViewController:DidCropSuccessfully:)])
    {
        [self.delegate CropImageViewController:self DidCropSuccessfully:image];
    }
    else{
        [self uploadImage:image];
    }
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }];
}

-(void) uploadImage:(UIImage*)imageToPost{

//    NetworkRequest *networkRequest = [NetworkRequest sharedNetWorkRequest];
//    
//    NSString *uploadImgUrl=UPLOAD_TASK_URL;
//    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"user.img", @"name", @"user.img", @"fileName", nil];
//    
//    [networkRequest uploadImage:uploadImgUrl parameters:parameters image:imageToPost success:^(id responseObject)
//     {
//         
////         [CampusLifeHelper warning:@"PROFILE_HEADPIC  接口待测"];
//         NSDictionary *json = [DataBase jsonData2NSDictionary:responseObject];
//         if ([json[ERROR_CODE] integerValue]!=0) {
//             return ;
//         }
//         NSDictionary *data = json[@"data"];
//         NSMutableDictionary *userImgDict = [[NSMutableDictionary alloc]init];
//         if(json[@"data"][@"file_path"])
//         {
//             [userImgDict setObject:data[@"file_path"] forKey:(@"headimgurl")];
//             [[NSUserDefaults standardUserDefaults] setObject:data[@"file_path"] forKey:@"headimgurl"];
//             [[NSNotificationCenter defaultCenter] postNotificationName:USER_IMG_CHANGED_NOTIFICATION  object:imageToPost];
//         }
//         
//     } failure:^(NSError *error)
//     {
//         NSLog(@"error");
//         [CampusLifeHelper alert:@"网络不给力，请稍后再试.."];
//     }];
}

- (void)cropImageButtonDidPressed
{
    [_doneBtn setTitle:@"完成" forState:UIControlStateNormal];
    [_doneBtn removeTarget:self action:@selector(cropImageButtonDidPressed) forControlEvents:UIControlEventTouchUpInside];
    [_doneBtn addTarget:self action:@selector(cropImageDoneAndBaceButtonDidPressed) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *image = [cropImageView cropImage];
    [cropImageView removeFromSuperview];
    [cropImageView release];
    cropImageView = nil;
    
    [self setOriginalImage:image];
    if (!imageView)
    {
        CGRect frame;
        if (self.view.bounds.size.height==480) {
            frame = CGRectMake((320-cropSize.width)/2, (self.view.bounds.size.height-cropSize.height)/2-25, cropSize.width, cropSize.height);
        }
        else{
            frame = CGRectMake((320-cropSize.width)/2, (self.view.bounds.size.height-cropSize.height)/2, cropSize.width, cropSize.height);
        }
        
        imageView = [[UIImageView alloc] initWithFrame:frame];
        [self.view addSubview:imageView];
        [imageView setBackgroundColor:[UIColor clearColor]];
        
        CATransition *animation = [CATransition animation];
        animation.duration = 0.15f;
        animation.timingFunction = UIViewAnimationCurveEaseInOut;
        [imageView.layer removeAllAnimations];
        [imageView.layer addAnimation:animation forKey:@"animation"];
    }
    [imageView setImage:self.originalImage];
    
    //取消滤镜
    if (_isNoFilter) {
        [self cropImageDoneAndBaceButtonDidPressed];
        return;
    }

    
    [[[self.navigationItem leftBarButtonItem] customView] setHidden:NO];
    [[[self.navigationItem rightBarButtonItem] customView] setHidden:YES];
    
    CGRect frame = filtersScrollView.frame;
    frame.origin.x = (self.view.bounds.size.width-300)/2;
    [filtersScrollView setFrame:frame];
    
    CATransition *transition = [CATransition animation];
    //        [transition setDuration:1.25f];
    [transition setType:kCATransitionPush];
    [transition setSubtype: kCATransitionFromRight];
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    filtersScrollView.alpha=0.9;
    [filtersScrollView.layer removeAllAnimations];
    [filtersScrollView.layer addAnimation:transition forKey:@"animation"];
    [filtersScrollView.layer setMasksToBounds:YES];
    [filtersScrollView.layer setCornerRadius:5.0];
    
    NSArray *array = [NSArray arrayWithObjects:@"原图",@"LOMO",@"黑白",@"复古",@"哥特",@"锐色",@"淡雅",@"酒红",@"青柠",@"浪漫",@"光晕",@"蓝调",@"梦幻",@"夜色", nil];
//    NSArray *array = [PlistManger instanceManger].theamPlist[@"CropImage"];
    for (int index = 0; index < [array count]; index++)
    {
        CGRect frame = CGRectMake(5+index*55, 2.5, 50, 40);
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setFrame:frame];
        button.layer.cornerRadius=5;
        button.layer.masksToBounds=YES;
        
        [button setTag:index+10];
        [button setBackgroundColor:index==0?[UIColor colorWithRed:61/255.f green:185/255.f blue:241/255.f alpha:1]:[UIColor lightGrayColor]];
        [button setShowsTouchWhenHighlighted:YES];
        [button setTitle:[array objectAtIndex:index] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(filtersSelectButtonDidPressed:) forControlEvents:UIControlEventTouchUpInside];
        [filtersScrollView addSubview:button];
    }
    [filtersScrollView setContentSize:CGSizeMake([array count]*55+5, 45)];
}


- (void)filters:(NSNumber*)number
{
    UIImage *image = nil;
    switch (number.intValue)
    {
        case 0:
        {
            image= self.originalImage;
            break;
        }
        case 1:
        {
            image = [self.originalImage lomo];
            break;
        }
        case 2:
        {
            image = [self.originalImage blackWhite];
            break;
        }
        case 3:
        {
            image = [self.originalImage missOld];
            break;
        }
        case 4:
        {
            image = [self.originalImage geTe];
            break;
        }
        case 5:
        {
            image = [self.originalImage ruiHuai];
            break;
        }
        case 6:
        {
            image = [self.originalImage danYa];
            break;
        }
        case 7:
        {
            image = [self.originalImage jiuHong];
            break;
        }
        case 8:
        {
            image = [self.originalImage qingNing];
            break;
        }
        case 9:
        {
            image = [self.originalImage langMan];
            break;
        }
        case 10:
        {
            image = [self.originalImage lanDiao];
            break;
        }
        case 11:
        {
            image = [self.originalImage mengHuan];
            break;
        }
        case 12:
        {
            image = [self.originalImage yeSe];
            break;
        }
        default:
            break;
    }
    [imageView setImage:image];
}

- (void)filtersSelectButtonDidPressed:(UIButton*)btn
{
    for (int index=0; index<14; index++) {
        UIButton *button=(UIButton *)[self.view viewWithTag:index+10];
        if (button.tag==btn.tag) {
            [button setEnabled:NO];
            button.backgroundColor=[UIColor colorWithRed:61/255.f green:185/255.f blue:241/255.f alpha:1];
        }
        else{
            [button setEnabled:YES];
            button.backgroundColor=[UIColor lightGrayColor];
        }
    }
    
    MBProgressHUD *waitView = [[MBProgressHUD alloc] initWithFrame:self.view.frame];
    [waitView setDelegate:self];
    [self.view addSubview:waitView];
    [waitView showWhileExecuting:@selector(filters:) onTarget:self withObject:[NSNumber numberWithInt:(int)btn.tag-10] animated:YES];
    [waitView release];
}

-(void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout=UIRectEdgeNone;
	// Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor blackColor]];
    cropImageView = [[CropImageView alloc] initWithFrame:CGRectMake(0, 0, cropImage.size.width, cropImage.size.height)];
    [cropImageView setImage:cropImage cropType:CropImageFillRect size:cropSize];
    [self.view addSubview:cropImageView];
    
//    _titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
//    _titleLabel.center=CGPointMake(self.view.bounds.size.width/2, 60);
//    _titleLabel.text=@"移动和缩放";
//    _titleLabel.textAlignment=NSTextAlignmentCenter;
//    _titleLabel.font=[UIFont systemFontOfSize:24];
//    [self.view addSubview:_titleLabel];
    
    CGRect frame;
    if (self.view.bounds.size.height==480) {
        frame = CGRectMake(self.view.bounds.size.width, cropImageView.frame.origin.y+cropSize.height+(cropImageView.frame.size.height-cropSize.height)/2-20, 300, 45);
    }
    else{
        frame = CGRectMake(self.view.bounds.size.width, cropImageView.frame.origin.y+cropSize.height+(cropImageView.frame.size.height-cropSize.height)/2+10, 300, 45);
    }
    
    filtersScrollView = [[UIScrollView alloc] initWithFrame:frame];
    [filtersScrollView setBackgroundColor:[UIColor colorWithRed:234.0/255.0 green:235.0/255.0 blue:236.0/255.0 alpha:1.0]];
    [filtersScrollView setShowsHorizontalScrollIndicator:NO];
    [filtersScrollView setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:filtersScrollView];
    
    [self createBottomView];
}

- (void)createBottomView
{
    UIView *bottomView=[[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-60, self.view.bounds.size.width, 60)];
    bottomView.backgroundColor=[UIColor blackColor];
    bottomView.alpha=0.7;
    [self.view addSubview:bottomView];
    [bottomView release];
    
    UIButton *cancelBtn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    cancelBtn.frame=CGRectMake(5, 10, 60, 40);
    [cancelBtn setTitle:@"返回" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:cancelBtn];
    
    _doneBtn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    _doneBtn.frame=CGRectMake(self.view.bounds.size.width-65, 10, 60, 40);
    [_doneBtn setTitle:@"选取" forState:UIControlStateNormal];
    [_doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_doneBtn addTarget:self action:@selector(cropImageButtonDidPressed) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:_doneBtn];
}

- (void)cancelAction
{
    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc
{
    if (cropImageView)
    {
        [cropImageView removeFromSuperview];
        [cropImageView release];
    }
    if (imageView)
    {
        [imageView release];
    }
    if (filtersScrollView)
    {
        [filtersScrollView release];
    }
    [originalImage release];
    [cropImage release];
//    _titleLabel=nil;
    [super dealloc];
}



#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [hud removeFromSuperview];
}
@end
