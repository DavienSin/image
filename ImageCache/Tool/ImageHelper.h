//
//  ImageHelper.h
//  ImageCache
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
 *  @param asset PHAsset
 *  @param options PHImageRequestOptions
 *  @param resultHandler resultHandler;
 */
-(void)fetchAssetDataUsingPha:(PHAsset *)asset options:(nullable PHImageRequestOptions *)options resultHandler:(void (^)(NSData *_Nullable imageData, NSString *_Nullable dataUTI, CGImagePropertyOrientation orientation, NSDictionary *_Nullable info))resultHandler;

/**
 *  获取系统全部相册资源  兼容新旧api，新api通过key=pha，旧api通过key=ala提取
 */
-(NSDictionary *)fetchAllAsset;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
/**
 *  获取系统全部相册资源 AssetsLibrary/AssetsLibrary.h
 */
-(void)fetchAllAssetUsingAla:(void(^)(ALAssetsGroup *groups))resultBlock;
#pragma clang diagnostic pop



@end

NS_ASSUME_NONNULL_END
