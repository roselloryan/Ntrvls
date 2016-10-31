
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Reachability.h"

@interface NtrvlsAPIClient : NSObject

+ (void)completeTokenExchangeWithResponseURL:(NSURL *)responseURL;

+ (void)postNtrvlWorkoutToStravaWithname:(NSString *)name type:(NSString *)type startDateLocal: (NSString *)startDateLocal elapsedTime:(NSUInteger)elapsedTime description: (NSString *)description withCompletionBlock:(void(^)(BOOL success))completionBlock;

+ (void)loginIntoStravaWithSuccessBlock:(void(^)(BOOL success))successBlock;

+ (BOOL)testForInternet;

@end
