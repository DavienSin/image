//
//  StorageHelper.h
//  ImageCache   读写图片信息缓存类
//
//  Created by Davien Sin on 2022/12/14.
//

#import <Foundation/Foundation.h>
#import "AAModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface StorageHelper : NSObject

/**
 *  把图片写入本地缓存
 *  @param imageCache 图片缓存，新api通过key=pha，旧api通过key=ala提取
 *  @param resultBlock resultBlock
 */
-(void)writeImageInCache:(NSArray <NSData *> *)imageCache resultBlock:(void(^)(void))resultBlock;

/**
 *  从本地缓存加载图片
 *  @param resultBlock resultBlock
 */
-(void)readImageInCache:(void (^)(AAModel *result,NSError *err))resultBlock;

/**
 *  从本地删除全部照片缓存
 */
-(BOOL)cleanImageCache;

@end

NS_ASSUME_NONNULL_END
