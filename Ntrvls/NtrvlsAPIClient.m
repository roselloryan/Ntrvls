//
//  APIClient.m
//  Ntrvls


#import "NtrvlsAPIClient.h"
#import "Constants.h"
#import "JNKeychainWrapper.h"


@interface NtrvlsAPIClient ()

@property (strong, nonatomic) NSString *accessToken;

@end


@implementation NtrvlsAPIClient



+ (void)loginIntoStrava {
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@%@%@", BaseStravaOAuthURL, ClientID, ResponseType, Scope, RedirectURI];    
    NSURL *url = [NSURL URLWithString:urlString];
    
    [[UIApplication sharedApplication] openURL:url];
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
        NSString *urlString = [NSString stringWithFormat:@"%@name=%@&elapsed_time=%lu&start_date_local=%@&type=%@", BaseStravaPostActivitieURL, name, elapsedTime, startDateLocal, type];
        
        NSLog(@"post url: %@", urlString);
    
        NSURL *url = [NSURL URLWithString: urlString];
    
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL: url];
        urlRequest.HTTPMethod = @"POST";
        NSString *authHeaderString = [NSString stringWithFormat: @"Bearer %@", accessToken];
        NSLog(@"Auth header string: %@", authHeaderString);
        
        [urlRequest addValue: authHeaderString forHTTPHeaderField:@"Authorization"];
        
        NSURLSession *urlSession = [NSURLSession sharedSession];
        
        NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest: urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
           

            // stuff
            if (data) {
                NSError *dictionaryError = nil;
                NSDictionary *dataResponseDict = [NSJSONSerialization JSONObjectWithData: data options: 0 error: &dictionaryError];
                NSLog(@"\n dataResponseDict: %@", dataResponseDict);
                
                completionBlock(YES);
                
            }
    
            NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse *)response;
            
            NSLog(@"httpURLResponse.statusCode: %ld", (long)httpURLResponse.statusCode);
        }];
        
        [dataTask resume];
        
        
        
//        completionBlock(YES);
    }
    else {
        // handle error for nil token string
        
        completionBlock(NO);
    }
    
    
}

+ (void)setAccessTokenValue {
    
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
