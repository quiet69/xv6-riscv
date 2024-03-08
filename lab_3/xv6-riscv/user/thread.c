#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/spinlock.h"
#include "user/user.h"
#include "user/thread.h"

int
thread_create(void *(start_routine)(void*), void *arg)
{
    int pg_size = 4096*sizeof(void);
    void* stack = (void*)malloc(pg_size);
    int t_id = clone(stack);
    if(t_id==0) {
        (*start_routine)(arg);
        exit(0);
    }
    return 0;
}

void
lock_init(struct lock_t *lock)
{
    lock->locked = 0;
}

void
lock_acquire(struct lock_t *lock)
{
    while(__sync_lock_test_and_set(&lock->locked, 1)!= 0);
    __sync_synchronize();
}

void
lock_release(struct lock_t *lock)
{
    __sync_synchronize();
    __sync_lock_release(&lock->locked, 0);
}

