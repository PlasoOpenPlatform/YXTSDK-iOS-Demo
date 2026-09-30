//
//  PlasoSDKBridge.h
//  YXTSDKDemo
//
//  将 requetUserWith 回调参数标为可空，便于 Swift 判断成功 / 失败。
//

#import <Foundation/Foundation.h>

@class PlasoerUser;

NS_ASSUME_NONNULL_BEGIN

@interface PlasoSDKBridge : NSObject

/// 包装 `PlasoSDK.requetUserWith:`，回调中 user / error 均可为 nil。
+ (void)requestUserWithToken:(NSString *)token
                  completion:(void (^)(PlasoerUser * _Nullable user, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
