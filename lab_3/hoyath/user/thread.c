#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "user/thread.h"
#include "kernel/spinlock.h"


// Function to create a new thread
int thread_create(void *(*start_routine)(void*), void *arg){
    void* stack = (void*)malloc(4096 * sizeof(void));

// // Create a new thread using the clone system call
    if(clone(stack) ==0){
        (*start_routine) (arg);
        // Exit the thread upon completion of the start routine
        exit(0);
    }
    return 0;
}

// Function to initialize a lock
void lock_init(struct lock_t *lock){
    lock->locked = 0;
 }

 // Function to acquire the lock using a spinlock mechanism
 // Spin until the lock is successfully acquired
void lock_acquire(struct lock_t *lock){
    while(__sync_lock_test_and_set(&lock->locked, 1)!=0);
    __sync_synchronize();
}


// Function to release the lock
void lock_release(struct lock_t *lock){
    __sync_synchronize();
    __sync_lock_release(&lock->locked,0);
}