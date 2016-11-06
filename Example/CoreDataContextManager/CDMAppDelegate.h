// This software is released under the MIT License.
// http://opensource.org/licenses/mit-license.php

@import UIKit;

#import "CDMCoreDataContextManager.h"

@interface CDMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic, nonnull) UIWindow *window;
@property (strong, nonatomic, nonnull) CDMCoreDataContextManager *coreDataContextManager;

+ (CDMAppDelegate * _Nonnull)appDelegate;

@end
