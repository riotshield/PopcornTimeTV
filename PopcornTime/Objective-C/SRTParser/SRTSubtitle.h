//
//  SDSubtitle.h
//  PopcornTime
//
//  Created by Yogi Bear on 5/13/16.
//  Copyright © 2016 PopcornTime. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRTSubtitle : NSObject

@property (nonatomic, assign, readonly) NSUInteger index;
@property (nonatomic, assign, readonly) NSTimeInterval startTime;
@property (nonatomic, assign, readonly) NSTimeInterval endTime;
@property (nonatomic, copy, readonly) NSString *content;

- (id)initWithIndex:(NSUInteger)index startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime content:(NSString *)content;

@end
