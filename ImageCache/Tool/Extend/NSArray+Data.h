//
//  NSObject.h
//  ImageCache
//
//  Created by Davien Sin on 2022/12/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<ObjectType>(Data)

/**
 *  初始化指定个数和object的数组
 *
 *  @param count 数组填充个数
 *  @param object 数组填充object
 */
+(instancetype)arrayInCount:(NSInteger)count fill:(ObjectType)object;


@end

NS_ASSUME_NONNULL_END
