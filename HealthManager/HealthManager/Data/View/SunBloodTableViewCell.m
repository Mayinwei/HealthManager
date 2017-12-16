//
//  SunBloodTableViewCell.m
//  HealthManager
//
//  Created by Mr_yinwei on 17/1/3.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import "SunBloodTableViewCell.h"
#import "SunDataBloodView.h"
#import "SunBloodDetailModel.h"


@interface SunBloodTableViewCell()
@end
@implementation SunBloodTableViewCell


+(instancetype)cellWithTableView:(UITableView *)tableview
{
    static NSString *ID=@"blood";
    SunBloodTableViewCell *cell=[tableview dequeueReusableCellWithIdentifier:ID];
    if (cell==nil) {
        cell=[[SunBloodTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    return cell;
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        SunDataBloodView *blood=[[SunDataBloodView alloc]init];
        self.blood=blood;
        [self addSubview:blood];
    }
    return self;
}
//重写Set方法
-(void)setBloodDetail:(SunBloodDetailModel *)bloodDetail
{
    _bloodDetail=bloodDetail;
    //设置数据
    self.blood.higLab.text=bloodDetail.SYSTOLIC;
    self.blood.lowLab.text=bloodDetail.DIASTOLIC;
    self.blood.rateLab.text=bloodDetail.HEARTRATE;
    self.blood.timeLab.text=bloodDetail.STARTTIME;
    NSString *imgName=[NSString stringWithFormat:@"blood_pressure_%@",bloodDetail.RESULT];
    self.blood.imgView.image=[UIImage imageNamed:imgName];
    //计算尺寸
    [self.blood mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.equalTo(self);
        make.size.equalTo(self);
    }];
}

@end
