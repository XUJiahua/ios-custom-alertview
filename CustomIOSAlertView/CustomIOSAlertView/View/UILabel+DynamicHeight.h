//
//  UILabel+DynamicHeight.h
//  CustomIOSAlertView
//
//  Created by XuJiahua on 15/12/11.
//  Copyright © 2015年 Wimagguc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (DynamicHeight)
#pragma mark - Calculate the size the Multi line Label
/*====================================================================*/

/* Calculate the size of the Multi line Label */

/*====================================================================*/
/**
 *  Returns the size of the Label
 *
 *  @param aLabel To be used to calculte the height
 *
 *  @return size of the Label
 */
-(CGSize)sizeOfMultiLineLabel;
@end
