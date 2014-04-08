A simple capture / email object for bug reporting and debugging.

# Example Usage

    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
    {
        // ...

        #ifdef SOME_DEBUG_FLAG    
        if (!self.snapper) {
            UITapGestureRecognizer *recognizer = [UITapGestureRecognizer new];
            recognizer.numberOfTapsRequired = 3;
            [self.window addGestureRecognizer:recognizer];
            
            DENDebugSnapper *snapper = [DENDebugSnapper new];
            snapper.window = self.window;
            snapper.gestureRecognizer = recognizer;
            snapper.shouldSnapOnUserScreenshot = YES;
            snapper.captureBlock = ^{
                NSString *tempDirectory = NSTemporaryDirectory();
                NSString *cacheDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
                
                NSArray *paths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cacheDirectory error:nil];
                
                NSMutableArray *sqlitePaths = [NSMutableArray new];
                [paths enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL *stop) {
                    if ([path rangeOfString:@".sqlite"].location != NSNotFound) {
                        [sqlitePaths addObject:[cacheDirectory stringByAppendingPathComponent:path]];
                    }
                }];
                
                NSString *outputPath = [tempDirectory stringByAppendingPathComponent:@"Snapshot.zip"];
                [SSZipArchive createZipFileAtPath:outputPath withFilesAtPaths:sqlitePaths];
                
                return [NSData dataWithContentsOfFile:outputPath];
            };
            
            self.snapper = snapper;
        }
        #endif
    }
