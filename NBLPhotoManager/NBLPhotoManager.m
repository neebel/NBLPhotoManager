//
//  NBLPhotoManager.m
//  NBLPhotoManager
//
//  Created by snb on 16/9/27.
//  Copyright © 2016年 neebel. All rights reserved.
//

#import "NBLPhotoManager.h"

@implementation NBLPhotoManager

+ (instancetype)sharedManager
{
    static NBLPhotoManager *mediaManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mediaManager = [[self alloc] init];
    });

    return mediaManager;
}


- (void)showPhotoBrowserInVC:(UIViewController<NBLPhotoListViewControllerDelegate> *)vc maxPicCount:(NSInteger)maxPicCount mediaType:(NBLMediaType)mediaType
{
    NBLPhotoListViewController *photoListVC = [[NBLPhotoListViewController alloc] init];
    photoListVC.delegate = vc;
    photoListVC.maxPicCount = maxPicCount;
    photoListVC.mediaType = mediaType;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:photoListVC];
    [vc.navigationController presentViewController:nav animated:YES completion:nil];
}


@end
