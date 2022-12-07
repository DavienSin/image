//
//  ViewController.m
//  ImageCache
//
//  Created by Davien Sin on 2022/12/2.
//

#import "ViewController.h"
#include <Photos/Photos.h>
#import "AACollectionViewCell.h"
#import "AACollectionView.h"
#import "DAException.h"
#import "NSArray+Data.h"
#import <AssetsLibrary/AssetsLibrary.h>
#define kScreen [UIScreen mainScreen].bounds.size

@interface AAModel :NSObject
@property (nonatomic,assign) BOOL isEncode;
//缩略图
@property (nonatomic,strong,nullable) UIImage *degradedimage;
//高清
@property (nonatomic,strong,nullable) UIImage *unDegradedimage;
//新api图片
@property (nonatomic,strong,nullable) PHAsset *pha;
//旧api图片
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@property (nonatomic,strong,nullable) ALAsset *ala;
#pragma clang diagnostic pop


@end

@implementation AAModel

-(instancetype)init{
    self = [super init];
    if(self){
        _isEncode = NO;
        _degradedimage = [UIImage imageNamed:@"1"];
        _unDegradedimage = NULL;
        _pha = NULL;
        _ala = NULL;
    }
    return self;
}

@end


@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

// 大图
@property (nonatomic,strong) UIImageView *headImageView;

// 图片集合View
@property (nonatomic,strong) AACollectionView *AACollectionView;

// 图数组
@property (nonatomic,strong) NSMutableArray <AAModel *> *imageCaches;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@property (nonatomic,strong) ALAssetsLibrary *library;
#pragma clang diagnostic pop

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(50,30, kScreen.width-100, 300)];
    [self.view addSubview:_headImageView];
    
    [self loadImage];
    [self initCollection];
    

}

// 读取相册全部图片
-(void)loadImage{
    // 新api
    if(@available(iOS 9,*)){
  //  if(NO){
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        //ascending 为YES时，按照照片的创建时间升序排列;为NO时，则降序排列
        option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        PHFetchResult  *fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:option];//PHFetchResult这个类型可以当成NSArray使用。此时所有可获取照片都已拿到，可以刷新UI进行显示
        _imageCaches = [NSMutableArray arrayInCount:fetchResult.count fill:[AAModel new]];
                
        __weak typeof(self) weakSelf = self;
        PHImageManager *manager = [PHImageManager defaultManager];
        for (NSInteger i = 0; i < fetchResult.count; i++) {
            [manager requestImageForAsset:fetchResult[i] targetSize:CGSizeMake(200, 150) contentMode:0 options:[PHImageRequestOptions new] resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                AAModel *model = [[AAModel alloc] init];
                if(info[@"PHImageResultIsDegradedKey"]){
                    model.isEncode = NO;
                    model.degradedimage = result;
                }else{
                    model.isEncode = YES;
                    model.unDegradedimage = result;
                }
                model.pha = fetchResult[i];
                [self.imageCaches replaceObjectAtIndex:i withObject:model];
           //     NSLog(@"%lu------->%@",i,info);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.AACollectionView reloadData];
                });
            }];
        }
    }else
    {// 旧api
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        // 这部分使用到的过期api
        //避免在枚举出 AssetsLibrary 中所需要的数据后，AssetsLibrary 就被 ARC 释放了
        _library = [[ALAssetsLibrary alloc] init];
        NSMutableArray <ALAssetsGroup *> *groups = [NSMutableArray array];
        // 遍历相册
        __block NSInteger assetCount = 0;
        __weak typeof(self) weakSelf = self;
        [_library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group) { // 遍历相册还未结束
                // 设置过滤器
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                [groups addObject:group];
                assetCount += group.numberOfAssets;
            } else { // 遍历结束（当group为空的时候就意味着结束）
                weakSelf.imageCaches = [NSMutableArray arrayInCount:assetCount fill:[AAModel new]];
                __block NSInteger itemCount = 0;
                for(NSInteger i = 0;i<groups.count;i++){
                    NSLog(@"%lu",i);
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [groups[i] enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                      if(index < groups[i].numberOfAssets){
                            AAModel *m = [[AAModel alloc] init];
                            ALAssetRepresentation * representation = [result defaultRepresentation];
                            m.isEncode = YES;
                            m.degradedimage = [UIImage imageWithCGImage:[result thumbnail] scale:1.0 orientation:UIImageOrientationUp];
                            m.unDegradedimage = [UIImage imageWithCGImage:[representation fullScreenImage] scale:1.0 orientation:UIImageOrientationUp];
                          m.ala = result;
                           [weakSelf.imageCaches replaceObjectAtIndex:itemCount withObject:m];
                          dispatch_async(dispatch_get_main_queue(), ^{
                              //刷新问题，如何避免每次加载图片后刷新整个collectionView
                              //     NSIndexPath *indexPath = [[NSIndexPath alloc] initWithIndex:itemCount];
                              //  [weakSelf.AACollectionView reloadItemsAtIndexPaths:@[indexPath]];
                              [weakSelf.AACollectionView reloadData];
                          });
                          itemCount = itemCount + 1;
                        }
                            
                        // 设置无效 *stop = NO;
//                        if(index == (groups[i].numberOfAssets - 1)){
//                            *stop = YES;
//                        }
//
                       }];
                });
                }
            }
                
        } failureBlock:^(NSError *error) {
            NSLog(@"遍历失败");
        }];
    #pragma clang diagnostic pop


       
    }
    
   
    
    
}

// 初始化collectionview
-(void)initCollection{
    _AACollectionView = [[AACollectionView alloc] initWithFrame:CGRectMake(0, 350, kScreen.width, 200) collectionViewLayout:[UICollectionViewFlowLayout new]];
    //view能否滑动
    _AACollectionView.scrollEnabled = YES;
    //为指定cell注册
    [_AACollectionView registerClass:[AACollectionViewCell class] forCellWithReuseIdentifier:@"cid"];
    //加入主视图
    [self.view addSubview:_AACollectionView];
    
    //设置代理
    _AACollectionView.delegate = self;
    _AACollectionView.dataSource = self;
}

//复用每个cell的数据
-(__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cid";
    AACollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if (cell == nil) {
           cell = [[AACollectionViewCell alloc] init];
       }
    cell.backgroundColor = [UIColor whiteColor];
    cell.imageView.image = _imageCaches[indexPath.row].degradedimage;
    return cell;
}

//指定section数量
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

//指定单个section的item数量
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _imageCaches.count;
}

//触发单击事件
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    [self showHeadImageWithIndex:indexPath];
   
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(200, 150);
}

//@property(nonatomic,readonly,getter=isTracking)     BOOL tracking;        // returns YES if user has touched. may not yet have started dragging
//@property(nonatomic,readonly,getter=isDragging)     BOOL dragging;        // returns YES if user has started scrolling. this may require some time and or distance to move to initiate dragging
//@property(nonatomic,readonly,getter=isDecelerating) BOOL decelerating;    // returns YES if user isn't dragging (touch up) but scroll view is still moving


//滚动结束后触发
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    NSLog(@"scrollViewDidEndDecelerating---->tracking%d",scrollView.tracking);
//    NSLog(@"scrollViewDidEndDecelerating---->dragging%d",scrollView.dragging);
//    NSLog(@"scrollViewDidEndDecelerating---->decelerating%d",scrollView.decelerating);
    [self showHeadImage:scrollView];
}

// 计算滚动停止时中心点
-(void)showHeadImage:(UIScrollView *)scrollView{
    CGPoint centerPoint = CGPointMake(scrollView.contentOffset.x + _AACollectionView.frame.size.width / 2, 70);
    NSIndexPath *centerIndex = [_AACollectionView indexPathForItemAtPoint:centerPoint];
//NSLog(@"%@",centerIndex);
    [self showHeadImageWithIndex:centerIndex];
}


-(void)showHeadImageWithIndex:(NSIndexPath *)index{
    //判断高清是否已渲染完成
    if(_imageCaches[index.row].unDegradedimage){
        _headImageView.image = _imageCaches[index.row].unDegradedimage;
   }else{
       if(@available(iOS 9,*)){
           PHImageManager *manager = [PHImageManager defaultManager];
           PHImageRequestOptions *op = [[PHImageRequestOptions alloc] init];
           op.synchronous = YES;
           [manager requestImageDataAndOrientationForAsset:_imageCaches[index.row].pha options:op resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, CGImagePropertyOrientation orientation, NSDictionary * _Nullable info) {
               self.headImageView.image = [UIImage imageWithData:imageData];
               self.imageCaches[index.row].unDegradedimage = [UIImage imageWithData:imageData];
           }];
       }else{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
           ALAssetRepresentation * representation = [_imageCaches[index.row].ala defaultRepresentation];
          _headImageView.image = [UIImage imageWithCGImage:[representation fullScreenImage] scale:1.0 orientation:UIImageOrientationUp];
#pragma clang diagnostic pop

       }
    }
}


// 按下拖动时候触发
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//    NSLog(@"scrollViewDidEndDragging---->tracking%d",scrollView.tracking);
//    NSLog(@"scrollViewDidEndDragging---->dragging%d",scrollView.dragging);
//    NSLog(@"scrollViewDidEndDragging---->decelerating%d",scrollView.decelerating);
//    NSLog(@"scrollViewDidEndDragging---->decelerate%d",decelerate);
//

}



@end


