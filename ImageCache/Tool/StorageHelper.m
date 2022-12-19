//
//  StorageHelper.m
//  ImageCache
//
//  Created by Davien Sin on 2022/12/14.
//

#import "StorageHelper.h"
#import "AAModel.h"
#include <AssetsLibrary/AssetsLibrary.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@implementation StorageHelper

-(NSString *)cachePath{
   NSString *cachePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"imageCache.plist"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:cachePath]){
     [[NSFileManager defaultManager] createFileAtPath:cachePath contents:nil attributes:nil];
    }else{
        NSLog(@"file exit");
    }
    return cachePath;
}

- (void)writeImageInCache:(NSArray <NSData *> *)imageCache resultBlock:(void (^)(void))resultBlock{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        AAModel *storage = [[AAModel alloc] init];
        // 解码输出后对非基本类型输出会有问题，暂不清楚问题。所以必须转换成基本类型进行归档
        storage.imageData = imageCache;
        NSData *objectData;
        if(@available(iOS 11,*)){
            objectData = [NSKeyedArchiver archivedDataWithRootObject:storage requiringSecureCoding:NO error:nil];
        }else{
            objectData = [NSKeyedArchiver archivedDataWithRootObject:storage];
        }
        
        if([self cleanImageCache]){
            NSLog(@"clean image cache");
        }
        if([objectData writeToFile:[self cachePath] atomically:YES]){
            dispatch_async(dispatch_get_main_queue(), ^{
                resultBlock();
            });
        }
    });
}

- (void)readImageInCache:(void (^)(AAModel *result,NSError *err))resultBlock{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData *objectData = [NSData dataWithContentsOfFile:[self cachePath]];
        NSError *err = nil;
        //基本类型归档可用unarchivedObjectOfClasse，但涉及到自定义类的必须用unarchivedObjectOfClasses+自定义类里边所有数据类型的class
        NSSet *classSet = [NSSet setWithObjects:[NSArray class],[AAModel class],[NSData class], nil];
        if (@available(iOS 11.0, *)) {
            AAModel *result =  [NSKeyedUnarchiver unarchivedObjectOfClasses:classSet fromData:objectData error:&err];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                resultBlock(result,err);
            });
        } else {
            // Fallback on earlier versions
        }
    });
}


-(BOOL)cleanImageCache{
    NSData *emptyData = [NSData data];
    return  [emptyData writeToFile:[self cachePath] options:NSDataWritingAtomic error:nil];
}


@end
#pragma clang diagnostic pop
