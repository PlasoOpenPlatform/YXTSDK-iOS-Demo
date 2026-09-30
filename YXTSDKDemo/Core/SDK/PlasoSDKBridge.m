//
//  PlasoSDKBridge.m
//  YXTSDKDemo
//

#import "PlasoSDKBridge.h"
#import <PlasoCommonSDK/PlasoSDK.h>

@implementation PlasoSDKBridge

+ (void)requestUserWithToken:(NSString *)token
                  completion:(void (^)(PlasoerUser * _Nullable user, NSError * _Nullable error))completion {
    [PlasoSDK requetUserWith:token completeBlock:^(PlasoerUser *user, NSError *error) {
        if (completion) {
            completion(user, error);
        }
    }];
}

@end
