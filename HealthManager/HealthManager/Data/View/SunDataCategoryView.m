//
//  SunDataCategoryVIew.m
//  HealthManager
//
//  Created by Mr_yinwei on 16/12/20.
//  Copyright © 2016年 马银伟. All rights reserved.
//

#import "SunDataCategoryVIew.h"

@implementation SunDataCategoryView

- (IBAction)joinClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(sunDataCategory:)]) {
        [self.delegate sunDataCategory:self];
    }
}

+(instancetype)viewFromNib
{
    NSArray *array=[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil];
    return array[0];
}

@end
