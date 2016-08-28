
#import "NtrvlWorkout.h"

@implementation NtrvlWorkout

// Insert code here to add functionality to your managed object subclass

- (NtrvlWorkout *)initWithWorkoutTitle:(NSString *)workoutTitle andCreationDate:(NSTimeInterval)creationDate {
    
    self = [super init];
    
    if (self) {
        self.workoutTitle = workoutTitle;
        self.creationDate = creationDate;
        self.interval = [[NSOrderedSet alloc]init];
    }
    
    return self;
}


@end
