
user/_lab2:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#define MAX_PROC 10
int main(int argc, char *argv[])
{
   0:	7119                	addi	sp,sp,-128
   2:	fc86                	sd	ra,120(sp)
   4:	f8a2                	sd	s0,112(sp)
   6:	f4a6                	sd	s1,104(sp)
   8:	f0ca                	sd	s2,96(sp)
   a:	ecce                	sd	s3,88(sp)
   c:	e8d2                	sd	s4,80(sp)
   e:	e4d6                	sd	s5,72(sp)
  10:	e0da                	sd	s6,64(sp)
  12:	fc5e                	sd	s7,56(sp)
  14:	0100                	addi	s0,sp,128
  16:	84ae                	mv	s1,a1
    int sleep_ticks, n_proc, ret, proc_pid[MAX_PROC];
    if (argc < 4)
  18:	478d                	li	a5,3
  1a:	02a7c063          	blt	a5,a0,3a <main+0x3a>
    {
        printf("Usage: %s [SLEEP] [N_PROC] [TICKET1] [TICKET2]...\n", argv[0]);
  1e:	618c                	ld	a1,0(a1)
  20:	00001517          	auipc	a0,0x1
  24:	92050513          	addi	a0,a0,-1760 # 940 <lock_release+0x22>
  28:	00000097          	auipc	ra,0x0
  2c:	6ec080e7          	jalr	1772(ra) # 714 <printf>
        exit(-1);
  30:	557d                	li	a0,-1
  32:	00000097          	auipc	ra,0x0
  36:	338080e7          	jalr	824(ra) # 36a <exit>
    }
    sleep_ticks = atoi(argv[1]);
  3a:	6588                	ld	a0,8(a1)
  3c:	00000097          	auipc	ra,0x0
  40:	234080e7          	jalr	564(ra) # 270 <atoi>
  44:	8aaa                	mv	s5,a0
    n_proc = atoi(argv[2]);
  46:	6888                	ld	a0,16(s1)
  48:	00000097          	auipc	ra,0x0
  4c:	228080e7          	jalr	552(ra) # 270 <atoi>
  50:	892a                	mv	s2,a0
    if (n_proc > MAX_PROC)
  52:	47a9                	li	a5,10
  54:	02a7cb63          	blt	a5,a0,8a <main+0x8a>
  58:	f8840b13          	addi	s6,s0,-120
  5c:	04e1                	addi	s1,s1,24
  5e:	8bda                	mv	s7,s6
    {
        printf("Cannot test with more than %d processes\n", MAX_PROC);
        exit(-1);
    }
    for (int i = 0; i < n_proc; i++)
  60:	4a01                	li	s4,0
  62:	052a5763          	bge	s4,s2,b0 <main+0xb0>
    {
        int n_tickets = atoi(argv[3 + i]);
  66:	6088                	ld	a0,0(s1)
  68:	00000097          	auipc	ra,0x0
  6c:	208080e7          	jalr	520(ra) # 270 <atoi>
  70:	89aa                	mv	s3,a0
        ret = fork();
  72:	00000097          	auipc	ra,0x0
  76:	2f0080e7          	jalr	752(ra) # 362 <fork>
        if (ret == 0)
  7a:	04a1                	addi	s1,s1,8
  7c:	e50d                	bnez	a0,a6 <main+0xa6>
        { // child process
            sched_tickets(n_tickets);
  7e:	854e                	mv	a0,s3
  80:	00000097          	auipc	ra,0x0
  84:	3a2080e7          	jalr	930(ra) # 422 <sched_tickets>
            while (1)
  88:	a001                	j	88 <main+0x88>
        printf("Cannot test with more than %d processes\n", MAX_PROC);
  8a:	45a9                	li	a1,10
  8c:	00001517          	auipc	a0,0x1
  90:	8ec50513          	addi	a0,a0,-1812 # 978 <lock_release+0x5a>
  94:	00000097          	auipc	ra,0x0
  98:	680080e7          	jalr	1664(ra) # 714 <printf>
        exit(-1);
  9c:	557d                	li	a0,-1
  9e:	00000097          	auipc	ra,0x0
  a2:	2cc080e7          	jalr	716(ra) # 36a <exit>
                ;
        }
        else
        { // parent
            proc_pid[i] = ret;
  a6:	00aba023          	sw	a0,0(s7)
    for (int i = 0; i < n_proc; i++)
  aa:	2a05                	addiw	s4,s4,1
  ac:	0b91                	addi	s7,s7,4
  ae:	bf55                	j	62 <main+0x62>
            continue;
        }
    }
    sleep(sleep_ticks);
  b0:	8556                	mv	a0,s5
  b2:	00000097          	auipc	ra,0x0
  b6:	348080e7          	jalr	840(ra) # 3fa <sleep>
    sched_statistics();
  ba:	00000097          	auipc	ra,0x0
  be:	370080e7          	jalr	880(ra) # 42a <sched_statistics>

    for (int i = 0; i < n_proc; i++)
  c2:	4481                	li	s1,0
  c4:	0124db63          	bge	s1,s2,da <main+0xda>
        kill(proc_pid[i]);
  c8:	000b2503          	lw	a0,0(s6)
  cc:	00000097          	auipc	ra,0x0
  d0:	2ce080e7          	jalr	718(ra) # 39a <kill>
    for (int i = 0; i < n_proc; i++)
  d4:	2485                	addiw	s1,s1,1
  d6:	0b11                	addi	s6,s6,4
  d8:	b7f5                	j	c4 <main+0xc4>
    exit(0);
  da:	4501                	li	a0,0
  dc:	00000097          	auipc	ra,0x0
  e0:	28e080e7          	jalr	654(ra) # 36a <exit>

00000000000000e4 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  e4:	1141                	addi	sp,sp,-16
  e6:	e406                	sd	ra,8(sp)
  e8:	e022                	sd	s0,0(sp)
  ea:	0800                	addi	s0,sp,16
  extern int main();
  main();
  ec:	00000097          	auipc	ra,0x0
  f0:	f14080e7          	jalr	-236(ra) # 0 <main>
  exit(0);
  f4:	4501                	li	a0,0
  f6:	00000097          	auipc	ra,0x0
  fa:	274080e7          	jalr	628(ra) # 36a <exit>

00000000000000fe <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  fe:	1141                	addi	sp,sp,-16
 100:	e422                	sd	s0,8(sp)
 102:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 104:	87aa                	mv	a5,a0
 106:	0585                	addi	a1,a1,1
 108:	0785                	addi	a5,a5,1
 10a:	fff5c703          	lbu	a4,-1(a1)
 10e:	fee78fa3          	sb	a4,-1(a5)
 112:	fb75                	bnez	a4,106 <strcpy+0x8>
    ;
  return os;
}
 114:	6422                	ld	s0,8(sp)
 116:	0141                	addi	sp,sp,16
 118:	8082                	ret

000000000000011a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 11a:	1141                	addi	sp,sp,-16
 11c:	e422                	sd	s0,8(sp)
 11e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 120:	00054783          	lbu	a5,0(a0)
 124:	cb91                	beqz	a5,138 <strcmp+0x1e>
 126:	0005c703          	lbu	a4,0(a1)
 12a:	00f71763          	bne	a4,a5,138 <strcmp+0x1e>
    p++, q++;
 12e:	0505                	addi	a0,a0,1
 130:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 132:	00054783          	lbu	a5,0(a0)
 136:	fbe5                	bnez	a5,126 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 138:	0005c503          	lbu	a0,0(a1)
}
 13c:	40a7853b          	subw	a0,a5,a0
 140:	6422                	ld	s0,8(sp)
 142:	0141                	addi	sp,sp,16
 144:	8082                	ret

0000000000000146 <strlen>:

uint
strlen(const char *s)
{
 146:	1141                	addi	sp,sp,-16
 148:	e422                	sd	s0,8(sp)
 14a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 14c:	00054783          	lbu	a5,0(a0)
 150:	cf91                	beqz	a5,16c <strlen+0x26>
 152:	0505                	addi	a0,a0,1
 154:	87aa                	mv	a5,a0
 156:	4685                	li	a3,1
 158:	9e89                	subw	a3,a3,a0
 15a:	00f6853b          	addw	a0,a3,a5
 15e:	0785                	addi	a5,a5,1
 160:	fff7c703          	lbu	a4,-1(a5)
 164:	fb7d                	bnez	a4,15a <strlen+0x14>
    ;
  return n;
}
 166:	6422                	ld	s0,8(sp)
 168:	0141                	addi	sp,sp,16
 16a:	8082                	ret
  for(n = 0; s[n]; n++)
 16c:	4501                	li	a0,0
 16e:	bfe5                	j	166 <strlen+0x20>

0000000000000170 <memset>:

void*
memset(void *dst, int c, uint n)
{
 170:	1141                	addi	sp,sp,-16
 172:	e422                	sd	s0,8(sp)
 174:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 176:	ca19                	beqz	a2,18c <memset+0x1c>
 178:	87aa                	mv	a5,a0
 17a:	1602                	slli	a2,a2,0x20
 17c:	9201                	srli	a2,a2,0x20
 17e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 182:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 186:	0785                	addi	a5,a5,1
 188:	fee79de3          	bne	a5,a4,182 <memset+0x12>
  }
  return dst;
}
 18c:	6422                	ld	s0,8(sp)
 18e:	0141                	addi	sp,sp,16
 190:	8082                	ret

0000000000000192 <strchr>:

char*
strchr(const char *s, char c)
{
 192:	1141                	addi	sp,sp,-16
 194:	e422                	sd	s0,8(sp)
 196:	0800                	addi	s0,sp,16
  for(; *s; s++)
 198:	00054783          	lbu	a5,0(a0)
 19c:	cb99                	beqz	a5,1b2 <strchr+0x20>
    if(*s == c)
 19e:	00f58763          	beq	a1,a5,1ac <strchr+0x1a>
  for(; *s; s++)
 1a2:	0505                	addi	a0,a0,1
 1a4:	00054783          	lbu	a5,0(a0)
 1a8:	fbfd                	bnez	a5,19e <strchr+0xc>
      return (char*)s;
  return 0;
 1aa:	4501                	li	a0,0
}
 1ac:	6422                	ld	s0,8(sp)
 1ae:	0141                	addi	sp,sp,16
 1b0:	8082                	ret
  return 0;
 1b2:	4501                	li	a0,0
 1b4:	bfe5                	j	1ac <strchr+0x1a>

00000000000001b6 <gets>:

char*
gets(char *buf, int max)
{
 1b6:	711d                	addi	sp,sp,-96
 1b8:	ec86                	sd	ra,88(sp)
 1ba:	e8a2                	sd	s0,80(sp)
 1bc:	e4a6                	sd	s1,72(sp)
 1be:	e0ca                	sd	s2,64(sp)
 1c0:	fc4e                	sd	s3,56(sp)
 1c2:	f852                	sd	s4,48(sp)
 1c4:	f456                	sd	s5,40(sp)
 1c6:	f05a                	sd	s6,32(sp)
 1c8:	ec5e                	sd	s7,24(sp)
 1ca:	1080                	addi	s0,sp,96
 1cc:	8baa                	mv	s7,a0
 1ce:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1d0:	892a                	mv	s2,a0
 1d2:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1d4:	4aa9                	li	s5,10
 1d6:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1d8:	89a6                	mv	s3,s1
 1da:	2485                	addiw	s1,s1,1
 1dc:	0344d863          	bge	s1,s4,20c <gets+0x56>
    cc = read(0, &c, 1);
 1e0:	4605                	li	a2,1
 1e2:	faf40593          	addi	a1,s0,-81
 1e6:	4501                	li	a0,0
 1e8:	00000097          	auipc	ra,0x0
 1ec:	19a080e7          	jalr	410(ra) # 382 <read>
    if(cc < 1)
 1f0:	00a05e63          	blez	a0,20c <gets+0x56>
    buf[i++] = c;
 1f4:	faf44783          	lbu	a5,-81(s0)
 1f8:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1fc:	01578763          	beq	a5,s5,20a <gets+0x54>
 200:	0905                	addi	s2,s2,1
 202:	fd679be3          	bne	a5,s6,1d8 <gets+0x22>
  for(i=0; i+1 < max; ){
 206:	89a6                	mv	s3,s1
 208:	a011                	j	20c <gets+0x56>
 20a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 20c:	99de                	add	s3,s3,s7
 20e:	00098023          	sb	zero,0(s3)
  return buf;
}
 212:	855e                	mv	a0,s7
 214:	60e6                	ld	ra,88(sp)
 216:	6446                	ld	s0,80(sp)
 218:	64a6                	ld	s1,72(sp)
 21a:	6906                	ld	s2,64(sp)
 21c:	79e2                	ld	s3,56(sp)
 21e:	7a42                	ld	s4,48(sp)
 220:	7aa2                	ld	s5,40(sp)
 222:	7b02                	ld	s6,32(sp)
 224:	6be2                	ld	s7,24(sp)
 226:	6125                	addi	sp,sp,96
 228:	8082                	ret

000000000000022a <stat>:

int
stat(const char *n, struct stat *st)
{
 22a:	1101                	addi	sp,sp,-32
 22c:	ec06                	sd	ra,24(sp)
 22e:	e822                	sd	s0,16(sp)
 230:	e426                	sd	s1,8(sp)
 232:	e04a                	sd	s2,0(sp)
 234:	1000                	addi	s0,sp,32
 236:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 238:	4581                	li	a1,0
 23a:	00000097          	auipc	ra,0x0
 23e:	170080e7          	jalr	368(ra) # 3aa <open>
  if(fd < 0)
 242:	02054563          	bltz	a0,26c <stat+0x42>
 246:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 248:	85ca                	mv	a1,s2
 24a:	00000097          	auipc	ra,0x0
 24e:	178080e7          	jalr	376(ra) # 3c2 <fstat>
 252:	892a                	mv	s2,a0
  close(fd);
 254:	8526                	mv	a0,s1
 256:	00000097          	auipc	ra,0x0
 25a:	13c080e7          	jalr	316(ra) # 392 <close>
  return r;
}
 25e:	854a                	mv	a0,s2
 260:	60e2                	ld	ra,24(sp)
 262:	6442                	ld	s0,16(sp)
 264:	64a2                	ld	s1,8(sp)
 266:	6902                	ld	s2,0(sp)
 268:	6105                	addi	sp,sp,32
 26a:	8082                	ret
    return -1;
 26c:	597d                	li	s2,-1
 26e:	bfc5                	j	25e <stat+0x34>

0000000000000270 <atoi>:

int
atoi(const char *s)
{
 270:	1141                	addi	sp,sp,-16
 272:	e422                	sd	s0,8(sp)
 274:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 276:	00054683          	lbu	a3,0(a0)
 27a:	fd06879b          	addiw	a5,a3,-48
 27e:	0ff7f793          	zext.b	a5,a5
 282:	4625                	li	a2,9
 284:	02f66863          	bltu	a2,a5,2b4 <atoi+0x44>
 288:	872a                	mv	a4,a0
  n = 0;
 28a:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 28c:	0705                	addi	a4,a4,1
 28e:	0025179b          	slliw	a5,a0,0x2
 292:	9fa9                	addw	a5,a5,a0
 294:	0017979b          	slliw	a5,a5,0x1
 298:	9fb5                	addw	a5,a5,a3
 29a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 29e:	00074683          	lbu	a3,0(a4)
 2a2:	fd06879b          	addiw	a5,a3,-48
 2a6:	0ff7f793          	zext.b	a5,a5
 2aa:	fef671e3          	bgeu	a2,a5,28c <atoi+0x1c>
  return n;
}
 2ae:	6422                	ld	s0,8(sp)
 2b0:	0141                	addi	sp,sp,16
 2b2:	8082                	ret
  n = 0;
 2b4:	4501                	li	a0,0
 2b6:	bfe5                	j	2ae <atoi+0x3e>

00000000000002b8 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2b8:	1141                	addi	sp,sp,-16
 2ba:	e422                	sd	s0,8(sp)
 2bc:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2be:	02b57463          	bgeu	a0,a1,2e6 <memmove+0x2e>
    while(n-- > 0)
 2c2:	00c05f63          	blez	a2,2e0 <memmove+0x28>
 2c6:	1602                	slli	a2,a2,0x20
 2c8:	9201                	srli	a2,a2,0x20
 2ca:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2ce:	872a                	mv	a4,a0
      *dst++ = *src++;
 2d0:	0585                	addi	a1,a1,1
 2d2:	0705                	addi	a4,a4,1
 2d4:	fff5c683          	lbu	a3,-1(a1)
 2d8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2dc:	fee79ae3          	bne	a5,a4,2d0 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2e0:	6422                	ld	s0,8(sp)
 2e2:	0141                	addi	sp,sp,16
 2e4:	8082                	ret
    dst += n;
 2e6:	00c50733          	add	a4,a0,a2
    src += n;
 2ea:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2ec:	fec05ae3          	blez	a2,2e0 <memmove+0x28>
 2f0:	fff6079b          	addiw	a5,a2,-1
 2f4:	1782                	slli	a5,a5,0x20
 2f6:	9381                	srli	a5,a5,0x20
 2f8:	fff7c793          	not	a5,a5
 2fc:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2fe:	15fd                	addi	a1,a1,-1
 300:	177d                	addi	a4,a4,-1
 302:	0005c683          	lbu	a3,0(a1)
 306:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 30a:	fee79ae3          	bne	a5,a4,2fe <memmove+0x46>
 30e:	bfc9                	j	2e0 <memmove+0x28>

0000000000000310 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 310:	1141                	addi	sp,sp,-16
 312:	e422                	sd	s0,8(sp)
 314:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 316:	ca05                	beqz	a2,346 <memcmp+0x36>
 318:	fff6069b          	addiw	a3,a2,-1
 31c:	1682                	slli	a3,a3,0x20
 31e:	9281                	srli	a3,a3,0x20
 320:	0685                	addi	a3,a3,1
 322:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 324:	00054783          	lbu	a5,0(a0)
 328:	0005c703          	lbu	a4,0(a1)
 32c:	00e79863          	bne	a5,a4,33c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 330:	0505                	addi	a0,a0,1
    p2++;
 332:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 334:	fed518e3          	bne	a0,a3,324 <memcmp+0x14>
  }
  return 0;
 338:	4501                	li	a0,0
 33a:	a019                	j	340 <memcmp+0x30>
      return *p1 - *p2;
 33c:	40e7853b          	subw	a0,a5,a4
}
 340:	6422                	ld	s0,8(sp)
 342:	0141                	addi	sp,sp,16
 344:	8082                	ret
  return 0;
 346:	4501                	li	a0,0
 348:	bfe5                	j	340 <memcmp+0x30>

000000000000034a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 34a:	1141                	addi	sp,sp,-16
 34c:	e406                	sd	ra,8(sp)
 34e:	e022                	sd	s0,0(sp)
 350:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 352:	00000097          	auipc	ra,0x0
 356:	f66080e7          	jalr	-154(ra) # 2b8 <memmove>
}
 35a:	60a2                	ld	ra,8(sp)
 35c:	6402                	ld	s0,0(sp)
 35e:	0141                	addi	sp,sp,16
 360:	8082                	ret

0000000000000362 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 362:	4885                	li	a7,1
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <exit>:
.global exit
exit:
 li a7, SYS_exit
 36a:	4889                	li	a7,2
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <wait>:
.global wait
wait:
 li a7, SYS_wait
 372:	488d                	li	a7,3
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 37a:	4891                	li	a7,4
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <read>:
.global read
read:
 li a7, SYS_read
 382:	4895                	li	a7,5
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <write>:
.global write
write:
 li a7, SYS_write
 38a:	48c1                	li	a7,16
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <close>:
.global close
close:
 li a7, SYS_close
 392:	48d5                	li	a7,21
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <kill>:
.global kill
kill:
 li a7, SYS_kill
 39a:	4899                	li	a7,6
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3a2:	489d                	li	a7,7
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <open>:
.global open
open:
 li a7, SYS_open
 3aa:	48bd                	li	a7,15
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3b2:	48c5                	li	a7,17
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3ba:	48c9                	li	a7,18
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3c2:	48a1                	li	a7,8
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <link>:
.global link
link:
 li a7, SYS_link
 3ca:	48cd                	li	a7,19
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3d2:	48d1                	li	a7,20
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3da:	48a5                	li	a7,9
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3e2:	48a9                	li	a7,10
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3ea:	48ad                	li	a7,11
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3f2:	48b1                	li	a7,12
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3fa:	48b5                	li	a7,13
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 402:	48b9                	li	a7,14
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <hello>:
.global hello
hello:
 li a7, SYS_hello
 40a:	48d9                	li	a7,22
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <sysinfo>:
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo
 412:	48dd                	li	a7,23
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <procinfo>:
.global procinfo
procinfo:
 li a7, SYS_procinfo
 41a:	48e1                	li	a7,24
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <sched_tickets>:
.global sched_tickets
sched_tickets:
 li a7, SYS_sched_tickets
 422:	48e9                	li	a7,26
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <sched_statistics>:
.global sched_statistics
sched_statistics:
 li a7, SYS_sched_statistics
 42a:	48e5                	li	a7,25
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <clone>:
.global clone
clone:
 li a7, SYS_clone
 432:	48ed                	li	a7,27
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 43a:	1101                	addi	sp,sp,-32
 43c:	ec06                	sd	ra,24(sp)
 43e:	e822                	sd	s0,16(sp)
 440:	1000                	addi	s0,sp,32
 442:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 446:	4605                	li	a2,1
 448:	fef40593          	addi	a1,s0,-17
 44c:	00000097          	auipc	ra,0x0
 450:	f3e080e7          	jalr	-194(ra) # 38a <write>
}
 454:	60e2                	ld	ra,24(sp)
 456:	6442                	ld	s0,16(sp)
 458:	6105                	addi	sp,sp,32
 45a:	8082                	ret

000000000000045c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 45c:	7139                	addi	sp,sp,-64
 45e:	fc06                	sd	ra,56(sp)
 460:	f822                	sd	s0,48(sp)
 462:	f426                	sd	s1,40(sp)
 464:	f04a                	sd	s2,32(sp)
 466:	ec4e                	sd	s3,24(sp)
 468:	0080                	addi	s0,sp,64
 46a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 46c:	c299                	beqz	a3,472 <printint+0x16>
 46e:	0805c963          	bltz	a1,500 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 472:	2581                	sext.w	a1,a1
  neg = 0;
 474:	4881                	li	a7,0
 476:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 47a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 47c:	2601                	sext.w	a2,a2
 47e:	00000517          	auipc	a0,0x0
 482:	58a50513          	addi	a0,a0,1418 # a08 <digits>
 486:	883a                	mv	a6,a4
 488:	2705                	addiw	a4,a4,1
 48a:	02c5f7bb          	remuw	a5,a1,a2
 48e:	1782                	slli	a5,a5,0x20
 490:	9381                	srli	a5,a5,0x20
 492:	97aa                	add	a5,a5,a0
 494:	0007c783          	lbu	a5,0(a5)
 498:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 49c:	0005879b          	sext.w	a5,a1
 4a0:	02c5d5bb          	divuw	a1,a1,a2
 4a4:	0685                	addi	a3,a3,1
 4a6:	fec7f0e3          	bgeu	a5,a2,486 <printint+0x2a>
  if(neg)
 4aa:	00088c63          	beqz	a7,4c2 <printint+0x66>
    buf[i++] = '-';
 4ae:	fd070793          	addi	a5,a4,-48
 4b2:	00878733          	add	a4,a5,s0
 4b6:	02d00793          	li	a5,45
 4ba:	fef70823          	sb	a5,-16(a4)
 4be:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4c2:	02e05863          	blez	a4,4f2 <printint+0x96>
 4c6:	fc040793          	addi	a5,s0,-64
 4ca:	00e78933          	add	s2,a5,a4
 4ce:	fff78993          	addi	s3,a5,-1
 4d2:	99ba                	add	s3,s3,a4
 4d4:	377d                	addiw	a4,a4,-1
 4d6:	1702                	slli	a4,a4,0x20
 4d8:	9301                	srli	a4,a4,0x20
 4da:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4de:	fff94583          	lbu	a1,-1(s2)
 4e2:	8526                	mv	a0,s1
 4e4:	00000097          	auipc	ra,0x0
 4e8:	f56080e7          	jalr	-170(ra) # 43a <putc>
  while(--i >= 0)
 4ec:	197d                	addi	s2,s2,-1
 4ee:	ff3918e3          	bne	s2,s3,4de <printint+0x82>
}
 4f2:	70e2                	ld	ra,56(sp)
 4f4:	7442                	ld	s0,48(sp)
 4f6:	74a2                	ld	s1,40(sp)
 4f8:	7902                	ld	s2,32(sp)
 4fa:	69e2                	ld	s3,24(sp)
 4fc:	6121                	addi	sp,sp,64
 4fe:	8082                	ret
    x = -xx;
 500:	40b005bb          	negw	a1,a1
    neg = 1;
 504:	4885                	li	a7,1
    x = -xx;
 506:	bf85                	j	476 <printint+0x1a>

0000000000000508 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 508:	7119                	addi	sp,sp,-128
 50a:	fc86                	sd	ra,120(sp)
 50c:	f8a2                	sd	s0,112(sp)
 50e:	f4a6                	sd	s1,104(sp)
 510:	f0ca                	sd	s2,96(sp)
 512:	ecce                	sd	s3,88(sp)
 514:	e8d2                	sd	s4,80(sp)
 516:	e4d6                	sd	s5,72(sp)
 518:	e0da                	sd	s6,64(sp)
 51a:	fc5e                	sd	s7,56(sp)
 51c:	f862                	sd	s8,48(sp)
 51e:	f466                	sd	s9,40(sp)
 520:	f06a                	sd	s10,32(sp)
 522:	ec6e                	sd	s11,24(sp)
 524:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 526:	0005c903          	lbu	s2,0(a1)
 52a:	18090f63          	beqz	s2,6c8 <vprintf+0x1c0>
 52e:	8aaa                	mv	s5,a0
 530:	8b32                	mv	s6,a2
 532:	00158493          	addi	s1,a1,1
  state = 0;
 536:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 538:	02500a13          	li	s4,37
 53c:	4c55                	li	s8,21
 53e:	00000c97          	auipc	s9,0x0
 542:	472c8c93          	addi	s9,s9,1138 # 9b0 <lock_release+0x92>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 546:	02800d93          	li	s11,40
  putc(fd, 'x');
 54a:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 54c:	00000b97          	auipc	s7,0x0
 550:	4bcb8b93          	addi	s7,s7,1212 # a08 <digits>
 554:	a839                	j	572 <vprintf+0x6a>
        putc(fd, c);
 556:	85ca                	mv	a1,s2
 558:	8556                	mv	a0,s5
 55a:	00000097          	auipc	ra,0x0
 55e:	ee0080e7          	jalr	-288(ra) # 43a <putc>
 562:	a019                	j	568 <vprintf+0x60>
    } else if(state == '%'){
 564:	01498d63          	beq	s3,s4,57e <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 568:	0485                	addi	s1,s1,1
 56a:	fff4c903          	lbu	s2,-1(s1)
 56e:	14090d63          	beqz	s2,6c8 <vprintf+0x1c0>
    if(state == 0){
 572:	fe0999e3          	bnez	s3,564 <vprintf+0x5c>
      if(c == '%'){
 576:	ff4910e3          	bne	s2,s4,556 <vprintf+0x4e>
        state = '%';
 57a:	89d2                	mv	s3,s4
 57c:	b7f5                	j	568 <vprintf+0x60>
      if(c == 'd'){
 57e:	11490c63          	beq	s2,s4,696 <vprintf+0x18e>
 582:	f9d9079b          	addiw	a5,s2,-99
 586:	0ff7f793          	zext.b	a5,a5
 58a:	10fc6e63          	bltu	s8,a5,6a6 <vprintf+0x19e>
 58e:	f9d9079b          	addiw	a5,s2,-99
 592:	0ff7f713          	zext.b	a4,a5
 596:	10ec6863          	bltu	s8,a4,6a6 <vprintf+0x19e>
 59a:	00271793          	slli	a5,a4,0x2
 59e:	97e6                	add	a5,a5,s9
 5a0:	439c                	lw	a5,0(a5)
 5a2:	97e6                	add	a5,a5,s9
 5a4:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 5a6:	008b0913          	addi	s2,s6,8
 5aa:	4685                	li	a3,1
 5ac:	4629                	li	a2,10
 5ae:	000b2583          	lw	a1,0(s6)
 5b2:	8556                	mv	a0,s5
 5b4:	00000097          	auipc	ra,0x0
 5b8:	ea8080e7          	jalr	-344(ra) # 45c <printint>
 5bc:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5be:	4981                	li	s3,0
 5c0:	b765                	j	568 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5c2:	008b0913          	addi	s2,s6,8
 5c6:	4681                	li	a3,0
 5c8:	4629                	li	a2,10
 5ca:	000b2583          	lw	a1,0(s6)
 5ce:	8556                	mv	a0,s5
 5d0:	00000097          	auipc	ra,0x0
 5d4:	e8c080e7          	jalr	-372(ra) # 45c <printint>
 5d8:	8b4a                	mv	s6,s2
      state = 0;
 5da:	4981                	li	s3,0
 5dc:	b771                	j	568 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 5de:	008b0913          	addi	s2,s6,8
 5e2:	4681                	li	a3,0
 5e4:	866a                	mv	a2,s10
 5e6:	000b2583          	lw	a1,0(s6)
 5ea:	8556                	mv	a0,s5
 5ec:	00000097          	auipc	ra,0x0
 5f0:	e70080e7          	jalr	-400(ra) # 45c <printint>
 5f4:	8b4a                	mv	s6,s2
      state = 0;
 5f6:	4981                	li	s3,0
 5f8:	bf85                	j	568 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 5fa:	008b0793          	addi	a5,s6,8
 5fe:	f8f43423          	sd	a5,-120(s0)
 602:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 606:	03000593          	li	a1,48
 60a:	8556                	mv	a0,s5
 60c:	00000097          	auipc	ra,0x0
 610:	e2e080e7          	jalr	-466(ra) # 43a <putc>
  putc(fd, 'x');
 614:	07800593          	li	a1,120
 618:	8556                	mv	a0,s5
 61a:	00000097          	auipc	ra,0x0
 61e:	e20080e7          	jalr	-480(ra) # 43a <putc>
 622:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 624:	03c9d793          	srli	a5,s3,0x3c
 628:	97de                	add	a5,a5,s7
 62a:	0007c583          	lbu	a1,0(a5)
 62e:	8556                	mv	a0,s5
 630:	00000097          	auipc	ra,0x0
 634:	e0a080e7          	jalr	-502(ra) # 43a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 638:	0992                	slli	s3,s3,0x4
 63a:	397d                	addiw	s2,s2,-1
 63c:	fe0914e3          	bnez	s2,624 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 640:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 644:	4981                	li	s3,0
 646:	b70d                	j	568 <vprintf+0x60>
        s = va_arg(ap, char*);
 648:	008b0913          	addi	s2,s6,8
 64c:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 650:	02098163          	beqz	s3,672 <vprintf+0x16a>
        while(*s != 0){
 654:	0009c583          	lbu	a1,0(s3)
 658:	c5ad                	beqz	a1,6c2 <vprintf+0x1ba>
          putc(fd, *s);
 65a:	8556                	mv	a0,s5
 65c:	00000097          	auipc	ra,0x0
 660:	dde080e7          	jalr	-546(ra) # 43a <putc>
          s++;
 664:	0985                	addi	s3,s3,1
        while(*s != 0){
 666:	0009c583          	lbu	a1,0(s3)
 66a:	f9e5                	bnez	a1,65a <vprintf+0x152>
        s = va_arg(ap, char*);
 66c:	8b4a                	mv	s6,s2
      state = 0;
 66e:	4981                	li	s3,0
 670:	bde5                	j	568 <vprintf+0x60>
          s = "(null)";
 672:	00000997          	auipc	s3,0x0
 676:	33698993          	addi	s3,s3,822 # 9a8 <lock_release+0x8a>
        while(*s != 0){
 67a:	85ee                	mv	a1,s11
 67c:	bff9                	j	65a <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 67e:	008b0913          	addi	s2,s6,8
 682:	000b4583          	lbu	a1,0(s6)
 686:	8556                	mv	a0,s5
 688:	00000097          	auipc	ra,0x0
 68c:	db2080e7          	jalr	-590(ra) # 43a <putc>
 690:	8b4a                	mv	s6,s2
      state = 0;
 692:	4981                	li	s3,0
 694:	bdd1                	j	568 <vprintf+0x60>
        putc(fd, c);
 696:	85d2                	mv	a1,s4
 698:	8556                	mv	a0,s5
 69a:	00000097          	auipc	ra,0x0
 69e:	da0080e7          	jalr	-608(ra) # 43a <putc>
      state = 0;
 6a2:	4981                	li	s3,0
 6a4:	b5d1                	j	568 <vprintf+0x60>
        putc(fd, '%');
 6a6:	85d2                	mv	a1,s4
 6a8:	8556                	mv	a0,s5
 6aa:	00000097          	auipc	ra,0x0
 6ae:	d90080e7          	jalr	-624(ra) # 43a <putc>
        putc(fd, c);
 6b2:	85ca                	mv	a1,s2
 6b4:	8556                	mv	a0,s5
 6b6:	00000097          	auipc	ra,0x0
 6ba:	d84080e7          	jalr	-636(ra) # 43a <putc>
      state = 0;
 6be:	4981                	li	s3,0
 6c0:	b565                	j	568 <vprintf+0x60>
        s = va_arg(ap, char*);
 6c2:	8b4a                	mv	s6,s2
      state = 0;
 6c4:	4981                	li	s3,0
 6c6:	b54d                	j	568 <vprintf+0x60>
    }
  }
}
 6c8:	70e6                	ld	ra,120(sp)
 6ca:	7446                	ld	s0,112(sp)
 6cc:	74a6                	ld	s1,104(sp)
 6ce:	7906                	ld	s2,96(sp)
 6d0:	69e6                	ld	s3,88(sp)
 6d2:	6a46                	ld	s4,80(sp)
 6d4:	6aa6                	ld	s5,72(sp)
 6d6:	6b06                	ld	s6,64(sp)
 6d8:	7be2                	ld	s7,56(sp)
 6da:	7c42                	ld	s8,48(sp)
 6dc:	7ca2                	ld	s9,40(sp)
 6de:	7d02                	ld	s10,32(sp)
 6e0:	6de2                	ld	s11,24(sp)
 6e2:	6109                	addi	sp,sp,128
 6e4:	8082                	ret

00000000000006e6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6e6:	715d                	addi	sp,sp,-80
 6e8:	ec06                	sd	ra,24(sp)
 6ea:	e822                	sd	s0,16(sp)
 6ec:	1000                	addi	s0,sp,32
 6ee:	e010                	sd	a2,0(s0)
 6f0:	e414                	sd	a3,8(s0)
 6f2:	e818                	sd	a4,16(s0)
 6f4:	ec1c                	sd	a5,24(s0)
 6f6:	03043023          	sd	a6,32(s0)
 6fa:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6fe:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 702:	8622                	mv	a2,s0
 704:	00000097          	auipc	ra,0x0
 708:	e04080e7          	jalr	-508(ra) # 508 <vprintf>
}
 70c:	60e2                	ld	ra,24(sp)
 70e:	6442                	ld	s0,16(sp)
 710:	6161                	addi	sp,sp,80
 712:	8082                	ret

0000000000000714 <printf>:

void
printf(const char *fmt, ...)
{
 714:	711d                	addi	sp,sp,-96
 716:	ec06                	sd	ra,24(sp)
 718:	e822                	sd	s0,16(sp)
 71a:	1000                	addi	s0,sp,32
 71c:	e40c                	sd	a1,8(s0)
 71e:	e810                	sd	a2,16(s0)
 720:	ec14                	sd	a3,24(s0)
 722:	f018                	sd	a4,32(s0)
 724:	f41c                	sd	a5,40(s0)
 726:	03043823          	sd	a6,48(s0)
 72a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 72e:	00840613          	addi	a2,s0,8
 732:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 736:	85aa                	mv	a1,a0
 738:	4505                	li	a0,1
 73a:	00000097          	auipc	ra,0x0
 73e:	dce080e7          	jalr	-562(ra) # 508 <vprintf>
}
 742:	60e2                	ld	ra,24(sp)
 744:	6442                	ld	s0,16(sp)
 746:	6125                	addi	sp,sp,96
 748:	8082                	ret

000000000000074a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 74a:	1141                	addi	sp,sp,-16
 74c:	e422                	sd	s0,8(sp)
 74e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 750:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 754:	00001797          	auipc	a5,0x1
 758:	8ac7b783          	ld	a5,-1876(a5) # 1000 <freep>
 75c:	a02d                	j	786 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 75e:	4618                	lw	a4,8(a2)
 760:	9f2d                	addw	a4,a4,a1
 762:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 766:	6398                	ld	a4,0(a5)
 768:	6310                	ld	a2,0(a4)
 76a:	a83d                	j	7a8 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 76c:	ff852703          	lw	a4,-8(a0)
 770:	9f31                	addw	a4,a4,a2
 772:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 774:	ff053683          	ld	a3,-16(a0)
 778:	a091                	j	7bc <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 77a:	6398                	ld	a4,0(a5)
 77c:	00e7e463          	bltu	a5,a4,784 <free+0x3a>
 780:	00e6ea63          	bltu	a3,a4,794 <free+0x4a>
{
 784:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 786:	fed7fae3          	bgeu	a5,a3,77a <free+0x30>
 78a:	6398                	ld	a4,0(a5)
 78c:	00e6e463          	bltu	a3,a4,794 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 790:	fee7eae3          	bltu	a5,a4,784 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 794:	ff852583          	lw	a1,-8(a0)
 798:	6390                	ld	a2,0(a5)
 79a:	02059813          	slli	a6,a1,0x20
 79e:	01c85713          	srli	a4,a6,0x1c
 7a2:	9736                	add	a4,a4,a3
 7a4:	fae60de3          	beq	a2,a4,75e <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7a8:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7ac:	4790                	lw	a2,8(a5)
 7ae:	02061593          	slli	a1,a2,0x20
 7b2:	01c5d713          	srli	a4,a1,0x1c
 7b6:	973e                	add	a4,a4,a5
 7b8:	fae68ae3          	beq	a3,a4,76c <free+0x22>
    p->s.ptr = bp->s.ptr;
 7bc:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7be:	00001717          	auipc	a4,0x1
 7c2:	84f73123          	sd	a5,-1982(a4) # 1000 <freep>
}
 7c6:	6422                	ld	s0,8(sp)
 7c8:	0141                	addi	sp,sp,16
 7ca:	8082                	ret

00000000000007cc <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7cc:	7139                	addi	sp,sp,-64
 7ce:	fc06                	sd	ra,56(sp)
 7d0:	f822                	sd	s0,48(sp)
 7d2:	f426                	sd	s1,40(sp)
 7d4:	f04a                	sd	s2,32(sp)
 7d6:	ec4e                	sd	s3,24(sp)
 7d8:	e852                	sd	s4,16(sp)
 7da:	e456                	sd	s5,8(sp)
 7dc:	e05a                	sd	s6,0(sp)
 7de:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7e0:	02051493          	slli	s1,a0,0x20
 7e4:	9081                	srli	s1,s1,0x20
 7e6:	04bd                	addi	s1,s1,15
 7e8:	8091                	srli	s1,s1,0x4
 7ea:	0014899b          	addiw	s3,s1,1
 7ee:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7f0:	00001517          	auipc	a0,0x1
 7f4:	81053503          	ld	a0,-2032(a0) # 1000 <freep>
 7f8:	c515                	beqz	a0,824 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7fa:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7fc:	4798                	lw	a4,8(a5)
 7fe:	02977f63          	bgeu	a4,s1,83c <malloc+0x70>
 802:	8a4e                	mv	s4,s3
 804:	0009871b          	sext.w	a4,s3
 808:	6685                	lui	a3,0x1
 80a:	00d77363          	bgeu	a4,a3,810 <malloc+0x44>
 80e:	6a05                	lui	s4,0x1
 810:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 814:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 818:	00000917          	auipc	s2,0x0
 81c:	7e890913          	addi	s2,s2,2024 # 1000 <freep>
  if(p == (char*)-1)
 820:	5afd                	li	s5,-1
 822:	a895                	j	896 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 824:	00000797          	auipc	a5,0x0
 828:	7ec78793          	addi	a5,a5,2028 # 1010 <base>
 82c:	00000717          	auipc	a4,0x0
 830:	7cf73a23          	sd	a5,2004(a4) # 1000 <freep>
 834:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 836:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 83a:	b7e1                	j	802 <malloc+0x36>
      if(p->s.size == nunits)
 83c:	02e48c63          	beq	s1,a4,874 <malloc+0xa8>
        p->s.size -= nunits;
 840:	4137073b          	subw	a4,a4,s3
 844:	c798                	sw	a4,8(a5)
        p += p->s.size;
 846:	02071693          	slli	a3,a4,0x20
 84a:	01c6d713          	srli	a4,a3,0x1c
 84e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 850:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 854:	00000717          	auipc	a4,0x0
 858:	7aa73623          	sd	a0,1964(a4) # 1000 <freep>
      return (void*)(p + 1);
 85c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 860:	70e2                	ld	ra,56(sp)
 862:	7442                	ld	s0,48(sp)
 864:	74a2                	ld	s1,40(sp)
 866:	7902                	ld	s2,32(sp)
 868:	69e2                	ld	s3,24(sp)
 86a:	6a42                	ld	s4,16(sp)
 86c:	6aa2                	ld	s5,8(sp)
 86e:	6b02                	ld	s6,0(sp)
 870:	6121                	addi	sp,sp,64
 872:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 874:	6398                	ld	a4,0(a5)
 876:	e118                	sd	a4,0(a0)
 878:	bff1                	j	854 <malloc+0x88>
  hp->s.size = nu;
 87a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 87e:	0541                	addi	a0,a0,16
 880:	00000097          	auipc	ra,0x0
 884:	eca080e7          	jalr	-310(ra) # 74a <free>
  return freep;
 888:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 88c:	d971                	beqz	a0,860 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 88e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 890:	4798                	lw	a4,8(a5)
 892:	fa9775e3          	bgeu	a4,s1,83c <malloc+0x70>
    if(p == freep)
 896:	00093703          	ld	a4,0(s2)
 89a:	853e                	mv	a0,a5
 89c:	fef719e3          	bne	a4,a5,88e <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 8a0:	8552                	mv	a0,s4
 8a2:	00000097          	auipc	ra,0x0
 8a6:	b50080e7          	jalr	-1200(ra) # 3f2 <sbrk>
  if(p == (char*)-1)
 8aa:	fd5518e3          	bne	a0,s5,87a <malloc+0xae>
        return 0;
 8ae:	4501                	li	a0,0
 8b0:	bf45                	j	860 <malloc+0x94>

00000000000008b2 <thread_create>:
#include "user/user.h"
#include "user/thread.h"

int
thread_create(void *(start_routine)(void*), void *arg)
{
 8b2:	1101                	addi	sp,sp,-32
 8b4:	ec06                	sd	ra,24(sp)
 8b6:	e822                	sd	s0,16(sp)
 8b8:	e426                	sd	s1,8(sp)
 8ba:	e04a                	sd	s2,0(sp)
 8bc:	1000                	addi	s0,sp,32
 8be:	84aa                	mv	s1,a0
 8c0:	892e                	mv	s2,a1
    int pg_size = 4096*sizeof(void);
    void* stack = (void*)malloc(pg_size);
 8c2:	6505                	lui	a0,0x1
 8c4:	00000097          	auipc	ra,0x0
 8c8:	f08080e7          	jalr	-248(ra) # 7cc <malloc>
    int t_id = clone(stack);
 8cc:	00000097          	auipc	ra,0x0
 8d0:	b66080e7          	jalr	-1178(ra) # 432 <clone>
    if(t_id==0) {
 8d4:	c901                	beqz	a0,8e4 <thread_create+0x32>
        (*start_routine)(arg);
        exit(0);
    }
    return 0;
}
 8d6:	4501                	li	a0,0
 8d8:	60e2                	ld	ra,24(sp)
 8da:	6442                	ld	s0,16(sp)
 8dc:	64a2                	ld	s1,8(sp)
 8de:	6902                	ld	s2,0(sp)
 8e0:	6105                	addi	sp,sp,32
 8e2:	8082                	ret
        (*start_routine)(arg);
 8e4:	854a                	mv	a0,s2
 8e6:	9482                	jalr	s1
        exit(0);
 8e8:	4501                	li	a0,0
 8ea:	00000097          	auipc	ra,0x0
 8ee:	a80080e7          	jalr	-1408(ra) # 36a <exit>

00000000000008f2 <lock_init>:

void
lock_init(struct lock_t *lock)
{
 8f2:	1141                	addi	sp,sp,-16
 8f4:	e422                	sd	s0,8(sp)
 8f6:	0800                	addi	s0,sp,16
    lock->locked = 0;
 8f8:	00052023          	sw	zero,0(a0) # 1000 <freep>
}
 8fc:	6422                	ld	s0,8(sp)
 8fe:	0141                	addi	sp,sp,16
 900:	8082                	ret

0000000000000902 <lock_acquire>:

void
lock_acquire(struct lock_t *lock)
{
 902:	1141                	addi	sp,sp,-16
 904:	e422                	sd	s0,8(sp)
 906:	0800                	addi	s0,sp,16
    while(__sync_lock_test_and_set(&lock->locked, 1)!= 0);
 908:	4705                	li	a4,1
 90a:	87ba                	mv	a5,a4
 90c:	0cf527af          	amoswap.w.aq	a5,a5,(a0)
 910:	2781                	sext.w	a5,a5
 912:	ffe5                	bnez	a5,90a <lock_acquire+0x8>
    __sync_synchronize();
 914:	0ff0000f          	fence
}
 918:	6422                	ld	s0,8(sp)
 91a:	0141                	addi	sp,sp,16
 91c:	8082                	ret

000000000000091e <lock_release>:

void
lock_release(struct lock_t *lock)
{
 91e:	1141                	addi	sp,sp,-16
 920:	e422                	sd	s0,8(sp)
 922:	0800                	addi	s0,sp,16
    __sync_synchronize();
 924:	0ff0000f          	fence
    __sync_lock_release(&lock->locked, 0);
 928:	0f50000f          	fence	iorw,ow
 92c:	0805202f          	amoswap.w	zero,zero,(a0)
}
 930:	6422                	ld	s0,8(sp)
 932:	0141                	addi	sp,sp,16
 934:	8082                	ret
