// Define a simple lock structure

typedef struct lock_t{
    uint locked; // Flag
}lock_t;

// Function declaration to create a new thread
int thread_create(void *(*sr)(void*), void *arg);

// Function declaration to initialize a lock
void lock_init(struct lock_t *lock);

// Function declaration to acquire the lock using a spinlock mechanism
void lock_acquire(struct lock_t *lock);

// Function declaration to acquire the lock using a spinlock mechanism
void lock_release(struct lock_t *lock);