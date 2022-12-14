//
//  AACollectionViewCell.m
//  ImageCache
//
//  Created by Davien Sin on 2022/12/3.
//

#import "AACollectionViewCell.h"
#include <Masonry/Masonry.h>

@implementation AACollectionViewCell

//初始化cell布局
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        _imageView = [[UIImageView alloc] initWithFrame:frame];
        [self addSubview:_imageView];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

//typedef NS_ENUM(NSInteger, UIViewContentMode) {
//    UIViewContentModeScaleToFill,
//    UIViewContentModeScaleAspectFit,      // contents scaled to fit with fixed aspect. remainder is transparent
//    UIViewContentModeScaleAspectFill,     // contents scaled to fill with fixed aspect. some portion of content may be clipped.
//    UIViewContentModeRedraw,              // redraw on bounds change (calls -setNeedsDisplay)
//    UIViewContentModeCenter,              // contents remain same size. positioned adjusted.
//    UIViewContentModeTop,
//    UIViewContentModeBottom,
//    UIViewContentModeLeft,
//    UIViewContentModeRight,
//    UIViewContentModeTopLeft,
//    UIViewContentModeTopRight,
//    UIViewContentModeBottomLeft,
//    UIViewContentModeBottomRight,
//};

//-(void)updateConstraints{
//    [super updateConstraints];
////    NSLayoutConstraint *Leftlayout = [NSLayoutConstraint constraintWithItem:_imageView attribute:1 relatedBy:0 toItem:self attribute:1 multiplier:1.0 constant:0];
////    NSLayoutConstraint *toptlayout = [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeTop relatedBy:0 toItem:self attribute:1 multiplier:1.0 constant:0];
////    NSLayoutConstraint *widthlayout = [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeWidth relatedBy:0 toItem:self attribute:1 multiplier:1.0 constant:0];
////    NSLayoutConstraint *heightlayout = [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeHeight relatedBy:0 toItem:self attribute:1 multiplier:1.0 constant:0];
////
////    [_imageView addConstraints:@[Leftlayout,toptlayout,widthlayout,heightlayout]];
//
//
//}

//-(void)layoutIfNeeded{
//
//}

@end
