//
//  NBLImageCell.m
//  NBLPhotoManager
//
//  Created by snb on 16/8/21.
//  Copyright © 2016年 neebel. All rights reserved.
//

#import "NBLImageCell.h"

@interface NBLImageCell()

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UIButton    *deleteBt;
@property (nonatomic, assign) NSInteger   cellIndex;

@end


@implementation NBLImageCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    
    return self;
}

#pragma mark - Private
- (void)initUI
{
    [self.contentView addSubview:self.imgView];
    [self.contentView addSubview:self.deleteBt];
}


#pragma mark - Getter
- (UIImageView *)imgView
{
    if (!_imgView) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.contentView.frame];
        imgView.contentMode = UIViewContentModeScaleToFill;
        _imgView = imgView;
    }
    
    return _imgView;
}


- (UIButton *)deleteBt
{
    if (!_deleteBt) {
        UIButton *deleteBt = [[UIButton alloc] initWithFrame:CGRectMake(self.contentView.frame.origin.x + self.frame.size.width - 21, self.contentView.frame.origin.y + self.contentView.frame.size.height - 21, 25, 25)];
        [deleteBt setImage:[UIImage imageNamed:@"ImageDelete"] forState:UIControlStateNormal];
        [deleteBt addTarget:self action:@selector(deletePicture) forControlEvents:UIControlEventTouchUpInside];
        _deleteBt = deleteBt;
    }
    
    return _deleteBt;
}

#pragma mark - Public
- (void)updateCellWithImage:(UIImage *)image cellIndex:(NSInteger)cellIndex
{
    self.imgView.image = image;
    self.cellIndex = cellIndex;
}


- (void)hideDeleteButton:(BOOL)hidden
{
    self.deleteBt.hidden = hidden;
}

#pragma mark - Action
- (void)deletePicture
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(deletePictureAtIndex:)]) {
        [self.delegate deletePictureAtIndex:self.cellIndex];
    }
}

@end
