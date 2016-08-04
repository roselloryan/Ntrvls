//
//  Ntrvl.h
//  Ntrvls


#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface Ntrvl : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

- (Ntrvl *)initWithScreenColor:(NSString *)screenColor intervalDuration:(NSInteger)intervalDuration andIntervalDescription:(NSString *)intervalDescription;


@end

NS_ASSUME_NONNULL_END

#import "Ntrvl+CoreDataProperties.h"
