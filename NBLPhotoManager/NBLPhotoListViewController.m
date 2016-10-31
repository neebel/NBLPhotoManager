//
//  NBLPhotoListViewController.m
//  NBLPhotoManager
//
//  Created by snb on 16/9/21.
//  Copyright © 2016年 neebel. All rights reserved.
//

#import "NBLPhotoListViewController.h"
#import "NBLPhotoListInfo.h"
#import "NBLPhotoListCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "MBProgressHUD.h"

@interface NBLPhotoListViewController()<UITableViewDataSource, UITableViewDelegate, MWPhotoBrowserDelegate>

@property (nonatomic, strong) UITableView     *tableView;
@property (nonatomic, strong) NSMutableArray  *alubms;
@property (nonatomic, strong) NSMutableArray  *photos;
@property (nonatomic, strong) NSMutableArray  *thumbs;
@property (nonatomic, strong) NSMutableArray  *selections;
@property (nonatomic, retain) NSMutableArray  *assetGroups;
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSArray<MWPhoto *> *selectedPhotos;
@property (nonatomic, strong) MBProgressHUD      *progressHUD;

@end


static NSString *photoListCellIdentifier = @"photoListCellIdentifier";

@implementation NBLPhotoListViewController

#pragma mark - LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];
    [self loadData];
}

#pragma mark - Private
- (void)initUI
{
    self.title = @"照片";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(cancelAction)];
}


- (void)loadData
{
    if (self.maxPicCount <= 0) {
        NSAssert(NO, @"最大图片张数设置错误");
    }
    
    [self loadAssets];
    [self.tableView registerClass:[NBLPhotoListCell class]
           forCellReuseIdentifier:photoListCellIdentifier];
}


- (NSMutableArray *)getPhotoList
{
    NSMutableArray *photoList = [NSMutableArray array];
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    
    //遍历相机胶卷
    PHFetchResult *smartAlbumFetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:fetchOptions];
    [smartAlbumFetchResult enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL *stop) {
            NSArray<PHAsset *> *assets = [self getAssetsInAssetCollection:collection];
            NBLPhotoListInfo *photoListInfo = [[NBLPhotoListInfo alloc] init];
            photoListInfo.count = assets.count;
            photoListInfo.title = [self formatPhotoAlumTitle:collection.localizedTitle];
            photoListInfo.lastObject = assets.lastObject;
            photoListInfo.assets = assets;
            [photoList addObject:photoListInfo];
    }];
    
    //遍历自定义相册
    PHFetchResult *topLevelUserFetchResult = [PHAssetCollection fetchTopLevelUserCollectionsWithOptions:fetchOptions];
    [topLevelUserFetchResult enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL *stop) {
        NSArray<PHAsset *> *assets = [self getAssetsInAssetCollection:collection];
        NBLPhotoListInfo *photoListInfo = [[NBLPhotoListInfo alloc] init];
        photoListInfo.count = assets.count;
        photoListInfo.title = collection.localizedTitle;
        photoListInfo.lastObject = assets.lastObject;
        photoListInfo.assets = assets;
        [photoList addObject:photoListInfo];
    }];
    
    
    //遍历云共享相册
    PHFetchResult *cloudAlbumFetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumCloudShared options:fetchOptions];
    [cloudAlbumFetchResult enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL *stop) {
        NSArray<PHAsset *> *assets = [self getAssetsInAssetCollection:collection];
        NBLPhotoListInfo *photoListInfo = [[NBLPhotoListInfo alloc] init];
        photoListInfo.count = assets.count;
        photoListInfo.title = [self formatPhotoAlumTitle:collection.localizedTitle];
        photoListInfo.lastObject = assets.lastObject;
        photoListInfo.assets = assets;
        [photoList addObject:photoListInfo];
    }];

    
    return photoList;
}


- (NSArray *)getAssetsInAssetCollection:(PHAssetCollection *)assetCollection
{
    NSMutableArray<PHAsset *> *arr = [NSMutableArray array];
    PHFetchResult *result = [self getFetchResult:assetCollection];
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        switch (self.mediaType) {
            case kNBLMediaTypeAll:
                [arr addObject:obj];
                break;
                
            case kNBLMediaTypePhoto:
                if (((PHAsset *)obj).mediaType == PHAssetMediaTypeImage) {
                    [arr addObject:obj];
                }
                break;
                
            case kNBLMediaTypeVideo:
                if (((PHAsset *)obj).mediaType == PHAssetMediaTypeVideo) {
                    [arr addObject:obj];
                }
                break;
                
            default:
                break;
        }
    }];
    
    return arr;
}


- (PHFetchResult *)getFetchResult:(PHAssetCollection *)assetCollection
{
    PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    return fetchResult;
}


- (NSString *)formatPhotoAlumTitle:(NSString *)title
{
    if ([title isEqualToString:@"All Photos"] || [title isEqualToString:@"Camera Roll"]) {
        return @"相机胶卷";
    } else {
        return title;
    }
}


- (void)showAuthorizationAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请在iPhone的\"设置-隐私-照片\"选项中，允许NBLPhotoManager访问你的相册" message:@"" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}


- (NSMutableArray *)preparePhotosWithAssetGroup:(ALAssetsGroup *)assetGroup
{
    NSMutableArray *assets = [NSMutableArray array];
    switch (self.mediaType) {
        case kNBLMediaTypeAll:
            [assetGroup setAssetsFilter:[ALAssetsFilter allAssets]];
            break;
            
        case kNBLMediaTypePhoto:
            [assetGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
            break;
            
        case kNBLMediaTypeVideo:
            [assetGroup setAssetsFilter:[ALAssetsFilter allVideos]];
            break;
            
        default:
            break;
    }
    
    [assetGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            [assets addObject:result];
        }
    }];
    
    return assets;
}


- (void)loadUnderlyingImageWithPhoto:(MWPhoto *)photo
{
    PHImageManager *imageManager = [PHImageManager defaultManager];
    
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.networkAccessAllowed = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous = false;
    
    UIScreen *screen = [UIScreen mainScreen];
    CGFloat scale = screen.scale;
    CGFloat imageSize = MAX(screen.bounds.size.width, screen.bounds.size.height) * 1.5;
    CGSize imageTargetSize = CGSizeMake(imageSize * scale, imageSize * scale);
    
    [self.progressHUD showAnimated:YES];
    __weak typeof(self) weakSelf = self;
    [imageManager requestImageForAsset:photo.asset targetSize:imageTargetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            photo.underlyingImage = result;
            for (MWPhoto *photo in weakSelf.selectedPhotos) {
                if (nil == photo.underlyingImage) {
                    return;
                } else {
                    if (photo == weakSelf.selectedPhotos.lastObject) {
                        [weakSelf.progressHUD hideAnimated:YES];
                        [weakSelf closeVC];
                    } else {
                        continue;
                    }
                }
            }
        });
    }];
}


- (void)closeVC
{
    if ([self.delegate respondsToSelector:@selector(selectedPhotos:)]) {
        [self.delegate selectedPhotos:self.selectedPhotos];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
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

#pragma mark - Getter
- (UITableView *)tableView
{
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        tableView.delegate = self;
        tableView.dataSource = self;
        UIView *view = [[UIView alloc] init];//清除tableView多余的横线
        view.backgroundColor = [UIColor clearColor];
        tableView.tableFooterView = view;
        _tableView = tableView;
    }
    
    return _tableView;
}


- (MBProgressHUD *)progressHUD
{
    if (!_progressHUD) {
        _progressHUD = [[MBProgressHUD alloc] initWithView:[self currentVisibleWindow]];
        _progressHUD.minSize = CGSizeMake(120, 120);
        _progressHUD.mode = MBProgressHUDModeIndeterminate;
        [[self currentVisibleWindow] addSubview:_progressHUD];
    }
    
    return _progressHUD;
}

#pragma mark - Action
- (void)cancelAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (NSClassFromString(@"PHAsset")) {
        return self.alubms.count;
    } else {
        return [self.assetGroups count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NBLPhotoListCell *cell = [tableView dequeueReusableCellWithIdentifier:photoListCellIdentifier];
    if (NSClassFromString(@"PHAsset")) {
        [cell loadPhotoListData:[self.alubms objectAtIndex:indexPath.row]];
    } else {
    
        ALAssetsGroup *group = (ALAssetsGroup *)[self.assetGroups objectAtIndex:indexPath.row];
        [group setAssetsFilter:[ALAssetsFilter allAssets]];
        NSInteger groupCount = [group numberOfAssets];
        cell.title.text = [group valueForProperty:ALAssetsGroupPropertyName];
        cell.subTitle.text = @(groupCount).stringValue;
        [cell.coverImageView setImage:[UIImage imageWithCGImage:[(ALAssetsGroup *)[self.assetGroups objectAtIndex:indexPath.row] posterImage]]];
    }
  
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSMutableArray *photos = [NSMutableArray array];
    NSMutableArray *thumbs = [NSMutableArray array];
    NSMutableArray *copy = [NSMutableArray array];
    
    if (NSClassFromString(@"PHAsset")) {
        NBLPhotoListInfo *info =  self.alubms[indexPath.row];
        copy = [info.assets copy];
        UIScreen *screen = [UIScreen mainScreen];
        CGFloat scale = screen.scale;
        CGFloat imageSize = MAX(screen.bounds.size.width, screen.bounds.size.height) * 1.5;
        CGSize imageTargetSize = CGSizeMake(imageSize * scale, imageSize * scale);
        CGSize thumbTargetSize = CGSizeMake(imageSize / 3.0 * scale, imageSize / 3.0 * scale);
        for (PHAsset *asset in copy) {
            [photos addObject:[MWPhoto photoWithAsset:asset targetSize:imageTargetSize]];
            [thumbs addObject:[MWPhoto photoWithAsset:asset targetSize:thumbTargetSize]];
        }
    } else {
        ALAssetsGroup *assetGroup = self.assetGroups[indexPath.row];
        copy = [[self preparePhotosWithAssetGroup:assetGroup] copy];
        for (ALAsset *asset in copy) {
            MWPhoto *photo = [MWPhoto photoWithURL:asset.defaultRepresentation.url alAsset:asset];
            [photos addObject:photo];
            MWPhoto *thumb = [MWPhoto photoWithImage:[UIImage imageWithCGImage:asset.thumbnail]];
            [thumbs addObject:thumb];
            if ([asset valueForProperty:ALAssetPropertyType] == ALAssetTypeVideo) {
                photo.videoURL = asset.defaultRepresentation.url;
                thumb.isVideo = true;
            }
        }
    }
    
    self.photos = photos;
    self.thumbs = thumbs;
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = NO;
    browser.displayNavArrows = NO;
    browser.displaySelectionButtons = YES;
    browser.alwaysShowControls = NO;
    browser.zoomPhotosToFill = YES;
    browser.enableGrid = YES;
    browser.startOnGrid = YES;
    browser.enableSwipeToDismiss = NO;
    browser.autoPlayOnAppear = NO;
    browser.maxPicCount = self.maxPicCount;
    [browser setCurrentPhotoIndex:0];
    
    if (photos.count > 0) {
        self.selections = [NSMutableArray array];
    }
    
    for (int i = 0; i < photos.count; i++) {
        [self.selections addObject:[NSNumber numberWithBool:NO]];
    }
    
    [self.navigationController pushViewController:browser animated:YES];
}

#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return self.photos.count;
}


- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < self.photos.count) {
        return [self.photos objectAtIndex:index];
    } else {
        return nil;
    }
}


- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index
{
    if (index < self.thumbs.count) {
        return [self.thumbs objectAtIndex:index];
    } else {
        return nil;
    }
}


- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index
{
    return [[self.selections objectAtIndex:index] boolValue];
}


- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected
{
    NSInteger count = 0;
    for (NSNumber *selection in self.selections) {
        if (selection.boolValue) {
            count++;
        }
    }
    
    NSInteger nextCount;
    if (selected) {
        nextCount = count + 1;
    } else {
        nextCount = count - 1;
    }
    
    if (nextCount <= self.maxPicCount) {
        [self.selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
    } else {
        if ([self.delegate respondsToSelector:@selector(photoIsEnough)]) {
            [self.delegate photoIsEnough];
        }
    }
}


- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser videoIndex:(NSInteger)videoIndex
{
    NSMutableArray *selectedPhotos = [NSMutableArray array];
    if (videoIndex < 0) {
        BOOL pictureIsLoading = NO;
        for (NSInteger i = 0; i < self.selections.count; i++) {
            NSNumber *selection = self.selections[i];
            if (selection.boolValue) {
                MWPhoto *photo = self.photos[i];
                if (NSClassFromString(@"PHAsset")) {
                    if (nil == photo.underlyingImage) {
                        pictureIsLoading = YES;
                        [self loadUnderlyingImageWithPhoto:photo];
                    }
                }
                
                [selectedPhotos addObject:photo];
            }
        }
        
        self.selectedPhotos = selectedPhotos;
        if (!NSClassFromString(@"PHAsset") || !pictureIsLoading) {
            [self closeVC];
        }
    } else {
        MWPhoto *photo = self.photos[videoIndex];
        [selectedPhotos addObject:photo];
        self.selectedPhotos = selectedPhotos;
        [self closeVC];
    }
}


- (NSInteger)photoBrowserSelectedPhotoCount:(MWPhotoBrowser *)photoBrowser
{
    NSInteger count = 0;
    for (NSNumber *selection in self.selections) {
        if (selection.boolValue) {
            count++;
        }
    }
    return count;
}


- (void)photoIsEnough
{
    if ([self.delegate respondsToSelector:@selector(photoIsEnough)]) {
        [self.delegate photoIsEnough];
    }
}

#pragma mark - Load Assets

- (void)loadAssets {
    if (NSClassFromString(@"PHAsset")) {
        
        // Check library permissions
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    [self performLoadAssets];
                }
            }];
        } else if (status == PHAuthorizationStatusAuthorized) {
            [self performLoadAssets];
        } else if (status == PHAuthorizationStatusDenied) {
            [self showAuthorizationAlert];
        }
        
    } else {

        // Assets library
        [self performLoadAssets];
        
    }
}

- (void)performLoadAssets {
    
    // Initialise
    _alubms = [NSMutableArray array];
    _assetGroups = [NSMutableArray array];
    _assetsLibrary = [[ALAssetsLibrary alloc] init];
    
    // Load
    if (NSClassFromString(@"PHAsset")) {
        
        // Photos library iOS >= 8
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
           
            weakSelf.alubms = [weakSelf getPhotoList];
            if (weakSelf.alubms.count > 0) {
                [weakSelf.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            }
        });
        
    } else {
    
        // Assets Library iOS < 8
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           @autoreleasepool {
                               // Group enumerator Block
                               void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
                               {
                                   if (group == nil) {
                                       return;
                                   }
                                   
                                   // added fix for camera albums order
                                   NSString *sGroupPropertyName = (NSString *)[group valueForProperty:ALAssetsGroupPropertyName];
                                   NSUInteger nType = [[group valueForProperty:ALAssetsGroupPropertyType] intValue];
                                   if (nType == ALAssetsGroupSavedPhotos || [sGroupPropertyName isEqualToString:@"相机胶卷"]) {
                                       [self.assetGroups insertObject:group atIndex:0];
                                   } else {
                                       [self.assetGroups addObject:group];
                                   }
                                   
                                   // Reload albums
                                   [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                               };
                               
                               // Group Enumerator Failure Block
                               void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
                                   [weakSelf showAuthorizationAlert];
                               };
                               
                               // Enumerate Albums
                               [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                                                 usingBlock:assetGroupEnumerator
                                                               failureBlock:assetGroupEnumberatorFailure];
                           }
                       });
    }
}

@end
