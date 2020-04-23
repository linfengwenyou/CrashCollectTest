//
//  CrashManager.m
//  LXDAppFluecyMonitor
//
//  Created by LIUSONG on 2020/4/23.
//  Copyright © 2020 Jolimark. All rights reserved.
//

#import "CrashManager.h"
#import <ZipArchive.h>

@implementation CrashManager

+ (instancetype)shareInstance {
	return [CrashManager new];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
	static dispatch_once_t onceToken;
	static CrashManager *instance;
	dispatch_once(&onceToken, ^{
		instance = [super allocWithZone:zone];
	});
	return instance;
}

- (void)startCrashMonitor {
	NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);	// 添加异常监听句柄
	
	// signal.h中包含所有指令
	signal(SIGABRT, handleSignal);		// 调用abort
	signal(SIGILL, handleSignal);		// 非法指令
	signal(SIGSEGV, handleSignal);		// 无效内存引用
	signal(SIGPIPE, handleSignal);		// 端口消息发送失败
}

void handleSignal(int signal) {
	
	NSLog(@"接收到信号：%d",signal);
}

void UncaughtExceptionHandler(NSException *exception) {
	NSString *name = [exception name];
	NSString *reason = [exception reason];
	NSArray *stackTrace = [exception callStackSymbols];
	NSString *crashInfo = [NSString stringWithFormat:@"\n%@\n%@\n%@\n",name,reason, stackTrace];
	
	[[CrashManager shareInstance] saveCrashToFile:crashInfo];
}

#pragma mark 上传日志信息
- (void)uploadLogInfo {
	NSString *zipFile = [self zipFileForAllCrash];
	if (!zipFile) {
		NSLog(@"资源文件不存在，无需上传");
		return;
	}
	NSLog(@"日志文件地址：%@",zipFile);
	BOOL success = NO;
	// 上传日志信息
//	如果成功
	if (success) {
		[self clearAllCacheLogFile];
	} else {	// 如果此次不再上传，可以选择重新上传，或者暂时不再发送，此时需要移除压缩文件
		[[NSFileManager defaultManager] removeItemAtPath:zipFile error:nil];
	}
}

#pragma mark - 路径
- (NSString *)logDirectory {
	NSString *directory =  [NSHomeDirectory() stringByAppendingPathComponent:@"log"];
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:directory]) {
		[[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
	}
	return directory;
}

/* 获取一个时间串，用来作为日志文件名 */
- (NSString *)timeString {
	NSDateFormatter *format = [NSDateFormatter new];
	[format setDateFormat:@"yyyy-MM-dd HH_mm_ss"];
	return [format stringFromDate:[NSDate date]];
}

/* 获取一个日志名称，用来存储这次的日志信息 */
- (NSString *)crashFilePath {
	NSString *fileName = [[self timeString] stringByAppendingString:@".log"];
	return [[self logDirectory] stringByAppendingPathComponent:fileName];
}

#pragma mark 保存文件
- (void)saveCrashToFile:(NSString *)crashInfo {
	NSFileManager *manager = [NSFileManager defaultManager];
	if (![manager fileExistsAtPath:[self crashFilePath]]) {
		[manager createFileAtPath:[self crashFilePath] contents:nil attributes:nil];
	}
	NSFileHandle *handler = [NSFileHandle fileHandleForWritingAtPath:[self crashFilePath]];
	[handler seekToEndOfFile];
	[handler writeData:[crashInfo dataUsingEncoding:NSUTF8StringEncoding]];
}

#pragma mark 压缩文件
- (NSString *)zipFileForAllCrash {
	// 压缩所有的crash文件, 返回压缩好的文件路径
	NSArray *sortArray = [self sortedCrashFiles];
	
	if (sortArray.count <= 0) return nil;
	// 创建一个压缩文件路径
	NSString *crashZipPath = [[self logDirectory] stringByAppendingPathComponent:[[self timeString] stringByAppendingString:@".zip"]];
	
	// 根据路径压缩所有文件信息
	BOOL ret = [SSZipArchive createZipFileAtPath:crashZipPath withFilesAtPaths:sortArray];
	
	if (!ret) {	// 压缩失败
		crashZipPath = nil;
		NSLog(@"创建压缩文件失败");
	}
	return crashZipPath;
}

#pragma mark 清理文件

- (void)clearAllCacheLogFile {
	// 清除所有Log日志文件
	
	NSFileManager *mana = [NSFileManager defaultManager];
	// 删除所有文件
	[mana removeItemAtPath:[self logDirectory] error:nil];
	
}


#pragma mark 文件排序
- (NSArray *)sortedCrashFiles {
	// 获取今天之前的所有数据，然后打包上传
	
	NSFileManager *mana = [NSFileManager defaultManager];
	if (![mana fileExistsAtPath:[self logDirectory]]) return nil;
	
	NSArray *filesArr = [mana contentsOfDirectoryAtPath:[self logDirectory] error:nil];
	NSLog(@"%@",filesArr);
	
	NSArray *sortArr = [filesArr sortedArrayUsingComparator:^NSComparisonResult(NSString *  _Nonnull obj1, NSString *  _Nonnull obj2) {
		// 配置全路径，找到文件，以文件创建时间进行排序
//		NSString *filePath1 = [[self logDirectory] stringByAppendingPathComponent:obj1];
//		NSString *filePath2 = [[self logDirectory] stringByAppendingPathComponent:obj2];
//
//		NSDictionary *file1Dcit = [mana attributesOfItemAtPath:filePath1 error:nil];
//		NSDictionary *file2Dict = [mana attributesOfItemAtPath:filePath2 error:nil];
//
//		NSDate *file1Date = [file1Dcit objectForKey:NSFileCreationDate];
//		NSDate *file2Date = [file2Dict objectForKey:NSFileCreationDate];
//		return [file1Date compare:file2Date];
		return [obj1 compare:obj2];		// 直接按照文件名进行排序
	}];
	
	NSMutableArray *tmpArr = @[].mutableCopy;
	for (NSString *fileName in sortArr) {
		[tmpArr addObject:[[self logDirectory] stringByAppendingPathComponent:fileName]];
	}
	return tmpArr;
	
}

@end
