//
//  NBLPhotoListCell.m
//  NBLPhotoManager
//
//  Created by snb on 16/9/21.
//  Copyright © 2016年 neebel. All rights reserved.
//

#import "NBLPhotoListCell.h"

@implementation NBLPhotoListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.coverImageView = [[UIImageView alloc]initWithFrame:CGRectMake(15, 5, 60, 60)];
        self.coverImageView.layer.masksToBounds = YES;
        self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.coverImageView];
        
        CGFloat labelWidth = [UIScreen mainScreen].bounds.size.width - 90;
        self.title = [[UILabel alloc]initWithFrame:CGRectMake(85, 15, labelWidth, 25)];
        self.title.textColor = [UIColor blackColor];
        self.title.font = [UIFont systemFontOfSize:18];
        [self.contentView addSubview:self.title];
        
        self.subTitle = [[UILabel alloc]initWithFrame:CGRectMake(85, 35, labelWidth, 25)];
        self.subTitle.textColor = [UIColor blackColor];
        self.subTitle.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:self.subTitle];
    }
    
    return self;
}

#pragma mark - Pudlic
- (void)loadPhotoListData:(NBLPhotoListInfo *)photoListInfo
{
    [[PHImageManager defaultManager] requestImageForAsset:photoListInfo.lastObject
                                               targetSize:CGSizeMake(200, 200)
                                              contentMode:PHImageContentModeDefault
                                                  options:nil
                                resultHandler:^(UIImage *result, NSDictionary *info)
     {
         if (result == nil) {
             self.coverImageView.backgroundColor = [UIColor lightGrayColor];
         } else {
             self.coverImageView.image = result;
         }
         
     }];
    
    self.title.text = photoListInfo.title;
    self.subTitle.text = [NSString stringWithFormat:@"%lu",(unsigned long)photoListInfo.count];
}

@end
