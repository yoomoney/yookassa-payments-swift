#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YMACClientAuthorization : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithClientId:(NSString *)clientId NS_DESIGNATED_INITIALIZER;

- (NSString *)generateToken;

@end

NS_ASSUME_NONNULL_END
