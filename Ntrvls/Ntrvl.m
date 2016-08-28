
#import "Ntrvl.h"

@implementation Ntrvl

// Insert code here to add functionality to your managed object subclass

- (Ntrvl *)initWithScreenColor:(NSString *)screenColor intervalDuration:(NSInteger)intervalDuration andIntervalDescription:(NSString *)intervalDescription {
    
    self = [super init];
    
    if (self) {
        self.intervalDuration = intervalDuration;
        self.intervalDescription = intervalDescription;
        self.screenColor = screenColor;
    }
    
    return self;
}

@end
