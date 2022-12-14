//
//  AAStorage.h
//  ImageCache
//
//  Created by Davien Sin on 2022/12/14.
//

#import <Foundation/Foundation.h>
#include <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface AAModel : NSObject<NSCoding,NSSecureCoding>
// image存储数组
@property (nonatomic,strong) NSArray <NSData *> * _Nullable imageData;

@end

NS_ASSUME_NONNULL_END
