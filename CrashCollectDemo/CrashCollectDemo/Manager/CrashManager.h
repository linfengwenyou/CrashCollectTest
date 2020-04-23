//
//  CrashManager.h
//  LXDAppFluecyMonitor
//
//  Created by LIUSONG on 2020/4/23.
//  Copyright © 2020 Jolimark. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CrashManager : NSObject

+ (instancetype)shareInstance;
- (void)startCrashMonitor;
/* 上传日志信息 */
- (void)uploadLogInfo;
@end

NS_ASSUME_NONNULL_END
