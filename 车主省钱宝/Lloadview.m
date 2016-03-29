//
//  Lloadview.m
//  loavi
//
//  Created by chenghao on 15/4/29.
//  Copyright (c) 2015年 chenghao. All rights reserved.
//

#import "Lloadview.h"
#import "Utils.h"
#import <ImageIO/ImageIO.h>
@implementation Lloadview

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)awakeFromNib{
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    // 读取gif图片数据
    NSData *gif = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"car" ofType:@"gif"]];
    UIImageView *gifImageView = [[UIImageView alloc] initWithFrame:CGRectMake(Screen.bounds.size.width/2-43, Screen.bounds.size.height/2-72, 86, 144)];
    gifImageView.animationImages = [self praseGIFDataToImageArray:gif]; //动画图片数组
    gifImageView.animationDuration = 1; //执行一次完整动画所需的时长
    gifImageView.animationRepeatCount = 0.2;  //动画重复次数
    [gifImageView startAnimating];
    [self addSubview:gifImageView];
    UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, Screen.bounds.size.width*0.8, 20)];
    label.text = @"请稍等....";
    label.center = CGPointMake(gifImageView.center.x, gifImageView.center.y+10);
    label.textAlignment = NSTextAlignmentCenter;
    [label setTextColor:[UIColor whiteColor]];
    label.font = [UIFont systemFontOfSize:15];
    [self addSubview:label];
    
}

-(NSMutableArray *)praseGIFDataToImageArray:(NSData *)data;
{
    NSMutableArray *frames = [[NSMutableArray alloc] init];
    CGImageSourceRef src = CGImageSourceCreateWithData((CFDataRef)data, NULL);
    CGFloat animationTime = 0.f;
    if (src) {
        size_t l = CGImageSourceGetCount(src);
        frames = [NSMutableArray arrayWithCapacity:l];
        for (size_t i = 0; i < l; i++) {
            CGImageRef img = CGImageSourceCreateImageAtIndex(src, i, NULL);
            NSDictionary *properties = (NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(src, i, NULL));
            NSDictionary *frameProperties = [properties objectForKey:(NSString *)kCGImagePropertyGIFDictionary];
            NSNumber *delayTime = [frameProperties objectForKey:(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
            animationTime += [delayTime floatValue];
            if (img) {
                [frames addObject:[UIImage imageWithCGImage:img]];
                CGImageRelease(img);
            }
        }
        CFRelease(src);
    }
    return frames;
}
@end
