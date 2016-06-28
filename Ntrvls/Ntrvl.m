//
//  Ntrvl.m
//  Ntrvls


#import "Ntrvl.h"

@implementation Ntrvl



- (Ntrvl *)initWithIntervalDescription:(NSString *)intervalDescription andDuration:(NSTimeInterval)duration {
    
    self = [super init];
    
    if (self) {
        self.intervalDescription = intervalDescription;
        self.duration = duration;
    }
    return self;
}


@end
