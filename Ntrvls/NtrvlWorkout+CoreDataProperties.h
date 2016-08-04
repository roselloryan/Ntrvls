//
//  NtrvlWorkout+CoreDataProperties.h
//  Ntrvls
//
//  Created by RYAN ROSELLO on 7/12/16.
//  Copyright © 2016 RYAN ROSELLO. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "NtrvlWorkout.h"
#import "Ntrvl.h"

NS_ASSUME_NONNULL_BEGIN

@interface NtrvlWorkout (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *workoutTitle;
@property (nonatomic) NSTimeInterval creationDate;
@property (nullable, nonatomic, retain) NSOrderedSet<Ntrvl *> *interval;

@end

@interface NtrvlWorkout (CoreDataGeneratedAccessors)

- (void)insertObject:(Ntrvl *)value inIntervalAtIndex:(NSUInteger)idx;
- (void)removeObjectFromIntervalAtIndex:(NSUInteger)idx;
- (void)insertInterval:(NSArray<Ntrvl *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeIntervalAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInIntervalAtIndex:(NSUInteger)idx withObject:(Ntrvl *)value;
- (void)replaceIntervalAtIndexes:(NSIndexSet *)indexes withInterval:(NSArray<Ntrvl *> *)values;
- (void)addIntervalObject:(Ntrvl *)value;
- (void)removeIntervalObject:(Ntrvl *)value;
- (void)addInterval:(NSOrderedSet<Ntrvl *> *)values;
- (void)removeInterval:(NSOrderedSet<Ntrvl *> *)values;

@end

NS_ASSUME_NONNULL_END
