//
//  SunSugarTableViewCell.m
//  HealthManager
//
//  Created by Mr_yinwei on 17/1/4.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import "SunSugarTableViewCell.h"
#import "SunDataSugarView.h"
#import "SunSugarDetailModel.h"
@implementation SunSugarTableViewCell

+(instancetype)cellWithTableView:(UITableView *)tableview
{
    static NSString *ID=@"sugar";
    SunSugarTableViewCell *cell=[tableview dequeueReusableCellWithIdentifier:ID];
    if (cell==nil) {
        cell=[[SunSugarTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    return cell;
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        SunDataSugarView *sugar=[[SunDataSugarView alloc]init];
        self.sugar=sugar;
        [self addSubview:sugar];
    }
    return self;
}

//重写方法
-(void)setSugarDetail:(SunSugarDetailModel *)sugarDetail
{
    _sugarDetail=sugarDetail;
    //设置数据
    self.sugar.higLab.text=sugarDetail.XTZ;
    self.sugar.timeLab.text=sugarDetail.CLSJ;
    self.sugar.sTimeLab.text=sugarDetail.XTLX;
    NSString *imgName=[NSString stringWithFormat:@"xuetang_%@",sugarDetail.RESULT];
    self.sugar.imgView.image=[UIImage imageNamed:imgName];
    //计算尺寸
    [self.sugar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.equalTo(self);
        make.size.equalTo(self);
    }];
}

@end
