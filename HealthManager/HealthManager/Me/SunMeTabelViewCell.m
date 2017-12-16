//
//  SunMeTabelViewCell.m
//  HealthManager
//
//  Created by 李金星 on 2017/1/13.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import "SunMeTabelViewCell.h"
#import "SunBasicModel.h"
#import "SunArrowItemModel.h"
#import "SunLableItemModel.h"
#import "SunViewItemModel.h"

@interface SunMeTabelViewCell()
@property(nonatomic,strong)UIImageView *arrowView;
@property(nonatomic,strong)UILabel *lable;
@property(nonatomic,strong)UILabel *labBageValue;
@property(nonatomic,strong)UIView *bagView;
@end
@implementation SunMeTabelViewCell

+(instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID=@"setting";
    SunMeTabelViewCell *cell=[tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell==nil) {
        cell=[[SunMeTabelViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    return cell;
}

-(UIImageView *)arrowView
{
    if (_arrowView==nil) {
        _arrowView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"nav-right"]];
    }
    return _arrowView;
}
-(UILabel *)lable
{
    if (_lable==nil) {
        _lable=[[UILabel alloc]init];
    }
    return _lable;
}

-(UIView *)bagView
{
    if (_bagView==nil) {
        _bagView=[[UIView alloc]init];
    }
    return _bagView;
}

-(UILabel *)labBageValue
{
    if (_labBageValue==nil) {
        _labBageValue=[[UILabel alloc]init];
    }
    return _labBageValue;
}

-(void)setBasicModel:(SunBasicModel *)basicModel
{
    _basicModel=basicModel;
    //设置数据
    [self setUpData];
    //设置右边的控件
    [self setUpRightView];
}

/**
 *  设置数据
 */
-(void)setUpData
{
    self.textLabel.text=self.basicModel.title;
    self.textLabel.font=kFont(15);
    self.detailTextLabel.text=self.basicModel.subTitle;
    self.labBageValue.text=self.basicModel.badgeValue;
    if(self.basicModel.icon){
        
        UIImage *icon = [UIImage imageNamed:self.basicModel.icon];
        CGSize imageSize = CGSizeMake(25, 25);
        UIGraphicsBeginImageContextWithOptions(imageSize, NO,0.0); //获得用来处理图片的图形上下文。利用该上下文，你就可以在其上进行绘图，并生成图片 ,三个参数含义是设置大小、透明度 （NO为不透明）、缩放（0代表不缩放）
        CGRect imageRect = CGRectMake(0.0, 0.0, imageSize.width, imageSize.height);
        [icon drawInRect:imageRect];
        self.imageView.image=UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        //设置文字位置
        [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.imageView);
            make.left.equalTo(self.imageView.mas_right).offset(8);
        }];
    }
    
    
    CGFloat x=self.textLabel.frame.origin.x;
    
    //设置分割线
    [self setSeparatorInset:UIEdgeInsetsMake(0, x, 0, 0)];
}

/**
 *  设置右边的控件
 */
-(void)setUpRightView
{
    //移除关注数字
    
    [self.bagView removeFromSuperview];
    
    if(self.basicModel.badgeValue!=nil){
        if (![self.basicModel.badgeValue isEqualToString:@"0"]) {
            //标志数字
            self.bagView=[[UIView alloc]init];
            self.bagView.backgroundColor=[UIColor redColor];
            self.bagView.layer.cornerRadius=10;
            self.bagView.layer.masksToBounds=YES;
            [self.bagView addSubview:self.labBageValue];
            self.labBageValue.textColor=[UIColor whiteColor];
            self.labBageValue.textAlignment=NSTextAlignmentCenter;
            self.labBageValue.font=kFont(12);
            self.labBageValue.frame=CGRectMake(0, 0, 20, 20);
            [self.contentView addSubview:self.bagView];
            
            [self.bagView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.contentView);
                make.height.mas_equalTo(20);
                make.width.mas_equalTo(20);
                make.right.equalTo(self.contentView).offset(-20);
            }];
        }
       
    }else if ([self.basicModel isKindOfClass:[SunArrowItemModel class]]) {
        //箭头
        self.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        
    }else if ([self.basicModel isKindOfClass:[SunLableItemModel class]]) {
        //文字
        SunLableItemModel *lableModel= (SunLableItemModel *)self.basicModel;
        self.lable.text=lableModel.rightTitle;
        self.lable.textColor=[UIColor lightGrayColor];
        [self.contentView addSubview:self.lable ];
        [self.lable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.right.equalTo(self.contentView).offset(-15);
        }];
        
    }else if ([self.basicModel isKindOfClass:[SunViewItemModel class]]) {
        //视图
        SunViewItemModel *viewModel= (SunViewItemModel *)self.basicModel;
        if([viewModel.myView isKindOfClass:[UITextField class]])
        {
            UITextField *textFild=(UITextField *)viewModel.myView;
            textFild.font=self.textLabel.font;
            textFild.textAlignment=NSTextAlignmentRight;
        }
        [self addSubview:viewModel.myView];
        [viewModel.myView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-8);
            make.top.equalTo(self).offset(2);
            make.bottom.equalTo(self).offset(-2);
            make.left.equalTo(self.textLabel.mas_right).offset(10);
        }];
    }else {
        
    }

}





@end
