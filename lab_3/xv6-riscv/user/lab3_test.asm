
user/_lab3_test:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <thread_fn>:
#include "user/thread.h"

struct lock_t lock;
int n_threads, n_passes, cur_turn, cur_pass;
void *thread_fn(void *arg)
{
   0:	715d                	addi	sp,sp,-80
   2:	e486                	sd	ra,72(sp)
   4:	e0a2                	sd	s0,64(sp)
   6:	fc26                	sd	s1,56(sp)
   8:	f84a                	sd	s2,48(sp)
   a:	f44e                	sd	s3,40(sp)
   c:	f052                	sd	s4,32(sp)
   e:	ec56                	sd	s5,24(sp)
  10:	e85a                	sd	s6,16(sp)
  12:	e45e                	sd	s7,8(sp)
  14:	e062                	sd	s8,0(sp)
  16:	0880                	addi	s0,sp,80
    int thread_id = (uint64)arg;
  18:	00050a9b          	sext.w	s5,a0
    int done = 0;
    while (!done)
    {
        lock_acquire(&lock);
  1c:	00001497          	auipc	s1,0x1
  20:	ff448493          	addi	s1,s1,-12 # 1010 <lock>
        if (cur_pass >= n_passes)
  24:	00001917          	auipc	s2,0x1
  28:	fdc90913          	addi	s2,s2,-36 # 1000 <cur_pass>
  2c:	00001997          	auipc	s3,0x1
  30:	fdc98993          	addi	s3,s3,-36 # 1008 <n_passes>
            done = 1;
        else if (cur_turn == thread_id)
  34:	00001a17          	auipc	s4,0x1
  38:	fd0a0a13          	addi	s4,s4,-48 # 1004 <cur_turn>
        {
            cur_turn = (cur_turn + 1) % n_threads;
  3c:	00150b1b          	addiw	s6,a0,1
  40:	00001c17          	auipc	s8,0x1
  44:	fccc0c13          	addi	s8,s8,-52 # 100c <n_threads>
            printf("Round %d: thread %d is passing the token to thread %d\n",
  48:	00001b97          	auipc	s7,0x1
  4c:	9d8b8b93          	addi	s7,s7,-1576 # a20 <lock_release+0x1c>
  50:	a819                	j	66 <thread_fn+0x66>
                   ++cur_pass, thread_id, cur_turn);
        }
        lock_release(&lock);
  52:	8526                	mv	a0,s1
  54:	00001097          	auipc	ra,0x1
  58:	9b0080e7          	jalr	-1616(ra) # a04 <lock_release>
        sleep(0);
  5c:	4501                	li	a0,0
  5e:	00000097          	auipc	ra,0x0
  62:	482080e7          	jalr	1154(ra) # 4e0 <sleep>
        lock_acquire(&lock);
  66:	8526                	mv	a0,s1
  68:	00001097          	auipc	ra,0x1
  6c:	980080e7          	jalr	-1664(ra) # 9e8 <lock_acquire>
        if (cur_pass >= n_passes)
  70:	00092583          	lw	a1,0(s2)
  74:	0009a783          	lw	a5,0(s3)
  78:	02f5d863          	bge	a1,a5,a8 <thread_fn+0xa8>
        else if (cur_turn == thread_id)
  7c:	000a2783          	lw	a5,0(s4)
  80:	fd5799e3          	bne	a5,s5,52 <thread_fn+0x52>
            cur_turn = (cur_turn + 1) % n_threads;
  84:	000c2683          	lw	a3,0(s8)
  88:	02db66bb          	remw	a3,s6,a3
  8c:	00da2023          	sw	a3,0(s4)
            printf("Round %d: thread %d is passing the token to thread %d\n",
  90:	2585                	addiw	a1,a1,1
  92:	00b92023          	sw	a1,0(s2)
  96:	2681                	sext.w	a3,a3
  98:	8656                	mv	a2,s5
  9a:	2581                	sext.w	a1,a1
  9c:	855e                	mv	a0,s7
  9e:	00000097          	auipc	ra,0x0
  a2:	75c080e7          	jalr	1884(ra) # 7fa <printf>
  a6:	b775                	j	52 <thread_fn+0x52>
        lock_release(&lock);
  a8:	00001517          	auipc	a0,0x1
  ac:	f6850513          	addi	a0,a0,-152 # 1010 <lock>
  b0:	00001097          	auipc	ra,0x1
  b4:	954080e7          	jalr	-1708(ra) # a04 <lock_release>
        sleep(0);
  b8:	4501                	li	a0,0
  ba:	00000097          	auipc	ra,0x0
  be:	426080e7          	jalr	1062(ra) # 4e0 <sleep>
    }
    return 0;
}
  c2:	4501                	li	a0,0
  c4:	60a6                	ld	ra,72(sp)
  c6:	6406                	ld	s0,64(sp)
  c8:	74e2                	ld	s1,56(sp)
  ca:	7942                	ld	s2,48(sp)
  cc:	79a2                	ld	s3,40(sp)
  ce:	7a02                	ld	s4,32(sp)
  d0:	6ae2                	ld	s5,24(sp)
  d2:	6b42                	ld	s6,16(sp)
  d4:	6ba2                	ld	s7,8(sp)
  d6:	6c02                	ld	s8,0(sp)
  d8:	6161                	addi	sp,sp,80
  da:	8082                	ret

00000000000000dc <main>:
int main(int argc, char *argv[])
{
  dc:	7179                	addi	sp,sp,-48
  de:	f406                	sd	ra,40(sp)
  e0:	f022                	sd	s0,32(sp)
  e2:	ec26                	sd	s1,24(sp)
  e4:	e84a                	sd	s2,16(sp)
  e6:	e44e                	sd	s3,8(sp)
  e8:	1800                	addi	s0,sp,48
  ea:	84ae                	mv	s1,a1
    if (argc < 3)
  ec:	4789                	li	a5,2
  ee:	02a7c063          	blt	a5,a0,10e <main+0x32>
    {
        printf("Usage: %s [N_PASSES] [N_THREADS]\n", argv[0]);
  f2:	618c                	ld	a1,0(a1)
  f4:	00001517          	auipc	a0,0x1
  f8:	96450513          	addi	a0,a0,-1692 # a58 <lock_release+0x54>
  fc:	00000097          	auipc	ra,0x0
 100:	6fe080e7          	jalr	1790(ra) # 7fa <printf>
        exit(-1);
 104:	557d                	li	a0,-1
 106:	00000097          	auipc	ra,0x0
 10a:	34a080e7          	jalr	842(ra) # 450 <exit>
    }
    n_passes = atoi(argv[1]);
 10e:	6588                	ld	a0,8(a1)
 110:	00000097          	auipc	ra,0x0
 114:	246080e7          	jalr	582(ra) # 356 <atoi>
 118:	00001797          	auipc	a5,0x1
 11c:	eea7a823          	sw	a0,-272(a5) # 1008 <n_passes>
    n_threads = atoi(argv[2]);
 120:	6888                	ld	a0,16(s1)
 122:	00000097          	auipc	ra,0x0
 126:	234080e7          	jalr	564(ra) # 356 <atoi>
 12a:	00001497          	auipc	s1,0x1
 12e:	ee248493          	addi	s1,s1,-286 # 100c <n_threads>
 132:	c088                	sw	a0,0(s1)
    cur_turn = 0;
 134:	00001797          	auipc	a5,0x1
 138:	ec07a823          	sw	zero,-304(a5) # 1004 <cur_turn>
    cur_pass = 0;
 13c:	00001797          	auipc	a5,0x1
 140:	ec07a223          	sw	zero,-316(a5) # 1000 <cur_pass>
    lock_init(&lock);
 144:	00001517          	auipc	a0,0x1
 148:	ecc50513          	addi	a0,a0,-308 # 1010 <lock>
 14c:	00001097          	auipc	ra,0x1
 150:	88c080e7          	jalr	-1908(ra) # 9d8 <lock_init>
    for (int i = 0; i < n_threads; i++)
 154:	409c                	lw	a5,0(s1)
 156:	04f05963          	blez	a5,1a8 <main+0xcc>
 15a:	4481                	li	s1,0
    {
        thread_create(thread_fn, (void *)(uint64)i);
 15c:	00000997          	auipc	s3,0x0
 160:	ea498993          	addi	s3,s3,-348 # 0 <thread_fn>
    for (int i = 0; i < n_threads; i++)
 164:	00001917          	auipc	s2,0x1
 168:	ea890913          	addi	s2,s2,-344 # 100c <n_threads>
        thread_create(thread_fn, (void *)(uint64)i);
 16c:	85a6                	mv	a1,s1
 16e:	854e                	mv	a0,s3
 170:	00001097          	auipc	ra,0x1
 174:	828080e7          	jalr	-2008(ra) # 998 <thread_create>
    for (int i = 0; i < n_threads; i++)
 178:	00092783          	lw	a5,0(s2)
 17c:	0485                	addi	s1,s1,1
 17e:	0004871b          	sext.w	a4,s1
 182:	fef745e3          	blt	a4,a5,16c <main+0x90>
    }
    for (int i = 0; i < n_threads; i++)
 186:	02f05163          	blez	a5,1a8 <main+0xcc>
 18a:	4481                	li	s1,0
 18c:	00001917          	auipc	s2,0x1
 190:	e8090913          	addi	s2,s2,-384 # 100c <n_threads>
    {
        wait(0);
 194:	4501                	li	a0,0
 196:	00000097          	auipc	ra,0x0
 19a:	2c2080e7          	jalr	706(ra) # 458 <wait>
    for (int i = 0; i < n_threads; i++)
 19e:	2485                	addiw	s1,s1,1
 1a0:	00092783          	lw	a5,0(s2)
 1a4:	fef4c8e3          	blt	s1,a5,194 <main+0xb8>
    }
    printf("Frisbee simulation has finished, %d rounds played in total\n", n_passes);
 1a8:	00001597          	auipc	a1,0x1
 1ac:	e605a583          	lw	a1,-416(a1) # 1008 <n_passes>
 1b0:	00001517          	auipc	a0,0x1
 1b4:	8d050513          	addi	a0,a0,-1840 # a80 <lock_release+0x7c>
 1b8:	00000097          	auipc	ra,0x0
 1bc:	642080e7          	jalr	1602(ra) # 7fa <printf>
    exit(0);
 1c0:	4501                	li	a0,0
 1c2:	00000097          	auipc	ra,0x0
 1c6:	28e080e7          	jalr	654(ra) # 450 <exit>

00000000000001ca <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 1ca:	1141                	addi	sp,sp,-16
 1cc:	e406                	sd	ra,8(sp)
 1ce:	e022                	sd	s0,0(sp)
 1d0:	0800                	addi	s0,sp,16
  extern int main();
  main();
 1d2:	00000097          	auipc	ra,0x0
 1d6:	f0a080e7          	jalr	-246(ra) # dc <main>
  exit(0);
 1da:	4501                	li	a0,0
 1dc:	00000097          	auipc	ra,0x0
 1e0:	274080e7          	jalr	628(ra) # 450 <exit>

00000000000001e4 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1e4:	1141                	addi	sp,sp,-16
 1e6:	e422                	sd	s0,8(sp)
 1e8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1ea:	87aa                	mv	a5,a0
 1ec:	0585                	addi	a1,a1,1
 1ee:	0785                	addi	a5,a5,1
 1f0:	fff5c703          	lbu	a4,-1(a1)
 1f4:	fee78fa3          	sb	a4,-1(a5)
 1f8:	fb75                	bnez	a4,1ec <strcpy+0x8>
    ;
  return os;
}
 1fa:	6422                	ld	s0,8(sp)
 1fc:	0141                	addi	sp,sp,16
 1fe:	8082                	ret

0000000000000200 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 200:	1141                	addi	sp,sp,-16
 202:	e422                	sd	s0,8(sp)
 204:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 206:	00054783          	lbu	a5,0(a0)
 20a:	cb91                	beqz	a5,21e <strcmp+0x1e>
 20c:	0005c703          	lbu	a4,0(a1)
 210:	00f71763          	bne	a4,a5,21e <strcmp+0x1e>
    p++, q++;
 214:	0505                	addi	a0,a0,1
 216:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 218:	00054783          	lbu	a5,0(a0)
 21c:	fbe5                	bnez	a5,20c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 21e:	0005c503          	lbu	a0,0(a1)
}
 222:	40a7853b          	subw	a0,a5,a0
 226:	6422                	ld	s0,8(sp)
 228:	0141                	addi	sp,sp,16
 22a:	8082                	ret

000000000000022c <strlen>:

uint
strlen(const char *s)
{
 22c:	1141                	addi	sp,sp,-16
 22e:	e422                	sd	s0,8(sp)
 230:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 232:	00054783          	lbu	a5,0(a0)
 236:	cf91                	beqz	a5,252 <strlen+0x26>
 238:	0505                	addi	a0,a0,1
 23a:	87aa                	mv	a5,a0
 23c:	4685                	li	a3,1
 23e:	9e89                	subw	a3,a3,a0
 240:	00f6853b          	addw	a0,a3,a5
 244:	0785                	addi	a5,a5,1
 246:	fff7c703          	lbu	a4,-1(a5)
 24a:	fb7d                	bnez	a4,240 <strlen+0x14>
    ;
  return n;
}
 24c:	6422                	ld	s0,8(sp)
 24e:	0141                	addi	sp,sp,16
 250:	8082                	ret
  for(n = 0; s[n]; n++)
 252:	4501                	li	a0,0
 254:	bfe5                	j	24c <strlen+0x20>

0000000000000256 <memset>:

void*
memset(void *dst, int c, uint n)
{
 256:	1141                	addi	sp,sp,-16
 258:	e422                	sd	s0,8(sp)
 25a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 25c:	ca19                	beqz	a2,272 <memset+0x1c>
 25e:	87aa                	mv	a5,a0
 260:	1602                	slli	a2,a2,0x20
 262:	9201                	srli	a2,a2,0x20
 264:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 268:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 26c:	0785                	addi	a5,a5,1
 26e:	fee79de3          	bne	a5,a4,268 <memset+0x12>
  }
  return dst;
}
 272:	6422                	ld	s0,8(sp)
 274:	0141                	addi	sp,sp,16
 276:	8082                	ret

0000000000000278 <strchr>:

char*
strchr(const char *s, char c)
{
 278:	1141                	addi	sp,sp,-16
 27a:	e422                	sd	s0,8(sp)
 27c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 27e:	00054783          	lbu	a5,0(a0)
 282:	cb99                	beqz	a5,298 <strchr+0x20>
    if(*s == c)
 284:	00f58763          	beq	a1,a5,292 <strchr+0x1a>
  for(; *s; s++)
 288:	0505                	addi	a0,a0,1
 28a:	00054783          	lbu	a5,0(a0)
 28e:	fbfd                	bnez	a5,284 <strchr+0xc>
      return (char*)s;
  return 0;
 290:	4501                	li	a0,0
}
 292:	6422                	ld	s0,8(sp)
 294:	0141                	addi	sp,sp,16
 296:	8082                	ret
  return 0;
 298:	4501                	li	a0,0
 29a:	bfe5                	j	292 <strchr+0x1a>

000000000000029c <gets>:

char*
gets(char *buf, int max)
{
 29c:	711d                	addi	sp,sp,-96
 29e:	ec86                	sd	ra,88(sp)
 2a0:	e8a2                	sd	s0,80(sp)
 2a2:	e4a6                	sd	s1,72(sp)
 2a4:	e0ca                	sd	s2,64(sp)
 2a6:	fc4e                	sd	s3,56(sp)
 2a8:	f852                	sd	s4,48(sp)
 2aa:	f456                	sd	s5,40(sp)
 2ac:	f05a                	sd	s6,32(sp)
 2ae:	ec5e                	sd	s7,24(sp)
 2b0:	1080                	addi	s0,sp,96
 2b2:	8baa                	mv	s7,a0
 2b4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2b6:	892a                	mv	s2,a0
 2b8:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2ba:	4aa9                	li	s5,10
 2bc:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2be:	89a6                	mv	s3,s1
 2c0:	2485                	addiw	s1,s1,1
 2c2:	0344d863          	bge	s1,s4,2f2 <gets+0x56>
    cc = read(0, &c, 1);
 2c6:	4605                	li	a2,1
 2c8:	faf40593          	addi	a1,s0,-81
 2cc:	4501                	li	a0,0
 2ce:	00000097          	auipc	ra,0x0
 2d2:	19a080e7          	jalr	410(ra) # 468 <read>
    if(cc < 1)
 2d6:	00a05e63          	blez	a0,2f2 <gets+0x56>
    buf[i++] = c;
 2da:	faf44783          	lbu	a5,-81(s0)
 2de:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2e2:	01578763          	beq	a5,s5,2f0 <gets+0x54>
 2e6:	0905                	addi	s2,s2,1
 2e8:	fd679be3          	bne	a5,s6,2be <gets+0x22>
  for(i=0; i+1 < max; ){
 2ec:	89a6                	mv	s3,s1
 2ee:	a011                	j	2f2 <gets+0x56>
 2f0:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2f2:	99de                	add	s3,s3,s7
 2f4:	00098023          	sb	zero,0(s3)
  return buf;
}
 2f8:	855e                	mv	a0,s7
 2fa:	60e6                	ld	ra,88(sp)
 2fc:	6446                	ld	s0,80(sp)
 2fe:	64a6                	ld	s1,72(sp)
 300:	6906                	ld	s2,64(sp)
 302:	79e2                	ld	s3,56(sp)
 304:	7a42                	ld	s4,48(sp)
 306:	7aa2                	ld	s5,40(sp)
 308:	7b02                	ld	s6,32(sp)
 30a:	6be2                	ld	s7,24(sp)
 30c:	6125                	addi	sp,sp,96
 30e:	8082                	ret

0000000000000310 <stat>:

int
stat(const char *n, struct stat *st)
{
 310:	1101                	addi	sp,sp,-32
 312:	ec06                	sd	ra,24(sp)
 314:	e822                	sd	s0,16(sp)
 316:	e426                	sd	s1,8(sp)
 318:	e04a                	sd	s2,0(sp)
 31a:	1000                	addi	s0,sp,32
 31c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 31e:	4581                	li	a1,0
 320:	00000097          	auipc	ra,0x0
 324:	170080e7          	jalr	368(ra) # 490 <open>
  if(fd < 0)
 328:	02054563          	bltz	a0,352 <stat+0x42>
 32c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 32e:	85ca                	mv	a1,s2
 330:	00000097          	auipc	ra,0x0
 334:	178080e7          	jalr	376(ra) # 4a8 <fstat>
 338:	892a                	mv	s2,a0
  close(fd);
 33a:	8526                	mv	a0,s1
 33c:	00000097          	auipc	ra,0x0
 340:	13c080e7          	jalr	316(ra) # 478 <close>
  return r;
}
 344:	854a                	mv	a0,s2
 346:	60e2                	ld	ra,24(sp)
 348:	6442                	ld	s0,16(sp)
 34a:	64a2                	ld	s1,8(sp)
 34c:	6902                	ld	s2,0(sp)
 34e:	6105                	addi	sp,sp,32
 350:	8082                	ret
    return -1;
 352:	597d                	li	s2,-1
 354:	bfc5                	j	344 <stat+0x34>

0000000000000356 <atoi>:

int
atoi(const char *s)
{
 356:	1141                	addi	sp,sp,-16
 358:	e422                	sd	s0,8(sp)
 35a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 35c:	00054683          	lbu	a3,0(a0)
 360:	fd06879b          	addiw	a5,a3,-48
 364:	0ff7f793          	zext.b	a5,a5
 368:	4625                	li	a2,9
 36a:	02f66863          	bltu	a2,a5,39a <atoi+0x44>
 36e:	872a                	mv	a4,a0
  n = 0;
 370:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 372:	0705                	addi	a4,a4,1
 374:	0025179b          	slliw	a5,a0,0x2
 378:	9fa9                	addw	a5,a5,a0
 37a:	0017979b          	slliw	a5,a5,0x1
 37e:	9fb5                	addw	a5,a5,a3
 380:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 384:	00074683          	lbu	a3,0(a4)
 388:	fd06879b          	addiw	a5,a3,-48
 38c:	0ff7f793          	zext.b	a5,a5
 390:	fef671e3          	bgeu	a2,a5,372 <atoi+0x1c>
  return n;
}
 394:	6422                	ld	s0,8(sp)
 396:	0141                	addi	sp,sp,16
 398:	8082                	ret
  n = 0;
 39a:	4501                	li	a0,0
 39c:	bfe5                	j	394 <atoi+0x3e>

000000000000039e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 39e:	1141                	addi	sp,sp,-16
 3a0:	e422                	sd	s0,8(sp)
 3a2:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3a4:	02b57463          	bgeu	a0,a1,3cc <memmove+0x2e>
    while(n-- > 0)
 3a8:	00c05f63          	blez	a2,3c6 <memmove+0x28>
 3ac:	1602                	slli	a2,a2,0x20
 3ae:	9201                	srli	a2,a2,0x20
 3b0:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3b4:	872a                	mv	a4,a0
      *dst++ = *src++;
 3b6:	0585                	addi	a1,a1,1
 3b8:	0705                	addi	a4,a4,1
 3ba:	fff5c683          	lbu	a3,-1(a1)
 3be:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3c2:	fee79ae3          	bne	a5,a4,3b6 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3c6:	6422                	ld	s0,8(sp)
 3c8:	0141                	addi	sp,sp,16
 3ca:	8082                	ret
    dst += n;
 3cc:	00c50733          	add	a4,a0,a2
    src += n;
 3d0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3d2:	fec05ae3          	blez	a2,3c6 <memmove+0x28>
 3d6:	fff6079b          	addiw	a5,a2,-1
 3da:	1782                	slli	a5,a5,0x20
 3dc:	9381                	srli	a5,a5,0x20
 3de:	fff7c793          	not	a5,a5
 3e2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3e4:	15fd                	addi	a1,a1,-1
 3e6:	177d                	addi	a4,a4,-1
 3e8:	0005c683          	lbu	a3,0(a1)
 3ec:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3f0:	fee79ae3          	bne	a5,a4,3e4 <memmove+0x46>
 3f4:	bfc9                	j	3c6 <memmove+0x28>

00000000000003f6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3f6:	1141                	addi	sp,sp,-16
 3f8:	e422                	sd	s0,8(sp)
 3fa:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3fc:	ca05                	beqz	a2,42c <memcmp+0x36>
 3fe:	fff6069b          	addiw	a3,a2,-1
 402:	1682                	slli	a3,a3,0x20
 404:	9281                	srli	a3,a3,0x20
 406:	0685                	addi	a3,a3,1
 408:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 40a:	00054783          	lbu	a5,0(a0)
 40e:	0005c703          	lbu	a4,0(a1)
 412:	00e79863          	bne	a5,a4,422 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 416:	0505                	addi	a0,a0,1
    p2++;
 418:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 41a:	fed518e3          	bne	a0,a3,40a <memcmp+0x14>
  }
  return 0;
 41e:	4501                	li	a0,0
 420:	a019                	j	426 <memcmp+0x30>
      return *p1 - *p2;
 422:	40e7853b          	subw	a0,a5,a4
}
 426:	6422                	ld	s0,8(sp)
 428:	0141                	addi	sp,sp,16
 42a:	8082                	ret
  return 0;
 42c:	4501                	li	a0,0
 42e:	bfe5                	j	426 <memcmp+0x30>

0000000000000430 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 430:	1141                	addi	sp,sp,-16
 432:	e406                	sd	ra,8(sp)
 434:	e022                	sd	s0,0(sp)
 436:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 438:	00000097          	auipc	ra,0x0
 43c:	f66080e7          	jalr	-154(ra) # 39e <memmove>
}
 440:	60a2                	ld	ra,8(sp)
 442:	6402                	ld	s0,0(sp)
 444:	0141                	addi	sp,sp,16
 446:	8082                	ret

0000000000000448 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 448:	4885                	li	a7,1
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <exit>:
.global exit
exit:
 li a7, SYS_exit
 450:	4889                	li	a7,2
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <wait>:
.global wait
wait:
 li a7, SYS_wait
 458:	488d                	li	a7,3
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 460:	4891                	li	a7,4
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <read>:
.global read
read:
 li a7, SYS_read
 468:	4895                	li	a7,5
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <write>:
.global write
write:
 li a7, SYS_write
 470:	48c1                	li	a7,16
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <close>:
.global close
close:
 li a7, SYS_close
 478:	48d5                	li	a7,21
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <kill>:
.global kill
kill:
 li a7, SYS_kill
 480:	4899                	li	a7,6
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <exec>:
.global exec
exec:
 li a7, SYS_exec
 488:	489d                	li	a7,7
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <open>:
.global open
open:
 li a7, SYS_open
 490:	48bd                	li	a7,15
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 498:	48c5                	li	a7,17
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4a0:	48c9                	li	a7,18
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4a8:	48a1                	li	a7,8
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <link>:
.global link
link:
 li a7, SYS_link
 4b0:	48cd                	li	a7,19
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4b8:	48d1                	li	a7,20
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4c0:	48a5                	li	a7,9
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4c8:	48a9                	li	a7,10
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4d0:	48ad                	li	a7,11
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4d8:	48b1                	li	a7,12
 ecall
 4da:	00000073          	ecall
 ret
 4de:	8082                	ret

00000000000004e0 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4e0:	48b5                	li	a7,13
 ecall
 4e2:	00000073          	ecall
 ret
 4e6:	8082                	ret

00000000000004e8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4e8:	48b9                	li	a7,14
 ecall
 4ea:	00000073          	ecall
 ret
 4ee:	8082                	ret

00000000000004f0 <hello>:
.global hello
hello:
 li a7, SYS_hello
 4f0:	48d9                	li	a7,22
 ecall
 4f2:	00000073          	ecall
 ret
 4f6:	8082                	ret

00000000000004f8 <sysinfo>:
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo
 4f8:	48dd                	li	a7,23
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <procinfo>:
.global procinfo
procinfo:
 li a7, SYS_procinfo
 500:	48e1                	li	a7,24
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <sched_tickets>:
.global sched_tickets
sched_tickets:
 li a7, SYS_sched_tickets
 508:	48e9                	li	a7,26
 ecall
 50a:	00000073          	ecall
 ret
 50e:	8082                	ret

0000000000000510 <sched_statistics>:
.global sched_statistics
sched_statistics:
 li a7, SYS_sched_statistics
 510:	48e5                	li	a7,25
 ecall
 512:	00000073          	ecall
 ret
 516:	8082                	ret

0000000000000518 <clone>:
.global clone
clone:
 li a7, SYS_clone
 518:	48ed                	li	a7,27
 ecall
 51a:	00000073          	ecall
 ret
 51e:	8082                	ret

0000000000000520 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 520:	1101                	addi	sp,sp,-32
 522:	ec06                	sd	ra,24(sp)
 524:	e822                	sd	s0,16(sp)
 526:	1000                	addi	s0,sp,32
 528:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 52c:	4605                	li	a2,1
 52e:	fef40593          	addi	a1,s0,-17
 532:	00000097          	auipc	ra,0x0
 536:	f3e080e7          	jalr	-194(ra) # 470 <write>
}
 53a:	60e2                	ld	ra,24(sp)
 53c:	6442                	ld	s0,16(sp)
 53e:	6105                	addi	sp,sp,32
 540:	8082                	ret

0000000000000542 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 542:	7139                	addi	sp,sp,-64
 544:	fc06                	sd	ra,56(sp)
 546:	f822                	sd	s0,48(sp)
 548:	f426                	sd	s1,40(sp)
 54a:	f04a                	sd	s2,32(sp)
 54c:	ec4e                	sd	s3,24(sp)
 54e:	0080                	addi	s0,sp,64
 550:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 552:	c299                	beqz	a3,558 <printint+0x16>
 554:	0805c963          	bltz	a1,5e6 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 558:	2581                	sext.w	a1,a1
  neg = 0;
 55a:	4881                	li	a7,0
 55c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 560:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 562:	2601                	sext.w	a2,a2
 564:	00000517          	auipc	a0,0x0
 568:	5bc50513          	addi	a0,a0,1468 # b20 <digits>
 56c:	883a                	mv	a6,a4
 56e:	2705                	addiw	a4,a4,1
 570:	02c5f7bb          	remuw	a5,a1,a2
 574:	1782                	slli	a5,a5,0x20
 576:	9381                	srli	a5,a5,0x20
 578:	97aa                	add	a5,a5,a0
 57a:	0007c783          	lbu	a5,0(a5)
 57e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 582:	0005879b          	sext.w	a5,a1
 586:	02c5d5bb          	divuw	a1,a1,a2
 58a:	0685                	addi	a3,a3,1
 58c:	fec7f0e3          	bgeu	a5,a2,56c <printint+0x2a>
  if(neg)
 590:	00088c63          	beqz	a7,5a8 <printint+0x66>
    buf[i++] = '-';
 594:	fd070793          	addi	a5,a4,-48
 598:	00878733          	add	a4,a5,s0
 59c:	02d00793          	li	a5,45
 5a0:	fef70823          	sb	a5,-16(a4)
 5a4:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5a8:	02e05863          	blez	a4,5d8 <printint+0x96>
 5ac:	fc040793          	addi	a5,s0,-64
 5b0:	00e78933          	add	s2,a5,a4
 5b4:	fff78993          	addi	s3,a5,-1
 5b8:	99ba                	add	s3,s3,a4
 5ba:	377d                	addiw	a4,a4,-1
 5bc:	1702                	slli	a4,a4,0x20
 5be:	9301                	srli	a4,a4,0x20
 5c0:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5c4:	fff94583          	lbu	a1,-1(s2)
 5c8:	8526                	mv	a0,s1
 5ca:	00000097          	auipc	ra,0x0
 5ce:	f56080e7          	jalr	-170(ra) # 520 <putc>
  while(--i >= 0)
 5d2:	197d                	addi	s2,s2,-1
 5d4:	ff3918e3          	bne	s2,s3,5c4 <printint+0x82>
}
 5d8:	70e2                	ld	ra,56(sp)
 5da:	7442                	ld	s0,48(sp)
 5dc:	74a2                	ld	s1,40(sp)
 5de:	7902                	ld	s2,32(sp)
 5e0:	69e2                	ld	s3,24(sp)
 5e2:	6121                	addi	sp,sp,64
 5e4:	8082                	ret
    x = -xx;
 5e6:	40b005bb          	negw	a1,a1
    neg = 1;
 5ea:	4885                	li	a7,1
    x = -xx;
 5ec:	bf85                	j	55c <printint+0x1a>

00000000000005ee <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5ee:	7119                	addi	sp,sp,-128
 5f0:	fc86                	sd	ra,120(sp)
 5f2:	f8a2                	sd	s0,112(sp)
 5f4:	f4a6                	sd	s1,104(sp)
 5f6:	f0ca                	sd	s2,96(sp)
 5f8:	ecce                	sd	s3,88(sp)
 5fa:	e8d2                	sd	s4,80(sp)
 5fc:	e4d6                	sd	s5,72(sp)
 5fe:	e0da                	sd	s6,64(sp)
 600:	fc5e                	sd	s7,56(sp)
 602:	f862                	sd	s8,48(sp)
 604:	f466                	sd	s9,40(sp)
 606:	f06a                	sd	s10,32(sp)
 608:	ec6e                	sd	s11,24(sp)
 60a:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 60c:	0005c903          	lbu	s2,0(a1)
 610:	18090f63          	beqz	s2,7ae <vprintf+0x1c0>
 614:	8aaa                	mv	s5,a0
 616:	8b32                	mv	s6,a2
 618:	00158493          	addi	s1,a1,1
  state = 0;
 61c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 61e:	02500a13          	li	s4,37
 622:	4c55                	li	s8,21
 624:	00000c97          	auipc	s9,0x0
 628:	4a4c8c93          	addi	s9,s9,1188 # ac8 <lock_release+0xc4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 62c:	02800d93          	li	s11,40
  putc(fd, 'x');
 630:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 632:	00000b97          	auipc	s7,0x0
 636:	4eeb8b93          	addi	s7,s7,1262 # b20 <digits>
 63a:	a839                	j	658 <vprintf+0x6a>
        putc(fd, c);
 63c:	85ca                	mv	a1,s2
 63e:	8556                	mv	a0,s5
 640:	00000097          	auipc	ra,0x0
 644:	ee0080e7          	jalr	-288(ra) # 520 <putc>
 648:	a019                	j	64e <vprintf+0x60>
    } else if(state == '%'){
 64a:	01498d63          	beq	s3,s4,664 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 64e:	0485                	addi	s1,s1,1
 650:	fff4c903          	lbu	s2,-1(s1)
 654:	14090d63          	beqz	s2,7ae <vprintf+0x1c0>
    if(state == 0){
 658:	fe0999e3          	bnez	s3,64a <vprintf+0x5c>
      if(c == '%'){
 65c:	ff4910e3          	bne	s2,s4,63c <vprintf+0x4e>
        state = '%';
 660:	89d2                	mv	s3,s4
 662:	b7f5                	j	64e <vprintf+0x60>
      if(c == 'd'){
 664:	11490c63          	beq	s2,s4,77c <vprintf+0x18e>
 668:	f9d9079b          	addiw	a5,s2,-99
 66c:	0ff7f793          	zext.b	a5,a5
 670:	10fc6e63          	bltu	s8,a5,78c <vprintf+0x19e>
 674:	f9d9079b          	addiw	a5,s2,-99
 678:	0ff7f713          	zext.b	a4,a5
 67c:	10ec6863          	bltu	s8,a4,78c <vprintf+0x19e>
 680:	00271793          	slli	a5,a4,0x2
 684:	97e6                	add	a5,a5,s9
 686:	439c                	lw	a5,0(a5)
 688:	97e6                	add	a5,a5,s9
 68a:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 68c:	008b0913          	addi	s2,s6,8
 690:	4685                	li	a3,1
 692:	4629                	li	a2,10
 694:	000b2583          	lw	a1,0(s6)
 698:	8556                	mv	a0,s5
 69a:	00000097          	auipc	ra,0x0
 69e:	ea8080e7          	jalr	-344(ra) # 542 <printint>
 6a2:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 6a4:	4981                	li	s3,0
 6a6:	b765                	j	64e <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6a8:	008b0913          	addi	s2,s6,8
 6ac:	4681                	li	a3,0
 6ae:	4629                	li	a2,10
 6b0:	000b2583          	lw	a1,0(s6)
 6b4:	8556                	mv	a0,s5
 6b6:	00000097          	auipc	ra,0x0
 6ba:	e8c080e7          	jalr	-372(ra) # 542 <printint>
 6be:	8b4a                	mv	s6,s2
      state = 0;
 6c0:	4981                	li	s3,0
 6c2:	b771                	j	64e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 6c4:	008b0913          	addi	s2,s6,8
 6c8:	4681                	li	a3,0
 6ca:	866a                	mv	a2,s10
 6cc:	000b2583          	lw	a1,0(s6)
 6d0:	8556                	mv	a0,s5
 6d2:	00000097          	auipc	ra,0x0
 6d6:	e70080e7          	jalr	-400(ra) # 542 <printint>
 6da:	8b4a                	mv	s6,s2
      state = 0;
 6dc:	4981                	li	s3,0
 6de:	bf85                	j	64e <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6e0:	008b0793          	addi	a5,s6,8
 6e4:	f8f43423          	sd	a5,-120(s0)
 6e8:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6ec:	03000593          	li	a1,48
 6f0:	8556                	mv	a0,s5
 6f2:	00000097          	auipc	ra,0x0
 6f6:	e2e080e7          	jalr	-466(ra) # 520 <putc>
  putc(fd, 'x');
 6fa:	07800593          	li	a1,120
 6fe:	8556                	mv	a0,s5
 700:	00000097          	auipc	ra,0x0
 704:	e20080e7          	jalr	-480(ra) # 520 <putc>
 708:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 70a:	03c9d793          	srli	a5,s3,0x3c
 70e:	97de                	add	a5,a5,s7
 710:	0007c583          	lbu	a1,0(a5)
 714:	8556                	mv	a0,s5
 716:	00000097          	auipc	ra,0x0
 71a:	e0a080e7          	jalr	-502(ra) # 520 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 71e:	0992                	slli	s3,s3,0x4
 720:	397d                	addiw	s2,s2,-1
 722:	fe0914e3          	bnez	s2,70a <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 726:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 72a:	4981                	li	s3,0
 72c:	b70d                	j	64e <vprintf+0x60>
        s = va_arg(ap, char*);
 72e:	008b0913          	addi	s2,s6,8
 732:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 736:	02098163          	beqz	s3,758 <vprintf+0x16a>
        while(*s != 0){
 73a:	0009c583          	lbu	a1,0(s3)
 73e:	c5ad                	beqz	a1,7a8 <vprintf+0x1ba>
          putc(fd, *s);
 740:	8556                	mv	a0,s5
 742:	00000097          	auipc	ra,0x0
 746:	dde080e7          	jalr	-546(ra) # 520 <putc>
          s++;
 74a:	0985                	addi	s3,s3,1
        while(*s != 0){
 74c:	0009c583          	lbu	a1,0(s3)
 750:	f9e5                	bnez	a1,740 <vprintf+0x152>
        s = va_arg(ap, char*);
 752:	8b4a                	mv	s6,s2
      state = 0;
 754:	4981                	li	s3,0
 756:	bde5                	j	64e <vprintf+0x60>
          s = "(null)";
 758:	00000997          	auipc	s3,0x0
 75c:	36898993          	addi	s3,s3,872 # ac0 <lock_release+0xbc>
        while(*s != 0){
 760:	85ee                	mv	a1,s11
 762:	bff9                	j	740 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 764:	008b0913          	addi	s2,s6,8
 768:	000b4583          	lbu	a1,0(s6)
 76c:	8556                	mv	a0,s5
 76e:	00000097          	auipc	ra,0x0
 772:	db2080e7          	jalr	-590(ra) # 520 <putc>
 776:	8b4a                	mv	s6,s2
      state = 0;
 778:	4981                	li	s3,0
 77a:	bdd1                	j	64e <vprintf+0x60>
        putc(fd, c);
 77c:	85d2                	mv	a1,s4
 77e:	8556                	mv	a0,s5
 780:	00000097          	auipc	ra,0x0
 784:	da0080e7          	jalr	-608(ra) # 520 <putc>
      state = 0;
 788:	4981                	li	s3,0
 78a:	b5d1                	j	64e <vprintf+0x60>
        putc(fd, '%');
 78c:	85d2                	mv	a1,s4
 78e:	8556                	mv	a0,s5
 790:	00000097          	auipc	ra,0x0
 794:	d90080e7          	jalr	-624(ra) # 520 <putc>
        putc(fd, c);
 798:	85ca                	mv	a1,s2
 79a:	8556                	mv	a0,s5
 79c:	00000097          	auipc	ra,0x0
 7a0:	d84080e7          	jalr	-636(ra) # 520 <putc>
      state = 0;
 7a4:	4981                	li	s3,0
 7a6:	b565                	j	64e <vprintf+0x60>
        s = va_arg(ap, char*);
 7a8:	8b4a                	mv	s6,s2
      state = 0;
 7aa:	4981                	li	s3,0
 7ac:	b54d                	j	64e <vprintf+0x60>
    }
  }
}
 7ae:	70e6                	ld	ra,120(sp)
 7b0:	7446                	ld	s0,112(sp)
 7b2:	74a6                	ld	s1,104(sp)
 7b4:	7906                	ld	s2,96(sp)
 7b6:	69e6                	ld	s3,88(sp)
 7b8:	6a46                	ld	s4,80(sp)
 7ba:	6aa6                	ld	s5,72(sp)
 7bc:	6b06                	ld	s6,64(sp)
 7be:	7be2                	ld	s7,56(sp)
 7c0:	7c42                	ld	s8,48(sp)
 7c2:	7ca2                	ld	s9,40(sp)
 7c4:	7d02                	ld	s10,32(sp)
 7c6:	6de2                	ld	s11,24(sp)
 7c8:	6109                	addi	sp,sp,128
 7ca:	8082                	ret

00000000000007cc <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7cc:	715d                	addi	sp,sp,-80
 7ce:	ec06                	sd	ra,24(sp)
 7d0:	e822                	sd	s0,16(sp)
 7d2:	1000                	addi	s0,sp,32
 7d4:	e010                	sd	a2,0(s0)
 7d6:	e414                	sd	a3,8(s0)
 7d8:	e818                	sd	a4,16(s0)
 7da:	ec1c                	sd	a5,24(s0)
 7dc:	03043023          	sd	a6,32(s0)
 7e0:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7e4:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7e8:	8622                	mv	a2,s0
 7ea:	00000097          	auipc	ra,0x0
 7ee:	e04080e7          	jalr	-508(ra) # 5ee <vprintf>
}
 7f2:	60e2                	ld	ra,24(sp)
 7f4:	6442                	ld	s0,16(sp)
 7f6:	6161                	addi	sp,sp,80
 7f8:	8082                	ret

00000000000007fa <printf>:

void
printf(const char *fmt, ...)
{
 7fa:	711d                	addi	sp,sp,-96
 7fc:	ec06                	sd	ra,24(sp)
 7fe:	e822                	sd	s0,16(sp)
 800:	1000                	addi	s0,sp,32
 802:	e40c                	sd	a1,8(s0)
 804:	e810                	sd	a2,16(s0)
 806:	ec14                	sd	a3,24(s0)
 808:	f018                	sd	a4,32(s0)
 80a:	f41c                	sd	a5,40(s0)
 80c:	03043823          	sd	a6,48(s0)
 810:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 814:	00840613          	addi	a2,s0,8
 818:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 81c:	85aa                	mv	a1,a0
 81e:	4505                	li	a0,1
 820:	00000097          	auipc	ra,0x0
 824:	dce080e7          	jalr	-562(ra) # 5ee <vprintf>
}
 828:	60e2                	ld	ra,24(sp)
 82a:	6442                	ld	s0,16(sp)
 82c:	6125                	addi	sp,sp,96
 82e:	8082                	ret

0000000000000830 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 830:	1141                	addi	sp,sp,-16
 832:	e422                	sd	s0,8(sp)
 834:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 836:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 83a:	00000797          	auipc	a5,0x0
 83e:	7de7b783          	ld	a5,2014(a5) # 1018 <freep>
 842:	a02d                	j	86c <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 844:	4618                	lw	a4,8(a2)
 846:	9f2d                	addw	a4,a4,a1
 848:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 84c:	6398                	ld	a4,0(a5)
 84e:	6310                	ld	a2,0(a4)
 850:	a83d                	j	88e <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 852:	ff852703          	lw	a4,-8(a0)
 856:	9f31                	addw	a4,a4,a2
 858:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 85a:	ff053683          	ld	a3,-16(a0)
 85e:	a091                	j	8a2 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 860:	6398                	ld	a4,0(a5)
 862:	00e7e463          	bltu	a5,a4,86a <free+0x3a>
 866:	00e6ea63          	bltu	a3,a4,87a <free+0x4a>
{
 86a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 86c:	fed7fae3          	bgeu	a5,a3,860 <free+0x30>
 870:	6398                	ld	a4,0(a5)
 872:	00e6e463          	bltu	a3,a4,87a <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 876:	fee7eae3          	bltu	a5,a4,86a <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 87a:	ff852583          	lw	a1,-8(a0)
 87e:	6390                	ld	a2,0(a5)
 880:	02059813          	slli	a6,a1,0x20
 884:	01c85713          	srli	a4,a6,0x1c
 888:	9736                	add	a4,a4,a3
 88a:	fae60de3          	beq	a2,a4,844 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 88e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 892:	4790                	lw	a2,8(a5)
 894:	02061593          	slli	a1,a2,0x20
 898:	01c5d713          	srli	a4,a1,0x1c
 89c:	973e                	add	a4,a4,a5
 89e:	fae68ae3          	beq	a3,a4,852 <free+0x22>
    p->s.ptr = bp->s.ptr;
 8a2:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8a4:	00000717          	auipc	a4,0x0
 8a8:	76f73a23          	sd	a5,1908(a4) # 1018 <freep>
}
 8ac:	6422                	ld	s0,8(sp)
 8ae:	0141                	addi	sp,sp,16
 8b0:	8082                	ret

00000000000008b2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8b2:	7139                	addi	sp,sp,-64
 8b4:	fc06                	sd	ra,56(sp)
 8b6:	f822                	sd	s0,48(sp)
 8b8:	f426                	sd	s1,40(sp)
 8ba:	f04a                	sd	s2,32(sp)
 8bc:	ec4e                	sd	s3,24(sp)
 8be:	e852                	sd	s4,16(sp)
 8c0:	e456                	sd	s5,8(sp)
 8c2:	e05a                	sd	s6,0(sp)
 8c4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8c6:	02051493          	slli	s1,a0,0x20
 8ca:	9081                	srli	s1,s1,0x20
 8cc:	04bd                	addi	s1,s1,15
 8ce:	8091                	srli	s1,s1,0x4
 8d0:	0014899b          	addiw	s3,s1,1
 8d4:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8d6:	00000517          	auipc	a0,0x0
 8da:	74253503          	ld	a0,1858(a0) # 1018 <freep>
 8de:	c515                	beqz	a0,90a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8e0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8e2:	4798                	lw	a4,8(a5)
 8e4:	02977f63          	bgeu	a4,s1,922 <malloc+0x70>
 8e8:	8a4e                	mv	s4,s3
 8ea:	0009871b          	sext.w	a4,s3
 8ee:	6685                	lui	a3,0x1
 8f0:	00d77363          	bgeu	a4,a3,8f6 <malloc+0x44>
 8f4:	6a05                	lui	s4,0x1
 8f6:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8fa:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8fe:	00000917          	auipc	s2,0x0
 902:	71a90913          	addi	s2,s2,1818 # 1018 <freep>
  if(p == (char*)-1)
 906:	5afd                	li	s5,-1
 908:	a895                	j	97c <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 90a:	00000797          	auipc	a5,0x0
 90e:	71678793          	addi	a5,a5,1814 # 1020 <base>
 912:	00000717          	auipc	a4,0x0
 916:	70f73323          	sd	a5,1798(a4) # 1018 <freep>
 91a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 91c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 920:	b7e1                	j	8e8 <malloc+0x36>
      if(p->s.size == nunits)
 922:	02e48c63          	beq	s1,a4,95a <malloc+0xa8>
        p->s.size -= nunits;
 926:	4137073b          	subw	a4,a4,s3
 92a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 92c:	02071693          	slli	a3,a4,0x20
 930:	01c6d713          	srli	a4,a3,0x1c
 934:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 936:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 93a:	00000717          	auipc	a4,0x0
 93e:	6ca73f23          	sd	a0,1758(a4) # 1018 <freep>
      return (void*)(p + 1);
 942:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 946:	70e2                	ld	ra,56(sp)
 948:	7442                	ld	s0,48(sp)
 94a:	74a2                	ld	s1,40(sp)
 94c:	7902                	ld	s2,32(sp)
 94e:	69e2                	ld	s3,24(sp)
 950:	6a42                	ld	s4,16(sp)
 952:	6aa2                	ld	s5,8(sp)
 954:	6b02                	ld	s6,0(sp)
 956:	6121                	addi	sp,sp,64
 958:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 95a:	6398                	ld	a4,0(a5)
 95c:	e118                	sd	a4,0(a0)
 95e:	bff1                	j	93a <malloc+0x88>
  hp->s.size = nu;
 960:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 964:	0541                	addi	a0,a0,16
 966:	00000097          	auipc	ra,0x0
 96a:	eca080e7          	jalr	-310(ra) # 830 <free>
  return freep;
 96e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 972:	d971                	beqz	a0,946 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 974:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 976:	4798                	lw	a4,8(a5)
 978:	fa9775e3          	bgeu	a4,s1,922 <malloc+0x70>
    if(p == freep)
 97c:	00093703          	ld	a4,0(s2)
 980:	853e                	mv	a0,a5
 982:	fef719e3          	bne	a4,a5,974 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 986:	8552                	mv	a0,s4
 988:	00000097          	auipc	ra,0x0
 98c:	b50080e7          	jalr	-1200(ra) # 4d8 <sbrk>
  if(p == (char*)-1)
 990:	fd5518e3          	bne	a0,s5,960 <malloc+0xae>
        return 0;
 994:	4501                	li	a0,0
 996:	bf45                	j	946 <malloc+0x94>

0000000000000998 <thread_create>:
#include "user/user.h"
#include "user/thread.h"

int
thread_create(void *(start_routine)(void*), void *arg)
{
 998:	1101                	addi	sp,sp,-32
 99a:	ec06                	sd	ra,24(sp)
 99c:	e822                	sd	s0,16(sp)
 99e:	e426                	sd	s1,8(sp)
 9a0:	e04a                	sd	s2,0(sp)
 9a2:	1000                	addi	s0,sp,32
 9a4:	84aa                	mv	s1,a0
 9a6:	892e                	mv	s2,a1
    int pg_size = 4096*sizeof(void);
    void* stack = (void*)malloc(pg_size);
 9a8:	6505                	lui	a0,0x1
 9aa:	00000097          	auipc	ra,0x0
 9ae:	f08080e7          	jalr	-248(ra) # 8b2 <malloc>
    int t_id = clone(stack);
 9b2:	00000097          	auipc	ra,0x0
 9b6:	b66080e7          	jalr	-1178(ra) # 518 <clone>
    if(t_id==0) {
 9ba:	c901                	beqz	a0,9ca <thread_create+0x32>
        (*start_routine)(arg);
        exit(0);
    }
    return 0;
}
 9bc:	4501                	li	a0,0
 9be:	60e2                	ld	ra,24(sp)
 9c0:	6442                	ld	s0,16(sp)
 9c2:	64a2                	ld	s1,8(sp)
 9c4:	6902                	ld	s2,0(sp)
 9c6:	6105                	addi	sp,sp,32
 9c8:	8082                	ret
        (*start_routine)(arg);
 9ca:	854a                	mv	a0,s2
 9cc:	9482                	jalr	s1
        exit(0);
 9ce:	4501                	li	a0,0
 9d0:	00000097          	auipc	ra,0x0
 9d4:	a80080e7          	jalr	-1408(ra) # 450 <exit>

00000000000009d8 <lock_init>:

void
lock_init(struct lock_t *lock)
{
 9d8:	1141                	addi	sp,sp,-16
 9da:	e422                	sd	s0,8(sp)
 9dc:	0800                	addi	s0,sp,16
    lock->locked = 0;
 9de:	00052023          	sw	zero,0(a0) # 1000 <cur_pass>
}
 9e2:	6422                	ld	s0,8(sp)
 9e4:	0141                	addi	sp,sp,16
 9e6:	8082                	ret

00000000000009e8 <lock_acquire>:

void
lock_acquire(struct lock_t *lock)
{
 9e8:	1141                	addi	sp,sp,-16
 9ea:	e422                	sd	s0,8(sp)
 9ec:	0800                	addi	s0,sp,16
    while(__sync_lock_test_and_set(&lock->locked, 1)!= 0);
 9ee:	4705                	li	a4,1
 9f0:	87ba                	mv	a5,a4
 9f2:	0cf527af          	amoswap.w.aq	a5,a5,(a0)
 9f6:	2781                	sext.w	a5,a5
 9f8:	ffe5                	bnez	a5,9f0 <lock_acquire+0x8>
    __sync_synchronize();
 9fa:	0ff0000f          	fence
}
 9fe:	6422                	ld	s0,8(sp)
 a00:	0141                	addi	sp,sp,16
 a02:	8082                	ret

0000000000000a04 <lock_release>:

void
lock_release(struct lock_t *lock)
{
 a04:	1141                	addi	sp,sp,-16
 a06:	e422                	sd	s0,8(sp)
 a08:	0800                	addi	s0,sp,16
    __sync_synchronize();
 a0a:	0ff0000f          	fence
    __sync_lock_release(&lock->locked, 0);
 a0e:	0f50000f          	fence	iorw,ow
 a12:	0805202f          	amoswap.w	zero,zero,(a0)
}
 a16:	6422                	ld	s0,8(sp)
 a18:	0141                	addi	sp,sp,16
 a1a:	8082                	ret