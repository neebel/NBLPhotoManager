//
//  NBLPhotoListViewController.h
//  NBLPhotoManager
//
//  Created by snb on 16/9/21.
//  Copyright © 2016年 neebel. All rights reserved.
//

#import "MWPhotoBrowser.h"

typedef NS_ENUM(NSInteger, NBLMediaType) {
    kNBLMediaTypeAll,              //所有类型
    kNBLMediaTypePhoto,            //图片
    kNBLMediaTypeVideo,            //视频
};

@protocol NBLPhotoListViewControllerDelegate <NSObject>

- (void)photoIsEnough;

//iOS 7下可以取MWPhoto的alasset属性（ALAsset），>7可以取MWPhoto的asset属性（PHAsset）
- (void)selectedPhotos:(NSArray<MWPhoto *> *)photos;

@end


@interface NBLPhotoListViewController : UIViewController

@property (nonatomic, assign) NSInteger maxPicCount;//最大图片张数
@property (nonatomic, assign) NBLMediaType mediaType;
@property (nonatomic, weak) id<NBLPhotoListViewControllerDelegate> delegate;

@end
