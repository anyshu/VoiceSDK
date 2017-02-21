/*
 * dycrash_catch.cpp
 *
 *  Created on: 2016Äê10ÔÂ21ÈÕ
 *      Author: duoyi01
 */
#include "dycrash_catch.h"

void initCrashCatch()
{
	int i = 0;
	signal(SIGALRM, signal_handler);

	for(int i = 0; i < 10; i++) {
		alarm(1);
	}

}

void signal_handler(int dumpno)
{
	LOGD("dumpno is %d", dumpno);
}
