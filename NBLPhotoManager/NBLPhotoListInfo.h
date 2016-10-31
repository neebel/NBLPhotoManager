//
//  NBLPhotoListInfo.h
//  NBLPhotoManager
//
//  Created by snb on 16/9/21.
//  Copyright © 2016年 neebel. All rights reserved.
//

#import <Photos/Photos.h>

@interface NBLPhotoListInfo : NSObject

@property (assign, nonatomic) NSInteger count;
@property (strong, nonatomic) PHAsset *lastObject;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSArray<PHAsset *> *assets;

@end
