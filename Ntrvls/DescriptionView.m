//
//  descriptionView.m
//  Ntrvls


#import "DescriptionView.h"



@implementation DescriptionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithFrame:(CGRect)frame andImage:(UIImage *)image {
    
    self = [super init];
    
    if (self) {
        self.frame = frame;
        self.image = image;
        
        
        UIImageView *topLeftImageView = [[UIImageView alloc]initWithFrame:CGRectMake(-self.frame.size.width/3, -self.frame.size.height * 2/5, self.frame.size.width/3, self.frame.size.height * 2/5)];
        topLeftImageView.image = self.image;
        topLeftImageView.contentMode = UIViewContentModeTopLeft;
        topLeftImageView.backgroundColor = [UIColor yellowColor];
        topLeftImageView.clipsToBounds = YES;
        [self addSubview:topLeftImageView];
        
        UIImageView *topCenterImageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width/3, -self.frame.size.height * 2/5, self.frame.size.width/3, self.frame.size.height * 2/5)];
        topCenterImageView.image = self.image;
        topCenterImageView.contentMode = UIViewContentModeTop;
        topCenterImageView.clipsToBounds = YES;
        topCenterImageView.backgroundColor = [UIColor yellowColor];
        [self addSubview:topCenterImageView];
        
        UIImageView *topRightImageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width*1.3, -self.frame.size.height * 2/5, self.frame.size.width/3, self.frame.size.height * 2/5)];
        topRightImageView.image = self.image;
        topRightImageView.contentMode = UIViewContentModeTopRight;
        topRightImageView.clipsToBounds = YES;
        topRightImageView.backgroundColor = [UIColor yellowColor];
        [self addSubview:topRightImageView];
        
        UIImageView *leftImageView = [[UIImageView alloc]initWithFrame:CGRectMake(-self.frame.size.width * 1.5, self.frame.size.height * 2/5, self.frame.size.width/2, self.frame.size.height * 1/5)];
        leftImageView.image = self.image;
        leftImageView.contentMode = UIViewContentModeLeft;
        leftImageView.clipsToBounds = YES;
        leftImageView.backgroundColor = [UIColor yellowColor];
        [self addSubview:leftImageView];
        
        UIImageView *rightImageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width * 1.5, self.frame.size.height * 2/5, self.frame.size.width/2, self.frame.size.height * 1/5)];
        rightImageView.image = self.image;
        rightImageView.contentMode = UIViewContentModeRight;
        rightImageView.clipsToBounds = YES;
        rightImageView.backgroundColor = [UIColor yellowColor];
        [self addSubview:rightImageView];
        
        UIImageView *bottomLeftImageView = [[UIImageView alloc]initWithFrame:CGRectMake(-self.frame.size.width/3, self.frame.size.height, self.frame.size.width/3, self.frame.size.height * 2/5)];
        bottomLeftImageView.image = self.image;
        bottomLeftImageView.contentMode = UIViewContentModeBottomLeft;
        bottomLeftImageView.clipsToBounds = YES;
        bottomLeftImageView.backgroundColor = [UIColor yellowColor];
        [self addSubview:bottomLeftImageView];
        
        UIImageView *bottomCenterImageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width/3, self.frame.size.height, self.frame.size.width/3, self.frame.size.height * 2/5)];
        bottomCenterImageView.image = self.image;
        bottomCenterImageView.contentMode = UIViewContentModeBottom;
        bottomCenterImageView.clipsToBounds = YES;
        bottomCenterImageView.backgroundColor = [UIColor yellowColor];
        [self addSubview:bottomCenterImageView];
        
        UIImageView *bottomRightImageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width*1.3, self.frame.size.height, self.frame.size.width/3, self.frame.size.height * 2/5)];
        bottomRightImageView.image = self.image;
        bottomRightImageView.contentMode = UIViewContentModeBottomRight;
        bottomRightImageView.clipsToBounds = YES;
        bottomRightImageView.backgroundColor = [UIColor yellowColor];
        [self addSubview:bottomRightImageView];
        
        
        [UIImageView animateWithDuration: 0.2 delay: 0 options: UIViewAnimationOptionCurveEaseOut animations:^{
            
            topLeftImageView.frame = CGRectMake(0, 0, topLeftImageView.frame.size.width, topLeftImageView.frame.size.height);
            
            topRightImageView.frame = CGRectMake((self.frame.size.width * 2/3), 0, topRightImageView.frame.size.width, topRightImageView.frame.size.height);
            
            bottomLeftImageView.frame = CGRectMake(0, self.frame.size.height * 3/5, bottomLeftImageView.frame.size.width, bottomLeftImageView.frame.size.height);
            
            bottomRightImageView.frame = CGRectMake(self.frame.size.width * 2/3, self.frame.size.height * 3/5, bottomRightImageView.frame.size.width, bottomRightImageView.frame.size.height);
            
            bottomCenterImageView.frame = CGRectMake(self.frame.size.width/3, self.frame.size.height * 3/5, bottomCenterImageView.frame.size.width, bottomCenterImageView.frame.size.height);
            
            topCenterImageView.frame = CGRectMake(self.frame.size.width/3, 0, topCenterImageView.frame.size.width, topCenterImageView.frame.size.height);
            
            leftImageView.frame = CGRectMake(0, self.frame.size.height * 2/5, leftImageView.frame.size.width, leftImageView.frame.size.height);
            
            rightImageView.frame = CGRectMake(self.frame.size.width/2 , self.frame.size.height * 2/5, rightImageView.frame.size.width, rightImageView.frame.size.height);
            
        } completion:^(BOOL finished) {
            
            //            [self removeFromSuperview];
        }];
        
        [UIView animateWithDuration: 0.2 delay: 0.7 options: 0 animations:^{
            
            
            topLeftImageView.frame = CGRectMake(-self.frame.size.width/3, -self.frame.size.height * 2/5, self.frame.size.width/3, self.frame.size.height * 2/5);
            topLeftImageView.backgroundColor = [UIColor greenColor];
            
            topCenterImageView.frame = CGRectMake(self.frame.size.width/3, -self.frame.size.height * 2/5, self.frame.size.width/3, self.frame.size.height * 2/5);
            topCenterImageView.backgroundColor = [UIColor greenColor];
            
            topRightImageView.frame = CGRectMake(self.frame.size.width*1.3, -self.frame.size.height * 2/5, self.frame.size.width/3, self.frame.size.height * 2/5);
            topRightImageView.backgroundColor = [UIColor greenColor];
            
            leftImageView.frame = CGRectMake(-self.frame.size.width * 1.5, self.frame.size.height * 2/5, self.frame.size.width/2, self.frame.size.height * 1/5);
            leftImageView.backgroundColor = [UIColor greenColor];
            
            rightImageView.frame = CGRectMake(self.frame.size.width * 1.5, self.frame.size.height * 2/5, self.frame.size.width/2, self.frame.size.height * 1/5);
            rightImageView.backgroundColor = [UIColor greenColor];
            
            bottomLeftImageView.frame = CGRectMake(-self.frame.size.width/3, self.frame.size.height, self.frame.size.width/3, self.frame.size.height * 2/5);
            bottomLeftImageView.backgroundColor = [UIColor greenColor];
            
            bottomCenterImageView.frame = CGRectMake(self.frame.size.width/3, self.frame.size.height, self.frame.size.width/3, self.frame.size.height * 2/5);
            bottomCenterImageView.backgroundColor = [UIColor greenColor];
            
            bottomRightImageView.frame = CGRectMake(self.frame.size.width*1.3, self.frame.size.height, self.frame.size.width/3, self.frame.size.height * 2/5);
            bottomRightImageView.backgroundColor = [UIColor greenColor];
            
            
        } completion: ^(BOOL finished) {
            // remove from superview
            [self removeFromSuperview];
        }];
    }
    
    return self;
}


-(instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        self.frame = frame;

        
        UIImageView *topLeftImageView = [[UIImageView alloc]initWithFrame:CGRectMake(-self.frame.size.width/3, -self.frame.size.height * 2/5, self.frame.size.width/3, self.frame.size.height * 2/5)];
        topLeftImageView.image = [UIImage new];
        topLeftImageView.contentMode = UIViewContentModeTopLeft;
        topLeftImageView.backgroundColor = [UIColor yellowColor];
        topLeftImageView.clipsToBounds = YES;
        [self addSubview:topLeftImageView];
        
        UIImageView *topCenterImageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width/3, -self.frame.size.height * 2/5, self.frame.size.width/3, self.frame.size.height * 2/5)];
        topCenterImageView.image = [UIImage new];
        topCenterImageView.contentMode = UIViewContentModeTop;
        topCenterImageView.clipsToBounds = YES;
        topCenterImageView.backgroundColor = [UIColor yellowColor];
        [self addSubview:topCenterImageView];
        
        UIImageView *topRightImageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width*1.3, -self.frame.size.height * 2/5, self.frame.size.width/3, self.frame.size.height * 2/5)];
        topRightImageView.image = [UIImage new];
        topRightImageView.contentMode = UIViewContentModeTopRight;
        topRightImageView.clipsToBounds = YES;
        topRightImageView.backgroundColor = [UIColor yellowColor];
        [self addSubview:topRightImageView];
        
        UIImageView *leftImageView = [[UIImageView alloc]initWithFrame:CGRectMake(-self.frame.size.width * 1.5, self.frame.size.height * 2/5, self.frame.size.width/2, self.frame.size.height * 1/5)];
        leftImageView.image = [UIImage new];
        leftImageView.contentMode = UIViewContentModeLeft;
        leftImageView.clipsToBounds = YES;
        leftImageView.backgroundColor = [UIColor yellowColor];
        [self addSubview:leftImageView];
        
        UIImageView *rightImageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width * 1.5, self.frame.size.height * 2/5, self.frame.size.width/2, self.frame.size.height * 1/5)];
        rightImageView.image = [UIImage new];
        rightImageView.contentMode = UIViewContentModeRight;
        rightImageView.clipsToBounds = YES;
        rightImageView.backgroundColor = [UIColor yellowColor];
        [self addSubview:rightImageView];
        
        UIImageView *bottomLeftImageView = [[UIImageView alloc]initWithFrame:CGRectMake(-self.frame.size.width/3, self.frame.size.height, self.frame.size.width/3, self.frame.size.height * 2/5)];
        bottomLeftImageView.image = [UIImage new];
        bottomLeftImageView.contentMode = UIViewContentModeBottomLeft;
        bottomLeftImageView.clipsToBounds = YES;
        bottomLeftImageView.backgroundColor = [UIColor yellowColor];
        [self addSubview:bottomLeftImageView];
        
        UIImageView *bottomCenterImageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width/3, self.frame.size.height, self.frame.size.width/3, self.frame.size.height * 2/5)];
        bottomCenterImageView.image = [UIImage new];
        bottomCenterImageView.contentMode = UIViewContentModeBottom;
        bottomCenterImageView.clipsToBounds = YES;
        bottomCenterImageView.backgroundColor = [UIColor yellowColor];
        [self addSubview:bottomCenterImageView];
        
        UIImageView *bottomRightImageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width*1.3, self.frame.size.height, self.frame.size.width/3, self.frame.size.height * 2/5)];
        bottomRightImageView.image = [UIImage new];
        bottomRightImageView.contentMode = UIViewContentModeBottomRight;
        bottomRightImageView.clipsToBounds = YES;
        bottomRightImageView.backgroundColor = [UIColor yellowColor];
        [self addSubview:bottomRightImageView];

        
        [UIImageView animateWithDuration: 1 delay: 0 options: UIViewAnimationOptionCurveEaseOut animations:^{
            
            topLeftImageView.frame = CGRectMake(0, 0, topLeftImageView.frame.size.width, topLeftImageView.frame.size.height);
            
            topRightImageView.frame = CGRectMake((self.frame.size.width * 2/3), 0, topRightImageView.frame.size.width, topRightImageView.frame.size.height);
            
            bottomLeftImageView.frame = CGRectMake(0, self.frame.size.height * 3/5, bottomLeftImageView.frame.size.width, bottomLeftImageView.frame.size.height);
            
            bottomRightImageView.frame = CGRectMake(self.frame.size.width * 2/3, self.frame.size.height * 3/5, bottomRightImageView.frame.size.width, bottomRightImageView.frame.size.height);
            
            bottomCenterImageView.frame = CGRectMake(self.frame.size.width/3, self.frame.size.height * 3/5, bottomCenterImageView.frame.size.width, bottomCenterImageView.frame.size.height);
            
            topCenterImageView.frame = CGRectMake(self.frame.size.width/3, 0, topCenterImageView.frame.size.width, topCenterImageView.frame.size.height);
            
            leftImageView.frame = CGRectMake(0, self.frame.size.height * 2/5, leftImageView.frame.size.width, leftImageView.frame.size.height);
            
            rightImageView.frame = CGRectMake(self.frame.size.width/2 , self.frame.size.height * 2/5, rightImageView.frame.size.width, rightImageView.frame.size.height);
            
        } completion:^(BOOL finished) {
            
//            [self removeFromSuperview];
        }];
        
        [UIView animateWithDuration: 1 delay: 0.5 options: 0 animations:^{
            

            topLeftImageView.frame = CGRectMake(-self.frame.size.width/3, -self.frame.size.height * 2/5, self.frame.size.width/3, self.frame.size.height * 2/5);
            topLeftImageView.backgroundColor = [UIColor greenColor];
            
            topCenterImageView.frame = CGRectMake(self.frame.size.width/3, -self.frame.size.height * 2/5, self.frame.size.width/3, self.frame.size.height * 2/5);
            topCenterImageView.backgroundColor = [UIColor greenColor];
            
            topRightImageView.frame = CGRectMake(self.frame.size.width*1.3, -self.frame.size.height * 2/5, self.frame.size.width/3, self.frame.size.height * 2/5);
            topRightImageView.backgroundColor = [UIColor greenColor];
            
            leftImageView.frame = CGRectMake(-self.frame.size.width * 1.5, self.frame.size.height * 2/5, self.frame.size.width/2, self.frame.size.height * 1/5);
            leftImageView.backgroundColor = [UIColor greenColor];
            
            rightImageView.frame = CGRectMake(self.frame.size.width * 1.5, self.frame.size.height * 2/5, self.frame.size.width/2, self.frame.size.height * 1/5);
            rightImageView.backgroundColor = [UIColor greenColor];
            
            bottomLeftImageView.frame = CGRectMake(-self.frame.size.width/3, self.frame.size.height, self.frame.size.width/3, self.frame.size.height * 2/5);
            bottomLeftImageView.backgroundColor = [UIColor greenColor];
            
            bottomCenterImageView.frame = CGRectMake(self.frame.size.width/3, self.frame.size.height, self.frame.size.width/3, self.frame.size.height * 2/5);
            bottomCenterImageView.backgroundColor = [UIColor greenColor];
            
            bottomRightImageView.frame = CGRectMake(self.frame.size.width*1.3, self.frame.size.height, self.frame.size.width/3, self.frame.size.height * 2/5);
            bottomRightImageView.backgroundColor = [UIColor greenColor];
            
            
            // animate out of screen
        } completion: ^(BOOL finished) {
            // anything?
            // remove from superview
            [self removeFromSuperview];
        }];
        
        
    }
    
    return self;
}

@end
