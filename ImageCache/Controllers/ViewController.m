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
    
  //  [self readImageCache];
    
    [self loadCacheImage];
}

// 读取相册全部图片
-(void)loadCacheImage{
    NSString *hasCache = [[NSUserDefaults standardUserDefaults] valueForKey:@"hasCache"];
    //判断有无图片缓存
    if([hasCache isEqualToString:@"no"]){ //没有
        [self fetchAllAsset];
    }else{
        [self readImageCache];
    }

}

// 初始化collectionview
-(void)initCollection{
    NSLog(@"---------->%@",_imageCaches);
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
    //return 1;
}

//复用每个cell的数据
-(__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cid";
    AACollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if (cell == nil) {
           cell = [[AACollectionViewCell alloc] init];
       }
    cell.backgroundColor = [UIColor grayColor];
    cell.imageView.image = [UIImage imageWithData:_imageCaches[indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    AACollectionViewCell *_cell = (AACollectionViewCell *)cell;
 //   _cell.imageView.image = [UIImage imageWithData:_imageCaches[indexPath.row]];
//    _cell.imageView.image = [UIImage imageNamed:@"1"];
    [_cell.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.width.height.equalTo(_cell);
    }];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return collectionView.frame.size;
}


-(void)fetchAllAsset{
    [_AACollectionView.mj_header beginRefreshing];
    
    ImageHelper *imageHelper = [ImageHelper defaultHelper];
    StorageHelper *storageHelper = [[StorageHelper alloc] init];
    
    __weak typeof(self) weakSelf = self;
    if(@available(iOS 9,*)){
        PHFetchOptions *op = [[PHFetchOptions alloc] init];
        op.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        PHFetchResult  *fetchResult = [imageHelper fetchAllAssetDataUsingPha:op mediaType:1];
        
        PHImageRequestOptions *rop = [[PHImageRequestOptions alloc] init];
        rop.version = PHImageRequestOptionsVersionOriginal;
        rop.resizeMode = PHImageRequestOptionsResizeModeNone;
        rop.synchronous = YES;
        [imageHelper fetchAssetDataUsingPha:fetchResult options:rop resultHandler:^(NSArray<NSData *> * _Nonnull imageData) {
            weakSelf.imageCaches = [imageData mutableCopy];
            [weakSelf.AACollectionView reloadData];
            [weakSelf.AACollectionView.mj_header endRefreshing];
            
            [storageHelper cleanImageCache];
            [storageHelper writeImageInCache:weakSelf.imageCaches resultBlock:^{
                [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"hasCache"];
                NSLog(@"pha--->write success");
            }];
        }];
    }else{
        [imageHelper fetchAllAssetDataUsingAla:nil resultBlock:^(NSArray<NSData *> * _Nonnull imageData) {
            weakSelf.imageCaches = [imageData mutableCopy];
            [weakSelf.AACollectionView reloadData];
            [weakSelf.AACollectionView.mj_header endRefreshing];
            
            [storageHelper cleanImageCache];
            [storageHelper writeImageInCache:weakSelf.imageCaches resultBlock:^{
                NSLog(@"Ala--->write success");
                [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"hasCache"];
            }];
        }];;
    }
    
    
}

-(void)readImageCache{
    StorageHelper *helper = [[StorageHelper alloc] init];
    __weak typeof(self) weakSelf = self;
    
    [helper readImageInCache:^(AAModel * _Nonnull result, NSError * _Nonnull err) {
        weakSelf.imageCaches = [result.imageData mutableCopy];
        [weakSelf initCollection];
    }];
}

-(void)checkHasNewAsset{
    __block NSInteger count = 0;
    __weak typeof(self) weakSelf = self;
    ImageHelper *helper = [ImageHelper defaultHelper];
 //  if(NO){
    if(@available(iOS 9,*)){
        PHFetchOptions *op = [[PHFetchOptions alloc] init];
        op.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        PHFetchResult *result = [helper fetchAllAssetDataUsingPha:op mediaType:1];
        if(result.count > _imageCaches.count){
            count = result.count - weakSelf.imageCaches.count;
        self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%lu",count];
        }
    }else{
        [helper fetchAllAssetUsingAla:^(ALAssetsGroup * _Nonnull groups) {
            if(groups.numberOfAssets > weakSelf.imageCaches.count){
                count = groups.numberOfAssets - weakSelf.imageCaches.count;
                self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%lu",count];
            }
        }];
    }
  //  NSLog(@"finish checkHasNewAsset");
}


- (void)dealloc{


}


@end

#pragma clang diagnostic pop
