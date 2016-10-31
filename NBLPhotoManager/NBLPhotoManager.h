//
//  NBLPhotoManager.h
//  NBLPhotoManager
//
//  Created by snb on 16/9/27.
//  Copyright © 2016年 neebel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NBLPhotoListViewController.h"

@interface NBLPhotoManager : NSObject

+ (instancetype)sharedManager;

- (void)showPhotoBrowserInVC:(UIViewController<NBLPhotoListViewControllerDelegate> *)vc maxPicCount:(NSInteger)maxPicCount mediaType:(NBLMediaType)mediaType;

@end
