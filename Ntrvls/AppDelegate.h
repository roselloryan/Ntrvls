
#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// CoreDataAccessorMethods for NtrvlWorkout
//static NSString *const kItemsKey = @"interval";
//
//- (void)insertObject:(Ntrvl *)value inIntervalAtIndex:(NSUInteger)idx {
//    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
//    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    [tmpOrderedSet insertObject:value atIndex:idx];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)removeObjectFromIntervalAtIndex:(NSUInteger)idx {
//    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
//    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    [tmpOrderedSet removeObjectAtIndex:idx];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)insertInterval:(NSArray<Ntrvl *> *)values atIndexes:(NSIndexSet *)indexes {
//    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    [tmpOrderedSet insertObjects:values atIndexes:indexes];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)removeIntervalAtIndexes:(NSIndexSet *)indexes {
//    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    [tmpOrderedSet removeObjectsAtIndexes:indexes];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)replaceObjectInIntervalAtIndex:(NSUInteger)idx withObject:(Ntrvl *)value {
//    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
//    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kItemsKey];
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    [tmpOrderedSet replaceObjectAtIndex:idx withObject:value];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)replaceIntervalAtIndexes:(NSIndexSet *)indexes withInterval:(NSArray<Ntrvl *> *)values {
//    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kItemsKey];
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    [tmpOrderedSet replaceObjectsAtIndexes:indexes withObjects:values];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)addIntervalObject:(Ntrvl *)value {
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    NSUInteger idx = [tmpOrderedSet count];
//    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
//    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//    [tmpOrderedSet addObject:value];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)removeIntervalObject:(Ntrvl *)value {
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    NSUInteger idx = [tmpOrderedSet indexOfObject:value];
//    if (idx != NSNotFound) {
//        NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
//        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//        [tmpOrderedSet removeObject:value];
//        [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//    }
//}
//
//- (void)addInterval:(NSOrderedSet<Ntrvl *> *)values {
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
//    NSUInteger valuesCount = [values count];
//    NSUInteger objectsCount = [tmpOrderedSet count];
//    for (NSUInteger i = 0; i < valuesCount; ++i) {
//        [indexes addIndex:(objectsCount + i)];
//    }
//    if (valuesCount > 0) {
//        [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//        [tmpOrderedSet addObjectsFromArray:[values array]];
//        [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//        [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//    }
//}
//
//- (void)removeInterval:(NSOrderedSet<Ntrvl *> *)values {
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
//    for (id value in values) {
//        NSUInteger idx = [tmpOrderedSet indexOfObject:value];
//        if (idx != NSNotFound) {
//            [indexes addIndex:idx];
//        }
//    }
//    if ([indexes count] > 0) {
//        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//        [tmpOrderedSet removeObjectsAtIndexes:indexes];
//        [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//    }
//}


@end

