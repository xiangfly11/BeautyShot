//
//  BSMaterialProtocol.h
//  Blast
//
//  Created by leon on 02/02/2018.
//  Copyright © 2018 codoon. All rights reserved.
//


@protocol BSMaterialProtocol <NSObject>
@required
- (int64_t)identifier;
- (BOOL)deleteable;
- (BOOL)isValid;

@end
