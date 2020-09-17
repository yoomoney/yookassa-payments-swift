#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YMACClientAuthorization : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithClientId:(NSString *)clientId isDevHost:(BOOL)isDevHost NS_DESIGNATED_INITIALIZER;

- (NSString *)generateToken;

@end

NS_ASSUME_NONNULL_END
