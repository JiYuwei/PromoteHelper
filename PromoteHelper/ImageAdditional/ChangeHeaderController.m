//
//  ChangeHeaderController.m
//  Campus Life
//
//  Created by 纪宇伟 on 14/12/3.
//  Copyright (c) 2014年 HP. All rights reserved.
//

#import "ChangeHeaderController.h"
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAssetsGroup.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import "GroupViewCell.h"
#import "PhotoViewCell.h"
//#import "CutPhotoController.h"
#import "CropImageViewController.h"
#import "MoreViewController.h"

@interface ChangeHeaderController () <CellSelectDelegate,CropImageViewControllerDelegate>
{
    UIView *_bottomView;
    UIButton *_groupBtn;
    UIButton *_cameraBtn;
    UIButton *_nextBtn;
    UIButton *_viewBtn;
    UIImageView *_arrowView;
    
    UITableView *_gTableView;
    UITableView *_pCollectionView;
    ALAssetsLibrary *_assetsLibary;
    NSMutableArray *_groupArray;
    NSMutableArray *_imageArray;
    BOOL _isGroupShown;
    
    CGRect _groupHideRect;
    CGRect _groupShowRect;
    
    ALAsset *_selectedResult;
}
@end

@implementation ChangeHeaderController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout=UIRectEdgeNone;
    
    _groupHideRect=CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height-64-36-50);
    _groupShowRect=CGRectMake(0, 50, self.view.bounds.size.width, self.view.bounds.size.height-64-36-50);
    
    self.view.backgroundColor=[UIColor colorWithRed:240/255.f green:240/255.f blue:240/255.f alpha:1];
    self.navigationController.navigationBar.barStyle=UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor=[UIColor colorWithRed:61/255.f green:185/255.f blue:241/255.f alpha:1];
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
//    self.title=@"修改头像";
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(cancelAction)];
    
    [self preparePhotos];
    [self createUI];
}

-(void)cancelAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)preparePhotos
{
    _groupArray=[[NSMutableArray alloc] init];
    _imageArray=[[NSMutableArray alloc] init];
    _assetsLibary=[[ALAssetsLibrary alloc] init];
    
    [_assetsLibary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop)
    {
        if (group) {
            [_groupArray addObject:group];
        }
        else{
            *stop=YES;
        }
        
        if (*stop) {
            [_gTableView reloadData];
            [self loadPhotoGroup:_groupArray.count-1];
            GroupViewCell *cell=(GroupViewCell *)[_gTableView.visibleCells lastObject];
            cell.selectView.hidden=NO;
            NSLog(@"%@",_groupArray);
        }
        
        
    } failureBlock:^(NSError *error) {
//        NSLog(@"%@",error);
//        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:[PlistManger instanceManger].theamPlist[@"Error"] message:[PlistManger instanceManger].theamPlist[@"MissingAlbum"] delegate:self cancelButtonTitle:[PlistManger instanceManger].theamPlist[@"OK"] otherButtonTitles:nil, nil];
//        [alert show];

    }];
    
}


-(void)createUI
{
//照片列表
    _pCollectionView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-64) style:UITableViewStylePlain];
    _pCollectionView.backgroundColor=[UIColor clearColor];
    _pCollectionView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _pCollectionView.dataSource=self;
    _pCollectionView.delegate=self;
    [self.view addSubview:_pCollectionView];
    
    UIView *footerView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 32)];
    _pCollectionView.tableFooterView=footerView;
//相册列表
    _gTableView=[[UITableView alloc] initWithFrame:_groupHideRect style:UITableViewStylePlain];
    _gTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _gTableView.dataSource=self;
    _gTableView.delegate=self;
    [self.view addSubview:_gTableView];
    
    [self customTabBar];
}

-(void)customTabBar
{
    _bottomView=[[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-36-64, self.view.bounds.size.width, 36)];
    _bottomView.backgroundColor=[UIColor blackColor];
    _bottomView.alpha=0.7;
    [self.view addSubview:_bottomView];
    
    _groupBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    _groupBtn.frame=CGRectMake(8, 8, 60, 20);
    //_groupBtn.backgroundColor=[UIColor redColor];
    _groupBtn.titleLabel.font=[UIFont systemFontOfSize:14];
    _groupBtn.titleLabel.textAlignment=NSTextAlignmentRight;
    [_groupBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_groupBtn addTarget:self action:@selector(selectGroup) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_groupBtn];
    
    _arrowView=[[UIImageView alloc] initWithFrame:CGRectMake(_groupBtn.frame.size.width+10, _groupBtn.frame.size.height, 7, 7)];
    _arrowView.image=[UIImage imageNamed:@"me_arrowup"];
    [_bottomView addSubview:_arrowView];
    
//相机
//    _cameraBtn=[UIButton buttonWithType:UIButtonTypeCustom];
//    _cameraBtn.frame=CGRectMake(0, 0, 35, 20);
//    _cameraBtn.center=CGPointMake(_bottomView.frame.size.width/2, _bottomView.frame.size.height/2);
//    [_cameraBtn setImage:[UIImage imageNamed:@"me_camera"] forState:UIControlStateNormal];
//    [_cameraBtn addTarget:self action:@selector(openCamera) forControlEvents:UIControlEventTouchUpInside];
//    [_bottomView addSubview:_cameraBtn];
    _viewBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    _viewBtn.frame=CGRectMake(_bottomView.frame.size.width-120, 8, 60, 20);
    [_viewBtn setTitle:@"预览" forState:UIControlStateNormal];
    _viewBtn.titleLabel.font=[UIFont systemFontOfSize:14];
    [_viewBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_viewBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
    [_viewBtn addTarget:self action:@selector(viewDetail) forControlEvents:UIControlEventTouchUpInside];
    [_viewBtn setEnabled:NO];
    [_bottomView addSubview:_viewBtn];
    
    _nextBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    _nextBtn.frame=CGRectMake(_bottomView.frame.size.width-60, 8, 60, 20);
    [_nextBtn setTitle:@"选择" forState:UIControlStateNormal];
    _nextBtn.titleLabel.font=[UIFont systemFontOfSize:14];
    [_nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_nextBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
    [_nextBtn addTarget:self action:@selector(nextStep) forControlEvents:UIControlEventTouchUpInside];
    [_nextBtn setEnabled:NO];
    [_bottomView addSubview:_nextBtn];
}

-(void)openCamera
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [self dismissViewControllerAnimated:YES completion:^{
            [self.delegate openCamera];
        }];
    }
    else{
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"错误" message:@"找不到相机！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}

-(void)viewDetail
{
    UIImage *image=[UIImage imageWithCGImage:[[_selectedResult defaultRepresentation] fullScreenImage]];
    
    MoreViewController *moreVC=[[MoreViewController alloc] init];
    moreVC.dataArray=@[image];
    moreVC.imgNum=0;
    
    [self.navigationController pushViewController:moreVC animated:YES];
}

-(void)nextStep
{
    UIImage *image=[UIImage imageWithCGImage:[[_selectedResult defaultRepresentation] fullScreenImage]];
    
    [self.delegate imageSelectedSuccessful:image];
    
    [self dismissViewControllerAnimated:YES completion:nil];
//    CropImageViewController *controller=[[CropImageViewController alloc] init];
//    [controller.navigationItem setHidesBackButton:YES];
//    if (_isChoosePic) {
//        controller.delegate=self;
//    }
//    controller.isNoFilter=YES;
//    [controller setCropImage:image];
//    [controller setCropSize:_cropSize];
//    [self.navigationController pushViewController:controller animated:YES];
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(void)selectGroup
{
    [self selectGroupWithDelay:0];
}

-(void)selectGroupWithDelay:(NSTimeInterval)delay
{
    [UIView animateWithDuration:0.4 delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^{
        _gTableView.frame=_isGroupShown?_groupHideRect:_groupShowRect;
//        _gTableView.alpha=_gTableView.alpha==0?1:0;
    } completion:^(BOOL finished) {
        _isGroupShown=_isGroupShown?NO:YES;
        _pCollectionView.userInteractionEnabled=_isGroupShown?NO:YES;
    }];
}

-(void)loadPhotoGroup:(NSInteger)groupNum
{
    [_imageArray removeAllObjects];
    ALAssetsGroup *group=_groupArray[groupNum];
    NSString *groupName=[group valueForProperty:ALAssetsGroupPropertyName];
    CGSize titleSize=[groupName sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(self.view.bounds.size.width, 20) lineBreakMode:NSLineBreakByWordWrapping];
    [_groupBtn setTitle:groupName forState:UIControlStateNormal];
    _groupBtn.frame=CGRectMake(_groupBtn.frame.origin.x, _groupBtn.frame.origin.y, titleSize.width, 20);
    _arrowView.frame=CGRectMake(_groupBtn.frame.size.width+10, _groupBtn.frame.size.height, 7, 7);
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                [_imageArray addObject:result];
            }
            else if (result){
                
            }
            else{
                *stop=YES;
            }
            
            if (*stop) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_pCollectionView reloadData];
                });
            }
        }];
    });
}


#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView==_gTableView) {
        return _groupArray.count;
    }
    else{
        return _imageArray.count%3==0?_imageArray.count/3:_imageArray.count/3+1;
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==_gTableView) {
        static NSString *cellID=@"gcell";
        GroupViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell=[[[NSBundle mainBundle] loadNibNamed:@"GroupViewCell" owner:self options:nil] firstObject];
        }
        cell.titleLabel.text=[_groupArray[indexPath.row] valueForProperty:ALAssetsGroupPropertyName];
        cell.numLabel.text=[NSString stringWithFormat:@"%ld张照片",[_groupArray[indexPath.row] numberOfAssets]];
        cell.posterImgView.image=[UIImage imageWithCGImage:[_groupArray[indexPath.row] posterImage]];
        
        return cell;
    }
    else{
        static NSString *cellID=@"pcell";
        PhotoViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell=[[[NSBundle mainBundle] loadNibNamed:@"PhotoViewCell" owner:self options:nil] firstObject];
            cell.delegate=self;
        }
        NSMutableArray *assetsArr=[[NSMutableArray alloc] init];
        NSMutableArray *photoArr=[[NSMutableArray alloc] init];
        
        for (int i=0; i<3; i++) {
            NSInteger num=indexPath.row*3+i;
            if (num<_imageArray.count) {
                ALAsset *result=_imageArray[_imageArray.count-num-1];
                UIImage *image=[UIImage imageWithCGImage:[result thumbnail]];
                [assetsArr addObject:result];
                [photoArr addObject:image];
            }
        }

        cell.assetsArray=assetsArr;
        cell.photoArray=photoArr;
        cell.selectResult=_selectedResult;
        [cell fillData];
        
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView==_gTableView) {
        [self hideSelectedView];
        [_nextBtn setEnabled:NO];
        GroupViewCell *selectedCell=(GroupViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        selectedCell.selectView.hidden=NO;
        [self loadPhotoGroup:indexPath.row];
        [self selectGroupWithDelay:0.5];
    }
}

-(void)hideSelectedView
{
    for (UITableViewCell *cell in _gTableView.visibleCells) {
        GroupViewCell *myCell=(GroupViewCell *)cell;
        myCell.selectView.hidden=YES;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==_gTableView) {
        return 80;
    }
    else{
        return ([[UIScreen mainScreen] bounds].size.width-8)/3+4;
    }
    
}

#pragma mark - CellSelectDalegate

-(void)cleanAllArrows
{
    for (UITableViewCell *cell in _pCollectionView.visibleCells) {
        PhotoViewCell *myCell=(PhotoViewCell *)cell;
        [myCell clearArrow];
    }
}

-(void)enableNextBtn
{
    [_nextBtn setEnabled:YES];
    [_viewBtn setEnabled:YES];
}

-(BOOL)saveSelectedAsset:(ALAsset *)result
{
    if (result && _selectedResult!=result) {
        _selectedResult=result;
       // NSLog(@"%@",_selectedResult);
    }
    return YES;
}

#pragma mark - CropDelegate

-(void)CropImageViewController:(CropImageViewController *)cropVC DidCropSuccessfully:(UIImage *)image
{
    [self.delegate imageSelectedSuccessful:image];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
