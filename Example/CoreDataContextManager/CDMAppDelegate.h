// This is free and unencumbered software released into the public domain.
// For more information, please refer to <http://unlicense.org/>

@import UIKit;

#import "CDMCoreDataContextManager.h"

@interface CDMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic, nonnull) UIWindow *window;
@property (strong, nonatomic, nonnull) CDMCoreDataContextManager *coreDataContextManager;

+ (CDMAppDelegate * _Nonnull)appDelegate;

@end
