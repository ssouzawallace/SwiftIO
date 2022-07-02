/*
 * @Copyright (c) 2020, MADMACHINE LIMITED
 * @Author: Andy Liu,Frank Li
 * @SPDX-License-Identifier: MIT
 */


#ifndef _SWIFT_THREAD_H_
#define _SWIFT_THREAD_H_

typedef void (*swifthal_task)(void *p1, void *p2, void *p3);

void *swifthal_os_task_create(swifthal_task fn, void *p1, void *p2, void *p3, int prio);
void swifthal_os_task_yield(void);

void *swifthal_os_mq_create(int mq_size, int mq_num);
int swifthal_os_mq_destory(void *mp);
int swifthal_os_mq_send(void *mp, void *data, int timeout);
int swifthal_os_mq_recv(void *mp, void *data, int timeout);
int swifthal_os_mq_peek(void *mp, void *data);
int swifthal_os_mq_purge(void *mp);

void *swifthal_os_mutex_create(void);
int swifthal_os_mutex_destroy(void *mutex);
int swifthal_os_mutex_lock(void *mutex, int timeout);
int swifthal_os_mutex_unlock(void *mutex);

#endif /*_SWIFT_THREAD_H_*/
