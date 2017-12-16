//
//  UITableView+EmptyData.h
//  HealthManager
//
//  Created by 李金星 on 2017/1/9.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (EmptyData)
- (void)tableViewDisplayWitMsg:(NSString *) message ifNecessaryForRowCount:(NSUInteger) rowCount;
@end
