//
//  EUExControl.m
//  AppCan
//
//  Created by AppCan on 11-11-23.
//  Copyright 2011 AppCan. All rights reserved.
//

#import "EUExControl.h"
#import "EUtility.h"
#import "EUExBaseDefine.h"
#import "JSON.h"
@implementation EUExControl
@synthesize dateObj;
@synthesize monthObj;
@synthesize inputObj;

//-(id)initWithBrwView:(EBrowserView *) eInBrwView {
//	if (self = [super initWithBrwView:eInBrwView]) {
//        _isDataPickerDidOpen = NO;
//	}
//	return self;
//}
-(id)initWithWebViewEngine:(id<AppCanWebViewEngineObject>)engine{
    if (self = [super initWithWebViewEngine:engine]) {
        _isDataPickerDidOpen = NO;
    }
    return self;
}
- (UIColor *)stringToColor:(NSString *)aString{
    if ([aString isKindOfClass:[NSString class]] && aString.length > 0) {
        UIColor *color = [EUtility ColorFromString:aString];
        return color;
    }else{
        return nil;
    }
}

-(void)setDatePickerConfirmBtnColor:(NSMutableArray *)inArguments{
    
    if ([inArguments count] <= 0) {
        
        return;
    }

    NSString * jsonStr = [inArguments objectAtIndex:0];
    NSMutableDictionary * jsDic = [jsonStr JSONValue];
    
    NSString * titleColor = [jsDic objectForKey:@"leftBtnTitleColor"];
    if ([titleColor isKindOfClass:[NSString class]] && [titleColor length]>0) {
        self.dateObj.toolView.canLabel.textColor = [self stringToColor:titleColor];
    }
    
    titleColor = [jsDic objectForKey:@"rightBtnTitleColor"];
    if ([titleColor isKindOfClass:[NSString class]] && [titleColor length]>0) {
        self.dateObj.toolView.conLabel.textColor = [self stringToColor:titleColor];
    }
}

-(void)setDatePickerWithoutDayConfirmBtnColor:(NSMutableArray *)inArguments{
    
    if ([inArguments count] <= 0) {
        
        return;
    }
    
    NSString * jsonStr = [inArguments objectAtIndex:0];
    NSMutableDictionary * jsDic = [jsonStr JSONValue];
    
    
    NSString * titleColor = [jsDic objectForKey:@"leftBtnTitleColor"];
    if ([titleColor isKindOfClass:[NSString class]] && [titleColor length]>0) {
        self.monthObj.toolView.canLabel.textColor = [self stringToColor:titleColor];
    }
    
    titleColor = [jsDic objectForKey:@"rightBtnTitleColor"];
    if ([titleColor isKindOfClass:[NSString class]] && [titleColor length]>0) {
        self.monthObj.toolView.conLabel.textColor = [self stringToColor:titleColor];
    }
}


-(void)clean{
	if (dateObj) {
        [[NSNotificationCenter defaultCenter] removeObserver:dateObj];
        [dateObj release];
        dateObj = nil;
	}
    if(monthObj){
        [[NSNotificationCenter defaultCenter] removeObserver:monthObj];
        [monthObj release];
        monthObj = nil;
    }
    if (inputObj) {
        [[NSNotificationCenter defaultCenter] removeObserver:inputObj];
        [inputObj release];
        inputObj = nil;
	}
}

-(void)dealloc{
    [self clean];
	[super dealloc];
}

-(void)openInputDialog:(NSMutableArray *)inArguments{
    if (inputHasDisplay) {
        return;
    }
    int inType = [[inArguments objectAtIndex:0] intValue];
    NSString * inHint = [inArguments objectAtIndex:1];
    
    NSString * btnTitle = [inArguments objectAtIndex:2];
    ACJSFunctionRef *func = JSFunctionArg(inArguments.lastObject);
    self.func = func;
	[inputObj release];
	inputObj = nil;
    
    CGRect frameOfInputObj = CGRectZero;
    float heightOfInputObj = 40;
    UIInterfaceOrientation cOrientation = [UIApplication sharedApplication].statusBarOrientation;
	if ((cOrientation == UIInterfaceOrientationLandscapeLeft) || (cOrientation == UIInterfaceOrientationLandscapeRight)) {
        frameOfInputObj = CGRectMake(0, [EUtility screenWidth] - heightOfInputObj, [EUtility screenHeight], heightOfInputObj);
    } else {
        frameOfInputObj = CGRectMake(0, [EUtility screenHeight] - heightOfInputObj, [EUtility screenWidth], heightOfInputObj);
    }
    inputObj = [[InputDialog alloc] initWithFrame:frameOfInputObj];
    [inputObj openInputWithText:inHint btnText:btnTitle KeyBoardType:inType];
    [inputObj setDelegate:self];
    //[EUtility brwView:meBrwView addSubview:inputObj];
    [[self.webViewEngine webView] addSubview:inputObj];
    //[EUtility brwView:meBrwView forbidRotate:YES];
    inputHasDisplay = YES;
}

-(void)inputFinish:(NSString *)inputResult{
     //[EUtility brwView:meBrwView forbidRotate:NO];
    inputHasDisplay = NO;
   // [self jsSuccessWithName:@"uexControl.cbInputCompleted" opId:0 dataType:UEX_CALLBACK_DATATYPE_TEXT strData:inputResult];
    //[self jsSuccessWithName:@"uexControl.cbOpenInputDialog" opId:0 dataType:UEX_CALLBACK_DATATYPE_TEXT strData:inputResult];
    [self.webViewEngine callbackWithFunctionKeyPath:@"uexControl.cbOpenInputDialog" arguments:ACArgsPack(@0,@0,inputResult)];
    [self.func executeWithArguments:ACArgsPack(inputResult)];
    self.func = nil;
}

-(void)inputDialogClose{
    inputHasDisplay = NO;
}

-(void)openDatePicker:(NSMutableArray *)inArguments{
    
    if (_isDataPickerDidOpen) {
        return;
    }
    
    DatePicker *tempObj = [[DatePicker alloc] initWithEuex:self];
    self.dateObj = tempObj;
    [tempObj release];
    inputHasDisplay = NO;
    _isDataPickerDidOpen = YES;
    if (![inArguments isKindOfClass:[NSMutableArray class]] || [inArguments count] < 3) {
        return;
    }
   
    NSInteger inYear = [[inArguments objectAtIndex:0] integerValue];
    NSInteger inMonth = [[inArguments objectAtIndex:1] integerValue];
    NSInteger inDay = [[inArguments objectAtIndex:2] integerValue];
    ACJSFunctionRef *func = JSFunctionArg(inArguments.lastObject);
    self.func = func;
    NSDate *inDate;
	if (inYear == 0 ||inMonth == 0 ||inDay == 0) {
		inDate = [NSDate date];
	}else {
		NSString *dateStr = [NSString stringWithFormat:@"%@-%@-%@",@(inYear),@(inMonth),@(inDay)];
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		[df setDateFormat:@"yyyy-MM-dd"];
		inDate = [df dateFromString:dateStr];
		[df release];
	}
    if (inDate == nil) {
		inDate = [NSDate date];
	}
	[dateObj showDatePickerWithType:0 date:inDate];
}
//---------------------------------------------------------
-(void)openDatePickerWithConfig:(NSMutableArray *)inArguments{
    if (_isDataPickerDidOpen) {
        return;
    }
    NSString *jsonStr = nil;
    NSMutableDictionary *jsonDict = [NSMutableDictionary dictionary];
    if (inArguments.count > 0) {
        jsonStr = [inArguments objectAtIndex:0];
        jsonDict = [jsonStr JSONValue];//将JSON类型的字符串转化为可变字典
        
    }else{
        return;
    }
    if (!self.dateObj) {
        DatePicker *tempObj = [[DatePicker alloc] initWithEuex:self];
        self.dateObj = tempObj;
        [tempObj release];
    }
    
    ACJSFunctionRef *func = JSFunctionArg(inArguments.lastObject);
    self.func = func;


//    if (![inArguments isKindOfClass:[NSMutableArray class]] || [inArguments count] < 3) {
//        return;
//    }

    
    NSString *(^getString)(id) = ^NSString * (id obj){
        if ([obj isKindOfClass:[NSString class]]) {
            return obj;
        }
        if ([obj isKindOfClass:[NSNumber class]]) {
            return [obj stringValue];
        }
        return @"";
    };
    float datePickerId = [[jsonDict objectForKey:@"datePickerId"] floatValue];
    NSDictionary *initDateDic = [jsonDict objectForKey:@"initDate"];
    NSDictionary *maxDateDic = [jsonDict objectForKey:@"maxDate"];
    NSDictionary *minDateDic = [jsonDict objectForKey:@"minDate"];
    
   	NSString *inYear = getString([initDateDic objectForKey:@"year"]);
    NSString *inMonth = getString([initDateDic objectForKey:@"month"]);
    NSString *inDay = getString([initDateDic objectForKey:@"day"]);
    //NSDictionary *dateData = [NSDictionary dictionary];
    NSDate *minDate = nil;
    if (minDateDic != nil) {
        float minLimitType = [[minDateDic objectForKey:@"limitType"] floatValue];
        NSString *minYear = getString([minDateDic objectForKey:@"data"][@"year"]);
        NSString *minMonth = getString([minDateDic objectForKey:@"data"][@"month"]);
        NSString *minDay = getString([minDateDic objectForKey:@"data"][@"day"]);
        if (minLimitType == 0) {
            if (minYear == nil||minMonth == nil||minDay == nil) {
                
                return;
            }else {
                NSString *dateStr = [NSString stringWithFormat:@"%@-%@-%@",minYear,minMonth,minDay];
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                [df setDateFormat:@"yyyy-MM-dd"];
                minDate = [df dateFromString:dateStr];
                [df release];
            }
            
        }else {
            if (minYear == nil && minMonth == nil && minDay == nil) {
                
                return;
            }else {
                NSString *dateStr = nil;
                if (minDay != nil) {
                    NSString *day1= [NSString stringWithFormat:@"%d",minDay.intValue + inDay.intValue] ;
                    dateStr = [NSString stringWithFormat:@"%@-%@-%@",inYear,inMonth, day1];
                }else if(minMonth != nil){
                    NSString *month1= [NSString stringWithFormat:@"%d",minMonth.intValue + inMonth.intValue] ;
                    dateStr = [NSString stringWithFormat:@"%@-%@-%@",inYear,month1,inDay];
                }else if (minYear != nil){
                    NSString *year1= [NSString stringWithFormat:@"%d",minYear.intValue + inYear.intValue] ;
                    dateStr = [NSString stringWithFormat:@"%@-%@-%@",year1,inMonth,inDay];
                }
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                [df setDateFormat:@"yyyy-MM-dd"];
                
                minDate = [df dateFromString:dateStr];
                
                [df release];
                
            }
        }

    }
    
    
         NSDate *inDate;
        if ([inYear isEqualToString:@""]||[inMonth isEqualToString:@""]||[inDay isEqualToString:@""]) {
            inDate = [NSDate date];
        }else {
            NSString *dateStr = [NSString stringWithFormat:@"%@-%@-%@",inYear,inMonth,inDay];
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy-MM-dd"];
            inDate = [df dateFromString:dateStr];
            [df release];
        }
        if (inDate == nil) {
            inDate = [NSDate date];
        }
      NSDate *maxDate = nil;
    if (maxDateDic != nil) {
        float maxLimitType = [[maxDateDic objectForKey:@"limitType"] floatValue];
        NSString *maxYear = getString([maxDateDic objectForKey:@"data"][@"year"]);
        NSString *maxMonth = getString([maxDateDic objectForKey:@"data"][@"month"]);
        NSString *maxDay = getString([maxDateDic objectForKey:@"data"][@"day"]);
        if (maxLimitType == 0) {
            if (maxYear == nil||maxMonth == nil||maxDay == nil) {
                
                return;
            }else {
                NSString *dateStr = [NSString stringWithFormat:@"%@-%@-%@",maxYear,maxMonth,maxDay];
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                [df setDateFormat:@"yyyy-MM-dd"];
                maxDate = [df dateFromString:dateStr];
                [df release];
            }
            
        }else {
            if (maxYear == nil && maxMonth == nil && maxDay == nil) {
                
                return;
            }else {
                NSString *dateStr = nil;
                if (maxDay != nil) {
                    NSString *day1= [NSString stringWithFormat:@"%d",maxDay.intValue + inDay.intValue] ;
                    dateStr = [NSString stringWithFormat:@"%@-%@-%@",inYear,inMonth, day1];
                }else if(maxMonth != nil){
                    NSString *month1= [NSString stringWithFormat:@"%d",maxMonth.intValue + inMonth.intValue] ;
                    dateStr = [NSString stringWithFormat:@"%@-%@-%@",inYear,month1,inDay];
                }else if (maxYear != nil){
                    NSString *year1= [NSString stringWithFormat:@"%d",maxYear.intValue + inYear.intValue] ;
                    dateStr = [NSString stringWithFormat:@"%@-%@-%@",year1,inMonth,inDay];
                }
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                [df setDateFormat:@"yyyy-MM-dd"];
                
                maxDate = [df dateFromString:dateStr];
                
                [df release];
                
            }
        }

    }
    [dateObj showDatePickerWithType:2 date:inDate minDate:minDate maxDate:maxDate tag:datePickerId];
    inputHasDisplay = NO;
    _isDataPickerDidOpen = YES;
  
}
//----------------------------------------------------------
-(void)openDatePickerWithoutDay:(NSMutableArray *)inArguments{
    
    
    if(self.monthObj != nil && self.monthObj.mainView != nil) { //已经打开
        
        return;
    }
    
    MonthPicker *tempObj = [[MonthPicker alloc] initWithEuex:self];
    self.monthObj = tempObj;
    [tempObj release];
    
    inputHasDisplay = NO;
    NSInteger inYear = [[inArguments objectAtIndex:0] integerValue];
    NSInteger inMonth = [[inArguments objectAtIndex:1] integerValue];
     ACJSFunctionRef *func = JSFunctionArg(inArguments.lastObject);
    self.func = func;
    if (inYear > 9999||inMonth > 12) {
        [self jsFailedWithOpId:0 errorCode:1050101 errorDes:UEX_ERROR_DESCRIBE_ARGS];
        return;
    }
    NSDate *inDate;
    if (inYear == 0||inMonth == 0) {
        inDate = [NSDate date];
    }else {
        NSString *dateStr = [NSString stringWithFormat:@"%@-%@",@(inYear),@(inMonth)];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM"];
        inDate = [df dateFromString:dateStr];
        [df release];
    }
    if (inDate == nil) {
        inDate = [NSDate date];
    }
    [monthObj showMonthPickerWithType:0 date:inDate];
    
}


-(void)openTimePicker:(NSMutableArray *)inArguments{
    
    if (_isDataPickerDidOpen){
        return;
    }
    if ([inArguments count]<2){
        return;
    }
    ACJSFunctionRef *func = JSFunctionArg(inArguments.lastObject);
    self.func = func;
    DatePicker * tempObj = [[DatePicker alloc] initWithEuex:self];
    self.dateObj = tempObj;
    [tempObj release];
    inputHasDisplay = NO;
    _isDataPickerDidOpen = YES;
    
    NSNumber * (^getNumber)(id) = ^NSNumber *(id obj){
        if ([obj isKindOfClass:[NSNumber class]]) {
            return obj;
        }
        if ([obj isKindOfClass:[NSString class]] && [obj length] > 0) {
            return [NSDecimalNumber decimalNumberWithString:obj];
        }
        return nil;
    };
    
    NSNumber *inHours = getNumber(inArguments[0]);
    NSNumber *inMin = getNumber(inArguments[1]);
    
    int h = [inHours intValue];
    int m = [inMin intValue];
    if (!inHours || !inMin || (h > 24)||(h < 0)||(m > 60)||(m < 0)) {
        NSDate *today = [NSDate date];
        [dateObj showDatePickerWithType:1 date:today];
    }
    else{
        NSString *dateStr = [NSString stringWithFormat:@"%@:%@",@(h),@(m)];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"HH:mm"];
        NSDate *inDate = [df dateFromString:dateStr];
        [df release];
        [dateObj showDatePickerWithType:1 date:inDate];
    }
    
    
}

-(void)uexOpenDatePickerWithOpId:(int)inOpId dataType:(int)inDataType data:(NSString*)inData{
	inData =[inData stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	//[self jsSuccessWithName:@"uexControl.cbOpenDatePicker" opId:inOpId dataType:inDataType strData:inData];
    [self.webViewEngine callbackWithFunctionKeyPath:@"uexControl.cbOpenDatePicker" arguments:ACArgsPack(@(inOpId),@(inDataType),inData)];
    [self.func executeWithArguments:ACArgsPack([inData JSONValue])];
    self.func = nil;
}
-(void)uexOpenMonthPickerWithOpId:(int)inOpId dataType:(int)inDataType data:(NSString*)inData{
    inData =[inData stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //[self jsSuccessWithName:@"uexControl.cbOpenDatePickerWithoutDay" opId:inOpId dataType:inDataType strData:inData];
    [self.webViewEngine callbackWithFunctionKeyPath:@"uexControl.cbOpenDatePickerWithoutDay" arguments:ACArgsPack(@(inOpId),@(inDataType),inData)];
    [self.func executeWithArguments:ACArgsPack([inData JSONValue])];
    self.func = nil;
}
-(void)uexOpenTimerPickerWithOpId:(int)inOpId dataType:(int)inDataType data:(NSString*)inData{
	inData =[inData stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	//[self jsSuccessWithName:@"uexControl.cbOpenTimePicker" opId:inOpId dataType:inDataType strData:inData];
    [self.webViewEngine callbackWithFunctionKeyPath:@"uexControl.cbOpenTimePicker" arguments:ACArgsPack(@(inOpId),@(inDataType),inData)];
    [self.func executeWithArguments:ACArgsPack([inData JSONValue])];
    self.func = nil;
}
-(void)uexOpenDatePickerWithConfigAndOpId:(int)inOpId tagID:(float)tag dataType:(int)inDataType data:(NSString*)inData{
    inData =[inData stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic = [inData JSONValue];
    [dic removeObjectForKey:@"minute"];
    [dic removeObjectForKey:@"hour"];
    [dic removeObjectForKey:@"second"];
    dic[@"datePickerId"]= [NSString stringWithFormat:@"%f",tag];
    NSString *dateStr = [dic JSONFragment];
   // NSString *jsString = [NSString stringWithFormat:@"uexControl.cbOpenDatePickerWithConfig('%@');",dateStr];
    //[EUtility brwView:meBrwView evaluateScript:jsString];
    //[self jsSuccessWithName:@"uexControl.cbOpenDatePickerWithConfig"  tagID:tag dataType:inDataType strData:inData];
    [self.webViewEngine callbackWithFunctionKeyPath:@"uexControl.cbOpenDatePickerWithConfig" arguments:ACArgsPack(dateStr)];
    [self.func executeWithArguments:ACArgsPack([dateStr JSONValue])];
    self.func = nil;
}
-(void)containViewTap:(UITapGestureRecognizer *)gest{
    if (tv) {
        [tv resignFirstResponder];
        [tv removeFromSuperview];
        if (tv.text) {
           // [self jsSuccessWithName:@"uexControl.cbEditCompleted" opId:0 dataType:UEX_CALLBACK_DATATYPE_TEXT strData:tv.text];
            [self.webViewEngine callbackWithFunctionKeyPath:@"uexControl.cbEditCompleted" arguments:ACArgsPack(@0,@0,tv.text)];
            
        }
    }
    [containView removeFromSuperview];
}

-(void)openEditDialog:(NSMutableArray *)inArguments{
    float ex = [[inArguments objectAtIndex:0] floatValue];
    float ey = [[inArguments objectAtIndex:1] floatValue];
    float ew = [[inArguments objectAtIndex:2] floatValue];
    float eh = [[inArguments objectAtIndex:3] floatValue];
    int eType = [[inArguments objectAtIndex:4] intValue];
    NSString *eHintString = [inArguments objectAtIndex:5];
    NSString *eDefString = [inArguments objectAtIndex:6];
     tv = [[UITextView alloc] initWithFrame:CGRectMake(ex, ey, ew, eh)];
    tv.font =[UIFont systemFontOfSize:16.0f];
    [tv setDelegate:self];
    [tv.layer setCornerRadius:5.0];
    [tv.layer setBorderWidth:1.0];
    [tv.layer setBorderColor:[[UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1.0] CGColor]];
    if (eType == 0) {
        [tv setKeyboardType:UIKeyboardTypeDefault];
    }else {
        [tv setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
    }
    if(eDefString&&eDefString.length>0){
        [tv setText:eDefString];
    }else {
        if(eHintString&&eHintString.length>0)
        {
            UILabel *hintLab = [[UILabel alloc] initWithFrame:CGRectMake(3, 2, ew-6, 20)];
            hintLab.text = eHintString;
            hintLab.font =[UIFont systemFontOfSize:16.0f];
            hintLab.textAlignment = UITextAlignmentLeft;
            hintLab.textColor = [UIColor grayColor];
            [tv addSubview:hintLab];
            [hintLab release];
        }
    }
 
    //[EUtility brwView:meBrwView addSubview:tv];
    [[self.webViewEngine webView] addSubview:tv];
//    [EUtility brwView:meBrwView forbidRotate:YES];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    return  YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    containView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EUtility screenWidth], [EUtility screenHeight]-216)];
    [containView setBackgroundColor:[UIColor whiteColor]];
    [containView setAlpha:0.1];
    UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(containViewTap:)];
    [containView addGestureRecognizer:tapG];
   // [EUtility brwView:meBrwView addSubview:containView];
    [[self.webViewEngine webView] addSubview:containView];

    [tapG release];
}

- (void)textViewDidEndEditing:(UITextView *)textView{

}

- (void)textViewDidChange:(UITextView *)textView{
    
}

- (void)textViewDidChangeSelection:(UITextView *)textView{

}
@end
