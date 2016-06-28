//
//  Ntrvl.h
//  Ntrvls


#import <Foundation/Foundation.h>

@interface Ntrvl : NSObject

@property (assign, nonatomic) NSTimeInterval duration;
@property (strong, nonatomic) NSString *intervalDescription;
@property (strong, nonatomic) NSString *nextSegment;



- (Ntrvl *)initWithIntervalDescription:(NSString *)intervalDescription andDuration:(NSTimeInterval)duration;

@end
