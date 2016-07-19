//
//  SRTParser.h
//  PopcornTime
//
//  Created by Yogi Bear on 5/13/16.
//  Copyright © 2016 PopcornTime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRTSubtitle.h"

typedef NS_ENUM(NSInteger, SRTParserError) {
    SDSRTMissingIndexError,
    SDSRTCarriageReturnIndexError,
    SDSRTInvalidTimeError,
    SDSRTMissingTimeError,
    SDSRTMissingTimeBoundariesError
};

@interface SRTParser: NSObject

@property (nonatomic, copy) NSArray *subtitles;

- (NSArray *)parseString:(NSString *)string error:(NSError **)error;

@end
