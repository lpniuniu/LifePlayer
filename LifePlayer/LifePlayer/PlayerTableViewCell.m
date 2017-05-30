//
//  PlayerTableViewCell.m
//  LifePlayer
//
//  Created by FanFamily on 2017/5/30.
//  Copyright © 2017年 niuniu. All rights reserved.
//

#import "PlayerTableViewCell.h"
#import <Masonry.h>

@implementation PlayerTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backImageView = [[UIImageView alloc] init];
        [self addSubview:self.backImageView];
        [self.backImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        self.titleLabel = [[UILabel alloc] init];
        [self.titleLabel setTextColor:[UIColor whiteColor]];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(10);
            make.top.right.bottom.equalTo(self);
        }];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (selected) {
        [self.titleLabel setTextColor:[UIColor orangeColor]];
    } else {
        [self.titleLabel setTextColor:[UIColor whiteColor]];
    }
    
}

@end
