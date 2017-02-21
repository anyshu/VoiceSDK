/*
 * dycrash_catch.h
 *
 *  Created on: 2016��10��21��
 *      Author: duoyi01
 */

#ifndef UTILS_DYCRASH_CATCH_H_
#define UTILS_DYCRASH_CATCH_H_

#include <signal.h>
#include "dyutils.h"

typedef void (*signal_handler)(int);

sigaction* m_newSigaction;
sigaction* m_oldSigaction;

void initCrashCatch();

#endif /* UTILS_DYCRASH_CATCH_H_ */
