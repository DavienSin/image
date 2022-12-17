//
//  ImageHelper.h
//  ImageCache  加载相册类
//
//  Created by Davien Sin on 2022/12/9.
//

#import <Foundation/Foundation.h>
#include <Photos/Photos.h>
#include <AssetsLibrary/AssetsLibrary.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageHelper : NSObject


+(instancetype)defaultHelper;

/**
 *  获取系统全部相册资源  Photos/Photos.h
 *  @param fetchOption PHFetchOptions
 *  @param mediaType PHAssetMediaType
 */
-(PHFetchResult *)fetchAllAssetDataUsingPha:(PHFetchOptions *)fetchOption mediaType:(PHAssetMediaType)mediaType;

/**
 *  获取特定图片资源  Photos/Photos.h
 *  @param fetchResult PHFetchResult
 *  @param options PHImageRequestOptions
 *  @param resultHandler resultHandler;
 */
-(void)fetchAssetDataUsingPha:(PHFetchResult *)fetchResult options:(nullable PHImageRequestOptions *)options resultHandler:(void (^)(NSArray <NSData *> *imageData))resultHandler;


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
/**
 *  获取系统全部相册资源 AssetsLibrary/AssetsLibrary.h
 *  @param resultBlock resultBlock;
 */
-(void)fetchAllAssetUsingAla:(void(^)(ALAssetsGroup *groups))resultBlock;

/**
 *  获取特定图片资源  AssetsLibrary/AssetsLibrary.h
 *  @param group group;
 *  @param resultBlock resultBlock;
 */
-(void)fetchAssetDataUsingAla:(ALAssetsGroup *)group resultBlock:(void(^)(NSData *imageData))resultBlock;

/**
 *  获取所有特定图片资源  AssetsLibrary/AssetsLibrary.h //ALAssetsLibrary因为生命周期问题，需要特殊处理，暂时不知道怎么操作--->>>执行效率非常慢
 *  @param group group;
 *  @param resultBlock resultBlock;
 */
-(void)fetchAllAssetDataUsingAla:(nullable ALAssetsGroup *)group resultBlock:(void(^)(NSArray <NSData *> *imageData))resultBlock;


#pragma clang diagnostic pop



@end

NS_ASSUME_NONNULL_END
