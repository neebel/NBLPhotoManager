//
//  NBLImageCell.h
//  NBLPhotoManager
//
//  Created by snb on 16/8/21.
//  Copyright © 2016年 neebel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NBLImageCellDelegate <NSObject>

- (void)deletePictureAtIndex:(NSInteger)index;

@end


@interface NBLImageCell : UICollectionViewCell

@property (nonatomic, weak) id<NBLImageCellDelegate> delegate;

- (void)updateCellWithImage:(UIImage *)image cellIndex:(NSInteger)cellIndex;
- (void)hideDeleteButton:(BOOL)hidden;

@end
