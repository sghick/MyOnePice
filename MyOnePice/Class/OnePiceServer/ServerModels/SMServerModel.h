//
//  SMServerModel.h
//  MyOnePice
//
//  Created by 丁治文 on 16/6/8.
//  Copyright © 2016年 sumrise.com. All rights reserved.
//

#import "SMModel.h"

@interface SMServerModel : SMModel
@end

@interface SMServerAccount : SMModel

@property (nonatomic, strong) NSString *account_id;
@property (nonatomic, strong) NSString *user_name;
@property (nonatomic, strong) NSString *real_name;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *player1_id;
@property (nonatomic, strong) NSString *player1_name;

@end

@interface SMServerPlayer : SMModel

@property (nonatomic, strong) NSString *ply_id;
@property (nonatomic, strong) NSString *ply_name;

@end

@interface SMServerPlayerRole : SMModel

@property (nonatomic, strong) NSString *ply_role_id;
@property (nonatomic, strong) NSString *ply_id;
@property (nonatomic, assign) int32_t  role_rank;
@property (nonatomic, strong) NSString *role_hat;
@property (nonatomic, strong) NSString *role_clothes;
@property (nonatomic, strong) NSString *role_pants;
@property (nonatomic, strong) NSString *role_shoes;
@property (nonatomic, strong) NSString *role_weapon;

@end

@interface SMServerPlayerSkill : SMModel

@property (nonatomic, strong) NSString *ply_skill_id;
@property (nonatomic, strong) NSString *ply_id;
@property (nonatomic, strong) NSString *skill_id;

@end

@interface SMServerSkill : SMModel

@property (nonatomic, strong) NSString *skill_id;
@property (nonatomic, strong) NSString *skill_name;
@property (nonatomic, strong) NSString *skill_belongs_role;
@property (nonatomic, assign) int32_t  skill_type;
@property (nonatomic, strong) NSString *skill_special_role;
@property (nonatomic, assign) int32_t  skill_ad_attack;
@property (nonatomic, assign) int32_t  skill_ap_attack;
@property (nonatomic, assign) int32_t  skill_ad_rection;
@property (nonatomic, assign) int32_t  skill_ad_rection_per;
@property (nonatomic, assign) int32_t  skill_ap_rection;
@property (nonatomic, assign) int32_t  skill_ap_rection_per;

@end

@interface SMServerRole : SMModel

@property (nonatomic, strong) NSString *role_id;
@property (nonatomic, strong) NSString *role_name;
@property (nonatomic, assign) int32_t  role_hp;
@property (nonatomic, assign) int32_t  role_mp;
@property (nonatomic, assign) int32_t  role_ad_atk;
@property (nonatomic, assign) int32_t  role_ap_atk;
@property (nonatomic, assign) int32_t  role_ad_def;
@property (nonatomic, assign) int32_t  role_ap_def;
@property (nonatomic, assign) int32_t  role_dodge;
@property (nonatomic, assign) int32_t  role_dodge_hit;

@end