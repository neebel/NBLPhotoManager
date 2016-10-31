//
//  NBLPhotoListCell.h
//  NBLPhotoManager
//
//  Created by snb on 16/9/21.
//  Copyright © 2016年 neebel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NBLPhotoListInfo.h"

@interface NBLPhotoListCell : UITableViewCell

@property(strong,nonatomic) UIImageView *coverImageView;
@property(strong,nonatomic) UILabel *title;
@property(strong,nonatomic) UILabel *subTitle;

-(void)loadPhotoListData:(NBLPhotoListInfo *)photoListInfo;

@end
