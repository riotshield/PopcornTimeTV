//
//  UIImageView+Network.h
//  PopcornTime
//
//  Created by Yogi Bear on 5/31/16.
//  Copyright © 2016 PopcornTime. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Network)

@property (nonatomic, copy) NSURL *imageURL;

- (void)loadImageFromURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;

@end
