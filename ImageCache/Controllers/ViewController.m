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
#include <ImageIO/ImageIO.h>
#include <Masonry/Masonry.h>
#import "ImageHelper.h"
#import "StorageHelper.h"
#import "UIDevice+VGAddition.h"
#include <MJRefresh/MJRefresh.h>
#define kScreen [UIScreen mainScreen].bounds.size


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"


@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

// 图片集合View
@property (nonatomic,strong) AACollectionView *AACollectionView;

// 图数组
@property (nonatomic,strong) NSMutableArray <NSData *> *imageCaches;

@property (nonatomic,strong) ALAssetsLibrary *library;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
  
    [self loadCacheImage];
    
    StorageHelper *storage = [[StorageHelper alloc] init];
//    AAStorage *s = [[AAStorage alloc] init];
//    s.pha = @[];
    
    ImageHelper *helper = [ImageHelper defaultHelper];
    PHFetchOptions *op = [[PHFetchOptions alloc] init];
    op.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult  *fetchResult = [helper fetchAllAssetDataUsingPha:op mediaType:1];
    
    
//    [storage writeImageInCache:@{@"pha":fetchResult} resultBlock:^{
//        NSLog(@"write success");
//
//        [storage readImageInCache:^(AAStorage * _Nonnull result, NSError * _Nonnull err) {
//            if(err){
//                NSLog(@"%@",err);
//            }else{
//                NSLog(@"%@",[result.pha class]);
//                //
//            }
//        }];
//    }];
  //  [self initCollection];
   // [self addAssetChangeObserver];
    
}

// 读取相册全部图片
-(void)loadCacheImage{
    NSString *hasCache = [[NSUserDefaults standardUserDefaults] valueForKey:@"hasCache"];
    ImageHelper *imageHelper = [ImageHelper defaultHelper];
    StorageHelper *storageHelper = [[StorageHelper alloc] init];
    //判断有无图片缓存
    if([hasCache isEqualToString:@"no"]){ //没有
        [self fetchAllAsset];
    }else{
        if(@available(iOS 9,*)){ //有
            
        }else{
            
        }
    }
    
    
    
//    // 新api
//    ImageHelper *helper = [ImageHelper defaultHelper];
//   // if(@available(iOS 9,*)){
//    if(NO){
//        PHFetchResult  *fetchResult = [self fetchAllAsset][@"pha"];
//        _imageCaches = [NSMutableArray arrayInCount:fetchResult.count fill:[AAModel new]];
//
//        PHImageRequestOptions *rop = [[PHImageRequestOptions alloc] init];
//        rop.version = PHImageRequestOptionsVersionOriginal;
//        rop.resizeMode = PHImageRequestOptionsResizeModeNone;
//        __weak typeof(self) weakSelf = self;
//
//        for (NSInteger i = 0; i < fetchResult.count; i++) {
//            [helper fetchAssetDataUsingPha:fetchResult[i] options:rop resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, CGImagePropertyOrientation orientation, NSDictionary * _Nullable info) {
//                AAModel *model = [[AAModel alloc] init];
//                UIImage *unDegradedimage = [UIImage imageWithData:imageData];
//
//                model.unDegradedimage = [UIImage imageWithData:imageData];
//              //  NSLog(@"exif-->%@",model.exif);
//                [weakSelf.imageCaches replaceObjectAtIndex:i withObject:model];
//                //     NSLog(@"%lu------->%@",i,info);
//                [weakSelf.AACollectionView reloadData];
//            }];
//        }
//    }else
//    {// 旧api
//        // 这部分使用到的过期api
//        //避免在枚举出 AssetsLibrary 中所需要的数据后，AssetsLibrary 就被 ARC 释放了
//
//        [helper fetchAllAssetUsingAla:^(ALAssetsGroup * _Nonnull groups) {
//            NSLog(@"%@",[NSThread currentThread]);
//            NSLog(@"------>%lu",groups.numberOfAssets);
//        }];
//        NSLog(@"afterhello");
//
//
//
//
//   }
}

// 初始化collectionview
-(void)initCollection{
    CGFloat y = [UIDevice vg_navigationFullHeight];
    CGFloat h = [UIDevice vg_tabBarFullHeight];
    
    CGRect frame = CGRectMake(0, y, self.view.frame.size.width, self.view.frame.size.height - h - y);
    _AACollectionView = [[AACollectionView alloc] initWithFrame:frame collectionViewLayout:[UICollectionViewFlowLayout new]];
    //view能否滑动
    _AACollectionView.scrollEnabled = YES;
    //为指定cell注册
    [_AACollectionView registerClass:[AACollectionViewCell class] forCellWithReuseIdentifier:@"cid"];
    //加入主视图
    [self.view addSubview:_AACollectionView];
    
    _AACollectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(fetchAllAsset)];
    
    _AACollectionView.pagingEnabled = YES;
    //设置代理
    _AACollectionView.delegate = self;
    _AACollectionView.dataSource = self;
}

//指定section数量
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

//指定单个section的item数量
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _imageCaches.count;
}

//复用每个cell的数据
-(__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cid";
    AACollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if (cell == nil) {
           cell = [[AACollectionViewCell alloc] init];
       }
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    AACollectionViewCell *_cell = (AACollectionViewCell *)cell;
  //  _cell.imageView.image = _imageCaches[indexPath.row].unDegradedimage;
    
    //NSDictionary *exif = _imageCaches[indexPath.row].exif;
   // NSLog(@"%w:-->%f,h:-->%f",width.floatValue,height.floatValue);
    [_cell.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.width.height.equalTo(_cell);
    }];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return self.view.frame.size;
}


-(void)fetchAllAsset{
    [_AACollectionView.mj_header beginRefreshing];
    
    ImageHelper *imageHelper = [ImageHelper defaultHelper];
    StorageHelper *storageHelper = [[StorageHelper alloc] init];
    if(@available(iOS 9,*)){
        PHFetchOptions *op = [[PHFetchOptions alloc] init];
        op.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        PHFetchResult  *fetchResult = [imageHelper fetchAllAssetDataUsingPha:op mediaType:1];
        _imageCaches = [NSMutableArray array];
    
        PHImageRequestOptions *rop = [[PHImageRequestOptions alloc] init];
        rop.version = PHImageRequestOptionsVersionOriginal;
        rop.resizeMode = PHImageRequestOptionsResizeModeNone;
        
        __weak typeof(self) weakSelf = self;
        NSMutableArray *operationArr = [NSMutableArray array];
        for (PHAsset *obj in fetchResult) { // 这里会创建太多线程，待优化
            NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
                dispatch_semaphore_t sema = dispatch_semaphore_create(0);
                [imageHelper fetchAssetDataUsingPha:obj options:rop resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, CGImagePropertyOrientation orientation, NSDictionary * _Nullable info) {
                    [weakSelf.imageCaches addObject:imageData];
                    NSLog(@"here");
                    dispatch_semaphore_signal(sema);
                }];
                dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            }];
            [operationArr addObject:op];
        }
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        queue.maxConcurrentOperationCount = 5;
        [queue addOperations:operationArr waitUntilFinished:NO];
        [queue addBarrierBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.AACollectionView reloadData];
            });
            [storageHelper writeImageInCache:weakSelf.imageCaches resultBlock:^{
                NSLog(@"write image data success");
            }];
       }];
    }else{
        
    }
}

-(void)checkHasNewAsset{
    __block NSInteger count = 0;
    __weak typeof(self) weakSelf = self;
    ImageHelper *helper = [ImageHelper defaultHelper];
 //   if(NO){
    if(@available(iOS 9,*)){
        PHFetchOptions *op = [[PHFetchOptions alloc] init];
        op.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        PHFetchResult *result = [helper fetchAllAssetDataUsingPha:op mediaType:1];
        count = result.count;
        self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%lu",count];
    }else{
        [helper fetchAllAssetUsingAla:^(ALAssetsGroup * _Nonnull groups) {
            count = groups.numberOfAssets;
            if(count > weakSelf.imageCaches.count){
                count = count - weakSelf.imageCaches.count;
            }
            self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%lu",count];
        }];
    }
    NSLog(@"finish checkHasNewAsset");
}


- (void)dealloc{


}


@end

#pragma clang diagnostic pop
