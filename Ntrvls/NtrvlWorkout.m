
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

- (void)updateTotalTime {
    NSUInteger tempTime = 0;
    for (NSInteger i = 1; i < self.interval.count - 1; i++) {
        tempTime += self.interval[i].intervalDuration;
    }
    self.totalTime = tempTime;
}
    
@end
