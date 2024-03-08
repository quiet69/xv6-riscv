
user/_grind:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <do_rand>:
#include "kernel/riscv.h"

// from FreeBSD.
int
do_rand(unsigned long *ctx)
{
       0:	1141                	addi	sp,sp,-16
       2:	e422                	sd	s0,8(sp)
       4:	0800                	addi	s0,sp,16
 * October 1988, p. 1195.
 */
    long hi, lo, x;

    /* Transform to [1, 0x7ffffffe] range. */
    x = (*ctx % 0x7ffffffe) + 1;
       6:	611c                	ld	a5,0(a0)
       8:	80000737          	lui	a4,0x80000
       c:	ffe74713          	xori	a4,a4,-2
      10:	02e7f7b3          	remu	a5,a5,a4
      14:	0785                	addi	a5,a5,1
    hi = x / 127773;
    lo = x % 127773;
      16:	66fd                	lui	a3,0x1f
      18:	31d68693          	addi	a3,a3,797 # 1f31d <base+0x1cf15>
      1c:	02d7e733          	rem	a4,a5,a3
    x = 16807 * lo - 2836 * hi;
      20:	6611                	lui	a2,0x4
      22:	1a760613          	addi	a2,a2,423 # 41a7 <base+0x1d9f>
      26:	02c70733          	mul	a4,a4,a2
    hi = x / 127773;
      2a:	02d7c7b3          	div	a5,a5,a3
    x = 16807 * lo - 2836 * hi;
      2e:	76fd                	lui	a3,0xfffff
      30:	4ec68693          	addi	a3,a3,1260 # fffffffffffff4ec <base+0xffffffffffffd0e4>
      34:	02d787b3          	mul	a5,a5,a3
      38:	97ba                	add	a5,a5,a4
    if (x < 0)
      3a:	0007c963          	bltz	a5,4c <do_rand+0x4c>
        x += 0x7fffffff;
    /* Transform to [0, 0x7ffffffd] range. */
    x--;
      3e:	17fd                	addi	a5,a5,-1
    *ctx = x;
      40:	e11c                	sd	a5,0(a0)
    return (x);
}
      42:	0007851b          	sext.w	a0,a5
      46:	6422                	ld	s0,8(sp)
      48:	0141                	addi	sp,sp,16
      4a:	8082                	ret
        x += 0x7fffffff;
      4c:	80000737          	lui	a4,0x80000
      50:	fff74713          	not	a4,a4
      54:	97ba                	add	a5,a5,a4
      56:	b7e5                	j	3e <do_rand+0x3e>

0000000000000058 <rand>:

unsigned long rand_next = 1;

int
rand(void)
{
      58:	1141                	addi	sp,sp,-16
      5a:	e406                	sd	ra,8(sp)
      5c:	e022                	sd	s0,0(sp)
      5e:	0800                	addi	s0,sp,16
    return (do_rand(&rand_next));
      60:	00002517          	auipc	a0,0x2
      64:	fa050513          	addi	a0,a0,-96 # 2000 <rand_next>
      68:	00000097          	auipc	ra,0x0
      6c:	f98080e7          	jalr	-104(ra) # 0 <do_rand>
}
      70:	60a2                	ld	ra,8(sp)
      72:	6402                	ld	s0,0(sp)
      74:	0141                	addi	sp,sp,16
      76:	8082                	ret

0000000000000078 <go>:

void
go(int which_child)
{
      78:	7159                	addi	sp,sp,-112
      7a:	f486                	sd	ra,104(sp)
      7c:	f0a2                	sd	s0,96(sp)
      7e:	eca6                	sd	s1,88(sp)
      80:	e8ca                	sd	s2,80(sp)
      82:	e4ce                	sd	s3,72(sp)
      84:	e0d2                	sd	s4,64(sp)
      86:	fc56                	sd	s5,56(sp)
      88:	f85a                	sd	s6,48(sp)
      8a:	1880                	addi	s0,sp,112
      8c:	84aa                	mv	s1,a0
  int fd = -1;
  static char buf[999];
  char *break0 = sbrk(0);
      8e:	4501                	li	a0,0
      90:	00001097          	auipc	ra,0x1
      94:	e26080e7          	jalr	-474(ra) # eb6 <sbrk>
      98:	8aaa                	mv	s5,a0
  uint64 iters = 0;

  mkdir("grindir");
      9a:	00001517          	auipc	a0,0x1
      9e:	36650513          	addi	a0,a0,870 # 1400 <lock_release+0x1e>
      a2:	00001097          	auipc	ra,0x1
      a6:	df4080e7          	jalr	-524(ra) # e96 <mkdir>
  if(chdir("grindir") != 0){
      aa:	00001517          	auipc	a0,0x1
      ae:	35650513          	addi	a0,a0,854 # 1400 <lock_release+0x1e>
      b2:	00001097          	auipc	ra,0x1
      b6:	dec080e7          	jalr	-532(ra) # e9e <chdir>
      ba:	cd11                	beqz	a0,d6 <go+0x5e>
    printf("grind: chdir grindir failed\n");
      bc:	00001517          	auipc	a0,0x1
      c0:	34c50513          	addi	a0,a0,844 # 1408 <lock_release+0x26>
      c4:	00001097          	auipc	ra,0x1
      c8:	114080e7          	jalr	276(ra) # 11d8 <printf>
    exit(1);
      cc:	4505                	li	a0,1
      ce:	00001097          	auipc	ra,0x1
      d2:	d60080e7          	jalr	-672(ra) # e2e <exit>
  }
  chdir("/");
      d6:	00001517          	auipc	a0,0x1
      da:	35250513          	addi	a0,a0,850 # 1428 <lock_release+0x46>
      de:	00001097          	auipc	ra,0x1
      e2:	dc0080e7          	jalr	-576(ra) # e9e <chdir>
  
  while(1){
    iters++;
    if((iters % 500) == 0)
      e6:	00001997          	auipc	s3,0x1
      ea:	35298993          	addi	s3,s3,850 # 1438 <lock_release+0x56>
      ee:	c489                	beqz	s1,f8 <go+0x80>
      f0:	00001997          	auipc	s3,0x1
      f4:	34098993          	addi	s3,s3,832 # 1430 <lock_release+0x4e>
    iters++;
      f8:	4485                	li	s1,1
  int fd = -1;
      fa:	5a7d                	li	s4,-1
      fc:	00001917          	auipc	s2,0x1
     100:	5ec90913          	addi	s2,s2,1516 # 16e8 <lock_release+0x306>
     104:	a825                	j	13c <go+0xc4>
      write(1, which_child?"B":"A", 1);
    int what = rand() % 23;
    if(what == 1){
      close(open("grindir/../a", O_CREATE|O_RDWR));
     106:	20200593          	li	a1,514
     10a:	00001517          	auipc	a0,0x1
     10e:	33650513          	addi	a0,a0,822 # 1440 <lock_release+0x5e>
     112:	00001097          	auipc	ra,0x1
     116:	d5c080e7          	jalr	-676(ra) # e6e <open>
     11a:	00001097          	auipc	ra,0x1
     11e:	d3c080e7          	jalr	-708(ra) # e56 <close>
    iters++;
     122:	0485                	addi	s1,s1,1
    if((iters % 500) == 0)
     124:	1f400793          	li	a5,500
     128:	02f4f7b3          	remu	a5,s1,a5
     12c:	eb81                	bnez	a5,13c <go+0xc4>
      write(1, which_child?"B":"A", 1);
     12e:	4605                	li	a2,1
     130:	85ce                	mv	a1,s3
     132:	4505                	li	a0,1
     134:	00001097          	auipc	ra,0x1
     138:	d1a080e7          	jalr	-742(ra) # e4e <write>
    int what = rand() % 23;
     13c:	00000097          	auipc	ra,0x0
     140:	f1c080e7          	jalr	-228(ra) # 58 <rand>
     144:	47dd                	li	a5,23
     146:	02f5653b          	remw	a0,a0,a5
    if(what == 1){
     14a:	4785                	li	a5,1
     14c:	faf50de3          	beq	a0,a5,106 <go+0x8e>
    } else if(what == 2){
     150:	47d9                	li	a5,22
     152:	fca7e8e3          	bltu	a5,a0,122 <go+0xaa>
     156:	050a                	slli	a0,a0,0x2
     158:	954a                	add	a0,a0,s2
     15a:	411c                	lw	a5,0(a0)
     15c:	97ca                	add	a5,a5,s2
     15e:	8782                	jr	a5
      close(open("grindir/../grindir/../b", O_CREATE|O_RDWR));
     160:	20200593          	li	a1,514
     164:	00001517          	auipc	a0,0x1
     168:	2ec50513          	addi	a0,a0,748 # 1450 <lock_release+0x6e>
     16c:	00001097          	auipc	ra,0x1
     170:	d02080e7          	jalr	-766(ra) # e6e <open>
     174:	00001097          	auipc	ra,0x1
     178:	ce2080e7          	jalr	-798(ra) # e56 <close>
     17c:	b75d                	j	122 <go+0xaa>
    } else if(what == 3){
      unlink("grindir/../a");
     17e:	00001517          	auipc	a0,0x1
     182:	2c250513          	addi	a0,a0,706 # 1440 <lock_release+0x5e>
     186:	00001097          	auipc	ra,0x1
     18a:	cf8080e7          	jalr	-776(ra) # e7e <unlink>
     18e:	bf51                	j	122 <go+0xaa>
    } else if(what == 4){
      if(chdir("grindir") != 0){
     190:	00001517          	auipc	a0,0x1
     194:	27050513          	addi	a0,a0,624 # 1400 <lock_release+0x1e>
     198:	00001097          	auipc	ra,0x1
     19c:	d06080e7          	jalr	-762(ra) # e9e <chdir>
     1a0:	e115                	bnez	a0,1c4 <go+0x14c>
        printf("grind: chdir grindir failed\n");
        exit(1);
      }
      unlink("../b");
     1a2:	00001517          	auipc	a0,0x1
     1a6:	2c650513          	addi	a0,a0,710 # 1468 <lock_release+0x86>
     1aa:	00001097          	auipc	ra,0x1
     1ae:	cd4080e7          	jalr	-812(ra) # e7e <unlink>
      chdir("/");
     1b2:	00001517          	auipc	a0,0x1
     1b6:	27650513          	addi	a0,a0,630 # 1428 <lock_release+0x46>
     1ba:	00001097          	auipc	ra,0x1
     1be:	ce4080e7          	jalr	-796(ra) # e9e <chdir>
     1c2:	b785                	j	122 <go+0xaa>
        printf("grind: chdir grindir failed\n");
     1c4:	00001517          	auipc	a0,0x1
     1c8:	24450513          	addi	a0,a0,580 # 1408 <lock_release+0x26>
     1cc:	00001097          	auipc	ra,0x1
     1d0:	00c080e7          	jalr	12(ra) # 11d8 <printf>
        exit(1);
     1d4:	4505                	li	a0,1
     1d6:	00001097          	auipc	ra,0x1
     1da:	c58080e7          	jalr	-936(ra) # e2e <exit>
    } else if(what == 5){
      close(fd);
     1de:	8552                	mv	a0,s4
     1e0:	00001097          	auipc	ra,0x1
     1e4:	c76080e7          	jalr	-906(ra) # e56 <close>
      fd = open("/grindir/../a", O_CREATE|O_RDWR);
     1e8:	20200593          	li	a1,514
     1ec:	00001517          	auipc	a0,0x1
     1f0:	28450513          	addi	a0,a0,644 # 1470 <lock_release+0x8e>
     1f4:	00001097          	auipc	ra,0x1
     1f8:	c7a080e7          	jalr	-902(ra) # e6e <open>
     1fc:	8a2a                	mv	s4,a0
     1fe:	b715                	j	122 <go+0xaa>
    } else if(what == 6){
      close(fd);
     200:	8552                	mv	a0,s4
     202:	00001097          	auipc	ra,0x1
     206:	c54080e7          	jalr	-940(ra) # e56 <close>
      fd = open("/./grindir/./../b", O_CREATE|O_RDWR);
     20a:	20200593          	li	a1,514
     20e:	00001517          	auipc	a0,0x1
     212:	27250513          	addi	a0,a0,626 # 1480 <lock_release+0x9e>
     216:	00001097          	auipc	ra,0x1
     21a:	c58080e7          	jalr	-936(ra) # e6e <open>
     21e:	8a2a                	mv	s4,a0
     220:	b709                	j	122 <go+0xaa>
    } else if(what == 7){
      write(fd, buf, sizeof(buf));
     222:	3e700613          	li	a2,999
     226:	00002597          	auipc	a1,0x2
     22a:	dfa58593          	addi	a1,a1,-518 # 2020 <buf.0>
     22e:	8552                	mv	a0,s4
     230:	00001097          	auipc	ra,0x1
     234:	c1e080e7          	jalr	-994(ra) # e4e <write>
     238:	b5ed                	j	122 <go+0xaa>
    } else if(what == 8){
      read(fd, buf, sizeof(buf));
     23a:	3e700613          	li	a2,999
     23e:	00002597          	auipc	a1,0x2
     242:	de258593          	addi	a1,a1,-542 # 2020 <buf.0>
     246:	8552                	mv	a0,s4
     248:	00001097          	auipc	ra,0x1
     24c:	bfe080e7          	jalr	-1026(ra) # e46 <read>
     250:	bdc9                	j	122 <go+0xaa>
    } else if(what == 9){
      mkdir("grindir/../a");
     252:	00001517          	auipc	a0,0x1
     256:	1ee50513          	addi	a0,a0,494 # 1440 <lock_release+0x5e>
     25a:	00001097          	auipc	ra,0x1
     25e:	c3c080e7          	jalr	-964(ra) # e96 <mkdir>
      close(open("a/../a/./a", O_CREATE|O_RDWR));
     262:	20200593          	li	a1,514
     266:	00001517          	auipc	a0,0x1
     26a:	23250513          	addi	a0,a0,562 # 1498 <lock_release+0xb6>
     26e:	00001097          	auipc	ra,0x1
     272:	c00080e7          	jalr	-1024(ra) # e6e <open>
     276:	00001097          	auipc	ra,0x1
     27a:	be0080e7          	jalr	-1056(ra) # e56 <close>
      unlink("a/a");
     27e:	00001517          	auipc	a0,0x1
     282:	22a50513          	addi	a0,a0,554 # 14a8 <lock_release+0xc6>
     286:	00001097          	auipc	ra,0x1
     28a:	bf8080e7          	jalr	-1032(ra) # e7e <unlink>
     28e:	bd51                	j	122 <go+0xaa>
    } else if(what == 10){
      mkdir("/../b");
     290:	00001517          	auipc	a0,0x1
     294:	22050513          	addi	a0,a0,544 # 14b0 <lock_release+0xce>
     298:	00001097          	auipc	ra,0x1
     29c:	bfe080e7          	jalr	-1026(ra) # e96 <mkdir>
      close(open("grindir/../b/b", O_CREATE|O_RDWR));
     2a0:	20200593          	li	a1,514
     2a4:	00001517          	auipc	a0,0x1
     2a8:	21450513          	addi	a0,a0,532 # 14b8 <lock_release+0xd6>
     2ac:	00001097          	auipc	ra,0x1
     2b0:	bc2080e7          	jalr	-1086(ra) # e6e <open>
     2b4:	00001097          	auipc	ra,0x1
     2b8:	ba2080e7          	jalr	-1118(ra) # e56 <close>
      unlink("b/b");
     2bc:	00001517          	auipc	a0,0x1
     2c0:	20c50513          	addi	a0,a0,524 # 14c8 <lock_release+0xe6>
     2c4:	00001097          	auipc	ra,0x1
     2c8:	bba080e7          	jalr	-1094(ra) # e7e <unlink>
     2cc:	bd99                	j	122 <go+0xaa>
    } else if(what == 11){
      unlink("b");
     2ce:	00001517          	auipc	a0,0x1
     2d2:	1c250513          	addi	a0,a0,450 # 1490 <lock_release+0xae>
     2d6:	00001097          	auipc	ra,0x1
     2da:	ba8080e7          	jalr	-1112(ra) # e7e <unlink>
      link("../grindir/./../a", "../b");
     2de:	00001597          	auipc	a1,0x1
     2e2:	18a58593          	addi	a1,a1,394 # 1468 <lock_release+0x86>
     2e6:	00001517          	auipc	a0,0x1
     2ea:	1ea50513          	addi	a0,a0,490 # 14d0 <lock_release+0xee>
     2ee:	00001097          	auipc	ra,0x1
     2f2:	ba0080e7          	jalr	-1120(ra) # e8e <link>
     2f6:	b535                	j	122 <go+0xaa>
    } else if(what == 12){
      unlink("../grindir/../a");
     2f8:	00001517          	auipc	a0,0x1
     2fc:	1f050513          	addi	a0,a0,496 # 14e8 <lock_release+0x106>
     300:	00001097          	auipc	ra,0x1
     304:	b7e080e7          	jalr	-1154(ra) # e7e <unlink>
      link(".././b", "/grindir/../a");
     308:	00001597          	auipc	a1,0x1
     30c:	16858593          	addi	a1,a1,360 # 1470 <lock_release+0x8e>
     310:	00001517          	auipc	a0,0x1
     314:	1e850513          	addi	a0,a0,488 # 14f8 <lock_release+0x116>
     318:	00001097          	auipc	ra,0x1
     31c:	b76080e7          	jalr	-1162(ra) # e8e <link>
     320:	b509                	j	122 <go+0xaa>
    } else if(what == 13){
      int pid = fork();
     322:	00001097          	auipc	ra,0x1
     326:	b04080e7          	jalr	-1276(ra) # e26 <fork>
      if(pid == 0){
     32a:	c909                	beqz	a0,33c <go+0x2c4>
        exit(0);
      } else if(pid < 0){
     32c:	00054c63          	bltz	a0,344 <go+0x2cc>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     330:	4501                	li	a0,0
     332:	00001097          	auipc	ra,0x1
     336:	b04080e7          	jalr	-1276(ra) # e36 <wait>
     33a:	b3e5                	j	122 <go+0xaa>
        exit(0);
     33c:	00001097          	auipc	ra,0x1
     340:	af2080e7          	jalr	-1294(ra) # e2e <exit>
        printf("grind: fork failed\n");
     344:	00001517          	auipc	a0,0x1
     348:	1bc50513          	addi	a0,a0,444 # 1500 <lock_release+0x11e>
     34c:	00001097          	auipc	ra,0x1
     350:	e8c080e7          	jalr	-372(ra) # 11d8 <printf>
        exit(1);
     354:	4505                	li	a0,1
     356:	00001097          	auipc	ra,0x1
     35a:	ad8080e7          	jalr	-1320(ra) # e2e <exit>
    } else if(what == 14){
      int pid = fork();
     35e:	00001097          	auipc	ra,0x1
     362:	ac8080e7          	jalr	-1336(ra) # e26 <fork>
      if(pid == 0){
     366:	c909                	beqz	a0,378 <go+0x300>
        fork();
        fork();
        exit(0);
      } else if(pid < 0){
     368:	02054563          	bltz	a0,392 <go+0x31a>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     36c:	4501                	li	a0,0
     36e:	00001097          	auipc	ra,0x1
     372:	ac8080e7          	jalr	-1336(ra) # e36 <wait>
     376:	b375                	j	122 <go+0xaa>
        fork();
     378:	00001097          	auipc	ra,0x1
     37c:	aae080e7          	jalr	-1362(ra) # e26 <fork>
        fork();
     380:	00001097          	auipc	ra,0x1
     384:	aa6080e7          	jalr	-1370(ra) # e26 <fork>
        exit(0);
     388:	4501                	li	a0,0
     38a:	00001097          	auipc	ra,0x1
     38e:	aa4080e7          	jalr	-1372(ra) # e2e <exit>
        printf("grind: fork failed\n");
     392:	00001517          	auipc	a0,0x1
     396:	16e50513          	addi	a0,a0,366 # 1500 <lock_release+0x11e>
     39a:	00001097          	auipc	ra,0x1
     39e:	e3e080e7          	jalr	-450(ra) # 11d8 <printf>
        exit(1);
     3a2:	4505                	li	a0,1
     3a4:	00001097          	auipc	ra,0x1
     3a8:	a8a080e7          	jalr	-1398(ra) # e2e <exit>
    } else if(what == 15){
      sbrk(6011);
     3ac:	6505                	lui	a0,0x1
     3ae:	77b50513          	addi	a0,a0,1915 # 177b <lock_release+0x399>
     3b2:	00001097          	auipc	ra,0x1
     3b6:	b04080e7          	jalr	-1276(ra) # eb6 <sbrk>
     3ba:	b3a5                	j	122 <go+0xaa>
    } else if(what == 16){
      if(sbrk(0) > break0)
     3bc:	4501                	li	a0,0
     3be:	00001097          	auipc	ra,0x1
     3c2:	af8080e7          	jalr	-1288(ra) # eb6 <sbrk>
     3c6:	d4aafee3          	bgeu	s5,a0,122 <go+0xaa>
        sbrk(-(sbrk(0) - break0));
     3ca:	4501                	li	a0,0
     3cc:	00001097          	auipc	ra,0x1
     3d0:	aea080e7          	jalr	-1302(ra) # eb6 <sbrk>
     3d4:	40aa853b          	subw	a0,s5,a0
     3d8:	00001097          	auipc	ra,0x1
     3dc:	ade080e7          	jalr	-1314(ra) # eb6 <sbrk>
     3e0:	b389                	j	122 <go+0xaa>
    } else if(what == 17){
      int pid = fork();
     3e2:	00001097          	auipc	ra,0x1
     3e6:	a44080e7          	jalr	-1468(ra) # e26 <fork>
     3ea:	8b2a                	mv	s6,a0
      if(pid == 0){
     3ec:	c51d                	beqz	a0,41a <go+0x3a2>
        close(open("a", O_CREATE|O_RDWR));
        exit(0);
      } else if(pid < 0){
     3ee:	04054963          	bltz	a0,440 <go+0x3c8>
        printf("grind: fork failed\n");
        exit(1);
      }
      if(chdir("../grindir/..") != 0){
     3f2:	00001517          	auipc	a0,0x1
     3f6:	12650513          	addi	a0,a0,294 # 1518 <lock_release+0x136>
     3fa:	00001097          	auipc	ra,0x1
     3fe:	aa4080e7          	jalr	-1372(ra) # e9e <chdir>
     402:	ed21                	bnez	a0,45a <go+0x3e2>
        printf("grind: chdir failed\n");
        exit(1);
      }
      kill(pid);
     404:	855a                	mv	a0,s6
     406:	00001097          	auipc	ra,0x1
     40a:	a58080e7          	jalr	-1448(ra) # e5e <kill>
      wait(0);
     40e:	4501                	li	a0,0
     410:	00001097          	auipc	ra,0x1
     414:	a26080e7          	jalr	-1498(ra) # e36 <wait>
     418:	b329                	j	122 <go+0xaa>
        close(open("a", O_CREATE|O_RDWR));
     41a:	20200593          	li	a1,514
     41e:	00001517          	auipc	a0,0x1
     422:	0c250513          	addi	a0,a0,194 # 14e0 <lock_release+0xfe>
     426:	00001097          	auipc	ra,0x1
     42a:	a48080e7          	jalr	-1464(ra) # e6e <open>
     42e:	00001097          	auipc	ra,0x1
     432:	a28080e7          	jalr	-1496(ra) # e56 <close>
        exit(0);
     436:	4501                	li	a0,0
     438:	00001097          	auipc	ra,0x1
     43c:	9f6080e7          	jalr	-1546(ra) # e2e <exit>
        printf("grind: fork failed\n");
     440:	00001517          	auipc	a0,0x1
     444:	0c050513          	addi	a0,a0,192 # 1500 <lock_release+0x11e>
     448:	00001097          	auipc	ra,0x1
     44c:	d90080e7          	jalr	-624(ra) # 11d8 <printf>
        exit(1);
     450:	4505                	li	a0,1
     452:	00001097          	auipc	ra,0x1
     456:	9dc080e7          	jalr	-1572(ra) # e2e <exit>
        printf("grind: chdir failed\n");
     45a:	00001517          	auipc	a0,0x1
     45e:	0ce50513          	addi	a0,a0,206 # 1528 <lock_release+0x146>
     462:	00001097          	auipc	ra,0x1
     466:	d76080e7          	jalr	-650(ra) # 11d8 <printf>
        exit(1);
     46a:	4505                	li	a0,1
     46c:	00001097          	auipc	ra,0x1
     470:	9c2080e7          	jalr	-1598(ra) # e2e <exit>
    } else if(what == 18){
      int pid = fork();
     474:	00001097          	auipc	ra,0x1
     478:	9b2080e7          	jalr	-1614(ra) # e26 <fork>
      if(pid == 0){
     47c:	c909                	beqz	a0,48e <go+0x416>
        kill(getpid());
        exit(0);
      } else if(pid < 0){
     47e:	02054563          	bltz	a0,4a8 <go+0x430>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     482:	4501                	li	a0,0
     484:	00001097          	auipc	ra,0x1
     488:	9b2080e7          	jalr	-1614(ra) # e36 <wait>
     48c:	b959                	j	122 <go+0xaa>
        kill(getpid());
     48e:	00001097          	auipc	ra,0x1
     492:	a20080e7          	jalr	-1504(ra) # eae <getpid>
     496:	00001097          	auipc	ra,0x1
     49a:	9c8080e7          	jalr	-1592(ra) # e5e <kill>
        exit(0);
     49e:	4501                	li	a0,0
     4a0:	00001097          	auipc	ra,0x1
     4a4:	98e080e7          	jalr	-1650(ra) # e2e <exit>
        printf("grind: fork failed\n");
     4a8:	00001517          	auipc	a0,0x1
     4ac:	05850513          	addi	a0,a0,88 # 1500 <lock_release+0x11e>
     4b0:	00001097          	auipc	ra,0x1
     4b4:	d28080e7          	jalr	-728(ra) # 11d8 <printf>
        exit(1);
     4b8:	4505                	li	a0,1
     4ba:	00001097          	auipc	ra,0x1
     4be:	974080e7          	jalr	-1676(ra) # e2e <exit>
    } else if(what == 19){
      int fds[2];
      if(pipe(fds) < 0){
     4c2:	fa840513          	addi	a0,s0,-88
     4c6:	00001097          	auipc	ra,0x1
     4ca:	978080e7          	jalr	-1672(ra) # e3e <pipe>
     4ce:	02054b63          	bltz	a0,504 <go+0x48c>
        printf("grind: pipe failed\n");
        exit(1);
      }
      int pid = fork();
     4d2:	00001097          	auipc	ra,0x1
     4d6:	954080e7          	jalr	-1708(ra) # e26 <fork>
      if(pid == 0){
     4da:	c131                	beqz	a0,51e <go+0x4a6>
          printf("grind: pipe write failed\n");
        char c;
        if(read(fds[0], &c, 1) != 1)
          printf("grind: pipe read failed\n");
        exit(0);
      } else if(pid < 0){
     4dc:	0a054a63          	bltz	a0,590 <go+0x518>
        printf("grind: fork failed\n");
        exit(1);
      }
      close(fds[0]);
     4e0:	fa842503          	lw	a0,-88(s0)
     4e4:	00001097          	auipc	ra,0x1
     4e8:	972080e7          	jalr	-1678(ra) # e56 <close>
      close(fds[1]);
     4ec:	fac42503          	lw	a0,-84(s0)
     4f0:	00001097          	auipc	ra,0x1
     4f4:	966080e7          	jalr	-1690(ra) # e56 <close>
      wait(0);
     4f8:	4501                	li	a0,0
     4fa:	00001097          	auipc	ra,0x1
     4fe:	93c080e7          	jalr	-1732(ra) # e36 <wait>
     502:	b105                	j	122 <go+0xaa>
        printf("grind: pipe failed\n");
     504:	00001517          	auipc	a0,0x1
     508:	03c50513          	addi	a0,a0,60 # 1540 <lock_release+0x15e>
     50c:	00001097          	auipc	ra,0x1
     510:	ccc080e7          	jalr	-820(ra) # 11d8 <printf>
        exit(1);
     514:	4505                	li	a0,1
     516:	00001097          	auipc	ra,0x1
     51a:	918080e7          	jalr	-1768(ra) # e2e <exit>
        fork();
     51e:	00001097          	auipc	ra,0x1
     522:	908080e7          	jalr	-1784(ra) # e26 <fork>
        fork();
     526:	00001097          	auipc	ra,0x1
     52a:	900080e7          	jalr	-1792(ra) # e26 <fork>
        if(write(fds[1], "x", 1) != 1)
     52e:	4605                	li	a2,1
     530:	00001597          	auipc	a1,0x1
     534:	02858593          	addi	a1,a1,40 # 1558 <lock_release+0x176>
     538:	fac42503          	lw	a0,-84(s0)
     53c:	00001097          	auipc	ra,0x1
     540:	912080e7          	jalr	-1774(ra) # e4e <write>
     544:	4785                	li	a5,1
     546:	02f51363          	bne	a0,a5,56c <go+0x4f4>
        if(read(fds[0], &c, 1) != 1)
     54a:	4605                	li	a2,1
     54c:	fa040593          	addi	a1,s0,-96
     550:	fa842503          	lw	a0,-88(s0)
     554:	00001097          	auipc	ra,0x1
     558:	8f2080e7          	jalr	-1806(ra) # e46 <read>
     55c:	4785                	li	a5,1
     55e:	02f51063          	bne	a0,a5,57e <go+0x506>
        exit(0);
     562:	4501                	li	a0,0
     564:	00001097          	auipc	ra,0x1
     568:	8ca080e7          	jalr	-1846(ra) # e2e <exit>
          printf("grind: pipe write failed\n");
     56c:	00001517          	auipc	a0,0x1
     570:	ff450513          	addi	a0,a0,-12 # 1560 <lock_release+0x17e>
     574:	00001097          	auipc	ra,0x1
     578:	c64080e7          	jalr	-924(ra) # 11d8 <printf>
     57c:	b7f9                	j	54a <go+0x4d2>
          printf("grind: pipe read failed\n");
     57e:	00001517          	auipc	a0,0x1
     582:	00250513          	addi	a0,a0,2 # 1580 <lock_release+0x19e>
     586:	00001097          	auipc	ra,0x1
     58a:	c52080e7          	jalr	-942(ra) # 11d8 <printf>
     58e:	bfd1                	j	562 <go+0x4ea>
        printf("grind: fork failed\n");
     590:	00001517          	auipc	a0,0x1
     594:	f7050513          	addi	a0,a0,-144 # 1500 <lock_release+0x11e>
     598:	00001097          	auipc	ra,0x1
     59c:	c40080e7          	jalr	-960(ra) # 11d8 <printf>
        exit(1);
     5a0:	4505                	li	a0,1
     5a2:	00001097          	auipc	ra,0x1
     5a6:	88c080e7          	jalr	-1908(ra) # e2e <exit>
    } else if(what == 20){
      int pid = fork();
     5aa:	00001097          	auipc	ra,0x1
     5ae:	87c080e7          	jalr	-1924(ra) # e26 <fork>
      if(pid == 0){
     5b2:	c909                	beqz	a0,5c4 <go+0x54c>
        chdir("a");
        unlink("../a");
        fd = open("x", O_CREATE|O_RDWR);
        unlink("x");
        exit(0);
      } else if(pid < 0){
     5b4:	06054f63          	bltz	a0,632 <go+0x5ba>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     5b8:	4501                	li	a0,0
     5ba:	00001097          	auipc	ra,0x1
     5be:	87c080e7          	jalr	-1924(ra) # e36 <wait>
     5c2:	b685                	j	122 <go+0xaa>
        unlink("a");
     5c4:	00001517          	auipc	a0,0x1
     5c8:	f1c50513          	addi	a0,a0,-228 # 14e0 <lock_release+0xfe>
     5cc:	00001097          	auipc	ra,0x1
     5d0:	8b2080e7          	jalr	-1870(ra) # e7e <unlink>
        mkdir("a");
     5d4:	00001517          	auipc	a0,0x1
     5d8:	f0c50513          	addi	a0,a0,-244 # 14e0 <lock_release+0xfe>
     5dc:	00001097          	auipc	ra,0x1
     5e0:	8ba080e7          	jalr	-1862(ra) # e96 <mkdir>
        chdir("a");
     5e4:	00001517          	auipc	a0,0x1
     5e8:	efc50513          	addi	a0,a0,-260 # 14e0 <lock_release+0xfe>
     5ec:	00001097          	auipc	ra,0x1
     5f0:	8b2080e7          	jalr	-1870(ra) # e9e <chdir>
        unlink("../a");
     5f4:	00001517          	auipc	a0,0x1
     5f8:	e5450513          	addi	a0,a0,-428 # 1448 <lock_release+0x66>
     5fc:	00001097          	auipc	ra,0x1
     600:	882080e7          	jalr	-1918(ra) # e7e <unlink>
        fd = open("x", O_CREATE|O_RDWR);
     604:	20200593          	li	a1,514
     608:	00001517          	auipc	a0,0x1
     60c:	f5050513          	addi	a0,a0,-176 # 1558 <lock_release+0x176>
     610:	00001097          	auipc	ra,0x1
     614:	85e080e7          	jalr	-1954(ra) # e6e <open>
        unlink("x");
     618:	00001517          	auipc	a0,0x1
     61c:	f4050513          	addi	a0,a0,-192 # 1558 <lock_release+0x176>
     620:	00001097          	auipc	ra,0x1
     624:	85e080e7          	jalr	-1954(ra) # e7e <unlink>
        exit(0);
     628:	4501                	li	a0,0
     62a:	00001097          	auipc	ra,0x1
     62e:	804080e7          	jalr	-2044(ra) # e2e <exit>
        printf("grind: fork failed\n");
     632:	00001517          	auipc	a0,0x1
     636:	ece50513          	addi	a0,a0,-306 # 1500 <lock_release+0x11e>
     63a:	00001097          	auipc	ra,0x1
     63e:	b9e080e7          	jalr	-1122(ra) # 11d8 <printf>
        exit(1);
     642:	4505                	li	a0,1
     644:	00000097          	auipc	ra,0x0
     648:	7ea080e7          	jalr	2026(ra) # e2e <exit>
    } else if(what == 21){
      unlink("c");
     64c:	00001517          	auipc	a0,0x1
     650:	f5450513          	addi	a0,a0,-172 # 15a0 <lock_release+0x1be>
     654:	00001097          	auipc	ra,0x1
     658:	82a080e7          	jalr	-2006(ra) # e7e <unlink>
      // should always succeed. check that there are free i-nodes,
      // file descriptors, blocks.
      int fd1 = open("c", O_CREATE|O_RDWR);
     65c:	20200593          	li	a1,514
     660:	00001517          	auipc	a0,0x1
     664:	f4050513          	addi	a0,a0,-192 # 15a0 <lock_release+0x1be>
     668:	00001097          	auipc	ra,0x1
     66c:	806080e7          	jalr	-2042(ra) # e6e <open>
     670:	8b2a                	mv	s6,a0
      if(fd1 < 0){
     672:	04054f63          	bltz	a0,6d0 <go+0x658>
        printf("grind: create c failed\n");
        exit(1);
      }
      if(write(fd1, "x", 1) != 1){
     676:	4605                	li	a2,1
     678:	00001597          	auipc	a1,0x1
     67c:	ee058593          	addi	a1,a1,-288 # 1558 <lock_release+0x176>
     680:	00000097          	auipc	ra,0x0
     684:	7ce080e7          	jalr	1998(ra) # e4e <write>
     688:	4785                	li	a5,1
     68a:	06f51063          	bne	a0,a5,6ea <go+0x672>
        printf("grind: write c failed\n");
        exit(1);
      }
      struct stat st;
      if(fstat(fd1, &st) != 0){
     68e:	fa840593          	addi	a1,s0,-88
     692:	855a                	mv	a0,s6
     694:	00000097          	auipc	ra,0x0
     698:	7f2080e7          	jalr	2034(ra) # e86 <fstat>
     69c:	e525                	bnez	a0,704 <go+0x68c>
        printf("grind: fstat failed\n");
        exit(1);
      }
      if(st.size != 1){
     69e:	fb843583          	ld	a1,-72(s0)
     6a2:	4785                	li	a5,1
     6a4:	06f59d63          	bne	a1,a5,71e <go+0x6a6>
        printf("grind: fstat reports wrong size %d\n", (int)st.size);
        exit(1);
      }
      if(st.ino > 200){
     6a8:	fac42583          	lw	a1,-84(s0)
     6ac:	0c800793          	li	a5,200
     6b0:	08b7e563          	bltu	a5,a1,73a <go+0x6c2>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
        exit(1);
      }
      close(fd1);
     6b4:	855a                	mv	a0,s6
     6b6:	00000097          	auipc	ra,0x0
     6ba:	7a0080e7          	jalr	1952(ra) # e56 <close>
      unlink("c");
     6be:	00001517          	auipc	a0,0x1
     6c2:	ee250513          	addi	a0,a0,-286 # 15a0 <lock_release+0x1be>
     6c6:	00000097          	auipc	ra,0x0
     6ca:	7b8080e7          	jalr	1976(ra) # e7e <unlink>
     6ce:	bc91                	j	122 <go+0xaa>
        printf("grind: create c failed\n");
     6d0:	00001517          	auipc	a0,0x1
     6d4:	ed850513          	addi	a0,a0,-296 # 15a8 <lock_release+0x1c6>
     6d8:	00001097          	auipc	ra,0x1
     6dc:	b00080e7          	jalr	-1280(ra) # 11d8 <printf>
        exit(1);
     6e0:	4505                	li	a0,1
     6e2:	00000097          	auipc	ra,0x0
     6e6:	74c080e7          	jalr	1868(ra) # e2e <exit>
        printf("grind: write c failed\n");
     6ea:	00001517          	auipc	a0,0x1
     6ee:	ed650513          	addi	a0,a0,-298 # 15c0 <lock_release+0x1de>
     6f2:	00001097          	auipc	ra,0x1
     6f6:	ae6080e7          	jalr	-1306(ra) # 11d8 <printf>
        exit(1);
     6fa:	4505                	li	a0,1
     6fc:	00000097          	auipc	ra,0x0
     700:	732080e7          	jalr	1842(ra) # e2e <exit>
        printf("grind: fstat failed\n");
     704:	00001517          	auipc	a0,0x1
     708:	ed450513          	addi	a0,a0,-300 # 15d8 <lock_release+0x1f6>
     70c:	00001097          	auipc	ra,0x1
     710:	acc080e7          	jalr	-1332(ra) # 11d8 <printf>
        exit(1);
     714:	4505                	li	a0,1
     716:	00000097          	auipc	ra,0x0
     71a:	718080e7          	jalr	1816(ra) # e2e <exit>
        printf("grind: fstat reports wrong size %d\n", (int)st.size);
     71e:	2581                	sext.w	a1,a1
     720:	00001517          	auipc	a0,0x1
     724:	ed050513          	addi	a0,a0,-304 # 15f0 <lock_release+0x20e>
     728:	00001097          	auipc	ra,0x1
     72c:	ab0080e7          	jalr	-1360(ra) # 11d8 <printf>
        exit(1);
     730:	4505                	li	a0,1
     732:	00000097          	auipc	ra,0x0
     736:	6fc080e7          	jalr	1788(ra) # e2e <exit>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
     73a:	00001517          	auipc	a0,0x1
     73e:	ede50513          	addi	a0,a0,-290 # 1618 <lock_release+0x236>
     742:	00001097          	auipc	ra,0x1
     746:	a96080e7          	jalr	-1386(ra) # 11d8 <printf>
        exit(1);
     74a:	4505                	li	a0,1
     74c:	00000097          	auipc	ra,0x0
     750:	6e2080e7          	jalr	1762(ra) # e2e <exit>
    } else if(what == 22){
      // echo hi | cat
      int aa[2], bb[2];
      if(pipe(aa) < 0){
     754:	f9840513          	addi	a0,s0,-104
     758:	00000097          	auipc	ra,0x0
     75c:	6e6080e7          	jalr	1766(ra) # e3e <pipe>
     760:	10054063          	bltz	a0,860 <go+0x7e8>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      if(pipe(bb) < 0){
     764:	fa040513          	addi	a0,s0,-96
     768:	00000097          	auipc	ra,0x0
     76c:	6d6080e7          	jalr	1750(ra) # e3e <pipe>
     770:	10054663          	bltz	a0,87c <go+0x804>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      int pid1 = fork();
     774:	00000097          	auipc	ra,0x0
     778:	6b2080e7          	jalr	1714(ra) # e26 <fork>
      if(pid1 == 0){
     77c:	10050e63          	beqz	a0,898 <go+0x820>
        close(aa[1]);
        char *args[3] = { "echo", "hi", 0 };
        exec("grindir/../echo", args);
        fprintf(2, "grind: echo: not found\n");
        exit(2);
      } else if(pid1 < 0){
     780:	1c054663          	bltz	a0,94c <go+0x8d4>
        fprintf(2, "grind: fork failed\n");
        exit(3);
      }
      int pid2 = fork();
     784:	00000097          	auipc	ra,0x0
     788:	6a2080e7          	jalr	1698(ra) # e26 <fork>
      if(pid2 == 0){
     78c:	1c050e63          	beqz	a0,968 <go+0x8f0>
        close(bb[1]);
        char *args[2] = { "cat", 0 };
        exec("/cat", args);
        fprintf(2, "grind: cat: not found\n");
        exit(6);
      } else if(pid2 < 0){
     790:	2a054a63          	bltz	a0,a44 <go+0x9cc>
        fprintf(2, "grind: fork failed\n");
        exit(7);
      }
      close(aa[0]);
     794:	f9842503          	lw	a0,-104(s0)
     798:	00000097          	auipc	ra,0x0
     79c:	6be080e7          	jalr	1726(ra) # e56 <close>
      close(aa[1]);
     7a0:	f9c42503          	lw	a0,-100(s0)
     7a4:	00000097          	auipc	ra,0x0
     7a8:	6b2080e7          	jalr	1714(ra) # e56 <close>
      close(bb[1]);
     7ac:	fa442503          	lw	a0,-92(s0)
     7b0:	00000097          	auipc	ra,0x0
     7b4:	6a6080e7          	jalr	1702(ra) # e56 <close>
      char buf[4] = { 0, 0, 0, 0 };
     7b8:	f8042823          	sw	zero,-112(s0)
      read(bb[0], buf+0, 1);
     7bc:	4605                	li	a2,1
     7be:	f9040593          	addi	a1,s0,-112
     7c2:	fa042503          	lw	a0,-96(s0)
     7c6:	00000097          	auipc	ra,0x0
     7ca:	680080e7          	jalr	1664(ra) # e46 <read>
      read(bb[0], buf+1, 1);
     7ce:	4605                	li	a2,1
     7d0:	f9140593          	addi	a1,s0,-111
     7d4:	fa042503          	lw	a0,-96(s0)
     7d8:	00000097          	auipc	ra,0x0
     7dc:	66e080e7          	jalr	1646(ra) # e46 <read>
      read(bb[0], buf+2, 1);
     7e0:	4605                	li	a2,1
     7e2:	f9240593          	addi	a1,s0,-110
     7e6:	fa042503          	lw	a0,-96(s0)
     7ea:	00000097          	auipc	ra,0x0
     7ee:	65c080e7          	jalr	1628(ra) # e46 <read>
      close(bb[0]);
     7f2:	fa042503          	lw	a0,-96(s0)
     7f6:	00000097          	auipc	ra,0x0
     7fa:	660080e7          	jalr	1632(ra) # e56 <close>
      int st1, st2;
      wait(&st1);
     7fe:	f9440513          	addi	a0,s0,-108
     802:	00000097          	auipc	ra,0x0
     806:	634080e7          	jalr	1588(ra) # e36 <wait>
      wait(&st2);
     80a:	fa840513          	addi	a0,s0,-88
     80e:	00000097          	auipc	ra,0x0
     812:	628080e7          	jalr	1576(ra) # e36 <wait>
      if(st1 != 0 || st2 != 0 || strcmp(buf, "hi\n") != 0){
     816:	f9442783          	lw	a5,-108(s0)
     81a:	fa842703          	lw	a4,-88(s0)
     81e:	8fd9                	or	a5,a5,a4
     820:	ef89                	bnez	a5,83a <go+0x7c2>
     822:	00001597          	auipc	a1,0x1
     826:	e9658593          	addi	a1,a1,-362 # 16b8 <lock_release+0x2d6>
     82a:	f9040513          	addi	a0,s0,-112
     82e:	00000097          	auipc	ra,0x0
     832:	3b0080e7          	jalr	944(ra) # bde <strcmp>
     836:	8e0506e3          	beqz	a0,122 <go+0xaa>
        printf("grind: exec pipeline failed %d %d \"%s\"\n", st1, st2, buf);
     83a:	f9040693          	addi	a3,s0,-112
     83e:	fa842603          	lw	a2,-88(s0)
     842:	f9442583          	lw	a1,-108(s0)
     846:	00001517          	auipc	a0,0x1
     84a:	e7a50513          	addi	a0,a0,-390 # 16c0 <lock_release+0x2de>
     84e:	00001097          	auipc	ra,0x1
     852:	98a080e7          	jalr	-1654(ra) # 11d8 <printf>
        exit(1);
     856:	4505                	li	a0,1
     858:	00000097          	auipc	ra,0x0
     85c:	5d6080e7          	jalr	1494(ra) # e2e <exit>
        fprintf(2, "grind: pipe failed\n");
     860:	00001597          	auipc	a1,0x1
     864:	ce058593          	addi	a1,a1,-800 # 1540 <lock_release+0x15e>
     868:	4509                	li	a0,2
     86a:	00001097          	auipc	ra,0x1
     86e:	940080e7          	jalr	-1728(ra) # 11aa <fprintf>
        exit(1);
     872:	4505                	li	a0,1
     874:	00000097          	auipc	ra,0x0
     878:	5ba080e7          	jalr	1466(ra) # e2e <exit>
        fprintf(2, "grind: pipe failed\n");
     87c:	00001597          	auipc	a1,0x1
     880:	cc458593          	addi	a1,a1,-828 # 1540 <lock_release+0x15e>
     884:	4509                	li	a0,2
     886:	00001097          	auipc	ra,0x1
     88a:	924080e7          	jalr	-1756(ra) # 11aa <fprintf>
        exit(1);
     88e:	4505                	li	a0,1
     890:	00000097          	auipc	ra,0x0
     894:	59e080e7          	jalr	1438(ra) # e2e <exit>
        close(bb[0]);
     898:	fa042503          	lw	a0,-96(s0)
     89c:	00000097          	auipc	ra,0x0
     8a0:	5ba080e7          	jalr	1466(ra) # e56 <close>
        close(bb[1]);
     8a4:	fa442503          	lw	a0,-92(s0)
     8a8:	00000097          	auipc	ra,0x0
     8ac:	5ae080e7          	jalr	1454(ra) # e56 <close>
        close(aa[0]);
     8b0:	f9842503          	lw	a0,-104(s0)
     8b4:	00000097          	auipc	ra,0x0
     8b8:	5a2080e7          	jalr	1442(ra) # e56 <close>
        close(1);
     8bc:	4505                	li	a0,1
     8be:	00000097          	auipc	ra,0x0
     8c2:	598080e7          	jalr	1432(ra) # e56 <close>
        if(dup(aa[1]) != 1){
     8c6:	f9c42503          	lw	a0,-100(s0)
     8ca:	00000097          	auipc	ra,0x0
     8ce:	5dc080e7          	jalr	1500(ra) # ea6 <dup>
     8d2:	4785                	li	a5,1
     8d4:	02f50063          	beq	a0,a5,8f4 <go+0x87c>
          fprintf(2, "grind: dup failed\n");
     8d8:	00001597          	auipc	a1,0x1
     8dc:	d6858593          	addi	a1,a1,-664 # 1640 <lock_release+0x25e>
     8e0:	4509                	li	a0,2
     8e2:	00001097          	auipc	ra,0x1
     8e6:	8c8080e7          	jalr	-1848(ra) # 11aa <fprintf>
          exit(1);
     8ea:	4505                	li	a0,1
     8ec:	00000097          	auipc	ra,0x0
     8f0:	542080e7          	jalr	1346(ra) # e2e <exit>
        close(aa[1]);
     8f4:	f9c42503          	lw	a0,-100(s0)
     8f8:	00000097          	auipc	ra,0x0
     8fc:	55e080e7          	jalr	1374(ra) # e56 <close>
        char *args[3] = { "echo", "hi", 0 };
     900:	00001797          	auipc	a5,0x1
     904:	d5878793          	addi	a5,a5,-680 # 1658 <lock_release+0x276>
     908:	faf43423          	sd	a5,-88(s0)
     90c:	00001797          	auipc	a5,0x1
     910:	d5478793          	addi	a5,a5,-684 # 1660 <lock_release+0x27e>
     914:	faf43823          	sd	a5,-80(s0)
     918:	fa043c23          	sd	zero,-72(s0)
        exec("grindir/../echo", args);
     91c:	fa840593          	addi	a1,s0,-88
     920:	00001517          	auipc	a0,0x1
     924:	d4850513          	addi	a0,a0,-696 # 1668 <lock_release+0x286>
     928:	00000097          	auipc	ra,0x0
     92c:	53e080e7          	jalr	1342(ra) # e66 <exec>
        fprintf(2, "grind: echo: not found\n");
     930:	00001597          	auipc	a1,0x1
     934:	d4858593          	addi	a1,a1,-696 # 1678 <lock_release+0x296>
     938:	4509                	li	a0,2
     93a:	00001097          	auipc	ra,0x1
     93e:	870080e7          	jalr	-1936(ra) # 11aa <fprintf>
        exit(2);
     942:	4509                	li	a0,2
     944:	00000097          	auipc	ra,0x0
     948:	4ea080e7          	jalr	1258(ra) # e2e <exit>
        fprintf(2, "grind: fork failed\n");
     94c:	00001597          	auipc	a1,0x1
     950:	bb458593          	addi	a1,a1,-1100 # 1500 <lock_release+0x11e>
     954:	4509                	li	a0,2
     956:	00001097          	auipc	ra,0x1
     95a:	854080e7          	jalr	-1964(ra) # 11aa <fprintf>
        exit(3);
     95e:	450d                	li	a0,3
     960:	00000097          	auipc	ra,0x0
     964:	4ce080e7          	jalr	1230(ra) # e2e <exit>
        close(aa[1]);
     968:	f9c42503          	lw	a0,-100(s0)
     96c:	00000097          	auipc	ra,0x0
     970:	4ea080e7          	jalr	1258(ra) # e56 <close>
        close(bb[0]);
     974:	fa042503          	lw	a0,-96(s0)
     978:	00000097          	auipc	ra,0x0
     97c:	4de080e7          	jalr	1246(ra) # e56 <close>
        close(0);
     980:	4501                	li	a0,0
     982:	00000097          	auipc	ra,0x0
     986:	4d4080e7          	jalr	1236(ra) # e56 <close>
        if(dup(aa[0]) != 0){
     98a:	f9842503          	lw	a0,-104(s0)
     98e:	00000097          	auipc	ra,0x0
     992:	518080e7          	jalr	1304(ra) # ea6 <dup>
     996:	cd19                	beqz	a0,9b4 <go+0x93c>
          fprintf(2, "grind: dup failed\n");
     998:	00001597          	auipc	a1,0x1
     99c:	ca858593          	addi	a1,a1,-856 # 1640 <lock_release+0x25e>
     9a0:	4509                	li	a0,2
     9a2:	00001097          	auipc	ra,0x1
     9a6:	808080e7          	jalr	-2040(ra) # 11aa <fprintf>
          exit(4);
     9aa:	4511                	li	a0,4
     9ac:	00000097          	auipc	ra,0x0
     9b0:	482080e7          	jalr	1154(ra) # e2e <exit>
        close(aa[0]);
     9b4:	f9842503          	lw	a0,-104(s0)
     9b8:	00000097          	auipc	ra,0x0
     9bc:	49e080e7          	jalr	1182(ra) # e56 <close>
        close(1);
     9c0:	4505                	li	a0,1
     9c2:	00000097          	auipc	ra,0x0
     9c6:	494080e7          	jalr	1172(ra) # e56 <close>
        if(dup(bb[1]) != 1){
     9ca:	fa442503          	lw	a0,-92(s0)
     9ce:	00000097          	auipc	ra,0x0
     9d2:	4d8080e7          	jalr	1240(ra) # ea6 <dup>
     9d6:	4785                	li	a5,1
     9d8:	02f50063          	beq	a0,a5,9f8 <go+0x980>
          fprintf(2, "grind: dup failed\n");
     9dc:	00001597          	auipc	a1,0x1
     9e0:	c6458593          	addi	a1,a1,-924 # 1640 <lock_release+0x25e>
     9e4:	4509                	li	a0,2
     9e6:	00000097          	auipc	ra,0x0
     9ea:	7c4080e7          	jalr	1988(ra) # 11aa <fprintf>
          exit(5);
     9ee:	4515                	li	a0,5
     9f0:	00000097          	auipc	ra,0x0
     9f4:	43e080e7          	jalr	1086(ra) # e2e <exit>
        close(bb[1]);
     9f8:	fa442503          	lw	a0,-92(s0)
     9fc:	00000097          	auipc	ra,0x0
     a00:	45a080e7          	jalr	1114(ra) # e56 <close>
        char *args[2] = { "cat", 0 };
     a04:	00001797          	auipc	a5,0x1
     a08:	c8c78793          	addi	a5,a5,-884 # 1690 <lock_release+0x2ae>
     a0c:	faf43423          	sd	a5,-88(s0)
     a10:	fa043823          	sd	zero,-80(s0)
        exec("/cat", args);
     a14:	fa840593          	addi	a1,s0,-88
     a18:	00001517          	auipc	a0,0x1
     a1c:	c8050513          	addi	a0,a0,-896 # 1698 <lock_release+0x2b6>
     a20:	00000097          	auipc	ra,0x0
     a24:	446080e7          	jalr	1094(ra) # e66 <exec>
        fprintf(2, "grind: cat: not found\n");
     a28:	00001597          	auipc	a1,0x1
     a2c:	c7858593          	addi	a1,a1,-904 # 16a0 <lock_release+0x2be>
     a30:	4509                	li	a0,2
     a32:	00000097          	auipc	ra,0x0
     a36:	778080e7          	jalr	1912(ra) # 11aa <fprintf>
        exit(6);
     a3a:	4519                	li	a0,6
     a3c:	00000097          	auipc	ra,0x0
     a40:	3f2080e7          	jalr	1010(ra) # e2e <exit>
        fprintf(2, "grind: fork failed\n");
     a44:	00001597          	auipc	a1,0x1
     a48:	abc58593          	addi	a1,a1,-1348 # 1500 <lock_release+0x11e>
     a4c:	4509                	li	a0,2
     a4e:	00000097          	auipc	ra,0x0
     a52:	75c080e7          	jalr	1884(ra) # 11aa <fprintf>
        exit(7);
     a56:	451d                	li	a0,7
     a58:	00000097          	auipc	ra,0x0
     a5c:	3d6080e7          	jalr	982(ra) # e2e <exit>

0000000000000a60 <iter>:
  }
}

void
iter()
{
     a60:	7179                	addi	sp,sp,-48
     a62:	f406                	sd	ra,40(sp)
     a64:	f022                	sd	s0,32(sp)
     a66:	ec26                	sd	s1,24(sp)
     a68:	e84a                	sd	s2,16(sp)
     a6a:	1800                	addi	s0,sp,48
  unlink("a");
     a6c:	00001517          	auipc	a0,0x1
     a70:	a7450513          	addi	a0,a0,-1420 # 14e0 <lock_release+0xfe>
     a74:	00000097          	auipc	ra,0x0
     a78:	40a080e7          	jalr	1034(ra) # e7e <unlink>
  unlink("b");
     a7c:	00001517          	auipc	a0,0x1
     a80:	a1450513          	addi	a0,a0,-1516 # 1490 <lock_release+0xae>
     a84:	00000097          	auipc	ra,0x0
     a88:	3fa080e7          	jalr	1018(ra) # e7e <unlink>
  
  int pid1 = fork();
     a8c:	00000097          	auipc	ra,0x0
     a90:	39a080e7          	jalr	922(ra) # e26 <fork>
  if(pid1 < 0){
     a94:	02054163          	bltz	a0,ab6 <iter+0x56>
     a98:	84aa                	mv	s1,a0
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid1 == 0){
     a9a:	e91d                	bnez	a0,ad0 <iter+0x70>
    rand_next ^= 31;
     a9c:	00001717          	auipc	a4,0x1
     aa0:	56470713          	addi	a4,a4,1380 # 2000 <rand_next>
     aa4:	631c                	ld	a5,0(a4)
     aa6:	01f7c793          	xori	a5,a5,31
     aaa:	e31c                	sd	a5,0(a4)
    go(0);
     aac:	4501                	li	a0,0
     aae:	fffff097          	auipc	ra,0xfffff
     ab2:	5ca080e7          	jalr	1482(ra) # 78 <go>
    printf("grind: fork failed\n");
     ab6:	00001517          	auipc	a0,0x1
     aba:	a4a50513          	addi	a0,a0,-1462 # 1500 <lock_release+0x11e>
     abe:	00000097          	auipc	ra,0x0
     ac2:	71a080e7          	jalr	1818(ra) # 11d8 <printf>
    exit(1);
     ac6:	4505                	li	a0,1
     ac8:	00000097          	auipc	ra,0x0
     acc:	366080e7          	jalr	870(ra) # e2e <exit>
    exit(0);
  }

  int pid2 = fork();
     ad0:	00000097          	auipc	ra,0x0
     ad4:	356080e7          	jalr	854(ra) # e26 <fork>
     ad8:	892a                	mv	s2,a0
  if(pid2 < 0){
     ada:	02054263          	bltz	a0,afe <iter+0x9e>
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid2 == 0){
     ade:	ed0d                	bnez	a0,b18 <iter+0xb8>
    rand_next ^= 7177;
     ae0:	00001697          	auipc	a3,0x1
     ae4:	52068693          	addi	a3,a3,1312 # 2000 <rand_next>
     ae8:	629c                	ld	a5,0(a3)
     aea:	6709                	lui	a4,0x2
     aec:	c0970713          	addi	a4,a4,-1015 # 1c09 <digits+0x461>
     af0:	8fb9                	xor	a5,a5,a4
     af2:	e29c                	sd	a5,0(a3)
    go(1);
     af4:	4505                	li	a0,1
     af6:	fffff097          	auipc	ra,0xfffff
     afa:	582080e7          	jalr	1410(ra) # 78 <go>
    printf("grind: fork failed\n");
     afe:	00001517          	auipc	a0,0x1
     b02:	a0250513          	addi	a0,a0,-1534 # 1500 <lock_release+0x11e>
     b06:	00000097          	auipc	ra,0x0
     b0a:	6d2080e7          	jalr	1746(ra) # 11d8 <printf>
    exit(1);
     b0e:	4505                	li	a0,1
     b10:	00000097          	auipc	ra,0x0
     b14:	31e080e7          	jalr	798(ra) # e2e <exit>
    exit(0);
  }

  int st1 = -1;
     b18:	57fd                	li	a5,-1
     b1a:	fcf42e23          	sw	a5,-36(s0)
  wait(&st1);
     b1e:	fdc40513          	addi	a0,s0,-36
     b22:	00000097          	auipc	ra,0x0
     b26:	314080e7          	jalr	788(ra) # e36 <wait>
  if(st1 != 0){
     b2a:	fdc42783          	lw	a5,-36(s0)
     b2e:	ef99                	bnez	a5,b4c <iter+0xec>
    kill(pid1);
    kill(pid2);
  }
  int st2 = -1;
     b30:	57fd                	li	a5,-1
     b32:	fcf42c23          	sw	a5,-40(s0)
  wait(&st2);
     b36:	fd840513          	addi	a0,s0,-40
     b3a:	00000097          	auipc	ra,0x0
     b3e:	2fc080e7          	jalr	764(ra) # e36 <wait>

  exit(0);
     b42:	4501                	li	a0,0
     b44:	00000097          	auipc	ra,0x0
     b48:	2ea080e7          	jalr	746(ra) # e2e <exit>
    kill(pid1);
     b4c:	8526                	mv	a0,s1
     b4e:	00000097          	auipc	ra,0x0
     b52:	310080e7          	jalr	784(ra) # e5e <kill>
    kill(pid2);
     b56:	854a                	mv	a0,s2
     b58:	00000097          	auipc	ra,0x0
     b5c:	306080e7          	jalr	774(ra) # e5e <kill>
     b60:	bfc1                	j	b30 <iter+0xd0>

0000000000000b62 <main>:
}

int
main()
{
     b62:	1101                	addi	sp,sp,-32
     b64:	ec06                	sd	ra,24(sp)
     b66:	e822                	sd	s0,16(sp)
     b68:	e426                	sd	s1,8(sp)
     b6a:	1000                	addi	s0,sp,32
    }
    if(pid > 0){
      wait(0);
    }
    sleep(20);
    rand_next += 1;
     b6c:	00001497          	auipc	s1,0x1
     b70:	49448493          	addi	s1,s1,1172 # 2000 <rand_next>
     b74:	a829                	j	b8e <main+0x2c>
      iter();
     b76:	00000097          	auipc	ra,0x0
     b7a:	eea080e7          	jalr	-278(ra) # a60 <iter>
    sleep(20);
     b7e:	4551                	li	a0,20
     b80:	00000097          	auipc	ra,0x0
     b84:	33e080e7          	jalr	830(ra) # ebe <sleep>
    rand_next += 1;
     b88:	609c                	ld	a5,0(s1)
     b8a:	0785                	addi	a5,a5,1
     b8c:	e09c                	sd	a5,0(s1)
    int pid = fork();
     b8e:	00000097          	auipc	ra,0x0
     b92:	298080e7          	jalr	664(ra) # e26 <fork>
    if(pid == 0){
     b96:	d165                	beqz	a0,b76 <main+0x14>
    if(pid > 0){
     b98:	fea053e3          	blez	a0,b7e <main+0x1c>
      wait(0);
     b9c:	4501                	li	a0,0
     b9e:	00000097          	auipc	ra,0x0
     ba2:	298080e7          	jalr	664(ra) # e36 <wait>
     ba6:	bfe1                	j	b7e <main+0x1c>

0000000000000ba8 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
     ba8:	1141                	addi	sp,sp,-16
     baa:	e406                	sd	ra,8(sp)
     bac:	e022                	sd	s0,0(sp)
     bae:	0800                	addi	s0,sp,16
  extern int main();
  main();
     bb0:	00000097          	auipc	ra,0x0
     bb4:	fb2080e7          	jalr	-78(ra) # b62 <main>
  exit(0);
     bb8:	4501                	li	a0,0
     bba:	00000097          	auipc	ra,0x0
     bbe:	274080e7          	jalr	628(ra) # e2e <exit>

0000000000000bc2 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     bc2:	1141                	addi	sp,sp,-16
     bc4:	e422                	sd	s0,8(sp)
     bc6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     bc8:	87aa                	mv	a5,a0
     bca:	0585                	addi	a1,a1,1
     bcc:	0785                	addi	a5,a5,1
     bce:	fff5c703          	lbu	a4,-1(a1)
     bd2:	fee78fa3          	sb	a4,-1(a5)
     bd6:	fb75                	bnez	a4,bca <strcpy+0x8>
    ;
  return os;
}
     bd8:	6422                	ld	s0,8(sp)
     bda:	0141                	addi	sp,sp,16
     bdc:	8082                	ret

0000000000000bde <strcmp>:

int
strcmp(const char *p, const char *q)
{
     bde:	1141                	addi	sp,sp,-16
     be0:	e422                	sd	s0,8(sp)
     be2:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     be4:	00054783          	lbu	a5,0(a0)
     be8:	cb91                	beqz	a5,bfc <strcmp+0x1e>
     bea:	0005c703          	lbu	a4,0(a1)
     bee:	00f71763          	bne	a4,a5,bfc <strcmp+0x1e>
    p++, q++;
     bf2:	0505                	addi	a0,a0,1
     bf4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     bf6:	00054783          	lbu	a5,0(a0)
     bfa:	fbe5                	bnez	a5,bea <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     bfc:	0005c503          	lbu	a0,0(a1)
}
     c00:	40a7853b          	subw	a0,a5,a0
     c04:	6422                	ld	s0,8(sp)
     c06:	0141                	addi	sp,sp,16
     c08:	8082                	ret

0000000000000c0a <strlen>:

uint
strlen(const char *s)
{
     c0a:	1141                	addi	sp,sp,-16
     c0c:	e422                	sd	s0,8(sp)
     c0e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     c10:	00054783          	lbu	a5,0(a0)
     c14:	cf91                	beqz	a5,c30 <strlen+0x26>
     c16:	0505                	addi	a0,a0,1
     c18:	87aa                	mv	a5,a0
     c1a:	4685                	li	a3,1
     c1c:	9e89                	subw	a3,a3,a0
     c1e:	00f6853b          	addw	a0,a3,a5
     c22:	0785                	addi	a5,a5,1
     c24:	fff7c703          	lbu	a4,-1(a5)
     c28:	fb7d                	bnez	a4,c1e <strlen+0x14>
    ;
  return n;
}
     c2a:	6422                	ld	s0,8(sp)
     c2c:	0141                	addi	sp,sp,16
     c2e:	8082                	ret
  for(n = 0; s[n]; n++)
     c30:	4501                	li	a0,0
     c32:	bfe5                	j	c2a <strlen+0x20>

0000000000000c34 <memset>:

void*
memset(void *dst, int c, uint n)
{
     c34:	1141                	addi	sp,sp,-16
     c36:	e422                	sd	s0,8(sp)
     c38:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     c3a:	ca19                	beqz	a2,c50 <memset+0x1c>
     c3c:	87aa                	mv	a5,a0
     c3e:	1602                	slli	a2,a2,0x20
     c40:	9201                	srli	a2,a2,0x20
     c42:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     c46:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     c4a:	0785                	addi	a5,a5,1
     c4c:	fee79de3          	bne	a5,a4,c46 <memset+0x12>
  }
  return dst;
}
     c50:	6422                	ld	s0,8(sp)
     c52:	0141                	addi	sp,sp,16
     c54:	8082                	ret

0000000000000c56 <strchr>:

char*
strchr(const char *s, char c)
{
     c56:	1141                	addi	sp,sp,-16
     c58:	e422                	sd	s0,8(sp)
     c5a:	0800                	addi	s0,sp,16
  for(; *s; s++)
     c5c:	00054783          	lbu	a5,0(a0)
     c60:	cb99                	beqz	a5,c76 <strchr+0x20>
    if(*s == c)
     c62:	00f58763          	beq	a1,a5,c70 <strchr+0x1a>
  for(; *s; s++)
     c66:	0505                	addi	a0,a0,1
     c68:	00054783          	lbu	a5,0(a0)
     c6c:	fbfd                	bnez	a5,c62 <strchr+0xc>
      return (char*)s;
  return 0;
     c6e:	4501                	li	a0,0
}
     c70:	6422                	ld	s0,8(sp)
     c72:	0141                	addi	sp,sp,16
     c74:	8082                	ret
  return 0;
     c76:	4501                	li	a0,0
     c78:	bfe5                	j	c70 <strchr+0x1a>

0000000000000c7a <gets>:

char*
gets(char *buf, int max)
{
     c7a:	711d                	addi	sp,sp,-96
     c7c:	ec86                	sd	ra,88(sp)
     c7e:	e8a2                	sd	s0,80(sp)
     c80:	e4a6                	sd	s1,72(sp)
     c82:	e0ca                	sd	s2,64(sp)
     c84:	fc4e                	sd	s3,56(sp)
     c86:	f852                	sd	s4,48(sp)
     c88:	f456                	sd	s5,40(sp)
     c8a:	f05a                	sd	s6,32(sp)
     c8c:	ec5e                	sd	s7,24(sp)
     c8e:	1080                	addi	s0,sp,96
     c90:	8baa                	mv	s7,a0
     c92:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     c94:	892a                	mv	s2,a0
     c96:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     c98:	4aa9                	li	s5,10
     c9a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     c9c:	89a6                	mv	s3,s1
     c9e:	2485                	addiw	s1,s1,1
     ca0:	0344d863          	bge	s1,s4,cd0 <gets+0x56>
    cc = read(0, &c, 1);
     ca4:	4605                	li	a2,1
     ca6:	faf40593          	addi	a1,s0,-81
     caa:	4501                	li	a0,0
     cac:	00000097          	auipc	ra,0x0
     cb0:	19a080e7          	jalr	410(ra) # e46 <read>
    if(cc < 1)
     cb4:	00a05e63          	blez	a0,cd0 <gets+0x56>
    buf[i++] = c;
     cb8:	faf44783          	lbu	a5,-81(s0)
     cbc:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     cc0:	01578763          	beq	a5,s5,cce <gets+0x54>
     cc4:	0905                	addi	s2,s2,1
     cc6:	fd679be3          	bne	a5,s6,c9c <gets+0x22>
  for(i=0; i+1 < max; ){
     cca:	89a6                	mv	s3,s1
     ccc:	a011                	j	cd0 <gets+0x56>
     cce:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     cd0:	99de                	add	s3,s3,s7
     cd2:	00098023          	sb	zero,0(s3)
  return buf;
}
     cd6:	855e                	mv	a0,s7
     cd8:	60e6                	ld	ra,88(sp)
     cda:	6446                	ld	s0,80(sp)
     cdc:	64a6                	ld	s1,72(sp)
     cde:	6906                	ld	s2,64(sp)
     ce0:	79e2                	ld	s3,56(sp)
     ce2:	7a42                	ld	s4,48(sp)
     ce4:	7aa2                	ld	s5,40(sp)
     ce6:	7b02                	ld	s6,32(sp)
     ce8:	6be2                	ld	s7,24(sp)
     cea:	6125                	addi	sp,sp,96
     cec:	8082                	ret

0000000000000cee <stat>:

int
stat(const char *n, struct stat *st)
{
     cee:	1101                	addi	sp,sp,-32
     cf0:	ec06                	sd	ra,24(sp)
     cf2:	e822                	sd	s0,16(sp)
     cf4:	e426                	sd	s1,8(sp)
     cf6:	e04a                	sd	s2,0(sp)
     cf8:	1000                	addi	s0,sp,32
     cfa:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     cfc:	4581                	li	a1,0
     cfe:	00000097          	auipc	ra,0x0
     d02:	170080e7          	jalr	368(ra) # e6e <open>
  if(fd < 0)
     d06:	02054563          	bltz	a0,d30 <stat+0x42>
     d0a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     d0c:	85ca                	mv	a1,s2
     d0e:	00000097          	auipc	ra,0x0
     d12:	178080e7          	jalr	376(ra) # e86 <fstat>
     d16:	892a                	mv	s2,a0
  close(fd);
     d18:	8526                	mv	a0,s1
     d1a:	00000097          	auipc	ra,0x0
     d1e:	13c080e7          	jalr	316(ra) # e56 <close>
  return r;
}
     d22:	854a                	mv	a0,s2
     d24:	60e2                	ld	ra,24(sp)
     d26:	6442                	ld	s0,16(sp)
     d28:	64a2                	ld	s1,8(sp)
     d2a:	6902                	ld	s2,0(sp)
     d2c:	6105                	addi	sp,sp,32
     d2e:	8082                	ret
    return -1;
     d30:	597d                	li	s2,-1
     d32:	bfc5                	j	d22 <stat+0x34>

0000000000000d34 <atoi>:

int
atoi(const char *s)
{
     d34:	1141                	addi	sp,sp,-16
     d36:	e422                	sd	s0,8(sp)
     d38:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     d3a:	00054683          	lbu	a3,0(a0)
     d3e:	fd06879b          	addiw	a5,a3,-48
     d42:	0ff7f793          	zext.b	a5,a5
     d46:	4625                	li	a2,9
     d48:	02f66863          	bltu	a2,a5,d78 <atoi+0x44>
     d4c:	872a                	mv	a4,a0
  n = 0;
     d4e:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
     d50:	0705                	addi	a4,a4,1
     d52:	0025179b          	slliw	a5,a0,0x2
     d56:	9fa9                	addw	a5,a5,a0
     d58:	0017979b          	slliw	a5,a5,0x1
     d5c:	9fb5                	addw	a5,a5,a3
     d5e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     d62:	00074683          	lbu	a3,0(a4)
     d66:	fd06879b          	addiw	a5,a3,-48
     d6a:	0ff7f793          	zext.b	a5,a5
     d6e:	fef671e3          	bgeu	a2,a5,d50 <atoi+0x1c>
  return n;
}
     d72:	6422                	ld	s0,8(sp)
     d74:	0141                	addi	sp,sp,16
     d76:	8082                	ret
  n = 0;
     d78:	4501                	li	a0,0
     d7a:	bfe5                	j	d72 <atoi+0x3e>

0000000000000d7c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     d7c:	1141                	addi	sp,sp,-16
     d7e:	e422                	sd	s0,8(sp)
     d80:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     d82:	02b57463          	bgeu	a0,a1,daa <memmove+0x2e>
    while(n-- > 0)
     d86:	00c05f63          	blez	a2,da4 <memmove+0x28>
     d8a:	1602                	slli	a2,a2,0x20
     d8c:	9201                	srli	a2,a2,0x20
     d8e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     d92:	872a                	mv	a4,a0
      *dst++ = *src++;
     d94:	0585                	addi	a1,a1,1
     d96:	0705                	addi	a4,a4,1
     d98:	fff5c683          	lbu	a3,-1(a1)
     d9c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     da0:	fee79ae3          	bne	a5,a4,d94 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     da4:	6422                	ld	s0,8(sp)
     da6:	0141                	addi	sp,sp,16
     da8:	8082                	ret
    dst += n;
     daa:	00c50733          	add	a4,a0,a2
    src += n;
     dae:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     db0:	fec05ae3          	blez	a2,da4 <memmove+0x28>
     db4:	fff6079b          	addiw	a5,a2,-1
     db8:	1782                	slli	a5,a5,0x20
     dba:	9381                	srli	a5,a5,0x20
     dbc:	fff7c793          	not	a5,a5
     dc0:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     dc2:	15fd                	addi	a1,a1,-1
     dc4:	177d                	addi	a4,a4,-1
     dc6:	0005c683          	lbu	a3,0(a1)
     dca:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     dce:	fee79ae3          	bne	a5,a4,dc2 <memmove+0x46>
     dd2:	bfc9                	j	da4 <memmove+0x28>

0000000000000dd4 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     dd4:	1141                	addi	sp,sp,-16
     dd6:	e422                	sd	s0,8(sp)
     dd8:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     dda:	ca05                	beqz	a2,e0a <memcmp+0x36>
     ddc:	fff6069b          	addiw	a3,a2,-1
     de0:	1682                	slli	a3,a3,0x20
     de2:	9281                	srli	a3,a3,0x20
     de4:	0685                	addi	a3,a3,1
     de6:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     de8:	00054783          	lbu	a5,0(a0)
     dec:	0005c703          	lbu	a4,0(a1)
     df0:	00e79863          	bne	a5,a4,e00 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     df4:	0505                	addi	a0,a0,1
    p2++;
     df6:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     df8:	fed518e3          	bne	a0,a3,de8 <memcmp+0x14>
  }
  return 0;
     dfc:	4501                	li	a0,0
     dfe:	a019                	j	e04 <memcmp+0x30>
      return *p1 - *p2;
     e00:	40e7853b          	subw	a0,a5,a4
}
     e04:	6422                	ld	s0,8(sp)
     e06:	0141                	addi	sp,sp,16
     e08:	8082                	ret
  return 0;
     e0a:	4501                	li	a0,0
     e0c:	bfe5                	j	e04 <memcmp+0x30>

0000000000000e0e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     e0e:	1141                	addi	sp,sp,-16
     e10:	e406                	sd	ra,8(sp)
     e12:	e022                	sd	s0,0(sp)
     e14:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     e16:	00000097          	auipc	ra,0x0
     e1a:	f66080e7          	jalr	-154(ra) # d7c <memmove>
}
     e1e:	60a2                	ld	ra,8(sp)
     e20:	6402                	ld	s0,0(sp)
     e22:	0141                	addi	sp,sp,16
     e24:	8082                	ret

0000000000000e26 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     e26:	4885                	li	a7,1
 ecall
     e28:	00000073          	ecall
 ret
     e2c:	8082                	ret

0000000000000e2e <exit>:
.global exit
exit:
 li a7, SYS_exit
     e2e:	4889                	li	a7,2
 ecall
     e30:	00000073          	ecall
 ret
     e34:	8082                	ret

0000000000000e36 <wait>:
.global wait
wait:
 li a7, SYS_wait
     e36:	488d                	li	a7,3
 ecall
     e38:	00000073          	ecall
 ret
     e3c:	8082                	ret

0000000000000e3e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     e3e:	4891                	li	a7,4
 ecall
     e40:	00000073          	ecall
 ret
     e44:	8082                	ret

0000000000000e46 <read>:
.global read
read:
 li a7, SYS_read
     e46:	4895                	li	a7,5
 ecall
     e48:	00000073          	ecall
 ret
     e4c:	8082                	ret

0000000000000e4e <write>:
.global write
write:
 li a7, SYS_write
     e4e:	48c1                	li	a7,16
 ecall
     e50:	00000073          	ecall
 ret
     e54:	8082                	ret

0000000000000e56 <close>:
.global close
close:
 li a7, SYS_close
     e56:	48d5                	li	a7,21
 ecall
     e58:	00000073          	ecall
 ret
     e5c:	8082                	ret

0000000000000e5e <kill>:
.global kill
kill:
 li a7, SYS_kill
     e5e:	4899                	li	a7,6
 ecall
     e60:	00000073          	ecall
 ret
     e64:	8082                	ret

0000000000000e66 <exec>:
.global exec
exec:
 li a7, SYS_exec
     e66:	489d                	li	a7,7
 ecall
     e68:	00000073          	ecall
 ret
     e6c:	8082                	ret

0000000000000e6e <open>:
.global open
open:
 li a7, SYS_open
     e6e:	48bd                	li	a7,15
 ecall
     e70:	00000073          	ecall
 ret
     e74:	8082                	ret

0000000000000e76 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     e76:	48c5                	li	a7,17
 ecall
     e78:	00000073          	ecall
 ret
     e7c:	8082                	ret

0000000000000e7e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     e7e:	48c9                	li	a7,18
 ecall
     e80:	00000073          	ecall
 ret
     e84:	8082                	ret

0000000000000e86 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     e86:	48a1                	li	a7,8
 ecall
     e88:	00000073          	ecall
 ret
     e8c:	8082                	ret

0000000000000e8e <link>:
.global link
link:
 li a7, SYS_link
     e8e:	48cd                	li	a7,19
 ecall
     e90:	00000073          	ecall
 ret
     e94:	8082                	ret

0000000000000e96 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     e96:	48d1                	li	a7,20
 ecall
     e98:	00000073          	ecall
 ret
     e9c:	8082                	ret

0000000000000e9e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     e9e:	48a5                	li	a7,9
 ecall
     ea0:	00000073          	ecall
 ret
     ea4:	8082                	ret

0000000000000ea6 <dup>:
.global dup
dup:
 li a7, SYS_dup
     ea6:	48a9                	li	a7,10
 ecall
     ea8:	00000073          	ecall
 ret
     eac:	8082                	ret

0000000000000eae <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     eae:	48ad                	li	a7,11
 ecall
     eb0:	00000073          	ecall
 ret
     eb4:	8082                	ret

0000000000000eb6 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     eb6:	48b1                	li	a7,12
 ecall
     eb8:	00000073          	ecall
 ret
     ebc:	8082                	ret

0000000000000ebe <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     ebe:	48b5                	li	a7,13
 ecall
     ec0:	00000073          	ecall
 ret
     ec4:	8082                	ret

0000000000000ec6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     ec6:	48b9                	li	a7,14
 ecall
     ec8:	00000073          	ecall
 ret
     ecc:	8082                	ret

0000000000000ece <hello>:
.global hello
hello:
 li a7, SYS_hello
     ece:	48d9                	li	a7,22
 ecall
     ed0:	00000073          	ecall
 ret
     ed4:	8082                	ret

0000000000000ed6 <sysinfo>:
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo
     ed6:	48dd                	li	a7,23
 ecall
     ed8:	00000073          	ecall
 ret
     edc:	8082                	ret

0000000000000ede <procinfo>:
.global procinfo
procinfo:
 li a7, SYS_procinfo
     ede:	48e1                	li	a7,24
 ecall
     ee0:	00000073          	ecall
 ret
     ee4:	8082                	ret

0000000000000ee6 <sched_tickets>:
.global sched_tickets
sched_tickets:
 li a7, SYS_sched_tickets
     ee6:	48e9                	li	a7,26
 ecall
     ee8:	00000073          	ecall
 ret
     eec:	8082                	ret

0000000000000eee <sched_statistics>:
.global sched_statistics
sched_statistics:
 li a7, SYS_sched_statistics
     eee:	48e5                	li	a7,25
 ecall
     ef0:	00000073          	ecall
 ret
     ef4:	8082                	ret

0000000000000ef6 <clone>:
.global clone
clone:
 li a7, SYS_clone
     ef6:	48ed                	li	a7,27
 ecall
     ef8:	00000073          	ecall
 ret
     efc:	8082                	ret

0000000000000efe <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     efe:	1101                	addi	sp,sp,-32
     f00:	ec06                	sd	ra,24(sp)
     f02:	e822                	sd	s0,16(sp)
     f04:	1000                	addi	s0,sp,32
     f06:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     f0a:	4605                	li	a2,1
     f0c:	fef40593          	addi	a1,s0,-17
     f10:	00000097          	auipc	ra,0x0
     f14:	f3e080e7          	jalr	-194(ra) # e4e <write>
}
     f18:	60e2                	ld	ra,24(sp)
     f1a:	6442                	ld	s0,16(sp)
     f1c:	6105                	addi	sp,sp,32
     f1e:	8082                	ret

0000000000000f20 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     f20:	7139                	addi	sp,sp,-64
     f22:	fc06                	sd	ra,56(sp)
     f24:	f822                	sd	s0,48(sp)
     f26:	f426                	sd	s1,40(sp)
     f28:	f04a                	sd	s2,32(sp)
     f2a:	ec4e                	sd	s3,24(sp)
     f2c:	0080                	addi	s0,sp,64
     f2e:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     f30:	c299                	beqz	a3,f36 <printint+0x16>
     f32:	0805c963          	bltz	a1,fc4 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     f36:	2581                	sext.w	a1,a1
  neg = 0;
     f38:	4881                	li	a7,0
     f3a:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
     f3e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     f40:	2601                	sext.w	a2,a2
     f42:	00001517          	auipc	a0,0x1
     f46:	86650513          	addi	a0,a0,-1946 # 17a8 <digits>
     f4a:	883a                	mv	a6,a4
     f4c:	2705                	addiw	a4,a4,1
     f4e:	02c5f7bb          	remuw	a5,a1,a2
     f52:	1782                	slli	a5,a5,0x20
     f54:	9381                	srli	a5,a5,0x20
     f56:	97aa                	add	a5,a5,a0
     f58:	0007c783          	lbu	a5,0(a5)
     f5c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     f60:	0005879b          	sext.w	a5,a1
     f64:	02c5d5bb          	divuw	a1,a1,a2
     f68:	0685                	addi	a3,a3,1
     f6a:	fec7f0e3          	bgeu	a5,a2,f4a <printint+0x2a>
  if(neg)
     f6e:	00088c63          	beqz	a7,f86 <printint+0x66>
    buf[i++] = '-';
     f72:	fd070793          	addi	a5,a4,-48
     f76:	00878733          	add	a4,a5,s0
     f7a:	02d00793          	li	a5,45
     f7e:	fef70823          	sb	a5,-16(a4)
     f82:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
     f86:	02e05863          	blez	a4,fb6 <printint+0x96>
     f8a:	fc040793          	addi	a5,s0,-64
     f8e:	00e78933          	add	s2,a5,a4
     f92:	fff78993          	addi	s3,a5,-1
     f96:	99ba                	add	s3,s3,a4
     f98:	377d                	addiw	a4,a4,-1
     f9a:	1702                	slli	a4,a4,0x20
     f9c:	9301                	srli	a4,a4,0x20
     f9e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
     fa2:	fff94583          	lbu	a1,-1(s2)
     fa6:	8526                	mv	a0,s1
     fa8:	00000097          	auipc	ra,0x0
     fac:	f56080e7          	jalr	-170(ra) # efe <putc>
  while(--i >= 0)
     fb0:	197d                	addi	s2,s2,-1
     fb2:	ff3918e3          	bne	s2,s3,fa2 <printint+0x82>
}
     fb6:	70e2                	ld	ra,56(sp)
     fb8:	7442                	ld	s0,48(sp)
     fba:	74a2                	ld	s1,40(sp)
     fbc:	7902                	ld	s2,32(sp)
     fbe:	69e2                	ld	s3,24(sp)
     fc0:	6121                	addi	sp,sp,64
     fc2:	8082                	ret
    x = -xx;
     fc4:	40b005bb          	negw	a1,a1
    neg = 1;
     fc8:	4885                	li	a7,1
    x = -xx;
     fca:	bf85                	j	f3a <printint+0x1a>

0000000000000fcc <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     fcc:	7119                	addi	sp,sp,-128
     fce:	fc86                	sd	ra,120(sp)
     fd0:	f8a2                	sd	s0,112(sp)
     fd2:	f4a6                	sd	s1,104(sp)
     fd4:	f0ca                	sd	s2,96(sp)
     fd6:	ecce                	sd	s3,88(sp)
     fd8:	e8d2                	sd	s4,80(sp)
     fda:	e4d6                	sd	s5,72(sp)
     fdc:	e0da                	sd	s6,64(sp)
     fde:	fc5e                	sd	s7,56(sp)
     fe0:	f862                	sd	s8,48(sp)
     fe2:	f466                	sd	s9,40(sp)
     fe4:	f06a                	sd	s10,32(sp)
     fe6:	ec6e                	sd	s11,24(sp)
     fe8:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
     fea:	0005c903          	lbu	s2,0(a1)
     fee:	18090f63          	beqz	s2,118c <vprintf+0x1c0>
     ff2:	8aaa                	mv	s5,a0
     ff4:	8b32                	mv	s6,a2
     ff6:	00158493          	addi	s1,a1,1
  state = 0;
     ffa:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
     ffc:	02500a13          	li	s4,37
    1000:	4c55                	li	s8,21
    1002:	00000c97          	auipc	s9,0x0
    1006:	74ec8c93          	addi	s9,s9,1870 # 1750 <lock_release+0x36e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    100a:	02800d93          	li	s11,40
  putc(fd, 'x');
    100e:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    1010:	00000b97          	auipc	s7,0x0
    1014:	798b8b93          	addi	s7,s7,1944 # 17a8 <digits>
    1018:	a839                	j	1036 <vprintf+0x6a>
        putc(fd, c);
    101a:	85ca                	mv	a1,s2
    101c:	8556                	mv	a0,s5
    101e:	00000097          	auipc	ra,0x0
    1022:	ee0080e7          	jalr	-288(ra) # efe <putc>
    1026:	a019                	j	102c <vprintf+0x60>
    } else if(state == '%'){
    1028:	01498d63          	beq	s3,s4,1042 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
    102c:	0485                	addi	s1,s1,1
    102e:	fff4c903          	lbu	s2,-1(s1)
    1032:	14090d63          	beqz	s2,118c <vprintf+0x1c0>
    if(state == 0){
    1036:	fe0999e3          	bnez	s3,1028 <vprintf+0x5c>
      if(c == '%'){
    103a:	ff4910e3          	bne	s2,s4,101a <vprintf+0x4e>
        state = '%';
    103e:	89d2                	mv	s3,s4
    1040:	b7f5                	j	102c <vprintf+0x60>
      if(c == 'd'){
    1042:	11490c63          	beq	s2,s4,115a <vprintf+0x18e>
    1046:	f9d9079b          	addiw	a5,s2,-99
    104a:	0ff7f793          	zext.b	a5,a5
    104e:	10fc6e63          	bltu	s8,a5,116a <vprintf+0x19e>
    1052:	f9d9079b          	addiw	a5,s2,-99
    1056:	0ff7f713          	zext.b	a4,a5
    105a:	10ec6863          	bltu	s8,a4,116a <vprintf+0x19e>
    105e:	00271793          	slli	a5,a4,0x2
    1062:	97e6                	add	a5,a5,s9
    1064:	439c                	lw	a5,0(a5)
    1066:	97e6                	add	a5,a5,s9
    1068:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
    106a:	008b0913          	addi	s2,s6,8
    106e:	4685                	li	a3,1
    1070:	4629                	li	a2,10
    1072:	000b2583          	lw	a1,0(s6)
    1076:	8556                	mv	a0,s5
    1078:	00000097          	auipc	ra,0x0
    107c:	ea8080e7          	jalr	-344(ra) # f20 <printint>
    1080:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
    1082:	4981                	li	s3,0
    1084:	b765                	j	102c <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    1086:	008b0913          	addi	s2,s6,8
    108a:	4681                	li	a3,0
    108c:	4629                	li	a2,10
    108e:	000b2583          	lw	a1,0(s6)
    1092:	8556                	mv	a0,s5
    1094:	00000097          	auipc	ra,0x0
    1098:	e8c080e7          	jalr	-372(ra) # f20 <printint>
    109c:	8b4a                	mv	s6,s2
      state = 0;
    109e:	4981                	li	s3,0
    10a0:	b771                	j	102c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    10a2:	008b0913          	addi	s2,s6,8
    10a6:	4681                	li	a3,0
    10a8:	866a                	mv	a2,s10
    10aa:	000b2583          	lw	a1,0(s6)
    10ae:	8556                	mv	a0,s5
    10b0:	00000097          	auipc	ra,0x0
    10b4:	e70080e7          	jalr	-400(ra) # f20 <printint>
    10b8:	8b4a                	mv	s6,s2
      state = 0;
    10ba:	4981                	li	s3,0
    10bc:	bf85                	j	102c <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    10be:	008b0793          	addi	a5,s6,8
    10c2:	f8f43423          	sd	a5,-120(s0)
    10c6:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    10ca:	03000593          	li	a1,48
    10ce:	8556                	mv	a0,s5
    10d0:	00000097          	auipc	ra,0x0
    10d4:	e2e080e7          	jalr	-466(ra) # efe <putc>
  putc(fd, 'x');
    10d8:	07800593          	li	a1,120
    10dc:	8556                	mv	a0,s5
    10de:	00000097          	auipc	ra,0x0
    10e2:	e20080e7          	jalr	-480(ra) # efe <putc>
    10e6:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    10e8:	03c9d793          	srli	a5,s3,0x3c
    10ec:	97de                	add	a5,a5,s7
    10ee:	0007c583          	lbu	a1,0(a5)
    10f2:	8556                	mv	a0,s5
    10f4:	00000097          	auipc	ra,0x0
    10f8:	e0a080e7          	jalr	-502(ra) # efe <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    10fc:	0992                	slli	s3,s3,0x4
    10fe:	397d                	addiw	s2,s2,-1
    1100:	fe0914e3          	bnez	s2,10e8 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
    1104:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    1108:	4981                	li	s3,0
    110a:	b70d                	j	102c <vprintf+0x60>
        s = va_arg(ap, char*);
    110c:	008b0913          	addi	s2,s6,8
    1110:	000b3983          	ld	s3,0(s6)
        if(s == 0)
    1114:	02098163          	beqz	s3,1136 <vprintf+0x16a>
        while(*s != 0){
    1118:	0009c583          	lbu	a1,0(s3)
    111c:	c5ad                	beqz	a1,1186 <vprintf+0x1ba>
          putc(fd, *s);
    111e:	8556                	mv	a0,s5
    1120:	00000097          	auipc	ra,0x0
    1124:	dde080e7          	jalr	-546(ra) # efe <putc>
          s++;
    1128:	0985                	addi	s3,s3,1
        while(*s != 0){
    112a:	0009c583          	lbu	a1,0(s3)
    112e:	f9e5                	bnez	a1,111e <vprintf+0x152>
        s = va_arg(ap, char*);
    1130:	8b4a                	mv	s6,s2
      state = 0;
    1132:	4981                	li	s3,0
    1134:	bde5                	j	102c <vprintf+0x60>
          s = "(null)";
    1136:	00000997          	auipc	s3,0x0
    113a:	61298993          	addi	s3,s3,1554 # 1748 <lock_release+0x366>
        while(*s != 0){
    113e:	85ee                	mv	a1,s11
    1140:	bff9                	j	111e <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
    1142:	008b0913          	addi	s2,s6,8
    1146:	000b4583          	lbu	a1,0(s6)
    114a:	8556                	mv	a0,s5
    114c:	00000097          	auipc	ra,0x0
    1150:	db2080e7          	jalr	-590(ra) # efe <putc>
    1154:	8b4a                	mv	s6,s2
      state = 0;
    1156:	4981                	li	s3,0
    1158:	bdd1                	j	102c <vprintf+0x60>
        putc(fd, c);
    115a:	85d2                	mv	a1,s4
    115c:	8556                	mv	a0,s5
    115e:	00000097          	auipc	ra,0x0
    1162:	da0080e7          	jalr	-608(ra) # efe <putc>
      state = 0;
    1166:	4981                	li	s3,0
    1168:	b5d1                	j	102c <vprintf+0x60>
        putc(fd, '%');
    116a:	85d2                	mv	a1,s4
    116c:	8556                	mv	a0,s5
    116e:	00000097          	auipc	ra,0x0
    1172:	d90080e7          	jalr	-624(ra) # efe <putc>
        putc(fd, c);
    1176:	85ca                	mv	a1,s2
    1178:	8556                	mv	a0,s5
    117a:	00000097          	auipc	ra,0x0
    117e:	d84080e7          	jalr	-636(ra) # efe <putc>
      state = 0;
    1182:	4981                	li	s3,0
    1184:	b565                	j	102c <vprintf+0x60>
        s = va_arg(ap, char*);
    1186:	8b4a                	mv	s6,s2
      state = 0;
    1188:	4981                	li	s3,0
    118a:	b54d                	j	102c <vprintf+0x60>
    }
  }
}
    118c:	70e6                	ld	ra,120(sp)
    118e:	7446                	ld	s0,112(sp)
    1190:	74a6                	ld	s1,104(sp)
    1192:	7906                	ld	s2,96(sp)
    1194:	69e6                	ld	s3,88(sp)
    1196:	6a46                	ld	s4,80(sp)
    1198:	6aa6                	ld	s5,72(sp)
    119a:	6b06                	ld	s6,64(sp)
    119c:	7be2                	ld	s7,56(sp)
    119e:	7c42                	ld	s8,48(sp)
    11a0:	7ca2                	ld	s9,40(sp)
    11a2:	7d02                	ld	s10,32(sp)
    11a4:	6de2                	ld	s11,24(sp)
    11a6:	6109                	addi	sp,sp,128
    11a8:	8082                	ret

00000000000011aa <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    11aa:	715d                	addi	sp,sp,-80
    11ac:	ec06                	sd	ra,24(sp)
    11ae:	e822                	sd	s0,16(sp)
    11b0:	1000                	addi	s0,sp,32
    11b2:	e010                	sd	a2,0(s0)
    11b4:	e414                	sd	a3,8(s0)
    11b6:	e818                	sd	a4,16(s0)
    11b8:	ec1c                	sd	a5,24(s0)
    11ba:	03043023          	sd	a6,32(s0)
    11be:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    11c2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    11c6:	8622                	mv	a2,s0
    11c8:	00000097          	auipc	ra,0x0
    11cc:	e04080e7          	jalr	-508(ra) # fcc <vprintf>
}
    11d0:	60e2                	ld	ra,24(sp)
    11d2:	6442                	ld	s0,16(sp)
    11d4:	6161                	addi	sp,sp,80
    11d6:	8082                	ret

00000000000011d8 <printf>:

void
printf(const char *fmt, ...)
{
    11d8:	711d                	addi	sp,sp,-96
    11da:	ec06                	sd	ra,24(sp)
    11dc:	e822                	sd	s0,16(sp)
    11de:	1000                	addi	s0,sp,32
    11e0:	e40c                	sd	a1,8(s0)
    11e2:	e810                	sd	a2,16(s0)
    11e4:	ec14                	sd	a3,24(s0)
    11e6:	f018                	sd	a4,32(s0)
    11e8:	f41c                	sd	a5,40(s0)
    11ea:	03043823          	sd	a6,48(s0)
    11ee:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    11f2:	00840613          	addi	a2,s0,8
    11f6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    11fa:	85aa                	mv	a1,a0
    11fc:	4505                	li	a0,1
    11fe:	00000097          	auipc	ra,0x0
    1202:	dce080e7          	jalr	-562(ra) # fcc <vprintf>
}
    1206:	60e2                	ld	ra,24(sp)
    1208:	6442                	ld	s0,16(sp)
    120a:	6125                	addi	sp,sp,96
    120c:	8082                	ret

000000000000120e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    120e:	1141                	addi	sp,sp,-16
    1210:	e422                	sd	s0,8(sp)
    1212:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1214:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1218:	00001797          	auipc	a5,0x1
    121c:	df87b783          	ld	a5,-520(a5) # 2010 <freep>
    1220:	a02d                	j	124a <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    1222:	4618                	lw	a4,8(a2)
    1224:	9f2d                	addw	a4,a4,a1
    1226:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    122a:	6398                	ld	a4,0(a5)
    122c:	6310                	ld	a2,0(a4)
    122e:	a83d                	j	126c <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    1230:	ff852703          	lw	a4,-8(a0)
    1234:	9f31                	addw	a4,a4,a2
    1236:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    1238:	ff053683          	ld	a3,-16(a0)
    123c:	a091                	j	1280 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    123e:	6398                	ld	a4,0(a5)
    1240:	00e7e463          	bltu	a5,a4,1248 <free+0x3a>
    1244:	00e6ea63          	bltu	a3,a4,1258 <free+0x4a>
{
    1248:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    124a:	fed7fae3          	bgeu	a5,a3,123e <free+0x30>
    124e:	6398                	ld	a4,0(a5)
    1250:	00e6e463          	bltu	a3,a4,1258 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1254:	fee7eae3          	bltu	a5,a4,1248 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
    1258:	ff852583          	lw	a1,-8(a0)
    125c:	6390                	ld	a2,0(a5)
    125e:	02059813          	slli	a6,a1,0x20
    1262:	01c85713          	srli	a4,a6,0x1c
    1266:	9736                	add	a4,a4,a3
    1268:	fae60de3          	beq	a2,a4,1222 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
    126c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    1270:	4790                	lw	a2,8(a5)
    1272:	02061593          	slli	a1,a2,0x20
    1276:	01c5d713          	srli	a4,a1,0x1c
    127a:	973e                	add	a4,a4,a5
    127c:	fae68ae3          	beq	a3,a4,1230 <free+0x22>
    p->s.ptr = bp->s.ptr;
    1280:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    1282:	00001717          	auipc	a4,0x1
    1286:	d8f73723          	sd	a5,-626(a4) # 2010 <freep>
}
    128a:	6422                	ld	s0,8(sp)
    128c:	0141                	addi	sp,sp,16
    128e:	8082                	ret

0000000000001290 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    1290:	7139                	addi	sp,sp,-64
    1292:	fc06                	sd	ra,56(sp)
    1294:	f822                	sd	s0,48(sp)
    1296:	f426                	sd	s1,40(sp)
    1298:	f04a                	sd	s2,32(sp)
    129a:	ec4e                	sd	s3,24(sp)
    129c:	e852                	sd	s4,16(sp)
    129e:	e456                	sd	s5,8(sp)
    12a0:	e05a                	sd	s6,0(sp)
    12a2:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    12a4:	02051493          	slli	s1,a0,0x20
    12a8:	9081                	srli	s1,s1,0x20
    12aa:	04bd                	addi	s1,s1,15
    12ac:	8091                	srli	s1,s1,0x4
    12ae:	0014899b          	addiw	s3,s1,1
    12b2:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    12b4:	00001517          	auipc	a0,0x1
    12b8:	d5c53503          	ld	a0,-676(a0) # 2010 <freep>
    12bc:	c515                	beqz	a0,12e8 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    12be:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    12c0:	4798                	lw	a4,8(a5)
    12c2:	02977f63          	bgeu	a4,s1,1300 <malloc+0x70>
    12c6:	8a4e                	mv	s4,s3
    12c8:	0009871b          	sext.w	a4,s3
    12cc:	6685                	lui	a3,0x1
    12ce:	00d77363          	bgeu	a4,a3,12d4 <malloc+0x44>
    12d2:	6a05                	lui	s4,0x1
    12d4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    12d8:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    12dc:	00001917          	auipc	s2,0x1
    12e0:	d3490913          	addi	s2,s2,-716 # 2010 <freep>
  if(p == (char*)-1)
    12e4:	5afd                	li	s5,-1
    12e6:	a895                	j	135a <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
    12e8:	00001797          	auipc	a5,0x1
    12ec:	12078793          	addi	a5,a5,288 # 2408 <base>
    12f0:	00001717          	auipc	a4,0x1
    12f4:	d2f73023          	sd	a5,-736(a4) # 2010 <freep>
    12f8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    12fa:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    12fe:	b7e1                	j	12c6 <malloc+0x36>
      if(p->s.size == nunits)
    1300:	02e48c63          	beq	s1,a4,1338 <malloc+0xa8>
        p->s.size -= nunits;
    1304:	4137073b          	subw	a4,a4,s3
    1308:	c798                	sw	a4,8(a5)
        p += p->s.size;
    130a:	02071693          	slli	a3,a4,0x20
    130e:	01c6d713          	srli	a4,a3,0x1c
    1312:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    1314:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    1318:	00001717          	auipc	a4,0x1
    131c:	cea73c23          	sd	a0,-776(a4) # 2010 <freep>
      return (void*)(p + 1);
    1320:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    1324:	70e2                	ld	ra,56(sp)
    1326:	7442                	ld	s0,48(sp)
    1328:	74a2                	ld	s1,40(sp)
    132a:	7902                	ld	s2,32(sp)
    132c:	69e2                	ld	s3,24(sp)
    132e:	6a42                	ld	s4,16(sp)
    1330:	6aa2                	ld	s5,8(sp)
    1332:	6b02                	ld	s6,0(sp)
    1334:	6121                	addi	sp,sp,64
    1336:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    1338:	6398                	ld	a4,0(a5)
    133a:	e118                	sd	a4,0(a0)
    133c:	bff1                	j	1318 <malloc+0x88>
  hp->s.size = nu;
    133e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    1342:	0541                	addi	a0,a0,16
    1344:	00000097          	auipc	ra,0x0
    1348:	eca080e7          	jalr	-310(ra) # 120e <free>
  return freep;
    134c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    1350:	d971                	beqz	a0,1324 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1352:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1354:	4798                	lw	a4,8(a5)
    1356:	fa9775e3          	bgeu	a4,s1,1300 <malloc+0x70>
    if(p == freep)
    135a:	00093703          	ld	a4,0(s2)
    135e:	853e                	mv	a0,a5
    1360:	fef719e3          	bne	a4,a5,1352 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
    1364:	8552                	mv	a0,s4
    1366:	00000097          	auipc	ra,0x0
    136a:	b50080e7          	jalr	-1200(ra) # eb6 <sbrk>
  if(p == (char*)-1)
    136e:	fd5518e3          	bne	a0,s5,133e <malloc+0xae>
        return 0;
    1372:	4501                	li	a0,0
    1374:	bf45                	j	1324 <malloc+0x94>

0000000000001376 <thread_create>:
#include "user/user.h"
#include "user/thread.h"

int
thread_create(void *(start_routine)(void*), void *arg)
{
    1376:	1101                	addi	sp,sp,-32
    1378:	ec06                	sd	ra,24(sp)
    137a:	e822                	sd	s0,16(sp)
    137c:	e426                	sd	s1,8(sp)
    137e:	e04a                	sd	s2,0(sp)
    1380:	1000                	addi	s0,sp,32
    1382:	84aa                	mv	s1,a0
    1384:	892e                	mv	s2,a1
    int pg_size = 4096*sizeof(void);
    void* stack = (void*)malloc(pg_size);
    1386:	6505                	lui	a0,0x1
    1388:	00000097          	auipc	ra,0x0
    138c:	f08080e7          	jalr	-248(ra) # 1290 <malloc>
    int t_id = clone(stack);
    1390:	00000097          	auipc	ra,0x0
    1394:	b66080e7          	jalr	-1178(ra) # ef6 <clone>
    if(t_id==0) {
    1398:	c901                	beqz	a0,13a8 <thread_create+0x32>
        (*start_routine)(arg);
        exit(0);
    }
    return 0;
}
    139a:	4501                	li	a0,0
    139c:	60e2                	ld	ra,24(sp)
    139e:	6442                	ld	s0,16(sp)
    13a0:	64a2                	ld	s1,8(sp)
    13a2:	6902                	ld	s2,0(sp)
    13a4:	6105                	addi	sp,sp,32
    13a6:	8082                	ret
        (*start_routine)(arg);
    13a8:	854a                	mv	a0,s2
    13aa:	9482                	jalr	s1
        exit(0);
    13ac:	4501                	li	a0,0
    13ae:	00000097          	auipc	ra,0x0
    13b2:	a80080e7          	jalr	-1408(ra) # e2e <exit>

00000000000013b6 <lock_init>:

void
lock_init(struct lock_t *lock)
{
    13b6:	1141                	addi	sp,sp,-16
    13b8:	e422                	sd	s0,8(sp)
    13ba:	0800                	addi	s0,sp,16
    lock->locked = 0;
    13bc:	00052023          	sw	zero,0(a0) # 1000 <vprintf+0x34>
}
    13c0:	6422                	ld	s0,8(sp)
    13c2:	0141                	addi	sp,sp,16
    13c4:	8082                	ret

00000000000013c6 <lock_acquire>:

void
lock_acquire(struct lock_t *lock)
{
    13c6:	1141                	addi	sp,sp,-16
    13c8:	e422                	sd	s0,8(sp)
    13ca:	0800                	addi	s0,sp,16
    while(__sync_lock_test_and_set(&lock->locked, 1)!= 0);
    13cc:	4705                	li	a4,1
    13ce:	87ba                	mv	a5,a4
    13d0:	0cf527af          	amoswap.w.aq	a5,a5,(a0)
    13d4:	2781                	sext.w	a5,a5
    13d6:	ffe5                	bnez	a5,13ce <lock_acquire+0x8>
    __sync_synchronize();
    13d8:	0ff0000f          	fence
}
    13dc:	6422                	ld	s0,8(sp)
    13de:	0141                	addi	sp,sp,16
    13e0:	8082                	ret

00000000000013e2 <lock_release>:

void
lock_release(struct lock_t *lock)
{
    13e2:	1141                	addi	sp,sp,-16
    13e4:	e422                	sd	s0,8(sp)
    13e6:	0800                	addi	s0,sp,16
    __sync_synchronize();
    13e8:	0ff0000f          	fence
    __sync_lock_release(&lock->locked, 0);
    13ec:	0f50000f          	fence	iorw,ow
    13f0:	0805202f          	amoswap.w	zero,zero,(a0)
}
    13f4:	6422                	ld	s0,8(sp)
    13f6:	0141                	addi	sp,sp,16
    13f8:	8082                	ret
