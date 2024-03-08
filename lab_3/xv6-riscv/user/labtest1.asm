
user/_labtest1:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <print_sysinfo>:
    int page_usage;
    int ppid;
};

void print_sysinfo(void)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
    int n_active_proc, n_syscalls, n_free_pages;
    n_active_proc = sysinfo(0);
   c:	4501                	li	a0,0
   e:	00000097          	auipc	ra,0x0
  12:	48c080e7          	jalr	1164(ra) # 49a <sysinfo>
  16:	84aa                	mv	s1,a0
    n_syscalls = sysinfo(1);
  18:	4505                	li	a0,1
  1a:	00000097          	auipc	ra,0x0
  1e:	480080e7          	jalr	1152(ra) # 49a <sysinfo>
  22:	892a                	mv	s2,a0
    n_free_pages = sysinfo(2);
  24:	4509                	li	a0,2
  26:	00000097          	auipc	ra,0x0
  2a:	474080e7          	jalr	1140(ra) # 49a <sysinfo>
  2e:	86aa                	mv	a3,a0
    printf("[sysinfo] active proc: %d, syscalls: %d, free pages: %d\n",
  30:	864a                	mv	a2,s2
  32:	85a6                	mv	a1,s1
  34:	00001517          	auipc	a0,0x1
  38:	98c50513          	addi	a0,a0,-1652 # 9c0 <lock_release+0x1a>
  3c:	00000097          	auipc	ra,0x0
  40:	760080e7          	jalr	1888(ra) # 79c <printf>
           n_active_proc, n_syscalls, n_free_pages);
}
  44:	60e2                	ld	ra,24(sp)
  46:	6442                	ld	s0,16(sp)
  48:	64a2                	ld	s1,8(sp)
  4a:	6902                	ld	s2,0(sp)
  4c:	6105                	addi	sp,sp,32
  4e:	8082                	ret

0000000000000050 <main>:
int main(int argc, char *argv[])
{
  50:	7119                	addi	sp,sp,-128
  52:	fc86                	sd	ra,120(sp)
  54:	f8a2                	sd	s0,112(sp)
  56:	f4a6                	sd	s1,104(sp)
  58:	f0ca                	sd	s2,96(sp)
  5a:	ecce                	sd	s3,88(sp)
  5c:	e8d2                	sd	s4,80(sp)
  5e:	e4d6                	sd	s5,72(sp)
  60:	0100                	addi	s0,sp,128
  62:	84ae                	mv	s1,a1
    int mem, n_proc, ret, proc_pid[MAX_PROC];
    if (argc < 3)
  64:	4789                	li	a5,2
  66:	02a7c063          	blt	a5,a0,86 <main+0x36>
    {
        printf("Usage: %s [MEM] [N_PROC]\n", argv[0]);
  6a:	618c                	ld	a1,0(a1)
  6c:	00001517          	auipc	a0,0x1
  70:	99450513          	addi	a0,a0,-1644 # a00 <lock_release+0x5a>
  74:	00000097          	auipc	ra,0x0
  78:	728080e7          	jalr	1832(ra) # 79c <printf>
        exit(-1);
  7c:	557d                	li	a0,-1
  7e:	00000097          	auipc	ra,0x0
  82:	374080e7          	jalr	884(ra) # 3f2 <exit>
    }
    mem = atoi(argv[1]);
  86:	6588                	ld	a0,8(a1)
  88:	00000097          	auipc	ra,0x0
  8c:	270080e7          	jalr	624(ra) # 2f8 <atoi>
  90:	892a                	mv	s2,a0
    n_proc = atoi(argv[2]);
  92:	6888                	ld	a0,16(s1)
  94:	00000097          	auipc	ra,0x0
  98:	264080e7          	jalr	612(ra) # 2f8 <atoi>
  9c:	84aa                	mv	s1,a0
    if (n_proc > MAX_PROC)
  9e:	47a9                	li	a5,10
  a0:	02a7d063          	bge	a5,a0,c0 <main+0x70>
    {
        printf("Cannot test with more than %d processes\n", MAX_PROC);
  a4:	45a9                	li	a1,10
  a6:	00001517          	auipc	a0,0x1
  aa:	97a50513          	addi	a0,a0,-1670 # a20 <lock_release+0x7a>
  ae:	00000097          	auipc	ra,0x0
  b2:	6ee080e7          	jalr	1774(ra) # 79c <printf>
        exit(-1);
  b6:	557d                	li	a0,-1
  b8:	00000097          	auipc	ra,0x0
  bc:	33a080e7          	jalr	826(ra) # 3f2 <exit>
    }
    print_sysinfo();
  c0:	00000097          	auipc	ra,0x0
  c4:	f40080e7          	jalr	-192(ra) # 0 <print_sysinfo>
    for (int i = 0; i < n_proc; i++)
  c8:	f9840a13          	addi	s4,s0,-104
  cc:	8ad2                	mv	s5,s4
  ce:	4981                	li	s3,0
  d0:	0699d463          	bge	s3,s1,138 <main+0xe8>
    {
        sleep(1);
  d4:	4505                	li	a0,1
  d6:	00000097          	auipc	ra,0x0
  da:	3ac080e7          	jalr	940(ra) # 482 <sleep>
        ret = fork();
  de:	00000097          	auipc	ra,0x0
  e2:	30c080e7          	jalr	780(ra) # 3ea <fork>
        if (ret == 0)
  e6:	e521                	bnez	a0,12e <main+0xde>
        { // child process
            struct pinfo param;
            malloc(mem); // this triggers a syscall
  e8:	0009051b          	sext.w	a0,s2
  ec:	00000097          	auipc	ra,0x0
  f0:	768080e7          	jalr	1896(ra) # 854 <malloc>
  f4:	44a9                	li	s1,10
            for (int j = 0; j < 10; j++)
                procinfo(&param); // calls 10 times
  f6:	f8840513          	addi	a0,s0,-120
  fa:	00000097          	auipc	ra,0x0
  fe:	3a8080e7          	jalr	936(ra) # 4a2 <procinfo>
            for (int j = 0; j < 10; j++)
 102:	34fd                	addiw	s1,s1,-1
 104:	f8ed                	bnez	s1,f6 <main+0xa6>
            printf("[procinfo %d] ppid: %d, syscalls: %d, page usage: %d\n",
 106:	00000097          	auipc	ra,0x0
 10a:	36c080e7          	jalr	876(ra) # 472 <getpid>
 10e:	85aa                	mv	a1,a0
 110:	f9042703          	lw	a4,-112(s0)
 114:	f8c42683          	lw	a3,-116(s0)
 118:	f9442603          	lw	a2,-108(s0)
 11c:	00001517          	auipc	a0,0x1
 120:	93450513          	addi	a0,a0,-1740 # a50 <lock_release+0xaa>
 124:	00000097          	auipc	ra,0x0
 128:	678080e7          	jalr	1656(ra) # 79c <printf>
                   getpid(), param.ppid, param.syscall_count, param.page_usage);
            while (1)
 12c:	a001                	j	12c <main+0xdc>
                ;
        }
        else
        { // parent
            proc_pid[i] = ret;
 12e:	00aaa023          	sw	a0,0(s5)
    for (int i = 0; i < n_proc; i++)
 132:	2985                	addiw	s3,s3,1
 134:	0a91                	addi	s5,s5,4
 136:	bf69                	j	d0 <main+0x80>
            continue;
        }
    }
    sleep(1);
 138:	4505                	li	a0,1
 13a:	00000097          	auipc	ra,0x0
 13e:	348080e7          	jalr	840(ra) # 482 <sleep>
    print_sysinfo();
 142:	00000097          	auipc	ra,0x0
 146:	ebe080e7          	jalr	-322(ra) # 0 <print_sysinfo>
    for (int i = 0; i < n_proc; i++)
 14a:	4901                	li	s2,0
 14c:	00995b63          	bge	s2,s1,162 <main+0x112>
        kill(proc_pid[i]);
 150:	000a2503          	lw	a0,0(s4)
 154:	00000097          	auipc	ra,0x0
 158:	2ce080e7          	jalr	718(ra) # 422 <kill>
    for (int i = 0; i < n_proc; i++)
 15c:	2905                	addiw	s2,s2,1
 15e:	0a11                	addi	s4,s4,4
 160:	b7f5                	j	14c <main+0xfc>
    exit(0);
 162:	4501                	li	a0,0
 164:	00000097          	auipc	ra,0x0
 168:	28e080e7          	jalr	654(ra) # 3f2 <exit>

000000000000016c <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 16c:	1141                	addi	sp,sp,-16
 16e:	e406                	sd	ra,8(sp)
 170:	e022                	sd	s0,0(sp)
 172:	0800                	addi	s0,sp,16
  extern int main();
  main();
 174:	00000097          	auipc	ra,0x0
 178:	edc080e7          	jalr	-292(ra) # 50 <main>
  exit(0);
 17c:	4501                	li	a0,0
 17e:	00000097          	auipc	ra,0x0
 182:	274080e7          	jalr	628(ra) # 3f2 <exit>

0000000000000186 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 186:	1141                	addi	sp,sp,-16
 188:	e422                	sd	s0,8(sp)
 18a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 18c:	87aa                	mv	a5,a0
 18e:	0585                	addi	a1,a1,1
 190:	0785                	addi	a5,a5,1
 192:	fff5c703          	lbu	a4,-1(a1)
 196:	fee78fa3          	sb	a4,-1(a5)
 19a:	fb75                	bnez	a4,18e <strcpy+0x8>
    ;
  return os;
}
 19c:	6422                	ld	s0,8(sp)
 19e:	0141                	addi	sp,sp,16
 1a0:	8082                	ret

00000000000001a2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1a2:	1141                	addi	sp,sp,-16
 1a4:	e422                	sd	s0,8(sp)
 1a6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1a8:	00054783          	lbu	a5,0(a0)
 1ac:	cb91                	beqz	a5,1c0 <strcmp+0x1e>
 1ae:	0005c703          	lbu	a4,0(a1)
 1b2:	00f71763          	bne	a4,a5,1c0 <strcmp+0x1e>
    p++, q++;
 1b6:	0505                	addi	a0,a0,1
 1b8:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1ba:	00054783          	lbu	a5,0(a0)
 1be:	fbe5                	bnez	a5,1ae <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1c0:	0005c503          	lbu	a0,0(a1)
}
 1c4:	40a7853b          	subw	a0,a5,a0
 1c8:	6422                	ld	s0,8(sp)
 1ca:	0141                	addi	sp,sp,16
 1cc:	8082                	ret

00000000000001ce <strlen>:

uint
strlen(const char *s)
{
 1ce:	1141                	addi	sp,sp,-16
 1d0:	e422                	sd	s0,8(sp)
 1d2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1d4:	00054783          	lbu	a5,0(a0)
 1d8:	cf91                	beqz	a5,1f4 <strlen+0x26>
 1da:	0505                	addi	a0,a0,1
 1dc:	87aa                	mv	a5,a0
 1de:	4685                	li	a3,1
 1e0:	9e89                	subw	a3,a3,a0
 1e2:	00f6853b          	addw	a0,a3,a5
 1e6:	0785                	addi	a5,a5,1
 1e8:	fff7c703          	lbu	a4,-1(a5)
 1ec:	fb7d                	bnez	a4,1e2 <strlen+0x14>
    ;
  return n;
}
 1ee:	6422                	ld	s0,8(sp)
 1f0:	0141                	addi	sp,sp,16
 1f2:	8082                	ret
  for(n = 0; s[n]; n++)
 1f4:	4501                	li	a0,0
 1f6:	bfe5                	j	1ee <strlen+0x20>

00000000000001f8 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1f8:	1141                	addi	sp,sp,-16
 1fa:	e422                	sd	s0,8(sp)
 1fc:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1fe:	ca19                	beqz	a2,214 <memset+0x1c>
 200:	87aa                	mv	a5,a0
 202:	1602                	slli	a2,a2,0x20
 204:	9201                	srli	a2,a2,0x20
 206:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 20a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 20e:	0785                	addi	a5,a5,1
 210:	fee79de3          	bne	a5,a4,20a <memset+0x12>
  }
  return dst;
}
 214:	6422                	ld	s0,8(sp)
 216:	0141                	addi	sp,sp,16
 218:	8082                	ret

000000000000021a <strchr>:

char*
strchr(const char *s, char c)
{
 21a:	1141                	addi	sp,sp,-16
 21c:	e422                	sd	s0,8(sp)
 21e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 220:	00054783          	lbu	a5,0(a0)
 224:	cb99                	beqz	a5,23a <strchr+0x20>
    if(*s == c)
 226:	00f58763          	beq	a1,a5,234 <strchr+0x1a>
  for(; *s; s++)
 22a:	0505                	addi	a0,a0,1
 22c:	00054783          	lbu	a5,0(a0)
 230:	fbfd                	bnez	a5,226 <strchr+0xc>
      return (char*)s;
  return 0;
 232:	4501                	li	a0,0
}
 234:	6422                	ld	s0,8(sp)
 236:	0141                	addi	sp,sp,16
 238:	8082                	ret
  return 0;
 23a:	4501                	li	a0,0
 23c:	bfe5                	j	234 <strchr+0x1a>

000000000000023e <gets>:

char*
gets(char *buf, int max)
{
 23e:	711d                	addi	sp,sp,-96
 240:	ec86                	sd	ra,88(sp)
 242:	e8a2                	sd	s0,80(sp)
 244:	e4a6                	sd	s1,72(sp)
 246:	e0ca                	sd	s2,64(sp)
 248:	fc4e                	sd	s3,56(sp)
 24a:	f852                	sd	s4,48(sp)
 24c:	f456                	sd	s5,40(sp)
 24e:	f05a                	sd	s6,32(sp)
 250:	ec5e                	sd	s7,24(sp)
 252:	1080                	addi	s0,sp,96
 254:	8baa                	mv	s7,a0
 256:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 258:	892a                	mv	s2,a0
 25a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 25c:	4aa9                	li	s5,10
 25e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 260:	89a6                	mv	s3,s1
 262:	2485                	addiw	s1,s1,1
 264:	0344d863          	bge	s1,s4,294 <gets+0x56>
    cc = read(0, &c, 1);
 268:	4605                	li	a2,1
 26a:	faf40593          	addi	a1,s0,-81
 26e:	4501                	li	a0,0
 270:	00000097          	auipc	ra,0x0
 274:	19a080e7          	jalr	410(ra) # 40a <read>
    if(cc < 1)
 278:	00a05e63          	blez	a0,294 <gets+0x56>
    buf[i++] = c;
 27c:	faf44783          	lbu	a5,-81(s0)
 280:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 284:	01578763          	beq	a5,s5,292 <gets+0x54>
 288:	0905                	addi	s2,s2,1
 28a:	fd679be3          	bne	a5,s6,260 <gets+0x22>
  for(i=0; i+1 < max; ){
 28e:	89a6                	mv	s3,s1
 290:	a011                	j	294 <gets+0x56>
 292:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 294:	99de                	add	s3,s3,s7
 296:	00098023          	sb	zero,0(s3)
  return buf;
}
 29a:	855e                	mv	a0,s7
 29c:	60e6                	ld	ra,88(sp)
 29e:	6446                	ld	s0,80(sp)
 2a0:	64a6                	ld	s1,72(sp)
 2a2:	6906                	ld	s2,64(sp)
 2a4:	79e2                	ld	s3,56(sp)
 2a6:	7a42                	ld	s4,48(sp)
 2a8:	7aa2                	ld	s5,40(sp)
 2aa:	7b02                	ld	s6,32(sp)
 2ac:	6be2                	ld	s7,24(sp)
 2ae:	6125                	addi	sp,sp,96
 2b0:	8082                	ret

00000000000002b2 <stat>:

int
stat(const char *n, struct stat *st)
{
 2b2:	1101                	addi	sp,sp,-32
 2b4:	ec06                	sd	ra,24(sp)
 2b6:	e822                	sd	s0,16(sp)
 2b8:	e426                	sd	s1,8(sp)
 2ba:	e04a                	sd	s2,0(sp)
 2bc:	1000                	addi	s0,sp,32
 2be:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2c0:	4581                	li	a1,0
 2c2:	00000097          	auipc	ra,0x0
 2c6:	170080e7          	jalr	368(ra) # 432 <open>
  if(fd < 0)
 2ca:	02054563          	bltz	a0,2f4 <stat+0x42>
 2ce:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2d0:	85ca                	mv	a1,s2
 2d2:	00000097          	auipc	ra,0x0
 2d6:	178080e7          	jalr	376(ra) # 44a <fstat>
 2da:	892a                	mv	s2,a0
  close(fd);
 2dc:	8526                	mv	a0,s1
 2de:	00000097          	auipc	ra,0x0
 2e2:	13c080e7          	jalr	316(ra) # 41a <close>
  return r;
}
 2e6:	854a                	mv	a0,s2
 2e8:	60e2                	ld	ra,24(sp)
 2ea:	6442                	ld	s0,16(sp)
 2ec:	64a2                	ld	s1,8(sp)
 2ee:	6902                	ld	s2,0(sp)
 2f0:	6105                	addi	sp,sp,32
 2f2:	8082                	ret
    return -1;
 2f4:	597d                	li	s2,-1
 2f6:	bfc5                	j	2e6 <stat+0x34>

00000000000002f8 <atoi>:

int
atoi(const char *s)
{
 2f8:	1141                	addi	sp,sp,-16
 2fa:	e422                	sd	s0,8(sp)
 2fc:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2fe:	00054683          	lbu	a3,0(a0)
 302:	fd06879b          	addiw	a5,a3,-48
 306:	0ff7f793          	zext.b	a5,a5
 30a:	4625                	li	a2,9
 30c:	02f66863          	bltu	a2,a5,33c <atoi+0x44>
 310:	872a                	mv	a4,a0
  n = 0;
 312:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 314:	0705                	addi	a4,a4,1
 316:	0025179b          	slliw	a5,a0,0x2
 31a:	9fa9                	addw	a5,a5,a0
 31c:	0017979b          	slliw	a5,a5,0x1
 320:	9fb5                	addw	a5,a5,a3
 322:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 326:	00074683          	lbu	a3,0(a4)
 32a:	fd06879b          	addiw	a5,a3,-48
 32e:	0ff7f793          	zext.b	a5,a5
 332:	fef671e3          	bgeu	a2,a5,314 <atoi+0x1c>
  return n;
}
 336:	6422                	ld	s0,8(sp)
 338:	0141                	addi	sp,sp,16
 33a:	8082                	ret
  n = 0;
 33c:	4501                	li	a0,0
 33e:	bfe5                	j	336 <atoi+0x3e>

0000000000000340 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 340:	1141                	addi	sp,sp,-16
 342:	e422                	sd	s0,8(sp)
 344:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 346:	02b57463          	bgeu	a0,a1,36e <memmove+0x2e>
    while(n-- > 0)
 34a:	00c05f63          	blez	a2,368 <memmove+0x28>
 34e:	1602                	slli	a2,a2,0x20
 350:	9201                	srli	a2,a2,0x20
 352:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 356:	872a                	mv	a4,a0
      *dst++ = *src++;
 358:	0585                	addi	a1,a1,1
 35a:	0705                	addi	a4,a4,1
 35c:	fff5c683          	lbu	a3,-1(a1)
 360:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 364:	fee79ae3          	bne	a5,a4,358 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 368:	6422                	ld	s0,8(sp)
 36a:	0141                	addi	sp,sp,16
 36c:	8082                	ret
    dst += n;
 36e:	00c50733          	add	a4,a0,a2
    src += n;
 372:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 374:	fec05ae3          	blez	a2,368 <memmove+0x28>
 378:	fff6079b          	addiw	a5,a2,-1
 37c:	1782                	slli	a5,a5,0x20
 37e:	9381                	srli	a5,a5,0x20
 380:	fff7c793          	not	a5,a5
 384:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 386:	15fd                	addi	a1,a1,-1
 388:	177d                	addi	a4,a4,-1
 38a:	0005c683          	lbu	a3,0(a1)
 38e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 392:	fee79ae3          	bne	a5,a4,386 <memmove+0x46>
 396:	bfc9                	j	368 <memmove+0x28>

0000000000000398 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 398:	1141                	addi	sp,sp,-16
 39a:	e422                	sd	s0,8(sp)
 39c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 39e:	ca05                	beqz	a2,3ce <memcmp+0x36>
 3a0:	fff6069b          	addiw	a3,a2,-1
 3a4:	1682                	slli	a3,a3,0x20
 3a6:	9281                	srli	a3,a3,0x20
 3a8:	0685                	addi	a3,a3,1
 3aa:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3ac:	00054783          	lbu	a5,0(a0)
 3b0:	0005c703          	lbu	a4,0(a1)
 3b4:	00e79863          	bne	a5,a4,3c4 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3b8:	0505                	addi	a0,a0,1
    p2++;
 3ba:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3bc:	fed518e3          	bne	a0,a3,3ac <memcmp+0x14>
  }
  return 0;
 3c0:	4501                	li	a0,0
 3c2:	a019                	j	3c8 <memcmp+0x30>
      return *p1 - *p2;
 3c4:	40e7853b          	subw	a0,a5,a4
}
 3c8:	6422                	ld	s0,8(sp)
 3ca:	0141                	addi	sp,sp,16
 3cc:	8082                	ret
  return 0;
 3ce:	4501                	li	a0,0
 3d0:	bfe5                	j	3c8 <memcmp+0x30>

00000000000003d2 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3d2:	1141                	addi	sp,sp,-16
 3d4:	e406                	sd	ra,8(sp)
 3d6:	e022                	sd	s0,0(sp)
 3d8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3da:	00000097          	auipc	ra,0x0
 3de:	f66080e7          	jalr	-154(ra) # 340 <memmove>
}
 3e2:	60a2                	ld	ra,8(sp)
 3e4:	6402                	ld	s0,0(sp)
 3e6:	0141                	addi	sp,sp,16
 3e8:	8082                	ret

00000000000003ea <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3ea:	4885                	li	a7,1
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3f2:	4889                	li	a7,2
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <wait>:
.global wait
wait:
 li a7, SYS_wait
 3fa:	488d                	li	a7,3
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 402:	4891                	li	a7,4
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <read>:
.global read
read:
 li a7, SYS_read
 40a:	4895                	li	a7,5
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <write>:
.global write
write:
 li a7, SYS_write
 412:	48c1                	li	a7,16
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <close>:
.global close
close:
 li a7, SYS_close
 41a:	48d5                	li	a7,21
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <kill>:
.global kill
kill:
 li a7, SYS_kill
 422:	4899                	li	a7,6
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <exec>:
.global exec
exec:
 li a7, SYS_exec
 42a:	489d                	li	a7,7
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <open>:
.global open
open:
 li a7, SYS_open
 432:	48bd                	li	a7,15
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 43a:	48c5                	li	a7,17
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 442:	48c9                	li	a7,18
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 44a:	48a1                	li	a7,8
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <link>:
.global link
link:
 li a7, SYS_link
 452:	48cd                	li	a7,19
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 45a:	48d1                	li	a7,20
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 462:	48a5                	li	a7,9
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <dup>:
.global dup
dup:
 li a7, SYS_dup
 46a:	48a9                	li	a7,10
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 472:	48ad                	li	a7,11
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 47a:	48b1                	li	a7,12
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 482:	48b5                	li	a7,13
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 48a:	48b9                	li	a7,14
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <hello>:
.global hello
hello:
 li a7, SYS_hello
 492:	48d9                	li	a7,22
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <sysinfo>:
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo
 49a:	48dd                	li	a7,23
 ecall
 49c:	00000073          	ecall
 ret
 4a0:	8082                	ret

00000000000004a2 <procinfo>:
.global procinfo
procinfo:
 li a7, SYS_procinfo
 4a2:	48e1                	li	a7,24
 ecall
 4a4:	00000073          	ecall
 ret
 4a8:	8082                	ret

00000000000004aa <sched_tickets>:
.global sched_tickets
sched_tickets:
 li a7, SYS_sched_tickets
 4aa:	48e9                	li	a7,26
 ecall
 4ac:	00000073          	ecall
 ret
 4b0:	8082                	ret

00000000000004b2 <sched_statistics>:
.global sched_statistics
sched_statistics:
 li a7, SYS_sched_statistics
 4b2:	48e5                	li	a7,25
 ecall
 4b4:	00000073          	ecall
 ret
 4b8:	8082                	ret

00000000000004ba <clone>:
.global clone
clone:
 li a7, SYS_clone
 4ba:	48ed                	li	a7,27
 ecall
 4bc:	00000073          	ecall
 ret
 4c0:	8082                	ret

00000000000004c2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4c2:	1101                	addi	sp,sp,-32
 4c4:	ec06                	sd	ra,24(sp)
 4c6:	e822                	sd	s0,16(sp)
 4c8:	1000                	addi	s0,sp,32
 4ca:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4ce:	4605                	li	a2,1
 4d0:	fef40593          	addi	a1,s0,-17
 4d4:	00000097          	auipc	ra,0x0
 4d8:	f3e080e7          	jalr	-194(ra) # 412 <write>
}
 4dc:	60e2                	ld	ra,24(sp)
 4de:	6442                	ld	s0,16(sp)
 4e0:	6105                	addi	sp,sp,32
 4e2:	8082                	ret

00000000000004e4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4e4:	7139                	addi	sp,sp,-64
 4e6:	fc06                	sd	ra,56(sp)
 4e8:	f822                	sd	s0,48(sp)
 4ea:	f426                	sd	s1,40(sp)
 4ec:	f04a                	sd	s2,32(sp)
 4ee:	ec4e                	sd	s3,24(sp)
 4f0:	0080                	addi	s0,sp,64
 4f2:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4f4:	c299                	beqz	a3,4fa <printint+0x16>
 4f6:	0805c963          	bltz	a1,588 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4fa:	2581                	sext.w	a1,a1
  neg = 0;
 4fc:	4881                	li	a7,0
 4fe:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 502:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 504:	2601                	sext.w	a2,a2
 506:	00000517          	auipc	a0,0x0
 50a:	5e250513          	addi	a0,a0,1506 # ae8 <digits>
 50e:	883a                	mv	a6,a4
 510:	2705                	addiw	a4,a4,1
 512:	02c5f7bb          	remuw	a5,a1,a2
 516:	1782                	slli	a5,a5,0x20
 518:	9381                	srli	a5,a5,0x20
 51a:	97aa                	add	a5,a5,a0
 51c:	0007c783          	lbu	a5,0(a5)
 520:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 524:	0005879b          	sext.w	a5,a1
 528:	02c5d5bb          	divuw	a1,a1,a2
 52c:	0685                	addi	a3,a3,1
 52e:	fec7f0e3          	bgeu	a5,a2,50e <printint+0x2a>
  if(neg)
 532:	00088c63          	beqz	a7,54a <printint+0x66>
    buf[i++] = '-';
 536:	fd070793          	addi	a5,a4,-48
 53a:	00878733          	add	a4,a5,s0
 53e:	02d00793          	li	a5,45
 542:	fef70823          	sb	a5,-16(a4)
 546:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 54a:	02e05863          	blez	a4,57a <printint+0x96>
 54e:	fc040793          	addi	a5,s0,-64
 552:	00e78933          	add	s2,a5,a4
 556:	fff78993          	addi	s3,a5,-1
 55a:	99ba                	add	s3,s3,a4
 55c:	377d                	addiw	a4,a4,-1
 55e:	1702                	slli	a4,a4,0x20
 560:	9301                	srli	a4,a4,0x20
 562:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 566:	fff94583          	lbu	a1,-1(s2)
 56a:	8526                	mv	a0,s1
 56c:	00000097          	auipc	ra,0x0
 570:	f56080e7          	jalr	-170(ra) # 4c2 <putc>
  while(--i >= 0)
 574:	197d                	addi	s2,s2,-1
 576:	ff3918e3          	bne	s2,s3,566 <printint+0x82>
}
 57a:	70e2                	ld	ra,56(sp)
 57c:	7442                	ld	s0,48(sp)
 57e:	74a2                	ld	s1,40(sp)
 580:	7902                	ld	s2,32(sp)
 582:	69e2                	ld	s3,24(sp)
 584:	6121                	addi	sp,sp,64
 586:	8082                	ret
    x = -xx;
 588:	40b005bb          	negw	a1,a1
    neg = 1;
 58c:	4885                	li	a7,1
    x = -xx;
 58e:	bf85                	j	4fe <printint+0x1a>

0000000000000590 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 590:	7119                	addi	sp,sp,-128
 592:	fc86                	sd	ra,120(sp)
 594:	f8a2                	sd	s0,112(sp)
 596:	f4a6                	sd	s1,104(sp)
 598:	f0ca                	sd	s2,96(sp)
 59a:	ecce                	sd	s3,88(sp)
 59c:	e8d2                	sd	s4,80(sp)
 59e:	e4d6                	sd	s5,72(sp)
 5a0:	e0da                	sd	s6,64(sp)
 5a2:	fc5e                	sd	s7,56(sp)
 5a4:	f862                	sd	s8,48(sp)
 5a6:	f466                	sd	s9,40(sp)
 5a8:	f06a                	sd	s10,32(sp)
 5aa:	ec6e                	sd	s11,24(sp)
 5ac:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5ae:	0005c903          	lbu	s2,0(a1)
 5b2:	18090f63          	beqz	s2,750 <vprintf+0x1c0>
 5b6:	8aaa                	mv	s5,a0
 5b8:	8b32                	mv	s6,a2
 5ba:	00158493          	addi	s1,a1,1
  state = 0;
 5be:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5c0:	02500a13          	li	s4,37
 5c4:	4c55                	li	s8,21
 5c6:	00000c97          	auipc	s9,0x0
 5ca:	4cac8c93          	addi	s9,s9,1226 # a90 <lock_release+0xea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5ce:	02800d93          	li	s11,40
  putc(fd, 'x');
 5d2:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5d4:	00000b97          	auipc	s7,0x0
 5d8:	514b8b93          	addi	s7,s7,1300 # ae8 <digits>
 5dc:	a839                	j	5fa <vprintf+0x6a>
        putc(fd, c);
 5de:	85ca                	mv	a1,s2
 5e0:	8556                	mv	a0,s5
 5e2:	00000097          	auipc	ra,0x0
 5e6:	ee0080e7          	jalr	-288(ra) # 4c2 <putc>
 5ea:	a019                	j	5f0 <vprintf+0x60>
    } else if(state == '%'){
 5ec:	01498d63          	beq	s3,s4,606 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 5f0:	0485                	addi	s1,s1,1
 5f2:	fff4c903          	lbu	s2,-1(s1)
 5f6:	14090d63          	beqz	s2,750 <vprintf+0x1c0>
    if(state == 0){
 5fa:	fe0999e3          	bnez	s3,5ec <vprintf+0x5c>
      if(c == '%'){
 5fe:	ff4910e3          	bne	s2,s4,5de <vprintf+0x4e>
        state = '%';
 602:	89d2                	mv	s3,s4
 604:	b7f5                	j	5f0 <vprintf+0x60>
      if(c == 'd'){
 606:	11490c63          	beq	s2,s4,71e <vprintf+0x18e>
 60a:	f9d9079b          	addiw	a5,s2,-99
 60e:	0ff7f793          	zext.b	a5,a5
 612:	10fc6e63          	bltu	s8,a5,72e <vprintf+0x19e>
 616:	f9d9079b          	addiw	a5,s2,-99
 61a:	0ff7f713          	zext.b	a4,a5
 61e:	10ec6863          	bltu	s8,a4,72e <vprintf+0x19e>
 622:	00271793          	slli	a5,a4,0x2
 626:	97e6                	add	a5,a5,s9
 628:	439c                	lw	a5,0(a5)
 62a:	97e6                	add	a5,a5,s9
 62c:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 62e:	008b0913          	addi	s2,s6,8
 632:	4685                	li	a3,1
 634:	4629                	li	a2,10
 636:	000b2583          	lw	a1,0(s6)
 63a:	8556                	mv	a0,s5
 63c:	00000097          	auipc	ra,0x0
 640:	ea8080e7          	jalr	-344(ra) # 4e4 <printint>
 644:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 646:	4981                	li	s3,0
 648:	b765                	j	5f0 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 64a:	008b0913          	addi	s2,s6,8
 64e:	4681                	li	a3,0
 650:	4629                	li	a2,10
 652:	000b2583          	lw	a1,0(s6)
 656:	8556                	mv	a0,s5
 658:	00000097          	auipc	ra,0x0
 65c:	e8c080e7          	jalr	-372(ra) # 4e4 <printint>
 660:	8b4a                	mv	s6,s2
      state = 0;
 662:	4981                	li	s3,0
 664:	b771                	j	5f0 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 666:	008b0913          	addi	s2,s6,8
 66a:	4681                	li	a3,0
 66c:	866a                	mv	a2,s10
 66e:	000b2583          	lw	a1,0(s6)
 672:	8556                	mv	a0,s5
 674:	00000097          	auipc	ra,0x0
 678:	e70080e7          	jalr	-400(ra) # 4e4 <printint>
 67c:	8b4a                	mv	s6,s2
      state = 0;
 67e:	4981                	li	s3,0
 680:	bf85                	j	5f0 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 682:	008b0793          	addi	a5,s6,8
 686:	f8f43423          	sd	a5,-120(s0)
 68a:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 68e:	03000593          	li	a1,48
 692:	8556                	mv	a0,s5
 694:	00000097          	auipc	ra,0x0
 698:	e2e080e7          	jalr	-466(ra) # 4c2 <putc>
  putc(fd, 'x');
 69c:	07800593          	li	a1,120
 6a0:	8556                	mv	a0,s5
 6a2:	00000097          	auipc	ra,0x0
 6a6:	e20080e7          	jalr	-480(ra) # 4c2 <putc>
 6aa:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6ac:	03c9d793          	srli	a5,s3,0x3c
 6b0:	97de                	add	a5,a5,s7
 6b2:	0007c583          	lbu	a1,0(a5)
 6b6:	8556                	mv	a0,s5
 6b8:	00000097          	auipc	ra,0x0
 6bc:	e0a080e7          	jalr	-502(ra) # 4c2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6c0:	0992                	slli	s3,s3,0x4
 6c2:	397d                	addiw	s2,s2,-1
 6c4:	fe0914e3          	bnez	s2,6ac <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 6c8:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6cc:	4981                	li	s3,0
 6ce:	b70d                	j	5f0 <vprintf+0x60>
        s = va_arg(ap, char*);
 6d0:	008b0913          	addi	s2,s6,8
 6d4:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 6d8:	02098163          	beqz	s3,6fa <vprintf+0x16a>
        while(*s != 0){
 6dc:	0009c583          	lbu	a1,0(s3)
 6e0:	c5ad                	beqz	a1,74a <vprintf+0x1ba>
          putc(fd, *s);
 6e2:	8556                	mv	a0,s5
 6e4:	00000097          	auipc	ra,0x0
 6e8:	dde080e7          	jalr	-546(ra) # 4c2 <putc>
          s++;
 6ec:	0985                	addi	s3,s3,1
        while(*s != 0){
 6ee:	0009c583          	lbu	a1,0(s3)
 6f2:	f9e5                	bnez	a1,6e2 <vprintf+0x152>
        s = va_arg(ap, char*);
 6f4:	8b4a                	mv	s6,s2
      state = 0;
 6f6:	4981                	li	s3,0
 6f8:	bde5                	j	5f0 <vprintf+0x60>
          s = "(null)";
 6fa:	00000997          	auipc	s3,0x0
 6fe:	38e98993          	addi	s3,s3,910 # a88 <lock_release+0xe2>
        while(*s != 0){
 702:	85ee                	mv	a1,s11
 704:	bff9                	j	6e2 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 706:	008b0913          	addi	s2,s6,8
 70a:	000b4583          	lbu	a1,0(s6)
 70e:	8556                	mv	a0,s5
 710:	00000097          	auipc	ra,0x0
 714:	db2080e7          	jalr	-590(ra) # 4c2 <putc>
 718:	8b4a                	mv	s6,s2
      state = 0;
 71a:	4981                	li	s3,0
 71c:	bdd1                	j	5f0 <vprintf+0x60>
        putc(fd, c);
 71e:	85d2                	mv	a1,s4
 720:	8556                	mv	a0,s5
 722:	00000097          	auipc	ra,0x0
 726:	da0080e7          	jalr	-608(ra) # 4c2 <putc>
      state = 0;
 72a:	4981                	li	s3,0
 72c:	b5d1                	j	5f0 <vprintf+0x60>
        putc(fd, '%');
 72e:	85d2                	mv	a1,s4
 730:	8556                	mv	a0,s5
 732:	00000097          	auipc	ra,0x0
 736:	d90080e7          	jalr	-624(ra) # 4c2 <putc>
        putc(fd, c);
 73a:	85ca                	mv	a1,s2
 73c:	8556                	mv	a0,s5
 73e:	00000097          	auipc	ra,0x0
 742:	d84080e7          	jalr	-636(ra) # 4c2 <putc>
      state = 0;
 746:	4981                	li	s3,0
 748:	b565                	j	5f0 <vprintf+0x60>
        s = va_arg(ap, char*);
 74a:	8b4a                	mv	s6,s2
      state = 0;
 74c:	4981                	li	s3,0
 74e:	b54d                	j	5f0 <vprintf+0x60>
    }
  }
}
 750:	70e6                	ld	ra,120(sp)
 752:	7446                	ld	s0,112(sp)
 754:	74a6                	ld	s1,104(sp)
 756:	7906                	ld	s2,96(sp)
 758:	69e6                	ld	s3,88(sp)
 75a:	6a46                	ld	s4,80(sp)
 75c:	6aa6                	ld	s5,72(sp)
 75e:	6b06                	ld	s6,64(sp)
 760:	7be2                	ld	s7,56(sp)
 762:	7c42                	ld	s8,48(sp)
 764:	7ca2                	ld	s9,40(sp)
 766:	7d02                	ld	s10,32(sp)
 768:	6de2                	ld	s11,24(sp)
 76a:	6109                	addi	sp,sp,128
 76c:	8082                	ret

000000000000076e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 76e:	715d                	addi	sp,sp,-80
 770:	ec06                	sd	ra,24(sp)
 772:	e822                	sd	s0,16(sp)
 774:	1000                	addi	s0,sp,32
 776:	e010                	sd	a2,0(s0)
 778:	e414                	sd	a3,8(s0)
 77a:	e818                	sd	a4,16(s0)
 77c:	ec1c                	sd	a5,24(s0)
 77e:	03043023          	sd	a6,32(s0)
 782:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 786:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 78a:	8622                	mv	a2,s0
 78c:	00000097          	auipc	ra,0x0
 790:	e04080e7          	jalr	-508(ra) # 590 <vprintf>
}
 794:	60e2                	ld	ra,24(sp)
 796:	6442                	ld	s0,16(sp)
 798:	6161                	addi	sp,sp,80
 79a:	8082                	ret

000000000000079c <printf>:

void
printf(const char *fmt, ...)
{
 79c:	711d                	addi	sp,sp,-96
 79e:	ec06                	sd	ra,24(sp)
 7a0:	e822                	sd	s0,16(sp)
 7a2:	1000                	addi	s0,sp,32
 7a4:	e40c                	sd	a1,8(s0)
 7a6:	e810                	sd	a2,16(s0)
 7a8:	ec14                	sd	a3,24(s0)
 7aa:	f018                	sd	a4,32(s0)
 7ac:	f41c                	sd	a5,40(s0)
 7ae:	03043823          	sd	a6,48(s0)
 7b2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7b6:	00840613          	addi	a2,s0,8
 7ba:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7be:	85aa                	mv	a1,a0
 7c0:	4505                	li	a0,1
 7c2:	00000097          	auipc	ra,0x0
 7c6:	dce080e7          	jalr	-562(ra) # 590 <vprintf>
}
 7ca:	60e2                	ld	ra,24(sp)
 7cc:	6442                	ld	s0,16(sp)
 7ce:	6125                	addi	sp,sp,96
 7d0:	8082                	ret

00000000000007d2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7d2:	1141                	addi	sp,sp,-16
 7d4:	e422                	sd	s0,8(sp)
 7d6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7d8:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7dc:	00001797          	auipc	a5,0x1
 7e0:	8247b783          	ld	a5,-2012(a5) # 1000 <freep>
 7e4:	a02d                	j	80e <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7e6:	4618                	lw	a4,8(a2)
 7e8:	9f2d                	addw	a4,a4,a1
 7ea:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7ee:	6398                	ld	a4,0(a5)
 7f0:	6310                	ld	a2,0(a4)
 7f2:	a83d                	j	830 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7f4:	ff852703          	lw	a4,-8(a0)
 7f8:	9f31                	addw	a4,a4,a2
 7fa:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7fc:	ff053683          	ld	a3,-16(a0)
 800:	a091                	j	844 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 802:	6398                	ld	a4,0(a5)
 804:	00e7e463          	bltu	a5,a4,80c <free+0x3a>
 808:	00e6ea63          	bltu	a3,a4,81c <free+0x4a>
{
 80c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 80e:	fed7fae3          	bgeu	a5,a3,802 <free+0x30>
 812:	6398                	ld	a4,0(a5)
 814:	00e6e463          	bltu	a3,a4,81c <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 818:	fee7eae3          	bltu	a5,a4,80c <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 81c:	ff852583          	lw	a1,-8(a0)
 820:	6390                	ld	a2,0(a5)
 822:	02059813          	slli	a6,a1,0x20
 826:	01c85713          	srli	a4,a6,0x1c
 82a:	9736                	add	a4,a4,a3
 82c:	fae60de3          	beq	a2,a4,7e6 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 830:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 834:	4790                	lw	a2,8(a5)
 836:	02061593          	slli	a1,a2,0x20
 83a:	01c5d713          	srli	a4,a1,0x1c
 83e:	973e                	add	a4,a4,a5
 840:	fae68ae3          	beq	a3,a4,7f4 <free+0x22>
    p->s.ptr = bp->s.ptr;
 844:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 846:	00000717          	auipc	a4,0x0
 84a:	7af73d23          	sd	a5,1978(a4) # 1000 <freep>
}
 84e:	6422                	ld	s0,8(sp)
 850:	0141                	addi	sp,sp,16
 852:	8082                	ret

0000000000000854 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 854:	7139                	addi	sp,sp,-64
 856:	fc06                	sd	ra,56(sp)
 858:	f822                	sd	s0,48(sp)
 85a:	f426                	sd	s1,40(sp)
 85c:	f04a                	sd	s2,32(sp)
 85e:	ec4e                	sd	s3,24(sp)
 860:	e852                	sd	s4,16(sp)
 862:	e456                	sd	s5,8(sp)
 864:	e05a                	sd	s6,0(sp)
 866:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 868:	02051493          	slli	s1,a0,0x20
 86c:	9081                	srli	s1,s1,0x20
 86e:	04bd                	addi	s1,s1,15
 870:	8091                	srli	s1,s1,0x4
 872:	0014899b          	addiw	s3,s1,1
 876:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 878:	00000517          	auipc	a0,0x0
 87c:	78853503          	ld	a0,1928(a0) # 1000 <freep>
 880:	c515                	beqz	a0,8ac <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 882:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 884:	4798                	lw	a4,8(a5)
 886:	02977f63          	bgeu	a4,s1,8c4 <malloc+0x70>
 88a:	8a4e                	mv	s4,s3
 88c:	0009871b          	sext.w	a4,s3
 890:	6685                	lui	a3,0x1
 892:	00d77363          	bgeu	a4,a3,898 <malloc+0x44>
 896:	6a05                	lui	s4,0x1
 898:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 89c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8a0:	00000917          	auipc	s2,0x0
 8a4:	76090913          	addi	s2,s2,1888 # 1000 <freep>
  if(p == (char*)-1)
 8a8:	5afd                	li	s5,-1
 8aa:	a895                	j	91e <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 8ac:	00000797          	auipc	a5,0x0
 8b0:	76478793          	addi	a5,a5,1892 # 1010 <base>
 8b4:	00000717          	auipc	a4,0x0
 8b8:	74f73623          	sd	a5,1868(a4) # 1000 <freep>
 8bc:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8be:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8c2:	b7e1                	j	88a <malloc+0x36>
      if(p->s.size == nunits)
 8c4:	02e48c63          	beq	s1,a4,8fc <malloc+0xa8>
        p->s.size -= nunits;
 8c8:	4137073b          	subw	a4,a4,s3
 8cc:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8ce:	02071693          	slli	a3,a4,0x20
 8d2:	01c6d713          	srli	a4,a3,0x1c
 8d6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8d8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8dc:	00000717          	auipc	a4,0x0
 8e0:	72a73223          	sd	a0,1828(a4) # 1000 <freep>
      return (void*)(p + 1);
 8e4:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8e8:	70e2                	ld	ra,56(sp)
 8ea:	7442                	ld	s0,48(sp)
 8ec:	74a2                	ld	s1,40(sp)
 8ee:	7902                	ld	s2,32(sp)
 8f0:	69e2                	ld	s3,24(sp)
 8f2:	6a42                	ld	s4,16(sp)
 8f4:	6aa2                	ld	s5,8(sp)
 8f6:	6b02                	ld	s6,0(sp)
 8f8:	6121                	addi	sp,sp,64
 8fa:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8fc:	6398                	ld	a4,0(a5)
 8fe:	e118                	sd	a4,0(a0)
 900:	bff1                	j	8dc <malloc+0x88>
  hp->s.size = nu;
 902:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 906:	0541                	addi	a0,a0,16
 908:	00000097          	auipc	ra,0x0
 90c:	eca080e7          	jalr	-310(ra) # 7d2 <free>
  return freep;
 910:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 914:	d971                	beqz	a0,8e8 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 916:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 918:	4798                	lw	a4,8(a5)
 91a:	fa9775e3          	bgeu	a4,s1,8c4 <malloc+0x70>
    if(p == freep)
 91e:	00093703          	ld	a4,0(s2)
 922:	853e                	mv	a0,a5
 924:	fef719e3          	bne	a4,a5,916 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 928:	8552                	mv	a0,s4
 92a:	00000097          	auipc	ra,0x0
 92e:	b50080e7          	jalr	-1200(ra) # 47a <sbrk>
  if(p == (char*)-1)
 932:	fd5518e3          	bne	a0,s5,902 <malloc+0xae>
        return 0;
 936:	4501                	li	a0,0
 938:	bf45                	j	8e8 <malloc+0x94>

000000000000093a <thread_create>:
#include "user/user.h"
#include "user/thread.h"

int
thread_create(void *(start_routine)(void*), void *arg)
{
 93a:	1101                	addi	sp,sp,-32
 93c:	ec06                	sd	ra,24(sp)
 93e:	e822                	sd	s0,16(sp)
 940:	e426                	sd	s1,8(sp)
 942:	e04a                	sd	s2,0(sp)
 944:	1000                	addi	s0,sp,32
 946:	84aa                	mv	s1,a0
 948:	892e                	mv	s2,a1
    int pg_size = 4096*sizeof(void);
    void* stack = (void*)malloc(pg_size);
 94a:	6505                	lui	a0,0x1
 94c:	00000097          	auipc	ra,0x0
 950:	f08080e7          	jalr	-248(ra) # 854 <malloc>
    int t_id = clone(stack);
 954:	00000097          	auipc	ra,0x0
 958:	b66080e7          	jalr	-1178(ra) # 4ba <clone>
    if(t_id==0) {
 95c:	c901                	beqz	a0,96c <thread_create+0x32>
        (*start_routine)(arg);
        exit(0);
    }
    return 0;
}
 95e:	4501                	li	a0,0
 960:	60e2                	ld	ra,24(sp)
 962:	6442                	ld	s0,16(sp)
 964:	64a2                	ld	s1,8(sp)
 966:	6902                	ld	s2,0(sp)
 968:	6105                	addi	sp,sp,32
 96a:	8082                	ret
        (*start_routine)(arg);
 96c:	854a                	mv	a0,s2
 96e:	9482                	jalr	s1
        exit(0);
 970:	4501                	li	a0,0
 972:	00000097          	auipc	ra,0x0
 976:	a80080e7          	jalr	-1408(ra) # 3f2 <exit>

000000000000097a <lock_init>:

void
lock_init(struct lock_t *lock)
{
 97a:	1141                	addi	sp,sp,-16
 97c:	e422                	sd	s0,8(sp)
 97e:	0800                	addi	s0,sp,16
    lock->locked = 0;
 980:	00052023          	sw	zero,0(a0) # 1000 <freep>
}
 984:	6422                	ld	s0,8(sp)
 986:	0141                	addi	sp,sp,16
 988:	8082                	ret

000000000000098a <lock_acquire>:

void
lock_acquire(struct lock_t *lock)
{
 98a:	1141                	addi	sp,sp,-16
 98c:	e422                	sd	s0,8(sp)
 98e:	0800                	addi	s0,sp,16
    while(__sync_lock_test_and_set(&lock->locked, 1)!= 0);
 990:	4705                	li	a4,1
 992:	87ba                	mv	a5,a4
 994:	0cf527af          	amoswap.w.aq	a5,a5,(a0)
 998:	2781                	sext.w	a5,a5
 99a:	ffe5                	bnez	a5,992 <lock_acquire+0x8>
    __sync_synchronize();
 99c:	0ff0000f          	fence
}
 9a0:	6422                	ld	s0,8(sp)
 9a2:	0141                	addi	sp,sp,16
 9a4:	8082                	ret

00000000000009a6 <lock_release>:

void
lock_release(struct lock_t *lock)
{
 9a6:	1141                	addi	sp,sp,-16
 9a8:	e422                	sd	s0,8(sp)
 9aa:	0800                	addi	s0,sp,16
    __sync_synchronize();
 9ac:	0ff0000f          	fence
    __sync_lock_release(&lock->locked, 0);
 9b0:	0f50000f          	fence	iorw,ow
 9b4:	0805202f          	amoswap.w	zero,zero,(a0)
}
 9b8:	6422                	ld	s0,8(sp)
 9ba:	0141                	addi	sp,sp,16
 9bc:	8082                	ret
