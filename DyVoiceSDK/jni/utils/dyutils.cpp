/*
 * dyutils.cpp
 *
 *  Created on: 2016��8��10��
 *      Author: duoyi01
 */
#include "dyutils.h"
#include <sys/time.h>

unsigned long getTimestamp() {
	struct timeval tv;
	gettimeofday(&tv, 0);
	return ((tv.tv_sec * 1000000) + (tv.tv_usec));
}
