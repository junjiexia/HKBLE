//
//  UserRecordItem.h
//  blackcard
//
//  Created by milton on 2016/12/17.
//  Copyright © 2016年 milton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserRecordItem : NSObject

/**
 打卡时间
 */
@property(nonatomic,assign)NSTimeInterval check_in;//打卡时间

/**
 标签id
 */
@property(nonatomic,strong)NSString *tab_id;

/**
 上传状态 1：成功   0：失败
 */
@property(nonatomic,assign)NSInteger status;

/**
 卡片mac地址
 */
@property(nonatomic,copy)NSString *mac;

@end
