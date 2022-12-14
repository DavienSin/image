//
//  ImageHelper.m
//  ImageCache
//
//  Created by Davien Sin on 2022/12/9.
//

#import "ImageHelper.h"

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

-(void)fetchAssetDataUsingPha:(PHAsset *)asset options:(PHImageRequestOptions *)options resultHandler:(void (^)(NSData * _Nullable, NSString * _Nullable, CGImagePropertyOrientation, NSDictionary * _Nullable))resultHandler{
    PHImageManager *manager = [PHImageManager defaultManager];
    [manager requestImageDataAndOrientationForAsset:asset options:options resultHandler:resultHandler];
}


//- (NSDictionary *)fetchAllAsset{
//    if(NO){
//    //if(@available(iOS 9,*)){
//        PHFetchOptions *fop = [[PHFetchOptions alloc] init];
//        //ascending 为YES时，按照照片的创建时间升序排列;为NO时，则降序排列
//        fop.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
//        PHFetchResult  *fetchResult = [self fetchAllAssetDataUsingPha:fop mediaType:1];
//        return @{@"pha":fetchResult};
//    }else{
//      //  __block ALAssetsGroup *groups = nil;
//        __weak typeof(self) weakSelf = self;
//        _library = [[ALAssetsLibrary alloc] init];
//
//        NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
//            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
//            [_library enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
//                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
//                NSLog(@"%@",[group valueForProperty:ALAssetsGroupPropertyName]);
//                if([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"Recents"]){
//                    NSLog(@"%lu",group.numberOfAssets);
//                    dispatch_semaphore_signal(sema);
//                }
//            } failureBlock:^(NSError *error) {
//
//            }];
//            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
//        }];
//
//
//        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//        [queue addOperations:@[op] waitUntilFinished:NO];
//        [queue addBarrierBlock:^{
//            NSLog(@"fin");
//            //return @{@"ala":@[]};
//        }];
//
//
//
//    }
//}

-(void)fetchAllAssetUsingAla:(void (^)(ALAssetsGroup *groups))resultBlock{
    __block ALAssetsGroup *_group = nil;
    __weak typeof(self) weakSelf = self;
    _library = [[ALAssetsLibrary alloc] init];
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        [weakSelf.library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            //[group setAssetsFilter:[ALAssetsFilter allPhotos]];
           // NSLog(@">>>>>%@",[group valueForProperty:ALAssetsGroupPropertyName]);
            if([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"Recents"]){
                NSLog(@"%lu",group.numberOfAssets);
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
        dispatch_async(dispatch_get_main_queue(), ^{
            resultBlock(_group);
        });
    }];
    NSLog(@"ffff");

}




@end

#pragma clang diagnostic pop
