//
//  ImageHelper.m
//  ImageCache
//
//  Created by Davien Sin on 2022/12/9.
//

#import "ImageHelper.h"
#include <UIKit/UIImage.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@interface ImageHelper()
//旧api图片
//@property (nonatomic,assign) BOOL is

@property (nonatomic,strong) ALAssetsLibrary *library;
@end

@implementation ImageHelper


+ (instancetype)defaultHelper{
    return [[ImageHelper alloc] init];
}

-(PHFetchResult *)fetchAllAssetDataUsingPha:(PHFetchOptions *)fetchOption mediaType:(PHAssetMediaType)mediaType{
    PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:mediaType options:fetchOption];
    return result;
}

- (void)fetchAssetDataUsingPha:(PHFetchResult *)fetchResult options:(PHImageRequestOptions *)options resultHandler:(void (^)(NSArray<NSData *> * _Nonnull))resultHandler{
    PHImageManager *manager = [PHImageManager defaultManager];
    
    __block NSMutableArray *arr = [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (PHAsset *asset in fetchResult) {
            if (@available(iOS 13, *)) {
                [manager requestImageDataAndOrientationForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, CGImagePropertyOrientation orientation, NSDictionary * _Nullable info) {
                    [arr addObject:imageData];
                }];
            } else {
                [manager requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    [arr addObject:imageData];
                }];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            resultHandler(arr);
        });
    });
    
}


-(void)fetchAllAssetUsingAla:(void (^)(ALAssetsGroup *groups))resultBlock{
    __block ALAssetsGroup *_group = nil;
    __weak typeof(self) weakSelf = self;
    _library = [[ALAssetsLibrary alloc] init];
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        [weakSelf.library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"Recents"]){
              //  NSLog(@"%lu",group.numberOfAssets);
                _group = group;
            }
            dispatch_semaphore_signal(sema);
      
        } failureBlock:^(NSError *error) {
            dispatch_semaphore_signal(sema);
      
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }];


    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperations:@[op] waitUntilFinished:NO];
    if (@available(iOS 13.0, *)) {
        [queue addBarrierBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                resultBlock(_group);
            });
        }];
    } else {
        // 这里还没实现
        // Fallback on earlier versions
    }
    NSLog(@"fetch all ala group");

}

-(NSData *)transformCGIToData:(CGImageRef)image{
    UIImage *_image = [UIImage imageWithCGImage:image];
    return UIImageJPEGRepresentation(_image,1);
}

- (void)fetchAssetDataUsingAla:(ALAssetsGroup *)group resultBlock:(void (^)(NSData * _Nonnull))resultBlock{
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            ALAssetRepresentation * representation = [result defaultRepresentation];
            resultBlock([self transformCGIToData:[representation fullScreenImage]]);
        }];
}

- (void)fetchAllAssetDataUsingAla:(nullable ALAssetsGroup *)group resultBlock:(void (^)(NSArray<NSData *> * _Nonnull))resultBlock{
    __block NSMutableArray <NSData *> *arr = [NSMutableArray array];
  //  _library = [[ALAssetsLibrary alloc] init];
    __block ALAssetsGroup *_group = nil;
    
    __weak typeof(self) weakSelf = self;
    
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        [weakSelf.library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"Recents"]){
                _group = group;
            }
            dispatch_semaphore_signal(sema);
      } failureBlock:^(NSError *error) {
            dispatch_semaphore_signal(sema);
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }];


    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperations:@[op] waitUntilFinished:NO];
    [queue addBarrierBlock:^{
        [self fetchAssetDataUsingAla:_group resultBlock:^(NSData * _Nonnull imageData) {
            if(imageData){
                [arr addObject:imageData];
            }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            resultBlock(arr);
        });
    }];
}



@end

#pragma clang diagnostic pop
