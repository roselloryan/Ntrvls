//
//  APIClient.h
//  Ntrvls
//
//  Created by RYAN ROSELLO on 7/13/16.
//  Copyright © 2016 RYAN ROSELLO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NtrvlsAPIClient : NSObject

+ (void)loginIntoStrava;

+ (void)completeTokenExchangeWithResponseURL:(NSURL *)responseURL;

+ (void)postNtrvlWorkoutToStravaWithname:(NSString *)name type:(NSString *)type startDateLocal: (NSString *)startDateLocal elapsedTime:(NSUInteger)elapsedTime description: (NSString *)description withCompletionBlock:(void(^)(BOOL success))completionBlock;

@end
