//
//  UDLog.h
//
//  Created by Rolandas Razma on 7/13/12.
//
//  Copyright (c) 2012 Rolandas Razma <rolandas@razma.lt>
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#ifndef __OPTIMIZE__
#import <mach/mach.h>
#import <mach/mach_time.h>

uint64_t gbLastCall;
inline static double UDTimeSinceLasstCall(){
	if( !gbLastCall ){
		gbLastCall = mach_absolute_time();
		return 0;
	}else{
		uint64_t duration = mach_absolute_time() -gbLastCall;
		gbLastCall = mach_absolute_time();
		
		mach_timebase_info_data_t info;
		mach_timebase_info(&info);
		
		return duration * ((double)info.numer / ((double)info.denom *1000000.0));
	}
}

#define UDLog(format, ...) CFShow( [NSString stringWithFormat:@"^%7.1f | %@", UDTimeSinceLasstCall(), [NSString stringWithFormat:format, ##__VA_ARGS__], __PRETTY_FUNCTION__, __LINE__]);

#else
#define UDLog(format, ...)
#endif
