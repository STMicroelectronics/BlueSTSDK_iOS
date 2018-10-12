/*******************************************************************************
 * COPYRIGHT(c) 2015 STMicroelectronics
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *   1. Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 *   2. Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 *   3. Neither the name of STMicroelectronics nor the names of its contributors
 *      may be used to endorse or promote products derived from this software
 *      without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 ******************************************************************************/

#import "UnwrapTimeStamp.h"

#define NEAR_TO_END_TH ((1<<16)-100)


@implementation UnwrapTimeStamp{
    
    /** number of time that the ts has reset, the timestamp is reseted when we receive a ts with
     * a  value > 65435 and than a package with a smaller value */
    uint32_t mNReset;
    
    /** last raw ts received from the board, it is a number between 0 and 2^16-1 */
    uint32_t mLastTs;
}

-(instancetype)init{
    mNReset=0;
    mLastTs=0;
    return self;
}

-(uint64_t) unwrap:(uint16_t)ts{
    @synchronized(self){
        if(mLastTs>(NEAR_TO_END_TH) && mLastTs > ts)
            mNReset++;
        mLastTs=ts;
        return (uint64_t)mNReset * (1<<16) + (uint64_t)ts;
    }//syncronized
}

-(uint64_t) getNext{
    return [self unwrap:(mLastTs+1)];
}


@end
