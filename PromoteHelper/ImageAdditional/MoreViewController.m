//
//  MoreViewController.m
//  剑灵帮帮
//
//  Created by qianfeng on 14-11-11.
//  Copyright (c) 2014年 jyw. All rights reserved.
//

#import "MoreViewController.h"
#import "UIImageView+WebCache.h"

static float newx = 0;
static float oldx = 0;

@interface MoreViewController ()
{
    CGSize _cSize;
    UIScrollView *_mainView;
    
    //CGFloat _lastScale;
    CGRect _oldFrame[50];
    CGRect _largeFrame[50];
    NSInteger _scrollLeftOrRight;
}
@end

@implementation MoreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

//-(void) doRotateAction:(NSNotification *) notification{
//    if ([[UIDevice currentDevice] orientation]==UIInterfaceOrientationPortrait
//        || [[UIDevice currentDevice] orientation]==UIInterfaceOrientationPortraitUpsideDown) {
//        NSLog(@">>>portrait");
//        _cSize=self.view.bounds.size;
//        [self setFrameWithAllSubviews];
//    }else{
//        NSLog(@">>>landscape");
//        _cSize=CGSizeMake([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);
//        [self setFrameWithAllSubviews];
//    }
//}

//- (void)setFrameWithAllSubviews
//{
//    oldx=_cSize.width*_imgNum;
//    newx=_cSize.width*_imgNum;
//    
//    _mainView.frame=CGRectMake(0, 0, _cSize.width, _cSize.height);
//    _mainView.contentSize=CGSizeMake(_cSize.width*_dataArray.count, _cSize.height);
//    _mainView.contentOffset=CGPointMake(_cSize.width*_imgNum, 0);
//    for (NSInteger i=0; i<_mainView.subviews.count; i++) {
//        UIImageView *imgView=_mainView.subviews[i];
//        imgView.frame=CGRectMake(_cSize.width*i, 0, _cSize.width, _cSize.height);
//    }
//
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.title=[NSString stringWithFormat:@"%d / %d",_imgNum+1,_dataArray.count];
    _cSize=self.view.bounds.size;
    self.automaticallyAdjustsScrollViewInsets=NO;
    self.view.backgroundColor=[UIColor blackColor];
//    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(backClick)];
    // Do any additional setup after loading the view.
    oldx=_cSize.width*_imgNum;
    newx=_cSize.width*_imgNum;
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doRotateAction:) name:UIDeviceOrientationDidChangeNotification object:nil];
    //NSLog(@"%@",_dataArray);
    [self createMainView];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

//-(void)backClick
//{
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

-(void)createMainView
{
    _mainView=[[UIScrollView alloc] initWithFrame:self.view.bounds];
    _mainView.pagingEnabled=YES;
    _mainView.delegate=self;
    _mainView.maximumZoomScale=2.0;
    _mainView.minimumZoomScale=0.5;
    _mainView.showsVerticalScrollIndicator=NO;
    _mainView.showsHorizontalScrollIndicator=NO;
    
    _mainView.contentSize=CGSizeMake(_cSize.width*_dataArray.count, _cSize.height);
    _mainView.contentOffset=CGPointMake(_cSize.width*_imgNum, 0);
    [self.view addSubview:_mainView];
    
    for (NSInteger i=0; i<_dataArray.count; i++) {
        UIImage *targetImage=_dataArray[i];
        CGFloat viewWidth=targetImage.size.width;
        CGFloat viewHeight=targetImage.size.height;
        if (viewWidth>self.view.bounds.size.width) {
            viewWidth=self.view.bounds.size.width;
            viewHeight=targetImage.size.height/targetImage.size.width*self.view.bounds.size.width;
        }
        if (viewHeight>self.view.bounds.size.height) {
            viewHeight=self.view.bounds.size.height;
            viewWidth=targetImage.size.width/targetImage.size.height*self.view.bounds.size.height;
        }
        
        UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake(_cSize.width*i, (self.view.bounds.size.height-viewHeight)/2, viewWidth, viewHeight)];
        imgView.tag=30+i;
        _oldFrame[i] = CGRectMake(_cSize.width*i, (self.view.bounds.size.height-viewHeight)/2, viewWidth, viewHeight);
        _largeFrame[i] = CGRectMake(_oldFrame[i].origin.x - viewWidth, _oldFrame[i].origin.y - viewHeight, 3 * _oldFrame[i].size.width, 3 * _oldFrame[i].size.height);
        
        imgView.userInteractionEnabled=YES;
        imgView.multipleTouchEnabled=YES;
        imgView.contentMode=UIViewContentModeScaleAspectFit;
        [self addGestureRecognizerToView:imgView];
        [_mainView addSubview:imgView];
        imgView.image=_dataArray[i];
//        [imgView setImageWithURL:[_dataArray[i] url] placeholderImage:[UIImage imageNamed:@"bgimg"]];
    }
}

- (void)addGestureRecognizerToView:(UIView *)imgView
{
    [imgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnClick:)]];
    [imgView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchOnClick:)]];
    [imgView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)]];
}

- (void)tapOnClick:(UITapGestureRecognizer *)recognizer
{
    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    newx= scrollView.contentOffset.x ;
    
    if (newx > oldx) {
        _scrollLeftOrRight = 1;
    }else if(newx < oldx){
        _scrollLeftOrRight = -1;
    }
    else{
        _scrollLeftOrRight = 0;
    }
    oldx = newx;
    
    if (_scrollLeftOrRight==1) {
        NSLog(@"Left");
        _imgNum++;
//        self.title=[NSString stringWithFormat:@"%ld / %ld",_imgNum+1,_dataArray.count];
    }
    else if(_scrollLeftOrRight==-1){
        NSLog(@"Right");
        _imgNum--;
//        self.title=[NSString stringWithFormat:@"%ld / %ld",_imgNum+1,_dataArray.count];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)pinchOnClick:(UIPinchGestureRecognizer *)recognizer
{
    NSInteger i = recognizer.view.tag-30;
    UIView *view=recognizer.view;
    if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged) {
        if (view.frame.size.width < _oldFrame[i].size.width/1.5){
            view.transform = CGAffineTransformScale(view.transform, 1, 1);
        }
        else{
            view.transform = CGAffineTransformScale(view.transform, recognizer.scale, recognizer.scale);
        }
        recognizer.scale = 1;
    }

    if (recognizer.state==UIGestureRecognizerStateEnded) {
        if (view.frame.size.width < _oldFrame[i].size.width) {
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                view.frame = _oldFrame[i];
            } completion:nil];
            //让图片无法缩得比原图小
        }
        if (view.frame.size.width > 3 * _oldFrame[i].size.width) {
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                view.frame = _largeFrame[i];
            } completion:nil];
        }
        
        [self checkPhotoPlace:view];
    }

}

- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    UIView *view = panGestureRecognizer.view;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        [view setCenter:(CGPoint){view.center.x + ((view.frame.size.width>=self.view.bounds.size.width)?translation.x:0), view.center.y + ((view.frame.size.height>=self.view.bounds.size.height)?translation.y:0)}];
        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
    }
    if (panGestureRecognizer.state==UIGestureRecognizerStateEnded) {
        [self checkPhotoPlace:view];
    }
}

-(void)checkPhotoPlace:(UIView *)view
{
    if (view.frame.origin.x>=0 && view.frame.size.width>=self.view.bounds.size.width) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            view.frame=CGRectMake(0, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
        } completion:nil];
    }
    if (view.frame.origin.y>=0 && view.frame.size.height>=self.view.bounds.size.height) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            view.frame=CGRectMake(view.frame.origin.x, 0, view.frame.size.width, view.frame.size.height);
        } completion:nil];
    }
    if (view.frame.origin.x+view.frame.size.width<=self.view.bounds.size.width && view.frame.size.width>=self.view.bounds.size.width) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            view.frame=CGRectMake(self.view.bounds.size.width-view.frame.size.width, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
        } completion:nil];
    }
    if (view.frame.origin.y+view.frame.size.height<=self.view.bounds.size.height && view.frame.size.height>=self.view.bounds.size.height) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            view.frame=CGRectMake(view.frame.origin.x, self.view.bounds.size.height-view.frame.size.height, view.frame.size.width, view.frame.size.height);
        } completion:nil];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
