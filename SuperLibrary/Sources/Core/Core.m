//
//  Core.m
//  
//
//  Created by Станислав Старжевский on 24.01.2022.
//

#import <Foundation/Foundation.h>

#import "Core.h"

@implementation Worker
- (void)test {
    Worker *w = [[Worker alloc] init];
    [w test];
    NSLog(@"Worker");
}
@end
