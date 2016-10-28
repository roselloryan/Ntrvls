
#import "NtrvlsAPIClient.h"
#import "Constants.h"
#import "JNKeychainWrapper.h"


@interface NtrvlsAPIClient ()



@end


@implementation NtrvlsAPIClient



+ (void)loginIntoStravaWithSuccessBlock:(void(^)(BOOL success))successBlock {
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@%@%@", BaseStravaOAuthURL, ClientID, ResponseType, Scope, RedirectURI];    
    NSURL *url = [NSURL URLWithString: urlString];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL: url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        // handle http error here if wanted
        if (!data) {
            
            successBlock(NO);
        }
        else {
            successBlock(YES);
            [[UIApplication sharedApplication] openURL:url];
        }
    }];
    [dataTask resume];
}


+ (void)completeTokenExchangeWithResponseURL:(NSURL *)responseURL {

    NSString *codeString = [[[NSString stringWithFormat:@"%@", responseURL] componentsSeparatedByString:@"="] lastObject];
    
    if ([codeString isEqualToString:@"access_denied"]) {
        
        // handle access denied error
        NSLog(@"ACCESS DENIED: handle this issue");
    }
    
    else {
    
        NSString *urlString = [NSString stringWithFormat:@"%@%@%@&code=%@", BaseStravaTokenURL, ClientID, ClientSecret, codeString];
        NSURL *url = [NSURL URLWithString: urlString];
        
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL: url];
        urlRequest.HTTPMethod = @"POST";
        
        NSURLSession *urlSession = [NSURLSession sharedSession];
        
        NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest: urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
            
            if (data) {
                NSError *dictionaryError = nil;
                NSDictionary *dataResponseDict = [NSJSONSerialization JSONObjectWithData: data options: 0 error: &dictionaryError];
                NSLog(@"\n%@", dataResponseDict);
                
                // token for header
                NSString *accessToken = dataResponseDict[@"access_token"];
                
                // if access token has changed, save new token to keychain
                if (![accessToken isEqualToString: [JNKeychainWrapper loadValueForKey:@"access_token"]]) {
                    
                    [JNKeychainWrapper saveValue: accessToken forKey:@"access_token"];
                    NSLog(@"New Access Token saved!");
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName: @"allowedAccess" object: nil];
            }
            
            else {
                // handle response error? No internet connection?
                [[NSNotificationCenter defaultCenter] postNotificationName: @"deniedAccess" object: nil];
            }
        }];
        
        [dataTask resume];
    }
}


+ (void)postNtrvlWorkoutToStravaWithname:(NSString *)name type:(NSString *)type startDateLocal: (NSString *)startDateLocal elapsedTime:(NSUInteger)elapsedTime description: (NSString *)description withCompletionBlock:(void(^)(BOOL success))completionBlock {
    
    NSString *accessToken = [JNKeychainWrapper loadValueForKey: @"access_token"];
    NSLog(@"access_token = %@", accessToken);
    
    //name=Treadmill Run&elapsed_time=123456&start_date_local=2013-10-23T10:02:13Z&type=run
    
    if (accessToken) {
        NSString *urlString = [NSString stringWithFormat:@"%@name=%@&elapsed_time=%lu&start_date_local=%@&type=%@&description=%@", BaseStravaPostActivitieURL, name, elapsedTime, startDateLocal, type, description];
        
        NSLog(@"post url: %@", urlString);
    
        NSURL *url = [NSURL URLWithString: urlString];
    
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL: url];
        urlRequest.HTTPMethod = @"POST";
        NSString *authHeaderString = [NSString stringWithFormat: @"Bearer %@", accessToken];
        [urlRequest addValue: authHeaderString forHTTPHeaderField:@"Authorization"];
        
        NSURLSession *urlSession = [NSURLSession sharedSession];
        
        NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest: urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if (data) {
                NSError *dictionaryError = nil;
                NSDictionary *dataResponseDict = [NSJSONSerialization JSONObjectWithData: data options: 0 error: &dictionaryError];
                NSLog(@"\n dataResponseDict: %@", dataResponseDict);
                
                NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse *)response;
                NSLog(@"httpURLResponse.statusCode: %ld", (long)httpURLResponse.statusCode);
                
                if (httpURLResponse.statusCode == 201) {
                    completionBlock(YES);
                }
                else {
                    completionBlock(NO);
                }
            }
            else {
                completionBlock(NO);
            }
        }];
        [dataTask resume];
    }
    
    else {
        // TODO: handle error for nil token string or failed posting
        
        completionBlock(NO);
    }
    
}

/*
 name:	string required
 type:	string required, case insensitive
 ‘Ride’, ‘Run’, ‘Swim’, etc. See above for all possible types.
 start_date_local:	datetime required
 ISO 8601 formatted date time, see Dates for more information
 elapsed_time:	integer required
 seconds
 description:	string optional
 */


@end
