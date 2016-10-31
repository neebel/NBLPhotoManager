//
//  ViewController.m
//  NBLPhotoManager
//
//  Created by snb on 16/10/31.
//  Copyright © 2016年 neebel. All rights reserved.
//

#import "ViewController.h"
#import "NBLPhotoManager.h"
#import "MBProgressHUD.h"
#import "NBLImageCell.h"

@interface ViewController ()<NBLPhotoListViewControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, NBLImageCellDelegate>

@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray<UIImage *> *pictures;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"照片选择器DEMO";
    [self.view addSubview:self.collectionView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Getter

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(19, 70, self.view.frame.size.width - 19 * 2, self.view.frame.size.height - 70)
                                                              collectionViewLayout:flowLayout];
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        [collectionView registerClass:[NBLImageCell class] forCellWithReuseIdentifier:@"imageCell"];
        _collectionView = collectionView;
    }
    
    return _collectionView;
}

- (MBProgressHUD *)progressHUD
{
    if (!_progressHUD) {
        _progressHUD = [[MBProgressHUD alloc] initWithView:[self currentVisibleWindow]];
        _progressHUD.minSize = CGSizeMake(120, 120);
        _progressHUD.label.text = @"最多只能选择9张图片";
        _progressHUD.mode = MBProgressHUDModeText;
        [[self currentVisibleWindow] addSubview:_progressHUD];
    }
    
    return _progressHUD;
}



- (NSMutableArray<UIImage *> *)pictures
{
    if (!_pictures) {
        NSMutableArray *pictures = [NSMutableArray array];
        [pictures addObject:[UIImage imageNamed:@"ImageCamera"]];
        _pictures = pictures;
    }
    
    return _pictures;
}

#pragma mark - Action

- (void)choosePictures
{
    NSInteger count = 10 - self.pictures.count;//数组中本身就有一张图片，所以此处是10，不是9
     [[NBLPhotoManager sharedManager] showPhotoBrowserInVC:self maxPicCount:count mediaType:kNBLMediaTypeAll];
}


- (void)hideHUD
{
    [self.progressHUD hideAnimated:YES];
}

#pragma mark - Private

- (void)addPictures:(NSMutableArray *)pictures
{
    if (self.pictures.count >= 10) {
        [self photoIsEnough];
        return;//数量够了
    }
    
    if (pictures.count <= 0) {
        return;
    }
    
    NSInteger remain = 10 - self.pictures.count > pictures.count ? pictures.count : 10 - self.pictures.count;
    
    NSMutableArray *tmpArr = [NSMutableArray array];
    
    for (NSInteger i = 0; i < self.pictures.count - 1; i++) {
        [tmpArr addObject:self.pictures[i]];
    }
    
    for (NSInteger i = 0; i < remain; i++) {
        [tmpArr addObject:pictures[i]];
    }
    
    [tmpArr addObject:self.pictures.lastObject];
    
    self.pictures = tmpArr;
    [self.collectionView reloadData];
}


- (UIWindow *)currentVisibleWindow
{
    NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
    for (UIWindow *window in frontToBackWindows){
        BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
        BOOL windowIsVisible = !window.hidden && window.alpha > 0;
        BOOL windowLevelNormal = window.windowLevel == UIWindowLevelNormal;
        if (windowOnMainScreen && windowIsVisible && windowLevelNormal) {
            return window;
        }
    }
    return [[[UIApplication sharedApplication] delegate] window];
}

#pragma mark - UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.pictures.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NBLImageCell *itemCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"imageCell" forIndexPath:indexPath];
    [itemCell updateCellWithImage:self.pictures[indexPath.row] cellIndex:indexPath.row];
    if (indexPath.row == self.pictures.count - 1) {
        [itemCell hideDeleteButton:YES];
    } else {
        [itemCell hideDeleteButton:NO];
    }
    itemCell.delegate = self;
    return itemCell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(50, 50);
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.pictures.count - 1) {
        
        if (self.pictures.count >= 10) {
            [self photoIsEnough];
            return;
        }
        
        [self choosePictures];
    }
}

#pragma mark - NBLPhotoListViewControllerDelegate

- (void)photoIsEnough
{
    [self.progressHUD showAnimated:YES];
    [self performSelector:@selector(hideHUD) withObject:nil afterDelay:1.0];
}


- (void)selectedPhotos:(NSArray<MWPhoto *> *)photos
{
    NSMutableArray *pictures = [NSMutableArray array];
    for (MWPhoto *photo in photos) {
        if (NSClassFromString(@"PHAsset")) {
            @autoreleasepool {
                if (photo.underlyingImage) {
                    [pictures addObject:photo.underlyingImage];
                }
            }
        } else {
            @autoreleasepool {
                ALAsset *asset = photo.alAsset;
                ALAssetRepresentation *assetRep = [asset defaultRepresentation];
                CGImageRef imgRef = [assetRep fullScreenImage];
                UIImage *image = [UIImage imageWithCGImage:imgRef];
                [pictures addObject:image];
            }
        }
    }
    
    [self addPictures:pictures];
}

#pragma mark - NBLImageCellDelegate

- (void)deletePictureAtIndex:(NSInteger)index
{
    [self.pictures removeObjectAtIndex:index];
    [self.collectionView reloadData];
}

@end
