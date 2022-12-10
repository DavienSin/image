//
//  AACollectionView.m
//  ImageCache
//
//  Created by Davien Sin on 2022/12/4.
//

#import "AACollectionView.h"

@interface AAFlowLayout:UICollectionViewFlowLayout

@end


@implementation AAFlowLayout

-(instancetype)init{
    self = [super init];
    if(self){
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.minimumInteritemSpacing = 0;
        self.minimumLineSpacing = 0;
    }
    return self;
}

//-(void)prepareLayout{
//    [super prepareLayout];
//    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//    self.minimumInteritemSpacing = 0;
//    //    CGSize collectionSize = self.collectionView.frame.size;
//    //
//    //    CGFloat itemWidth = collectionSize.height * 0.6;
//    //    CGFloat itemHight = collectionSize.height * 0.8;
//    //
//    //    self.itemSize = CGSizeMake(itemWidth, itemHight);
//    //
//    //    CGFloat topMargin = collectionSize.width/2 - itemWidth/2;
//    //    self.sectionInset = UIEdgeInsetsMake(0, topMargin, 0, topMargin);
//    //}
//}
//
//-(NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
//    //获取全部item属性
//    NSArray *superAttrs = [super layoutAttributesForElementsInRect:rect];
//
//    //计算中心点
//  //  CGFloat centerPoint = self.collectionView.contentOffset.x + self.collectionView.frame.size.width / 2;
//
//    CGFloat contentOffsetX = self.collectionView.contentOffset.x;
//    CGFloat collectionViewCenterX = self.collectionView.frame.size.width / 2;
//
//
//    for (UICollectionViewLayoutAttributes *attr in superAttrs) {
//      //计算差值
//       // CGFloat deltaMargin = ABS(centerPoint - attr.center.x);
//      //计算放大比例
//        CGFloat scale = 1 - fabs(attr.center.x - contentOffsetX - collectionViewCenterX) / self.collectionView.bounds.size.width;
//        //重新对item属性赋值
//        attr.transform = CGAffineTransformMakeScale(scale, scale);
//    }
//    return superAttrs;
//}

//-(CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity{
//    CGRect rect;
//    rect.origin.y = 20;
//    rect.origin.x = proposedContentOffset.x;
//    rect.size = self.collectionView.frame.size;
//
//    NSArray *visibleArry = [super layoutAttributesForElementsInRect:rect];
//    CGFloat contentOffsetX = self.collectionView.contentOffset.x;
//    CGFloat collectionViewCenterX = self.collectionView.frame.size.width * 0.5;
//
//
//    CGFloat minMargin = MAXFLOAT;
//
//    for (UICollectionViewLayoutAttributes *attr in visibleArry) {
//        CGFloat deltaMargin = attr.center.x - contentOffsetX - collectionViewCenterX;
//        if(fabs(minMargin) > fabs(deltaMargin)){
//            minMargin = deltaMargin;
//        }
//    }
//    proposedContentOffset.x += minMargin;
//    return proposedContentOffset;
//}

//-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
//    return YES;
//}

@end

@implementation AACollectionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


// 初始化collectionView
-(instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout{
    self = [super initWithFrame:frame collectionViewLayout:[AAFlowLayout new]];
    if(self){
        
    }
    return self;
}

@end
