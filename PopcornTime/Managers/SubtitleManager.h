//
//  SubtitleManager.h
//  PopcornTime
//
//  Created by Anthony Castelli on 5/13/16.
//  Copyright © 2016 PopcornTime. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SubtitleManager : NSObject

+ (instancetype)sharedManager;

- (void)fetchSubtitlesForIMDB:(NSString *)imdbID completion:(void (^)(NSArray *subtitles))completionHandler;

@end
