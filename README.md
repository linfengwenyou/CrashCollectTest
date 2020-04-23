# CrashCollectTest
模拟crash日志收集上传流程

#### 开启日志监控
```
[[CrashManager shareInstance] startCrashMonitor];
```
### 在适当的时候上送日志
```
[[CrashManager shareInstance] uploadLogInfo];
```

### 构造一个crash
```
// 构造crash
[self performSelector:@selector(testCrashAction)];
```

## 注意
工程引用了第三方库`ZipArchive`, 需要再`Podfile`文件中调整
```
# 我本地用的是本地路径，如果没有本地路径，需要将path操作移除，重新pod install
pod 'SSZipArchive' ,:path=>'~/Downloads/ZipArchive'	

```
