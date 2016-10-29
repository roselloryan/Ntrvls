
#import "NtrvlsConstants.h"

@implementation NtrvlsConstants

NSString* const kWorkoutCopyName = @"RARWorkoutCopy";

NSString* const BaseStravaOAuthURL = @"https://www.strava.com/oauth/authorize?";
NSString* const ClientID = @"client_id=12251";
NSString* const ResponseType = @"&response_type=code";
NSString* const RedirectURI = @"&redirect_uri=RAR-Ntrvls-app://oauth";
NSString* const Scope = @"&scope=write";

NSString* const BaseStravaTokenURL = @"https://www.strava.com/oauth/token?";
NSString* const ClientSecret = @"&client_secret=2eaebc0ba4804fe621902fffb2834cdbaf0e4af2";

NSString* const BaseStravaPostActivitieURL = @"https://www.strava.com/api/v3/activities?";

@end
