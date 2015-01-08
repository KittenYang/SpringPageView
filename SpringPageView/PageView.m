//
//  PageView.m
//  SpringPageView
//
//  Created by Kitten Yang on 15/1/7.
//  Copyright (c) 2015年 Kitten Yang. All rights reserved.
//

#import "PageView.h"


@interface PageView()

@property (nonatomic) UIImage         *image;
@property (nonatomic) UIImageView     *topView;
@property (nonatomic) UIImageView     *bottomView;
@property (nonatomic) NSUInteger      initialLocation;
@property (nonatomic) CAGradientLayer *topShadowLayer;
@property (nonatomic) CAGradientLayer *bottomShadowLayer;
@end


@implementation PageView

-(void)awakeFromNib{
    self.image = [UIImage imageNamed:@"avator.jpg"];
    [self addTopView];
    [self addBottomView];
    [self addGestureRecognizer];
    
}



#pragma mark - 上半部分
-(void) addTopView{
    
    self.topView                   = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetMidY(self.bounds))];
    //把锚点移到上半视图的底部居中
    self.topView.layer.anchorPoint = CGPointMake(0.5, 1.0);
    //把锚点位置固定在【整个PageView的中心】（可以理解为anchorPoint会吸附到position）
    self.topView.layer.position    = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    //使得topView具有透视效果
    self.topView.layer.transform   = [self setTransform3D];
    
    self.topView.contentMode = UIViewContentModeScaleAspectFill;
    self.topView.image = [self cutImageWithID:@"top"];
    self.topView.userInteractionEnabled = YES;
    
    self.topShadowLayer = [CAGradientLayer layer];
    self.topShadowLayer.frame = self.topView.bounds;
    self.topShadowLayer.colors = @[(id)[UIColor clearColor].CGColor, (id)[UIColor blackColor].CGColor];
    self.topShadowLayer.opacity = 0;
    [self.topView.layer addSublayer:self.topShadowLayer];
    
    [self addSubview:_topView];
}

-(void) addBottomView{
    self.bottomView                   = [[UIImageView alloc]initWithFrame:CGRectMake(0, CGRectGetMidY(self.bounds), CGRectGetWidth(self.bounds), CGRectGetMidY(self.bounds))];
    //把锚点移到下半视图的顶部居中
    self.bottomView.layer.anchorPoint = CGPointMake(0.5, 0);
    //把锚点位置固定在【整个PageView的中心】
    self.bottomView.layer.position    = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    self.bottomView.layer.transform   = [self setTransform3D];
    
    self.bottomView.contentMode = UIViewContentModeScaleAspectFill;
    self.bottomView.image = [self cutImageWithID:@"bottom"];
    self.bottomView.userInteractionEnabled = YES;
    
    //初始化阴影图层
    self.bottomShadowLayer = [CAGradientLayer layer];
    self.bottomShadowLayer.frame = self.bottomView.bounds;
    self.bottomShadowLayer.colors = @[(id)[UIColor blackColor].CGColor, (id)[UIColor clearColor].CGColor];
    self.bottomShadowLayer.opacity = 0;
    [self.bottomView.layer addSublayer:self.bottomShadowLayer];
    
    [self addSubview:_bottomView];
}


-(void)addGestureRecognizer{
    UIPanGestureRecognizer *panGesture   = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan1:)];
    UITapGestureRecognizer *pokeGesture  = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(poke1:)];
    [self.topView addGestureRecognizer:panGesture];
    [self.topView addGestureRecognizer:pokeGesture];

    UIPanGestureRecognizer *panGesture2  =[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan2:)];
    UITapGestureRecognizer *pokeGesture2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(poke2:)];
    
    [self.bottomView addGestureRecognizer:panGesture2];
    [self.bottomView addGestureRecognizer:pokeGesture2];
    
}


#pragma mark  - method
//topView
-(void)pan1:(UIPanGestureRecognizer *)recognizer{
    CGPoint location = [recognizer locationInView:self];
    //获取手指在PageView中的初始坐标
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.initialLocation = location.y;
        [self bringSubviewToFront:self.topView];
    }
    
    //添加阴影
    if ([[self.topView.layer valueForKeyPath:@"transform.rotation.x"] floatValue] < -M_PI_2) {

        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue
                         forKey:kCATransactionDisableActions];
        self.topShadowLayer.opacity = 0.0;
        self.bottomShadowLayer.opacity = (location.y-self.initialLocation)/(CGRectGetHeight(self.bounds)-self.initialLocation);
        [CATransaction commit];
    } else {

        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue
                         forKey:kCATransactionDisableActions];
        CGFloat opacity = (location.y-self.initialLocation)/(CGRectGetHeight(self.bounds)-self.initialLocation);
        self.bottomShadowLayer.opacity = opacity;
        self.topShadowLayer.opacity = opacity;
        [CATransaction commit];
    }


    
    //如果手指在PageView里面,开始使用POPAnimation
    if([self isLocation:location InView:self]){
        //把一个PI平均分成可以下滑的最大距离份
        CGFloat percent = -M_PI / (CGRectGetHeight(self.bounds) - self.initialLocation);

        //POPAnimation的使用
        //创建一个Animation,设置为绕着X轴旋转。还记得我们上面设置的锚点吗？设置为（0.5，0.5）。这时什么意思呢？当我们设置kPOPLayerRotationX（绕X轴旋转），那么x就起作用了，绕x所在轴；kPOPLayerRotationY，y就起作用了，绕y所在轴。
        POPBasicAnimation *rotationAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotationX];
        
        //给这个animation设值。这个值根据手的滑动而变化，所以值会不断改变。又因为这个方法会实时调用，所以变化的值会实时显示在屏幕上。
        rotationAnimation.duration = 0.01;//默认的duration是0.4
        rotationAnimation.toValue =@((location.y-self.initialLocation)*percent);
        
        //把这个animation加到topView的layer,key只是个识别符。
        [self.topView.layer pop_addAnimation:rotationAnimation forKey:@"rotationAnimation"];

        //当松手的时候，自动复原
        if (recognizer.state == UIGestureRecognizerStateEnded ||
            recognizer.state == UIGestureRecognizerStateCancelled) {
            POPSpringAnimation *recoverAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotationX];
            recoverAnimation.springBounciness = 18.0f; //弹簧反弹力度
            recoverAnimation.dynamicsMass = 2.0f;
            recoverAnimation.dynamicsTension = 200;
            recoverAnimation.toValue = @(0);
            [self.topView.layer pop_addAnimation:recoverAnimation forKey:@"recoverAnimation"];
            self.topShadowLayer.opacity = 0.0;
            self.bottomShadowLayer.opacity = 0.0;
        }
        
    }
    
    //手指超出边界也自动复原
    if (location.y < 0 || (location.y - self.initialLocation)>(CGRectGetHeight(self.bounds))-(self.initialLocation)) {
        recognizer.enabled = NO;
        POPSpringAnimation *recoverAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotationX];
        recoverAnimation.springBounciness = 18.0f; //弹簧反弹力度
        recoverAnimation.dynamicsMass = 2.0f;
        recoverAnimation.dynamicsTension = 200;
        recoverAnimation.toValue = @(0);
        [self.topView.layer pop_addAnimation:recoverAnimation forKey:@"recoverAnimation"];
        self.topShadowLayer.opacity = 0.0;
        self.bottomShadowLayer.opacity = 0.0;
        
    }
    
    recognizer.enabled = YES;

    
}
-(void)poke1:(UITapGestureRecognizer *)recognizer{
    
}


#pragma mark  - bottomView
//bottomView
-(void)pan2:(UIPanGestureRecognizer *)recognizer{
    CGPoint location = [recognizer locationInView:self];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.initialLocation = location.y;
        [self bringSubviewToFront:self.bottomView];
    }
    
    
    //添加阴影
    if ([[self.bottomView.layer valueForKeyPath:@"transform.rotation.x"] floatValue] < M_PI_2) {

        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue
                         forKey:kCATransactionDisableActions];
        self.topShadowLayer.opacity = (self.initialLocation - location.y)/(self.initialLocation);

        self.bottomShadowLayer.opacity = (self.initialLocation - location.y)/(self.initialLocation);
        [CATransaction commit];
    } else {

        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue
                         forKey:kCATransactionDisableActions];
        CGFloat opacity = (location.y-self.initialLocation)/(CGRectGetHeight(self.bounds)-self.initialLocation);
        self.bottomShadowLayer.opacity = opacity;
        self.topShadowLayer.opacity = opacity;
        [CATransaction commit];    }
    

    //如果手指在PageView里面,开始使用POPAnimation
    if([self isLocation:location InView:self]){
        //把一个PI平均分成可以上滑的最大距离份
        CGFloat percent = -M_PI / self.initialLocation;
        
        POPBasicAnimation *rotationAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotationX];
        rotationAnimation.duration = 0.01;//默认的duration是0.4
        rotationAnimation.toValue =@((location.y-self.initialLocation)*percent);
        [self.bottomView.layer pop_addAnimation:rotationAnimation forKey:@"rotationAnimation"];
        if (recognizer.state == UIGestureRecognizerStateEnded ||
            recognizer.state == UIGestureRecognizerStateCancelled) {
            POPSpringAnimation *recoverAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotationX];
            recoverAnimation.springBounciness = 18.0f; //弹簧反弹力度
            recoverAnimation.dynamicsMass = 2.0f;
            recoverAnimation.dynamicsTension = 200;
            recoverAnimation.toValue = @(0);
            [self.bottomView.layer pop_addAnimation:recoverAnimation forKey:@"recoverAnimation"];
            self.topShadowLayer.opacity = 0.0;
            self.bottomShadowLayer.opacity = 0.0;
        }
        
    }
    if (location.y < 0 || (location.y - self.initialLocation)>(CGRectGetHeight(self.bounds))-(self.initialLocation)) {
        recognizer.enabled = NO;
        POPSpringAnimation *recoverAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotationX];
        recoverAnimation.springBounciness = 18.0f; //弹簧反弹力度
        recoverAnimation.dynamicsMass = 2.0f;
        recoverAnimation.dynamicsTension = 200;
        recoverAnimation.toValue = @(0);
        [self.bottomView.layer pop_addAnimation:recoverAnimation forKey:@"recoverAnimation"];
        self.topShadowLayer.opacity = 0.0;
        self.bottomShadowLayer.opacity = 0.0;
        
    }
    
    recognizer.enabled = YES;
}
-(void)poke2:(UITapGestureRecognizer *)recognizer{
    
}



#pragma mark ----------------一些工具方法
#pragma mark - 设置3D的透视效果
-(CATransform3D)setTransform3D{
    //如果不设置这个值，无论转多少角度都不会有3D效果
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 2.5/-2000;
    return transform;
}


#pragma mark - 把一张图片分成两部分
-(UIImage *)cutImageWithID:(NSString *)ID{
    
    CGRect rect = CGRectMake(0.f, 0.f, self.image.size.width, self.image.size.height / 2.f);
    if ([ID isEqualToString:@"bottom"]){
        rect.origin.y = self.image.size.height / 2.f;
    }
    
    CGImageRef imgRef = CGImageCreateWithImageInRect(self.image.CGImage, rect);
    UIImage *cuttedImage = [UIImage imageWithCGImage:imgRef];
    CGImageRelease(imgRef);
    
    return cuttedImage;
}


-(BOOL)isLocation:(CGPoint)location InView:(UIView *)view{
    if ((location.x > 0 && location.x < view.bounds.size.width) &&
        (location.y > 0 && location.y < view.bounds.size.height)) {
        return YES;
    }else{
        return NO;
    }
}


@end



