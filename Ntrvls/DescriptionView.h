//
//  descriptionView.h
//  Ntrvls


#import <UIKit/UIKit.h>

@interface DescriptionView : UIView

@property (strong, nonatomic) NSString *intervalDescription;
@property (strong, nonatomic) UIImage *image;


-(instancetype)initWithFrame:(CGRect)frame andImage:(UIImage *)image;

@end
