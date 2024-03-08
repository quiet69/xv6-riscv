
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	99013103          	ld	sp,-1648(sp) # 80008990 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	ra,8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	9b070713          	addi	a4,a4,-1616 # 80008a00 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	0fe78793          	addi	a5,a5,254 # 80006160 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc177>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	dcc78793          	addi	a5,a5,-564 # 80000e78 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	450080e7          	jalr	1104(ra) # 8000257a <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	784080e7          	jalr	1924(ra) # 800008be <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7159                	addi	sp,sp,-112
    80000166:	f486                	sd	ra,104(sp)
    80000168:	f0a2                	sd	s0,96(sp)
    8000016a:	eca6                	sd	s1,88(sp)
    8000016c:	e8ca                	sd	s2,80(sp)
    8000016e:	e4ce                	sd	s3,72(sp)
    80000170:	e0d2                	sd	s4,64(sp)
    80000172:	fc56                	sd	s5,56(sp)
    80000174:	f85a                	sd	s6,48(sp)
    80000176:	f45e                	sd	s7,40(sp)
    80000178:	f062                	sd	s8,32(sp)
    8000017a:	ec66                	sd	s9,24(sp)
    8000017c:	e86a                	sd	s10,16(sp)
    8000017e:	1880                	addi	s0,sp,112
    80000180:	8aaa                	mv	s5,a0
    80000182:	8a2e                	mv	s4,a1
    80000184:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000186:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018a:	00011517          	auipc	a0,0x11
    8000018e:	9b650513          	addi	a0,a0,-1610 # 80010b40 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a44080e7          	jalr	-1468(ra) # 80000bd6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	9a648493          	addi	s1,s1,-1626 # 80010b40 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	a3690913          	addi	s2,s2,-1482 # 80010bd8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    800001aa:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ac:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001ae:	4ca9                	li	s9,10
  while(n > 0){
    800001b0:	07305b63          	blez	s3,80000226 <consoleread+0xc2>
    while(cons.r == cons.w){
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71763          	bne	a4,a5,800001ea <consoleread+0x86>
      if(killed(myproc())){
    800001c0:	00002097          	auipc	ra,0x2
    800001c4:	804080e7          	jalr	-2044(ra) # 800019c4 <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	1fc080e7          	jalr	508(ra) # 800023c4 <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	f46080e7          	jalr	-186(ra) # 8000211c <sleep>
    while(cons.r == cons.w){
    800001de:	0984a783          	lw	a5,152(s1)
    800001e2:	09c4a703          	lw	a4,156(s1)
    800001e6:	fcf70de3          	beq	a4,a5,800001c0 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ea:	0017871b          	addiw	a4,a5,1
    800001ee:	08e4ac23          	sw	a4,152(s1)
    800001f2:	07f7f713          	andi	a4,a5,127
    800001f6:	9726                	add	a4,a4,s1
    800001f8:	01874703          	lbu	a4,24(a4)
    800001fc:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80000200:	077d0563          	beq	s10,s7,8000026a <consoleread+0x106>
    cbuf = c;
    80000204:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000208:	4685                	li	a3,1
    8000020a:	f9f40613          	addi	a2,s0,-97
    8000020e:	85d2                	mv	a1,s4
    80000210:	8556                	mv	a0,s5
    80000212:	00002097          	auipc	ra,0x2
    80000216:	312080e7          	jalr	786(ra) # 80002524 <either_copyout>
    8000021a:	01850663          	beq	a0,s8,80000226 <consoleread+0xc2>
    dst++;
    8000021e:	0a05                	addi	s4,s4,1
    --n;
    80000220:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80000222:	f99d17e3          	bne	s10,s9,800001b0 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000226:	00011517          	auipc	a0,0x11
    8000022a:	91a50513          	addi	a0,a0,-1766 # 80010b40 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	90450513          	addi	a0,a0,-1788 # 80010b40 <cons>
    80000244:	00001097          	auipc	ra,0x1
    80000248:	a46080e7          	jalr	-1466(ra) # 80000c8a <release>
        return -1;
    8000024c:	557d                	li	a0,-1
}
    8000024e:	70a6                	ld	ra,104(sp)
    80000250:	7406                	ld	s0,96(sp)
    80000252:	64e6                	ld	s1,88(sp)
    80000254:	6946                	ld	s2,80(sp)
    80000256:	69a6                	ld	s3,72(sp)
    80000258:	6a06                	ld	s4,64(sp)
    8000025a:	7ae2                	ld	s5,56(sp)
    8000025c:	7b42                	ld	s6,48(sp)
    8000025e:	7ba2                	ld	s7,40(sp)
    80000260:	7c02                	ld	s8,32(sp)
    80000262:	6ce2                	ld	s9,24(sp)
    80000264:	6d42                	ld	s10,16(sp)
    80000266:	6165                	addi	sp,sp,112
    80000268:	8082                	ret
      if(n < target){
    8000026a:	0009871b          	sext.w	a4,s3
    8000026e:	fb677ce3          	bgeu	a4,s6,80000226 <consoleread+0xc2>
        cons.r--;
    80000272:	00011717          	auipc	a4,0x11
    80000276:	96f72323          	sw	a5,-1690(a4) # 80010bd8 <cons+0x98>
    8000027a:	b775                	j	80000226 <consoleread+0xc2>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000284:	10000793          	li	a5,256
    80000288:	00f50a63          	beq	a0,a5,8000029c <consputc+0x20>
    uartputc_sync(c);
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	560080e7          	jalr	1376(ra) # 800007ec <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	54e080e7          	jalr	1358(ra) # 800007ec <uartputc_sync>
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	542080e7          	jalr	1346(ra) # 800007ec <uartputc_sync>
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	538080e7          	jalr	1336(ra) # 800007ec <uartputc_sync>
    800002bc:	bfe1                	j	80000294 <consputc+0x18>

00000000800002be <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002be:	1101                	addi	sp,sp,-32
    800002c0:	ec06                	sd	ra,24(sp)
    800002c2:	e822                	sd	s0,16(sp)
    800002c4:	e426                	sd	s1,8(sp)
    800002c6:	e04a                	sd	s2,0(sp)
    800002c8:	1000                	addi	s0,sp,32
    800002ca:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002cc:	00011517          	auipc	a0,0x11
    800002d0:	87450513          	addi	a0,a0,-1932 # 80010b40 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	902080e7          	jalr	-1790(ra) # 80000bd6 <acquire>

  switch(c){
    800002dc:	47d5                	li	a5,21
    800002de:	0af48663          	beq	s1,a5,8000038a <consoleintr+0xcc>
    800002e2:	0297ca63          	blt	a5,s1,80000316 <consoleintr+0x58>
    800002e6:	47a1                	li	a5,8
    800002e8:	0ef48763          	beq	s1,a5,800003d6 <consoleintr+0x118>
    800002ec:	47c1                	li	a5,16
    800002ee:	10f49a63          	bne	s1,a5,80000402 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f2:	00002097          	auipc	ra,0x2
    800002f6:	2de080e7          	jalr	734(ra) # 800025d0 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00011517          	auipc	a0,0x11
    800002fe:	84650513          	addi	a0,a0,-1978 # 80010b40 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	988080e7          	jalr	-1656(ra) # 80000c8a <release>
}
    8000030a:	60e2                	ld	ra,24(sp)
    8000030c:	6442                	ld	s0,16(sp)
    8000030e:	64a2                	ld	s1,8(sp)
    80000310:	6902                	ld	s2,0(sp)
    80000312:	6105                	addi	sp,sp,32
    80000314:	8082                	ret
  switch(c){
    80000316:	07f00793          	li	a5,127
    8000031a:	0af48e63          	beq	s1,a5,800003d6 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000031e:	00011717          	auipc	a4,0x11
    80000322:	82270713          	addi	a4,a4,-2014 # 80010b40 <cons>
    80000326:	0a072783          	lw	a5,160(a4)
    8000032a:	09872703          	lw	a4,152(a4)
    8000032e:	9f99                	subw	a5,a5,a4
    80000330:	07f00713          	li	a4,127
    80000334:	fcf763e3          	bltu	a4,a5,800002fa <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000338:	47b5                	li	a5,13
    8000033a:	0cf48763          	beq	s1,a5,80000408 <consoleintr+0x14a>
      consputc(c);
    8000033e:	8526                	mv	a0,s1
    80000340:	00000097          	auipc	ra,0x0
    80000344:	f3c080e7          	jalr	-196(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000348:	00010797          	auipc	a5,0x10
    8000034c:	7f878793          	addi	a5,a5,2040 # 80010b40 <cons>
    80000350:	0a07a683          	lw	a3,160(a5)
    80000354:	0016871b          	addiw	a4,a3,1
    80000358:	0007061b          	sext.w	a2,a4
    8000035c:	0ae7a023          	sw	a4,160(a5)
    80000360:	07f6f693          	andi	a3,a3,127
    80000364:	97b6                	add	a5,a5,a3
    80000366:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000036a:	47a9                	li	a5,10
    8000036c:	0cf48563          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000370:	4791                	li	a5,4
    80000372:	0cf48263          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000376:	00011797          	auipc	a5,0x11
    8000037a:	8627a783          	lw	a5,-1950(a5) # 80010bd8 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00010717          	auipc	a4,0x10
    8000038e:	7b670713          	addi	a4,a4,1974 # 80010b40 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000039a:	00010497          	auipc	s1,0x10
    8000039e:	7a648493          	addi	s1,s1,1958 # 80010b40 <cons>
    while(cons.e != cons.w &&
    800003a2:	4929                	li	s2,10
    800003a4:	f4f70be3          	beq	a4,a5,800002fa <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	07f7f713          	andi	a4,a5,127
    800003ae:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b0:	01874703          	lbu	a4,24(a4)
    800003b4:	f52703e3          	beq	a4,s2,800002fa <consoleintr+0x3c>
      cons.e--;
    800003b8:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003bc:	10000513          	li	a0,256
    800003c0:	00000097          	auipc	ra,0x0
    800003c4:	ebc080e7          	jalr	-324(ra) # 8000027c <consputc>
    while(cons.e != cons.w &&
    800003c8:	0a04a783          	lw	a5,160(s1)
    800003cc:	09c4a703          	lw	a4,156(s1)
    800003d0:	fcf71ce3          	bne	a4,a5,800003a8 <consoleintr+0xea>
    800003d4:	b71d                	j	800002fa <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d6:	00010717          	auipc	a4,0x10
    800003da:	76a70713          	addi	a4,a4,1898 # 80010b40 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00010717          	auipc	a4,0x10
    800003f0:	7ef72a23          	sw	a5,2036(a4) # 80010be0 <cons+0xa0>
      consputc(BACKSPACE);
    800003f4:	10000513          	li	a0,256
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	e84080e7          	jalr	-380(ra) # 8000027c <consputc>
    80000400:	bded                	j	800002fa <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000402:	ee048ce3          	beqz	s1,800002fa <consoleintr+0x3c>
    80000406:	bf21                	j	8000031e <consoleintr+0x60>
      consputc(c);
    80000408:	4529                	li	a0,10
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e72080e7          	jalr	-398(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000412:	00010797          	auipc	a5,0x10
    80000416:	72e78793          	addi	a5,a5,1838 # 80010b40 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000436:	00010797          	auipc	a5,0x10
    8000043a:	7ac7a323          	sw	a2,1958(a5) # 80010bdc <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00010517          	auipc	a0,0x10
    80000442:	79a50513          	addi	a0,a0,1946 # 80010bd8 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	d3a080e7          	jalr	-710(ra) # 80002180 <wakeup>
    8000044e:	b575                	j	800002fa <consoleintr+0x3c>

0000000080000450 <consoleinit>:

void
consoleinit(void)
{
    80000450:	1141                	addi	sp,sp,-16
    80000452:	e406                	sd	ra,8(sp)
    80000454:	e022                	sd	s0,0(sp)
    80000456:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000458:	00008597          	auipc	a1,0x8
    8000045c:	bb858593          	addi	a1,a1,-1096 # 80008010 <etext+0x10>
    80000460:	00010517          	auipc	a0,0x10
    80000464:	6e050513          	addi	a0,a0,1760 # 80010b40 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32c080e7          	jalr	812(ra) # 8000079c <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00021797          	auipc	a5,0x21
    8000047c:	07878793          	addi	a5,a5,120 # 800214f0 <devsw>
    80000480:	00000717          	auipc	a4,0x0
    80000484:	ce470713          	addi	a4,a4,-796 # 80000164 <consoleread>
    80000488:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c7670713          	addi	a4,a4,-906 # 80000100 <consolewrite>
    80000492:	ef98                	sd	a4,24(a5)
}
    80000494:	60a2                	ld	ra,8(sp)
    80000496:	6402                	ld	s0,0(sp)
    80000498:	0141                	addi	sp,sp,16
    8000049a:	8082                	ret

000000008000049c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049c:	7179                	addi	sp,sp,-48
    8000049e:	f406                	sd	ra,40(sp)
    800004a0:	f022                	sd	s0,32(sp)
    800004a2:	ec26                	sd	s1,24(sp)
    800004a4:	e84a                	sd	s2,16(sp)
    800004a6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a8:	c219                	beqz	a2,800004ae <printint+0x12>
    800004aa:	08054763          	bltz	a0,80000538 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004ae:	2501                	sext.w	a0,a0
    800004b0:	4881                	li	a7,0
    800004b2:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b8660613          	addi	a2,a2,-1146 # 80008040 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

  if(sign)
    800004e6:	00088c63          	beqz	a7,800004fe <printint+0x62>
    buf[i++] = '-';
    800004ea:	fe070793          	addi	a5,a4,-32
    800004ee:	00878733          	add	a4,a5,s0
    800004f2:	02d00793          	li	a5,45
    800004f6:	fef70823          	sb	a5,-16(a4)
    800004fa:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fe:	02e05763          	blez	a4,8000052c <printint+0x90>
    80000502:	fd040793          	addi	a5,s0,-48
    80000506:	00e784b3          	add	s1,a5,a4
    8000050a:	fff78913          	addi	s2,a5,-1
    8000050e:	993a                	add	s2,s2,a4
    80000510:	377d                	addiw	a4,a4,-1
    80000512:	1702                	slli	a4,a4,0x20
    80000514:	9301                	srli	a4,a4,0x20
    80000516:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000051a:	fff4c503          	lbu	a0,-1(s1)
    8000051e:	00000097          	auipc	ra,0x0
    80000522:	d5e080e7          	jalr	-674(ra) # 8000027c <consputc>
  while(--i >= 0)
    80000526:	14fd                	addi	s1,s1,-1
    80000528:	ff2499e3          	bne	s1,s2,8000051a <printint+0x7e>
}
    8000052c:	70a2                	ld	ra,40(sp)
    8000052e:	7402                	ld	s0,32(sp)
    80000530:	64e2                	ld	s1,24(sp)
    80000532:	6942                	ld	s2,16(sp)
    80000534:	6145                	addi	sp,sp,48
    80000536:	8082                	ret
    x = -xx;
    80000538:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000053c:	4885                	li	a7,1
    x = -xx;
    8000053e:	bf95                	j	800004b2 <printint+0x16>

0000000080000540 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000540:	1101                	addi	sp,sp,-32
    80000542:	ec06                	sd	ra,24(sp)
    80000544:	e822                	sd	s0,16(sp)
    80000546:	e426                	sd	s1,8(sp)
    80000548:	1000                	addi	s0,sp,32
    8000054a:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054c:	00010797          	auipc	a5,0x10
    80000550:	6a07aa23          	sw	zero,1716(a5) # 80010c00 <pr+0x18>
  printf("panic: ");
    80000554:	00008517          	auipc	a0,0x8
    80000558:	ac450513          	addi	a0,a0,-1340 # 80008018 <etext+0x18>
    8000055c:	00000097          	auipc	ra,0x0
    80000560:	02e080e7          	jalr	46(ra) # 8000058a <printf>
  printf(s);
    80000564:	8526                	mv	a0,s1
    80000566:	00000097          	auipc	ra,0x0
    8000056a:	024080e7          	jalr	36(ra) # 8000058a <printf>
  printf("\n");
    8000056e:	00008517          	auipc	a0,0x8
    80000572:	b5a50513          	addi	a0,a0,-1190 # 800080c8 <digits+0x88>
    80000576:	00000097          	auipc	ra,0x0
    8000057a:	014080e7          	jalr	20(ra) # 8000058a <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057e:	4785                	li	a5,1
    80000580:	00008717          	auipc	a4,0x8
    80000584:	42f72823          	sw	a5,1072(a4) # 800089b0 <panicked>
  for(;;)
    80000588:	a001                	j	80000588 <panic+0x48>

000000008000058a <printf>:
{
    8000058a:	7131                	addi	sp,sp,-192
    8000058c:	fc86                	sd	ra,120(sp)
    8000058e:	f8a2                	sd	s0,112(sp)
    80000590:	f4a6                	sd	s1,104(sp)
    80000592:	f0ca                	sd	s2,96(sp)
    80000594:	ecce                	sd	s3,88(sp)
    80000596:	e8d2                	sd	s4,80(sp)
    80000598:	e4d6                	sd	s5,72(sp)
    8000059a:	e0da                	sd	s6,64(sp)
    8000059c:	fc5e                	sd	s7,56(sp)
    8000059e:	f862                	sd	s8,48(sp)
    800005a0:	f466                	sd	s9,40(sp)
    800005a2:	f06a                	sd	s10,32(sp)
    800005a4:	ec6e                	sd	s11,24(sp)
    800005a6:	0100                	addi	s0,sp,128
    800005a8:	8a2a                	mv	s4,a0
    800005aa:	e40c                	sd	a1,8(s0)
    800005ac:	e810                	sd	a2,16(s0)
    800005ae:	ec14                	sd	a3,24(s0)
    800005b0:	f018                	sd	a4,32(s0)
    800005b2:	f41c                	sd	a5,40(s0)
    800005b4:	03043823          	sd	a6,48(s0)
    800005b8:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005bc:	00010d97          	auipc	s11,0x10
    800005c0:	644dad83          	lw	s11,1604(s11) # 80010c00 <pr+0x18>
  if(locking)
    800005c4:	020d9b63          	bnez	s11,800005fa <printf+0x70>
  if (fmt == 0)
    800005c8:	040a0263          	beqz	s4,8000060c <printf+0x82>
  va_start(ap, fmt);
    800005cc:	00840793          	addi	a5,s0,8
    800005d0:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d4:	000a4503          	lbu	a0,0(s4)
    800005d8:	14050f63          	beqz	a0,80000736 <printf+0x1ac>
    800005dc:	4981                	li	s3,0
    if(c != '%'){
    800005de:	02500a93          	li	s5,37
    switch(c){
    800005e2:	07000b93          	li	s7,112
  consputc('x');
    800005e6:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e8:	00008b17          	auipc	s6,0x8
    800005ec:	a58b0b13          	addi	s6,s6,-1448 # 80008040 <digits>
    switch(c){
    800005f0:	07300c93          	li	s9,115
    800005f4:	06400c13          	li	s8,100
    800005f8:	a82d                	j	80000632 <printf+0xa8>
    acquire(&pr.lock);
    800005fa:	00010517          	auipc	a0,0x10
    800005fe:	5ee50513          	addi	a0,a0,1518 # 80010be8 <pr>
    80000602:	00000097          	auipc	ra,0x0
    80000606:	5d4080e7          	jalr	1492(ra) # 80000bd6 <acquire>
    8000060a:	bf7d                	j	800005c8 <printf+0x3e>
    panic("null fmt");
    8000060c:	00008517          	auipc	a0,0x8
    80000610:	a1c50513          	addi	a0,a0,-1508 # 80008028 <etext+0x28>
    80000614:	00000097          	auipc	ra,0x0
    80000618:	f2c080e7          	jalr	-212(ra) # 80000540 <panic>
      consputc(c);
    8000061c:	00000097          	auipc	ra,0x0
    80000620:	c60080e7          	jalr	-928(ra) # 8000027c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000624:	2985                	addiw	s3,s3,1
    80000626:	013a07b3          	add	a5,s4,s3
    8000062a:	0007c503          	lbu	a0,0(a5)
    8000062e:	10050463          	beqz	a0,80000736 <printf+0x1ac>
    if(c != '%'){
    80000632:	ff5515e3          	bne	a0,s5,8000061c <printf+0x92>
    c = fmt[++i] & 0xff;
    80000636:	2985                	addiw	s3,s3,1
    80000638:	013a07b3          	add	a5,s4,s3
    8000063c:	0007c783          	lbu	a5,0(a5)
    80000640:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000644:	cbed                	beqz	a5,80000736 <printf+0x1ac>
    switch(c){
    80000646:	05778a63          	beq	a5,s7,8000069a <printf+0x110>
    8000064a:	02fbf663          	bgeu	s7,a5,80000676 <printf+0xec>
    8000064e:	09978863          	beq	a5,s9,800006de <printf+0x154>
    80000652:	07800713          	li	a4,120
    80000656:	0ce79563          	bne	a5,a4,80000720 <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    8000065a:	f8843783          	ld	a5,-120(s0)
    8000065e:	00878713          	addi	a4,a5,8
    80000662:	f8e43423          	sd	a4,-120(s0)
    80000666:	4605                	li	a2,1
    80000668:	85ea                	mv	a1,s10
    8000066a:	4388                	lw	a0,0(a5)
    8000066c:	00000097          	auipc	ra,0x0
    80000670:	e30080e7          	jalr	-464(ra) # 8000049c <printint>
      break;
    80000674:	bf45                	j	80000624 <printf+0x9a>
    switch(c){
    80000676:	09578f63          	beq	a5,s5,80000714 <printf+0x18a>
    8000067a:	0b879363          	bne	a5,s8,80000720 <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067e:	f8843783          	ld	a5,-120(s0)
    80000682:	00878713          	addi	a4,a5,8
    80000686:	f8e43423          	sd	a4,-120(s0)
    8000068a:	4605                	li	a2,1
    8000068c:	45a9                	li	a1,10
    8000068e:	4388                	lw	a0,0(a5)
    80000690:	00000097          	auipc	ra,0x0
    80000694:	e0c080e7          	jalr	-500(ra) # 8000049c <printint>
      break;
    80000698:	b771                	j	80000624 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    8000069a:	f8843783          	ld	a5,-120(s0)
    8000069e:	00878713          	addi	a4,a5,8
    800006a2:	f8e43423          	sd	a4,-120(s0)
    800006a6:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006aa:	03000513          	li	a0,48
    800006ae:	00000097          	auipc	ra,0x0
    800006b2:	bce080e7          	jalr	-1074(ra) # 8000027c <consputc>
  consputc('x');
    800006b6:	07800513          	li	a0,120
    800006ba:	00000097          	auipc	ra,0x0
    800006be:	bc2080e7          	jalr	-1086(ra) # 8000027c <consputc>
    800006c2:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c4:	03c95793          	srli	a5,s2,0x3c
    800006c8:	97da                	add	a5,a5,s6
    800006ca:	0007c503          	lbu	a0,0(a5)
    800006ce:	00000097          	auipc	ra,0x0
    800006d2:	bae080e7          	jalr	-1106(ra) # 8000027c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d6:	0912                	slli	s2,s2,0x4
    800006d8:	34fd                	addiw	s1,s1,-1
    800006da:	f4ed                	bnez	s1,800006c4 <printf+0x13a>
    800006dc:	b7a1                	j	80000624 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006de:	f8843783          	ld	a5,-120(s0)
    800006e2:	00878713          	addi	a4,a5,8
    800006e6:	f8e43423          	sd	a4,-120(s0)
    800006ea:	6384                	ld	s1,0(a5)
    800006ec:	cc89                	beqz	s1,80000706 <printf+0x17c>
      for(; *s; s++)
    800006ee:	0004c503          	lbu	a0,0(s1)
    800006f2:	d90d                	beqz	a0,80000624 <printf+0x9a>
        consputc(*s);
    800006f4:	00000097          	auipc	ra,0x0
    800006f8:	b88080e7          	jalr	-1144(ra) # 8000027c <consputc>
      for(; *s; s++)
    800006fc:	0485                	addi	s1,s1,1
    800006fe:	0004c503          	lbu	a0,0(s1)
    80000702:	f96d                	bnez	a0,800006f4 <printf+0x16a>
    80000704:	b705                	j	80000624 <printf+0x9a>
        s = "(null)";
    80000706:	00008497          	auipc	s1,0x8
    8000070a:	91a48493          	addi	s1,s1,-1766 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070e:	02800513          	li	a0,40
    80000712:	b7cd                	j	800006f4 <printf+0x16a>
      consputc('%');
    80000714:	8556                	mv	a0,s5
    80000716:	00000097          	auipc	ra,0x0
    8000071a:	b66080e7          	jalr	-1178(ra) # 8000027c <consputc>
      break;
    8000071e:	b719                	j	80000624 <printf+0x9a>
      consputc('%');
    80000720:	8556                	mv	a0,s5
    80000722:	00000097          	auipc	ra,0x0
    80000726:	b5a080e7          	jalr	-1190(ra) # 8000027c <consputc>
      consputc(c);
    8000072a:	8526                	mv	a0,s1
    8000072c:	00000097          	auipc	ra,0x0
    80000730:	b50080e7          	jalr	-1200(ra) # 8000027c <consputc>
      break;
    80000734:	bdc5                	j	80000624 <printf+0x9a>
  if(locking)
    80000736:	020d9163          	bnez	s11,80000758 <printf+0x1ce>
}
    8000073a:	70e6                	ld	ra,120(sp)
    8000073c:	7446                	ld	s0,112(sp)
    8000073e:	74a6                	ld	s1,104(sp)
    80000740:	7906                	ld	s2,96(sp)
    80000742:	69e6                	ld	s3,88(sp)
    80000744:	6a46                	ld	s4,80(sp)
    80000746:	6aa6                	ld	s5,72(sp)
    80000748:	6b06                	ld	s6,64(sp)
    8000074a:	7be2                	ld	s7,56(sp)
    8000074c:	7c42                	ld	s8,48(sp)
    8000074e:	7ca2                	ld	s9,40(sp)
    80000750:	7d02                	ld	s10,32(sp)
    80000752:	6de2                	ld	s11,24(sp)
    80000754:	6129                	addi	sp,sp,192
    80000756:	8082                	ret
    release(&pr.lock);
    80000758:	00010517          	auipc	a0,0x10
    8000075c:	49050513          	addi	a0,a0,1168 # 80010be8 <pr>
    80000760:	00000097          	auipc	ra,0x0
    80000764:	52a080e7          	jalr	1322(ra) # 80000c8a <release>
}
    80000768:	bfc9                	j	8000073a <printf+0x1b0>

000000008000076a <printfinit>:
    ;
}

void
printfinit(void)
{
    8000076a:	1101                	addi	sp,sp,-32
    8000076c:	ec06                	sd	ra,24(sp)
    8000076e:	e822                	sd	s0,16(sp)
    80000770:	e426                	sd	s1,8(sp)
    80000772:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000774:	00010497          	auipc	s1,0x10
    80000778:	47448493          	addi	s1,s1,1140 # 80010be8 <pr>
    8000077c:	00008597          	auipc	a1,0x8
    80000780:	8bc58593          	addi	a1,a1,-1860 # 80008038 <etext+0x38>
    80000784:	8526                	mv	a0,s1
    80000786:	00000097          	auipc	ra,0x0
    8000078a:	3c0080e7          	jalr	960(ra) # 80000b46 <initlock>
  pr.locking = 1;
    8000078e:	4785                	li	a5,1
    80000790:	cc9c                	sw	a5,24(s1)
}
    80000792:	60e2                	ld	ra,24(sp)
    80000794:	6442                	ld	s0,16(sp)
    80000796:	64a2                	ld	s1,8(sp)
    80000798:	6105                	addi	sp,sp,32
    8000079a:	8082                	ret

000000008000079c <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000079c:	1141                	addi	sp,sp,-16
    8000079e:	e406                	sd	ra,8(sp)
    800007a0:	e022                	sd	s0,0(sp)
    800007a2:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a4:	100007b7          	lui	a5,0x10000
    800007a8:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007ac:	f8000713          	li	a4,-128
    800007b0:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b4:	470d                	li	a4,3
    800007b6:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007ba:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007be:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c2:	469d                	li	a3,7
    800007c4:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c8:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007cc:	00008597          	auipc	a1,0x8
    800007d0:	88c58593          	addi	a1,a1,-1908 # 80008058 <digits+0x18>
    800007d4:	00010517          	auipc	a0,0x10
    800007d8:	43450513          	addi	a0,a0,1076 # 80010c08 <uart_tx_lock>
    800007dc:	00000097          	auipc	ra,0x0
    800007e0:	36a080e7          	jalr	874(ra) # 80000b46 <initlock>
}
    800007e4:	60a2                	ld	ra,8(sp)
    800007e6:	6402                	ld	s0,0(sp)
    800007e8:	0141                	addi	sp,sp,16
    800007ea:	8082                	ret

00000000800007ec <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007ec:	1101                	addi	sp,sp,-32
    800007ee:	ec06                	sd	ra,24(sp)
    800007f0:	e822                	sd	s0,16(sp)
    800007f2:	e426                	sd	s1,8(sp)
    800007f4:	1000                	addi	s0,sp,32
    800007f6:	84aa                	mv	s1,a0
  push_off();
    800007f8:	00000097          	auipc	ra,0x0
    800007fc:	392080e7          	jalr	914(ra) # 80000b8a <push_off>

  if(panicked){
    80000800:	00008797          	auipc	a5,0x8
    80000804:	1b07a783          	lw	a5,432(a5) # 800089b0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000808:	10000737          	lui	a4,0x10000
  if(panicked){
    8000080c:	c391                	beqz	a5,80000810 <uartputc_sync+0x24>
    for(;;)
    8000080e:	a001                	j	8000080e <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000810:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000814:	0207f793          	andi	a5,a5,32
    80000818:	dfe5                	beqz	a5,80000810 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000081a:	0ff4f513          	zext.b	a0,s1
    8000081e:	100007b7          	lui	a5,0x10000
    80000822:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000826:	00000097          	auipc	ra,0x0
    8000082a:	404080e7          	jalr	1028(ra) # 80000c2a <pop_off>
}
    8000082e:	60e2                	ld	ra,24(sp)
    80000830:	6442                	ld	s0,16(sp)
    80000832:	64a2                	ld	s1,8(sp)
    80000834:	6105                	addi	sp,sp,32
    80000836:	8082                	ret

0000000080000838 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000838:	00008797          	auipc	a5,0x8
    8000083c:	1807b783          	ld	a5,384(a5) # 800089b8 <uart_tx_r>
    80000840:	00008717          	auipc	a4,0x8
    80000844:	18073703          	ld	a4,384(a4) # 800089c0 <uart_tx_w>
    80000848:	06f70a63          	beq	a4,a5,800008bc <uartstart+0x84>
{
    8000084c:	7139                	addi	sp,sp,-64
    8000084e:	fc06                	sd	ra,56(sp)
    80000850:	f822                	sd	s0,48(sp)
    80000852:	f426                	sd	s1,40(sp)
    80000854:	f04a                	sd	s2,32(sp)
    80000856:	ec4e                	sd	s3,24(sp)
    80000858:	e852                	sd	s4,16(sp)
    8000085a:	e456                	sd	s5,8(sp)
    8000085c:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085e:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000862:	00010a17          	auipc	s4,0x10
    80000866:	3a6a0a13          	addi	s4,s4,934 # 80010c08 <uart_tx_lock>
    uart_tx_r += 1;
    8000086a:	00008497          	auipc	s1,0x8
    8000086e:	14e48493          	addi	s1,s1,334 # 800089b8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000872:	00008997          	auipc	s3,0x8
    80000876:	14e98993          	addi	s3,s3,334 # 800089c0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000087a:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087e:	02077713          	andi	a4,a4,32
    80000882:	c705                	beqz	a4,800008aa <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000884:	01f7f713          	andi	a4,a5,31
    80000888:	9752                	add	a4,a4,s4
    8000088a:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088e:	0785                	addi	a5,a5,1
    80000890:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80000892:	8526                	mv	a0,s1
    80000894:	00002097          	auipc	ra,0x2
    80000898:	8ec080e7          	jalr	-1812(ra) # 80002180 <wakeup>
    
    WriteReg(THR, c);
    8000089c:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008a0:	609c                	ld	a5,0(s1)
    800008a2:	0009b703          	ld	a4,0(s3)
    800008a6:	fcf71ae3          	bne	a4,a5,8000087a <uartstart+0x42>
  }
}
    800008aa:	70e2                	ld	ra,56(sp)
    800008ac:	7442                	ld	s0,48(sp)
    800008ae:	74a2                	ld	s1,40(sp)
    800008b0:	7902                	ld	s2,32(sp)
    800008b2:	69e2                	ld	s3,24(sp)
    800008b4:	6a42                	ld	s4,16(sp)
    800008b6:	6aa2                	ld	s5,8(sp)
    800008b8:	6121                	addi	sp,sp,64
    800008ba:	8082                	ret
    800008bc:	8082                	ret

00000000800008be <uartputc>:
{
    800008be:	7179                	addi	sp,sp,-48
    800008c0:	f406                	sd	ra,40(sp)
    800008c2:	f022                	sd	s0,32(sp)
    800008c4:	ec26                	sd	s1,24(sp)
    800008c6:	e84a                	sd	s2,16(sp)
    800008c8:	e44e                	sd	s3,8(sp)
    800008ca:	e052                	sd	s4,0(sp)
    800008cc:	1800                	addi	s0,sp,48
    800008ce:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008d0:	00010517          	auipc	a0,0x10
    800008d4:	33850513          	addi	a0,a0,824 # 80010c08 <uart_tx_lock>
    800008d8:	00000097          	auipc	ra,0x0
    800008dc:	2fe080e7          	jalr	766(ra) # 80000bd6 <acquire>
  if(panicked){
    800008e0:	00008797          	auipc	a5,0x8
    800008e4:	0d07a783          	lw	a5,208(a5) # 800089b0 <panicked>
    800008e8:	e7c9                	bnez	a5,80000972 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008ea:	00008717          	auipc	a4,0x8
    800008ee:	0d673703          	ld	a4,214(a4) # 800089c0 <uart_tx_w>
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	0c67b783          	ld	a5,198(a5) # 800089b8 <uart_tx_r>
    800008fa:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fe:	00010997          	auipc	s3,0x10
    80000902:	30a98993          	addi	s3,s3,778 # 80010c08 <uart_tx_lock>
    80000906:	00008497          	auipc	s1,0x8
    8000090a:	0b248493          	addi	s1,s1,178 # 800089b8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090e:	00008917          	auipc	s2,0x8
    80000912:	0b290913          	addi	s2,s2,178 # 800089c0 <uart_tx_w>
    80000916:	00e79f63          	bne	a5,a4,80000934 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000091a:	85ce                	mv	a1,s3
    8000091c:	8526                	mv	a0,s1
    8000091e:	00001097          	auipc	ra,0x1
    80000922:	7fe080e7          	jalr	2046(ra) # 8000211c <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000926:	00093703          	ld	a4,0(s2)
    8000092a:	609c                	ld	a5,0(s1)
    8000092c:	02078793          	addi	a5,a5,32
    80000930:	fee785e3          	beq	a5,a4,8000091a <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000934:	00010497          	auipc	s1,0x10
    80000938:	2d448493          	addi	s1,s1,724 # 80010c08 <uart_tx_lock>
    8000093c:	01f77793          	andi	a5,a4,31
    80000940:	97a6                	add	a5,a5,s1
    80000942:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000946:	0705                	addi	a4,a4,1
    80000948:	00008797          	auipc	a5,0x8
    8000094c:	06e7bc23          	sd	a4,120(a5) # 800089c0 <uart_tx_w>
  uartstart();
    80000950:	00000097          	auipc	ra,0x0
    80000954:	ee8080e7          	jalr	-280(ra) # 80000838 <uartstart>
  release(&uart_tx_lock);
    80000958:	8526                	mv	a0,s1
    8000095a:	00000097          	auipc	ra,0x0
    8000095e:	330080e7          	jalr	816(ra) # 80000c8a <release>
}
    80000962:	70a2                	ld	ra,40(sp)
    80000964:	7402                	ld	s0,32(sp)
    80000966:	64e2                	ld	s1,24(sp)
    80000968:	6942                	ld	s2,16(sp)
    8000096a:	69a2                	ld	s3,8(sp)
    8000096c:	6a02                	ld	s4,0(sp)
    8000096e:	6145                	addi	sp,sp,48
    80000970:	8082                	ret
    for(;;)
    80000972:	a001                	j	80000972 <uartputc+0xb4>

0000000080000974 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000974:	1141                	addi	sp,sp,-16
    80000976:	e422                	sd	s0,8(sp)
    80000978:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    8000097a:	100007b7          	lui	a5,0x10000
    8000097e:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000982:	8b85                	andi	a5,a5,1
    80000984:	cb81                	beqz	a5,80000994 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000986:	100007b7          	lui	a5,0x10000
    8000098a:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000098e:	6422                	ld	s0,8(sp)
    80000990:	0141                	addi	sp,sp,16
    80000992:	8082                	ret
    return -1;
    80000994:	557d                	li	a0,-1
    80000996:	bfe5                	j	8000098e <uartgetc+0x1a>

0000000080000998 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000998:	1101                	addi	sp,sp,-32
    8000099a:	ec06                	sd	ra,24(sp)
    8000099c:	e822                	sd	s0,16(sp)
    8000099e:	e426                	sd	s1,8(sp)
    800009a0:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009a2:	54fd                	li	s1,-1
    800009a4:	a029                	j	800009ae <uartintr+0x16>
      break;
    consoleintr(c);
    800009a6:	00000097          	auipc	ra,0x0
    800009aa:	918080e7          	jalr	-1768(ra) # 800002be <consoleintr>
    int c = uartgetc();
    800009ae:	00000097          	auipc	ra,0x0
    800009b2:	fc6080e7          	jalr	-58(ra) # 80000974 <uartgetc>
    if(c == -1)
    800009b6:	fe9518e3          	bne	a0,s1,800009a6 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009ba:	00010497          	auipc	s1,0x10
    800009be:	24e48493          	addi	s1,s1,590 # 80010c08 <uart_tx_lock>
    800009c2:	8526                	mv	a0,s1
    800009c4:	00000097          	auipc	ra,0x0
    800009c8:	212080e7          	jalr	530(ra) # 80000bd6 <acquire>
  uartstart();
    800009cc:	00000097          	auipc	ra,0x0
    800009d0:	e6c080e7          	jalr	-404(ra) # 80000838 <uartstart>
  release(&uart_tx_lock);
    800009d4:	8526                	mv	a0,s1
    800009d6:	00000097          	auipc	ra,0x0
    800009da:	2b4080e7          	jalr	692(ra) # 80000c8a <release>
}
    800009de:	60e2                	ld	ra,24(sp)
    800009e0:	6442                	ld	s0,16(sp)
    800009e2:	64a2                	ld	s1,8(sp)
    800009e4:	6105                	addi	sp,sp,32
    800009e6:	8082                	ret

00000000800009e8 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e8:	1101                	addi	sp,sp,-32
    800009ea:	ec06                	sd	ra,24(sp)
    800009ec:	e822                	sd	s0,16(sp)
    800009ee:	e426                	sd	s1,8(sp)
    800009f0:	e04a                	sd	s2,0(sp)
    800009f2:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f4:	03451793          	slli	a5,a0,0x34
    800009f8:	ebb9                	bnez	a5,80000a4e <kfree+0x66>
    800009fa:	84aa                	mv	s1,a0
    800009fc:	00022797          	auipc	a5,0x22
    80000a00:	c8c78793          	addi	a5,a5,-884 # 80022688 <end>
    80000a04:	04f56563          	bltu	a0,a5,80000a4e <kfree+0x66>
    80000a08:	47c5                	li	a5,17
    80000a0a:	07ee                	slli	a5,a5,0x1b
    80000a0c:	04f57163          	bgeu	a0,a5,80000a4e <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a10:	6605                	lui	a2,0x1
    80000a12:	4585                	li	a1,1
    80000a14:	00000097          	auipc	ra,0x0
    80000a18:	2be080e7          	jalr	702(ra) # 80000cd2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a1c:	00010917          	auipc	s2,0x10
    80000a20:	22490913          	addi	s2,s2,548 # 80010c40 <kmem>
    80000a24:	854a                	mv	a0,s2
    80000a26:	00000097          	auipc	ra,0x0
    80000a2a:	1b0080e7          	jalr	432(ra) # 80000bd6 <acquire>
  r->next = kmem.freelist;
    80000a2e:	01893783          	ld	a5,24(s2)
    80000a32:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a34:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a38:	854a                	mv	a0,s2
    80000a3a:	00000097          	auipc	ra,0x0
    80000a3e:	250080e7          	jalr	592(ra) # 80000c8a <release>
}
    80000a42:	60e2                	ld	ra,24(sp)
    80000a44:	6442                	ld	s0,16(sp)
    80000a46:	64a2                	ld	s1,8(sp)
    80000a48:	6902                	ld	s2,0(sp)
    80000a4a:	6105                	addi	sp,sp,32
    80000a4c:	8082                	ret
    panic("kfree");
    80000a4e:	00007517          	auipc	a0,0x7
    80000a52:	61250513          	addi	a0,a0,1554 # 80008060 <digits+0x20>
    80000a56:	00000097          	auipc	ra,0x0
    80000a5a:	aea080e7          	jalr	-1302(ra) # 80000540 <panic>

0000000080000a5e <freerange>:
{
    80000a5e:	7179                	addi	sp,sp,-48
    80000a60:	f406                	sd	ra,40(sp)
    80000a62:	f022                	sd	s0,32(sp)
    80000a64:	ec26                	sd	s1,24(sp)
    80000a66:	e84a                	sd	s2,16(sp)
    80000a68:	e44e                	sd	s3,8(sp)
    80000a6a:	e052                	sd	s4,0(sp)
    80000a6c:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a6e:	6785                	lui	a5,0x1
    80000a70:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a74:	00e504b3          	add	s1,a0,a4
    80000a78:	777d                	lui	a4,0xfffff
    80000a7a:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a7c:	94be                	add	s1,s1,a5
    80000a7e:	0095ee63          	bltu	a1,s1,80000a9a <freerange+0x3c>
    80000a82:	892e                	mv	s2,a1
    kfree(p);
    80000a84:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a86:	6985                	lui	s3,0x1
    kfree(p);
    80000a88:	01448533          	add	a0,s1,s4
    80000a8c:	00000097          	auipc	ra,0x0
    80000a90:	f5c080e7          	jalr	-164(ra) # 800009e8 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a94:	94ce                	add	s1,s1,s3
    80000a96:	fe9979e3          	bgeu	s2,s1,80000a88 <freerange+0x2a>
}
    80000a9a:	70a2                	ld	ra,40(sp)
    80000a9c:	7402                	ld	s0,32(sp)
    80000a9e:	64e2                	ld	s1,24(sp)
    80000aa0:	6942                	ld	s2,16(sp)
    80000aa2:	69a2                	ld	s3,8(sp)
    80000aa4:	6a02                	ld	s4,0(sp)
    80000aa6:	6145                	addi	sp,sp,48
    80000aa8:	8082                	ret

0000000080000aaa <kinit>:
{
    80000aaa:	1141                	addi	sp,sp,-16
    80000aac:	e406                	sd	ra,8(sp)
    80000aae:	e022                	sd	s0,0(sp)
    80000ab0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ab2:	00007597          	auipc	a1,0x7
    80000ab6:	5b658593          	addi	a1,a1,1462 # 80008068 <digits+0x28>
    80000aba:	00010517          	auipc	a0,0x10
    80000abe:	18650513          	addi	a0,a0,390 # 80010c40 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00022517          	auipc	a0,0x22
    80000ad2:	bba50513          	addi	a0,a0,-1094 # 80022688 <end>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	f88080e7          	jalr	-120(ra) # 80000a5e <freerange>
}
    80000ade:	60a2                	ld	ra,8(sp)
    80000ae0:	6402                	ld	s0,0(sp)
    80000ae2:	0141                	addi	sp,sp,16
    80000ae4:	8082                	ret

0000000080000ae6 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae6:	1101                	addi	sp,sp,-32
    80000ae8:	ec06                	sd	ra,24(sp)
    80000aea:	e822                	sd	s0,16(sp)
    80000aec:	e426                	sd	s1,8(sp)
    80000aee:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000af0:	00010497          	auipc	s1,0x10
    80000af4:	15048493          	addi	s1,s1,336 # 80010c40 <kmem>
    80000af8:	8526                	mv	a0,s1
    80000afa:	00000097          	auipc	ra,0x0
    80000afe:	0dc080e7          	jalr	220(ra) # 80000bd6 <acquire>
  r = kmem.freelist;
    80000b02:	6c84                	ld	s1,24(s1)
  if(r)
    80000b04:	c885                	beqz	s1,80000b34 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b06:	609c                	ld	a5,0(s1)
    80000b08:	00010517          	auipc	a0,0x10
    80000b0c:	13850513          	addi	a0,a0,312 # 80010c40 <kmem>
    80000b10:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b12:	00000097          	auipc	ra,0x0
    80000b16:	178080e7          	jalr	376(ra) # 80000c8a <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b1a:	6605                	lui	a2,0x1
    80000b1c:	4595                	li	a1,5
    80000b1e:	8526                	mv	a0,s1
    80000b20:	00000097          	auipc	ra,0x0
    80000b24:	1b2080e7          	jalr	434(ra) # 80000cd2 <memset>
  return (void*)r;
}
    80000b28:	8526                	mv	a0,s1
    80000b2a:	60e2                	ld	ra,24(sp)
    80000b2c:	6442                	ld	s0,16(sp)
    80000b2e:	64a2                	ld	s1,8(sp)
    80000b30:	6105                	addi	sp,sp,32
    80000b32:	8082                	ret
  release(&kmem.lock);
    80000b34:	00010517          	auipc	a0,0x10
    80000b38:	10c50513          	addi	a0,a0,268 # 80010c40 <kmem>
    80000b3c:	00000097          	auipc	ra,0x0
    80000b40:	14e080e7          	jalr	334(ra) # 80000c8a <release>
  if(r)
    80000b44:	b7d5                	j	80000b28 <kalloc+0x42>

0000000080000b46 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b46:	1141                	addi	sp,sp,-16
    80000b48:	e422                	sd	s0,8(sp)
    80000b4a:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b4c:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4e:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b52:	00053823          	sd	zero,16(a0)
}
    80000b56:	6422                	ld	s0,8(sp)
    80000b58:	0141                	addi	sp,sp,16
    80000b5a:	8082                	ret

0000000080000b5c <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b5c:	411c                	lw	a5,0(a0)
    80000b5e:	e399                	bnez	a5,80000b64 <holding+0x8>
    80000b60:	4501                	li	a0,0
  return r;
}
    80000b62:	8082                	ret
{
    80000b64:	1101                	addi	sp,sp,-32
    80000b66:	ec06                	sd	ra,24(sp)
    80000b68:	e822                	sd	s0,16(sp)
    80000b6a:	e426                	sd	s1,8(sp)
    80000b6c:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6e:	6904                	ld	s1,16(a0)
    80000b70:	00001097          	auipc	ra,0x1
    80000b74:	e38080e7          	jalr	-456(ra) # 800019a8 <mycpu>
    80000b78:	40a48533          	sub	a0,s1,a0
    80000b7c:	00153513          	seqz	a0,a0
}
    80000b80:	60e2                	ld	ra,24(sp)
    80000b82:	6442                	ld	s0,16(sp)
    80000b84:	64a2                	ld	s1,8(sp)
    80000b86:	6105                	addi	sp,sp,32
    80000b88:	8082                	ret

0000000080000b8a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b8a:	1101                	addi	sp,sp,-32
    80000b8c:	ec06                	sd	ra,24(sp)
    80000b8e:	e822                	sd	s0,16(sp)
    80000b90:	e426                	sd	s1,8(sp)
    80000b92:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b94:	100024f3          	csrr	s1,sstatus
    80000b98:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b9c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9e:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000ba2:	00001097          	auipc	ra,0x1
    80000ba6:	e06080e7          	jalr	-506(ra) # 800019a8 <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cf89                	beqz	a5,80000bc6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	00001097          	auipc	ra,0x1
    80000bb2:	dfa080e7          	jalr	-518(ra) # 800019a8 <mycpu>
    80000bb6:	5d3c                	lw	a5,120(a0)
    80000bb8:	2785                	addiw	a5,a5,1
    80000bba:	dd3c                	sw	a5,120(a0)
}
    80000bbc:	60e2                	ld	ra,24(sp)
    80000bbe:	6442                	ld	s0,16(sp)
    80000bc0:	64a2                	ld	s1,8(sp)
    80000bc2:	6105                	addi	sp,sp,32
    80000bc4:	8082                	ret
    mycpu()->intena = old;
    80000bc6:	00001097          	auipc	ra,0x1
    80000bca:	de2080e7          	jalr	-542(ra) # 800019a8 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bce:	8085                	srli	s1,s1,0x1
    80000bd0:	8885                	andi	s1,s1,1
    80000bd2:	dd64                	sw	s1,124(a0)
    80000bd4:	bfe9                	j	80000bae <push_off+0x24>

0000000080000bd6 <acquire>:
{
    80000bd6:	1101                	addi	sp,sp,-32
    80000bd8:	ec06                	sd	ra,24(sp)
    80000bda:	e822                	sd	s0,16(sp)
    80000bdc:	e426                	sd	s1,8(sp)
    80000bde:	1000                	addi	s0,sp,32
    80000be0:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000be2:	00000097          	auipc	ra,0x0
    80000be6:	fa8080e7          	jalr	-88(ra) # 80000b8a <push_off>
  if(holding(lk))
    80000bea:	8526                	mv	a0,s1
    80000bec:	00000097          	auipc	ra,0x0
    80000bf0:	f70080e7          	jalr	-144(ra) # 80000b5c <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	4705                	li	a4,1
  if(holding(lk))
    80000bf6:	e115                	bnez	a0,80000c1a <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf8:	87ba                	mv	a5,a4
    80000bfa:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfe:	2781                	sext.w	a5,a5
    80000c00:	ffe5                	bnez	a5,80000bf8 <acquire+0x22>
  __sync_synchronize();
    80000c02:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c06:	00001097          	auipc	ra,0x1
    80000c0a:	da2080e7          	jalr	-606(ra) # 800019a8 <mycpu>
    80000c0e:	e888                	sd	a0,16(s1)
}
    80000c10:	60e2                	ld	ra,24(sp)
    80000c12:	6442                	ld	s0,16(sp)
    80000c14:	64a2                	ld	s1,8(sp)
    80000c16:	6105                	addi	sp,sp,32
    80000c18:	8082                	ret
    panic("acquire");
    80000c1a:	00007517          	auipc	a0,0x7
    80000c1e:	45650513          	addi	a0,a0,1110 # 80008070 <digits+0x30>
    80000c22:	00000097          	auipc	ra,0x0
    80000c26:	91e080e7          	jalr	-1762(ra) # 80000540 <panic>

0000000080000c2a <pop_off>:

void
pop_off(void)
{
    80000c2a:	1141                	addi	sp,sp,-16
    80000c2c:	e406                	sd	ra,8(sp)
    80000c2e:	e022                	sd	s0,0(sp)
    80000c30:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c32:	00001097          	auipc	ra,0x1
    80000c36:	d76080e7          	jalr	-650(ra) # 800019a8 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c3a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c40:	e78d                	bnez	a5,80000c6a <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c42:	5d3c                	lw	a5,120(a0)
    80000c44:	02f05b63          	blez	a5,80000c7a <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c48:	37fd                	addiw	a5,a5,-1
    80000c4a:	0007871b          	sext.w	a4,a5
    80000c4e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c50:	eb09                	bnez	a4,80000c62 <pop_off+0x38>
    80000c52:	5d7c                	lw	a5,124(a0)
    80000c54:	c799                	beqz	a5,80000c62 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c56:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c5a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c62:	60a2                	ld	ra,8(sp)
    80000c64:	6402                	ld	s0,0(sp)
    80000c66:	0141                	addi	sp,sp,16
    80000c68:	8082                	ret
    panic("pop_off - interruptible");
    80000c6a:	00007517          	auipc	a0,0x7
    80000c6e:	40e50513          	addi	a0,a0,1038 # 80008078 <digits+0x38>
    80000c72:	00000097          	auipc	ra,0x0
    80000c76:	8ce080e7          	jalr	-1842(ra) # 80000540 <panic>
    panic("pop_off");
    80000c7a:	00007517          	auipc	a0,0x7
    80000c7e:	41650513          	addi	a0,a0,1046 # 80008090 <digits+0x50>
    80000c82:	00000097          	auipc	ra,0x0
    80000c86:	8be080e7          	jalr	-1858(ra) # 80000540 <panic>

0000000080000c8a <release>:
{
    80000c8a:	1101                	addi	sp,sp,-32
    80000c8c:	ec06                	sd	ra,24(sp)
    80000c8e:	e822                	sd	s0,16(sp)
    80000c90:	e426                	sd	s1,8(sp)
    80000c92:	1000                	addi	s0,sp,32
    80000c94:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c96:	00000097          	auipc	ra,0x0
    80000c9a:	ec6080e7          	jalr	-314(ra) # 80000b5c <holding>
    80000c9e:	c115                	beqz	a0,80000cc2 <release+0x38>
  lk->cpu = 0;
    80000ca0:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca4:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca8:	0f50000f          	fence	iorw,ow
    80000cac:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cb0:	00000097          	auipc	ra,0x0
    80000cb4:	f7a080e7          	jalr	-134(ra) # 80000c2a <pop_off>
}
    80000cb8:	60e2                	ld	ra,24(sp)
    80000cba:	6442                	ld	s0,16(sp)
    80000cbc:	64a2                	ld	s1,8(sp)
    80000cbe:	6105                	addi	sp,sp,32
    80000cc0:	8082                	ret
    panic("release");
    80000cc2:	00007517          	auipc	a0,0x7
    80000cc6:	3d650513          	addi	a0,a0,982 # 80008098 <digits+0x58>
    80000cca:	00000097          	auipc	ra,0x0
    80000cce:	876080e7          	jalr	-1930(ra) # 80000540 <panic>

0000000080000cd2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cd2:	1141                	addi	sp,sp,-16
    80000cd4:	e422                	sd	s0,8(sp)
    80000cd6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd8:	ca19                	beqz	a2,80000cee <memset+0x1c>
    80000cda:	87aa                	mv	a5,a0
    80000cdc:	1602                	slli	a2,a2,0x20
    80000cde:	9201                	srli	a2,a2,0x20
    80000ce0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce8:	0785                	addi	a5,a5,1
    80000cea:	fee79de3          	bne	a5,a4,80000ce4 <memset+0x12>
  }
  return dst;
}
    80000cee:	6422                	ld	s0,8(sp)
    80000cf0:	0141                	addi	sp,sp,16
    80000cf2:	8082                	ret

0000000080000cf4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf4:	1141                	addi	sp,sp,-16
    80000cf6:	e422                	sd	s0,8(sp)
    80000cf8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cfa:	ca05                	beqz	a2,80000d2a <memcmp+0x36>
    80000cfc:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000d00:	1682                	slli	a3,a3,0x20
    80000d02:	9281                	srli	a3,a3,0x20
    80000d04:	0685                	addi	a3,a3,1
    80000d06:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d08:	00054783          	lbu	a5,0(a0)
    80000d0c:	0005c703          	lbu	a4,0(a1)
    80000d10:	00e79863          	bne	a5,a4,80000d20 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d14:	0505                	addi	a0,a0,1
    80000d16:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d18:	fed518e3          	bne	a0,a3,80000d08 <memcmp+0x14>
  }

  return 0;
    80000d1c:	4501                	li	a0,0
    80000d1e:	a019                	j	80000d24 <memcmp+0x30>
      return *s1 - *s2;
    80000d20:	40e7853b          	subw	a0,a5,a4
}
    80000d24:	6422                	ld	s0,8(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret
  return 0;
    80000d2a:	4501                	li	a0,0
    80000d2c:	bfe5                	j	80000d24 <memcmp+0x30>

0000000080000d2e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2e:	1141                	addi	sp,sp,-16
    80000d30:	e422                	sd	s0,8(sp)
    80000d32:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d34:	c205                	beqz	a2,80000d54 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d36:	02a5e263          	bltu	a1,a0,80000d5a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d3a:	1602                	slli	a2,a2,0x20
    80000d3c:	9201                	srli	a2,a2,0x20
    80000d3e:	00c587b3          	add	a5,a1,a2
{
    80000d42:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d44:	0585                	addi	a1,a1,1
    80000d46:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdc979>
    80000d48:	fff5c683          	lbu	a3,-1(a1)
    80000d4c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d50:	fef59ae3          	bne	a1,a5,80000d44 <memmove+0x16>

  return dst;
}
    80000d54:	6422                	ld	s0,8(sp)
    80000d56:	0141                	addi	sp,sp,16
    80000d58:	8082                	ret
  if(s < d && s + n > d){
    80000d5a:	02061693          	slli	a3,a2,0x20
    80000d5e:	9281                	srli	a3,a3,0x20
    80000d60:	00d58733          	add	a4,a1,a3
    80000d64:	fce57be3          	bgeu	a0,a4,80000d3a <memmove+0xc>
    d += n;
    80000d68:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d6a:	fff6079b          	addiw	a5,a2,-1
    80000d6e:	1782                	slli	a5,a5,0x20
    80000d70:	9381                	srli	a5,a5,0x20
    80000d72:	fff7c793          	not	a5,a5
    80000d76:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d78:	177d                	addi	a4,a4,-1
    80000d7a:	16fd                	addi	a3,a3,-1
    80000d7c:	00074603          	lbu	a2,0(a4)
    80000d80:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d84:	fee79ae3          	bne	a5,a4,80000d78 <memmove+0x4a>
    80000d88:	b7f1                	j	80000d54 <memmove+0x26>

0000000080000d8a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d8a:	1141                	addi	sp,sp,-16
    80000d8c:	e406                	sd	ra,8(sp)
    80000d8e:	e022                	sd	s0,0(sp)
    80000d90:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d92:	00000097          	auipc	ra,0x0
    80000d96:	f9c080e7          	jalr	-100(ra) # 80000d2e <memmove>
}
    80000d9a:	60a2                	ld	ra,8(sp)
    80000d9c:	6402                	ld	s0,0(sp)
    80000d9e:	0141                	addi	sp,sp,16
    80000da0:	8082                	ret

0000000080000da2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000da2:	1141                	addi	sp,sp,-16
    80000da4:	e422                	sd	s0,8(sp)
    80000da6:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da8:	ce11                	beqz	a2,80000dc4 <strncmp+0x22>
    80000daa:	00054783          	lbu	a5,0(a0)
    80000dae:	cf89                	beqz	a5,80000dc8 <strncmp+0x26>
    80000db0:	0005c703          	lbu	a4,0(a1)
    80000db4:	00f71a63          	bne	a4,a5,80000dc8 <strncmp+0x26>
    n--, p++, q++;
    80000db8:	367d                	addiw	a2,a2,-1
    80000dba:	0505                	addi	a0,a0,1
    80000dbc:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dbe:	f675                	bnez	a2,80000daa <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dc0:	4501                	li	a0,0
    80000dc2:	a809                	j	80000dd4 <strncmp+0x32>
    80000dc4:	4501                	li	a0,0
    80000dc6:	a039                	j	80000dd4 <strncmp+0x32>
  if(n == 0)
    80000dc8:	ca09                	beqz	a2,80000dda <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dca:	00054503          	lbu	a0,0(a0)
    80000dce:	0005c783          	lbu	a5,0(a1)
    80000dd2:	9d1d                	subw	a0,a0,a5
}
    80000dd4:	6422                	ld	s0,8(sp)
    80000dd6:	0141                	addi	sp,sp,16
    80000dd8:	8082                	ret
    return 0;
    80000dda:	4501                	li	a0,0
    80000ddc:	bfe5                	j	80000dd4 <strncmp+0x32>

0000000080000dde <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dde:	1141                	addi	sp,sp,-16
    80000de0:	e422                	sd	s0,8(sp)
    80000de2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de4:	872a                	mv	a4,a0
    80000de6:	8832                	mv	a6,a2
    80000de8:	367d                	addiw	a2,a2,-1
    80000dea:	01005963          	blez	a6,80000dfc <strncpy+0x1e>
    80000dee:	0705                	addi	a4,a4,1
    80000df0:	0005c783          	lbu	a5,0(a1)
    80000df4:	fef70fa3          	sb	a5,-1(a4)
    80000df8:	0585                	addi	a1,a1,1
    80000dfa:	f7f5                	bnez	a5,80000de6 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000dfc:	86ba                	mv	a3,a4
    80000dfe:	00c05c63          	blez	a2,80000e16 <strncpy+0x38>
    *s++ = 0;
    80000e02:	0685                	addi	a3,a3,1
    80000e04:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e08:	40d707bb          	subw	a5,a4,a3
    80000e0c:	37fd                	addiw	a5,a5,-1
    80000e0e:	010787bb          	addw	a5,a5,a6
    80000e12:	fef048e3          	bgtz	a5,80000e02 <strncpy+0x24>
  return os;
}
    80000e16:	6422                	ld	s0,8(sp)
    80000e18:	0141                	addi	sp,sp,16
    80000e1a:	8082                	ret

0000000080000e1c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e1c:	1141                	addi	sp,sp,-16
    80000e1e:	e422                	sd	s0,8(sp)
    80000e20:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e22:	02c05363          	blez	a2,80000e48 <safestrcpy+0x2c>
    80000e26:	fff6069b          	addiw	a3,a2,-1
    80000e2a:	1682                	slli	a3,a3,0x20
    80000e2c:	9281                	srli	a3,a3,0x20
    80000e2e:	96ae                	add	a3,a3,a1
    80000e30:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e32:	00d58963          	beq	a1,a3,80000e44 <safestrcpy+0x28>
    80000e36:	0585                	addi	a1,a1,1
    80000e38:	0785                	addi	a5,a5,1
    80000e3a:	fff5c703          	lbu	a4,-1(a1)
    80000e3e:	fee78fa3          	sb	a4,-1(a5)
    80000e42:	fb65                	bnez	a4,80000e32 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e44:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e48:	6422                	ld	s0,8(sp)
    80000e4a:	0141                	addi	sp,sp,16
    80000e4c:	8082                	ret

0000000080000e4e <strlen>:

int
strlen(const char *s)
{
    80000e4e:	1141                	addi	sp,sp,-16
    80000e50:	e422                	sd	s0,8(sp)
    80000e52:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e54:	00054783          	lbu	a5,0(a0)
    80000e58:	cf91                	beqz	a5,80000e74 <strlen+0x26>
    80000e5a:	0505                	addi	a0,a0,1
    80000e5c:	87aa                	mv	a5,a0
    80000e5e:	4685                	li	a3,1
    80000e60:	9e89                	subw	a3,a3,a0
    80000e62:	00f6853b          	addw	a0,a3,a5
    80000e66:	0785                	addi	a5,a5,1
    80000e68:	fff7c703          	lbu	a4,-1(a5)
    80000e6c:	fb7d                	bnez	a4,80000e62 <strlen+0x14>
    ;
  return n;
}
    80000e6e:	6422                	ld	s0,8(sp)
    80000e70:	0141                	addi	sp,sp,16
    80000e72:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e74:	4501                	li	a0,0
    80000e76:	bfe5                	j	80000e6e <strlen+0x20>

0000000080000e78 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e78:	1141                	addi	sp,sp,-16
    80000e7a:	e406                	sd	ra,8(sp)
    80000e7c:	e022                	sd	s0,0(sp)
    80000e7e:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e80:	00001097          	auipc	ra,0x1
    80000e84:	b18080e7          	jalr	-1256(ra) # 80001998 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e88:	00008717          	auipc	a4,0x8
    80000e8c:	b4070713          	addi	a4,a4,-1216 # 800089c8 <started>
  if(cpuid() == 0){
    80000e90:	c139                	beqz	a0,80000ed6 <main+0x5e>
    while(started == 0)
    80000e92:	431c                	lw	a5,0(a4)
    80000e94:	2781                	sext.w	a5,a5
    80000e96:	dff5                	beqz	a5,80000e92 <main+0x1a>
      ;
    __sync_synchronize();
    80000e98:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e9c:	00001097          	auipc	ra,0x1
    80000ea0:	afc080e7          	jalr	-1284(ra) # 80001998 <cpuid>
    80000ea4:	85aa                	mv	a1,a0
    80000ea6:	00007517          	auipc	a0,0x7
    80000eaa:	21250513          	addi	a0,a0,530 # 800080b8 <digits+0x78>
    80000eae:	fffff097          	auipc	ra,0xfffff
    80000eb2:	6dc080e7          	jalr	1756(ra) # 8000058a <printf>
    kvminithart();    // turn on paging
    80000eb6:	00000097          	auipc	ra,0x0
    80000eba:	0d8080e7          	jalr	216(ra) # 80000f8e <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ebe:	00002097          	auipc	ra,0x2
    80000ec2:	c2e080e7          	jalr	-978(ra) # 80002aec <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	2da080e7          	jalr	730(ra) # 800061a0 <plicinithart>
  }

  scheduler();        
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	092080e7          	jalr	146(ra) # 80001f60 <scheduler>
    consoleinit();
    80000ed6:	fffff097          	auipc	ra,0xfffff
    80000eda:	57a080e7          	jalr	1402(ra) # 80000450 <consoleinit>
    printfinit();
    80000ede:	00000097          	auipc	ra,0x0
    80000ee2:	88c080e7          	jalr	-1908(ra) # 8000076a <printfinit>
    printf("\n");
    80000ee6:	00007517          	auipc	a0,0x7
    80000eea:	1e250513          	addi	a0,a0,482 # 800080c8 <digits+0x88>
    80000eee:	fffff097          	auipc	ra,0xfffff
    80000ef2:	69c080e7          	jalr	1692(ra) # 8000058a <printf>
    printf("xv6 kernel is booting\n");
    80000ef6:	00007517          	auipc	a0,0x7
    80000efa:	1aa50513          	addi	a0,a0,426 # 800080a0 <digits+0x60>
    80000efe:	fffff097          	auipc	ra,0xfffff
    80000f02:	68c080e7          	jalr	1676(ra) # 8000058a <printf>
    printf("\n");
    80000f06:	00007517          	auipc	a0,0x7
    80000f0a:	1c250513          	addi	a0,a0,450 # 800080c8 <digits+0x88>
    80000f0e:	fffff097          	auipc	ra,0xfffff
    80000f12:	67c080e7          	jalr	1660(ra) # 8000058a <printf>
    kinit();         // physical page allocator
    80000f16:	00000097          	auipc	ra,0x0
    80000f1a:	b94080e7          	jalr	-1132(ra) # 80000aaa <kinit>
    kvminit();       // create kernel page table
    80000f1e:	00000097          	auipc	ra,0x0
    80000f22:	326080e7          	jalr	806(ra) # 80001244 <kvminit>
    kvminithart();   // turn on paging
    80000f26:	00000097          	auipc	ra,0x0
    80000f2a:	068080e7          	jalr	104(ra) # 80000f8e <kvminithart>
    procinit();      // process table
    80000f2e:	00001097          	auipc	ra,0x1
    80000f32:	99e080e7          	jalr	-1634(ra) # 800018cc <procinit>
    trapinit();      // trap vectors
    80000f36:	00002097          	auipc	ra,0x2
    80000f3a:	b8e080e7          	jalr	-1138(ra) # 80002ac4 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00002097          	auipc	ra,0x2
    80000f42:	bae080e7          	jalr	-1106(ra) # 80002aec <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	244080e7          	jalr	580(ra) # 8000618a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	252080e7          	jalr	594(ra) # 800061a0 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	3f2080e7          	jalr	1010(ra) # 80003348 <binit>
    iinit();         // inode table
    80000f5e:	00003097          	auipc	ra,0x3
    80000f62:	a92080e7          	jalr	-1390(ra) # 800039f0 <iinit>
    fileinit();      // file table
    80000f66:	00004097          	auipc	ra,0x4
    80000f6a:	a38080e7          	jalr	-1480(ra) # 8000499e <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	33a080e7          	jalr	826(ra) # 800062a8 <virtio_disk_init>
    userinit();      // first user process
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	d7c080e7          	jalr	-644(ra) # 80001cf2 <userinit>
    __sync_synchronize();
    80000f7e:	0ff0000f          	fence
    started = 1;
    80000f82:	4785                	li	a5,1
    80000f84:	00008717          	auipc	a4,0x8
    80000f88:	a4f72223          	sw	a5,-1468(a4) # 800089c8 <started>
    80000f8c:	b789                	j	80000ece <main+0x56>

0000000080000f8e <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f8e:	1141                	addi	sp,sp,-16
    80000f90:	e422                	sd	s0,8(sp)
    80000f92:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f94:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f98:	00008797          	auipc	a5,0x8
    80000f9c:	a387b783          	ld	a5,-1480(a5) # 800089d0 <kernel_pagetable>
    80000fa0:	83b1                	srli	a5,a5,0xc
    80000fa2:	577d                	li	a4,-1
    80000fa4:	177e                	slli	a4,a4,0x3f
    80000fa6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fa8:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fac:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fb0:	6422                	ld	s0,8(sp)
    80000fb2:	0141                	addi	sp,sp,16
    80000fb4:	8082                	ret

0000000080000fb6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fb6:	7139                	addi	sp,sp,-64
    80000fb8:	fc06                	sd	ra,56(sp)
    80000fba:	f822                	sd	s0,48(sp)
    80000fbc:	f426                	sd	s1,40(sp)
    80000fbe:	f04a                	sd	s2,32(sp)
    80000fc0:	ec4e                	sd	s3,24(sp)
    80000fc2:	e852                	sd	s4,16(sp)
    80000fc4:	e456                	sd	s5,8(sp)
    80000fc6:	e05a                	sd	s6,0(sp)
    80000fc8:	0080                	addi	s0,sp,64
    80000fca:	84aa                	mv	s1,a0
    80000fcc:	89ae                	mv	s3,a1
    80000fce:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fd0:	57fd                	li	a5,-1
    80000fd2:	83e9                	srli	a5,a5,0x1a
    80000fd4:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fd6:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fd8:	04b7f263          	bgeu	a5,a1,8000101c <walk+0x66>
    panic("walk");
    80000fdc:	00007517          	auipc	a0,0x7
    80000fe0:	0f450513          	addi	a0,a0,244 # 800080d0 <digits+0x90>
    80000fe4:	fffff097          	auipc	ra,0xfffff
    80000fe8:	55c080e7          	jalr	1372(ra) # 80000540 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fec:	060a8663          	beqz	s5,80001058 <walk+0xa2>
    80000ff0:	00000097          	auipc	ra,0x0
    80000ff4:	af6080e7          	jalr	-1290(ra) # 80000ae6 <kalloc>
    80000ff8:	84aa                	mv	s1,a0
    80000ffa:	c529                	beqz	a0,80001044 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ffc:	6605                	lui	a2,0x1
    80000ffe:	4581                	li	a1,0
    80001000:	00000097          	auipc	ra,0x0
    80001004:	cd2080e7          	jalr	-814(ra) # 80000cd2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001008:	00c4d793          	srli	a5,s1,0xc
    8000100c:	07aa                	slli	a5,a5,0xa
    8000100e:	0017e793          	ori	a5,a5,1
    80001012:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001016:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdc96f>
    80001018:	036a0063          	beq	s4,s6,80001038 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000101c:	0149d933          	srl	s2,s3,s4
    80001020:	1ff97913          	andi	s2,s2,511
    80001024:	090e                	slli	s2,s2,0x3
    80001026:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001028:	00093483          	ld	s1,0(s2)
    8000102c:	0014f793          	andi	a5,s1,1
    80001030:	dfd5                	beqz	a5,80000fec <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001032:	80a9                	srli	s1,s1,0xa
    80001034:	04b2                	slli	s1,s1,0xc
    80001036:	b7c5                	j	80001016 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001038:	00c9d513          	srli	a0,s3,0xc
    8000103c:	1ff57513          	andi	a0,a0,511
    80001040:	050e                	slli	a0,a0,0x3
    80001042:	9526                	add	a0,a0,s1
}
    80001044:	70e2                	ld	ra,56(sp)
    80001046:	7442                	ld	s0,48(sp)
    80001048:	74a2                	ld	s1,40(sp)
    8000104a:	7902                	ld	s2,32(sp)
    8000104c:	69e2                	ld	s3,24(sp)
    8000104e:	6a42                	ld	s4,16(sp)
    80001050:	6aa2                	ld	s5,8(sp)
    80001052:	6b02                	ld	s6,0(sp)
    80001054:	6121                	addi	sp,sp,64
    80001056:	8082                	ret
        return 0;
    80001058:	4501                	li	a0,0
    8000105a:	b7ed                	j	80001044 <walk+0x8e>

000000008000105c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000105c:	57fd                	li	a5,-1
    8000105e:	83e9                	srli	a5,a5,0x1a
    80001060:	00b7f463          	bgeu	a5,a1,80001068 <walkaddr+0xc>
    return 0;
    80001064:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001066:	8082                	ret
{
    80001068:	1141                	addi	sp,sp,-16
    8000106a:	e406                	sd	ra,8(sp)
    8000106c:	e022                	sd	s0,0(sp)
    8000106e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001070:	4601                	li	a2,0
    80001072:	00000097          	auipc	ra,0x0
    80001076:	f44080e7          	jalr	-188(ra) # 80000fb6 <walk>
  if(pte == 0)
    8000107a:	c105                	beqz	a0,8000109a <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000107c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000107e:	0117f693          	andi	a3,a5,17
    80001082:	4745                	li	a4,17
    return 0;
    80001084:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001086:	00e68663          	beq	a3,a4,80001092 <walkaddr+0x36>
}
    8000108a:	60a2                	ld	ra,8(sp)
    8000108c:	6402                	ld	s0,0(sp)
    8000108e:	0141                	addi	sp,sp,16
    80001090:	8082                	ret
  pa = PTE2PA(*pte);
    80001092:	83a9                	srli	a5,a5,0xa
    80001094:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001098:	bfcd                	j	8000108a <walkaddr+0x2e>
    return 0;
    8000109a:	4501                	li	a0,0
    8000109c:	b7fd                	j	8000108a <walkaddr+0x2e>

000000008000109e <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000109e:	715d                	addi	sp,sp,-80
    800010a0:	e486                	sd	ra,72(sp)
    800010a2:	e0a2                	sd	s0,64(sp)
    800010a4:	fc26                	sd	s1,56(sp)
    800010a6:	f84a                	sd	s2,48(sp)
    800010a8:	f44e                	sd	s3,40(sp)
    800010aa:	f052                	sd	s4,32(sp)
    800010ac:	ec56                	sd	s5,24(sp)
    800010ae:	e85a                	sd	s6,16(sp)
    800010b0:	e45e                	sd	s7,8(sp)
    800010b2:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010b4:	c639                	beqz	a2,80001102 <mappages+0x64>
    800010b6:	8aaa                	mv	s5,a0
    800010b8:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010ba:	777d                	lui	a4,0xfffff
    800010bc:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010c0:	fff58993          	addi	s3,a1,-1
    800010c4:	99b2                	add	s3,s3,a2
    800010c6:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010ca:	893e                	mv	s2,a5
    800010cc:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010d0:	6b85                	lui	s7,0x1
    800010d2:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d6:	4605                	li	a2,1
    800010d8:	85ca                	mv	a1,s2
    800010da:	8556                	mv	a0,s5
    800010dc:	00000097          	auipc	ra,0x0
    800010e0:	eda080e7          	jalr	-294(ra) # 80000fb6 <walk>
    800010e4:	cd1d                	beqz	a0,80001122 <mappages+0x84>
    if(*pte & PTE_V)
    800010e6:	611c                	ld	a5,0(a0)
    800010e8:	8b85                	andi	a5,a5,1
    800010ea:	e785                	bnez	a5,80001112 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010ec:	80b1                	srli	s1,s1,0xc
    800010ee:	04aa                	slli	s1,s1,0xa
    800010f0:	0164e4b3          	or	s1,s1,s6
    800010f4:	0014e493          	ori	s1,s1,1
    800010f8:	e104                	sd	s1,0(a0)
    if(a == last)
    800010fa:	05390063          	beq	s2,s3,8000113a <mappages+0x9c>
    a += PGSIZE;
    800010fe:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001100:	bfc9                	j	800010d2 <mappages+0x34>
    panic("mappages: size");
    80001102:	00007517          	auipc	a0,0x7
    80001106:	fd650513          	addi	a0,a0,-42 # 800080d8 <digits+0x98>
    8000110a:	fffff097          	auipc	ra,0xfffff
    8000110e:	436080e7          	jalr	1078(ra) # 80000540 <panic>
      panic("mappages: remap");
    80001112:	00007517          	auipc	a0,0x7
    80001116:	fd650513          	addi	a0,a0,-42 # 800080e8 <digits+0xa8>
    8000111a:	fffff097          	auipc	ra,0xfffff
    8000111e:	426080e7          	jalr	1062(ra) # 80000540 <panic>
      return -1;
    80001122:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001124:	60a6                	ld	ra,72(sp)
    80001126:	6406                	ld	s0,64(sp)
    80001128:	74e2                	ld	s1,56(sp)
    8000112a:	7942                	ld	s2,48(sp)
    8000112c:	79a2                	ld	s3,40(sp)
    8000112e:	7a02                	ld	s4,32(sp)
    80001130:	6ae2                	ld	s5,24(sp)
    80001132:	6b42                	ld	s6,16(sp)
    80001134:	6ba2                	ld	s7,8(sp)
    80001136:	6161                	addi	sp,sp,80
    80001138:	8082                	ret
  return 0;
    8000113a:	4501                	li	a0,0
    8000113c:	b7e5                	j	80001124 <mappages+0x86>

000000008000113e <kvmmap>:
{
    8000113e:	1141                	addi	sp,sp,-16
    80001140:	e406                	sd	ra,8(sp)
    80001142:	e022                	sd	s0,0(sp)
    80001144:	0800                	addi	s0,sp,16
    80001146:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001148:	86b2                	mv	a3,a2
    8000114a:	863e                	mv	a2,a5
    8000114c:	00000097          	auipc	ra,0x0
    80001150:	f52080e7          	jalr	-174(ra) # 8000109e <mappages>
    80001154:	e509                	bnez	a0,8000115e <kvmmap+0x20>
}
    80001156:	60a2                	ld	ra,8(sp)
    80001158:	6402                	ld	s0,0(sp)
    8000115a:	0141                	addi	sp,sp,16
    8000115c:	8082                	ret
    panic("kvmmap");
    8000115e:	00007517          	auipc	a0,0x7
    80001162:	f9a50513          	addi	a0,a0,-102 # 800080f8 <digits+0xb8>
    80001166:	fffff097          	auipc	ra,0xfffff
    8000116a:	3da080e7          	jalr	986(ra) # 80000540 <panic>

000000008000116e <kvmmake>:
{
    8000116e:	1101                	addi	sp,sp,-32
    80001170:	ec06                	sd	ra,24(sp)
    80001172:	e822                	sd	s0,16(sp)
    80001174:	e426                	sd	s1,8(sp)
    80001176:	e04a                	sd	s2,0(sp)
    80001178:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000117a:	00000097          	auipc	ra,0x0
    8000117e:	96c080e7          	jalr	-1684(ra) # 80000ae6 <kalloc>
    80001182:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001184:	6605                	lui	a2,0x1
    80001186:	4581                	li	a1,0
    80001188:	00000097          	auipc	ra,0x0
    8000118c:	b4a080e7          	jalr	-1206(ra) # 80000cd2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001190:	4719                	li	a4,6
    80001192:	6685                	lui	a3,0x1
    80001194:	10000637          	lui	a2,0x10000
    80001198:	100005b7          	lui	a1,0x10000
    8000119c:	8526                	mv	a0,s1
    8000119e:	00000097          	auipc	ra,0x0
    800011a2:	fa0080e7          	jalr	-96(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a6:	4719                	li	a4,6
    800011a8:	6685                	lui	a3,0x1
    800011aa:	10001637          	lui	a2,0x10001
    800011ae:	100015b7          	lui	a1,0x10001
    800011b2:	8526                	mv	a0,s1
    800011b4:	00000097          	auipc	ra,0x0
    800011b8:	f8a080e7          	jalr	-118(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011bc:	4719                	li	a4,6
    800011be:	004006b7          	lui	a3,0x400
    800011c2:	0c000637          	lui	a2,0xc000
    800011c6:	0c0005b7          	lui	a1,0xc000
    800011ca:	8526                	mv	a0,s1
    800011cc:	00000097          	auipc	ra,0x0
    800011d0:	f72080e7          	jalr	-142(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011d4:	00007917          	auipc	s2,0x7
    800011d8:	e2c90913          	addi	s2,s2,-468 # 80008000 <etext>
    800011dc:	4729                	li	a4,10
    800011de:	80007697          	auipc	a3,0x80007
    800011e2:	e2268693          	addi	a3,a3,-478 # 8000 <_entry-0x7fff8000>
    800011e6:	4605                	li	a2,1
    800011e8:	067e                	slli	a2,a2,0x1f
    800011ea:	85b2                	mv	a1,a2
    800011ec:	8526                	mv	a0,s1
    800011ee:	00000097          	auipc	ra,0x0
    800011f2:	f50080e7          	jalr	-176(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011f6:	4719                	li	a4,6
    800011f8:	46c5                	li	a3,17
    800011fa:	06ee                	slli	a3,a3,0x1b
    800011fc:	412686b3          	sub	a3,a3,s2
    80001200:	864a                	mv	a2,s2
    80001202:	85ca                	mv	a1,s2
    80001204:	8526                	mv	a0,s1
    80001206:	00000097          	auipc	ra,0x0
    8000120a:	f38080e7          	jalr	-200(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000120e:	4729                	li	a4,10
    80001210:	6685                	lui	a3,0x1
    80001212:	00006617          	auipc	a2,0x6
    80001216:	dee60613          	addi	a2,a2,-530 # 80007000 <_trampoline>
    8000121a:	040005b7          	lui	a1,0x4000
    8000121e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001220:	05b2                	slli	a1,a1,0xc
    80001222:	8526                	mv	a0,s1
    80001224:	00000097          	auipc	ra,0x0
    80001228:	f1a080e7          	jalr	-230(ra) # 8000113e <kvmmap>
  proc_mapstacks(kpgtbl);
    8000122c:	8526                	mv	a0,s1
    8000122e:	00000097          	auipc	ra,0x0
    80001232:	608080e7          	jalr	1544(ra) # 80001836 <proc_mapstacks>
}
    80001236:	8526                	mv	a0,s1
    80001238:	60e2                	ld	ra,24(sp)
    8000123a:	6442                	ld	s0,16(sp)
    8000123c:	64a2                	ld	s1,8(sp)
    8000123e:	6902                	ld	s2,0(sp)
    80001240:	6105                	addi	sp,sp,32
    80001242:	8082                	ret

0000000080001244 <kvminit>:
{
    80001244:	1141                	addi	sp,sp,-16
    80001246:	e406                	sd	ra,8(sp)
    80001248:	e022                	sd	s0,0(sp)
    8000124a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000124c:	00000097          	auipc	ra,0x0
    80001250:	f22080e7          	jalr	-222(ra) # 8000116e <kvmmake>
    80001254:	00007797          	auipc	a5,0x7
    80001258:	76a7be23          	sd	a0,1916(a5) # 800089d0 <kernel_pagetable>
}
    8000125c:	60a2                	ld	ra,8(sp)
    8000125e:	6402                	ld	s0,0(sp)
    80001260:	0141                	addi	sp,sp,16
    80001262:	8082                	ret

0000000080001264 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001264:	715d                	addi	sp,sp,-80
    80001266:	e486                	sd	ra,72(sp)
    80001268:	e0a2                	sd	s0,64(sp)
    8000126a:	fc26                	sd	s1,56(sp)
    8000126c:	f84a                	sd	s2,48(sp)
    8000126e:	f44e                	sd	s3,40(sp)
    80001270:	f052                	sd	s4,32(sp)
    80001272:	ec56                	sd	s5,24(sp)
    80001274:	e85a                	sd	s6,16(sp)
    80001276:	e45e                	sd	s7,8(sp)
    80001278:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000127a:	03459793          	slli	a5,a1,0x34
    8000127e:	e795                	bnez	a5,800012aa <uvmunmap+0x46>
    80001280:	8a2a                	mv	s4,a0
    80001282:	892e                	mv	s2,a1
    80001284:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001286:	0632                	slli	a2,a2,0xc
    80001288:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000128c:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000128e:	6b05                	lui	s6,0x1
    80001290:	0735e263          	bltu	a1,s3,800012f4 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001294:	60a6                	ld	ra,72(sp)
    80001296:	6406                	ld	s0,64(sp)
    80001298:	74e2                	ld	s1,56(sp)
    8000129a:	7942                	ld	s2,48(sp)
    8000129c:	79a2                	ld	s3,40(sp)
    8000129e:	7a02                	ld	s4,32(sp)
    800012a0:	6ae2                	ld	s5,24(sp)
    800012a2:	6b42                	ld	s6,16(sp)
    800012a4:	6ba2                	ld	s7,8(sp)
    800012a6:	6161                	addi	sp,sp,80
    800012a8:	8082                	ret
    panic("uvmunmap: not aligned");
    800012aa:	00007517          	auipc	a0,0x7
    800012ae:	e5650513          	addi	a0,a0,-426 # 80008100 <digits+0xc0>
    800012b2:	fffff097          	auipc	ra,0xfffff
    800012b6:	28e080e7          	jalr	654(ra) # 80000540 <panic>
      panic("uvmunmap: walk");
    800012ba:	00007517          	auipc	a0,0x7
    800012be:	e5e50513          	addi	a0,a0,-418 # 80008118 <digits+0xd8>
    800012c2:	fffff097          	auipc	ra,0xfffff
    800012c6:	27e080e7          	jalr	638(ra) # 80000540 <panic>
      panic("uvmunmap: not mapped");
    800012ca:	00007517          	auipc	a0,0x7
    800012ce:	e5e50513          	addi	a0,a0,-418 # 80008128 <digits+0xe8>
    800012d2:	fffff097          	auipc	ra,0xfffff
    800012d6:	26e080e7          	jalr	622(ra) # 80000540 <panic>
      panic("uvmunmap: not a leaf");
    800012da:	00007517          	auipc	a0,0x7
    800012de:	e6650513          	addi	a0,a0,-410 # 80008140 <digits+0x100>
    800012e2:	fffff097          	auipc	ra,0xfffff
    800012e6:	25e080e7          	jalr	606(ra) # 80000540 <panic>
    *pte = 0;
    800012ea:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012ee:	995a                	add	s2,s2,s6
    800012f0:	fb3972e3          	bgeu	s2,s3,80001294 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012f4:	4601                	li	a2,0
    800012f6:	85ca                	mv	a1,s2
    800012f8:	8552                	mv	a0,s4
    800012fa:	00000097          	auipc	ra,0x0
    800012fe:	cbc080e7          	jalr	-836(ra) # 80000fb6 <walk>
    80001302:	84aa                	mv	s1,a0
    80001304:	d95d                	beqz	a0,800012ba <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001306:	6108                	ld	a0,0(a0)
    80001308:	00157793          	andi	a5,a0,1
    8000130c:	dfdd                	beqz	a5,800012ca <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000130e:	3ff57793          	andi	a5,a0,1023
    80001312:	fd7784e3          	beq	a5,s7,800012da <uvmunmap+0x76>
    if(do_free){
    80001316:	fc0a8ae3          	beqz	s5,800012ea <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    8000131a:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000131c:	0532                	slli	a0,a0,0xc
    8000131e:	fffff097          	auipc	ra,0xfffff
    80001322:	6ca080e7          	jalr	1738(ra) # 800009e8 <kfree>
    80001326:	b7d1                	j	800012ea <uvmunmap+0x86>

0000000080001328 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001328:	1101                	addi	sp,sp,-32
    8000132a:	ec06                	sd	ra,24(sp)
    8000132c:	e822                	sd	s0,16(sp)
    8000132e:	e426                	sd	s1,8(sp)
    80001330:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001332:	fffff097          	auipc	ra,0xfffff
    80001336:	7b4080e7          	jalr	1972(ra) # 80000ae6 <kalloc>
    8000133a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000133c:	c519                	beqz	a0,8000134a <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000133e:	6605                	lui	a2,0x1
    80001340:	4581                	li	a1,0
    80001342:	00000097          	auipc	ra,0x0
    80001346:	990080e7          	jalr	-1648(ra) # 80000cd2 <memset>
  return pagetable;
}
    8000134a:	8526                	mv	a0,s1
    8000134c:	60e2                	ld	ra,24(sp)
    8000134e:	6442                	ld	s0,16(sp)
    80001350:	64a2                	ld	s1,8(sp)
    80001352:	6105                	addi	sp,sp,32
    80001354:	8082                	ret

0000000080001356 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001356:	7179                	addi	sp,sp,-48
    80001358:	f406                	sd	ra,40(sp)
    8000135a:	f022                	sd	s0,32(sp)
    8000135c:	ec26                	sd	s1,24(sp)
    8000135e:	e84a                	sd	s2,16(sp)
    80001360:	e44e                	sd	s3,8(sp)
    80001362:	e052                	sd	s4,0(sp)
    80001364:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001366:	6785                	lui	a5,0x1
    80001368:	04f67863          	bgeu	a2,a5,800013b8 <uvmfirst+0x62>
    8000136c:	8a2a                	mv	s4,a0
    8000136e:	89ae                	mv	s3,a1
    80001370:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001372:	fffff097          	auipc	ra,0xfffff
    80001376:	774080e7          	jalr	1908(ra) # 80000ae6 <kalloc>
    8000137a:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000137c:	6605                	lui	a2,0x1
    8000137e:	4581                	li	a1,0
    80001380:	00000097          	auipc	ra,0x0
    80001384:	952080e7          	jalr	-1710(ra) # 80000cd2 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001388:	4779                	li	a4,30
    8000138a:	86ca                	mv	a3,s2
    8000138c:	6605                	lui	a2,0x1
    8000138e:	4581                	li	a1,0
    80001390:	8552                	mv	a0,s4
    80001392:	00000097          	auipc	ra,0x0
    80001396:	d0c080e7          	jalr	-756(ra) # 8000109e <mappages>
  memmove(mem, src, sz);
    8000139a:	8626                	mv	a2,s1
    8000139c:	85ce                	mv	a1,s3
    8000139e:	854a                	mv	a0,s2
    800013a0:	00000097          	auipc	ra,0x0
    800013a4:	98e080e7          	jalr	-1650(ra) # 80000d2e <memmove>
}
    800013a8:	70a2                	ld	ra,40(sp)
    800013aa:	7402                	ld	s0,32(sp)
    800013ac:	64e2                	ld	s1,24(sp)
    800013ae:	6942                	ld	s2,16(sp)
    800013b0:	69a2                	ld	s3,8(sp)
    800013b2:	6a02                	ld	s4,0(sp)
    800013b4:	6145                	addi	sp,sp,48
    800013b6:	8082                	ret
    panic("uvmfirst: more than a page");
    800013b8:	00007517          	auipc	a0,0x7
    800013bc:	da050513          	addi	a0,a0,-608 # 80008158 <digits+0x118>
    800013c0:	fffff097          	auipc	ra,0xfffff
    800013c4:	180080e7          	jalr	384(ra) # 80000540 <panic>

00000000800013c8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013c8:	1101                	addi	sp,sp,-32
    800013ca:	ec06                	sd	ra,24(sp)
    800013cc:	e822                	sd	s0,16(sp)
    800013ce:	e426                	sd	s1,8(sp)
    800013d0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013d2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013d4:	00b67d63          	bgeu	a2,a1,800013ee <uvmdealloc+0x26>
    800013d8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013da:	6785                	lui	a5,0x1
    800013dc:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013de:	00f60733          	add	a4,a2,a5
    800013e2:	76fd                	lui	a3,0xfffff
    800013e4:	8f75                	and	a4,a4,a3
    800013e6:	97ae                	add	a5,a5,a1
    800013e8:	8ff5                	and	a5,a5,a3
    800013ea:	00f76863          	bltu	a4,a5,800013fa <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013ee:	8526                	mv	a0,s1
    800013f0:	60e2                	ld	ra,24(sp)
    800013f2:	6442                	ld	s0,16(sp)
    800013f4:	64a2                	ld	s1,8(sp)
    800013f6:	6105                	addi	sp,sp,32
    800013f8:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013fa:	8f99                	sub	a5,a5,a4
    800013fc:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013fe:	4685                	li	a3,1
    80001400:	0007861b          	sext.w	a2,a5
    80001404:	85ba                	mv	a1,a4
    80001406:	00000097          	auipc	ra,0x0
    8000140a:	e5e080e7          	jalr	-418(ra) # 80001264 <uvmunmap>
    8000140e:	b7c5                	j	800013ee <uvmdealloc+0x26>

0000000080001410 <uvmalloc>:
  if(newsz < oldsz)
    80001410:	0ab66563          	bltu	a2,a1,800014ba <uvmalloc+0xaa>
{
    80001414:	7139                	addi	sp,sp,-64
    80001416:	fc06                	sd	ra,56(sp)
    80001418:	f822                	sd	s0,48(sp)
    8000141a:	f426                	sd	s1,40(sp)
    8000141c:	f04a                	sd	s2,32(sp)
    8000141e:	ec4e                	sd	s3,24(sp)
    80001420:	e852                	sd	s4,16(sp)
    80001422:	e456                	sd	s5,8(sp)
    80001424:	e05a                	sd	s6,0(sp)
    80001426:	0080                	addi	s0,sp,64
    80001428:	8aaa                	mv	s5,a0
    8000142a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000142c:	6785                	lui	a5,0x1
    8000142e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001430:	95be                	add	a1,a1,a5
    80001432:	77fd                	lui	a5,0xfffff
    80001434:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001438:	08c9f363          	bgeu	s3,a2,800014be <uvmalloc+0xae>
    8000143c:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000143e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001442:	fffff097          	auipc	ra,0xfffff
    80001446:	6a4080e7          	jalr	1700(ra) # 80000ae6 <kalloc>
    8000144a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000144c:	c51d                	beqz	a0,8000147a <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    8000144e:	6605                	lui	a2,0x1
    80001450:	4581                	li	a1,0
    80001452:	00000097          	auipc	ra,0x0
    80001456:	880080e7          	jalr	-1920(ra) # 80000cd2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000145a:	875a                	mv	a4,s6
    8000145c:	86a6                	mv	a3,s1
    8000145e:	6605                	lui	a2,0x1
    80001460:	85ca                	mv	a1,s2
    80001462:	8556                	mv	a0,s5
    80001464:	00000097          	auipc	ra,0x0
    80001468:	c3a080e7          	jalr	-966(ra) # 8000109e <mappages>
    8000146c:	e90d                	bnez	a0,8000149e <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000146e:	6785                	lui	a5,0x1
    80001470:	993e                	add	s2,s2,a5
    80001472:	fd4968e3          	bltu	s2,s4,80001442 <uvmalloc+0x32>
  return newsz;
    80001476:	8552                	mv	a0,s4
    80001478:	a809                	j	8000148a <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    8000147a:	864e                	mv	a2,s3
    8000147c:	85ca                	mv	a1,s2
    8000147e:	8556                	mv	a0,s5
    80001480:	00000097          	auipc	ra,0x0
    80001484:	f48080e7          	jalr	-184(ra) # 800013c8 <uvmdealloc>
      return 0;
    80001488:	4501                	li	a0,0
}
    8000148a:	70e2                	ld	ra,56(sp)
    8000148c:	7442                	ld	s0,48(sp)
    8000148e:	74a2                	ld	s1,40(sp)
    80001490:	7902                	ld	s2,32(sp)
    80001492:	69e2                	ld	s3,24(sp)
    80001494:	6a42                	ld	s4,16(sp)
    80001496:	6aa2                	ld	s5,8(sp)
    80001498:	6b02                	ld	s6,0(sp)
    8000149a:	6121                	addi	sp,sp,64
    8000149c:	8082                	ret
      kfree(mem);
    8000149e:	8526                	mv	a0,s1
    800014a0:	fffff097          	auipc	ra,0xfffff
    800014a4:	548080e7          	jalr	1352(ra) # 800009e8 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014a8:	864e                	mv	a2,s3
    800014aa:	85ca                	mv	a1,s2
    800014ac:	8556                	mv	a0,s5
    800014ae:	00000097          	auipc	ra,0x0
    800014b2:	f1a080e7          	jalr	-230(ra) # 800013c8 <uvmdealloc>
      return 0;
    800014b6:	4501                	li	a0,0
    800014b8:	bfc9                	j	8000148a <uvmalloc+0x7a>
    return oldsz;
    800014ba:	852e                	mv	a0,a1
}
    800014bc:	8082                	ret
  return newsz;
    800014be:	8532                	mv	a0,a2
    800014c0:	b7e9                	j	8000148a <uvmalloc+0x7a>

00000000800014c2 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014c2:	7179                	addi	sp,sp,-48
    800014c4:	f406                	sd	ra,40(sp)
    800014c6:	f022                	sd	s0,32(sp)
    800014c8:	ec26                	sd	s1,24(sp)
    800014ca:	e84a                	sd	s2,16(sp)
    800014cc:	e44e                	sd	s3,8(sp)
    800014ce:	e052                	sd	s4,0(sp)
    800014d0:	1800                	addi	s0,sp,48
    800014d2:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014d4:	84aa                	mv	s1,a0
    800014d6:	6905                	lui	s2,0x1
    800014d8:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014da:	4985                	li	s3,1
    800014dc:	a829                	j	800014f6 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014de:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800014e0:	00c79513          	slli	a0,a5,0xc
    800014e4:	00000097          	auipc	ra,0x0
    800014e8:	fde080e7          	jalr	-34(ra) # 800014c2 <freewalk>
      pagetable[i] = 0;
    800014ec:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014f0:	04a1                	addi	s1,s1,8
    800014f2:	03248163          	beq	s1,s2,80001514 <freewalk+0x52>
    pte_t pte = pagetable[i];
    800014f6:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014f8:	00f7f713          	andi	a4,a5,15
    800014fc:	ff3701e3          	beq	a4,s3,800014de <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001500:	8b85                	andi	a5,a5,1
    80001502:	d7fd                	beqz	a5,800014f0 <freewalk+0x2e>
      panic("freewalk: leaf");
    80001504:	00007517          	auipc	a0,0x7
    80001508:	c7450513          	addi	a0,a0,-908 # 80008178 <digits+0x138>
    8000150c:	fffff097          	auipc	ra,0xfffff
    80001510:	034080e7          	jalr	52(ra) # 80000540 <panic>
    }
  }
  kfree((void*)pagetable);
    80001514:	8552                	mv	a0,s4
    80001516:	fffff097          	auipc	ra,0xfffff
    8000151a:	4d2080e7          	jalr	1234(ra) # 800009e8 <kfree>
}
    8000151e:	70a2                	ld	ra,40(sp)
    80001520:	7402                	ld	s0,32(sp)
    80001522:	64e2                	ld	s1,24(sp)
    80001524:	6942                	ld	s2,16(sp)
    80001526:	69a2                	ld	s3,8(sp)
    80001528:	6a02                	ld	s4,0(sp)
    8000152a:	6145                	addi	sp,sp,48
    8000152c:	8082                	ret

000000008000152e <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000152e:	1101                	addi	sp,sp,-32
    80001530:	ec06                	sd	ra,24(sp)
    80001532:	e822                	sd	s0,16(sp)
    80001534:	e426                	sd	s1,8(sp)
    80001536:	1000                	addi	s0,sp,32
    80001538:	84aa                	mv	s1,a0
  if(sz > 0)
    8000153a:	e999                	bnez	a1,80001550 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000153c:	8526                	mv	a0,s1
    8000153e:	00000097          	auipc	ra,0x0
    80001542:	f84080e7          	jalr	-124(ra) # 800014c2 <freewalk>
}
    80001546:	60e2                	ld	ra,24(sp)
    80001548:	6442                	ld	s0,16(sp)
    8000154a:	64a2                	ld	s1,8(sp)
    8000154c:	6105                	addi	sp,sp,32
    8000154e:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001550:	6785                	lui	a5,0x1
    80001552:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001554:	95be                	add	a1,a1,a5
    80001556:	4685                	li	a3,1
    80001558:	00c5d613          	srli	a2,a1,0xc
    8000155c:	4581                	li	a1,0
    8000155e:	00000097          	auipc	ra,0x0
    80001562:	d06080e7          	jalr	-762(ra) # 80001264 <uvmunmap>
    80001566:	bfd9                	j	8000153c <uvmfree+0xe>

0000000080001568 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001568:	c679                	beqz	a2,80001636 <uvmcopy+0xce>
{
    8000156a:	715d                	addi	sp,sp,-80
    8000156c:	e486                	sd	ra,72(sp)
    8000156e:	e0a2                	sd	s0,64(sp)
    80001570:	fc26                	sd	s1,56(sp)
    80001572:	f84a                	sd	s2,48(sp)
    80001574:	f44e                	sd	s3,40(sp)
    80001576:	f052                	sd	s4,32(sp)
    80001578:	ec56                	sd	s5,24(sp)
    8000157a:	e85a                	sd	s6,16(sp)
    8000157c:	e45e                	sd	s7,8(sp)
    8000157e:	0880                	addi	s0,sp,80
    80001580:	8b2a                	mv	s6,a0
    80001582:	8aae                	mv	s5,a1
    80001584:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001586:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001588:	4601                	li	a2,0
    8000158a:	85ce                	mv	a1,s3
    8000158c:	855a                	mv	a0,s6
    8000158e:	00000097          	auipc	ra,0x0
    80001592:	a28080e7          	jalr	-1496(ra) # 80000fb6 <walk>
    80001596:	c531                	beqz	a0,800015e2 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001598:	6118                	ld	a4,0(a0)
    8000159a:	00177793          	andi	a5,a4,1
    8000159e:	cbb1                	beqz	a5,800015f2 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015a0:	00a75593          	srli	a1,a4,0xa
    800015a4:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015a8:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015ac:	fffff097          	auipc	ra,0xfffff
    800015b0:	53a080e7          	jalr	1338(ra) # 80000ae6 <kalloc>
    800015b4:	892a                	mv	s2,a0
    800015b6:	c939                	beqz	a0,8000160c <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015b8:	6605                	lui	a2,0x1
    800015ba:	85de                	mv	a1,s7
    800015bc:	fffff097          	auipc	ra,0xfffff
    800015c0:	772080e7          	jalr	1906(ra) # 80000d2e <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015c4:	8726                	mv	a4,s1
    800015c6:	86ca                	mv	a3,s2
    800015c8:	6605                	lui	a2,0x1
    800015ca:	85ce                	mv	a1,s3
    800015cc:	8556                	mv	a0,s5
    800015ce:	00000097          	auipc	ra,0x0
    800015d2:	ad0080e7          	jalr	-1328(ra) # 8000109e <mappages>
    800015d6:	e515                	bnez	a0,80001602 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015d8:	6785                	lui	a5,0x1
    800015da:	99be                	add	s3,s3,a5
    800015dc:	fb49e6e3          	bltu	s3,s4,80001588 <uvmcopy+0x20>
    800015e0:	a081                	j	80001620 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015e2:	00007517          	auipc	a0,0x7
    800015e6:	ba650513          	addi	a0,a0,-1114 # 80008188 <digits+0x148>
    800015ea:	fffff097          	auipc	ra,0xfffff
    800015ee:	f56080e7          	jalr	-170(ra) # 80000540 <panic>
      panic("uvmcopy: page not present");
    800015f2:	00007517          	auipc	a0,0x7
    800015f6:	bb650513          	addi	a0,a0,-1098 # 800081a8 <digits+0x168>
    800015fa:	fffff097          	auipc	ra,0xfffff
    800015fe:	f46080e7          	jalr	-186(ra) # 80000540 <panic>
      kfree(mem);
    80001602:	854a                	mv	a0,s2
    80001604:	fffff097          	auipc	ra,0xfffff
    80001608:	3e4080e7          	jalr	996(ra) # 800009e8 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000160c:	4685                	li	a3,1
    8000160e:	00c9d613          	srli	a2,s3,0xc
    80001612:	4581                	li	a1,0
    80001614:	8556                	mv	a0,s5
    80001616:	00000097          	auipc	ra,0x0
    8000161a:	c4e080e7          	jalr	-946(ra) # 80001264 <uvmunmap>
  return -1;
    8000161e:	557d                	li	a0,-1
}
    80001620:	60a6                	ld	ra,72(sp)
    80001622:	6406                	ld	s0,64(sp)
    80001624:	74e2                	ld	s1,56(sp)
    80001626:	7942                	ld	s2,48(sp)
    80001628:	79a2                	ld	s3,40(sp)
    8000162a:	7a02                	ld	s4,32(sp)
    8000162c:	6ae2                	ld	s5,24(sp)
    8000162e:	6b42                	ld	s6,16(sp)
    80001630:	6ba2                	ld	s7,8(sp)
    80001632:	6161                	addi	sp,sp,80
    80001634:	8082                	ret
  return 0;
    80001636:	4501                	li	a0,0
}
    80001638:	8082                	ret

000000008000163a <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000163a:	1141                	addi	sp,sp,-16
    8000163c:	e406                	sd	ra,8(sp)
    8000163e:	e022                	sd	s0,0(sp)
    80001640:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001642:	4601                	li	a2,0
    80001644:	00000097          	auipc	ra,0x0
    80001648:	972080e7          	jalr	-1678(ra) # 80000fb6 <walk>
  if(pte == 0)
    8000164c:	c901                	beqz	a0,8000165c <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000164e:	611c                	ld	a5,0(a0)
    80001650:	9bbd                	andi	a5,a5,-17
    80001652:	e11c                	sd	a5,0(a0)
}
    80001654:	60a2                	ld	ra,8(sp)
    80001656:	6402                	ld	s0,0(sp)
    80001658:	0141                	addi	sp,sp,16
    8000165a:	8082                	ret
    panic("uvmclear");
    8000165c:	00007517          	auipc	a0,0x7
    80001660:	b6c50513          	addi	a0,a0,-1172 # 800081c8 <digits+0x188>
    80001664:	fffff097          	auipc	ra,0xfffff
    80001668:	edc080e7          	jalr	-292(ra) # 80000540 <panic>

000000008000166c <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000166c:	c6bd                	beqz	a3,800016da <copyout+0x6e>
{
    8000166e:	715d                	addi	sp,sp,-80
    80001670:	e486                	sd	ra,72(sp)
    80001672:	e0a2                	sd	s0,64(sp)
    80001674:	fc26                	sd	s1,56(sp)
    80001676:	f84a                	sd	s2,48(sp)
    80001678:	f44e                	sd	s3,40(sp)
    8000167a:	f052                	sd	s4,32(sp)
    8000167c:	ec56                	sd	s5,24(sp)
    8000167e:	e85a                	sd	s6,16(sp)
    80001680:	e45e                	sd	s7,8(sp)
    80001682:	e062                	sd	s8,0(sp)
    80001684:	0880                	addi	s0,sp,80
    80001686:	8b2a                	mv	s6,a0
    80001688:	8c2e                	mv	s8,a1
    8000168a:	8a32                	mv	s4,a2
    8000168c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000168e:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001690:	6a85                	lui	s5,0x1
    80001692:	a015                	j	800016b6 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001694:	9562                	add	a0,a0,s8
    80001696:	0004861b          	sext.w	a2,s1
    8000169a:	85d2                	mv	a1,s4
    8000169c:	41250533          	sub	a0,a0,s2
    800016a0:	fffff097          	auipc	ra,0xfffff
    800016a4:	68e080e7          	jalr	1678(ra) # 80000d2e <memmove>

    len -= n;
    800016a8:	409989b3          	sub	s3,s3,s1
    src += n;
    800016ac:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016ae:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016b2:	02098263          	beqz	s3,800016d6 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016b6:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016ba:	85ca                	mv	a1,s2
    800016bc:	855a                	mv	a0,s6
    800016be:	00000097          	auipc	ra,0x0
    800016c2:	99e080e7          	jalr	-1634(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800016c6:	cd01                	beqz	a0,800016de <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016c8:	418904b3          	sub	s1,s2,s8
    800016cc:	94d6                	add	s1,s1,s5
    800016ce:	fc99f3e3          	bgeu	s3,s1,80001694 <copyout+0x28>
    800016d2:	84ce                	mv	s1,s3
    800016d4:	b7c1                	j	80001694 <copyout+0x28>
  }
  return 0;
    800016d6:	4501                	li	a0,0
    800016d8:	a021                	j	800016e0 <copyout+0x74>
    800016da:	4501                	li	a0,0
}
    800016dc:	8082                	ret
      return -1;
    800016de:	557d                	li	a0,-1
}
    800016e0:	60a6                	ld	ra,72(sp)
    800016e2:	6406                	ld	s0,64(sp)
    800016e4:	74e2                	ld	s1,56(sp)
    800016e6:	7942                	ld	s2,48(sp)
    800016e8:	79a2                	ld	s3,40(sp)
    800016ea:	7a02                	ld	s4,32(sp)
    800016ec:	6ae2                	ld	s5,24(sp)
    800016ee:	6b42                	ld	s6,16(sp)
    800016f0:	6ba2                	ld	s7,8(sp)
    800016f2:	6c02                	ld	s8,0(sp)
    800016f4:	6161                	addi	sp,sp,80
    800016f6:	8082                	ret

00000000800016f8 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016f8:	caa5                	beqz	a3,80001768 <copyin+0x70>
{
    800016fa:	715d                	addi	sp,sp,-80
    800016fc:	e486                	sd	ra,72(sp)
    800016fe:	e0a2                	sd	s0,64(sp)
    80001700:	fc26                	sd	s1,56(sp)
    80001702:	f84a                	sd	s2,48(sp)
    80001704:	f44e                	sd	s3,40(sp)
    80001706:	f052                	sd	s4,32(sp)
    80001708:	ec56                	sd	s5,24(sp)
    8000170a:	e85a                	sd	s6,16(sp)
    8000170c:	e45e                	sd	s7,8(sp)
    8000170e:	e062                	sd	s8,0(sp)
    80001710:	0880                	addi	s0,sp,80
    80001712:	8b2a                	mv	s6,a0
    80001714:	8a2e                	mv	s4,a1
    80001716:	8c32                	mv	s8,a2
    80001718:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000171a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000171c:	6a85                	lui	s5,0x1
    8000171e:	a01d                	j	80001744 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001720:	018505b3          	add	a1,a0,s8
    80001724:	0004861b          	sext.w	a2,s1
    80001728:	412585b3          	sub	a1,a1,s2
    8000172c:	8552                	mv	a0,s4
    8000172e:	fffff097          	auipc	ra,0xfffff
    80001732:	600080e7          	jalr	1536(ra) # 80000d2e <memmove>

    len -= n;
    80001736:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000173a:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000173c:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001740:	02098263          	beqz	s3,80001764 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001744:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001748:	85ca                	mv	a1,s2
    8000174a:	855a                	mv	a0,s6
    8000174c:	00000097          	auipc	ra,0x0
    80001750:	910080e7          	jalr	-1776(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    80001754:	cd01                	beqz	a0,8000176c <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001756:	418904b3          	sub	s1,s2,s8
    8000175a:	94d6                	add	s1,s1,s5
    8000175c:	fc99f2e3          	bgeu	s3,s1,80001720 <copyin+0x28>
    80001760:	84ce                	mv	s1,s3
    80001762:	bf7d                	j	80001720 <copyin+0x28>
  }
  return 0;
    80001764:	4501                	li	a0,0
    80001766:	a021                	j	8000176e <copyin+0x76>
    80001768:	4501                	li	a0,0
}
    8000176a:	8082                	ret
      return -1;
    8000176c:	557d                	li	a0,-1
}
    8000176e:	60a6                	ld	ra,72(sp)
    80001770:	6406                	ld	s0,64(sp)
    80001772:	74e2                	ld	s1,56(sp)
    80001774:	7942                	ld	s2,48(sp)
    80001776:	79a2                	ld	s3,40(sp)
    80001778:	7a02                	ld	s4,32(sp)
    8000177a:	6ae2                	ld	s5,24(sp)
    8000177c:	6b42                	ld	s6,16(sp)
    8000177e:	6ba2                	ld	s7,8(sp)
    80001780:	6c02                	ld	s8,0(sp)
    80001782:	6161                	addi	sp,sp,80
    80001784:	8082                	ret

0000000080001786 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001786:	c2dd                	beqz	a3,8000182c <copyinstr+0xa6>
{
    80001788:	715d                	addi	sp,sp,-80
    8000178a:	e486                	sd	ra,72(sp)
    8000178c:	e0a2                	sd	s0,64(sp)
    8000178e:	fc26                	sd	s1,56(sp)
    80001790:	f84a                	sd	s2,48(sp)
    80001792:	f44e                	sd	s3,40(sp)
    80001794:	f052                	sd	s4,32(sp)
    80001796:	ec56                	sd	s5,24(sp)
    80001798:	e85a                	sd	s6,16(sp)
    8000179a:	e45e                	sd	s7,8(sp)
    8000179c:	0880                	addi	s0,sp,80
    8000179e:	8a2a                	mv	s4,a0
    800017a0:	8b2e                	mv	s6,a1
    800017a2:	8bb2                	mv	s7,a2
    800017a4:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017a6:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017a8:	6985                	lui	s3,0x1
    800017aa:	a02d                	j	800017d4 <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017ac:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017b0:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017b2:	37fd                	addiw	a5,a5,-1
    800017b4:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017b8:	60a6                	ld	ra,72(sp)
    800017ba:	6406                	ld	s0,64(sp)
    800017bc:	74e2                	ld	s1,56(sp)
    800017be:	7942                	ld	s2,48(sp)
    800017c0:	79a2                	ld	s3,40(sp)
    800017c2:	7a02                	ld	s4,32(sp)
    800017c4:	6ae2                	ld	s5,24(sp)
    800017c6:	6b42                	ld	s6,16(sp)
    800017c8:	6ba2                	ld	s7,8(sp)
    800017ca:	6161                	addi	sp,sp,80
    800017cc:	8082                	ret
    srcva = va0 + PGSIZE;
    800017ce:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017d2:	c8a9                	beqz	s1,80001824 <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800017d4:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017d8:	85ca                	mv	a1,s2
    800017da:	8552                	mv	a0,s4
    800017dc:	00000097          	auipc	ra,0x0
    800017e0:	880080e7          	jalr	-1920(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800017e4:	c131                	beqz	a0,80001828 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800017e6:	417906b3          	sub	a3,s2,s7
    800017ea:	96ce                	add	a3,a3,s3
    800017ec:	00d4f363          	bgeu	s1,a3,800017f2 <copyinstr+0x6c>
    800017f0:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017f2:	955e                	add	a0,a0,s7
    800017f4:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017f8:	daf9                	beqz	a3,800017ce <copyinstr+0x48>
    800017fa:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017fc:	41650633          	sub	a2,a0,s6
    80001800:	fff48593          	addi	a1,s1,-1
    80001804:	95da                	add	a1,a1,s6
    while(n > 0){
    80001806:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    80001808:	00f60733          	add	a4,a2,a5
    8000180c:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdc978>
    80001810:	df51                	beqz	a4,800017ac <copyinstr+0x26>
        *dst = *p;
    80001812:	00e78023          	sb	a4,0(a5)
      --max;
    80001816:	40f584b3          	sub	s1,a1,a5
      dst++;
    8000181a:	0785                	addi	a5,a5,1
    while(n > 0){
    8000181c:	fed796e3          	bne	a5,a3,80001808 <copyinstr+0x82>
      dst++;
    80001820:	8b3e                	mv	s6,a5
    80001822:	b775                	j	800017ce <copyinstr+0x48>
    80001824:	4781                	li	a5,0
    80001826:	b771                	j	800017b2 <copyinstr+0x2c>
      return -1;
    80001828:	557d                	li	a0,-1
    8000182a:	b779                	j	800017b8 <copyinstr+0x32>
  int got_null = 0;
    8000182c:	4781                	li	a5,0
  if(got_null){
    8000182e:	37fd                	addiw	a5,a5,-1
    80001830:	0007851b          	sext.w	a0,a5
}
    80001834:	8082                	ret

0000000080001836 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001836:	7139                	addi	sp,sp,-64
    80001838:	fc06                	sd	ra,56(sp)
    8000183a:	f822                	sd	s0,48(sp)
    8000183c:	f426                	sd	s1,40(sp)
    8000183e:	f04a                	sd	s2,32(sp)
    80001840:	ec4e                	sd	s3,24(sp)
    80001842:	e852                	sd	s4,16(sp)
    80001844:	e456                	sd	s5,8(sp)
    80001846:	e05a                	sd	s6,0(sp)
    80001848:	0080                	addi	s0,sp,64
    8000184a:	89aa                	mv	s3,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000184c:	00010497          	auipc	s1,0x10
    80001850:	85c48493          	addi	s1,s1,-1956 # 800110a8 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001854:	8b26                	mv	s6,s1
    80001856:	00006a97          	auipc	s5,0x6
    8000185a:	7aaa8a93          	addi	s5,s5,1962 # 80008000 <etext>
    8000185e:	04000937          	lui	s2,0x4000
    80001862:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001864:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001866:	00016a17          	auipc	s4,0x16
    8000186a:	a42a0a13          	addi	s4,s4,-1470 # 800172a8 <tickslock>
    char *pa = kalloc();
    8000186e:	fffff097          	auipc	ra,0xfffff
    80001872:	278080e7          	jalr	632(ra) # 80000ae6 <kalloc>
    80001876:	862a                	mv	a2,a0
    if(pa == 0)
    80001878:	c131                	beqz	a0,800018bc <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    8000187a:	416485b3          	sub	a1,s1,s6
    8000187e:	858d                	srai	a1,a1,0x3
    80001880:	000ab783          	ld	a5,0(s5)
    80001884:	02f585b3          	mul	a1,a1,a5
    80001888:	2585                	addiw	a1,a1,1
    8000188a:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000188e:	4719                	li	a4,6
    80001890:	6685                	lui	a3,0x1
    80001892:	40b905b3          	sub	a1,s2,a1
    80001896:	854e                	mv	a0,s3
    80001898:	00000097          	auipc	ra,0x0
    8000189c:	8a6080e7          	jalr	-1882(ra) # 8000113e <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018a0:	18848493          	addi	s1,s1,392
    800018a4:	fd4495e3          	bne	s1,s4,8000186e <proc_mapstacks+0x38>
  }
}
    800018a8:	70e2                	ld	ra,56(sp)
    800018aa:	7442                	ld	s0,48(sp)
    800018ac:	74a2                	ld	s1,40(sp)
    800018ae:	7902                	ld	s2,32(sp)
    800018b0:	69e2                	ld	s3,24(sp)
    800018b2:	6a42                	ld	s4,16(sp)
    800018b4:	6aa2                	ld	s5,8(sp)
    800018b6:	6b02                	ld	s6,0(sp)
    800018b8:	6121                	addi	sp,sp,64
    800018ba:	8082                	ret
      panic("kalloc");
    800018bc:	00007517          	auipc	a0,0x7
    800018c0:	91c50513          	addi	a0,a0,-1764 # 800081d8 <digits+0x198>
    800018c4:	fffff097          	auipc	ra,0xfffff
    800018c8:	c7c080e7          	jalr	-900(ra) # 80000540 <panic>

00000000800018cc <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800018cc:	7139                	addi	sp,sp,-64
    800018ce:	fc06                	sd	ra,56(sp)
    800018d0:	f822                	sd	s0,48(sp)
    800018d2:	f426                	sd	s1,40(sp)
    800018d4:	f04a                	sd	s2,32(sp)
    800018d6:	ec4e                	sd	s3,24(sp)
    800018d8:	e852                	sd	s4,16(sp)
    800018da:	e456                	sd	s5,8(sp)
    800018dc:	e05a                	sd	s6,0(sp)
    800018de:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    800018e0:	00007597          	auipc	a1,0x7
    800018e4:	90058593          	addi	a1,a1,-1792 # 800081e0 <digits+0x1a0>
    800018e8:	0000f517          	auipc	a0,0xf
    800018ec:	37850513          	addi	a0,a0,888 # 80010c60 <pid_lock>
    800018f0:	fffff097          	auipc	ra,0xfffff
    800018f4:	256080e7          	jalr	598(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018f8:	00007597          	auipc	a1,0x7
    800018fc:	8f058593          	addi	a1,a1,-1808 # 800081e8 <digits+0x1a8>
    80001900:	0000f517          	auipc	a0,0xf
    80001904:	37850513          	addi	a0,a0,888 # 80010c78 <wait_lock>
    80001908:	fffff097          	auipc	ra,0xfffff
    8000190c:	23e080e7          	jalr	574(ra) # 80000b46 <initlock>
  initlock(&thread_lock, "next_thread_id");
    80001910:	00007597          	auipc	a1,0x7
    80001914:	8e858593          	addi	a1,a1,-1816 # 800081f8 <digits+0x1b8>
    80001918:	0000f517          	auipc	a0,0xf
    8000191c:	37850513          	addi	a0,a0,888 # 80010c90 <thread_lock>
    80001920:	fffff097          	auipc	ra,0xfffff
    80001924:	226080e7          	jalr	550(ra) # 80000b46 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001928:	0000f497          	auipc	s1,0xf
    8000192c:	78048493          	addi	s1,s1,1920 # 800110a8 <proc>
      initlock(&p->lock, "proc");
    80001930:	00007b17          	auipc	s6,0x7
    80001934:	8d8b0b13          	addi	s6,s6,-1832 # 80008208 <digits+0x1c8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001938:	8aa6                	mv	s5,s1
    8000193a:	00006a17          	auipc	s4,0x6
    8000193e:	6c6a0a13          	addi	s4,s4,1734 # 80008000 <etext>
    80001942:	04000937          	lui	s2,0x4000
    80001946:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001948:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000194a:	00016997          	auipc	s3,0x16
    8000194e:	95e98993          	addi	s3,s3,-1698 # 800172a8 <tickslock>
      initlock(&p->lock, "proc");
    80001952:	85da                	mv	a1,s6
    80001954:	8526                	mv	a0,s1
    80001956:	fffff097          	auipc	ra,0xfffff
    8000195a:	1f0080e7          	jalr	496(ra) # 80000b46 <initlock>
      p->state = UNUSED;
    8000195e:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001962:	415487b3          	sub	a5,s1,s5
    80001966:	878d                	srai	a5,a5,0x3
    80001968:	000a3703          	ld	a4,0(s4)
    8000196c:	02e787b3          	mul	a5,a5,a4
    80001970:	2785                	addiw	a5,a5,1
    80001972:	00d7979b          	slliw	a5,a5,0xd
    80001976:	40f907b3          	sub	a5,s2,a5
    8000197a:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000197c:	18848493          	addi	s1,s1,392
    80001980:	fd3499e3          	bne	s1,s3,80001952 <procinit+0x86>
  }
}
    80001984:	70e2                	ld	ra,56(sp)
    80001986:	7442                	ld	s0,48(sp)
    80001988:	74a2                	ld	s1,40(sp)
    8000198a:	7902                	ld	s2,32(sp)
    8000198c:	69e2                	ld	s3,24(sp)
    8000198e:	6a42                	ld	s4,16(sp)
    80001990:	6aa2                	ld	s5,8(sp)
    80001992:	6b02                	ld	s6,0(sp)
    80001994:	6121                	addi	sp,sp,64
    80001996:	8082                	ret

0000000080001998 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001998:	1141                	addi	sp,sp,-16
    8000199a:	e422                	sd	s0,8(sp)
    8000199c:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    8000199e:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800019a0:	2501                	sext.w	a0,a0
    800019a2:	6422                	ld	s0,8(sp)
    800019a4:	0141                	addi	sp,sp,16
    800019a6:	8082                	ret

00000000800019a8 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800019a8:	1141                	addi	sp,sp,-16
    800019aa:	e422                	sd	s0,8(sp)
    800019ac:	0800                	addi	s0,sp,16
    800019ae:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800019b0:	2781                	sext.w	a5,a5
    800019b2:	079e                	slli	a5,a5,0x7
  return c;
}
    800019b4:	0000f517          	auipc	a0,0xf
    800019b8:	2f450513          	addi	a0,a0,756 # 80010ca8 <cpus>
    800019bc:	953e                	add	a0,a0,a5
    800019be:	6422                	ld	s0,8(sp)
    800019c0:	0141                	addi	sp,sp,16
    800019c2:	8082                	ret

00000000800019c4 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800019c4:	1101                	addi	sp,sp,-32
    800019c6:	ec06                	sd	ra,24(sp)
    800019c8:	e822                	sd	s0,16(sp)
    800019ca:	e426                	sd	s1,8(sp)
    800019cc:	1000                	addi	s0,sp,32
  push_off();
    800019ce:	fffff097          	auipc	ra,0xfffff
    800019d2:	1bc080e7          	jalr	444(ra) # 80000b8a <push_off>
    800019d6:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019d8:	2781                	sext.w	a5,a5
    800019da:	079e                	slli	a5,a5,0x7
    800019dc:	0000f717          	auipc	a4,0xf
    800019e0:	28470713          	addi	a4,a4,644 # 80010c60 <pid_lock>
    800019e4:	97ba                	add	a5,a5,a4
    800019e6:	67a4                	ld	s1,72(a5)
  pop_off();
    800019e8:	fffff097          	auipc	ra,0xfffff
    800019ec:	242080e7          	jalr	578(ra) # 80000c2a <pop_off>
  return p;
}
    800019f0:	8526                	mv	a0,s1
    800019f2:	60e2                	ld	ra,24(sp)
    800019f4:	6442                	ld	s0,16(sp)
    800019f6:	64a2                	ld	s1,8(sp)
    800019f8:	6105                	addi	sp,sp,32
    800019fa:	8082                	ret

00000000800019fc <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019fc:	1141                	addi	sp,sp,-16
    800019fe:	e406                	sd	ra,8(sp)
    80001a00:	e022                	sd	s0,0(sp)
    80001a02:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a04:	00000097          	auipc	ra,0x0
    80001a08:	fc0080e7          	jalr	-64(ra) # 800019c4 <myproc>
    80001a0c:	fffff097          	auipc	ra,0xfffff
    80001a10:	27e080e7          	jalr	638(ra) # 80000c8a <release>

  if (first) {
    80001a14:	00007797          	auipc	a5,0x7
    80001a18:	f1c7a783          	lw	a5,-228(a5) # 80008930 <first.2>
    80001a1c:	eb89                	bnez	a5,80001a2e <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a1e:	00001097          	auipc	ra,0x1
    80001a22:	0e6080e7          	jalr	230(ra) # 80002b04 <usertrapret>
}
    80001a26:	60a2                	ld	ra,8(sp)
    80001a28:	6402                	ld	s0,0(sp)
    80001a2a:	0141                	addi	sp,sp,16
    80001a2c:	8082                	ret
    first = 0;
    80001a2e:	00007797          	auipc	a5,0x7
    80001a32:	f007a123          	sw	zero,-254(a5) # 80008930 <first.2>
    fsinit(ROOTDEV);
    80001a36:	4505                	li	a0,1
    80001a38:	00002097          	auipc	ra,0x2
    80001a3c:	f38080e7          	jalr	-200(ra) # 80003970 <fsinit>
    80001a40:	bff9                	j	80001a1e <forkret+0x22>

0000000080001a42 <allocpid>:
{
    80001a42:	1101                	addi	sp,sp,-32
    80001a44:	ec06                	sd	ra,24(sp)
    80001a46:	e822                	sd	s0,16(sp)
    80001a48:	e426                	sd	s1,8(sp)
    80001a4a:	e04a                	sd	s2,0(sp)
    80001a4c:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a4e:	0000f917          	auipc	s2,0xf
    80001a52:	21290913          	addi	s2,s2,530 # 80010c60 <pid_lock>
    80001a56:	854a                	mv	a0,s2
    80001a58:	fffff097          	auipc	ra,0xfffff
    80001a5c:	17e080e7          	jalr	382(ra) # 80000bd6 <acquire>
  pid = nextpid;
    80001a60:	00007797          	auipc	a5,0x7
    80001a64:	ee078793          	addi	a5,a5,-288 # 80008940 <nextpid>
    80001a68:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a6a:	0014871b          	addiw	a4,s1,1
    80001a6e:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a70:	854a                	mv	a0,s2
    80001a72:	fffff097          	auipc	ra,0xfffff
    80001a76:	218080e7          	jalr	536(ra) # 80000c8a <release>
}
    80001a7a:	8526                	mv	a0,s1
    80001a7c:	60e2                	ld	ra,24(sp)
    80001a7e:	6442                	ld	s0,16(sp)
    80001a80:	64a2                	ld	s1,8(sp)
    80001a82:	6902                	ld	s2,0(sp)
    80001a84:	6105                	addi	sp,sp,32
    80001a86:	8082                	ret

0000000080001a88 <proc_pagetable>:
{
    80001a88:	1101                	addi	sp,sp,-32
    80001a8a:	ec06                	sd	ra,24(sp)
    80001a8c:	e822                	sd	s0,16(sp)
    80001a8e:	e426                	sd	s1,8(sp)
    80001a90:	e04a                	sd	s2,0(sp)
    80001a92:	1000                	addi	s0,sp,32
    80001a94:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a96:	00000097          	auipc	ra,0x0
    80001a9a:	892080e7          	jalr	-1902(ra) # 80001328 <uvmcreate>
    80001a9e:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001aa0:	c121                	beqz	a0,80001ae0 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001aa2:	4729                	li	a4,10
    80001aa4:	00005697          	auipc	a3,0x5
    80001aa8:	55c68693          	addi	a3,a3,1372 # 80007000 <_trampoline>
    80001aac:	6605                	lui	a2,0x1
    80001aae:	040005b7          	lui	a1,0x4000
    80001ab2:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ab4:	05b2                	slli	a1,a1,0xc
    80001ab6:	fffff097          	auipc	ra,0xfffff
    80001aba:	5e8080e7          	jalr	1512(ra) # 8000109e <mappages>
    80001abe:	02054863          	bltz	a0,80001aee <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ac2:	4719                	li	a4,6
    80001ac4:	05893683          	ld	a3,88(s2)
    80001ac8:	6605                	lui	a2,0x1
    80001aca:	020005b7          	lui	a1,0x2000
    80001ace:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001ad0:	05b6                	slli	a1,a1,0xd
    80001ad2:	8526                	mv	a0,s1
    80001ad4:	fffff097          	auipc	ra,0xfffff
    80001ad8:	5ca080e7          	jalr	1482(ra) # 8000109e <mappages>
    80001adc:	02054163          	bltz	a0,80001afe <proc_pagetable+0x76>
}
    80001ae0:	8526                	mv	a0,s1
    80001ae2:	60e2                	ld	ra,24(sp)
    80001ae4:	6442                	ld	s0,16(sp)
    80001ae6:	64a2                	ld	s1,8(sp)
    80001ae8:	6902                	ld	s2,0(sp)
    80001aea:	6105                	addi	sp,sp,32
    80001aec:	8082                	ret
    uvmfree(pagetable, 0);
    80001aee:	4581                	li	a1,0
    80001af0:	8526                	mv	a0,s1
    80001af2:	00000097          	auipc	ra,0x0
    80001af6:	a3c080e7          	jalr	-1476(ra) # 8000152e <uvmfree>
    return 0;
    80001afa:	4481                	li	s1,0
    80001afc:	b7d5                	j	80001ae0 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001afe:	4681                	li	a3,0
    80001b00:	4605                	li	a2,1
    80001b02:	040005b7          	lui	a1,0x4000
    80001b06:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b08:	05b2                	slli	a1,a1,0xc
    80001b0a:	8526                	mv	a0,s1
    80001b0c:	fffff097          	auipc	ra,0xfffff
    80001b10:	758080e7          	jalr	1880(ra) # 80001264 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b14:	4581                	li	a1,0
    80001b16:	8526                	mv	a0,s1
    80001b18:	00000097          	auipc	ra,0x0
    80001b1c:	a16080e7          	jalr	-1514(ra) # 8000152e <uvmfree>
    return 0;
    80001b20:	4481                	li	s1,0
    80001b22:	bf7d                	j	80001ae0 <proc_pagetable+0x58>

0000000080001b24 <proc_freepagetable>:
{
    80001b24:	1101                	addi	sp,sp,-32
    80001b26:	ec06                	sd	ra,24(sp)
    80001b28:	e822                	sd	s0,16(sp)
    80001b2a:	e426                	sd	s1,8(sp)
    80001b2c:	e04a                	sd	s2,0(sp)
    80001b2e:	1000                	addi	s0,sp,32
    80001b30:	84aa                	mv	s1,a0
    80001b32:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b34:	4681                	li	a3,0
    80001b36:	4605                	li	a2,1
    80001b38:	040005b7          	lui	a1,0x4000
    80001b3c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b3e:	05b2                	slli	a1,a1,0xc
    80001b40:	fffff097          	auipc	ra,0xfffff
    80001b44:	724080e7          	jalr	1828(ra) # 80001264 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b48:	4681                	li	a3,0
    80001b4a:	4605                	li	a2,1
    80001b4c:	020005b7          	lui	a1,0x2000
    80001b50:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b52:	05b6                	slli	a1,a1,0xd
    80001b54:	8526                	mv	a0,s1
    80001b56:	fffff097          	auipc	ra,0xfffff
    80001b5a:	70e080e7          	jalr	1806(ra) # 80001264 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b5e:	85ca                	mv	a1,s2
    80001b60:	8526                	mv	a0,s1
    80001b62:	00000097          	auipc	ra,0x0
    80001b66:	9cc080e7          	jalr	-1588(ra) # 8000152e <uvmfree>
}
    80001b6a:	60e2                	ld	ra,24(sp)
    80001b6c:	6442                	ld	s0,16(sp)
    80001b6e:	64a2                	ld	s1,8(sp)
    80001b70:	6902                	ld	s2,0(sp)
    80001b72:	6105                	addi	sp,sp,32
    80001b74:	8082                	ret

0000000080001b76 <freeproc>:
{
    80001b76:	1101                	addi	sp,sp,-32
    80001b78:	ec06                	sd	ra,24(sp)
    80001b7a:	e822                	sd	s0,16(sp)
    80001b7c:	e426                	sd	s1,8(sp)
    80001b7e:	1000                	addi	s0,sp,32
    80001b80:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b82:	6d28                	ld	a0,88(a0)
    80001b84:	c509                	beqz	a0,80001b8e <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b86:	fffff097          	auipc	ra,0xfffff
    80001b8a:	e62080e7          	jalr	-414(ra) # 800009e8 <kfree>
  p->trapframe = 0;
    80001b8e:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable!=0 && p->thread_id == 0){
    80001b92:	68a8                	ld	a0,80(s1)
    80001b94:	c501                	beqz	a0,80001b9c <freeproc+0x26>
    80001b96:	1804a783          	lw	a5,384(s1)
    80001b9a:	cbb1                	beqz	a5,80001bee <freeproc+0x78>
    uvmunmap(p->pagetable, TRAPFRAME - PGSIZE * (p->thread_id), 1, 0);
    80001b9c:	1804a583          	lw	a1,384(s1)
    80001ba0:	00c5959b          	slliw	a1,a1,0xc
    80001ba4:	020007b7          	lui	a5,0x2000
    80001ba8:	4681                	li	a3,0
    80001baa:	4605                	li	a2,1
    80001bac:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001bae:	07b6                	slli	a5,a5,0xd
    80001bb0:	40b785b3          	sub	a1,a5,a1
    80001bb4:	fffff097          	auipc	ra,0xfffff
    80001bb8:	6b0080e7          	jalr	1712(ra) # 80001264 <uvmunmap>
  p->pagetable = 0;
    80001bbc:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001bc0:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001bc4:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001bc8:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001bcc:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001bd0:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001bd4:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bd8:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bdc:	0004ac23          	sw	zero,24(s1)
  p->thread_id = 0;
    80001be0:	1804a023          	sw	zero,384(s1)
}
    80001be4:	60e2                	ld	ra,24(sp)
    80001be6:	6442                	ld	s0,16(sp)
    80001be8:	64a2                	ld	s1,8(sp)
    80001bea:	6105                	addi	sp,sp,32
    80001bec:	8082                	ret
    proc_freepagetable(p->pagetable, p->sz);
    80001bee:	64ac                	ld	a1,72(s1)
    80001bf0:	00000097          	auipc	ra,0x0
    80001bf4:	f34080e7          	jalr	-204(ra) # 80001b24 <proc_freepagetable>
    80001bf8:	b7d1                	j	80001bbc <freeproc+0x46>

0000000080001bfa <allocproc>:
{
    80001bfa:	1101                	addi	sp,sp,-32
    80001bfc:	ec06                	sd	ra,24(sp)
    80001bfe:	e822                	sd	s0,16(sp)
    80001c00:	e426                	sd	s1,8(sp)
    80001c02:	e04a                	sd	s2,0(sp)
    80001c04:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c06:	0000f497          	auipc	s1,0xf
    80001c0a:	4a248493          	addi	s1,s1,1186 # 800110a8 <proc>
    80001c0e:	00015917          	auipc	s2,0x15
    80001c12:	69a90913          	addi	s2,s2,1690 # 800172a8 <tickslock>
    acquire(&p->lock);
    80001c16:	8526                	mv	a0,s1
    80001c18:	fffff097          	auipc	ra,0xfffff
    80001c1c:	fbe080e7          	jalr	-66(ra) # 80000bd6 <acquire>
    if(p->state == UNUSED) {
    80001c20:	4c9c                	lw	a5,24(s1)
    80001c22:	cf81                	beqz	a5,80001c3a <allocproc+0x40>
      release(&p->lock);
    80001c24:	8526                	mv	a0,s1
    80001c26:	fffff097          	auipc	ra,0xfffff
    80001c2a:	064080e7          	jalr	100(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c2e:	18848493          	addi	s1,s1,392
    80001c32:	ff2492e3          	bne	s1,s2,80001c16 <allocproc+0x1c>
  return 0;
    80001c36:	4481                	li	s1,0
    80001c38:	a8b5                	j	80001cb4 <allocproc+0xba>
  p->pid = allocpid();
    80001c3a:	00000097          	auipc	ra,0x0
    80001c3e:	e08080e7          	jalr	-504(ra) # 80001a42 <allocpid>
    80001c42:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c44:	4785                	li	a5,1
    80001c46:	cc9c                	sw	a5,24(s1)
  p->systemcalls=0;
    80001c48:	1604a423          	sw	zero,360(s1)
  p->systemcallstillnow=0;
    80001c4c:	1604a623          	sw	zero,364(s1)
  p->tickets = 10000;
    80001c50:	6709                	lui	a4,0x2
    80001c52:	71070713          	addi	a4,a4,1808 # 2710 <_entry-0x7fffd8f0>
    80001c56:	16e4a823          	sw	a4,368(s1)
  p->ticks = 0;
    80001c5a:	1604aa23          	sw	zero,372(s1)
  p->stride = (k_value/p->tickets);
    80001c5e:	00007797          	auipc	a5,0x7
    80001c62:	cda7a783          	lw	a5,-806(a5) # 80008938 <k_value>
    80001c66:	02e7c7bb          	divw	a5,a5,a4
    80001c6a:	16f4ac23          	sw	a5,376(s1)
  p->pass = p->stride;
    80001c6e:	16f4ae23          	sw	a5,380(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c72:	fffff097          	auipc	ra,0xfffff
    80001c76:	e74080e7          	jalr	-396(ra) # 80000ae6 <kalloc>
    80001c7a:	892a                	mv	s2,a0
    80001c7c:	eca8                	sd	a0,88(s1)
    80001c7e:	c131                	beqz	a0,80001cc2 <allocproc+0xc8>
  p->pagetable = proc_pagetable(p);
    80001c80:	8526                	mv	a0,s1
    80001c82:	00000097          	auipc	ra,0x0
    80001c86:	e06080e7          	jalr	-506(ra) # 80001a88 <proc_pagetable>
    80001c8a:	892a                	mv	s2,a0
    80001c8c:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c8e:	c531                	beqz	a0,80001cda <allocproc+0xe0>
  memset(&p->context, 0, sizeof(p->context));
    80001c90:	07000613          	li	a2,112
    80001c94:	4581                	li	a1,0
    80001c96:	06048513          	addi	a0,s1,96
    80001c9a:	fffff097          	auipc	ra,0xfffff
    80001c9e:	038080e7          	jalr	56(ra) # 80000cd2 <memset>
  p->context.ra = (uint64)forkret;
    80001ca2:	00000797          	auipc	a5,0x0
    80001ca6:	d5a78793          	addi	a5,a5,-678 # 800019fc <forkret>
    80001caa:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001cac:	60bc                	ld	a5,64(s1)
    80001cae:	6705                	lui	a4,0x1
    80001cb0:	97ba                	add	a5,a5,a4
    80001cb2:	f4bc                	sd	a5,104(s1)
}
    80001cb4:	8526                	mv	a0,s1
    80001cb6:	60e2                	ld	ra,24(sp)
    80001cb8:	6442                	ld	s0,16(sp)
    80001cba:	64a2                	ld	s1,8(sp)
    80001cbc:	6902                	ld	s2,0(sp)
    80001cbe:	6105                	addi	sp,sp,32
    80001cc0:	8082                	ret
    freeproc(p);
    80001cc2:	8526                	mv	a0,s1
    80001cc4:	00000097          	auipc	ra,0x0
    80001cc8:	eb2080e7          	jalr	-334(ra) # 80001b76 <freeproc>
    release(&p->lock);
    80001ccc:	8526                	mv	a0,s1
    80001cce:	fffff097          	auipc	ra,0xfffff
    80001cd2:	fbc080e7          	jalr	-68(ra) # 80000c8a <release>
    return 0;
    80001cd6:	84ca                	mv	s1,s2
    80001cd8:	bff1                	j	80001cb4 <allocproc+0xba>
    freeproc(p);
    80001cda:	8526                	mv	a0,s1
    80001cdc:	00000097          	auipc	ra,0x0
    80001ce0:	e9a080e7          	jalr	-358(ra) # 80001b76 <freeproc>
    release(&p->lock);
    80001ce4:	8526                	mv	a0,s1
    80001ce6:	fffff097          	auipc	ra,0xfffff
    80001cea:	fa4080e7          	jalr	-92(ra) # 80000c8a <release>
    return 0;
    80001cee:	84ca                	mv	s1,s2
    80001cf0:	b7d1                	j	80001cb4 <allocproc+0xba>

0000000080001cf2 <userinit>:
{
    80001cf2:	1101                	addi	sp,sp,-32
    80001cf4:	ec06                	sd	ra,24(sp)
    80001cf6:	e822                	sd	s0,16(sp)
    80001cf8:	e426                	sd	s1,8(sp)
    80001cfa:	1000                	addi	s0,sp,32
  p = allocproc();
    80001cfc:	00000097          	auipc	ra,0x0
    80001d00:	efe080e7          	jalr	-258(ra) # 80001bfa <allocproc>
    80001d04:	84aa                	mv	s1,a0
  initproc = p;
    80001d06:	00007797          	auipc	a5,0x7
    80001d0a:	cca7bd23          	sd	a0,-806(a5) # 800089e0 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001d0e:	03400613          	li	a2,52
    80001d12:	00007597          	auipc	a1,0x7
    80001d16:	c3e58593          	addi	a1,a1,-962 # 80008950 <initcode>
    80001d1a:	6928                	ld	a0,80(a0)
    80001d1c:	fffff097          	auipc	ra,0xfffff
    80001d20:	63a080e7          	jalr	1594(ra) # 80001356 <uvmfirst>
  p->sz = PGSIZE;
    80001d24:	6785                	lui	a5,0x1
    80001d26:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d28:	6cb8                	ld	a4,88(s1)
    80001d2a:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d2e:	6cb8                	ld	a4,88(s1)
    80001d30:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d32:	4641                	li	a2,16
    80001d34:	00006597          	auipc	a1,0x6
    80001d38:	4dc58593          	addi	a1,a1,1244 # 80008210 <digits+0x1d0>
    80001d3c:	15848513          	addi	a0,s1,344
    80001d40:	fffff097          	auipc	ra,0xfffff
    80001d44:	0dc080e7          	jalr	220(ra) # 80000e1c <safestrcpy>
  p->cwd = namei("/");
    80001d48:	00006517          	auipc	a0,0x6
    80001d4c:	4d850513          	addi	a0,a0,1240 # 80008220 <digits+0x1e0>
    80001d50:	00002097          	auipc	ra,0x2
    80001d54:	64a080e7          	jalr	1610(ra) # 8000439a <namei>
    80001d58:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d5c:	478d                	li	a5,3
    80001d5e:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d60:	8526                	mv	a0,s1
    80001d62:	fffff097          	auipc	ra,0xfffff
    80001d66:	f28080e7          	jalr	-216(ra) # 80000c8a <release>
}
    80001d6a:	60e2                	ld	ra,24(sp)
    80001d6c:	6442                	ld	s0,16(sp)
    80001d6e:	64a2                	ld	s1,8(sp)
    80001d70:	6105                	addi	sp,sp,32
    80001d72:	8082                	ret

0000000080001d74 <growproc>:
{
    80001d74:	1101                	addi	sp,sp,-32
    80001d76:	ec06                	sd	ra,24(sp)
    80001d78:	e822                	sd	s0,16(sp)
    80001d7a:	e426                	sd	s1,8(sp)
    80001d7c:	e04a                	sd	s2,0(sp)
    80001d7e:	1000                	addi	s0,sp,32
    80001d80:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d82:	00000097          	auipc	ra,0x0
    80001d86:	c42080e7          	jalr	-958(ra) # 800019c4 <myproc>
    80001d8a:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d8c:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001d8e:	01204c63          	bgtz	s2,80001da6 <growproc+0x32>
  } else if(n < 0){
    80001d92:	02094663          	bltz	s2,80001dbe <growproc+0x4a>
  p->sz = sz;
    80001d96:	e4ac                	sd	a1,72(s1)
  return 0;
    80001d98:	4501                	li	a0,0
}
    80001d9a:	60e2                	ld	ra,24(sp)
    80001d9c:	6442                	ld	s0,16(sp)
    80001d9e:	64a2                	ld	s1,8(sp)
    80001da0:	6902                	ld	s2,0(sp)
    80001da2:	6105                	addi	sp,sp,32
    80001da4:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001da6:	4691                	li	a3,4
    80001da8:	00b90633          	add	a2,s2,a1
    80001dac:	6928                	ld	a0,80(a0)
    80001dae:	fffff097          	auipc	ra,0xfffff
    80001db2:	662080e7          	jalr	1634(ra) # 80001410 <uvmalloc>
    80001db6:	85aa                	mv	a1,a0
    80001db8:	fd79                	bnez	a0,80001d96 <growproc+0x22>
      return -1;
    80001dba:	557d                	li	a0,-1
    80001dbc:	bff9                	j	80001d9a <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001dbe:	00b90633          	add	a2,s2,a1
    80001dc2:	6928                	ld	a0,80(a0)
    80001dc4:	fffff097          	auipc	ra,0xfffff
    80001dc8:	604080e7          	jalr	1540(ra) # 800013c8 <uvmdealloc>
    80001dcc:	85aa                	mv	a1,a0
    80001dce:	b7e1                	j	80001d96 <growproc+0x22>

0000000080001dd0 <fork>:
{
    80001dd0:	7139                	addi	sp,sp,-64
    80001dd2:	fc06                	sd	ra,56(sp)
    80001dd4:	f822                	sd	s0,48(sp)
    80001dd6:	f426                	sd	s1,40(sp)
    80001dd8:	f04a                	sd	s2,32(sp)
    80001dda:	ec4e                	sd	s3,24(sp)
    80001ddc:	e852                	sd	s4,16(sp)
    80001dde:	e456                	sd	s5,8(sp)
    80001de0:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001de2:	00000097          	auipc	ra,0x0
    80001de6:	be2080e7          	jalr	-1054(ra) # 800019c4 <myproc>
    80001dea:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001dec:	00000097          	auipc	ra,0x0
    80001df0:	e0e080e7          	jalr	-498(ra) # 80001bfa <allocproc>
    80001df4:	10050c63          	beqz	a0,80001f0c <fork+0x13c>
    80001df8:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001dfa:	048ab603          	ld	a2,72(s5)
    80001dfe:	692c                	ld	a1,80(a0)
    80001e00:	050ab503          	ld	a0,80(s5)
    80001e04:	fffff097          	auipc	ra,0xfffff
    80001e08:	764080e7          	jalr	1892(ra) # 80001568 <uvmcopy>
    80001e0c:	04054863          	bltz	a0,80001e5c <fork+0x8c>
  np->sz = p->sz;
    80001e10:	048ab783          	ld	a5,72(s5)
    80001e14:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001e18:	058ab683          	ld	a3,88(s5)
    80001e1c:	87b6                	mv	a5,a3
    80001e1e:	058a3703          	ld	a4,88(s4)
    80001e22:	12068693          	addi	a3,a3,288
    80001e26:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e2a:	6788                	ld	a0,8(a5)
    80001e2c:	6b8c                	ld	a1,16(a5)
    80001e2e:	6f90                	ld	a2,24(a5)
    80001e30:	01073023          	sd	a6,0(a4)
    80001e34:	e708                	sd	a0,8(a4)
    80001e36:	eb0c                	sd	a1,16(a4)
    80001e38:	ef10                	sd	a2,24(a4)
    80001e3a:	02078793          	addi	a5,a5,32
    80001e3e:	02070713          	addi	a4,a4,32
    80001e42:	fed792e3          	bne	a5,a3,80001e26 <fork+0x56>
  np->trapframe->a0 = 0;
    80001e46:	058a3783          	ld	a5,88(s4)
    80001e4a:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e4e:	0d0a8493          	addi	s1,s5,208
    80001e52:	0d0a0913          	addi	s2,s4,208
    80001e56:	150a8993          	addi	s3,s5,336
    80001e5a:	a00d                	j	80001e7c <fork+0xac>
    freeproc(np);
    80001e5c:	8552                	mv	a0,s4
    80001e5e:	00000097          	auipc	ra,0x0
    80001e62:	d18080e7          	jalr	-744(ra) # 80001b76 <freeproc>
    release(&np->lock);
    80001e66:	8552                	mv	a0,s4
    80001e68:	fffff097          	auipc	ra,0xfffff
    80001e6c:	e22080e7          	jalr	-478(ra) # 80000c8a <release>
    return -1;
    80001e70:	597d                	li	s2,-1
    80001e72:	a059                	j	80001ef8 <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    80001e74:	04a1                	addi	s1,s1,8
    80001e76:	0921                	addi	s2,s2,8
    80001e78:	01348b63          	beq	s1,s3,80001e8e <fork+0xbe>
    if(p->ofile[i])
    80001e7c:	6088                	ld	a0,0(s1)
    80001e7e:	d97d                	beqz	a0,80001e74 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e80:	00003097          	auipc	ra,0x3
    80001e84:	bb0080e7          	jalr	-1104(ra) # 80004a30 <filedup>
    80001e88:	00a93023          	sd	a0,0(s2)
    80001e8c:	b7e5                	j	80001e74 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e8e:	150ab503          	ld	a0,336(s5)
    80001e92:	00002097          	auipc	ra,0x2
    80001e96:	d1e080e7          	jalr	-738(ra) # 80003bb0 <idup>
    80001e9a:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e9e:	4641                	li	a2,16
    80001ea0:	158a8593          	addi	a1,s5,344
    80001ea4:	158a0513          	addi	a0,s4,344
    80001ea8:	fffff097          	auipc	ra,0xfffff
    80001eac:	f74080e7          	jalr	-140(ra) # 80000e1c <safestrcpy>
  pid = np->pid;
    80001eb0:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001eb4:	8552                	mv	a0,s4
    80001eb6:	fffff097          	auipc	ra,0xfffff
    80001eba:	dd4080e7          	jalr	-556(ra) # 80000c8a <release>
  acquire(&wait_lock);
    80001ebe:	0000f497          	auipc	s1,0xf
    80001ec2:	dba48493          	addi	s1,s1,-582 # 80010c78 <wait_lock>
    80001ec6:	8526                	mv	a0,s1
    80001ec8:	fffff097          	auipc	ra,0xfffff
    80001ecc:	d0e080e7          	jalr	-754(ra) # 80000bd6 <acquire>
  np->parent = p;
    80001ed0:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001ed4:	8526                	mv	a0,s1
    80001ed6:	fffff097          	auipc	ra,0xfffff
    80001eda:	db4080e7          	jalr	-588(ra) # 80000c8a <release>
  acquire(&np->lock);
    80001ede:	8552                	mv	a0,s4
    80001ee0:	fffff097          	auipc	ra,0xfffff
    80001ee4:	cf6080e7          	jalr	-778(ra) # 80000bd6 <acquire>
  np->state = RUNNABLE;
    80001ee8:	478d                	li	a5,3
    80001eea:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001eee:	8552                	mv	a0,s4
    80001ef0:	fffff097          	auipc	ra,0xfffff
    80001ef4:	d9a080e7          	jalr	-614(ra) # 80000c8a <release>
}
    80001ef8:	854a                	mv	a0,s2
    80001efa:	70e2                	ld	ra,56(sp)
    80001efc:	7442                	ld	s0,48(sp)
    80001efe:	74a2                	ld	s1,40(sp)
    80001f00:	7902                	ld	s2,32(sp)
    80001f02:	69e2                	ld	s3,24(sp)
    80001f04:	6a42                	ld	s4,16(sp)
    80001f06:	6aa2                	ld	s5,8(sp)
    80001f08:	6121                	addi	sp,sp,64
    80001f0a:	8082                	ret
    return -1;
    80001f0c:	597d                	li	s2,-1
    80001f0e:	b7ed                	j	80001ef8 <fork+0x128>

0000000080001f10 <rand>:
{
    80001f10:	1141                	addi	sp,sp,-16
    80001f12:	e422                	sd	s0,8(sp)
    80001f14:	0800                	addi	s0,sp,16
  bit = ((lfsr >> 0) ^ (lfsr >> 2) ^ (lfsr >> 3) ^ (lfsr >> 5)) & 1;
    80001f16:	00007697          	auipc	a3,0x7
    80001f1a:	a1e68693          	addi	a3,a3,-1506 # 80008934 <lfsr>
    80001f1e:	0006d783          	lhu	a5,0(a3)
    80001f22:	0027d71b          	srliw	a4,a5,0x2
    80001f26:	0037d61b          	srliw	a2,a5,0x3
    80001f2a:	8f31                	xor	a4,a4,a2
    80001f2c:	8f3d                	xor	a4,a4,a5
    80001f2e:	0057d61b          	srliw	a2,a5,0x5
    80001f32:	8f31                	xor	a4,a4,a2
    80001f34:	8b05                	andi	a4,a4,1
    80001f36:	00007617          	auipc	a2,0x7
    80001f3a:	aae61123          	sh	a4,-1374(a2) # 800089d8 <bit>
  lfsr = (lfsr >> 1) | (bit << 15);
    80001f3e:	0017d79b          	srliw	a5,a5,0x1
    80001f42:	00f7171b          	slliw	a4,a4,0xf
    80001f46:	8fd9                	or	a5,a5,a4
    80001f48:	17c2                	slli	a5,a5,0x30
    80001f4a:	93c1                	srli	a5,a5,0x30
    80001f4c:	00f69023          	sh	a5,0(a3)
  return lfsr % (upperBound+1);
    80001f50:	2505                	addiw	a0,a0,1
    80001f52:	02a7e53b          	remw	a0,a5,a0
}
    80001f56:	1542                	slli	a0,a0,0x30
    80001f58:	9141                	srli	a0,a0,0x30
    80001f5a:	6422                	ld	s0,8(sp)
    80001f5c:	0141                	addi	sp,sp,16
    80001f5e:	8082                	ret

0000000080001f60 <scheduler>:
{
    80001f60:	7139                	addi	sp,sp,-64
    80001f62:	fc06                	sd	ra,56(sp)
    80001f64:	f822                	sd	s0,48(sp)
    80001f66:	f426                	sd	s1,40(sp)
    80001f68:	f04a                	sd	s2,32(sp)
    80001f6a:	ec4e                	sd	s3,24(sp)
    80001f6c:	e852                	sd	s4,16(sp)
    80001f6e:	e456                	sd	s5,8(sp)
    80001f70:	e05a                	sd	s6,0(sp)
    80001f72:	0080                	addi	s0,sp,64
    80001f74:	8792                	mv	a5,tp
  int id = r_tp();
    80001f76:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f78:	00779a93          	slli	s5,a5,0x7
    80001f7c:	0000f717          	auipc	a4,0xf
    80001f80:	ce470713          	addi	a4,a4,-796 # 80010c60 <pid_lock>
    80001f84:	9756                	add	a4,a4,s5
    80001f86:	04073423          	sd	zero,72(a4)
        swtch(&c->context, &p->context);
    80001f8a:	0000f717          	auipc	a4,0xf
    80001f8e:	d2670713          	addi	a4,a4,-730 # 80010cb0 <cpus+0x8>
    80001f92:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001f94:	498d                	li	s3,3
        p->state = RUNNING;
    80001f96:	4b11                	li	s6,4
        c->proc = p;
    80001f98:	079e                	slli	a5,a5,0x7
    80001f9a:	0000fa17          	auipc	s4,0xf
    80001f9e:	cc6a0a13          	addi	s4,s4,-826 # 80010c60 <pid_lock>
    80001fa2:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fa4:	00015917          	auipc	s2,0x15
    80001fa8:	30490913          	addi	s2,s2,772 # 800172a8 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fac:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001fb0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fb4:	10079073          	csrw	sstatus,a5
    80001fb8:	0000f497          	auipc	s1,0xf
    80001fbc:	0f048493          	addi	s1,s1,240 # 800110a8 <proc>
    80001fc0:	a811                	j	80001fd4 <scheduler+0x74>
      release(&p->lock);
    80001fc2:	8526                	mv	a0,s1
    80001fc4:	fffff097          	auipc	ra,0xfffff
    80001fc8:	cc6080e7          	jalr	-826(ra) # 80000c8a <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fcc:	18848493          	addi	s1,s1,392
    80001fd0:	fd248ee3          	beq	s1,s2,80001fac <scheduler+0x4c>
      acquire(&p->lock);
    80001fd4:	8526                	mv	a0,s1
    80001fd6:	fffff097          	auipc	ra,0xfffff
    80001fda:	c00080e7          	jalr	-1024(ra) # 80000bd6 <acquire>
      if(p->state == RUNNABLE) {
    80001fde:	4c9c                	lw	a5,24(s1)
    80001fe0:	ff3791e3          	bne	a5,s3,80001fc2 <scheduler+0x62>
        p->state = RUNNING;
    80001fe4:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001fe8:	049a3423          	sd	s1,72(s4)
        p->ticks +=1;
    80001fec:	1744a783          	lw	a5,372(s1)
    80001ff0:	2785                	addiw	a5,a5,1
    80001ff2:	16f4aa23          	sw	a5,372(s1)
        swtch(&c->context, &p->context);
    80001ff6:	06048593          	addi	a1,s1,96
    80001ffa:	8556                	mv	a0,s5
    80001ffc:	00001097          	auipc	ra,0x1
    80002000:	a5e080e7          	jalr	-1442(ra) # 80002a5a <swtch>
        c->proc = 0;
    80002004:	040a3423          	sd	zero,72(s4)
    80002008:	bf6d                	j	80001fc2 <scheduler+0x62>

000000008000200a <sched>:
{
    8000200a:	7179                	addi	sp,sp,-48
    8000200c:	f406                	sd	ra,40(sp)
    8000200e:	f022                	sd	s0,32(sp)
    80002010:	ec26                	sd	s1,24(sp)
    80002012:	e84a                	sd	s2,16(sp)
    80002014:	e44e                	sd	s3,8(sp)
    80002016:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002018:	00000097          	auipc	ra,0x0
    8000201c:	9ac080e7          	jalr	-1620(ra) # 800019c4 <myproc>
    80002020:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002022:	fffff097          	auipc	ra,0xfffff
    80002026:	b3a080e7          	jalr	-1222(ra) # 80000b5c <holding>
    8000202a:	c93d                	beqz	a0,800020a0 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000202c:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000202e:	2781                	sext.w	a5,a5
    80002030:	079e                	slli	a5,a5,0x7
    80002032:	0000f717          	auipc	a4,0xf
    80002036:	c2e70713          	addi	a4,a4,-978 # 80010c60 <pid_lock>
    8000203a:	97ba                	add	a5,a5,a4
    8000203c:	0c07a703          	lw	a4,192(a5)
    80002040:	4785                	li	a5,1
    80002042:	06f71763          	bne	a4,a5,800020b0 <sched+0xa6>
  if(p->state == RUNNING)
    80002046:	4c98                	lw	a4,24(s1)
    80002048:	4791                	li	a5,4
    8000204a:	06f70b63          	beq	a4,a5,800020c0 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000204e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002052:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002054:	efb5                	bnez	a5,800020d0 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002056:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002058:	0000f917          	auipc	s2,0xf
    8000205c:	c0890913          	addi	s2,s2,-1016 # 80010c60 <pid_lock>
    80002060:	2781                	sext.w	a5,a5
    80002062:	079e                	slli	a5,a5,0x7
    80002064:	97ca                	add	a5,a5,s2
    80002066:	0c47a983          	lw	s3,196(a5)
    8000206a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000206c:	2781                	sext.w	a5,a5
    8000206e:	079e                	slli	a5,a5,0x7
    80002070:	0000f597          	auipc	a1,0xf
    80002074:	c4058593          	addi	a1,a1,-960 # 80010cb0 <cpus+0x8>
    80002078:	95be                	add	a1,a1,a5
    8000207a:	06048513          	addi	a0,s1,96
    8000207e:	00001097          	auipc	ra,0x1
    80002082:	9dc080e7          	jalr	-1572(ra) # 80002a5a <swtch>
    80002086:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002088:	2781                	sext.w	a5,a5
    8000208a:	079e                	slli	a5,a5,0x7
    8000208c:	993e                	add	s2,s2,a5
    8000208e:	0d392223          	sw	s3,196(s2)
}
    80002092:	70a2                	ld	ra,40(sp)
    80002094:	7402                	ld	s0,32(sp)
    80002096:	64e2                	ld	s1,24(sp)
    80002098:	6942                	ld	s2,16(sp)
    8000209a:	69a2                	ld	s3,8(sp)
    8000209c:	6145                	addi	sp,sp,48
    8000209e:	8082                	ret
    panic("sched p->lock");
    800020a0:	00006517          	auipc	a0,0x6
    800020a4:	18850513          	addi	a0,a0,392 # 80008228 <digits+0x1e8>
    800020a8:	ffffe097          	auipc	ra,0xffffe
    800020ac:	498080e7          	jalr	1176(ra) # 80000540 <panic>
    panic("sched locks");
    800020b0:	00006517          	auipc	a0,0x6
    800020b4:	18850513          	addi	a0,a0,392 # 80008238 <digits+0x1f8>
    800020b8:	ffffe097          	auipc	ra,0xffffe
    800020bc:	488080e7          	jalr	1160(ra) # 80000540 <panic>
    panic("sched running");
    800020c0:	00006517          	auipc	a0,0x6
    800020c4:	18850513          	addi	a0,a0,392 # 80008248 <digits+0x208>
    800020c8:	ffffe097          	auipc	ra,0xffffe
    800020cc:	478080e7          	jalr	1144(ra) # 80000540 <panic>
    panic("sched interruptible");
    800020d0:	00006517          	auipc	a0,0x6
    800020d4:	18850513          	addi	a0,a0,392 # 80008258 <digits+0x218>
    800020d8:	ffffe097          	auipc	ra,0xffffe
    800020dc:	468080e7          	jalr	1128(ra) # 80000540 <panic>

00000000800020e0 <yield>:
{
    800020e0:	1101                	addi	sp,sp,-32
    800020e2:	ec06                	sd	ra,24(sp)
    800020e4:	e822                	sd	s0,16(sp)
    800020e6:	e426                	sd	s1,8(sp)
    800020e8:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800020ea:	00000097          	auipc	ra,0x0
    800020ee:	8da080e7          	jalr	-1830(ra) # 800019c4 <myproc>
    800020f2:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020f4:	fffff097          	auipc	ra,0xfffff
    800020f8:	ae2080e7          	jalr	-1310(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    800020fc:	478d                	li	a5,3
    800020fe:	cc9c                	sw	a5,24(s1)
  sched();
    80002100:	00000097          	auipc	ra,0x0
    80002104:	f0a080e7          	jalr	-246(ra) # 8000200a <sched>
  release(&p->lock);
    80002108:	8526                	mv	a0,s1
    8000210a:	fffff097          	auipc	ra,0xfffff
    8000210e:	b80080e7          	jalr	-1152(ra) # 80000c8a <release>
}
    80002112:	60e2                	ld	ra,24(sp)
    80002114:	6442                	ld	s0,16(sp)
    80002116:	64a2                	ld	s1,8(sp)
    80002118:	6105                	addi	sp,sp,32
    8000211a:	8082                	ret

000000008000211c <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000211c:	7179                	addi	sp,sp,-48
    8000211e:	f406                	sd	ra,40(sp)
    80002120:	f022                	sd	s0,32(sp)
    80002122:	ec26                	sd	s1,24(sp)
    80002124:	e84a                	sd	s2,16(sp)
    80002126:	e44e                	sd	s3,8(sp)
    80002128:	1800                	addi	s0,sp,48
    8000212a:	89aa                	mv	s3,a0
    8000212c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000212e:	00000097          	auipc	ra,0x0
    80002132:	896080e7          	jalr	-1898(ra) # 800019c4 <myproc>
    80002136:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002138:	fffff097          	auipc	ra,0xfffff
    8000213c:	a9e080e7          	jalr	-1378(ra) # 80000bd6 <acquire>
  release(lk);
    80002140:	854a                	mv	a0,s2
    80002142:	fffff097          	auipc	ra,0xfffff
    80002146:	b48080e7          	jalr	-1208(ra) # 80000c8a <release>

  // Go to sleep.
  p->chan = chan;
    8000214a:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000214e:	4789                	li	a5,2
    80002150:	cc9c                	sw	a5,24(s1)

  sched();
    80002152:	00000097          	auipc	ra,0x0
    80002156:	eb8080e7          	jalr	-328(ra) # 8000200a <sched>

  // Tidy up.
  p->chan = 0;
    8000215a:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000215e:	8526                	mv	a0,s1
    80002160:	fffff097          	auipc	ra,0xfffff
    80002164:	b2a080e7          	jalr	-1238(ra) # 80000c8a <release>
  acquire(lk);
    80002168:	854a                	mv	a0,s2
    8000216a:	fffff097          	auipc	ra,0xfffff
    8000216e:	a6c080e7          	jalr	-1428(ra) # 80000bd6 <acquire>
}
    80002172:	70a2                	ld	ra,40(sp)
    80002174:	7402                	ld	s0,32(sp)
    80002176:	64e2                	ld	s1,24(sp)
    80002178:	6942                	ld	s2,16(sp)
    8000217a:	69a2                	ld	s3,8(sp)
    8000217c:	6145                	addi	sp,sp,48
    8000217e:	8082                	ret

0000000080002180 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002180:	7139                	addi	sp,sp,-64
    80002182:	fc06                	sd	ra,56(sp)
    80002184:	f822                	sd	s0,48(sp)
    80002186:	f426                	sd	s1,40(sp)
    80002188:	f04a                	sd	s2,32(sp)
    8000218a:	ec4e                	sd	s3,24(sp)
    8000218c:	e852                	sd	s4,16(sp)
    8000218e:	e456                	sd	s5,8(sp)
    80002190:	0080                	addi	s0,sp,64
    80002192:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002194:	0000f497          	auipc	s1,0xf
    80002198:	f1448493          	addi	s1,s1,-236 # 800110a8 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000219c:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000219e:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800021a0:	00015917          	auipc	s2,0x15
    800021a4:	10890913          	addi	s2,s2,264 # 800172a8 <tickslock>
    800021a8:	a811                	j	800021bc <wakeup+0x3c>
      }
      release(&p->lock);
    800021aa:	8526                	mv	a0,s1
    800021ac:	fffff097          	auipc	ra,0xfffff
    800021b0:	ade080e7          	jalr	-1314(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800021b4:	18848493          	addi	s1,s1,392
    800021b8:	03248663          	beq	s1,s2,800021e4 <wakeup+0x64>
    if(p != myproc()){
    800021bc:	00000097          	auipc	ra,0x0
    800021c0:	808080e7          	jalr	-2040(ra) # 800019c4 <myproc>
    800021c4:	fea488e3          	beq	s1,a0,800021b4 <wakeup+0x34>
      acquire(&p->lock);
    800021c8:	8526                	mv	a0,s1
    800021ca:	fffff097          	auipc	ra,0xfffff
    800021ce:	a0c080e7          	jalr	-1524(ra) # 80000bd6 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800021d2:	4c9c                	lw	a5,24(s1)
    800021d4:	fd379be3          	bne	a5,s3,800021aa <wakeup+0x2a>
    800021d8:	709c                	ld	a5,32(s1)
    800021da:	fd4798e3          	bne	a5,s4,800021aa <wakeup+0x2a>
        p->state = RUNNABLE;
    800021de:	0154ac23          	sw	s5,24(s1)
    800021e2:	b7e1                	j	800021aa <wakeup+0x2a>
    }
  }
}
    800021e4:	70e2                	ld	ra,56(sp)
    800021e6:	7442                	ld	s0,48(sp)
    800021e8:	74a2                	ld	s1,40(sp)
    800021ea:	7902                	ld	s2,32(sp)
    800021ec:	69e2                	ld	s3,24(sp)
    800021ee:	6a42                	ld	s4,16(sp)
    800021f0:	6aa2                	ld	s5,8(sp)
    800021f2:	6121                	addi	sp,sp,64
    800021f4:	8082                	ret

00000000800021f6 <reparent>:
{
    800021f6:	7179                	addi	sp,sp,-48
    800021f8:	f406                	sd	ra,40(sp)
    800021fa:	f022                	sd	s0,32(sp)
    800021fc:	ec26                	sd	s1,24(sp)
    800021fe:	e84a                	sd	s2,16(sp)
    80002200:	e44e                	sd	s3,8(sp)
    80002202:	e052                	sd	s4,0(sp)
    80002204:	1800                	addi	s0,sp,48
    80002206:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002208:	0000f497          	auipc	s1,0xf
    8000220c:	ea048493          	addi	s1,s1,-352 # 800110a8 <proc>
      pp->parent = initproc;
    80002210:	00006a17          	auipc	s4,0x6
    80002214:	7d0a0a13          	addi	s4,s4,2000 # 800089e0 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002218:	00015997          	auipc	s3,0x15
    8000221c:	09098993          	addi	s3,s3,144 # 800172a8 <tickslock>
    80002220:	a029                	j	8000222a <reparent+0x34>
    80002222:	18848493          	addi	s1,s1,392
    80002226:	01348d63          	beq	s1,s3,80002240 <reparent+0x4a>
    if(pp->parent == p){
    8000222a:	7c9c                	ld	a5,56(s1)
    8000222c:	ff279be3          	bne	a5,s2,80002222 <reparent+0x2c>
      pp->parent = initproc;
    80002230:	000a3503          	ld	a0,0(s4)
    80002234:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002236:	00000097          	auipc	ra,0x0
    8000223a:	f4a080e7          	jalr	-182(ra) # 80002180 <wakeup>
    8000223e:	b7d5                	j	80002222 <reparent+0x2c>
}
    80002240:	70a2                	ld	ra,40(sp)
    80002242:	7402                	ld	s0,32(sp)
    80002244:	64e2                	ld	s1,24(sp)
    80002246:	6942                	ld	s2,16(sp)
    80002248:	69a2                	ld	s3,8(sp)
    8000224a:	6a02                	ld	s4,0(sp)
    8000224c:	6145                	addi	sp,sp,48
    8000224e:	8082                	ret

0000000080002250 <exit>:
{
    80002250:	7179                	addi	sp,sp,-48
    80002252:	f406                	sd	ra,40(sp)
    80002254:	f022                	sd	s0,32(sp)
    80002256:	ec26                	sd	s1,24(sp)
    80002258:	e84a                	sd	s2,16(sp)
    8000225a:	e44e                	sd	s3,8(sp)
    8000225c:	e052                	sd	s4,0(sp)
    8000225e:	1800                	addi	s0,sp,48
    80002260:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002262:	fffff097          	auipc	ra,0xfffff
    80002266:	762080e7          	jalr	1890(ra) # 800019c4 <myproc>
    8000226a:	89aa                	mv	s3,a0
  if(p == initproc)
    8000226c:	00006797          	auipc	a5,0x6
    80002270:	7747b783          	ld	a5,1908(a5) # 800089e0 <initproc>
    80002274:	0d050493          	addi	s1,a0,208
    80002278:	15050913          	addi	s2,a0,336
    8000227c:	02a79363          	bne	a5,a0,800022a2 <exit+0x52>
    panic("init exiting");
    80002280:	00006517          	auipc	a0,0x6
    80002284:	ff050513          	addi	a0,a0,-16 # 80008270 <digits+0x230>
    80002288:	ffffe097          	auipc	ra,0xffffe
    8000228c:	2b8080e7          	jalr	696(ra) # 80000540 <panic>
      fileclose(f);
    80002290:	00002097          	auipc	ra,0x2
    80002294:	7f2080e7          	jalr	2034(ra) # 80004a82 <fileclose>
      p->ofile[fd] = 0;
    80002298:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000229c:	04a1                	addi	s1,s1,8
    8000229e:	01248563          	beq	s1,s2,800022a8 <exit+0x58>
    if(p->ofile[fd]){
    800022a2:	6088                	ld	a0,0(s1)
    800022a4:	f575                	bnez	a0,80002290 <exit+0x40>
    800022a6:	bfdd                	j	8000229c <exit+0x4c>
  begin_op();
    800022a8:	00002097          	auipc	ra,0x2
    800022ac:	312080e7          	jalr	786(ra) # 800045ba <begin_op>
  iput(p->cwd);
    800022b0:	1509b503          	ld	a0,336(s3)
    800022b4:	00002097          	auipc	ra,0x2
    800022b8:	af4080e7          	jalr	-1292(ra) # 80003da8 <iput>
  end_op();
    800022bc:	00002097          	auipc	ra,0x2
    800022c0:	37c080e7          	jalr	892(ra) # 80004638 <end_op>
  p->cwd = 0;
    800022c4:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800022c8:	0000f497          	auipc	s1,0xf
    800022cc:	9b048493          	addi	s1,s1,-1616 # 80010c78 <wait_lock>
    800022d0:	8526                	mv	a0,s1
    800022d2:	fffff097          	auipc	ra,0xfffff
    800022d6:	904080e7          	jalr	-1788(ra) # 80000bd6 <acquire>
  reparent(p);
    800022da:	854e                	mv	a0,s3
    800022dc:	00000097          	auipc	ra,0x0
    800022e0:	f1a080e7          	jalr	-230(ra) # 800021f6 <reparent>
  wakeup(p->parent);
    800022e4:	0389b503          	ld	a0,56(s3)
    800022e8:	00000097          	auipc	ra,0x0
    800022ec:	e98080e7          	jalr	-360(ra) # 80002180 <wakeup>
  acquire(&p->lock);
    800022f0:	854e                	mv	a0,s3
    800022f2:	fffff097          	auipc	ra,0xfffff
    800022f6:	8e4080e7          	jalr	-1820(ra) # 80000bd6 <acquire>
  p->xstate = status;
    800022fa:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800022fe:	4795                	li	a5,5
    80002300:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002304:	8526                	mv	a0,s1
    80002306:	fffff097          	auipc	ra,0xfffff
    8000230a:	984080e7          	jalr	-1660(ra) # 80000c8a <release>
  sched();
    8000230e:	00000097          	auipc	ra,0x0
    80002312:	cfc080e7          	jalr	-772(ra) # 8000200a <sched>
  panic("zombie exit");
    80002316:	00006517          	auipc	a0,0x6
    8000231a:	f6a50513          	addi	a0,a0,-150 # 80008280 <digits+0x240>
    8000231e:	ffffe097          	auipc	ra,0xffffe
    80002322:	222080e7          	jalr	546(ra) # 80000540 <panic>

0000000080002326 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002326:	7179                	addi	sp,sp,-48
    80002328:	f406                	sd	ra,40(sp)
    8000232a:	f022                	sd	s0,32(sp)
    8000232c:	ec26                	sd	s1,24(sp)
    8000232e:	e84a                	sd	s2,16(sp)
    80002330:	e44e                	sd	s3,8(sp)
    80002332:	1800                	addi	s0,sp,48
    80002334:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002336:	0000f497          	auipc	s1,0xf
    8000233a:	d7248493          	addi	s1,s1,-654 # 800110a8 <proc>
    8000233e:	00015997          	auipc	s3,0x15
    80002342:	f6a98993          	addi	s3,s3,-150 # 800172a8 <tickslock>
    acquire(&p->lock);
    80002346:	8526                	mv	a0,s1
    80002348:	fffff097          	auipc	ra,0xfffff
    8000234c:	88e080e7          	jalr	-1906(ra) # 80000bd6 <acquire>
    if(p->pid == pid){
    80002350:	589c                	lw	a5,48(s1)
    80002352:	01278d63          	beq	a5,s2,8000236c <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002356:	8526                	mv	a0,s1
    80002358:	fffff097          	auipc	ra,0xfffff
    8000235c:	932080e7          	jalr	-1742(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002360:	18848493          	addi	s1,s1,392
    80002364:	ff3491e3          	bne	s1,s3,80002346 <kill+0x20>
  }
  return -1;
    80002368:	557d                	li	a0,-1
    8000236a:	a829                	j	80002384 <kill+0x5e>
      p->killed = 1;
    8000236c:	4785                	li	a5,1
    8000236e:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002370:	4c98                	lw	a4,24(s1)
    80002372:	4789                	li	a5,2
    80002374:	00f70f63          	beq	a4,a5,80002392 <kill+0x6c>
      release(&p->lock);
    80002378:	8526                	mv	a0,s1
    8000237a:	fffff097          	auipc	ra,0xfffff
    8000237e:	910080e7          	jalr	-1776(ra) # 80000c8a <release>
      return 0;
    80002382:	4501                	li	a0,0
}
    80002384:	70a2                	ld	ra,40(sp)
    80002386:	7402                	ld	s0,32(sp)
    80002388:	64e2                	ld	s1,24(sp)
    8000238a:	6942                	ld	s2,16(sp)
    8000238c:	69a2                	ld	s3,8(sp)
    8000238e:	6145                	addi	sp,sp,48
    80002390:	8082                	ret
        p->state = RUNNABLE;
    80002392:	478d                	li	a5,3
    80002394:	cc9c                	sw	a5,24(s1)
    80002396:	b7cd                	j	80002378 <kill+0x52>

0000000080002398 <setkilled>:

void
setkilled(struct proc *p)
{
    80002398:	1101                	addi	sp,sp,-32
    8000239a:	ec06                	sd	ra,24(sp)
    8000239c:	e822                	sd	s0,16(sp)
    8000239e:	e426                	sd	s1,8(sp)
    800023a0:	1000                	addi	s0,sp,32
    800023a2:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800023a4:	fffff097          	auipc	ra,0xfffff
    800023a8:	832080e7          	jalr	-1998(ra) # 80000bd6 <acquire>
  p->killed = 1;
    800023ac:	4785                	li	a5,1
    800023ae:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800023b0:	8526                	mv	a0,s1
    800023b2:	fffff097          	auipc	ra,0xfffff
    800023b6:	8d8080e7          	jalr	-1832(ra) # 80000c8a <release>
}
    800023ba:	60e2                	ld	ra,24(sp)
    800023bc:	6442                	ld	s0,16(sp)
    800023be:	64a2                	ld	s1,8(sp)
    800023c0:	6105                	addi	sp,sp,32
    800023c2:	8082                	ret

00000000800023c4 <killed>:

int
killed(struct proc *p)
{
    800023c4:	1101                	addi	sp,sp,-32
    800023c6:	ec06                	sd	ra,24(sp)
    800023c8:	e822                	sd	s0,16(sp)
    800023ca:	e426                	sd	s1,8(sp)
    800023cc:	e04a                	sd	s2,0(sp)
    800023ce:	1000                	addi	s0,sp,32
    800023d0:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    800023d2:	fffff097          	auipc	ra,0xfffff
    800023d6:	804080e7          	jalr	-2044(ra) # 80000bd6 <acquire>
  k = p->killed;
    800023da:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800023de:	8526                	mv	a0,s1
    800023e0:	fffff097          	auipc	ra,0xfffff
    800023e4:	8aa080e7          	jalr	-1878(ra) # 80000c8a <release>
  return k;
}
    800023e8:	854a                	mv	a0,s2
    800023ea:	60e2                	ld	ra,24(sp)
    800023ec:	6442                	ld	s0,16(sp)
    800023ee:	64a2                	ld	s1,8(sp)
    800023f0:	6902                	ld	s2,0(sp)
    800023f2:	6105                	addi	sp,sp,32
    800023f4:	8082                	ret

00000000800023f6 <wait>:
{
    800023f6:	715d                	addi	sp,sp,-80
    800023f8:	e486                	sd	ra,72(sp)
    800023fa:	e0a2                	sd	s0,64(sp)
    800023fc:	fc26                	sd	s1,56(sp)
    800023fe:	f84a                	sd	s2,48(sp)
    80002400:	f44e                	sd	s3,40(sp)
    80002402:	f052                	sd	s4,32(sp)
    80002404:	ec56                	sd	s5,24(sp)
    80002406:	e85a                	sd	s6,16(sp)
    80002408:	e45e                	sd	s7,8(sp)
    8000240a:	e062                	sd	s8,0(sp)
    8000240c:	0880                	addi	s0,sp,80
    8000240e:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002410:	fffff097          	auipc	ra,0xfffff
    80002414:	5b4080e7          	jalr	1460(ra) # 800019c4 <myproc>
    80002418:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000241a:	0000f517          	auipc	a0,0xf
    8000241e:	85e50513          	addi	a0,a0,-1954 # 80010c78 <wait_lock>
    80002422:	ffffe097          	auipc	ra,0xffffe
    80002426:	7b4080e7          	jalr	1972(ra) # 80000bd6 <acquire>
    havekids = 0;
    8000242a:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    8000242c:	4a15                	li	s4,5
        havekids = 1;
    8000242e:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002430:	00015997          	auipc	s3,0x15
    80002434:	e7898993          	addi	s3,s3,-392 # 800172a8 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002438:	0000fc17          	auipc	s8,0xf
    8000243c:	840c0c13          	addi	s8,s8,-1984 # 80010c78 <wait_lock>
    havekids = 0;
    80002440:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002442:	0000f497          	auipc	s1,0xf
    80002446:	c6648493          	addi	s1,s1,-922 # 800110a8 <proc>
    8000244a:	a0bd                	j	800024b8 <wait+0xc2>
          pid = pp->pid;
    8000244c:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002450:	000b0e63          	beqz	s6,8000246c <wait+0x76>
    80002454:	4691                	li	a3,4
    80002456:	02c48613          	addi	a2,s1,44
    8000245a:	85da                	mv	a1,s6
    8000245c:	05093503          	ld	a0,80(s2)
    80002460:	fffff097          	auipc	ra,0xfffff
    80002464:	20c080e7          	jalr	524(ra) # 8000166c <copyout>
    80002468:	02054563          	bltz	a0,80002492 <wait+0x9c>
          freeproc(pp);
    8000246c:	8526                	mv	a0,s1
    8000246e:	fffff097          	auipc	ra,0xfffff
    80002472:	708080e7          	jalr	1800(ra) # 80001b76 <freeproc>
          release(&pp->lock);
    80002476:	8526                	mv	a0,s1
    80002478:	fffff097          	auipc	ra,0xfffff
    8000247c:	812080e7          	jalr	-2030(ra) # 80000c8a <release>
          release(&wait_lock);
    80002480:	0000e517          	auipc	a0,0xe
    80002484:	7f850513          	addi	a0,a0,2040 # 80010c78 <wait_lock>
    80002488:	fffff097          	auipc	ra,0xfffff
    8000248c:	802080e7          	jalr	-2046(ra) # 80000c8a <release>
          return pid;
    80002490:	a0b5                	j	800024fc <wait+0x106>
            release(&pp->lock);
    80002492:	8526                	mv	a0,s1
    80002494:	ffffe097          	auipc	ra,0xffffe
    80002498:	7f6080e7          	jalr	2038(ra) # 80000c8a <release>
            release(&wait_lock);
    8000249c:	0000e517          	auipc	a0,0xe
    800024a0:	7dc50513          	addi	a0,a0,2012 # 80010c78 <wait_lock>
    800024a4:	ffffe097          	auipc	ra,0xffffe
    800024a8:	7e6080e7          	jalr	2022(ra) # 80000c8a <release>
            return -1;
    800024ac:	59fd                	li	s3,-1
    800024ae:	a0b9                	j	800024fc <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800024b0:	18848493          	addi	s1,s1,392
    800024b4:	03348463          	beq	s1,s3,800024dc <wait+0xe6>
      if(pp->parent == p){
    800024b8:	7c9c                	ld	a5,56(s1)
    800024ba:	ff279be3          	bne	a5,s2,800024b0 <wait+0xba>
        acquire(&pp->lock);
    800024be:	8526                	mv	a0,s1
    800024c0:	ffffe097          	auipc	ra,0xffffe
    800024c4:	716080e7          	jalr	1814(ra) # 80000bd6 <acquire>
        if(pp->state == ZOMBIE){
    800024c8:	4c9c                	lw	a5,24(s1)
    800024ca:	f94781e3          	beq	a5,s4,8000244c <wait+0x56>
        release(&pp->lock);
    800024ce:	8526                	mv	a0,s1
    800024d0:	ffffe097          	auipc	ra,0xffffe
    800024d4:	7ba080e7          	jalr	1978(ra) # 80000c8a <release>
        havekids = 1;
    800024d8:	8756                	mv	a4,s5
    800024da:	bfd9                	j	800024b0 <wait+0xba>
    if(!havekids || killed(p)){
    800024dc:	c719                	beqz	a4,800024ea <wait+0xf4>
    800024de:	854a                	mv	a0,s2
    800024e0:	00000097          	auipc	ra,0x0
    800024e4:	ee4080e7          	jalr	-284(ra) # 800023c4 <killed>
    800024e8:	c51d                	beqz	a0,80002516 <wait+0x120>
      release(&wait_lock);
    800024ea:	0000e517          	auipc	a0,0xe
    800024ee:	78e50513          	addi	a0,a0,1934 # 80010c78 <wait_lock>
    800024f2:	ffffe097          	auipc	ra,0xffffe
    800024f6:	798080e7          	jalr	1944(ra) # 80000c8a <release>
      return -1;
    800024fa:	59fd                	li	s3,-1
}
    800024fc:	854e                	mv	a0,s3
    800024fe:	60a6                	ld	ra,72(sp)
    80002500:	6406                	ld	s0,64(sp)
    80002502:	74e2                	ld	s1,56(sp)
    80002504:	7942                	ld	s2,48(sp)
    80002506:	79a2                	ld	s3,40(sp)
    80002508:	7a02                	ld	s4,32(sp)
    8000250a:	6ae2                	ld	s5,24(sp)
    8000250c:	6b42                	ld	s6,16(sp)
    8000250e:	6ba2                	ld	s7,8(sp)
    80002510:	6c02                	ld	s8,0(sp)
    80002512:	6161                	addi	sp,sp,80
    80002514:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002516:	85e2                	mv	a1,s8
    80002518:	854a                	mv	a0,s2
    8000251a:	00000097          	auipc	ra,0x0
    8000251e:	c02080e7          	jalr	-1022(ra) # 8000211c <sleep>
    havekids = 0;
    80002522:	bf39                	j	80002440 <wait+0x4a>

0000000080002524 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002524:	7179                	addi	sp,sp,-48
    80002526:	f406                	sd	ra,40(sp)
    80002528:	f022                	sd	s0,32(sp)
    8000252a:	ec26                	sd	s1,24(sp)
    8000252c:	e84a                	sd	s2,16(sp)
    8000252e:	e44e                	sd	s3,8(sp)
    80002530:	e052                	sd	s4,0(sp)
    80002532:	1800                	addi	s0,sp,48
    80002534:	84aa                	mv	s1,a0
    80002536:	892e                	mv	s2,a1
    80002538:	89b2                	mv	s3,a2
    8000253a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000253c:	fffff097          	auipc	ra,0xfffff
    80002540:	488080e7          	jalr	1160(ra) # 800019c4 <myproc>
  if(user_dst){
    80002544:	c08d                	beqz	s1,80002566 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002546:	86d2                	mv	a3,s4
    80002548:	864e                	mv	a2,s3
    8000254a:	85ca                	mv	a1,s2
    8000254c:	6928                	ld	a0,80(a0)
    8000254e:	fffff097          	auipc	ra,0xfffff
    80002552:	11e080e7          	jalr	286(ra) # 8000166c <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002556:	70a2                	ld	ra,40(sp)
    80002558:	7402                	ld	s0,32(sp)
    8000255a:	64e2                	ld	s1,24(sp)
    8000255c:	6942                	ld	s2,16(sp)
    8000255e:	69a2                	ld	s3,8(sp)
    80002560:	6a02                	ld	s4,0(sp)
    80002562:	6145                	addi	sp,sp,48
    80002564:	8082                	ret
    memmove((char *)dst, src, len);
    80002566:	000a061b          	sext.w	a2,s4
    8000256a:	85ce                	mv	a1,s3
    8000256c:	854a                	mv	a0,s2
    8000256e:	ffffe097          	auipc	ra,0xffffe
    80002572:	7c0080e7          	jalr	1984(ra) # 80000d2e <memmove>
    return 0;
    80002576:	8526                	mv	a0,s1
    80002578:	bff9                	j	80002556 <either_copyout+0x32>

000000008000257a <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000257a:	7179                	addi	sp,sp,-48
    8000257c:	f406                	sd	ra,40(sp)
    8000257e:	f022                	sd	s0,32(sp)
    80002580:	ec26                	sd	s1,24(sp)
    80002582:	e84a                	sd	s2,16(sp)
    80002584:	e44e                	sd	s3,8(sp)
    80002586:	e052                	sd	s4,0(sp)
    80002588:	1800                	addi	s0,sp,48
    8000258a:	892a                	mv	s2,a0
    8000258c:	84ae                	mv	s1,a1
    8000258e:	89b2                	mv	s3,a2
    80002590:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002592:	fffff097          	auipc	ra,0xfffff
    80002596:	432080e7          	jalr	1074(ra) # 800019c4 <myproc>
  if(user_src){
    8000259a:	c08d                	beqz	s1,800025bc <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    8000259c:	86d2                	mv	a3,s4
    8000259e:	864e                	mv	a2,s3
    800025a0:	85ca                	mv	a1,s2
    800025a2:	6928                	ld	a0,80(a0)
    800025a4:	fffff097          	auipc	ra,0xfffff
    800025a8:	154080e7          	jalr	340(ra) # 800016f8 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800025ac:	70a2                	ld	ra,40(sp)
    800025ae:	7402                	ld	s0,32(sp)
    800025b0:	64e2                	ld	s1,24(sp)
    800025b2:	6942                	ld	s2,16(sp)
    800025b4:	69a2                	ld	s3,8(sp)
    800025b6:	6a02                	ld	s4,0(sp)
    800025b8:	6145                	addi	sp,sp,48
    800025ba:	8082                	ret
    memmove(dst, (char*)src, len);
    800025bc:	000a061b          	sext.w	a2,s4
    800025c0:	85ce                	mv	a1,s3
    800025c2:	854a                	mv	a0,s2
    800025c4:	ffffe097          	auipc	ra,0xffffe
    800025c8:	76a080e7          	jalr	1898(ra) # 80000d2e <memmove>
    return 0;
    800025cc:	8526                	mv	a0,s1
    800025ce:	bff9                	j	800025ac <either_copyin+0x32>

00000000800025d0 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800025d0:	715d                	addi	sp,sp,-80
    800025d2:	e486                	sd	ra,72(sp)
    800025d4:	e0a2                	sd	s0,64(sp)
    800025d6:	fc26                	sd	s1,56(sp)
    800025d8:	f84a                	sd	s2,48(sp)
    800025da:	f44e                	sd	s3,40(sp)
    800025dc:	f052                	sd	s4,32(sp)
    800025de:	ec56                	sd	s5,24(sp)
    800025e0:	e85a                	sd	s6,16(sp)
    800025e2:	e45e                	sd	s7,8(sp)
    800025e4:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800025e6:	00006517          	auipc	a0,0x6
    800025ea:	ae250513          	addi	a0,a0,-1310 # 800080c8 <digits+0x88>
    800025ee:	ffffe097          	auipc	ra,0xffffe
    800025f2:	f9c080e7          	jalr	-100(ra) # 8000058a <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025f6:	0000f497          	auipc	s1,0xf
    800025fa:	c0a48493          	addi	s1,s1,-1014 # 80011200 <proc+0x158>
    800025fe:	00015917          	auipc	s2,0x15
    80002602:	e0290913          	addi	s2,s2,-510 # 80017400 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002606:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002608:	00006997          	auipc	s3,0x6
    8000260c:	c8898993          	addi	s3,s3,-888 # 80008290 <digits+0x250>
    printf("%d %s %s", p->pid, state, p->name);
    80002610:	00006a97          	auipc	s5,0x6
    80002614:	c88a8a93          	addi	s5,s5,-888 # 80008298 <digits+0x258>
    printf("\n");
    80002618:	00006a17          	auipc	s4,0x6
    8000261c:	ab0a0a13          	addi	s4,s4,-1360 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002620:	00006b97          	auipc	s7,0x6
    80002624:	d30b8b93          	addi	s7,s7,-720 # 80008350 <states.1>
    80002628:	a00d                	j	8000264a <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    8000262a:	ed86a583          	lw	a1,-296(a3)
    8000262e:	8556                	mv	a0,s5
    80002630:	ffffe097          	auipc	ra,0xffffe
    80002634:	f5a080e7          	jalr	-166(ra) # 8000058a <printf>
    printf("\n");
    80002638:	8552                	mv	a0,s4
    8000263a:	ffffe097          	auipc	ra,0xffffe
    8000263e:	f50080e7          	jalr	-176(ra) # 8000058a <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002642:	18848493          	addi	s1,s1,392
    80002646:	03248263          	beq	s1,s2,8000266a <procdump+0x9a>
    if(p->state == UNUSED)
    8000264a:	86a6                	mv	a3,s1
    8000264c:	ec04a783          	lw	a5,-320(s1)
    80002650:	dbed                	beqz	a5,80002642 <procdump+0x72>
      state = "???";
    80002652:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002654:	fcfb6be3          	bltu	s6,a5,8000262a <procdump+0x5a>
    80002658:	02079713          	slli	a4,a5,0x20
    8000265c:	01d75793          	srli	a5,a4,0x1d
    80002660:	97de                	add	a5,a5,s7
    80002662:	6390                	ld	a2,0(a5)
    80002664:	f279                	bnez	a2,8000262a <procdump+0x5a>
      state = "???";
    80002666:	864e                	mv	a2,s3
    80002668:	b7c9                	j	8000262a <procdump+0x5a>
  }
}
    8000266a:	60a6                	ld	ra,72(sp)
    8000266c:	6406                	ld	s0,64(sp)
    8000266e:	74e2                	ld	s1,56(sp)
    80002670:	7942                	ld	s2,48(sp)
    80002672:	79a2                	ld	s3,40(sp)
    80002674:	7a02                	ld	s4,32(sp)
    80002676:	6ae2                	ld	s5,24(sp)
    80002678:	6b42                	ld	s6,16(sp)
    8000267a:	6ba2                	ld	s7,8(sp)
    8000267c:	6161                	addi	sp,sp,80
    8000267e:	8082                	ret

0000000080002680 <print_hello>:
// hello: printing hello message
void  print_hello(int n)
{
    80002680:	1141                	addi	sp,sp,-16
    80002682:	e406                	sd	ra,8(sp)
    80002684:	e022                	sd	s0,0(sp)
    80002686:	0800                	addi	s0,sp,16
    80002688:	85aa                	mv	a1,a0
  printf("Hello from the kernal space %d\n",n);
    8000268a:	00006517          	auipc	a0,0x6
    8000268e:	c1e50513          	addi	a0,a0,-994 # 800082a8 <digits+0x268>
    80002692:	ffffe097          	auipc	ra,0xffffe
    80002696:	ef8080e7          	jalr	-264(ra) # 8000058a <printf>
}
    8000269a:	60a2                	ld	ra,8(sp)
    8000269c:	6402                	ld	s0,0(sp)
    8000269e:	0141                	addi	sp,sp,16
    800026a0:	8082                	ret

00000000800026a2 <print_info>:


extern int sys_calls_since_boot;   //  syscalls made since boot up

uint64 print_info(int n)
{
    800026a2:	1141                	addi	sp,sp,-16
    800026a4:	e422                	sd	s0,8(sp)
    800026a6:	0800                	addi	s0,sp,16
    800026a8:	85aa                	mv	a1,a0
 if(n==0)
    800026aa:	c919                	beqz	a0,800026c0 <print_info+0x1e>
            activeProcessCounter++;
          }
        return activeProcessCounter;
  }

else if (n==1)
    800026ac:	4785                	li	a5,1
    800026ae:	04f50963          	beq	a0,a5,80002700 <print_info+0x5e>
  {
      return sys_calls_since_boot;              // return system calls till now excluding current one
  }

 else if(n==2)
    800026b2:	4789                	li	a5,2
   count++;
   r = r->next;
     }
   return count;
 }
 return -1;                               //  error
    800026b4:	557d                	li	a0,-1
 else if(n==2)
    800026b6:	04f58a63          	beq	a1,a5,8000270a <print_info+0x68>
}
    800026ba:	6422                	ld	s0,8(sp)
    800026bc:	0141                	addi	sp,sp,16
    800026be:	8082                	ret
        for(p = proc; p < &proc[NPROC]; p++){                                     // counting processes that are NOT UNUSED
    800026c0:	0000f717          	auipc	a4,0xf
    800026c4:	9e870713          	addi	a4,a4,-1560 # 800110a8 <proc>
          if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026c8:	4615                	li	a2,5
    800026ca:	00006517          	auipc	a0,0x6
    800026ce:	c8650513          	addi	a0,a0,-890 # 80008350 <states.1>
        for(p = proc; p < &proc[NPROC]; p++){                                     // counting processes that are NOT UNUSED
    800026d2:	00015697          	auipc	a3,0x15
    800026d6:	bd668693          	addi	a3,a3,-1066 # 800172a8 <tickslock>
    800026da:	a029                	j	800026e4 <print_info+0x42>
    800026dc:	18870713          	addi	a4,a4,392
    800026e0:	00d70e63          	beq	a4,a3,800026fc <print_info+0x5a>
          if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026e4:	4f1c                	lw	a5,24(a4)
    800026e6:	fef66be3          	bltu	a2,a5,800026dc <print_info+0x3a>
    800026ea:	02079813          	slli	a6,a5,0x20
    800026ee:	01d85793          	srli	a5,a6,0x1d
    800026f2:	97aa                	add	a5,a5,a0
    800026f4:	7b9c                	ld	a5,48(a5)
    800026f6:	d3fd                	beqz	a5,800026dc <print_info+0x3a>
            activeProcessCounter++;
    800026f8:	2585                	addiw	a1,a1,1
    800026fa:	b7cd                	j	800026dc <print_info+0x3a>
        return activeProcessCounter;
    800026fc:	852e                	mv	a0,a1
    800026fe:	bf75                	j	800026ba <print_info+0x18>
      return sys_calls_since_boot;              // return system calls till now excluding current one
    80002700:	00006517          	auipc	a0,0x6
    80002704:	2f052503          	lw	a0,752(a0) # 800089f0 <sys_calls_since_boot>
    80002708:	bf4d                	j	800026ba <print_info+0x18>
  struct run *r = kmem.freelist;
    8000270a:	0000e797          	auipc	a5,0xe
    8000270e:	54e7b783          	ld	a5,1358(a5) # 80010c58 <kmem+0x18>
   while (r) {                           // loop through linked list until its empty
    80002712:	c791                	beqz	a5,8000271e <print_info+0x7c>
   int count = 0;
    80002714:	4501                	li	a0,0
   count++;
    80002716:	2505                	addiw	a0,a0,1
   r = r->next;
    80002718:	639c                	ld	a5,0(a5)
   while (r) {                           // loop through linked list until its empty
    8000271a:	fff5                	bnez	a5,80002716 <print_info+0x74>
    8000271c:	bf79                	j	800026ba <print_info+0x18>
   int count = 0;
    8000271e:	4501                	li	a0,0
   return count;
    80002720:	bf69                	j	800026ba <print_info+0x18>

0000000080002722 <procinfo>:


uint64 procinfo(struct pinfo *param)
{
    80002722:	7179                	addi	sp,sp,-48
    80002724:	f406                	sd	ra,40(sp)
    80002726:	f022                	sd	s0,32(sp)
    80002728:	ec26                	sd	s1,24(sp)
    8000272a:	1800                	addi	s0,sp,48
    8000272c:	84aa                	mv	s1,a0
  uint64 n;
  argaddr(0,&n);
    8000272e:	fd840593          	addi	a1,s0,-40
    80002732:	4501                	li	a0,0
    80002734:	00001097          	auipc	ra,0x1
    80002738:	872080e7          	jalr	-1934(ra) # 80002fa6 <argaddr>
  struct proc *p = myproc();
    8000273c:	fffff097          	auipc	ra,0xfffff
    80002740:	288080e7          	jalr	648(ra) # 800019c4 <myproc>

  //Set data from PCB to struct param

  param->syscall_count=p->systemcallstillnow;   //System calls till now excluding the current system call
    80002744:	16c52783          	lw	a5,364(a0)
    80002748:	c0dc                	sw	a5,4(s1)
  param->ppid=p->parent->pid;
    8000274a:	7d1c                	ld	a5,56(a0)
    8000274c:	5b9c                	lw	a5,48(a5)
    8000274e:	c4dc                	sw	a5,12(s1)
  param->page_usage=(p->sz +4095)/ 4096;        // dividing with size of one page and using a ceiling function
    80002750:	653c                	ld	a5,72(a0)
    80002752:	6705                	lui	a4,0x1
    80002754:	177d                	addi	a4,a4,-1 # fff <_entry-0x7ffff001>
    80002756:	97ba                	add	a5,a5,a4
    80002758:	83b1                	srli	a5,a5,0xc
    8000275a:	c49c                	sw	a5,8(s1)


  //Copy data from kernal space to user space since The kernel cannot directly write data to the userspace memory

  if(copyout(p->pagetable,n,(char *)param, sizeof(*param))==0)
    8000275c:	46c1                	li	a3,16
    8000275e:	8626                	mv	a2,s1
    80002760:	fd843583          	ld	a1,-40(s0)
    80002764:	6928                	ld	a0,80(a0)
    80002766:	fffff097          	auipc	ra,0xfffff
    8000276a:	f06080e7          	jalr	-250(ra) # 8000166c <copyout>
    8000276e:	00a03533          	snez	a0,a0
  return 0;
  else return -1;

}
    80002772:	40a00533          	neg	a0,a0
    80002776:	70a2                	ld	ra,40(sp)
    80002778:	7402                	ld	s0,32(sp)
    8000277a:	64e2                	ld	s1,24(sp)
    8000277c:	6145                	addi	sp,sp,48
    8000277e:	8082                	ret

0000000080002780 <sched_statistics>:

uint64 sched_statistics(void)
{
    80002780:	7179                	addi	sp,sp,-48
    80002782:	f406                	sd	ra,40(sp)
    80002784:	f022                	sd	s0,32(sp)
    80002786:	ec26                	sd	s1,24(sp)
    80002788:	e84a                	sd	s2,16(sp)
    8000278a:	e44e                	sd	s3,8(sp)
    8000278c:	1800                	addi	s0,sp,48
struct proc *p;
 for(p = proc; p < &proc[NPROC]; p++){
    8000278e:	0000f497          	auipc	s1,0xf
    80002792:	a7248493          	addi	s1,s1,-1422 # 80011200 <proc+0x158>
    80002796:	00015917          	auipc	s2,0x15
    8000279a:	c6a90913          	addi	s2,s2,-918 # 80017400 <bcache+0x140>
 if(p->pid>0)
 {
  printf("%d (%s) : tickets: %d, ticks: %d \n",p->pid,p->name,p->tickets,p->ticks);    //For all processes print pid, name , tickets and its executedtime
    8000279e:	00006997          	auipc	s3,0x6
    800027a2:	b2a98993          	addi	s3,s3,-1238 # 800082c8 <digits+0x288>
    800027a6:	a029                	j	800027b0 <sched_statistics+0x30>
 for(p = proc; p < &proc[NPROC]; p++){
    800027a8:	18848493          	addi	s1,s1,392
    800027ac:	01248f63          	beq	s1,s2,800027ca <sched_statistics+0x4a>
 if(p->pid>0)
    800027b0:	ed84a583          	lw	a1,-296(s1)
    800027b4:	feb05ae3          	blez	a1,800027a8 <sched_statistics+0x28>
  printf("%d (%s) : tickets: %d, ticks: %d \n",p->pid,p->name,p->tickets,p->ticks);    //For all processes print pid, name , tickets and its executedtime
    800027b8:	4cd8                	lw	a4,28(s1)
    800027ba:	4c94                	lw	a3,24(s1)
    800027bc:	8626                	mv	a2,s1
    800027be:	854e                	mv	a0,s3
    800027c0:	ffffe097          	auipc	ra,0xffffe
    800027c4:	dca080e7          	jalr	-566(ra) # 8000058a <printf>
    800027c8:	b7c5                	j	800027a8 <sched_statistics+0x28>
 }  
 }
  return 0;
}
    800027ca:	4501                	li	a0,0
    800027cc:	70a2                	ld	ra,40(sp)
    800027ce:	7402                	ld	s0,32(sp)
    800027d0:	64e2                	ld	s1,24(sp)
    800027d2:	6942                	ld	s2,16(sp)
    800027d4:	69a2                	ld	s3,8(sp)
    800027d6:	6145                	addi	sp,sp,48
    800027d8:	8082                	ret

00000000800027da <sched_tickets>:

uint64 sched_tickets(int n){
    800027da:	1101                	addi	sp,sp,-32
    800027dc:	ec06                	sd	ra,24(sp)
    800027de:	e822                	sd	s0,16(sp)
    800027e0:	e426                	sd	s1,8(sp)
    800027e2:	e04a                	sd	s2,0(sp)
    800027e4:	1000                	addi	s0,sp,32
    800027e6:	892a                	mv	s2,a0
  struct proc *p = myproc();
    800027e8:	fffff097          	auipc	ra,0xfffff
    800027ec:	1dc080e7          	jalr	476(ra) # 800019c4 <myproc>
    800027f0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800027f2:	ffffe097          	auipc	ra,0xffffe
    800027f6:	3e4080e7          	jalr	996(ra) # 80000bd6 <acquire>
  p->tickets = n;
    800027fa:	1724a823          	sw	s2,368(s1)
  p->stride = (k_value/n);
    800027fe:	00006797          	auipc	a5,0x6
    80002802:	13a7a783          	lw	a5,314(a5) # 80008938 <k_value>
    80002806:	0327c53b          	divw	a0,a5,s2
    8000280a:	16a4ac23          	sw	a0,376(s1)
  p->pass = p->stride;
    8000280e:	16a4ae23          	sw	a0,380(s1)
  // printf("");
  release(&p->lock);
    80002812:	8526                	mv	a0,s1
    80002814:	ffffe097          	auipc	ra,0xffffe
    80002818:	476080e7          	jalr	1142(ra) # 80000c8a <release>
  printf("\npid: %d tickets: %d", p->pid, p->tickets);
    8000281c:	1704a603          	lw	a2,368(s1)
    80002820:	588c                	lw	a1,48(s1)
    80002822:	00006517          	auipc	a0,0x6
    80002826:	ace50513          	addi	a0,a0,-1330 # 800082f0 <digits+0x2b0>
    8000282a:	ffffe097          	auipc	ra,0xffffe
    8000282e:	d60080e7          	jalr	-672(ra) # 8000058a <printf>
  return 0;
}
    80002832:	4501                	li	a0,0
    80002834:	60e2                	ld	ra,24(sp)
    80002836:	6442                	ld	s0,16(sp)
    80002838:	64a2                	ld	s1,8(sp)
    8000283a:	6902                	ld	s2,0(sp)
    8000283c:	6105                	addi	sp,sp,32
    8000283e:	8082                	ret

0000000080002840 <clone>:

uint64 clone(void *stack) {
    80002840:	7139                	addi	sp,sp,-64
    80002842:	fc06                	sd	ra,56(sp)
    80002844:	f822                	sd	s0,48(sp)
    80002846:	f426                	sd	s1,40(sp)
    80002848:	f04a                	sd	s2,32(sp)
    8000284a:	ec4e                	sd	s3,24(sp)
    8000284c:	e852                	sd	s4,16(sp)
    8000284e:	e456                	sd	s5,8(sp)
    80002850:	0080                	addi	s0,sp,64
    80002852:	89aa                	mv	s3,a0
  struct proc *p = myproc();
    80002854:	fffff097          	auipc	ra,0xfffff
    80002858:	170080e7          	jalr	368(ra) # 800019c4 <myproc>
  struct proc *np;
  int thread_id;
  if(stack == NULL) {
    8000285c:	1e098d63          	beqz	s3,80002a56 <clone+0x216>
    80002860:	8aaa                	mv	s5,a0
  for(p = proc; p<&proc[NPROC]; p++)  {
    80002862:	0000f497          	auipc	s1,0xf
    80002866:	84648493          	addi	s1,s1,-1978 # 800110a8 <proc>
    8000286a:	00015917          	auipc	s2,0x15
    8000286e:	a3e90913          	addi	s2,s2,-1474 # 800172a8 <tickslock>
    acquire(&p->lock);
    80002872:	8526                	mv	a0,s1
    80002874:	ffffe097          	auipc	ra,0xffffe
    80002878:	362080e7          	jalr	866(ra) # 80000bd6 <acquire>
    if(p->state == UNUSED)  {
    8000287c:	4c9c                	lw	a5,24(s1)
    8000287e:	cf81                	beqz	a5,80002896 <clone+0x56>
      release(&p->lock);
    80002880:	8526                	mv	a0,s1
    80002882:	ffffe097          	auipc	ra,0xffffe
    80002886:	408080e7          	jalr	1032(ra) # 80000c8a <release>
  for(p = proc; p<&proc[NPROC]; p++)  {
    8000288a:	18848493          	addi	s1,s1,392
    8000288e:	ff2492e3          	bne	s1,s2,80002872 <clone+0x32>
    return -1;
  }
  if((np=allocproc_thread()) == 0)  {
    return -1;
    80002892:	557d                	li	a0,-1
    80002894:	aa45                	j	80002a44 <clone+0x204>
  p->pid = allocpid();
    80002896:	fffff097          	auipc	ra,0xfffff
    8000289a:	1ac080e7          	jalr	428(ra) # 80001a42 <allocpid>
    8000289e:	d888                	sw	a0,48(s1)
  p->state = USED;
    800028a0:	4785                	li	a5,1
    800028a2:	cc9c                	sw	a5,24(s1)
  acquire(&thread_lock);
    800028a4:	0000ea17          	auipc	s4,0xe
    800028a8:	3eca0a13          	addi	s4,s4,1004 # 80010c90 <thread_lock>
    800028ac:	8552                	mv	a0,s4
    800028ae:	ffffe097          	auipc	ra,0xffffe
    800028b2:	328080e7          	jalr	808(ra) # 80000bd6 <acquire>
  thread_id = next_thread_id;
    800028b6:	00006797          	auipc	a5,0x6
    800028ba:	08678793          	addi	a5,a5,134 # 8000893c <next_thread_id>
    800028be:	0007a903          	lw	s2,0(a5)
  next_thread_id += 1;
    800028c2:	0019071b          	addiw	a4,s2,1
    800028c6:	c398                	sw	a4,0(a5)
  release(&thread_lock);
    800028c8:	8552                	mv	a0,s4
    800028ca:	ffffe097          	auipc	ra,0xffffe
    800028ce:	3c0080e7          	jalr	960(ra) # 80000c8a <release>
  p->thread_id = thread_id;
    800028d2:	1924a023          	sw	s2,384(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0)
    800028d6:	ffffe097          	auipc	ra,0xffffe
    800028da:	210080e7          	jalr	528(ra) # 80000ae6 <kalloc>
    800028de:	eca8                	sd	a0,88(s1)
    800028e0:	c14d                	beqz	a0,80002982 <clone+0x142>
  memset(&p->context, 0, sizeof(p->context));
    800028e2:	07000613          	li	a2,112
    800028e6:	4581                	li	a1,0
    800028e8:	06048513          	addi	a0,s1,96
    800028ec:	ffffe097          	auipc	ra,0xffffe
    800028f0:	3e6080e7          	jalr	998(ra) # 80000cd2 <memset>
  p->context.ra = (uint64)forkret;
    800028f4:	fffff797          	auipc	a5,0xfffff
    800028f8:	10878793          	addi	a5,a5,264 # 800019fc <forkret>
    800028fc:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    800028fe:	60bc                	ld	a5,64(s1)
    80002900:	6705                	lui	a4,0x1
    80002902:	97ba                	add	a5,a5,a4
    80002904:	f4bc                	sd	a5,104(s1)
  }
  np->pagetable = p->pagetable;
    80002906:	050ab503          	ld	a0,80(s5)
    8000290a:	e8a8                	sd	a0,80(s1)
  if(mappages(np->pagetable, TRAPFRAME - (PGSIZE*np->thread_id), PGSIZE, (uint64)(np->trapframe), PTE_R | PTE_W) < 0) {
    8000290c:	1804a583          	lw	a1,384(s1)
    80002910:	00c5959b          	slliw	a1,a1,0xc
    80002914:	020007b7          	lui	a5,0x2000
    80002918:	4719                	li	a4,6
    8000291a:	6cb4                	ld	a3,88(s1)
    8000291c:	6605                	lui	a2,0x1
    8000291e:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80002920:	07b6                	slli	a5,a5,0xd
    80002922:	40b785b3          	sub	a1,a5,a1
    80002926:	ffffe097          	auipc	ra,0xffffe
    8000292a:	778080e7          	jalr	1912(ra) # 8000109e <mappages>
    8000292e:	06054563          	bltz	a0,80002998 <clone+0x158>
    uvmunmap(np->pagetable, TRAMPOLINE,1,0);
    uvmfree(np->pagetable,0);
    return 0;
  }
  np->sz = p->sz;
    80002932:	048ab783          	ld	a5,72(s5)
    80002936:	e4bc                	sd	a5,72(s1)
  *(np->trapframe) = *(p->trapframe);
    80002938:	058ab683          	ld	a3,88(s5)
    8000293c:	87b6                	mv	a5,a3
    8000293e:	6cb8                	ld	a4,88(s1)
    80002940:	12068693          	addi	a3,a3,288
    80002944:	0007b803          	ld	a6,0(a5)
    80002948:	6788                	ld	a0,8(a5)
    8000294a:	6b8c                	ld	a1,16(a5)
    8000294c:	6f90                	ld	a2,24(a5)
    8000294e:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80002952:	e708                	sd	a0,8(a4)
    80002954:	eb0c                	sd	a1,16(a4)
    80002956:	ef10                	sd	a2,24(a4)
    80002958:	02078793          	addi	a5,a5,32
    8000295c:	02070713          	addi	a4,a4,32
    80002960:	fed792e3          	bne	a5,a3,80002944 <clone+0x104>
  np->trapframe->a0 = 0;
    80002964:	6cbc                	ld	a5,88(s1)
    80002966:	0607b823          	sd	zero,112(a5)
  np->trapframe->sp = (uint64)stack + PGSIZE;
    8000296a:	6cbc                	ld	a5,88(s1)
    8000296c:	6705                	lui	a4,0x1
    8000296e:	99ba                	add	s3,s3,a4
    80002970:	0337b823          	sd	s3,48(a5)
  for(int i = 0; i < NOFILE; i++) {
    80002974:	0d0a8913          	addi	s2,s5,208
    80002978:	0d048993          	addi	s3,s1,208
    8000297c:	150a8a13          	addi	s4,s5,336
    80002980:	a099                	j	800029c6 <clone+0x186>
    freeproc(p);
    80002982:	8526                	mv	a0,s1
    80002984:	fffff097          	auipc	ra,0xfffff
    80002988:	1f2080e7          	jalr	498(ra) # 80001b76 <freeproc>
    release(&p->lock);
    8000298c:	8526                	mv	a0,s1
    8000298e:	ffffe097          	auipc	ra,0xffffe
    80002992:	2fc080e7          	jalr	764(ra) # 80000c8a <release>
    return 0;
    80002996:	bdf5                	j	80002892 <clone+0x52>
    uvmunmap(np->pagetable, TRAMPOLINE,1,0);
    80002998:	4681                	li	a3,0
    8000299a:	4605                	li	a2,1
    8000299c:	040005b7          	lui	a1,0x4000
    800029a0:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800029a2:	05b2                	slli	a1,a1,0xc
    800029a4:	68a8                	ld	a0,80(s1)
    800029a6:	fffff097          	auipc	ra,0xfffff
    800029aa:	8be080e7          	jalr	-1858(ra) # 80001264 <uvmunmap>
    uvmfree(np->pagetable,0);
    800029ae:	4581                	li	a1,0
    800029b0:	68a8                	ld	a0,80(s1)
    800029b2:	fffff097          	auipc	ra,0xfffff
    800029b6:	b7c080e7          	jalr	-1156(ra) # 8000152e <uvmfree>
    return 0;
    800029ba:	4501                	li	a0,0
    800029bc:	a061                	j	80002a44 <clone+0x204>
  for(int i = 0; i < NOFILE; i++) {
    800029be:	0921                	addi	s2,s2,8
    800029c0:	09a1                	addi	s3,s3,8
    800029c2:	01490c63          	beq	s2,s4,800029da <clone+0x19a>
    if(p->ofile[i]){
    800029c6:	00093503          	ld	a0,0(s2)
    800029ca:	d975                	beqz	a0,800029be <clone+0x17e>
      np->ofile[i] = filedup(p->ofile[i]);
    800029cc:	00002097          	auipc	ra,0x2
    800029d0:	064080e7          	jalr	100(ra) # 80004a30 <filedup>
    800029d4:	00a9b023          	sd	a0,0(s3)
    800029d8:	b7dd                	j	800029be <clone+0x17e>
    }
  }
  np->cwd = idup(p->cwd);
    800029da:	150ab503          	ld	a0,336(s5)
    800029de:	00001097          	auipc	ra,0x1
    800029e2:	1d2080e7          	jalr	466(ra) # 80003bb0 <idup>
    800029e6:	14a4b823          	sd	a0,336(s1)
  safestrcpy(np->name, p->name, sizeof(np->name));
    800029ea:	4641                	li	a2,16
    800029ec:	158a8593          	addi	a1,s5,344
    800029f0:	15848513          	addi	a0,s1,344
    800029f4:	ffffe097          	auipc	ra,0xffffe
    800029f8:	428080e7          	jalr	1064(ra) # 80000e1c <safestrcpy>
  thread_id = np->thread_id;
    800029fc:	1804a903          	lw	s2,384(s1)
  release(&np->lock);
    80002a00:	8526                	mv	a0,s1
    80002a02:	ffffe097          	auipc	ra,0xffffe
    80002a06:	288080e7          	jalr	648(ra) # 80000c8a <release>
  acquire(&wait_lock);
    80002a0a:	0000e997          	auipc	s3,0xe
    80002a0e:	26e98993          	addi	s3,s3,622 # 80010c78 <wait_lock>
    80002a12:	854e                	mv	a0,s3
    80002a14:	ffffe097          	auipc	ra,0xffffe
    80002a18:	1c2080e7          	jalr	450(ra) # 80000bd6 <acquire>
  np->parent = p;
    80002a1c:	0354bc23          	sd	s5,56(s1)
  release(&wait_lock);
    80002a20:	854e                	mv	a0,s3
    80002a22:	ffffe097          	auipc	ra,0xffffe
    80002a26:	268080e7          	jalr	616(ra) # 80000c8a <release>
  acquire(&np->lock);
    80002a2a:	8526                	mv	a0,s1
    80002a2c:	ffffe097          	auipc	ra,0xffffe
    80002a30:	1aa080e7          	jalr	426(ra) # 80000bd6 <acquire>
  np->state = RUNNABLE;
    80002a34:	478d                	li	a5,3
    80002a36:	cc9c                	sw	a5,24(s1)
  release(&np->lock);
    80002a38:	8526                	mv	a0,s1
    80002a3a:	ffffe097          	auipc	ra,0xffffe
    80002a3e:	250080e7          	jalr	592(ra) # 80000c8a <release>
  return thread_id;
    80002a42:	854a                	mv	a0,s2
    80002a44:	70e2                	ld	ra,56(sp)
    80002a46:	7442                	ld	s0,48(sp)
    80002a48:	74a2                	ld	s1,40(sp)
    80002a4a:	7902                	ld	s2,32(sp)
    80002a4c:	69e2                	ld	s3,24(sp)
    80002a4e:	6a42                	ld	s4,16(sp)
    80002a50:	6aa2                	ld	s5,8(sp)
    80002a52:	6121                	addi	sp,sp,64
    80002a54:	8082                	ret
    return -1;
    80002a56:	557d                	li	a0,-1
    80002a58:	b7f5                	j	80002a44 <clone+0x204>

0000000080002a5a <swtch>:
    80002a5a:	00153023          	sd	ra,0(a0)
    80002a5e:	00253423          	sd	sp,8(a0)
    80002a62:	e900                	sd	s0,16(a0)
    80002a64:	ed04                	sd	s1,24(a0)
    80002a66:	03253023          	sd	s2,32(a0)
    80002a6a:	03353423          	sd	s3,40(a0)
    80002a6e:	03453823          	sd	s4,48(a0)
    80002a72:	03553c23          	sd	s5,56(a0)
    80002a76:	05653023          	sd	s6,64(a0)
    80002a7a:	05753423          	sd	s7,72(a0)
    80002a7e:	05853823          	sd	s8,80(a0)
    80002a82:	05953c23          	sd	s9,88(a0)
    80002a86:	07a53023          	sd	s10,96(a0)
    80002a8a:	07b53423          	sd	s11,104(a0)
    80002a8e:	0005b083          	ld	ra,0(a1)
    80002a92:	0085b103          	ld	sp,8(a1)
    80002a96:	6980                	ld	s0,16(a1)
    80002a98:	6d84                	ld	s1,24(a1)
    80002a9a:	0205b903          	ld	s2,32(a1)
    80002a9e:	0285b983          	ld	s3,40(a1)
    80002aa2:	0305ba03          	ld	s4,48(a1)
    80002aa6:	0385ba83          	ld	s5,56(a1)
    80002aaa:	0405bb03          	ld	s6,64(a1)
    80002aae:	0485bb83          	ld	s7,72(a1)
    80002ab2:	0505bc03          	ld	s8,80(a1)
    80002ab6:	0585bc83          	ld	s9,88(a1)
    80002aba:	0605bd03          	ld	s10,96(a1)
    80002abe:	0685bd83          	ld	s11,104(a1)
    80002ac2:	8082                	ret

0000000080002ac4 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002ac4:	1141                	addi	sp,sp,-16
    80002ac6:	e406                	sd	ra,8(sp)
    80002ac8:	e022                	sd	s0,0(sp)
    80002aca:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002acc:	00006597          	auipc	a1,0x6
    80002ad0:	8e458593          	addi	a1,a1,-1820 # 800083b0 <states.0+0x30>
    80002ad4:	00014517          	auipc	a0,0x14
    80002ad8:	7d450513          	addi	a0,a0,2004 # 800172a8 <tickslock>
    80002adc:	ffffe097          	auipc	ra,0xffffe
    80002ae0:	06a080e7          	jalr	106(ra) # 80000b46 <initlock>
}
    80002ae4:	60a2                	ld	ra,8(sp)
    80002ae6:	6402                	ld	s0,0(sp)
    80002ae8:	0141                	addi	sp,sp,16
    80002aea:	8082                	ret

0000000080002aec <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002aec:	1141                	addi	sp,sp,-16
    80002aee:	e422                	sd	s0,8(sp)
    80002af0:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002af2:	00003797          	auipc	a5,0x3
    80002af6:	5de78793          	addi	a5,a5,1502 # 800060d0 <kernelvec>
    80002afa:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002afe:	6422                	ld	s0,8(sp)
    80002b00:	0141                	addi	sp,sp,16
    80002b02:	8082                	ret

0000000080002b04 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002b04:	1141                	addi	sp,sp,-16
    80002b06:	e406                	sd	ra,8(sp)
    80002b08:	e022                	sd	s0,0(sp)
    80002b0a:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002b0c:	fffff097          	auipc	ra,0xfffff
    80002b10:	eb8080e7          	jalr	-328(ra) # 800019c4 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b14:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002b18:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b1a:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002b1e:	00004697          	auipc	a3,0x4
    80002b22:	4e268693          	addi	a3,a3,1250 # 80007000 <_trampoline>
    80002b26:	00004717          	auipc	a4,0x4
    80002b2a:	4da70713          	addi	a4,a4,1242 # 80007000 <_trampoline>
    80002b2e:	8f15                	sub	a4,a4,a3
    80002b30:	040007b7          	lui	a5,0x4000
    80002b34:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002b36:	07b2                	slli	a5,a5,0xc
    80002b38:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b3a:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002b3e:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002b40:	18002673          	csrr	a2,satp
    80002b44:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002b46:	6d30                	ld	a2,88(a0)
    80002b48:	6138                	ld	a4,64(a0)
    80002b4a:	6585                	lui	a1,0x1
    80002b4c:	972e                	add	a4,a4,a1
    80002b4e:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002b50:	6d38                	ld	a4,88(a0)
    80002b52:	00000617          	auipc	a2,0x0
    80002b56:	15260613          	addi	a2,a2,338 # 80002ca4 <usertrap>
    80002b5a:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002b5c:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002b5e:	8612                	mv	a2,tp
    80002b60:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b62:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002b66:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002b6a:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b6e:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002b72:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002b74:	6f18                	ld	a4,24(a4)
    80002b76:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002b7a:	692c                	ld	a1,80(a0)
    80002b7c:	81b1                	srli	a1,a1,0xc
    80002b7e:	577d                	li	a4,-1
    80002b80:	177e                	slli	a4,a4,0x3f
    80002b82:	8dd9                	or	a1,a1,a4

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002b84:	00004717          	auipc	a4,0x4
    80002b88:	50c70713          	addi	a4,a4,1292 # 80007090 <userret>
    80002b8c:	8f15                	sub	a4,a4,a3
    80002b8e:	97ba                	add	a5,a5,a4
  if(p->thread_id == 0){
    80002b90:	18052503          	lw	a0,384(a0)
    80002b94:	e911                	bnez	a0,80002ba8 <usertrapret+0xa4>
    ((void (*)(uint64, uint64))trampoline_userret)(TRAPFRAME, satp);
    80002b96:	02000537          	lui	a0,0x2000
    80002b9a:	157d                	addi	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    80002b9c:	0536                	slli	a0,a0,0xd
    80002b9e:	9782                	jalr	a5
  } else {
    ((void (*)(uint64, uint64))trampoline_userret)(TRAPFRAME - PGSIZE*p->thread_id, satp);
  }
}
    80002ba0:	60a2                	ld	ra,8(sp)
    80002ba2:	6402                	ld	s0,0(sp)
    80002ba4:	0141                	addi	sp,sp,16
    80002ba6:	8082                	ret
    ((void (*)(uint64, uint64))trampoline_userret)(TRAPFRAME - PGSIZE*p->thread_id, satp);
    80002ba8:	00c5151b          	slliw	a0,a0,0xc
    80002bac:	02000737          	lui	a4,0x2000
    80002bb0:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002bb2:	0736                	slli	a4,a4,0xd
    80002bb4:	40a70533          	sub	a0,a4,a0
    80002bb8:	9782                	jalr	a5
}
    80002bba:	b7dd                	j	80002ba0 <usertrapret+0x9c>

0000000080002bbc <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002bbc:	1101                	addi	sp,sp,-32
    80002bbe:	ec06                	sd	ra,24(sp)
    80002bc0:	e822                	sd	s0,16(sp)
    80002bc2:	e426                	sd	s1,8(sp)
    80002bc4:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002bc6:	00014497          	auipc	s1,0x14
    80002bca:	6e248493          	addi	s1,s1,1762 # 800172a8 <tickslock>
    80002bce:	8526                	mv	a0,s1
    80002bd0:	ffffe097          	auipc	ra,0xffffe
    80002bd4:	006080e7          	jalr	6(ra) # 80000bd6 <acquire>
  ticks++;
    80002bd8:	00006517          	auipc	a0,0x6
    80002bdc:	e1050513          	addi	a0,a0,-496 # 800089e8 <ticks>
    80002be0:	411c                	lw	a5,0(a0)
    80002be2:	2785                	addiw	a5,a5,1
    80002be4:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002be6:	fffff097          	auipc	ra,0xfffff
    80002bea:	59a080e7          	jalr	1434(ra) # 80002180 <wakeup>
  release(&tickslock);
    80002bee:	8526                	mv	a0,s1
    80002bf0:	ffffe097          	auipc	ra,0xffffe
    80002bf4:	09a080e7          	jalr	154(ra) # 80000c8a <release>
}
    80002bf8:	60e2                	ld	ra,24(sp)
    80002bfa:	6442                	ld	s0,16(sp)
    80002bfc:	64a2                	ld	s1,8(sp)
    80002bfe:	6105                	addi	sp,sp,32
    80002c00:	8082                	ret

0000000080002c02 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002c02:	1101                	addi	sp,sp,-32
    80002c04:	ec06                	sd	ra,24(sp)
    80002c06:	e822                	sd	s0,16(sp)
    80002c08:	e426                	sd	s1,8(sp)
    80002c0a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c0c:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002c10:	00074d63          	bltz	a4,80002c2a <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002c14:	57fd                	li	a5,-1
    80002c16:	17fe                	slli	a5,a5,0x3f
    80002c18:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002c1a:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002c1c:	06f70363          	beq	a4,a5,80002c82 <devintr+0x80>
  }
}
    80002c20:	60e2                	ld	ra,24(sp)
    80002c22:	6442                	ld	s0,16(sp)
    80002c24:	64a2                	ld	s1,8(sp)
    80002c26:	6105                	addi	sp,sp,32
    80002c28:	8082                	ret
     (scause & 0xff) == 9){
    80002c2a:	0ff77793          	zext.b	a5,a4
  if((scause & 0x8000000000000000L) &&
    80002c2e:	46a5                	li	a3,9
    80002c30:	fed792e3          	bne	a5,a3,80002c14 <devintr+0x12>
    int irq = plic_claim();
    80002c34:	00003097          	auipc	ra,0x3
    80002c38:	5a4080e7          	jalr	1444(ra) # 800061d8 <plic_claim>
    80002c3c:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002c3e:	47a9                	li	a5,10
    80002c40:	02f50763          	beq	a0,a5,80002c6e <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002c44:	4785                	li	a5,1
    80002c46:	02f50963          	beq	a0,a5,80002c78 <devintr+0x76>
    return 1;
    80002c4a:	4505                	li	a0,1
    } else if(irq){
    80002c4c:	d8f1                	beqz	s1,80002c20 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002c4e:	85a6                	mv	a1,s1
    80002c50:	00005517          	auipc	a0,0x5
    80002c54:	76850513          	addi	a0,a0,1896 # 800083b8 <states.0+0x38>
    80002c58:	ffffe097          	auipc	ra,0xffffe
    80002c5c:	932080e7          	jalr	-1742(ra) # 8000058a <printf>
      plic_complete(irq);
    80002c60:	8526                	mv	a0,s1
    80002c62:	00003097          	auipc	ra,0x3
    80002c66:	59a080e7          	jalr	1434(ra) # 800061fc <plic_complete>
    return 1;
    80002c6a:	4505                	li	a0,1
    80002c6c:	bf55                	j	80002c20 <devintr+0x1e>
      uartintr();
    80002c6e:	ffffe097          	auipc	ra,0xffffe
    80002c72:	d2a080e7          	jalr	-726(ra) # 80000998 <uartintr>
    80002c76:	b7ed                	j	80002c60 <devintr+0x5e>
      virtio_disk_intr();
    80002c78:	00004097          	auipc	ra,0x4
    80002c7c:	a4c080e7          	jalr	-1460(ra) # 800066c4 <virtio_disk_intr>
    80002c80:	b7c5                	j	80002c60 <devintr+0x5e>
    if(cpuid() == 0){
    80002c82:	fffff097          	auipc	ra,0xfffff
    80002c86:	d16080e7          	jalr	-746(ra) # 80001998 <cpuid>
    80002c8a:	c901                	beqz	a0,80002c9a <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002c8c:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002c90:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002c92:	14479073          	csrw	sip,a5
    return 2;
    80002c96:	4509                	li	a0,2
    80002c98:	b761                	j	80002c20 <devintr+0x1e>
      clockintr();
    80002c9a:	00000097          	auipc	ra,0x0
    80002c9e:	f22080e7          	jalr	-222(ra) # 80002bbc <clockintr>
    80002ca2:	b7ed                	j	80002c8c <devintr+0x8a>

0000000080002ca4 <usertrap>:
{
    80002ca4:	1101                	addi	sp,sp,-32
    80002ca6:	ec06                	sd	ra,24(sp)
    80002ca8:	e822                	sd	s0,16(sp)
    80002caa:	e426                	sd	s1,8(sp)
    80002cac:	e04a                	sd	s2,0(sp)
    80002cae:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cb0:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002cb4:	1007f793          	andi	a5,a5,256
    80002cb8:	e3b1                	bnez	a5,80002cfc <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002cba:	00003797          	auipc	a5,0x3
    80002cbe:	41678793          	addi	a5,a5,1046 # 800060d0 <kernelvec>
    80002cc2:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002cc6:	fffff097          	auipc	ra,0xfffff
    80002cca:	cfe080e7          	jalr	-770(ra) # 800019c4 <myproc>
    80002cce:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002cd0:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cd2:	14102773          	csrr	a4,sepc
    80002cd6:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002cd8:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002cdc:	47a1                	li	a5,8
    80002cde:	02f70763          	beq	a4,a5,80002d0c <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002ce2:	00000097          	auipc	ra,0x0
    80002ce6:	f20080e7          	jalr	-224(ra) # 80002c02 <devintr>
    80002cea:	892a                	mv	s2,a0
    80002cec:	c151                	beqz	a0,80002d70 <usertrap+0xcc>
  if(killed(p))
    80002cee:	8526                	mv	a0,s1
    80002cf0:	fffff097          	auipc	ra,0xfffff
    80002cf4:	6d4080e7          	jalr	1748(ra) # 800023c4 <killed>
    80002cf8:	c929                	beqz	a0,80002d4a <usertrap+0xa6>
    80002cfa:	a099                	j	80002d40 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002cfc:	00005517          	auipc	a0,0x5
    80002d00:	6dc50513          	addi	a0,a0,1756 # 800083d8 <states.0+0x58>
    80002d04:	ffffe097          	auipc	ra,0xffffe
    80002d08:	83c080e7          	jalr	-1988(ra) # 80000540 <panic>
    if(killed(p))
    80002d0c:	fffff097          	auipc	ra,0xfffff
    80002d10:	6b8080e7          	jalr	1720(ra) # 800023c4 <killed>
    80002d14:	e921                	bnez	a0,80002d64 <usertrap+0xc0>
    p->trapframe->epc += 4;
    80002d16:	6cb8                	ld	a4,88(s1)
    80002d18:	6f1c                	ld	a5,24(a4)
    80002d1a:	0791                	addi	a5,a5,4
    80002d1c:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d1e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002d22:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d26:	10079073          	csrw	sstatus,a5
    syscall();
    80002d2a:	00000097          	auipc	ra,0x0
    80002d2e:	2d4080e7          	jalr	724(ra) # 80002ffe <syscall>
  if(killed(p))
    80002d32:	8526                	mv	a0,s1
    80002d34:	fffff097          	auipc	ra,0xfffff
    80002d38:	690080e7          	jalr	1680(ra) # 800023c4 <killed>
    80002d3c:	c911                	beqz	a0,80002d50 <usertrap+0xac>
    80002d3e:	4901                	li	s2,0
    exit(-1);
    80002d40:	557d                	li	a0,-1
    80002d42:	fffff097          	auipc	ra,0xfffff
    80002d46:	50e080e7          	jalr	1294(ra) # 80002250 <exit>
  if(which_dev == 2)
    80002d4a:	4789                	li	a5,2
    80002d4c:	04f90f63          	beq	s2,a5,80002daa <usertrap+0x106>
  usertrapret();
    80002d50:	00000097          	auipc	ra,0x0
    80002d54:	db4080e7          	jalr	-588(ra) # 80002b04 <usertrapret>
}
    80002d58:	60e2                	ld	ra,24(sp)
    80002d5a:	6442                	ld	s0,16(sp)
    80002d5c:	64a2                	ld	s1,8(sp)
    80002d5e:	6902                	ld	s2,0(sp)
    80002d60:	6105                	addi	sp,sp,32
    80002d62:	8082                	ret
      exit(-1);
    80002d64:	557d                	li	a0,-1
    80002d66:	fffff097          	auipc	ra,0xfffff
    80002d6a:	4ea080e7          	jalr	1258(ra) # 80002250 <exit>
    80002d6e:	b765                	j	80002d16 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d70:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002d74:	5890                	lw	a2,48(s1)
    80002d76:	00005517          	auipc	a0,0x5
    80002d7a:	68250513          	addi	a0,a0,1666 # 800083f8 <states.0+0x78>
    80002d7e:	ffffe097          	auipc	ra,0xffffe
    80002d82:	80c080e7          	jalr	-2036(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d86:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d8a:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d8e:	00005517          	auipc	a0,0x5
    80002d92:	69a50513          	addi	a0,a0,1690 # 80008428 <states.0+0xa8>
    80002d96:	ffffd097          	auipc	ra,0xffffd
    80002d9a:	7f4080e7          	jalr	2036(ra) # 8000058a <printf>
    setkilled(p);
    80002d9e:	8526                	mv	a0,s1
    80002da0:	fffff097          	auipc	ra,0xfffff
    80002da4:	5f8080e7          	jalr	1528(ra) # 80002398 <setkilled>
    80002da8:	b769                	j	80002d32 <usertrap+0x8e>
    yield();
    80002daa:	fffff097          	auipc	ra,0xfffff
    80002dae:	336080e7          	jalr	822(ra) # 800020e0 <yield>
    80002db2:	bf79                	j	80002d50 <usertrap+0xac>

0000000080002db4 <kerneltrap>:
{
    80002db4:	7179                	addi	sp,sp,-48
    80002db6:	f406                	sd	ra,40(sp)
    80002db8:	f022                	sd	s0,32(sp)
    80002dba:	ec26                	sd	s1,24(sp)
    80002dbc:	e84a                	sd	s2,16(sp)
    80002dbe:	e44e                	sd	s3,8(sp)
    80002dc0:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002dc2:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002dc6:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002dca:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002dce:	1004f793          	andi	a5,s1,256
    80002dd2:	cb85                	beqz	a5,80002e02 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002dd4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002dd8:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002dda:	ef85                	bnez	a5,80002e12 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002ddc:	00000097          	auipc	ra,0x0
    80002de0:	e26080e7          	jalr	-474(ra) # 80002c02 <devintr>
    80002de4:	cd1d                	beqz	a0,80002e22 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002de6:	4789                	li	a5,2
    80002de8:	06f50a63          	beq	a0,a5,80002e5c <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002dec:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002df0:	10049073          	csrw	sstatus,s1
}
    80002df4:	70a2                	ld	ra,40(sp)
    80002df6:	7402                	ld	s0,32(sp)
    80002df8:	64e2                	ld	s1,24(sp)
    80002dfa:	6942                	ld	s2,16(sp)
    80002dfc:	69a2                	ld	s3,8(sp)
    80002dfe:	6145                	addi	sp,sp,48
    80002e00:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002e02:	00005517          	auipc	a0,0x5
    80002e06:	64650513          	addi	a0,a0,1606 # 80008448 <states.0+0xc8>
    80002e0a:	ffffd097          	auipc	ra,0xffffd
    80002e0e:	736080e7          	jalr	1846(ra) # 80000540 <panic>
    panic("kerneltrap: interrupts enabled");
    80002e12:	00005517          	auipc	a0,0x5
    80002e16:	65e50513          	addi	a0,a0,1630 # 80008470 <states.0+0xf0>
    80002e1a:	ffffd097          	auipc	ra,0xffffd
    80002e1e:	726080e7          	jalr	1830(ra) # 80000540 <panic>
    printf("scause %p\n", scause);
    80002e22:	85ce                	mv	a1,s3
    80002e24:	00005517          	auipc	a0,0x5
    80002e28:	66c50513          	addi	a0,a0,1644 # 80008490 <states.0+0x110>
    80002e2c:	ffffd097          	auipc	ra,0xffffd
    80002e30:	75e080e7          	jalr	1886(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e34:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002e38:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002e3c:	00005517          	auipc	a0,0x5
    80002e40:	66450513          	addi	a0,a0,1636 # 800084a0 <states.0+0x120>
    80002e44:	ffffd097          	auipc	ra,0xffffd
    80002e48:	746080e7          	jalr	1862(ra) # 8000058a <printf>
    panic("kerneltrap");
    80002e4c:	00005517          	auipc	a0,0x5
    80002e50:	66c50513          	addi	a0,a0,1644 # 800084b8 <states.0+0x138>
    80002e54:	ffffd097          	auipc	ra,0xffffd
    80002e58:	6ec080e7          	jalr	1772(ra) # 80000540 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002e5c:	fffff097          	auipc	ra,0xfffff
    80002e60:	b68080e7          	jalr	-1176(ra) # 800019c4 <myproc>
    80002e64:	d541                	beqz	a0,80002dec <kerneltrap+0x38>
    80002e66:	fffff097          	auipc	ra,0xfffff
    80002e6a:	b5e080e7          	jalr	-1186(ra) # 800019c4 <myproc>
    80002e6e:	4d18                	lw	a4,24(a0)
    80002e70:	4791                	li	a5,4
    80002e72:	f6f71de3          	bne	a4,a5,80002dec <kerneltrap+0x38>
    yield();
    80002e76:	fffff097          	auipc	ra,0xfffff
    80002e7a:	26a080e7          	jalr	618(ra) # 800020e0 <yield>
    80002e7e:	b7bd                	j	80002dec <kerneltrap+0x38>

0000000080002e80 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002e80:	1101                	addi	sp,sp,-32
    80002e82:	ec06                	sd	ra,24(sp)
    80002e84:	e822                	sd	s0,16(sp)
    80002e86:	e426                	sd	s1,8(sp)
    80002e88:	1000                	addi	s0,sp,32
    80002e8a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002e8c:	fffff097          	auipc	ra,0xfffff
    80002e90:	b38080e7          	jalr	-1224(ra) # 800019c4 <myproc>
  switch (n) { 
    80002e94:	4795                	li	a5,5
    80002e96:	0497e163          	bltu	a5,s1,80002ed8 <argraw+0x58>
    80002e9a:	048a                	slli	s1,s1,0x2
    80002e9c:	00005717          	auipc	a4,0x5
    80002ea0:	65470713          	addi	a4,a4,1620 # 800084f0 <states.0+0x170>
    80002ea4:	94ba                	add	s1,s1,a4
    80002ea6:	409c                	lw	a5,0(s1)
    80002ea8:	97ba                	add	a5,a5,a4
    80002eaa:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002eac:	6d3c                	ld	a5,88(a0)
    80002eae:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002eb0:	60e2                	ld	ra,24(sp)
    80002eb2:	6442                	ld	s0,16(sp)
    80002eb4:	64a2                	ld	s1,8(sp)
    80002eb6:	6105                	addi	sp,sp,32
    80002eb8:	8082                	ret
    return p->trapframe->a1;
    80002eba:	6d3c                	ld	a5,88(a0)
    80002ebc:	7fa8                	ld	a0,120(a5)
    80002ebe:	bfcd                	j	80002eb0 <argraw+0x30>
    return p->trapframe->a2;
    80002ec0:	6d3c                	ld	a5,88(a0)
    80002ec2:	63c8                	ld	a0,128(a5)
    80002ec4:	b7f5                	j	80002eb0 <argraw+0x30>
    return p->trapframe->a3;
    80002ec6:	6d3c                	ld	a5,88(a0)
    80002ec8:	67c8                	ld	a0,136(a5)
    80002eca:	b7dd                	j	80002eb0 <argraw+0x30>
    return p->trapframe->a4;
    80002ecc:	6d3c                	ld	a5,88(a0)
    80002ece:	6bc8                	ld	a0,144(a5)
    80002ed0:	b7c5                	j	80002eb0 <argraw+0x30>
    return p->trapframe->a5;
    80002ed2:	6d3c                	ld	a5,88(a0)
    80002ed4:	6fc8                	ld	a0,152(a5)
    80002ed6:	bfe9                	j	80002eb0 <argraw+0x30>
  panic("argraw");
    80002ed8:	00005517          	auipc	a0,0x5
    80002edc:	5f050513          	addi	a0,a0,1520 # 800084c8 <states.0+0x148>
    80002ee0:	ffffd097          	auipc	ra,0xffffd
    80002ee4:	660080e7          	jalr	1632(ra) # 80000540 <panic>

0000000080002ee8 <fetchaddr>:
{
    80002ee8:	1101                	addi	sp,sp,-32
    80002eea:	ec06                	sd	ra,24(sp)
    80002eec:	e822                	sd	s0,16(sp)
    80002eee:	e426                	sd	s1,8(sp)
    80002ef0:	e04a                	sd	s2,0(sp)
    80002ef2:	1000                	addi	s0,sp,32
    80002ef4:	84aa                	mv	s1,a0
    80002ef6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002ef8:	fffff097          	auipc	ra,0xfffff
    80002efc:	acc080e7          	jalr	-1332(ra) # 800019c4 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002f00:	653c                	ld	a5,72(a0)
    80002f02:	02f4f863          	bgeu	s1,a5,80002f32 <fetchaddr+0x4a>
    80002f06:	00848713          	addi	a4,s1,8
    80002f0a:	02e7e663          	bltu	a5,a4,80002f36 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002f0e:	46a1                	li	a3,8
    80002f10:	8626                	mv	a2,s1
    80002f12:	85ca                	mv	a1,s2
    80002f14:	6928                	ld	a0,80(a0)
    80002f16:	ffffe097          	auipc	ra,0xffffe
    80002f1a:	7e2080e7          	jalr	2018(ra) # 800016f8 <copyin>
    80002f1e:	00a03533          	snez	a0,a0
    80002f22:	40a00533          	neg	a0,a0
}
    80002f26:	60e2                	ld	ra,24(sp)
    80002f28:	6442                	ld	s0,16(sp)
    80002f2a:	64a2                	ld	s1,8(sp)
    80002f2c:	6902                	ld	s2,0(sp)
    80002f2e:	6105                	addi	sp,sp,32
    80002f30:	8082                	ret
    return -1;
    80002f32:	557d                	li	a0,-1
    80002f34:	bfcd                	j	80002f26 <fetchaddr+0x3e>
    80002f36:	557d                	li	a0,-1
    80002f38:	b7fd                	j	80002f26 <fetchaddr+0x3e>

0000000080002f3a <fetchstr>:
{
    80002f3a:	7179                	addi	sp,sp,-48
    80002f3c:	f406                	sd	ra,40(sp)
    80002f3e:	f022                	sd	s0,32(sp)
    80002f40:	ec26                	sd	s1,24(sp)
    80002f42:	e84a                	sd	s2,16(sp)
    80002f44:	e44e                	sd	s3,8(sp)
    80002f46:	1800                	addi	s0,sp,48
    80002f48:	892a                	mv	s2,a0
    80002f4a:	84ae                	mv	s1,a1
    80002f4c:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002f4e:	fffff097          	auipc	ra,0xfffff
    80002f52:	a76080e7          	jalr	-1418(ra) # 800019c4 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002f56:	86ce                	mv	a3,s3
    80002f58:	864a                	mv	a2,s2
    80002f5a:	85a6                	mv	a1,s1
    80002f5c:	6928                	ld	a0,80(a0)
    80002f5e:	fffff097          	auipc	ra,0xfffff
    80002f62:	828080e7          	jalr	-2008(ra) # 80001786 <copyinstr>
    80002f66:	00054e63          	bltz	a0,80002f82 <fetchstr+0x48>
  return strlen(buf);
    80002f6a:	8526                	mv	a0,s1
    80002f6c:	ffffe097          	auipc	ra,0xffffe
    80002f70:	ee2080e7          	jalr	-286(ra) # 80000e4e <strlen>
}
    80002f74:	70a2                	ld	ra,40(sp)
    80002f76:	7402                	ld	s0,32(sp)
    80002f78:	64e2                	ld	s1,24(sp)
    80002f7a:	6942                	ld	s2,16(sp)
    80002f7c:	69a2                	ld	s3,8(sp)
    80002f7e:	6145                	addi	sp,sp,48
    80002f80:	8082                	ret
    return -1;
    80002f82:	557d                	li	a0,-1
    80002f84:	bfc5                	j	80002f74 <fetchstr+0x3a>

0000000080002f86 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002f86:	1101                	addi	sp,sp,-32
    80002f88:	ec06                	sd	ra,24(sp)
    80002f8a:	e822                	sd	s0,16(sp)
    80002f8c:	e426                	sd	s1,8(sp)
    80002f8e:	1000                	addi	s0,sp,32
    80002f90:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002f92:	00000097          	auipc	ra,0x0
    80002f96:	eee080e7          	jalr	-274(ra) # 80002e80 <argraw>
    80002f9a:	c088                	sw	a0,0(s1)
}
    80002f9c:	60e2                	ld	ra,24(sp)
    80002f9e:	6442                	ld	s0,16(sp)
    80002fa0:	64a2                	ld	s1,8(sp)
    80002fa2:	6105                	addi	sp,sp,32
    80002fa4:	8082                	ret

0000000080002fa6 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002fa6:	1101                	addi	sp,sp,-32
    80002fa8:	ec06                	sd	ra,24(sp)
    80002faa:	e822                	sd	s0,16(sp)
    80002fac:	e426                	sd	s1,8(sp)
    80002fae:	1000                	addi	s0,sp,32
    80002fb0:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002fb2:	00000097          	auipc	ra,0x0
    80002fb6:	ece080e7          	jalr	-306(ra) # 80002e80 <argraw>
    80002fba:	e088                	sd	a0,0(s1)
}
    80002fbc:	60e2                	ld	ra,24(sp)
    80002fbe:	6442                	ld	s0,16(sp)
    80002fc0:	64a2                	ld	s1,8(sp)
    80002fc2:	6105                	addi	sp,sp,32
    80002fc4:	8082                	ret

0000000080002fc6 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002fc6:	7179                	addi	sp,sp,-48
    80002fc8:	f406                	sd	ra,40(sp)
    80002fca:	f022                	sd	s0,32(sp)
    80002fcc:	ec26                	sd	s1,24(sp)
    80002fce:	e84a                	sd	s2,16(sp)
    80002fd0:	1800                	addi	s0,sp,48
    80002fd2:	84ae                	mv	s1,a1
    80002fd4:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002fd6:	fd840593          	addi	a1,s0,-40
    80002fda:	00000097          	auipc	ra,0x0
    80002fde:	fcc080e7          	jalr	-52(ra) # 80002fa6 <argaddr>
  return fetchstr(addr, buf, max);
    80002fe2:	864a                	mv	a2,s2
    80002fe4:	85a6                	mv	a1,s1
    80002fe6:	fd843503          	ld	a0,-40(s0)
    80002fea:	00000097          	auipc	ra,0x0
    80002fee:	f50080e7          	jalr	-176(ra) # 80002f3a <fetchstr>
}
    80002ff2:	70a2                	ld	ra,40(sp)
    80002ff4:	7402                	ld	s0,32(sp)
    80002ff6:	64e2                	ld	s1,24(sp)
    80002ff8:	6942                	ld	s2,16(sp)
    80002ffa:	6145                	addi	sp,sp,48
    80002ffc:	8082                	ret

0000000080002ffe <syscall>:
int sys_calls_since_boot=0;                // all system call counts including the current
int syscalltillnow=0;                // all system call counts excluding the current

void
syscall(void)
{
    80002ffe:	1101                	addi	sp,sp,-32
    80003000:	ec06                	sd	ra,24(sp)
    80003002:	e822                	sd	s0,16(sp)
    80003004:	e426                	sd	s1,8(sp)
    80003006:	e04a                	sd	s2,0(sp)
    80003008:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    8000300a:	fffff097          	auipc	ra,0xfffff
    8000300e:	9ba080e7          	jalr	-1606(ra) # 800019c4 <myproc>
    80003012:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80003014:	05853903          	ld	s2,88(a0)
    80003018:	0a893783          	ld	a5,168(s2)
    8000301c:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80003020:	37fd                	addiw	a5,a5,-1
    80003022:	4769                	li	a4,26
    80003024:	04f76163          	bltu	a4,a5,80003066 <syscall+0x68>
    80003028:	00369713          	slli	a4,a3,0x3
    8000302c:	00005797          	auipc	a5,0x5
    80003030:	4dc78793          	addi	a5,a5,1244 # 80008508 <syscalls>
    80003034:	97ba                	add	a5,a5,a4
    80003036:	6398                	ld	a4,0(a5)
    80003038:	c71d                	beqz	a4,80003066 <syscall+0x68>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
        syscalltillnow=sys_calls_since_boot;              // updating the system call counts here
    8000303a:	00006697          	auipc	a3,0x6
    8000303e:	9b668693          	addi	a3,a3,-1610 # 800089f0 <sys_calls_since_boot>
    80003042:	429c                	lw	a5,0(a3)
    80003044:	00006617          	auipc	a2,0x6
    80003048:	9af62423          	sw	a5,-1624(a2) # 800089ec <syscalltillnow>
        sys_calls_since_boot++;
    8000304c:	2785                	addiw	a5,a5,1
    8000304e:	c29c                	sw	a5,0(a3)
        p->systemcallstillnow = p->systemcalls;
    80003050:	16852783          	lw	a5,360(a0)
    80003054:	16f52623          	sw	a5,364(a0)
        p->systemcalls++;
    80003058:	2785                	addiw	a5,a5,1
    8000305a:	16f52423          	sw	a5,360(a0)
    p->trapframe->a0 = syscalls[num]();
    8000305e:	9702                	jalr	a4
    80003060:	06a93823          	sd	a0,112(s2)
    80003064:	a839                	j	80003082 <syscall+0x84>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80003066:	15848613          	addi	a2,s1,344
    8000306a:	588c                	lw	a1,48(s1)
    8000306c:	00005517          	auipc	a0,0x5
    80003070:	46450513          	addi	a0,a0,1124 # 800084d0 <states.0+0x150>
    80003074:	ffffd097          	auipc	ra,0xffffd
    80003078:	516080e7          	jalr	1302(ra) # 8000058a <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    8000307c:	6cbc                	ld	a5,88(s1)
    8000307e:	577d                	li	a4,-1
    80003080:	fbb8                	sd	a4,112(a5)
  }
}
    80003082:	60e2                	ld	ra,24(sp)
    80003084:	6442                	ld	s0,16(sp)
    80003086:	64a2                	ld	s1,8(sp)
    80003088:	6902                	ld	s2,0(sp)
    8000308a:	6105                	addi	sp,sp,32
    8000308c:	8082                	ret

000000008000308e <sys_exit>:
#include <stdint.h>


uint64
sys_exit(void)
{
    8000308e:	1101                	addi	sp,sp,-32
    80003090:	ec06                	sd	ra,24(sp)
    80003092:	e822                	sd	s0,16(sp)
    80003094:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80003096:	fec40593          	addi	a1,s0,-20
    8000309a:	4501                	li	a0,0
    8000309c:	00000097          	auipc	ra,0x0
    800030a0:	eea080e7          	jalr	-278(ra) # 80002f86 <argint>
  exit(n);
    800030a4:	fec42503          	lw	a0,-20(s0)
    800030a8:	fffff097          	auipc	ra,0xfffff
    800030ac:	1a8080e7          	jalr	424(ra) # 80002250 <exit>
  return 0;  // not reached
}
    800030b0:	4501                	li	a0,0
    800030b2:	60e2                	ld	ra,24(sp)
    800030b4:	6442                	ld	s0,16(sp)
    800030b6:	6105                	addi	sp,sp,32
    800030b8:	8082                	ret

00000000800030ba <sys_getpid>:

uint64
sys_getpid(void)
{
    800030ba:	1141                	addi	sp,sp,-16
    800030bc:	e406                	sd	ra,8(sp)
    800030be:	e022                	sd	s0,0(sp)
    800030c0:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800030c2:	fffff097          	auipc	ra,0xfffff
    800030c6:	902080e7          	jalr	-1790(ra) # 800019c4 <myproc>
}
    800030ca:	5908                	lw	a0,48(a0)
    800030cc:	60a2                	ld	ra,8(sp)
    800030ce:	6402                	ld	s0,0(sp)
    800030d0:	0141                	addi	sp,sp,16
    800030d2:	8082                	ret

00000000800030d4 <sys_fork>:

uint64
sys_fork(void)
{
    800030d4:	1141                	addi	sp,sp,-16
    800030d6:	e406                	sd	ra,8(sp)
    800030d8:	e022                	sd	s0,0(sp)
    800030da:	0800                	addi	s0,sp,16
  return fork();
    800030dc:	fffff097          	auipc	ra,0xfffff
    800030e0:	cf4080e7          	jalr	-780(ra) # 80001dd0 <fork>
}
    800030e4:	60a2                	ld	ra,8(sp)
    800030e6:	6402                	ld	s0,0(sp)
    800030e8:	0141                	addi	sp,sp,16
    800030ea:	8082                	ret

00000000800030ec <sys_wait>:

uint64
sys_wait(void)
{
    800030ec:	1101                	addi	sp,sp,-32
    800030ee:	ec06                	sd	ra,24(sp)
    800030f0:	e822                	sd	s0,16(sp)
    800030f2:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800030f4:	fe840593          	addi	a1,s0,-24
    800030f8:	4501                	li	a0,0
    800030fa:	00000097          	auipc	ra,0x0
    800030fe:	eac080e7          	jalr	-340(ra) # 80002fa6 <argaddr>
  return wait(p);
    80003102:	fe843503          	ld	a0,-24(s0)
    80003106:	fffff097          	auipc	ra,0xfffff
    8000310a:	2f0080e7          	jalr	752(ra) # 800023f6 <wait>
}
    8000310e:	60e2                	ld	ra,24(sp)
    80003110:	6442                	ld	s0,16(sp)
    80003112:	6105                	addi	sp,sp,32
    80003114:	8082                	ret

0000000080003116 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003116:	7179                	addi	sp,sp,-48
    80003118:	f406                	sd	ra,40(sp)
    8000311a:	f022                	sd	s0,32(sp)
    8000311c:	ec26                	sd	s1,24(sp)
    8000311e:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80003120:	fdc40593          	addi	a1,s0,-36
    80003124:	4501                	li	a0,0
    80003126:	00000097          	auipc	ra,0x0
    8000312a:	e60080e7          	jalr	-416(ra) # 80002f86 <argint>
  addr = myproc()->sz;
    8000312e:	fffff097          	auipc	ra,0xfffff
    80003132:	896080e7          	jalr	-1898(ra) # 800019c4 <myproc>
    80003136:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80003138:	fdc42503          	lw	a0,-36(s0)
    8000313c:	fffff097          	auipc	ra,0xfffff
    80003140:	c38080e7          	jalr	-968(ra) # 80001d74 <growproc>
    80003144:	00054863          	bltz	a0,80003154 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80003148:	8526                	mv	a0,s1
    8000314a:	70a2                	ld	ra,40(sp)
    8000314c:	7402                	ld	s0,32(sp)
    8000314e:	64e2                	ld	s1,24(sp)
    80003150:	6145                	addi	sp,sp,48
    80003152:	8082                	ret
    return -1;
    80003154:	54fd                	li	s1,-1
    80003156:	bfcd                	j	80003148 <sys_sbrk+0x32>

0000000080003158 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003158:	7139                	addi	sp,sp,-64
    8000315a:	fc06                	sd	ra,56(sp)
    8000315c:	f822                	sd	s0,48(sp)
    8000315e:	f426                	sd	s1,40(sp)
    80003160:	f04a                	sd	s2,32(sp)
    80003162:	ec4e                	sd	s3,24(sp)
    80003164:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80003166:	fcc40593          	addi	a1,s0,-52
    8000316a:	4501                	li	a0,0
    8000316c:	00000097          	auipc	ra,0x0
    80003170:	e1a080e7          	jalr	-486(ra) # 80002f86 <argint>
  acquire(&tickslock);
    80003174:	00014517          	auipc	a0,0x14
    80003178:	13450513          	addi	a0,a0,308 # 800172a8 <tickslock>
    8000317c:	ffffe097          	auipc	ra,0xffffe
    80003180:	a5a080e7          	jalr	-1446(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    80003184:	00006917          	auipc	s2,0x6
    80003188:	86492903          	lw	s2,-1948(s2) # 800089e8 <ticks>
  while(ticks - ticks0 < n){
    8000318c:	fcc42783          	lw	a5,-52(s0)
    80003190:	cf9d                	beqz	a5,800031ce <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003192:	00014997          	auipc	s3,0x14
    80003196:	11698993          	addi	s3,s3,278 # 800172a8 <tickslock>
    8000319a:	00006497          	auipc	s1,0x6
    8000319e:	84e48493          	addi	s1,s1,-1970 # 800089e8 <ticks>
    if(killed(myproc())){
    800031a2:	fffff097          	auipc	ra,0xfffff
    800031a6:	822080e7          	jalr	-2014(ra) # 800019c4 <myproc>
    800031aa:	fffff097          	auipc	ra,0xfffff
    800031ae:	21a080e7          	jalr	538(ra) # 800023c4 <killed>
    800031b2:	ed15                	bnez	a0,800031ee <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    800031b4:	85ce                	mv	a1,s3
    800031b6:	8526                	mv	a0,s1
    800031b8:	fffff097          	auipc	ra,0xfffff
    800031bc:	f64080e7          	jalr	-156(ra) # 8000211c <sleep>
  while(ticks - ticks0 < n){
    800031c0:	409c                	lw	a5,0(s1)
    800031c2:	412787bb          	subw	a5,a5,s2
    800031c6:	fcc42703          	lw	a4,-52(s0)
    800031ca:	fce7ece3          	bltu	a5,a4,800031a2 <sys_sleep+0x4a>
  }
  release(&tickslock);
    800031ce:	00014517          	auipc	a0,0x14
    800031d2:	0da50513          	addi	a0,a0,218 # 800172a8 <tickslock>
    800031d6:	ffffe097          	auipc	ra,0xffffe
    800031da:	ab4080e7          	jalr	-1356(ra) # 80000c8a <release>
  return 0;
    800031de:	4501                	li	a0,0
}
    800031e0:	70e2                	ld	ra,56(sp)
    800031e2:	7442                	ld	s0,48(sp)
    800031e4:	74a2                	ld	s1,40(sp)
    800031e6:	7902                	ld	s2,32(sp)
    800031e8:	69e2                	ld	s3,24(sp)
    800031ea:	6121                	addi	sp,sp,64
    800031ec:	8082                	ret
      release(&tickslock);
    800031ee:	00014517          	auipc	a0,0x14
    800031f2:	0ba50513          	addi	a0,a0,186 # 800172a8 <tickslock>
    800031f6:	ffffe097          	auipc	ra,0xffffe
    800031fa:	a94080e7          	jalr	-1388(ra) # 80000c8a <release>
      return -1;
    800031fe:	557d                	li	a0,-1
    80003200:	b7c5                	j	800031e0 <sys_sleep+0x88>

0000000080003202 <sys_kill>:

uint64
sys_kill(void)
{
    80003202:	1101                	addi	sp,sp,-32
    80003204:	ec06                	sd	ra,24(sp)
    80003206:	e822                	sd	s0,16(sp)
    80003208:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    8000320a:	fec40593          	addi	a1,s0,-20
    8000320e:	4501                	li	a0,0
    80003210:	00000097          	auipc	ra,0x0
    80003214:	d76080e7          	jalr	-650(ra) # 80002f86 <argint>
  return kill(pid);
    80003218:	fec42503          	lw	a0,-20(s0)
    8000321c:	fffff097          	auipc	ra,0xfffff
    80003220:	10a080e7          	jalr	266(ra) # 80002326 <kill>
}
    80003224:	60e2                	ld	ra,24(sp)
    80003226:	6442                	ld	s0,16(sp)
    80003228:	6105                	addi	sp,sp,32
    8000322a:	8082                	ret

000000008000322c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000322c:	1101                	addi	sp,sp,-32
    8000322e:	ec06                	sd	ra,24(sp)
    80003230:	e822                	sd	s0,16(sp)
    80003232:	e426                	sd	s1,8(sp)
    80003234:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003236:	00014517          	auipc	a0,0x14
    8000323a:	07250513          	addi	a0,a0,114 # 800172a8 <tickslock>
    8000323e:	ffffe097          	auipc	ra,0xffffe
    80003242:	998080e7          	jalr	-1640(ra) # 80000bd6 <acquire>
  xticks = ticks;
    80003246:	00005497          	auipc	s1,0x5
    8000324a:	7a24a483          	lw	s1,1954(s1) # 800089e8 <ticks>
  release(&tickslock);
    8000324e:	00014517          	auipc	a0,0x14
    80003252:	05a50513          	addi	a0,a0,90 # 800172a8 <tickslock>
    80003256:	ffffe097          	auipc	ra,0xffffe
    8000325a:	a34080e7          	jalr	-1484(ra) # 80000c8a <release>
  return xticks;
}
    8000325e:	02049513          	slli	a0,s1,0x20
    80003262:	9101                	srli	a0,a0,0x20
    80003264:	60e2                	ld	ra,24(sp)
    80003266:	6442                	ld	s0,16(sp)
    80003268:	64a2                	ld	s1,8(sp)
    8000326a:	6105                	addi	sp,sp,32
    8000326c:	8082                	ret

000000008000326e <sys_hello>:

uint64 
sys_hello(void)   // hello syscall definition
{
    8000326e:	1101                	addi	sp,sp,-32
    80003270:	ec06                	sd	ra,24(sp)
    80003272:	e822                	sd	s0,16(sp)
    80003274:	1000                	addi	s0,sp,32
  int n;
  argint(0,&n);
    80003276:	fec40593          	addi	a1,s0,-20
    8000327a:	4501                	li	a0,0
    8000327c:	00000097          	auipc	ra,0x0
    80003280:	d0a080e7          	jalr	-758(ra) # 80002f86 <argint>
  print_hello(n);
    80003284:	fec42503          	lw	a0,-20(s0)
    80003288:	fffff097          	auipc	ra,0xfffff
    8000328c:	3f8080e7          	jalr	1016(ra) # 80002680 <print_hello>
  return 0;
}
    80003290:	4501                	li	a0,0
    80003292:	60e2                	ld	ra,24(sp)
    80003294:	6442                	ld	s0,16(sp)
    80003296:	6105                	addi	sp,sp,32
    80003298:	8082                	ret

000000008000329a <sys_sysinfo>:

uint64 
sys_sysinfo(void)   // Sysinfo syscall definition
{
    8000329a:	1101                	addi	sp,sp,-32
    8000329c:	ec06                	sd	ra,24(sp)
    8000329e:	e822                	sd	s0,16(sp)
    800032a0:	1000                	addi	s0,sp,32
  int n;
  argint(0,&n);
    800032a2:	fec40593          	addi	a1,s0,-20
    800032a6:	4501                	li	a0,0
    800032a8:	00000097          	auipc	ra,0x0
    800032ac:	cde080e7          	jalr	-802(ra) # 80002f86 <argint>
  return print_info(n);
    800032b0:	fec42503          	lw	a0,-20(s0)
    800032b4:	fffff097          	auipc	ra,0xfffff
    800032b8:	3ee080e7          	jalr	1006(ra) # 800026a2 <print_info>
}
    800032bc:	60e2                	ld	ra,24(sp)
    800032be:	6442                	ld	s0,16(sp)
    800032c0:	6105                	addi	sp,sp,32
    800032c2:	8082                	ret

00000000800032c4 <sys_procinfo>:
 

uint64
sys_procinfo(struct pinfo* param) // procinfo syscall definition
{
    800032c4:	1141                	addi	sp,sp,-16
    800032c6:	e406                	sd	ra,8(sp)
    800032c8:	e022                	sd	s0,0(sp)
    800032ca:	0800                	addi	s0,sp,16
  return procinfo(param);
    800032cc:	fffff097          	auipc	ra,0xfffff
    800032d0:	456080e7          	jalr	1110(ra) # 80002722 <procinfo>
}
    800032d4:	60a2                	ld	ra,8(sp)
    800032d6:	6402                	ld	s0,0(sp)
    800032d8:	0141                	addi	sp,sp,16
    800032da:	8082                	ret

00000000800032dc <sys_sched_statistics>:

uint64
sys_sched_statistics(void)
{
    800032dc:	1141                	addi	sp,sp,-16
    800032de:	e406                	sd	ra,8(sp)
    800032e0:	e022                	sd	s0,0(sp)
    800032e2:	0800                	addi	s0,sp,16
  return sched_statistics();
    800032e4:	fffff097          	auipc	ra,0xfffff
    800032e8:	49c080e7          	jalr	1180(ra) # 80002780 <sched_statistics>
}
    800032ec:	60a2                	ld	ra,8(sp)
    800032ee:	6402                	ld	s0,0(sp)
    800032f0:	0141                	addi	sp,sp,16
    800032f2:	8082                	ret

00000000800032f4 <sys_sched_tickets>:

uint64
sys_sched_tickets(void)
{
    800032f4:	1101                	addi	sp,sp,-32
    800032f6:	ec06                	sd	ra,24(sp)
    800032f8:	e822                	sd	s0,16(sp)
    800032fa:	1000                	addi	s0,sp,32
  int n;
  argint(0,&n);
    800032fc:	fec40593          	addi	a1,s0,-20
    80003300:	4501                	li	a0,0
    80003302:	00000097          	auipc	ra,0x0
    80003306:	c84080e7          	jalr	-892(ra) # 80002f86 <argint>
  return sched_tickets(n);
    8000330a:	fec42503          	lw	a0,-20(s0)
    8000330e:	fffff097          	auipc	ra,0xfffff
    80003312:	4cc080e7          	jalr	1228(ra) # 800027da <sched_tickets>
}
    80003316:	60e2                	ld	ra,24(sp)
    80003318:	6442                	ld	s0,16(sp)
    8000331a:	6105                	addi	sp,sp,32
    8000331c:	8082                	ret

000000008000331e <sys_clone>:

uint64
sys_clone(void){
    8000331e:	1101                	addi	sp,sp,-32
    80003320:	ec06                	sd	ra,24(sp)
    80003322:	e822                	sd	s0,16(sp)
    80003324:	1000                	addi	s0,sp,32
  uint64 stack;
  argaddr(0, &stack);
    80003326:	fe840593          	addi	a1,s0,-24
    8000332a:	4501                	li	a0,0
    8000332c:	00000097          	auipc	ra,0x0
    80003330:	c7a080e7          	jalr	-902(ra) # 80002fa6 <argaddr>
  return clone((void*)stack);
    80003334:	fe843503          	ld	a0,-24(s0)
    80003338:	fffff097          	auipc	ra,0xfffff
    8000333c:	508080e7          	jalr	1288(ra) # 80002840 <clone>
    80003340:	60e2                	ld	ra,24(sp)
    80003342:	6442                	ld	s0,16(sp)
    80003344:	6105                	addi	sp,sp,32
    80003346:	8082                	ret

0000000080003348 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003348:	7179                	addi	sp,sp,-48
    8000334a:	f406                	sd	ra,40(sp)
    8000334c:	f022                	sd	s0,32(sp)
    8000334e:	ec26                	sd	s1,24(sp)
    80003350:	e84a                	sd	s2,16(sp)
    80003352:	e44e                	sd	s3,8(sp)
    80003354:	e052                	sd	s4,0(sp)
    80003356:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003358:	00005597          	auipc	a1,0x5
    8000335c:	29058593          	addi	a1,a1,656 # 800085e8 <syscalls+0xe0>
    80003360:	00014517          	auipc	a0,0x14
    80003364:	f6050513          	addi	a0,a0,-160 # 800172c0 <bcache>
    80003368:	ffffd097          	auipc	ra,0xffffd
    8000336c:	7de080e7          	jalr	2014(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003370:	0001c797          	auipc	a5,0x1c
    80003374:	f5078793          	addi	a5,a5,-176 # 8001f2c0 <bcache+0x8000>
    80003378:	0001c717          	auipc	a4,0x1c
    8000337c:	1b070713          	addi	a4,a4,432 # 8001f528 <bcache+0x8268>
    80003380:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003384:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003388:	00014497          	auipc	s1,0x14
    8000338c:	f5048493          	addi	s1,s1,-176 # 800172d8 <bcache+0x18>
    b->next = bcache.head.next;
    80003390:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003392:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003394:	00005a17          	auipc	s4,0x5
    80003398:	25ca0a13          	addi	s4,s4,604 # 800085f0 <syscalls+0xe8>
    b->next = bcache.head.next;
    8000339c:	2b893783          	ld	a5,696(s2)
    800033a0:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800033a2:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800033a6:	85d2                	mv	a1,s4
    800033a8:	01048513          	addi	a0,s1,16
    800033ac:	00001097          	auipc	ra,0x1
    800033b0:	4c8080e7          	jalr	1224(ra) # 80004874 <initsleeplock>
    bcache.head.next->prev = b;
    800033b4:	2b893783          	ld	a5,696(s2)
    800033b8:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800033ba:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800033be:	45848493          	addi	s1,s1,1112
    800033c2:	fd349de3          	bne	s1,s3,8000339c <binit+0x54>
  }
}
    800033c6:	70a2                	ld	ra,40(sp)
    800033c8:	7402                	ld	s0,32(sp)
    800033ca:	64e2                	ld	s1,24(sp)
    800033cc:	6942                	ld	s2,16(sp)
    800033ce:	69a2                	ld	s3,8(sp)
    800033d0:	6a02                	ld	s4,0(sp)
    800033d2:	6145                	addi	sp,sp,48
    800033d4:	8082                	ret

00000000800033d6 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800033d6:	7179                	addi	sp,sp,-48
    800033d8:	f406                	sd	ra,40(sp)
    800033da:	f022                	sd	s0,32(sp)
    800033dc:	ec26                	sd	s1,24(sp)
    800033de:	e84a                	sd	s2,16(sp)
    800033e0:	e44e                	sd	s3,8(sp)
    800033e2:	1800                	addi	s0,sp,48
    800033e4:	892a                	mv	s2,a0
    800033e6:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800033e8:	00014517          	auipc	a0,0x14
    800033ec:	ed850513          	addi	a0,a0,-296 # 800172c0 <bcache>
    800033f0:	ffffd097          	auipc	ra,0xffffd
    800033f4:	7e6080e7          	jalr	2022(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800033f8:	0001c497          	auipc	s1,0x1c
    800033fc:	1804b483          	ld	s1,384(s1) # 8001f578 <bcache+0x82b8>
    80003400:	0001c797          	auipc	a5,0x1c
    80003404:	12878793          	addi	a5,a5,296 # 8001f528 <bcache+0x8268>
    80003408:	02f48f63          	beq	s1,a5,80003446 <bread+0x70>
    8000340c:	873e                	mv	a4,a5
    8000340e:	a021                	j	80003416 <bread+0x40>
    80003410:	68a4                	ld	s1,80(s1)
    80003412:	02e48a63          	beq	s1,a4,80003446 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003416:	449c                	lw	a5,8(s1)
    80003418:	ff279ce3          	bne	a5,s2,80003410 <bread+0x3a>
    8000341c:	44dc                	lw	a5,12(s1)
    8000341e:	ff3799e3          	bne	a5,s3,80003410 <bread+0x3a>
      b->refcnt++;
    80003422:	40bc                	lw	a5,64(s1)
    80003424:	2785                	addiw	a5,a5,1
    80003426:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003428:	00014517          	auipc	a0,0x14
    8000342c:	e9850513          	addi	a0,a0,-360 # 800172c0 <bcache>
    80003430:	ffffe097          	auipc	ra,0xffffe
    80003434:	85a080e7          	jalr	-1958(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80003438:	01048513          	addi	a0,s1,16
    8000343c:	00001097          	auipc	ra,0x1
    80003440:	472080e7          	jalr	1138(ra) # 800048ae <acquiresleep>
      return b;
    80003444:	a8b9                	j	800034a2 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003446:	0001c497          	auipc	s1,0x1c
    8000344a:	12a4b483          	ld	s1,298(s1) # 8001f570 <bcache+0x82b0>
    8000344e:	0001c797          	auipc	a5,0x1c
    80003452:	0da78793          	addi	a5,a5,218 # 8001f528 <bcache+0x8268>
    80003456:	00f48863          	beq	s1,a5,80003466 <bread+0x90>
    8000345a:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000345c:	40bc                	lw	a5,64(s1)
    8000345e:	cf81                	beqz	a5,80003476 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003460:	64a4                	ld	s1,72(s1)
    80003462:	fee49de3          	bne	s1,a4,8000345c <bread+0x86>
  panic("bget: no buffers");
    80003466:	00005517          	auipc	a0,0x5
    8000346a:	19250513          	addi	a0,a0,402 # 800085f8 <syscalls+0xf0>
    8000346e:	ffffd097          	auipc	ra,0xffffd
    80003472:	0d2080e7          	jalr	210(ra) # 80000540 <panic>
      b->dev = dev;
    80003476:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000347a:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000347e:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003482:	4785                	li	a5,1
    80003484:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003486:	00014517          	auipc	a0,0x14
    8000348a:	e3a50513          	addi	a0,a0,-454 # 800172c0 <bcache>
    8000348e:	ffffd097          	auipc	ra,0xffffd
    80003492:	7fc080e7          	jalr	2044(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80003496:	01048513          	addi	a0,s1,16
    8000349a:	00001097          	auipc	ra,0x1
    8000349e:	414080e7          	jalr	1044(ra) # 800048ae <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800034a2:	409c                	lw	a5,0(s1)
    800034a4:	cb89                	beqz	a5,800034b6 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800034a6:	8526                	mv	a0,s1
    800034a8:	70a2                	ld	ra,40(sp)
    800034aa:	7402                	ld	s0,32(sp)
    800034ac:	64e2                	ld	s1,24(sp)
    800034ae:	6942                	ld	s2,16(sp)
    800034b0:	69a2                	ld	s3,8(sp)
    800034b2:	6145                	addi	sp,sp,48
    800034b4:	8082                	ret
    virtio_disk_rw(b, 0);
    800034b6:	4581                	li	a1,0
    800034b8:	8526                	mv	a0,s1
    800034ba:	00003097          	auipc	ra,0x3
    800034be:	fd8080e7          	jalr	-40(ra) # 80006492 <virtio_disk_rw>
    b->valid = 1;
    800034c2:	4785                	li	a5,1
    800034c4:	c09c                	sw	a5,0(s1)
  return b;
    800034c6:	b7c5                	j	800034a6 <bread+0xd0>

00000000800034c8 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800034c8:	1101                	addi	sp,sp,-32
    800034ca:	ec06                	sd	ra,24(sp)
    800034cc:	e822                	sd	s0,16(sp)
    800034ce:	e426                	sd	s1,8(sp)
    800034d0:	1000                	addi	s0,sp,32
    800034d2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800034d4:	0541                	addi	a0,a0,16
    800034d6:	00001097          	auipc	ra,0x1
    800034da:	472080e7          	jalr	1138(ra) # 80004948 <holdingsleep>
    800034de:	cd01                	beqz	a0,800034f6 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800034e0:	4585                	li	a1,1
    800034e2:	8526                	mv	a0,s1
    800034e4:	00003097          	auipc	ra,0x3
    800034e8:	fae080e7          	jalr	-82(ra) # 80006492 <virtio_disk_rw>
}
    800034ec:	60e2                	ld	ra,24(sp)
    800034ee:	6442                	ld	s0,16(sp)
    800034f0:	64a2                	ld	s1,8(sp)
    800034f2:	6105                	addi	sp,sp,32
    800034f4:	8082                	ret
    panic("bwrite");
    800034f6:	00005517          	auipc	a0,0x5
    800034fa:	11a50513          	addi	a0,a0,282 # 80008610 <syscalls+0x108>
    800034fe:	ffffd097          	auipc	ra,0xffffd
    80003502:	042080e7          	jalr	66(ra) # 80000540 <panic>

0000000080003506 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003506:	1101                	addi	sp,sp,-32
    80003508:	ec06                	sd	ra,24(sp)
    8000350a:	e822                	sd	s0,16(sp)
    8000350c:	e426                	sd	s1,8(sp)
    8000350e:	e04a                	sd	s2,0(sp)
    80003510:	1000                	addi	s0,sp,32
    80003512:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003514:	01050913          	addi	s2,a0,16
    80003518:	854a                	mv	a0,s2
    8000351a:	00001097          	auipc	ra,0x1
    8000351e:	42e080e7          	jalr	1070(ra) # 80004948 <holdingsleep>
    80003522:	c92d                	beqz	a0,80003594 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003524:	854a                	mv	a0,s2
    80003526:	00001097          	auipc	ra,0x1
    8000352a:	3de080e7          	jalr	990(ra) # 80004904 <releasesleep>

  acquire(&bcache.lock);
    8000352e:	00014517          	auipc	a0,0x14
    80003532:	d9250513          	addi	a0,a0,-622 # 800172c0 <bcache>
    80003536:	ffffd097          	auipc	ra,0xffffd
    8000353a:	6a0080e7          	jalr	1696(ra) # 80000bd6 <acquire>
  b->refcnt--;
    8000353e:	40bc                	lw	a5,64(s1)
    80003540:	37fd                	addiw	a5,a5,-1
    80003542:	0007871b          	sext.w	a4,a5
    80003546:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003548:	eb05                	bnez	a4,80003578 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000354a:	68bc                	ld	a5,80(s1)
    8000354c:	64b8                	ld	a4,72(s1)
    8000354e:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003550:	64bc                	ld	a5,72(s1)
    80003552:	68b8                	ld	a4,80(s1)
    80003554:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003556:	0001c797          	auipc	a5,0x1c
    8000355a:	d6a78793          	addi	a5,a5,-662 # 8001f2c0 <bcache+0x8000>
    8000355e:	2b87b703          	ld	a4,696(a5)
    80003562:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003564:	0001c717          	auipc	a4,0x1c
    80003568:	fc470713          	addi	a4,a4,-60 # 8001f528 <bcache+0x8268>
    8000356c:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000356e:	2b87b703          	ld	a4,696(a5)
    80003572:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003574:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003578:	00014517          	auipc	a0,0x14
    8000357c:	d4850513          	addi	a0,a0,-696 # 800172c0 <bcache>
    80003580:	ffffd097          	auipc	ra,0xffffd
    80003584:	70a080e7          	jalr	1802(ra) # 80000c8a <release>
}
    80003588:	60e2                	ld	ra,24(sp)
    8000358a:	6442                	ld	s0,16(sp)
    8000358c:	64a2                	ld	s1,8(sp)
    8000358e:	6902                	ld	s2,0(sp)
    80003590:	6105                	addi	sp,sp,32
    80003592:	8082                	ret
    panic("brelse");
    80003594:	00005517          	auipc	a0,0x5
    80003598:	08450513          	addi	a0,a0,132 # 80008618 <syscalls+0x110>
    8000359c:	ffffd097          	auipc	ra,0xffffd
    800035a0:	fa4080e7          	jalr	-92(ra) # 80000540 <panic>

00000000800035a4 <bpin>:

void
bpin(struct buf *b) {
    800035a4:	1101                	addi	sp,sp,-32
    800035a6:	ec06                	sd	ra,24(sp)
    800035a8:	e822                	sd	s0,16(sp)
    800035aa:	e426                	sd	s1,8(sp)
    800035ac:	1000                	addi	s0,sp,32
    800035ae:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800035b0:	00014517          	auipc	a0,0x14
    800035b4:	d1050513          	addi	a0,a0,-752 # 800172c0 <bcache>
    800035b8:	ffffd097          	auipc	ra,0xffffd
    800035bc:	61e080e7          	jalr	1566(ra) # 80000bd6 <acquire>
  b->refcnt++;
    800035c0:	40bc                	lw	a5,64(s1)
    800035c2:	2785                	addiw	a5,a5,1
    800035c4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800035c6:	00014517          	auipc	a0,0x14
    800035ca:	cfa50513          	addi	a0,a0,-774 # 800172c0 <bcache>
    800035ce:	ffffd097          	auipc	ra,0xffffd
    800035d2:	6bc080e7          	jalr	1724(ra) # 80000c8a <release>
}
    800035d6:	60e2                	ld	ra,24(sp)
    800035d8:	6442                	ld	s0,16(sp)
    800035da:	64a2                	ld	s1,8(sp)
    800035dc:	6105                	addi	sp,sp,32
    800035de:	8082                	ret

00000000800035e0 <bunpin>:

void
bunpin(struct buf *b) {
    800035e0:	1101                	addi	sp,sp,-32
    800035e2:	ec06                	sd	ra,24(sp)
    800035e4:	e822                	sd	s0,16(sp)
    800035e6:	e426                	sd	s1,8(sp)
    800035e8:	1000                	addi	s0,sp,32
    800035ea:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800035ec:	00014517          	auipc	a0,0x14
    800035f0:	cd450513          	addi	a0,a0,-812 # 800172c0 <bcache>
    800035f4:	ffffd097          	auipc	ra,0xffffd
    800035f8:	5e2080e7          	jalr	1506(ra) # 80000bd6 <acquire>
  b->refcnt--;
    800035fc:	40bc                	lw	a5,64(s1)
    800035fe:	37fd                	addiw	a5,a5,-1
    80003600:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003602:	00014517          	auipc	a0,0x14
    80003606:	cbe50513          	addi	a0,a0,-834 # 800172c0 <bcache>
    8000360a:	ffffd097          	auipc	ra,0xffffd
    8000360e:	680080e7          	jalr	1664(ra) # 80000c8a <release>
}
    80003612:	60e2                	ld	ra,24(sp)
    80003614:	6442                	ld	s0,16(sp)
    80003616:	64a2                	ld	s1,8(sp)
    80003618:	6105                	addi	sp,sp,32
    8000361a:	8082                	ret

000000008000361c <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000361c:	1101                	addi	sp,sp,-32
    8000361e:	ec06                	sd	ra,24(sp)
    80003620:	e822                	sd	s0,16(sp)
    80003622:	e426                	sd	s1,8(sp)
    80003624:	e04a                	sd	s2,0(sp)
    80003626:	1000                	addi	s0,sp,32
    80003628:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000362a:	00d5d59b          	srliw	a1,a1,0xd
    8000362e:	0001c797          	auipc	a5,0x1c
    80003632:	36e7a783          	lw	a5,878(a5) # 8001f99c <sb+0x1c>
    80003636:	9dbd                	addw	a1,a1,a5
    80003638:	00000097          	auipc	ra,0x0
    8000363c:	d9e080e7          	jalr	-610(ra) # 800033d6 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003640:	0074f713          	andi	a4,s1,7
    80003644:	4785                	li	a5,1
    80003646:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000364a:	14ce                	slli	s1,s1,0x33
    8000364c:	90d9                	srli	s1,s1,0x36
    8000364e:	00950733          	add	a4,a0,s1
    80003652:	05874703          	lbu	a4,88(a4)
    80003656:	00e7f6b3          	and	a3,a5,a4
    8000365a:	c69d                	beqz	a3,80003688 <bfree+0x6c>
    8000365c:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000365e:	94aa                	add	s1,s1,a0
    80003660:	fff7c793          	not	a5,a5
    80003664:	8f7d                	and	a4,a4,a5
    80003666:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000366a:	00001097          	auipc	ra,0x1
    8000366e:	126080e7          	jalr	294(ra) # 80004790 <log_write>
  brelse(bp);
    80003672:	854a                	mv	a0,s2
    80003674:	00000097          	auipc	ra,0x0
    80003678:	e92080e7          	jalr	-366(ra) # 80003506 <brelse>
}
    8000367c:	60e2                	ld	ra,24(sp)
    8000367e:	6442                	ld	s0,16(sp)
    80003680:	64a2                	ld	s1,8(sp)
    80003682:	6902                	ld	s2,0(sp)
    80003684:	6105                	addi	sp,sp,32
    80003686:	8082                	ret
    panic("freeing free block");
    80003688:	00005517          	auipc	a0,0x5
    8000368c:	f9850513          	addi	a0,a0,-104 # 80008620 <syscalls+0x118>
    80003690:	ffffd097          	auipc	ra,0xffffd
    80003694:	eb0080e7          	jalr	-336(ra) # 80000540 <panic>

0000000080003698 <balloc>:
{
    80003698:	711d                	addi	sp,sp,-96
    8000369a:	ec86                	sd	ra,88(sp)
    8000369c:	e8a2                	sd	s0,80(sp)
    8000369e:	e4a6                	sd	s1,72(sp)
    800036a0:	e0ca                	sd	s2,64(sp)
    800036a2:	fc4e                	sd	s3,56(sp)
    800036a4:	f852                	sd	s4,48(sp)
    800036a6:	f456                	sd	s5,40(sp)
    800036a8:	f05a                	sd	s6,32(sp)
    800036aa:	ec5e                	sd	s7,24(sp)
    800036ac:	e862                	sd	s8,16(sp)
    800036ae:	e466                	sd	s9,8(sp)
    800036b0:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800036b2:	0001c797          	auipc	a5,0x1c
    800036b6:	2d27a783          	lw	a5,722(a5) # 8001f984 <sb+0x4>
    800036ba:	cff5                	beqz	a5,800037b6 <balloc+0x11e>
    800036bc:	8baa                	mv	s7,a0
    800036be:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800036c0:	0001cb17          	auipc	s6,0x1c
    800036c4:	2c0b0b13          	addi	s6,s6,704 # 8001f980 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800036c8:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800036ca:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800036cc:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800036ce:	6c89                	lui	s9,0x2
    800036d0:	a061                	j	80003758 <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    800036d2:	97ca                	add	a5,a5,s2
    800036d4:	8e55                	or	a2,a2,a3
    800036d6:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800036da:	854a                	mv	a0,s2
    800036dc:	00001097          	auipc	ra,0x1
    800036e0:	0b4080e7          	jalr	180(ra) # 80004790 <log_write>
        brelse(bp);
    800036e4:	854a                	mv	a0,s2
    800036e6:	00000097          	auipc	ra,0x0
    800036ea:	e20080e7          	jalr	-480(ra) # 80003506 <brelse>
  bp = bread(dev, bno);
    800036ee:	85a6                	mv	a1,s1
    800036f0:	855e                	mv	a0,s7
    800036f2:	00000097          	auipc	ra,0x0
    800036f6:	ce4080e7          	jalr	-796(ra) # 800033d6 <bread>
    800036fa:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800036fc:	40000613          	li	a2,1024
    80003700:	4581                	li	a1,0
    80003702:	05850513          	addi	a0,a0,88
    80003706:	ffffd097          	auipc	ra,0xffffd
    8000370a:	5cc080e7          	jalr	1484(ra) # 80000cd2 <memset>
  log_write(bp);
    8000370e:	854a                	mv	a0,s2
    80003710:	00001097          	auipc	ra,0x1
    80003714:	080080e7          	jalr	128(ra) # 80004790 <log_write>
  brelse(bp);
    80003718:	854a                	mv	a0,s2
    8000371a:	00000097          	auipc	ra,0x0
    8000371e:	dec080e7          	jalr	-532(ra) # 80003506 <brelse>
}
    80003722:	8526                	mv	a0,s1
    80003724:	60e6                	ld	ra,88(sp)
    80003726:	6446                	ld	s0,80(sp)
    80003728:	64a6                	ld	s1,72(sp)
    8000372a:	6906                	ld	s2,64(sp)
    8000372c:	79e2                	ld	s3,56(sp)
    8000372e:	7a42                	ld	s4,48(sp)
    80003730:	7aa2                	ld	s5,40(sp)
    80003732:	7b02                	ld	s6,32(sp)
    80003734:	6be2                	ld	s7,24(sp)
    80003736:	6c42                	ld	s8,16(sp)
    80003738:	6ca2                	ld	s9,8(sp)
    8000373a:	6125                	addi	sp,sp,96
    8000373c:	8082                	ret
    brelse(bp);
    8000373e:	854a                	mv	a0,s2
    80003740:	00000097          	auipc	ra,0x0
    80003744:	dc6080e7          	jalr	-570(ra) # 80003506 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003748:	015c87bb          	addw	a5,s9,s5
    8000374c:	00078a9b          	sext.w	s5,a5
    80003750:	004b2703          	lw	a4,4(s6)
    80003754:	06eaf163          	bgeu	s5,a4,800037b6 <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    80003758:	41fad79b          	sraiw	a5,s5,0x1f
    8000375c:	0137d79b          	srliw	a5,a5,0x13
    80003760:	015787bb          	addw	a5,a5,s5
    80003764:	40d7d79b          	sraiw	a5,a5,0xd
    80003768:	01cb2583          	lw	a1,28(s6)
    8000376c:	9dbd                	addw	a1,a1,a5
    8000376e:	855e                	mv	a0,s7
    80003770:	00000097          	auipc	ra,0x0
    80003774:	c66080e7          	jalr	-922(ra) # 800033d6 <bread>
    80003778:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000377a:	004b2503          	lw	a0,4(s6)
    8000377e:	000a849b          	sext.w	s1,s5
    80003782:	8762                	mv	a4,s8
    80003784:	faa4fde3          	bgeu	s1,a0,8000373e <balloc+0xa6>
      m = 1 << (bi % 8);
    80003788:	00777693          	andi	a3,a4,7
    8000378c:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003790:	41f7579b          	sraiw	a5,a4,0x1f
    80003794:	01d7d79b          	srliw	a5,a5,0x1d
    80003798:	9fb9                	addw	a5,a5,a4
    8000379a:	4037d79b          	sraiw	a5,a5,0x3
    8000379e:	00f90633          	add	a2,s2,a5
    800037a2:	05864603          	lbu	a2,88(a2)
    800037a6:	00c6f5b3          	and	a1,a3,a2
    800037aa:	d585                	beqz	a1,800036d2 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037ac:	2705                	addiw	a4,a4,1
    800037ae:	2485                	addiw	s1,s1,1
    800037b0:	fd471ae3          	bne	a4,s4,80003784 <balloc+0xec>
    800037b4:	b769                	j	8000373e <balloc+0xa6>
  printf("balloc: out of blocks\n");
    800037b6:	00005517          	auipc	a0,0x5
    800037ba:	e8250513          	addi	a0,a0,-382 # 80008638 <syscalls+0x130>
    800037be:	ffffd097          	auipc	ra,0xffffd
    800037c2:	dcc080e7          	jalr	-564(ra) # 8000058a <printf>
  return 0;
    800037c6:	4481                	li	s1,0
    800037c8:	bfa9                	j	80003722 <balloc+0x8a>

00000000800037ca <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800037ca:	7179                	addi	sp,sp,-48
    800037cc:	f406                	sd	ra,40(sp)
    800037ce:	f022                	sd	s0,32(sp)
    800037d0:	ec26                	sd	s1,24(sp)
    800037d2:	e84a                	sd	s2,16(sp)
    800037d4:	e44e                	sd	s3,8(sp)
    800037d6:	e052                	sd	s4,0(sp)
    800037d8:	1800                	addi	s0,sp,48
    800037da:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800037dc:	47ad                	li	a5,11
    800037de:	02b7e863          	bltu	a5,a1,8000380e <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    800037e2:	02059793          	slli	a5,a1,0x20
    800037e6:	01e7d593          	srli	a1,a5,0x1e
    800037ea:	00b504b3          	add	s1,a0,a1
    800037ee:	0504a903          	lw	s2,80(s1)
    800037f2:	06091e63          	bnez	s2,8000386e <bmap+0xa4>
      addr = balloc(ip->dev);
    800037f6:	4108                	lw	a0,0(a0)
    800037f8:	00000097          	auipc	ra,0x0
    800037fc:	ea0080e7          	jalr	-352(ra) # 80003698 <balloc>
    80003800:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003804:	06090563          	beqz	s2,8000386e <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    80003808:	0524a823          	sw	s2,80(s1)
    8000380c:	a08d                	j	8000386e <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000380e:	ff45849b          	addiw	s1,a1,-12
    80003812:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003816:	0ff00793          	li	a5,255
    8000381a:	08e7e563          	bltu	a5,a4,800038a4 <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000381e:	08052903          	lw	s2,128(a0)
    80003822:	00091d63          	bnez	s2,8000383c <bmap+0x72>
      addr = balloc(ip->dev);
    80003826:	4108                	lw	a0,0(a0)
    80003828:	00000097          	auipc	ra,0x0
    8000382c:	e70080e7          	jalr	-400(ra) # 80003698 <balloc>
    80003830:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003834:	02090d63          	beqz	s2,8000386e <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003838:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    8000383c:	85ca                	mv	a1,s2
    8000383e:	0009a503          	lw	a0,0(s3)
    80003842:	00000097          	auipc	ra,0x0
    80003846:	b94080e7          	jalr	-1132(ra) # 800033d6 <bread>
    8000384a:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000384c:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003850:	02049713          	slli	a4,s1,0x20
    80003854:	01e75593          	srli	a1,a4,0x1e
    80003858:	00b784b3          	add	s1,a5,a1
    8000385c:	0004a903          	lw	s2,0(s1)
    80003860:	02090063          	beqz	s2,80003880 <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003864:	8552                	mv	a0,s4
    80003866:	00000097          	auipc	ra,0x0
    8000386a:	ca0080e7          	jalr	-864(ra) # 80003506 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000386e:	854a                	mv	a0,s2
    80003870:	70a2                	ld	ra,40(sp)
    80003872:	7402                	ld	s0,32(sp)
    80003874:	64e2                	ld	s1,24(sp)
    80003876:	6942                	ld	s2,16(sp)
    80003878:	69a2                	ld	s3,8(sp)
    8000387a:	6a02                	ld	s4,0(sp)
    8000387c:	6145                	addi	sp,sp,48
    8000387e:	8082                	ret
      addr = balloc(ip->dev);
    80003880:	0009a503          	lw	a0,0(s3)
    80003884:	00000097          	auipc	ra,0x0
    80003888:	e14080e7          	jalr	-492(ra) # 80003698 <balloc>
    8000388c:	0005091b          	sext.w	s2,a0
      if(addr){
    80003890:	fc090ae3          	beqz	s2,80003864 <bmap+0x9a>
        a[bn] = addr;
    80003894:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003898:	8552                	mv	a0,s4
    8000389a:	00001097          	auipc	ra,0x1
    8000389e:	ef6080e7          	jalr	-266(ra) # 80004790 <log_write>
    800038a2:	b7c9                	j	80003864 <bmap+0x9a>
  panic("bmap: out of range");
    800038a4:	00005517          	auipc	a0,0x5
    800038a8:	dac50513          	addi	a0,a0,-596 # 80008650 <syscalls+0x148>
    800038ac:	ffffd097          	auipc	ra,0xffffd
    800038b0:	c94080e7          	jalr	-876(ra) # 80000540 <panic>

00000000800038b4 <iget>:
{
    800038b4:	7179                	addi	sp,sp,-48
    800038b6:	f406                	sd	ra,40(sp)
    800038b8:	f022                	sd	s0,32(sp)
    800038ba:	ec26                	sd	s1,24(sp)
    800038bc:	e84a                	sd	s2,16(sp)
    800038be:	e44e                	sd	s3,8(sp)
    800038c0:	e052                	sd	s4,0(sp)
    800038c2:	1800                	addi	s0,sp,48
    800038c4:	89aa                	mv	s3,a0
    800038c6:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800038c8:	0001c517          	auipc	a0,0x1c
    800038cc:	0d850513          	addi	a0,a0,216 # 8001f9a0 <itable>
    800038d0:	ffffd097          	auipc	ra,0xffffd
    800038d4:	306080e7          	jalr	774(ra) # 80000bd6 <acquire>
  empty = 0;
    800038d8:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800038da:	0001c497          	auipc	s1,0x1c
    800038de:	0de48493          	addi	s1,s1,222 # 8001f9b8 <itable+0x18>
    800038e2:	0001e697          	auipc	a3,0x1e
    800038e6:	b6668693          	addi	a3,a3,-1178 # 80021448 <log>
    800038ea:	a039                	j	800038f8 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800038ec:	02090b63          	beqz	s2,80003922 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800038f0:	08848493          	addi	s1,s1,136
    800038f4:	02d48a63          	beq	s1,a3,80003928 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800038f8:	449c                	lw	a5,8(s1)
    800038fa:	fef059e3          	blez	a5,800038ec <iget+0x38>
    800038fe:	4098                	lw	a4,0(s1)
    80003900:	ff3716e3          	bne	a4,s3,800038ec <iget+0x38>
    80003904:	40d8                	lw	a4,4(s1)
    80003906:	ff4713e3          	bne	a4,s4,800038ec <iget+0x38>
      ip->ref++;
    8000390a:	2785                	addiw	a5,a5,1
    8000390c:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000390e:	0001c517          	auipc	a0,0x1c
    80003912:	09250513          	addi	a0,a0,146 # 8001f9a0 <itable>
    80003916:	ffffd097          	auipc	ra,0xffffd
    8000391a:	374080e7          	jalr	884(ra) # 80000c8a <release>
      return ip;
    8000391e:	8926                	mv	s2,s1
    80003920:	a03d                	j	8000394e <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003922:	f7f9                	bnez	a5,800038f0 <iget+0x3c>
    80003924:	8926                	mv	s2,s1
    80003926:	b7e9                	j	800038f0 <iget+0x3c>
  if(empty == 0)
    80003928:	02090c63          	beqz	s2,80003960 <iget+0xac>
  ip->dev = dev;
    8000392c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003930:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003934:	4785                	li	a5,1
    80003936:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000393a:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000393e:	0001c517          	auipc	a0,0x1c
    80003942:	06250513          	addi	a0,a0,98 # 8001f9a0 <itable>
    80003946:	ffffd097          	auipc	ra,0xffffd
    8000394a:	344080e7          	jalr	836(ra) # 80000c8a <release>
}
    8000394e:	854a                	mv	a0,s2
    80003950:	70a2                	ld	ra,40(sp)
    80003952:	7402                	ld	s0,32(sp)
    80003954:	64e2                	ld	s1,24(sp)
    80003956:	6942                	ld	s2,16(sp)
    80003958:	69a2                	ld	s3,8(sp)
    8000395a:	6a02                	ld	s4,0(sp)
    8000395c:	6145                	addi	sp,sp,48
    8000395e:	8082                	ret
    panic("iget: no inodes");
    80003960:	00005517          	auipc	a0,0x5
    80003964:	d0850513          	addi	a0,a0,-760 # 80008668 <syscalls+0x160>
    80003968:	ffffd097          	auipc	ra,0xffffd
    8000396c:	bd8080e7          	jalr	-1064(ra) # 80000540 <panic>

0000000080003970 <fsinit>:
fsinit(int dev) {
    80003970:	7179                	addi	sp,sp,-48
    80003972:	f406                	sd	ra,40(sp)
    80003974:	f022                	sd	s0,32(sp)
    80003976:	ec26                	sd	s1,24(sp)
    80003978:	e84a                	sd	s2,16(sp)
    8000397a:	e44e                	sd	s3,8(sp)
    8000397c:	1800                	addi	s0,sp,48
    8000397e:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003980:	4585                	li	a1,1
    80003982:	00000097          	auipc	ra,0x0
    80003986:	a54080e7          	jalr	-1452(ra) # 800033d6 <bread>
    8000398a:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000398c:	0001c997          	auipc	s3,0x1c
    80003990:	ff498993          	addi	s3,s3,-12 # 8001f980 <sb>
    80003994:	02000613          	li	a2,32
    80003998:	05850593          	addi	a1,a0,88
    8000399c:	854e                	mv	a0,s3
    8000399e:	ffffd097          	auipc	ra,0xffffd
    800039a2:	390080e7          	jalr	912(ra) # 80000d2e <memmove>
  brelse(bp);
    800039a6:	8526                	mv	a0,s1
    800039a8:	00000097          	auipc	ra,0x0
    800039ac:	b5e080e7          	jalr	-1186(ra) # 80003506 <brelse>
  if(sb.magic != FSMAGIC)
    800039b0:	0009a703          	lw	a4,0(s3)
    800039b4:	102037b7          	lui	a5,0x10203
    800039b8:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800039bc:	02f71263          	bne	a4,a5,800039e0 <fsinit+0x70>
  initlog(dev, &sb);
    800039c0:	0001c597          	auipc	a1,0x1c
    800039c4:	fc058593          	addi	a1,a1,-64 # 8001f980 <sb>
    800039c8:	854a                	mv	a0,s2
    800039ca:	00001097          	auipc	ra,0x1
    800039ce:	b4a080e7          	jalr	-1206(ra) # 80004514 <initlog>
}
    800039d2:	70a2                	ld	ra,40(sp)
    800039d4:	7402                	ld	s0,32(sp)
    800039d6:	64e2                	ld	s1,24(sp)
    800039d8:	6942                	ld	s2,16(sp)
    800039da:	69a2                	ld	s3,8(sp)
    800039dc:	6145                	addi	sp,sp,48
    800039de:	8082                	ret
    panic("invalid file system");
    800039e0:	00005517          	auipc	a0,0x5
    800039e4:	c9850513          	addi	a0,a0,-872 # 80008678 <syscalls+0x170>
    800039e8:	ffffd097          	auipc	ra,0xffffd
    800039ec:	b58080e7          	jalr	-1192(ra) # 80000540 <panic>

00000000800039f0 <iinit>:
{
    800039f0:	7179                	addi	sp,sp,-48
    800039f2:	f406                	sd	ra,40(sp)
    800039f4:	f022                	sd	s0,32(sp)
    800039f6:	ec26                	sd	s1,24(sp)
    800039f8:	e84a                	sd	s2,16(sp)
    800039fa:	e44e                	sd	s3,8(sp)
    800039fc:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800039fe:	00005597          	auipc	a1,0x5
    80003a02:	c9258593          	addi	a1,a1,-878 # 80008690 <syscalls+0x188>
    80003a06:	0001c517          	auipc	a0,0x1c
    80003a0a:	f9a50513          	addi	a0,a0,-102 # 8001f9a0 <itable>
    80003a0e:	ffffd097          	auipc	ra,0xffffd
    80003a12:	138080e7          	jalr	312(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003a16:	0001c497          	auipc	s1,0x1c
    80003a1a:	fb248493          	addi	s1,s1,-78 # 8001f9c8 <itable+0x28>
    80003a1e:	0001e997          	auipc	s3,0x1e
    80003a22:	a3a98993          	addi	s3,s3,-1478 # 80021458 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003a26:	00005917          	auipc	s2,0x5
    80003a2a:	c7290913          	addi	s2,s2,-910 # 80008698 <syscalls+0x190>
    80003a2e:	85ca                	mv	a1,s2
    80003a30:	8526                	mv	a0,s1
    80003a32:	00001097          	auipc	ra,0x1
    80003a36:	e42080e7          	jalr	-446(ra) # 80004874 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003a3a:	08848493          	addi	s1,s1,136
    80003a3e:	ff3498e3          	bne	s1,s3,80003a2e <iinit+0x3e>
}
    80003a42:	70a2                	ld	ra,40(sp)
    80003a44:	7402                	ld	s0,32(sp)
    80003a46:	64e2                	ld	s1,24(sp)
    80003a48:	6942                	ld	s2,16(sp)
    80003a4a:	69a2                	ld	s3,8(sp)
    80003a4c:	6145                	addi	sp,sp,48
    80003a4e:	8082                	ret

0000000080003a50 <ialloc>:
{
    80003a50:	715d                	addi	sp,sp,-80
    80003a52:	e486                	sd	ra,72(sp)
    80003a54:	e0a2                	sd	s0,64(sp)
    80003a56:	fc26                	sd	s1,56(sp)
    80003a58:	f84a                	sd	s2,48(sp)
    80003a5a:	f44e                	sd	s3,40(sp)
    80003a5c:	f052                	sd	s4,32(sp)
    80003a5e:	ec56                	sd	s5,24(sp)
    80003a60:	e85a                	sd	s6,16(sp)
    80003a62:	e45e                	sd	s7,8(sp)
    80003a64:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003a66:	0001c717          	auipc	a4,0x1c
    80003a6a:	f2672703          	lw	a4,-218(a4) # 8001f98c <sb+0xc>
    80003a6e:	4785                	li	a5,1
    80003a70:	04e7fa63          	bgeu	a5,a4,80003ac4 <ialloc+0x74>
    80003a74:	8aaa                	mv	s5,a0
    80003a76:	8bae                	mv	s7,a1
    80003a78:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003a7a:	0001ca17          	auipc	s4,0x1c
    80003a7e:	f06a0a13          	addi	s4,s4,-250 # 8001f980 <sb>
    80003a82:	00048b1b          	sext.w	s6,s1
    80003a86:	0044d593          	srli	a1,s1,0x4
    80003a8a:	018a2783          	lw	a5,24(s4)
    80003a8e:	9dbd                	addw	a1,a1,a5
    80003a90:	8556                	mv	a0,s5
    80003a92:	00000097          	auipc	ra,0x0
    80003a96:	944080e7          	jalr	-1724(ra) # 800033d6 <bread>
    80003a9a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003a9c:	05850993          	addi	s3,a0,88
    80003aa0:	00f4f793          	andi	a5,s1,15
    80003aa4:	079a                	slli	a5,a5,0x6
    80003aa6:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003aa8:	00099783          	lh	a5,0(s3)
    80003aac:	c3a1                	beqz	a5,80003aec <ialloc+0x9c>
    brelse(bp);
    80003aae:	00000097          	auipc	ra,0x0
    80003ab2:	a58080e7          	jalr	-1448(ra) # 80003506 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003ab6:	0485                	addi	s1,s1,1
    80003ab8:	00ca2703          	lw	a4,12(s4)
    80003abc:	0004879b          	sext.w	a5,s1
    80003ac0:	fce7e1e3          	bltu	a5,a4,80003a82 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003ac4:	00005517          	auipc	a0,0x5
    80003ac8:	bdc50513          	addi	a0,a0,-1060 # 800086a0 <syscalls+0x198>
    80003acc:	ffffd097          	auipc	ra,0xffffd
    80003ad0:	abe080e7          	jalr	-1346(ra) # 8000058a <printf>
  return 0;
    80003ad4:	4501                	li	a0,0
}
    80003ad6:	60a6                	ld	ra,72(sp)
    80003ad8:	6406                	ld	s0,64(sp)
    80003ada:	74e2                	ld	s1,56(sp)
    80003adc:	7942                	ld	s2,48(sp)
    80003ade:	79a2                	ld	s3,40(sp)
    80003ae0:	7a02                	ld	s4,32(sp)
    80003ae2:	6ae2                	ld	s5,24(sp)
    80003ae4:	6b42                	ld	s6,16(sp)
    80003ae6:	6ba2                	ld	s7,8(sp)
    80003ae8:	6161                	addi	sp,sp,80
    80003aea:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003aec:	04000613          	li	a2,64
    80003af0:	4581                	li	a1,0
    80003af2:	854e                	mv	a0,s3
    80003af4:	ffffd097          	auipc	ra,0xffffd
    80003af8:	1de080e7          	jalr	478(ra) # 80000cd2 <memset>
      dip->type = type;
    80003afc:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003b00:	854a                	mv	a0,s2
    80003b02:	00001097          	auipc	ra,0x1
    80003b06:	c8e080e7          	jalr	-882(ra) # 80004790 <log_write>
      brelse(bp);
    80003b0a:	854a                	mv	a0,s2
    80003b0c:	00000097          	auipc	ra,0x0
    80003b10:	9fa080e7          	jalr	-1542(ra) # 80003506 <brelse>
      return iget(dev, inum);
    80003b14:	85da                	mv	a1,s6
    80003b16:	8556                	mv	a0,s5
    80003b18:	00000097          	auipc	ra,0x0
    80003b1c:	d9c080e7          	jalr	-612(ra) # 800038b4 <iget>
    80003b20:	bf5d                	j	80003ad6 <ialloc+0x86>

0000000080003b22 <iupdate>:
{
    80003b22:	1101                	addi	sp,sp,-32
    80003b24:	ec06                	sd	ra,24(sp)
    80003b26:	e822                	sd	s0,16(sp)
    80003b28:	e426                	sd	s1,8(sp)
    80003b2a:	e04a                	sd	s2,0(sp)
    80003b2c:	1000                	addi	s0,sp,32
    80003b2e:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003b30:	415c                	lw	a5,4(a0)
    80003b32:	0047d79b          	srliw	a5,a5,0x4
    80003b36:	0001c597          	auipc	a1,0x1c
    80003b3a:	e625a583          	lw	a1,-414(a1) # 8001f998 <sb+0x18>
    80003b3e:	9dbd                	addw	a1,a1,a5
    80003b40:	4108                	lw	a0,0(a0)
    80003b42:	00000097          	auipc	ra,0x0
    80003b46:	894080e7          	jalr	-1900(ra) # 800033d6 <bread>
    80003b4a:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003b4c:	05850793          	addi	a5,a0,88
    80003b50:	40d8                	lw	a4,4(s1)
    80003b52:	8b3d                	andi	a4,a4,15
    80003b54:	071a                	slli	a4,a4,0x6
    80003b56:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003b58:	04449703          	lh	a4,68(s1)
    80003b5c:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003b60:	04649703          	lh	a4,70(s1)
    80003b64:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003b68:	04849703          	lh	a4,72(s1)
    80003b6c:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003b70:	04a49703          	lh	a4,74(s1)
    80003b74:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003b78:	44f8                	lw	a4,76(s1)
    80003b7a:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003b7c:	03400613          	li	a2,52
    80003b80:	05048593          	addi	a1,s1,80
    80003b84:	00c78513          	addi	a0,a5,12
    80003b88:	ffffd097          	auipc	ra,0xffffd
    80003b8c:	1a6080e7          	jalr	422(ra) # 80000d2e <memmove>
  log_write(bp);
    80003b90:	854a                	mv	a0,s2
    80003b92:	00001097          	auipc	ra,0x1
    80003b96:	bfe080e7          	jalr	-1026(ra) # 80004790 <log_write>
  brelse(bp);
    80003b9a:	854a                	mv	a0,s2
    80003b9c:	00000097          	auipc	ra,0x0
    80003ba0:	96a080e7          	jalr	-1686(ra) # 80003506 <brelse>
}
    80003ba4:	60e2                	ld	ra,24(sp)
    80003ba6:	6442                	ld	s0,16(sp)
    80003ba8:	64a2                	ld	s1,8(sp)
    80003baa:	6902                	ld	s2,0(sp)
    80003bac:	6105                	addi	sp,sp,32
    80003bae:	8082                	ret

0000000080003bb0 <idup>:
{
    80003bb0:	1101                	addi	sp,sp,-32
    80003bb2:	ec06                	sd	ra,24(sp)
    80003bb4:	e822                	sd	s0,16(sp)
    80003bb6:	e426                	sd	s1,8(sp)
    80003bb8:	1000                	addi	s0,sp,32
    80003bba:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003bbc:	0001c517          	auipc	a0,0x1c
    80003bc0:	de450513          	addi	a0,a0,-540 # 8001f9a0 <itable>
    80003bc4:	ffffd097          	auipc	ra,0xffffd
    80003bc8:	012080e7          	jalr	18(ra) # 80000bd6 <acquire>
  ip->ref++;
    80003bcc:	449c                	lw	a5,8(s1)
    80003bce:	2785                	addiw	a5,a5,1
    80003bd0:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003bd2:	0001c517          	auipc	a0,0x1c
    80003bd6:	dce50513          	addi	a0,a0,-562 # 8001f9a0 <itable>
    80003bda:	ffffd097          	auipc	ra,0xffffd
    80003bde:	0b0080e7          	jalr	176(ra) # 80000c8a <release>
}
    80003be2:	8526                	mv	a0,s1
    80003be4:	60e2                	ld	ra,24(sp)
    80003be6:	6442                	ld	s0,16(sp)
    80003be8:	64a2                	ld	s1,8(sp)
    80003bea:	6105                	addi	sp,sp,32
    80003bec:	8082                	ret

0000000080003bee <ilock>:
{
    80003bee:	1101                	addi	sp,sp,-32
    80003bf0:	ec06                	sd	ra,24(sp)
    80003bf2:	e822                	sd	s0,16(sp)
    80003bf4:	e426                	sd	s1,8(sp)
    80003bf6:	e04a                	sd	s2,0(sp)
    80003bf8:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003bfa:	c115                	beqz	a0,80003c1e <ilock+0x30>
    80003bfc:	84aa                	mv	s1,a0
    80003bfe:	451c                	lw	a5,8(a0)
    80003c00:	00f05f63          	blez	a5,80003c1e <ilock+0x30>
  acquiresleep(&ip->lock);
    80003c04:	0541                	addi	a0,a0,16
    80003c06:	00001097          	auipc	ra,0x1
    80003c0a:	ca8080e7          	jalr	-856(ra) # 800048ae <acquiresleep>
  if(ip->valid == 0){
    80003c0e:	40bc                	lw	a5,64(s1)
    80003c10:	cf99                	beqz	a5,80003c2e <ilock+0x40>
}
    80003c12:	60e2                	ld	ra,24(sp)
    80003c14:	6442                	ld	s0,16(sp)
    80003c16:	64a2                	ld	s1,8(sp)
    80003c18:	6902                	ld	s2,0(sp)
    80003c1a:	6105                	addi	sp,sp,32
    80003c1c:	8082                	ret
    panic("ilock");
    80003c1e:	00005517          	auipc	a0,0x5
    80003c22:	a9a50513          	addi	a0,a0,-1382 # 800086b8 <syscalls+0x1b0>
    80003c26:	ffffd097          	auipc	ra,0xffffd
    80003c2a:	91a080e7          	jalr	-1766(ra) # 80000540 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003c2e:	40dc                	lw	a5,4(s1)
    80003c30:	0047d79b          	srliw	a5,a5,0x4
    80003c34:	0001c597          	auipc	a1,0x1c
    80003c38:	d645a583          	lw	a1,-668(a1) # 8001f998 <sb+0x18>
    80003c3c:	9dbd                	addw	a1,a1,a5
    80003c3e:	4088                	lw	a0,0(s1)
    80003c40:	fffff097          	auipc	ra,0xfffff
    80003c44:	796080e7          	jalr	1942(ra) # 800033d6 <bread>
    80003c48:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003c4a:	05850593          	addi	a1,a0,88
    80003c4e:	40dc                	lw	a5,4(s1)
    80003c50:	8bbd                	andi	a5,a5,15
    80003c52:	079a                	slli	a5,a5,0x6
    80003c54:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003c56:	00059783          	lh	a5,0(a1)
    80003c5a:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003c5e:	00259783          	lh	a5,2(a1)
    80003c62:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003c66:	00459783          	lh	a5,4(a1)
    80003c6a:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003c6e:	00659783          	lh	a5,6(a1)
    80003c72:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003c76:	459c                	lw	a5,8(a1)
    80003c78:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003c7a:	03400613          	li	a2,52
    80003c7e:	05b1                	addi	a1,a1,12
    80003c80:	05048513          	addi	a0,s1,80
    80003c84:	ffffd097          	auipc	ra,0xffffd
    80003c88:	0aa080e7          	jalr	170(ra) # 80000d2e <memmove>
    brelse(bp);
    80003c8c:	854a                	mv	a0,s2
    80003c8e:	00000097          	auipc	ra,0x0
    80003c92:	878080e7          	jalr	-1928(ra) # 80003506 <brelse>
    ip->valid = 1;
    80003c96:	4785                	li	a5,1
    80003c98:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003c9a:	04449783          	lh	a5,68(s1)
    80003c9e:	fbb5                	bnez	a5,80003c12 <ilock+0x24>
      panic("ilock: no type");
    80003ca0:	00005517          	auipc	a0,0x5
    80003ca4:	a2050513          	addi	a0,a0,-1504 # 800086c0 <syscalls+0x1b8>
    80003ca8:	ffffd097          	auipc	ra,0xffffd
    80003cac:	898080e7          	jalr	-1896(ra) # 80000540 <panic>

0000000080003cb0 <iunlock>:
{
    80003cb0:	1101                	addi	sp,sp,-32
    80003cb2:	ec06                	sd	ra,24(sp)
    80003cb4:	e822                	sd	s0,16(sp)
    80003cb6:	e426                	sd	s1,8(sp)
    80003cb8:	e04a                	sd	s2,0(sp)
    80003cba:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003cbc:	c905                	beqz	a0,80003cec <iunlock+0x3c>
    80003cbe:	84aa                	mv	s1,a0
    80003cc0:	01050913          	addi	s2,a0,16
    80003cc4:	854a                	mv	a0,s2
    80003cc6:	00001097          	auipc	ra,0x1
    80003cca:	c82080e7          	jalr	-894(ra) # 80004948 <holdingsleep>
    80003cce:	cd19                	beqz	a0,80003cec <iunlock+0x3c>
    80003cd0:	449c                	lw	a5,8(s1)
    80003cd2:	00f05d63          	blez	a5,80003cec <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003cd6:	854a                	mv	a0,s2
    80003cd8:	00001097          	auipc	ra,0x1
    80003cdc:	c2c080e7          	jalr	-980(ra) # 80004904 <releasesleep>
}
    80003ce0:	60e2                	ld	ra,24(sp)
    80003ce2:	6442                	ld	s0,16(sp)
    80003ce4:	64a2                	ld	s1,8(sp)
    80003ce6:	6902                	ld	s2,0(sp)
    80003ce8:	6105                	addi	sp,sp,32
    80003cea:	8082                	ret
    panic("iunlock");
    80003cec:	00005517          	auipc	a0,0x5
    80003cf0:	9e450513          	addi	a0,a0,-1564 # 800086d0 <syscalls+0x1c8>
    80003cf4:	ffffd097          	auipc	ra,0xffffd
    80003cf8:	84c080e7          	jalr	-1972(ra) # 80000540 <panic>

0000000080003cfc <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003cfc:	7179                	addi	sp,sp,-48
    80003cfe:	f406                	sd	ra,40(sp)
    80003d00:	f022                	sd	s0,32(sp)
    80003d02:	ec26                	sd	s1,24(sp)
    80003d04:	e84a                	sd	s2,16(sp)
    80003d06:	e44e                	sd	s3,8(sp)
    80003d08:	e052                	sd	s4,0(sp)
    80003d0a:	1800                	addi	s0,sp,48
    80003d0c:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003d0e:	05050493          	addi	s1,a0,80
    80003d12:	08050913          	addi	s2,a0,128
    80003d16:	a021                	j	80003d1e <itrunc+0x22>
    80003d18:	0491                	addi	s1,s1,4
    80003d1a:	01248d63          	beq	s1,s2,80003d34 <itrunc+0x38>
    if(ip->addrs[i]){
    80003d1e:	408c                	lw	a1,0(s1)
    80003d20:	dde5                	beqz	a1,80003d18 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003d22:	0009a503          	lw	a0,0(s3)
    80003d26:	00000097          	auipc	ra,0x0
    80003d2a:	8f6080e7          	jalr	-1802(ra) # 8000361c <bfree>
      ip->addrs[i] = 0;
    80003d2e:	0004a023          	sw	zero,0(s1)
    80003d32:	b7dd                	j	80003d18 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003d34:	0809a583          	lw	a1,128(s3)
    80003d38:	e185                	bnez	a1,80003d58 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003d3a:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003d3e:	854e                	mv	a0,s3
    80003d40:	00000097          	auipc	ra,0x0
    80003d44:	de2080e7          	jalr	-542(ra) # 80003b22 <iupdate>
}
    80003d48:	70a2                	ld	ra,40(sp)
    80003d4a:	7402                	ld	s0,32(sp)
    80003d4c:	64e2                	ld	s1,24(sp)
    80003d4e:	6942                	ld	s2,16(sp)
    80003d50:	69a2                	ld	s3,8(sp)
    80003d52:	6a02                	ld	s4,0(sp)
    80003d54:	6145                	addi	sp,sp,48
    80003d56:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003d58:	0009a503          	lw	a0,0(s3)
    80003d5c:	fffff097          	auipc	ra,0xfffff
    80003d60:	67a080e7          	jalr	1658(ra) # 800033d6 <bread>
    80003d64:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003d66:	05850493          	addi	s1,a0,88
    80003d6a:	45850913          	addi	s2,a0,1112
    80003d6e:	a021                	j	80003d76 <itrunc+0x7a>
    80003d70:	0491                	addi	s1,s1,4
    80003d72:	01248b63          	beq	s1,s2,80003d88 <itrunc+0x8c>
      if(a[j])
    80003d76:	408c                	lw	a1,0(s1)
    80003d78:	dde5                	beqz	a1,80003d70 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003d7a:	0009a503          	lw	a0,0(s3)
    80003d7e:	00000097          	auipc	ra,0x0
    80003d82:	89e080e7          	jalr	-1890(ra) # 8000361c <bfree>
    80003d86:	b7ed                	j	80003d70 <itrunc+0x74>
    brelse(bp);
    80003d88:	8552                	mv	a0,s4
    80003d8a:	fffff097          	auipc	ra,0xfffff
    80003d8e:	77c080e7          	jalr	1916(ra) # 80003506 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003d92:	0809a583          	lw	a1,128(s3)
    80003d96:	0009a503          	lw	a0,0(s3)
    80003d9a:	00000097          	auipc	ra,0x0
    80003d9e:	882080e7          	jalr	-1918(ra) # 8000361c <bfree>
    ip->addrs[NDIRECT] = 0;
    80003da2:	0809a023          	sw	zero,128(s3)
    80003da6:	bf51                	j	80003d3a <itrunc+0x3e>

0000000080003da8 <iput>:
{
    80003da8:	1101                	addi	sp,sp,-32
    80003daa:	ec06                	sd	ra,24(sp)
    80003dac:	e822                	sd	s0,16(sp)
    80003dae:	e426                	sd	s1,8(sp)
    80003db0:	e04a                	sd	s2,0(sp)
    80003db2:	1000                	addi	s0,sp,32
    80003db4:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003db6:	0001c517          	auipc	a0,0x1c
    80003dba:	bea50513          	addi	a0,a0,-1046 # 8001f9a0 <itable>
    80003dbe:	ffffd097          	auipc	ra,0xffffd
    80003dc2:	e18080e7          	jalr	-488(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003dc6:	4498                	lw	a4,8(s1)
    80003dc8:	4785                	li	a5,1
    80003dca:	02f70363          	beq	a4,a5,80003df0 <iput+0x48>
  ip->ref--;
    80003dce:	449c                	lw	a5,8(s1)
    80003dd0:	37fd                	addiw	a5,a5,-1
    80003dd2:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003dd4:	0001c517          	auipc	a0,0x1c
    80003dd8:	bcc50513          	addi	a0,a0,-1076 # 8001f9a0 <itable>
    80003ddc:	ffffd097          	auipc	ra,0xffffd
    80003de0:	eae080e7          	jalr	-338(ra) # 80000c8a <release>
}
    80003de4:	60e2                	ld	ra,24(sp)
    80003de6:	6442                	ld	s0,16(sp)
    80003de8:	64a2                	ld	s1,8(sp)
    80003dea:	6902                	ld	s2,0(sp)
    80003dec:	6105                	addi	sp,sp,32
    80003dee:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003df0:	40bc                	lw	a5,64(s1)
    80003df2:	dff1                	beqz	a5,80003dce <iput+0x26>
    80003df4:	04a49783          	lh	a5,74(s1)
    80003df8:	fbf9                	bnez	a5,80003dce <iput+0x26>
    acquiresleep(&ip->lock);
    80003dfa:	01048913          	addi	s2,s1,16
    80003dfe:	854a                	mv	a0,s2
    80003e00:	00001097          	auipc	ra,0x1
    80003e04:	aae080e7          	jalr	-1362(ra) # 800048ae <acquiresleep>
    release(&itable.lock);
    80003e08:	0001c517          	auipc	a0,0x1c
    80003e0c:	b9850513          	addi	a0,a0,-1128 # 8001f9a0 <itable>
    80003e10:	ffffd097          	auipc	ra,0xffffd
    80003e14:	e7a080e7          	jalr	-390(ra) # 80000c8a <release>
    itrunc(ip);
    80003e18:	8526                	mv	a0,s1
    80003e1a:	00000097          	auipc	ra,0x0
    80003e1e:	ee2080e7          	jalr	-286(ra) # 80003cfc <itrunc>
    ip->type = 0;
    80003e22:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003e26:	8526                	mv	a0,s1
    80003e28:	00000097          	auipc	ra,0x0
    80003e2c:	cfa080e7          	jalr	-774(ra) # 80003b22 <iupdate>
    ip->valid = 0;
    80003e30:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003e34:	854a                	mv	a0,s2
    80003e36:	00001097          	auipc	ra,0x1
    80003e3a:	ace080e7          	jalr	-1330(ra) # 80004904 <releasesleep>
    acquire(&itable.lock);
    80003e3e:	0001c517          	auipc	a0,0x1c
    80003e42:	b6250513          	addi	a0,a0,-1182 # 8001f9a0 <itable>
    80003e46:	ffffd097          	auipc	ra,0xffffd
    80003e4a:	d90080e7          	jalr	-624(ra) # 80000bd6 <acquire>
    80003e4e:	b741                	j	80003dce <iput+0x26>

0000000080003e50 <iunlockput>:
{
    80003e50:	1101                	addi	sp,sp,-32
    80003e52:	ec06                	sd	ra,24(sp)
    80003e54:	e822                	sd	s0,16(sp)
    80003e56:	e426                	sd	s1,8(sp)
    80003e58:	1000                	addi	s0,sp,32
    80003e5a:	84aa                	mv	s1,a0
  iunlock(ip);
    80003e5c:	00000097          	auipc	ra,0x0
    80003e60:	e54080e7          	jalr	-428(ra) # 80003cb0 <iunlock>
  iput(ip);
    80003e64:	8526                	mv	a0,s1
    80003e66:	00000097          	auipc	ra,0x0
    80003e6a:	f42080e7          	jalr	-190(ra) # 80003da8 <iput>
}
    80003e6e:	60e2                	ld	ra,24(sp)
    80003e70:	6442                	ld	s0,16(sp)
    80003e72:	64a2                	ld	s1,8(sp)
    80003e74:	6105                	addi	sp,sp,32
    80003e76:	8082                	ret

0000000080003e78 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003e78:	1141                	addi	sp,sp,-16
    80003e7a:	e422                	sd	s0,8(sp)
    80003e7c:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003e7e:	411c                	lw	a5,0(a0)
    80003e80:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003e82:	415c                	lw	a5,4(a0)
    80003e84:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003e86:	04451783          	lh	a5,68(a0)
    80003e8a:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003e8e:	04a51783          	lh	a5,74(a0)
    80003e92:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003e96:	04c56783          	lwu	a5,76(a0)
    80003e9a:	e99c                	sd	a5,16(a1)
}
    80003e9c:	6422                	ld	s0,8(sp)
    80003e9e:	0141                	addi	sp,sp,16
    80003ea0:	8082                	ret

0000000080003ea2 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003ea2:	457c                	lw	a5,76(a0)
    80003ea4:	0ed7e963          	bltu	a5,a3,80003f96 <readi+0xf4>
{
    80003ea8:	7159                	addi	sp,sp,-112
    80003eaa:	f486                	sd	ra,104(sp)
    80003eac:	f0a2                	sd	s0,96(sp)
    80003eae:	eca6                	sd	s1,88(sp)
    80003eb0:	e8ca                	sd	s2,80(sp)
    80003eb2:	e4ce                	sd	s3,72(sp)
    80003eb4:	e0d2                	sd	s4,64(sp)
    80003eb6:	fc56                	sd	s5,56(sp)
    80003eb8:	f85a                	sd	s6,48(sp)
    80003eba:	f45e                	sd	s7,40(sp)
    80003ebc:	f062                	sd	s8,32(sp)
    80003ebe:	ec66                	sd	s9,24(sp)
    80003ec0:	e86a                	sd	s10,16(sp)
    80003ec2:	e46e                	sd	s11,8(sp)
    80003ec4:	1880                	addi	s0,sp,112
    80003ec6:	8b2a                	mv	s6,a0
    80003ec8:	8bae                	mv	s7,a1
    80003eca:	8a32                	mv	s4,a2
    80003ecc:	84b6                	mv	s1,a3
    80003ece:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003ed0:	9f35                	addw	a4,a4,a3
    return 0;
    80003ed2:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003ed4:	0ad76063          	bltu	a4,a3,80003f74 <readi+0xd2>
  if(off + n > ip->size)
    80003ed8:	00e7f463          	bgeu	a5,a4,80003ee0 <readi+0x3e>
    n = ip->size - off;
    80003edc:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ee0:	0a0a8963          	beqz	s5,80003f92 <readi+0xf0>
    80003ee4:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ee6:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003eea:	5c7d                	li	s8,-1
    80003eec:	a82d                	j	80003f26 <readi+0x84>
    80003eee:	020d1d93          	slli	s11,s10,0x20
    80003ef2:	020ddd93          	srli	s11,s11,0x20
    80003ef6:	05890613          	addi	a2,s2,88
    80003efa:	86ee                	mv	a3,s11
    80003efc:	963a                	add	a2,a2,a4
    80003efe:	85d2                	mv	a1,s4
    80003f00:	855e                	mv	a0,s7
    80003f02:	ffffe097          	auipc	ra,0xffffe
    80003f06:	622080e7          	jalr	1570(ra) # 80002524 <either_copyout>
    80003f0a:	05850d63          	beq	a0,s8,80003f64 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003f0e:	854a                	mv	a0,s2
    80003f10:	fffff097          	auipc	ra,0xfffff
    80003f14:	5f6080e7          	jalr	1526(ra) # 80003506 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f18:	013d09bb          	addw	s3,s10,s3
    80003f1c:	009d04bb          	addw	s1,s10,s1
    80003f20:	9a6e                	add	s4,s4,s11
    80003f22:	0559f763          	bgeu	s3,s5,80003f70 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003f26:	00a4d59b          	srliw	a1,s1,0xa
    80003f2a:	855a                	mv	a0,s6
    80003f2c:	00000097          	auipc	ra,0x0
    80003f30:	89e080e7          	jalr	-1890(ra) # 800037ca <bmap>
    80003f34:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003f38:	cd85                	beqz	a1,80003f70 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003f3a:	000b2503          	lw	a0,0(s6)
    80003f3e:	fffff097          	auipc	ra,0xfffff
    80003f42:	498080e7          	jalr	1176(ra) # 800033d6 <bread>
    80003f46:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f48:	3ff4f713          	andi	a4,s1,1023
    80003f4c:	40ec87bb          	subw	a5,s9,a4
    80003f50:	413a86bb          	subw	a3,s5,s3
    80003f54:	8d3e                	mv	s10,a5
    80003f56:	2781                	sext.w	a5,a5
    80003f58:	0006861b          	sext.w	a2,a3
    80003f5c:	f8f679e3          	bgeu	a2,a5,80003eee <readi+0x4c>
    80003f60:	8d36                	mv	s10,a3
    80003f62:	b771                	j	80003eee <readi+0x4c>
      brelse(bp);
    80003f64:	854a                	mv	a0,s2
    80003f66:	fffff097          	auipc	ra,0xfffff
    80003f6a:	5a0080e7          	jalr	1440(ra) # 80003506 <brelse>
      tot = -1;
    80003f6e:	59fd                	li	s3,-1
  }
  return tot;
    80003f70:	0009851b          	sext.w	a0,s3
}
    80003f74:	70a6                	ld	ra,104(sp)
    80003f76:	7406                	ld	s0,96(sp)
    80003f78:	64e6                	ld	s1,88(sp)
    80003f7a:	6946                	ld	s2,80(sp)
    80003f7c:	69a6                	ld	s3,72(sp)
    80003f7e:	6a06                	ld	s4,64(sp)
    80003f80:	7ae2                	ld	s5,56(sp)
    80003f82:	7b42                	ld	s6,48(sp)
    80003f84:	7ba2                	ld	s7,40(sp)
    80003f86:	7c02                	ld	s8,32(sp)
    80003f88:	6ce2                	ld	s9,24(sp)
    80003f8a:	6d42                	ld	s10,16(sp)
    80003f8c:	6da2                	ld	s11,8(sp)
    80003f8e:	6165                	addi	sp,sp,112
    80003f90:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f92:	89d6                	mv	s3,s5
    80003f94:	bff1                	j	80003f70 <readi+0xce>
    return 0;
    80003f96:	4501                	li	a0,0
}
    80003f98:	8082                	ret

0000000080003f9a <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003f9a:	457c                	lw	a5,76(a0)
    80003f9c:	10d7e863          	bltu	a5,a3,800040ac <writei+0x112>
{
    80003fa0:	7159                	addi	sp,sp,-112
    80003fa2:	f486                	sd	ra,104(sp)
    80003fa4:	f0a2                	sd	s0,96(sp)
    80003fa6:	eca6                	sd	s1,88(sp)
    80003fa8:	e8ca                	sd	s2,80(sp)
    80003faa:	e4ce                	sd	s3,72(sp)
    80003fac:	e0d2                	sd	s4,64(sp)
    80003fae:	fc56                	sd	s5,56(sp)
    80003fb0:	f85a                	sd	s6,48(sp)
    80003fb2:	f45e                	sd	s7,40(sp)
    80003fb4:	f062                	sd	s8,32(sp)
    80003fb6:	ec66                	sd	s9,24(sp)
    80003fb8:	e86a                	sd	s10,16(sp)
    80003fba:	e46e                	sd	s11,8(sp)
    80003fbc:	1880                	addi	s0,sp,112
    80003fbe:	8aaa                	mv	s5,a0
    80003fc0:	8bae                	mv	s7,a1
    80003fc2:	8a32                	mv	s4,a2
    80003fc4:	8936                	mv	s2,a3
    80003fc6:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003fc8:	00e687bb          	addw	a5,a3,a4
    80003fcc:	0ed7e263          	bltu	a5,a3,800040b0 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003fd0:	00043737          	lui	a4,0x43
    80003fd4:	0ef76063          	bltu	a4,a5,800040b4 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003fd8:	0c0b0863          	beqz	s6,800040a8 <writei+0x10e>
    80003fdc:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003fde:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003fe2:	5c7d                	li	s8,-1
    80003fe4:	a091                	j	80004028 <writei+0x8e>
    80003fe6:	020d1d93          	slli	s11,s10,0x20
    80003fea:	020ddd93          	srli	s11,s11,0x20
    80003fee:	05848513          	addi	a0,s1,88
    80003ff2:	86ee                	mv	a3,s11
    80003ff4:	8652                	mv	a2,s4
    80003ff6:	85de                	mv	a1,s7
    80003ff8:	953a                	add	a0,a0,a4
    80003ffa:	ffffe097          	auipc	ra,0xffffe
    80003ffe:	580080e7          	jalr	1408(ra) # 8000257a <either_copyin>
    80004002:	07850263          	beq	a0,s8,80004066 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004006:	8526                	mv	a0,s1
    80004008:	00000097          	auipc	ra,0x0
    8000400c:	788080e7          	jalr	1928(ra) # 80004790 <log_write>
    brelse(bp);
    80004010:	8526                	mv	a0,s1
    80004012:	fffff097          	auipc	ra,0xfffff
    80004016:	4f4080e7          	jalr	1268(ra) # 80003506 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000401a:	013d09bb          	addw	s3,s10,s3
    8000401e:	012d093b          	addw	s2,s10,s2
    80004022:	9a6e                	add	s4,s4,s11
    80004024:	0569f663          	bgeu	s3,s6,80004070 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80004028:	00a9559b          	srliw	a1,s2,0xa
    8000402c:	8556                	mv	a0,s5
    8000402e:	fffff097          	auipc	ra,0xfffff
    80004032:	79c080e7          	jalr	1948(ra) # 800037ca <bmap>
    80004036:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000403a:	c99d                	beqz	a1,80004070 <writei+0xd6>
    bp = bread(ip->dev, addr);
    8000403c:	000aa503          	lw	a0,0(s5)
    80004040:	fffff097          	auipc	ra,0xfffff
    80004044:	396080e7          	jalr	918(ra) # 800033d6 <bread>
    80004048:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000404a:	3ff97713          	andi	a4,s2,1023
    8000404e:	40ec87bb          	subw	a5,s9,a4
    80004052:	413b06bb          	subw	a3,s6,s3
    80004056:	8d3e                	mv	s10,a5
    80004058:	2781                	sext.w	a5,a5
    8000405a:	0006861b          	sext.w	a2,a3
    8000405e:	f8f674e3          	bgeu	a2,a5,80003fe6 <writei+0x4c>
    80004062:	8d36                	mv	s10,a3
    80004064:	b749                	j	80003fe6 <writei+0x4c>
      brelse(bp);
    80004066:	8526                	mv	a0,s1
    80004068:	fffff097          	auipc	ra,0xfffff
    8000406c:	49e080e7          	jalr	1182(ra) # 80003506 <brelse>
  }

  if(off > ip->size)
    80004070:	04caa783          	lw	a5,76(s5)
    80004074:	0127f463          	bgeu	a5,s2,8000407c <writei+0xe2>
    ip->size = off;
    80004078:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000407c:	8556                	mv	a0,s5
    8000407e:	00000097          	auipc	ra,0x0
    80004082:	aa4080e7          	jalr	-1372(ra) # 80003b22 <iupdate>

  return tot;
    80004086:	0009851b          	sext.w	a0,s3
}
    8000408a:	70a6                	ld	ra,104(sp)
    8000408c:	7406                	ld	s0,96(sp)
    8000408e:	64e6                	ld	s1,88(sp)
    80004090:	6946                	ld	s2,80(sp)
    80004092:	69a6                	ld	s3,72(sp)
    80004094:	6a06                	ld	s4,64(sp)
    80004096:	7ae2                	ld	s5,56(sp)
    80004098:	7b42                	ld	s6,48(sp)
    8000409a:	7ba2                	ld	s7,40(sp)
    8000409c:	7c02                	ld	s8,32(sp)
    8000409e:	6ce2                	ld	s9,24(sp)
    800040a0:	6d42                	ld	s10,16(sp)
    800040a2:	6da2                	ld	s11,8(sp)
    800040a4:	6165                	addi	sp,sp,112
    800040a6:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800040a8:	89da                	mv	s3,s6
    800040aa:	bfc9                	j	8000407c <writei+0xe2>
    return -1;
    800040ac:	557d                	li	a0,-1
}
    800040ae:	8082                	ret
    return -1;
    800040b0:	557d                	li	a0,-1
    800040b2:	bfe1                	j	8000408a <writei+0xf0>
    return -1;
    800040b4:	557d                	li	a0,-1
    800040b6:	bfd1                	j	8000408a <writei+0xf0>

00000000800040b8 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800040b8:	1141                	addi	sp,sp,-16
    800040ba:	e406                	sd	ra,8(sp)
    800040bc:	e022                	sd	s0,0(sp)
    800040be:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800040c0:	4639                	li	a2,14
    800040c2:	ffffd097          	auipc	ra,0xffffd
    800040c6:	ce0080e7          	jalr	-800(ra) # 80000da2 <strncmp>
}
    800040ca:	60a2                	ld	ra,8(sp)
    800040cc:	6402                	ld	s0,0(sp)
    800040ce:	0141                	addi	sp,sp,16
    800040d0:	8082                	ret

00000000800040d2 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800040d2:	7139                	addi	sp,sp,-64
    800040d4:	fc06                	sd	ra,56(sp)
    800040d6:	f822                	sd	s0,48(sp)
    800040d8:	f426                	sd	s1,40(sp)
    800040da:	f04a                	sd	s2,32(sp)
    800040dc:	ec4e                	sd	s3,24(sp)
    800040de:	e852                	sd	s4,16(sp)
    800040e0:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800040e2:	04451703          	lh	a4,68(a0)
    800040e6:	4785                	li	a5,1
    800040e8:	00f71a63          	bne	a4,a5,800040fc <dirlookup+0x2a>
    800040ec:	892a                	mv	s2,a0
    800040ee:	89ae                	mv	s3,a1
    800040f0:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800040f2:	457c                	lw	a5,76(a0)
    800040f4:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800040f6:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040f8:	e79d                	bnez	a5,80004126 <dirlookup+0x54>
    800040fa:	a8a5                	j	80004172 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800040fc:	00004517          	auipc	a0,0x4
    80004100:	5dc50513          	addi	a0,a0,1500 # 800086d8 <syscalls+0x1d0>
    80004104:	ffffc097          	auipc	ra,0xffffc
    80004108:	43c080e7          	jalr	1084(ra) # 80000540 <panic>
      panic("dirlookup read");
    8000410c:	00004517          	auipc	a0,0x4
    80004110:	5e450513          	addi	a0,a0,1508 # 800086f0 <syscalls+0x1e8>
    80004114:	ffffc097          	auipc	ra,0xffffc
    80004118:	42c080e7          	jalr	1068(ra) # 80000540 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000411c:	24c1                	addiw	s1,s1,16
    8000411e:	04c92783          	lw	a5,76(s2)
    80004122:	04f4f763          	bgeu	s1,a5,80004170 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004126:	4741                	li	a4,16
    80004128:	86a6                	mv	a3,s1
    8000412a:	fc040613          	addi	a2,s0,-64
    8000412e:	4581                	li	a1,0
    80004130:	854a                	mv	a0,s2
    80004132:	00000097          	auipc	ra,0x0
    80004136:	d70080e7          	jalr	-656(ra) # 80003ea2 <readi>
    8000413a:	47c1                	li	a5,16
    8000413c:	fcf518e3          	bne	a0,a5,8000410c <dirlookup+0x3a>
    if(de.inum == 0)
    80004140:	fc045783          	lhu	a5,-64(s0)
    80004144:	dfe1                	beqz	a5,8000411c <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004146:	fc240593          	addi	a1,s0,-62
    8000414a:	854e                	mv	a0,s3
    8000414c:	00000097          	auipc	ra,0x0
    80004150:	f6c080e7          	jalr	-148(ra) # 800040b8 <namecmp>
    80004154:	f561                	bnez	a0,8000411c <dirlookup+0x4a>
      if(poff)
    80004156:	000a0463          	beqz	s4,8000415e <dirlookup+0x8c>
        *poff = off;
    8000415a:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000415e:	fc045583          	lhu	a1,-64(s0)
    80004162:	00092503          	lw	a0,0(s2)
    80004166:	fffff097          	auipc	ra,0xfffff
    8000416a:	74e080e7          	jalr	1870(ra) # 800038b4 <iget>
    8000416e:	a011                	j	80004172 <dirlookup+0xa0>
  return 0;
    80004170:	4501                	li	a0,0
}
    80004172:	70e2                	ld	ra,56(sp)
    80004174:	7442                	ld	s0,48(sp)
    80004176:	74a2                	ld	s1,40(sp)
    80004178:	7902                	ld	s2,32(sp)
    8000417a:	69e2                	ld	s3,24(sp)
    8000417c:	6a42                	ld	s4,16(sp)
    8000417e:	6121                	addi	sp,sp,64
    80004180:	8082                	ret

0000000080004182 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004182:	711d                	addi	sp,sp,-96
    80004184:	ec86                	sd	ra,88(sp)
    80004186:	e8a2                	sd	s0,80(sp)
    80004188:	e4a6                	sd	s1,72(sp)
    8000418a:	e0ca                	sd	s2,64(sp)
    8000418c:	fc4e                	sd	s3,56(sp)
    8000418e:	f852                	sd	s4,48(sp)
    80004190:	f456                	sd	s5,40(sp)
    80004192:	f05a                	sd	s6,32(sp)
    80004194:	ec5e                	sd	s7,24(sp)
    80004196:	e862                	sd	s8,16(sp)
    80004198:	e466                	sd	s9,8(sp)
    8000419a:	e06a                	sd	s10,0(sp)
    8000419c:	1080                	addi	s0,sp,96
    8000419e:	84aa                	mv	s1,a0
    800041a0:	8b2e                	mv	s6,a1
    800041a2:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800041a4:	00054703          	lbu	a4,0(a0)
    800041a8:	02f00793          	li	a5,47
    800041ac:	02f70363          	beq	a4,a5,800041d2 <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800041b0:	ffffe097          	auipc	ra,0xffffe
    800041b4:	814080e7          	jalr	-2028(ra) # 800019c4 <myproc>
    800041b8:	15053503          	ld	a0,336(a0)
    800041bc:	00000097          	auipc	ra,0x0
    800041c0:	9f4080e7          	jalr	-1548(ra) # 80003bb0 <idup>
    800041c4:	8a2a                	mv	s4,a0
  while(*path == '/')
    800041c6:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    800041ca:	4cb5                	li	s9,13
  len = path - s;
    800041cc:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800041ce:	4c05                	li	s8,1
    800041d0:	a87d                	j	8000428e <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    800041d2:	4585                	li	a1,1
    800041d4:	4505                	li	a0,1
    800041d6:	fffff097          	auipc	ra,0xfffff
    800041da:	6de080e7          	jalr	1758(ra) # 800038b4 <iget>
    800041de:	8a2a                	mv	s4,a0
    800041e0:	b7dd                	j	800041c6 <namex+0x44>
      iunlockput(ip);
    800041e2:	8552                	mv	a0,s4
    800041e4:	00000097          	auipc	ra,0x0
    800041e8:	c6c080e7          	jalr	-916(ra) # 80003e50 <iunlockput>
      return 0;
    800041ec:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800041ee:	8552                	mv	a0,s4
    800041f0:	60e6                	ld	ra,88(sp)
    800041f2:	6446                	ld	s0,80(sp)
    800041f4:	64a6                	ld	s1,72(sp)
    800041f6:	6906                	ld	s2,64(sp)
    800041f8:	79e2                	ld	s3,56(sp)
    800041fa:	7a42                	ld	s4,48(sp)
    800041fc:	7aa2                	ld	s5,40(sp)
    800041fe:	7b02                	ld	s6,32(sp)
    80004200:	6be2                	ld	s7,24(sp)
    80004202:	6c42                	ld	s8,16(sp)
    80004204:	6ca2                	ld	s9,8(sp)
    80004206:	6d02                	ld	s10,0(sp)
    80004208:	6125                	addi	sp,sp,96
    8000420a:	8082                	ret
      iunlock(ip);
    8000420c:	8552                	mv	a0,s4
    8000420e:	00000097          	auipc	ra,0x0
    80004212:	aa2080e7          	jalr	-1374(ra) # 80003cb0 <iunlock>
      return ip;
    80004216:	bfe1                	j	800041ee <namex+0x6c>
      iunlockput(ip);
    80004218:	8552                	mv	a0,s4
    8000421a:	00000097          	auipc	ra,0x0
    8000421e:	c36080e7          	jalr	-970(ra) # 80003e50 <iunlockput>
      return 0;
    80004222:	8a4e                	mv	s4,s3
    80004224:	b7e9                	j	800041ee <namex+0x6c>
  len = path - s;
    80004226:	40998633          	sub	a2,s3,s1
    8000422a:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    8000422e:	09acd863          	bge	s9,s10,800042be <namex+0x13c>
    memmove(name, s, DIRSIZ);
    80004232:	4639                	li	a2,14
    80004234:	85a6                	mv	a1,s1
    80004236:	8556                	mv	a0,s5
    80004238:	ffffd097          	auipc	ra,0xffffd
    8000423c:	af6080e7          	jalr	-1290(ra) # 80000d2e <memmove>
    80004240:	84ce                	mv	s1,s3
  while(*path == '/')
    80004242:	0004c783          	lbu	a5,0(s1)
    80004246:	01279763          	bne	a5,s2,80004254 <namex+0xd2>
    path++;
    8000424a:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000424c:	0004c783          	lbu	a5,0(s1)
    80004250:	ff278de3          	beq	a5,s2,8000424a <namex+0xc8>
    ilock(ip);
    80004254:	8552                	mv	a0,s4
    80004256:	00000097          	auipc	ra,0x0
    8000425a:	998080e7          	jalr	-1640(ra) # 80003bee <ilock>
    if(ip->type != T_DIR){
    8000425e:	044a1783          	lh	a5,68(s4)
    80004262:	f98790e3          	bne	a5,s8,800041e2 <namex+0x60>
    if(nameiparent && *path == '\0'){
    80004266:	000b0563          	beqz	s6,80004270 <namex+0xee>
    8000426a:	0004c783          	lbu	a5,0(s1)
    8000426e:	dfd9                	beqz	a5,8000420c <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004270:	865e                	mv	a2,s7
    80004272:	85d6                	mv	a1,s5
    80004274:	8552                	mv	a0,s4
    80004276:	00000097          	auipc	ra,0x0
    8000427a:	e5c080e7          	jalr	-420(ra) # 800040d2 <dirlookup>
    8000427e:	89aa                	mv	s3,a0
    80004280:	dd41                	beqz	a0,80004218 <namex+0x96>
    iunlockput(ip);
    80004282:	8552                	mv	a0,s4
    80004284:	00000097          	auipc	ra,0x0
    80004288:	bcc080e7          	jalr	-1076(ra) # 80003e50 <iunlockput>
    ip = next;
    8000428c:	8a4e                	mv	s4,s3
  while(*path == '/')
    8000428e:	0004c783          	lbu	a5,0(s1)
    80004292:	01279763          	bne	a5,s2,800042a0 <namex+0x11e>
    path++;
    80004296:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004298:	0004c783          	lbu	a5,0(s1)
    8000429c:	ff278de3          	beq	a5,s2,80004296 <namex+0x114>
  if(*path == 0)
    800042a0:	cb9d                	beqz	a5,800042d6 <namex+0x154>
  while(*path != '/' && *path != 0)
    800042a2:	0004c783          	lbu	a5,0(s1)
    800042a6:	89a6                	mv	s3,s1
  len = path - s;
    800042a8:	8d5e                	mv	s10,s7
    800042aa:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    800042ac:	01278963          	beq	a5,s2,800042be <namex+0x13c>
    800042b0:	dbbd                	beqz	a5,80004226 <namex+0xa4>
    path++;
    800042b2:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    800042b4:	0009c783          	lbu	a5,0(s3)
    800042b8:	ff279ce3          	bne	a5,s2,800042b0 <namex+0x12e>
    800042bc:	b7ad                	j	80004226 <namex+0xa4>
    memmove(name, s, len);
    800042be:	2601                	sext.w	a2,a2
    800042c0:	85a6                	mv	a1,s1
    800042c2:	8556                	mv	a0,s5
    800042c4:	ffffd097          	auipc	ra,0xffffd
    800042c8:	a6a080e7          	jalr	-1430(ra) # 80000d2e <memmove>
    name[len] = 0;
    800042cc:	9d56                	add	s10,s10,s5
    800042ce:	000d0023          	sb	zero,0(s10)
    800042d2:	84ce                	mv	s1,s3
    800042d4:	b7bd                	j	80004242 <namex+0xc0>
  if(nameiparent){
    800042d6:	f00b0ce3          	beqz	s6,800041ee <namex+0x6c>
    iput(ip);
    800042da:	8552                	mv	a0,s4
    800042dc:	00000097          	auipc	ra,0x0
    800042e0:	acc080e7          	jalr	-1332(ra) # 80003da8 <iput>
    return 0;
    800042e4:	4a01                	li	s4,0
    800042e6:	b721                	j	800041ee <namex+0x6c>

00000000800042e8 <dirlink>:
{
    800042e8:	7139                	addi	sp,sp,-64
    800042ea:	fc06                	sd	ra,56(sp)
    800042ec:	f822                	sd	s0,48(sp)
    800042ee:	f426                	sd	s1,40(sp)
    800042f0:	f04a                	sd	s2,32(sp)
    800042f2:	ec4e                	sd	s3,24(sp)
    800042f4:	e852                	sd	s4,16(sp)
    800042f6:	0080                	addi	s0,sp,64
    800042f8:	892a                	mv	s2,a0
    800042fa:	8a2e                	mv	s4,a1
    800042fc:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800042fe:	4601                	li	a2,0
    80004300:	00000097          	auipc	ra,0x0
    80004304:	dd2080e7          	jalr	-558(ra) # 800040d2 <dirlookup>
    80004308:	e93d                	bnez	a0,8000437e <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000430a:	04c92483          	lw	s1,76(s2)
    8000430e:	c49d                	beqz	s1,8000433c <dirlink+0x54>
    80004310:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004312:	4741                	li	a4,16
    80004314:	86a6                	mv	a3,s1
    80004316:	fc040613          	addi	a2,s0,-64
    8000431a:	4581                	li	a1,0
    8000431c:	854a                	mv	a0,s2
    8000431e:	00000097          	auipc	ra,0x0
    80004322:	b84080e7          	jalr	-1148(ra) # 80003ea2 <readi>
    80004326:	47c1                	li	a5,16
    80004328:	06f51163          	bne	a0,a5,8000438a <dirlink+0xa2>
    if(de.inum == 0)
    8000432c:	fc045783          	lhu	a5,-64(s0)
    80004330:	c791                	beqz	a5,8000433c <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004332:	24c1                	addiw	s1,s1,16
    80004334:	04c92783          	lw	a5,76(s2)
    80004338:	fcf4ede3          	bltu	s1,a5,80004312 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000433c:	4639                	li	a2,14
    8000433e:	85d2                	mv	a1,s4
    80004340:	fc240513          	addi	a0,s0,-62
    80004344:	ffffd097          	auipc	ra,0xffffd
    80004348:	a9a080e7          	jalr	-1382(ra) # 80000dde <strncpy>
  de.inum = inum;
    8000434c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004350:	4741                	li	a4,16
    80004352:	86a6                	mv	a3,s1
    80004354:	fc040613          	addi	a2,s0,-64
    80004358:	4581                	li	a1,0
    8000435a:	854a                	mv	a0,s2
    8000435c:	00000097          	auipc	ra,0x0
    80004360:	c3e080e7          	jalr	-962(ra) # 80003f9a <writei>
    80004364:	1541                	addi	a0,a0,-16
    80004366:	00a03533          	snez	a0,a0
    8000436a:	40a00533          	neg	a0,a0
}
    8000436e:	70e2                	ld	ra,56(sp)
    80004370:	7442                	ld	s0,48(sp)
    80004372:	74a2                	ld	s1,40(sp)
    80004374:	7902                	ld	s2,32(sp)
    80004376:	69e2                	ld	s3,24(sp)
    80004378:	6a42                	ld	s4,16(sp)
    8000437a:	6121                	addi	sp,sp,64
    8000437c:	8082                	ret
    iput(ip);
    8000437e:	00000097          	auipc	ra,0x0
    80004382:	a2a080e7          	jalr	-1494(ra) # 80003da8 <iput>
    return -1;
    80004386:	557d                	li	a0,-1
    80004388:	b7dd                	j	8000436e <dirlink+0x86>
      panic("dirlink read");
    8000438a:	00004517          	auipc	a0,0x4
    8000438e:	37650513          	addi	a0,a0,886 # 80008700 <syscalls+0x1f8>
    80004392:	ffffc097          	auipc	ra,0xffffc
    80004396:	1ae080e7          	jalr	430(ra) # 80000540 <panic>

000000008000439a <namei>:

struct inode*
namei(char *path)
{
    8000439a:	1101                	addi	sp,sp,-32
    8000439c:	ec06                	sd	ra,24(sp)
    8000439e:	e822                	sd	s0,16(sp)
    800043a0:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800043a2:	fe040613          	addi	a2,s0,-32
    800043a6:	4581                	li	a1,0
    800043a8:	00000097          	auipc	ra,0x0
    800043ac:	dda080e7          	jalr	-550(ra) # 80004182 <namex>
}
    800043b0:	60e2                	ld	ra,24(sp)
    800043b2:	6442                	ld	s0,16(sp)
    800043b4:	6105                	addi	sp,sp,32
    800043b6:	8082                	ret

00000000800043b8 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800043b8:	1141                	addi	sp,sp,-16
    800043ba:	e406                	sd	ra,8(sp)
    800043bc:	e022                	sd	s0,0(sp)
    800043be:	0800                	addi	s0,sp,16
    800043c0:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800043c2:	4585                	li	a1,1
    800043c4:	00000097          	auipc	ra,0x0
    800043c8:	dbe080e7          	jalr	-578(ra) # 80004182 <namex>
}
    800043cc:	60a2                	ld	ra,8(sp)
    800043ce:	6402                	ld	s0,0(sp)
    800043d0:	0141                	addi	sp,sp,16
    800043d2:	8082                	ret

00000000800043d4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800043d4:	1101                	addi	sp,sp,-32
    800043d6:	ec06                	sd	ra,24(sp)
    800043d8:	e822                	sd	s0,16(sp)
    800043da:	e426                	sd	s1,8(sp)
    800043dc:	e04a                	sd	s2,0(sp)
    800043de:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800043e0:	0001d917          	auipc	s2,0x1d
    800043e4:	06890913          	addi	s2,s2,104 # 80021448 <log>
    800043e8:	01892583          	lw	a1,24(s2)
    800043ec:	02892503          	lw	a0,40(s2)
    800043f0:	fffff097          	auipc	ra,0xfffff
    800043f4:	fe6080e7          	jalr	-26(ra) # 800033d6 <bread>
    800043f8:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800043fa:	02c92683          	lw	a3,44(s2)
    800043fe:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004400:	02d05863          	blez	a3,80004430 <write_head+0x5c>
    80004404:	0001d797          	auipc	a5,0x1d
    80004408:	07478793          	addi	a5,a5,116 # 80021478 <log+0x30>
    8000440c:	05c50713          	addi	a4,a0,92
    80004410:	36fd                	addiw	a3,a3,-1
    80004412:	02069613          	slli	a2,a3,0x20
    80004416:	01e65693          	srli	a3,a2,0x1e
    8000441a:	0001d617          	auipc	a2,0x1d
    8000441e:	06260613          	addi	a2,a2,98 # 8002147c <log+0x34>
    80004422:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004424:	4390                	lw	a2,0(a5)
    80004426:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004428:	0791                	addi	a5,a5,4
    8000442a:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    8000442c:	fed79ce3          	bne	a5,a3,80004424 <write_head+0x50>
  }
  bwrite(buf);
    80004430:	8526                	mv	a0,s1
    80004432:	fffff097          	auipc	ra,0xfffff
    80004436:	096080e7          	jalr	150(ra) # 800034c8 <bwrite>
  brelse(buf);
    8000443a:	8526                	mv	a0,s1
    8000443c:	fffff097          	auipc	ra,0xfffff
    80004440:	0ca080e7          	jalr	202(ra) # 80003506 <brelse>
}
    80004444:	60e2                	ld	ra,24(sp)
    80004446:	6442                	ld	s0,16(sp)
    80004448:	64a2                	ld	s1,8(sp)
    8000444a:	6902                	ld	s2,0(sp)
    8000444c:	6105                	addi	sp,sp,32
    8000444e:	8082                	ret

0000000080004450 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004450:	0001d797          	auipc	a5,0x1d
    80004454:	0247a783          	lw	a5,36(a5) # 80021474 <log+0x2c>
    80004458:	0af05d63          	blez	a5,80004512 <install_trans+0xc2>
{
    8000445c:	7139                	addi	sp,sp,-64
    8000445e:	fc06                	sd	ra,56(sp)
    80004460:	f822                	sd	s0,48(sp)
    80004462:	f426                	sd	s1,40(sp)
    80004464:	f04a                	sd	s2,32(sp)
    80004466:	ec4e                	sd	s3,24(sp)
    80004468:	e852                	sd	s4,16(sp)
    8000446a:	e456                	sd	s5,8(sp)
    8000446c:	e05a                	sd	s6,0(sp)
    8000446e:	0080                	addi	s0,sp,64
    80004470:	8b2a                	mv	s6,a0
    80004472:	0001da97          	auipc	s5,0x1d
    80004476:	006a8a93          	addi	s5,s5,6 # 80021478 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000447a:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000447c:	0001d997          	auipc	s3,0x1d
    80004480:	fcc98993          	addi	s3,s3,-52 # 80021448 <log>
    80004484:	a00d                	j	800044a6 <install_trans+0x56>
    brelse(lbuf);
    80004486:	854a                	mv	a0,s2
    80004488:	fffff097          	auipc	ra,0xfffff
    8000448c:	07e080e7          	jalr	126(ra) # 80003506 <brelse>
    brelse(dbuf);
    80004490:	8526                	mv	a0,s1
    80004492:	fffff097          	auipc	ra,0xfffff
    80004496:	074080e7          	jalr	116(ra) # 80003506 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000449a:	2a05                	addiw	s4,s4,1
    8000449c:	0a91                	addi	s5,s5,4
    8000449e:	02c9a783          	lw	a5,44(s3)
    800044a2:	04fa5e63          	bge	s4,a5,800044fe <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800044a6:	0189a583          	lw	a1,24(s3)
    800044aa:	014585bb          	addw	a1,a1,s4
    800044ae:	2585                	addiw	a1,a1,1
    800044b0:	0289a503          	lw	a0,40(s3)
    800044b4:	fffff097          	auipc	ra,0xfffff
    800044b8:	f22080e7          	jalr	-222(ra) # 800033d6 <bread>
    800044bc:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800044be:	000aa583          	lw	a1,0(s5)
    800044c2:	0289a503          	lw	a0,40(s3)
    800044c6:	fffff097          	auipc	ra,0xfffff
    800044ca:	f10080e7          	jalr	-240(ra) # 800033d6 <bread>
    800044ce:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800044d0:	40000613          	li	a2,1024
    800044d4:	05890593          	addi	a1,s2,88
    800044d8:	05850513          	addi	a0,a0,88
    800044dc:	ffffd097          	auipc	ra,0xffffd
    800044e0:	852080e7          	jalr	-1966(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    800044e4:	8526                	mv	a0,s1
    800044e6:	fffff097          	auipc	ra,0xfffff
    800044ea:	fe2080e7          	jalr	-30(ra) # 800034c8 <bwrite>
    if(recovering == 0)
    800044ee:	f80b1ce3          	bnez	s6,80004486 <install_trans+0x36>
      bunpin(dbuf);
    800044f2:	8526                	mv	a0,s1
    800044f4:	fffff097          	auipc	ra,0xfffff
    800044f8:	0ec080e7          	jalr	236(ra) # 800035e0 <bunpin>
    800044fc:	b769                	j	80004486 <install_trans+0x36>
}
    800044fe:	70e2                	ld	ra,56(sp)
    80004500:	7442                	ld	s0,48(sp)
    80004502:	74a2                	ld	s1,40(sp)
    80004504:	7902                	ld	s2,32(sp)
    80004506:	69e2                	ld	s3,24(sp)
    80004508:	6a42                	ld	s4,16(sp)
    8000450a:	6aa2                	ld	s5,8(sp)
    8000450c:	6b02                	ld	s6,0(sp)
    8000450e:	6121                	addi	sp,sp,64
    80004510:	8082                	ret
    80004512:	8082                	ret

0000000080004514 <initlog>:
{
    80004514:	7179                	addi	sp,sp,-48
    80004516:	f406                	sd	ra,40(sp)
    80004518:	f022                	sd	s0,32(sp)
    8000451a:	ec26                	sd	s1,24(sp)
    8000451c:	e84a                	sd	s2,16(sp)
    8000451e:	e44e                	sd	s3,8(sp)
    80004520:	1800                	addi	s0,sp,48
    80004522:	892a                	mv	s2,a0
    80004524:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004526:	0001d497          	auipc	s1,0x1d
    8000452a:	f2248493          	addi	s1,s1,-222 # 80021448 <log>
    8000452e:	00004597          	auipc	a1,0x4
    80004532:	1e258593          	addi	a1,a1,482 # 80008710 <syscalls+0x208>
    80004536:	8526                	mv	a0,s1
    80004538:	ffffc097          	auipc	ra,0xffffc
    8000453c:	60e080e7          	jalr	1550(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    80004540:	0149a583          	lw	a1,20(s3)
    80004544:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004546:	0109a783          	lw	a5,16(s3)
    8000454a:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000454c:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004550:	854a                	mv	a0,s2
    80004552:	fffff097          	auipc	ra,0xfffff
    80004556:	e84080e7          	jalr	-380(ra) # 800033d6 <bread>
  log.lh.n = lh->n;
    8000455a:	4d34                	lw	a3,88(a0)
    8000455c:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000455e:	02d05663          	blez	a3,8000458a <initlog+0x76>
    80004562:	05c50793          	addi	a5,a0,92
    80004566:	0001d717          	auipc	a4,0x1d
    8000456a:	f1270713          	addi	a4,a4,-238 # 80021478 <log+0x30>
    8000456e:	36fd                	addiw	a3,a3,-1
    80004570:	02069613          	slli	a2,a3,0x20
    80004574:	01e65693          	srli	a3,a2,0x1e
    80004578:	06050613          	addi	a2,a0,96
    8000457c:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    8000457e:	4390                	lw	a2,0(a5)
    80004580:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004582:	0791                	addi	a5,a5,4
    80004584:	0711                	addi	a4,a4,4
    80004586:	fed79ce3          	bne	a5,a3,8000457e <initlog+0x6a>
  brelse(buf);
    8000458a:	fffff097          	auipc	ra,0xfffff
    8000458e:	f7c080e7          	jalr	-132(ra) # 80003506 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004592:	4505                	li	a0,1
    80004594:	00000097          	auipc	ra,0x0
    80004598:	ebc080e7          	jalr	-324(ra) # 80004450 <install_trans>
  log.lh.n = 0;
    8000459c:	0001d797          	auipc	a5,0x1d
    800045a0:	ec07ac23          	sw	zero,-296(a5) # 80021474 <log+0x2c>
  write_head(); // clear the log
    800045a4:	00000097          	auipc	ra,0x0
    800045a8:	e30080e7          	jalr	-464(ra) # 800043d4 <write_head>
}
    800045ac:	70a2                	ld	ra,40(sp)
    800045ae:	7402                	ld	s0,32(sp)
    800045b0:	64e2                	ld	s1,24(sp)
    800045b2:	6942                	ld	s2,16(sp)
    800045b4:	69a2                	ld	s3,8(sp)
    800045b6:	6145                	addi	sp,sp,48
    800045b8:	8082                	ret

00000000800045ba <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800045ba:	1101                	addi	sp,sp,-32
    800045bc:	ec06                	sd	ra,24(sp)
    800045be:	e822                	sd	s0,16(sp)
    800045c0:	e426                	sd	s1,8(sp)
    800045c2:	e04a                	sd	s2,0(sp)
    800045c4:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800045c6:	0001d517          	auipc	a0,0x1d
    800045ca:	e8250513          	addi	a0,a0,-382 # 80021448 <log>
    800045ce:	ffffc097          	auipc	ra,0xffffc
    800045d2:	608080e7          	jalr	1544(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    800045d6:	0001d497          	auipc	s1,0x1d
    800045da:	e7248493          	addi	s1,s1,-398 # 80021448 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800045de:	4979                	li	s2,30
    800045e0:	a039                	j	800045ee <begin_op+0x34>
      sleep(&log, &log.lock);
    800045e2:	85a6                	mv	a1,s1
    800045e4:	8526                	mv	a0,s1
    800045e6:	ffffe097          	auipc	ra,0xffffe
    800045ea:	b36080e7          	jalr	-1226(ra) # 8000211c <sleep>
    if(log.committing){
    800045ee:	50dc                	lw	a5,36(s1)
    800045f0:	fbed                	bnez	a5,800045e2 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800045f2:	5098                	lw	a4,32(s1)
    800045f4:	2705                	addiw	a4,a4,1
    800045f6:	0007069b          	sext.w	a3,a4
    800045fa:	0027179b          	slliw	a5,a4,0x2
    800045fe:	9fb9                	addw	a5,a5,a4
    80004600:	0017979b          	slliw	a5,a5,0x1
    80004604:	54d8                	lw	a4,44(s1)
    80004606:	9fb9                	addw	a5,a5,a4
    80004608:	00f95963          	bge	s2,a5,8000461a <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000460c:	85a6                	mv	a1,s1
    8000460e:	8526                	mv	a0,s1
    80004610:	ffffe097          	auipc	ra,0xffffe
    80004614:	b0c080e7          	jalr	-1268(ra) # 8000211c <sleep>
    80004618:	bfd9                	j	800045ee <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000461a:	0001d517          	auipc	a0,0x1d
    8000461e:	e2e50513          	addi	a0,a0,-466 # 80021448 <log>
    80004622:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004624:	ffffc097          	auipc	ra,0xffffc
    80004628:	666080e7          	jalr	1638(ra) # 80000c8a <release>
      break;
    }
  }
}
    8000462c:	60e2                	ld	ra,24(sp)
    8000462e:	6442                	ld	s0,16(sp)
    80004630:	64a2                	ld	s1,8(sp)
    80004632:	6902                	ld	s2,0(sp)
    80004634:	6105                	addi	sp,sp,32
    80004636:	8082                	ret

0000000080004638 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004638:	7139                	addi	sp,sp,-64
    8000463a:	fc06                	sd	ra,56(sp)
    8000463c:	f822                	sd	s0,48(sp)
    8000463e:	f426                	sd	s1,40(sp)
    80004640:	f04a                	sd	s2,32(sp)
    80004642:	ec4e                	sd	s3,24(sp)
    80004644:	e852                	sd	s4,16(sp)
    80004646:	e456                	sd	s5,8(sp)
    80004648:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000464a:	0001d497          	auipc	s1,0x1d
    8000464e:	dfe48493          	addi	s1,s1,-514 # 80021448 <log>
    80004652:	8526                	mv	a0,s1
    80004654:	ffffc097          	auipc	ra,0xffffc
    80004658:	582080e7          	jalr	1410(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    8000465c:	509c                	lw	a5,32(s1)
    8000465e:	37fd                	addiw	a5,a5,-1
    80004660:	0007891b          	sext.w	s2,a5
    80004664:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004666:	50dc                	lw	a5,36(s1)
    80004668:	e7b9                	bnez	a5,800046b6 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000466a:	04091e63          	bnez	s2,800046c6 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000466e:	0001d497          	auipc	s1,0x1d
    80004672:	dda48493          	addi	s1,s1,-550 # 80021448 <log>
    80004676:	4785                	li	a5,1
    80004678:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000467a:	8526                	mv	a0,s1
    8000467c:	ffffc097          	auipc	ra,0xffffc
    80004680:	60e080e7          	jalr	1550(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004684:	54dc                	lw	a5,44(s1)
    80004686:	06f04763          	bgtz	a5,800046f4 <end_op+0xbc>
    acquire(&log.lock);
    8000468a:	0001d497          	auipc	s1,0x1d
    8000468e:	dbe48493          	addi	s1,s1,-578 # 80021448 <log>
    80004692:	8526                	mv	a0,s1
    80004694:	ffffc097          	auipc	ra,0xffffc
    80004698:	542080e7          	jalr	1346(ra) # 80000bd6 <acquire>
    log.committing = 0;
    8000469c:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800046a0:	8526                	mv	a0,s1
    800046a2:	ffffe097          	auipc	ra,0xffffe
    800046a6:	ade080e7          	jalr	-1314(ra) # 80002180 <wakeup>
    release(&log.lock);
    800046aa:	8526                	mv	a0,s1
    800046ac:	ffffc097          	auipc	ra,0xffffc
    800046b0:	5de080e7          	jalr	1502(ra) # 80000c8a <release>
}
    800046b4:	a03d                	j	800046e2 <end_op+0xaa>
    panic("log.committing");
    800046b6:	00004517          	auipc	a0,0x4
    800046ba:	06250513          	addi	a0,a0,98 # 80008718 <syscalls+0x210>
    800046be:	ffffc097          	auipc	ra,0xffffc
    800046c2:	e82080e7          	jalr	-382(ra) # 80000540 <panic>
    wakeup(&log);
    800046c6:	0001d497          	auipc	s1,0x1d
    800046ca:	d8248493          	addi	s1,s1,-638 # 80021448 <log>
    800046ce:	8526                	mv	a0,s1
    800046d0:	ffffe097          	auipc	ra,0xffffe
    800046d4:	ab0080e7          	jalr	-1360(ra) # 80002180 <wakeup>
  release(&log.lock);
    800046d8:	8526                	mv	a0,s1
    800046da:	ffffc097          	auipc	ra,0xffffc
    800046de:	5b0080e7          	jalr	1456(ra) # 80000c8a <release>
}
    800046e2:	70e2                	ld	ra,56(sp)
    800046e4:	7442                	ld	s0,48(sp)
    800046e6:	74a2                	ld	s1,40(sp)
    800046e8:	7902                	ld	s2,32(sp)
    800046ea:	69e2                	ld	s3,24(sp)
    800046ec:	6a42                	ld	s4,16(sp)
    800046ee:	6aa2                	ld	s5,8(sp)
    800046f0:	6121                	addi	sp,sp,64
    800046f2:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800046f4:	0001da97          	auipc	s5,0x1d
    800046f8:	d84a8a93          	addi	s5,s5,-636 # 80021478 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800046fc:	0001da17          	auipc	s4,0x1d
    80004700:	d4ca0a13          	addi	s4,s4,-692 # 80021448 <log>
    80004704:	018a2583          	lw	a1,24(s4)
    80004708:	012585bb          	addw	a1,a1,s2
    8000470c:	2585                	addiw	a1,a1,1
    8000470e:	028a2503          	lw	a0,40(s4)
    80004712:	fffff097          	auipc	ra,0xfffff
    80004716:	cc4080e7          	jalr	-828(ra) # 800033d6 <bread>
    8000471a:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000471c:	000aa583          	lw	a1,0(s5)
    80004720:	028a2503          	lw	a0,40(s4)
    80004724:	fffff097          	auipc	ra,0xfffff
    80004728:	cb2080e7          	jalr	-846(ra) # 800033d6 <bread>
    8000472c:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000472e:	40000613          	li	a2,1024
    80004732:	05850593          	addi	a1,a0,88
    80004736:	05848513          	addi	a0,s1,88
    8000473a:	ffffc097          	auipc	ra,0xffffc
    8000473e:	5f4080e7          	jalr	1524(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    80004742:	8526                	mv	a0,s1
    80004744:	fffff097          	auipc	ra,0xfffff
    80004748:	d84080e7          	jalr	-636(ra) # 800034c8 <bwrite>
    brelse(from);
    8000474c:	854e                	mv	a0,s3
    8000474e:	fffff097          	auipc	ra,0xfffff
    80004752:	db8080e7          	jalr	-584(ra) # 80003506 <brelse>
    brelse(to);
    80004756:	8526                	mv	a0,s1
    80004758:	fffff097          	auipc	ra,0xfffff
    8000475c:	dae080e7          	jalr	-594(ra) # 80003506 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004760:	2905                	addiw	s2,s2,1
    80004762:	0a91                	addi	s5,s5,4
    80004764:	02ca2783          	lw	a5,44(s4)
    80004768:	f8f94ee3          	blt	s2,a5,80004704 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000476c:	00000097          	auipc	ra,0x0
    80004770:	c68080e7          	jalr	-920(ra) # 800043d4 <write_head>
    install_trans(0); // Now install writes to home locations
    80004774:	4501                	li	a0,0
    80004776:	00000097          	auipc	ra,0x0
    8000477a:	cda080e7          	jalr	-806(ra) # 80004450 <install_trans>
    log.lh.n = 0;
    8000477e:	0001d797          	auipc	a5,0x1d
    80004782:	ce07ab23          	sw	zero,-778(a5) # 80021474 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004786:	00000097          	auipc	ra,0x0
    8000478a:	c4e080e7          	jalr	-946(ra) # 800043d4 <write_head>
    8000478e:	bdf5                	j	8000468a <end_op+0x52>

0000000080004790 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004790:	1101                	addi	sp,sp,-32
    80004792:	ec06                	sd	ra,24(sp)
    80004794:	e822                	sd	s0,16(sp)
    80004796:	e426                	sd	s1,8(sp)
    80004798:	e04a                	sd	s2,0(sp)
    8000479a:	1000                	addi	s0,sp,32
    8000479c:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000479e:	0001d917          	auipc	s2,0x1d
    800047a2:	caa90913          	addi	s2,s2,-854 # 80021448 <log>
    800047a6:	854a                	mv	a0,s2
    800047a8:	ffffc097          	auipc	ra,0xffffc
    800047ac:	42e080e7          	jalr	1070(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800047b0:	02c92603          	lw	a2,44(s2)
    800047b4:	47f5                	li	a5,29
    800047b6:	06c7c563          	blt	a5,a2,80004820 <log_write+0x90>
    800047ba:	0001d797          	auipc	a5,0x1d
    800047be:	caa7a783          	lw	a5,-854(a5) # 80021464 <log+0x1c>
    800047c2:	37fd                	addiw	a5,a5,-1
    800047c4:	04f65e63          	bge	a2,a5,80004820 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800047c8:	0001d797          	auipc	a5,0x1d
    800047cc:	ca07a783          	lw	a5,-864(a5) # 80021468 <log+0x20>
    800047d0:	06f05063          	blez	a5,80004830 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800047d4:	4781                	li	a5,0
    800047d6:	06c05563          	blez	a2,80004840 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800047da:	44cc                	lw	a1,12(s1)
    800047dc:	0001d717          	auipc	a4,0x1d
    800047e0:	c9c70713          	addi	a4,a4,-868 # 80021478 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800047e4:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800047e6:	4314                	lw	a3,0(a4)
    800047e8:	04b68c63          	beq	a3,a1,80004840 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800047ec:	2785                	addiw	a5,a5,1
    800047ee:	0711                	addi	a4,a4,4
    800047f0:	fef61be3          	bne	a2,a5,800047e6 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800047f4:	0621                	addi	a2,a2,8
    800047f6:	060a                	slli	a2,a2,0x2
    800047f8:	0001d797          	auipc	a5,0x1d
    800047fc:	c5078793          	addi	a5,a5,-944 # 80021448 <log>
    80004800:	97b2                	add	a5,a5,a2
    80004802:	44d8                	lw	a4,12(s1)
    80004804:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004806:	8526                	mv	a0,s1
    80004808:	fffff097          	auipc	ra,0xfffff
    8000480c:	d9c080e7          	jalr	-612(ra) # 800035a4 <bpin>
    log.lh.n++;
    80004810:	0001d717          	auipc	a4,0x1d
    80004814:	c3870713          	addi	a4,a4,-968 # 80021448 <log>
    80004818:	575c                	lw	a5,44(a4)
    8000481a:	2785                	addiw	a5,a5,1
    8000481c:	d75c                	sw	a5,44(a4)
    8000481e:	a82d                	j	80004858 <log_write+0xc8>
    panic("too big a transaction");
    80004820:	00004517          	auipc	a0,0x4
    80004824:	f0850513          	addi	a0,a0,-248 # 80008728 <syscalls+0x220>
    80004828:	ffffc097          	auipc	ra,0xffffc
    8000482c:	d18080e7          	jalr	-744(ra) # 80000540 <panic>
    panic("log_write outside of trans");
    80004830:	00004517          	auipc	a0,0x4
    80004834:	f1050513          	addi	a0,a0,-240 # 80008740 <syscalls+0x238>
    80004838:	ffffc097          	auipc	ra,0xffffc
    8000483c:	d08080e7          	jalr	-760(ra) # 80000540 <panic>
  log.lh.block[i] = b->blockno;
    80004840:	00878693          	addi	a3,a5,8
    80004844:	068a                	slli	a3,a3,0x2
    80004846:	0001d717          	auipc	a4,0x1d
    8000484a:	c0270713          	addi	a4,a4,-1022 # 80021448 <log>
    8000484e:	9736                	add	a4,a4,a3
    80004850:	44d4                	lw	a3,12(s1)
    80004852:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004854:	faf609e3          	beq	a2,a5,80004806 <log_write+0x76>
  }
  release(&log.lock);
    80004858:	0001d517          	auipc	a0,0x1d
    8000485c:	bf050513          	addi	a0,a0,-1040 # 80021448 <log>
    80004860:	ffffc097          	auipc	ra,0xffffc
    80004864:	42a080e7          	jalr	1066(ra) # 80000c8a <release>
}
    80004868:	60e2                	ld	ra,24(sp)
    8000486a:	6442                	ld	s0,16(sp)
    8000486c:	64a2                	ld	s1,8(sp)
    8000486e:	6902                	ld	s2,0(sp)
    80004870:	6105                	addi	sp,sp,32
    80004872:	8082                	ret

0000000080004874 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004874:	1101                	addi	sp,sp,-32
    80004876:	ec06                	sd	ra,24(sp)
    80004878:	e822                	sd	s0,16(sp)
    8000487a:	e426                	sd	s1,8(sp)
    8000487c:	e04a                	sd	s2,0(sp)
    8000487e:	1000                	addi	s0,sp,32
    80004880:	84aa                	mv	s1,a0
    80004882:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004884:	00004597          	auipc	a1,0x4
    80004888:	edc58593          	addi	a1,a1,-292 # 80008760 <syscalls+0x258>
    8000488c:	0521                	addi	a0,a0,8
    8000488e:	ffffc097          	auipc	ra,0xffffc
    80004892:	2b8080e7          	jalr	696(ra) # 80000b46 <initlock>
  lk->name = name;
    80004896:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000489a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000489e:	0204a423          	sw	zero,40(s1)
}
    800048a2:	60e2                	ld	ra,24(sp)
    800048a4:	6442                	ld	s0,16(sp)
    800048a6:	64a2                	ld	s1,8(sp)
    800048a8:	6902                	ld	s2,0(sp)
    800048aa:	6105                	addi	sp,sp,32
    800048ac:	8082                	ret

00000000800048ae <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800048ae:	1101                	addi	sp,sp,-32
    800048b0:	ec06                	sd	ra,24(sp)
    800048b2:	e822                	sd	s0,16(sp)
    800048b4:	e426                	sd	s1,8(sp)
    800048b6:	e04a                	sd	s2,0(sp)
    800048b8:	1000                	addi	s0,sp,32
    800048ba:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800048bc:	00850913          	addi	s2,a0,8
    800048c0:	854a                	mv	a0,s2
    800048c2:	ffffc097          	auipc	ra,0xffffc
    800048c6:	314080e7          	jalr	788(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    800048ca:	409c                	lw	a5,0(s1)
    800048cc:	cb89                	beqz	a5,800048de <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800048ce:	85ca                	mv	a1,s2
    800048d0:	8526                	mv	a0,s1
    800048d2:	ffffe097          	auipc	ra,0xffffe
    800048d6:	84a080e7          	jalr	-1974(ra) # 8000211c <sleep>
  while (lk->locked) {
    800048da:	409c                	lw	a5,0(s1)
    800048dc:	fbed                	bnez	a5,800048ce <acquiresleep+0x20>
  }
  lk->locked = 1;
    800048de:	4785                	li	a5,1
    800048e0:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800048e2:	ffffd097          	auipc	ra,0xffffd
    800048e6:	0e2080e7          	jalr	226(ra) # 800019c4 <myproc>
    800048ea:	591c                	lw	a5,48(a0)
    800048ec:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800048ee:	854a                	mv	a0,s2
    800048f0:	ffffc097          	auipc	ra,0xffffc
    800048f4:	39a080e7          	jalr	922(ra) # 80000c8a <release>
}
    800048f8:	60e2                	ld	ra,24(sp)
    800048fa:	6442                	ld	s0,16(sp)
    800048fc:	64a2                	ld	s1,8(sp)
    800048fe:	6902                	ld	s2,0(sp)
    80004900:	6105                	addi	sp,sp,32
    80004902:	8082                	ret

0000000080004904 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004904:	1101                	addi	sp,sp,-32
    80004906:	ec06                	sd	ra,24(sp)
    80004908:	e822                	sd	s0,16(sp)
    8000490a:	e426                	sd	s1,8(sp)
    8000490c:	e04a                	sd	s2,0(sp)
    8000490e:	1000                	addi	s0,sp,32
    80004910:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004912:	00850913          	addi	s2,a0,8
    80004916:	854a                	mv	a0,s2
    80004918:	ffffc097          	auipc	ra,0xffffc
    8000491c:	2be080e7          	jalr	702(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    80004920:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004924:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004928:	8526                	mv	a0,s1
    8000492a:	ffffe097          	auipc	ra,0xffffe
    8000492e:	856080e7          	jalr	-1962(ra) # 80002180 <wakeup>
  release(&lk->lk);
    80004932:	854a                	mv	a0,s2
    80004934:	ffffc097          	auipc	ra,0xffffc
    80004938:	356080e7          	jalr	854(ra) # 80000c8a <release>
}
    8000493c:	60e2                	ld	ra,24(sp)
    8000493e:	6442                	ld	s0,16(sp)
    80004940:	64a2                	ld	s1,8(sp)
    80004942:	6902                	ld	s2,0(sp)
    80004944:	6105                	addi	sp,sp,32
    80004946:	8082                	ret

0000000080004948 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004948:	7179                	addi	sp,sp,-48
    8000494a:	f406                	sd	ra,40(sp)
    8000494c:	f022                	sd	s0,32(sp)
    8000494e:	ec26                	sd	s1,24(sp)
    80004950:	e84a                	sd	s2,16(sp)
    80004952:	e44e                	sd	s3,8(sp)
    80004954:	1800                	addi	s0,sp,48
    80004956:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004958:	00850913          	addi	s2,a0,8
    8000495c:	854a                	mv	a0,s2
    8000495e:	ffffc097          	auipc	ra,0xffffc
    80004962:	278080e7          	jalr	632(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004966:	409c                	lw	a5,0(s1)
    80004968:	ef99                	bnez	a5,80004986 <holdingsleep+0x3e>
    8000496a:	4481                	li	s1,0
  release(&lk->lk);
    8000496c:	854a                	mv	a0,s2
    8000496e:	ffffc097          	auipc	ra,0xffffc
    80004972:	31c080e7          	jalr	796(ra) # 80000c8a <release>
  return r;
}
    80004976:	8526                	mv	a0,s1
    80004978:	70a2                	ld	ra,40(sp)
    8000497a:	7402                	ld	s0,32(sp)
    8000497c:	64e2                	ld	s1,24(sp)
    8000497e:	6942                	ld	s2,16(sp)
    80004980:	69a2                	ld	s3,8(sp)
    80004982:	6145                	addi	sp,sp,48
    80004984:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004986:	0284a983          	lw	s3,40(s1)
    8000498a:	ffffd097          	auipc	ra,0xffffd
    8000498e:	03a080e7          	jalr	58(ra) # 800019c4 <myproc>
    80004992:	5904                	lw	s1,48(a0)
    80004994:	413484b3          	sub	s1,s1,s3
    80004998:	0014b493          	seqz	s1,s1
    8000499c:	bfc1                	j	8000496c <holdingsleep+0x24>

000000008000499e <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000499e:	1141                	addi	sp,sp,-16
    800049a0:	e406                	sd	ra,8(sp)
    800049a2:	e022                	sd	s0,0(sp)
    800049a4:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800049a6:	00004597          	auipc	a1,0x4
    800049aa:	dca58593          	addi	a1,a1,-566 # 80008770 <syscalls+0x268>
    800049ae:	0001d517          	auipc	a0,0x1d
    800049b2:	be250513          	addi	a0,a0,-1054 # 80021590 <ftable>
    800049b6:	ffffc097          	auipc	ra,0xffffc
    800049ba:	190080e7          	jalr	400(ra) # 80000b46 <initlock>
}
    800049be:	60a2                	ld	ra,8(sp)
    800049c0:	6402                	ld	s0,0(sp)
    800049c2:	0141                	addi	sp,sp,16
    800049c4:	8082                	ret

00000000800049c6 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800049c6:	1101                	addi	sp,sp,-32
    800049c8:	ec06                	sd	ra,24(sp)
    800049ca:	e822                	sd	s0,16(sp)
    800049cc:	e426                	sd	s1,8(sp)
    800049ce:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800049d0:	0001d517          	auipc	a0,0x1d
    800049d4:	bc050513          	addi	a0,a0,-1088 # 80021590 <ftable>
    800049d8:	ffffc097          	auipc	ra,0xffffc
    800049dc:	1fe080e7          	jalr	510(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800049e0:	0001d497          	auipc	s1,0x1d
    800049e4:	bc848493          	addi	s1,s1,-1080 # 800215a8 <ftable+0x18>
    800049e8:	0001e717          	auipc	a4,0x1e
    800049ec:	b6070713          	addi	a4,a4,-1184 # 80022548 <disk>
    if(f->ref == 0){
    800049f0:	40dc                	lw	a5,4(s1)
    800049f2:	cf99                	beqz	a5,80004a10 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800049f4:	02848493          	addi	s1,s1,40
    800049f8:	fee49ce3          	bne	s1,a4,800049f0 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800049fc:	0001d517          	auipc	a0,0x1d
    80004a00:	b9450513          	addi	a0,a0,-1132 # 80021590 <ftable>
    80004a04:	ffffc097          	auipc	ra,0xffffc
    80004a08:	286080e7          	jalr	646(ra) # 80000c8a <release>
  return 0;
    80004a0c:	4481                	li	s1,0
    80004a0e:	a819                	j	80004a24 <filealloc+0x5e>
      f->ref = 1;
    80004a10:	4785                	li	a5,1
    80004a12:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004a14:	0001d517          	auipc	a0,0x1d
    80004a18:	b7c50513          	addi	a0,a0,-1156 # 80021590 <ftable>
    80004a1c:	ffffc097          	auipc	ra,0xffffc
    80004a20:	26e080e7          	jalr	622(ra) # 80000c8a <release>
}
    80004a24:	8526                	mv	a0,s1
    80004a26:	60e2                	ld	ra,24(sp)
    80004a28:	6442                	ld	s0,16(sp)
    80004a2a:	64a2                	ld	s1,8(sp)
    80004a2c:	6105                	addi	sp,sp,32
    80004a2e:	8082                	ret

0000000080004a30 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004a30:	1101                	addi	sp,sp,-32
    80004a32:	ec06                	sd	ra,24(sp)
    80004a34:	e822                	sd	s0,16(sp)
    80004a36:	e426                	sd	s1,8(sp)
    80004a38:	1000                	addi	s0,sp,32
    80004a3a:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004a3c:	0001d517          	auipc	a0,0x1d
    80004a40:	b5450513          	addi	a0,a0,-1196 # 80021590 <ftable>
    80004a44:	ffffc097          	auipc	ra,0xffffc
    80004a48:	192080e7          	jalr	402(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004a4c:	40dc                	lw	a5,4(s1)
    80004a4e:	02f05263          	blez	a5,80004a72 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004a52:	2785                	addiw	a5,a5,1
    80004a54:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004a56:	0001d517          	auipc	a0,0x1d
    80004a5a:	b3a50513          	addi	a0,a0,-1222 # 80021590 <ftable>
    80004a5e:	ffffc097          	auipc	ra,0xffffc
    80004a62:	22c080e7          	jalr	556(ra) # 80000c8a <release>
  return f;
}
    80004a66:	8526                	mv	a0,s1
    80004a68:	60e2                	ld	ra,24(sp)
    80004a6a:	6442                	ld	s0,16(sp)
    80004a6c:	64a2                	ld	s1,8(sp)
    80004a6e:	6105                	addi	sp,sp,32
    80004a70:	8082                	ret
    panic("filedup");
    80004a72:	00004517          	auipc	a0,0x4
    80004a76:	d0650513          	addi	a0,a0,-762 # 80008778 <syscalls+0x270>
    80004a7a:	ffffc097          	auipc	ra,0xffffc
    80004a7e:	ac6080e7          	jalr	-1338(ra) # 80000540 <panic>

0000000080004a82 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004a82:	7139                	addi	sp,sp,-64
    80004a84:	fc06                	sd	ra,56(sp)
    80004a86:	f822                	sd	s0,48(sp)
    80004a88:	f426                	sd	s1,40(sp)
    80004a8a:	f04a                	sd	s2,32(sp)
    80004a8c:	ec4e                	sd	s3,24(sp)
    80004a8e:	e852                	sd	s4,16(sp)
    80004a90:	e456                	sd	s5,8(sp)
    80004a92:	0080                	addi	s0,sp,64
    80004a94:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004a96:	0001d517          	auipc	a0,0x1d
    80004a9a:	afa50513          	addi	a0,a0,-1286 # 80021590 <ftable>
    80004a9e:	ffffc097          	auipc	ra,0xffffc
    80004aa2:	138080e7          	jalr	312(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004aa6:	40dc                	lw	a5,4(s1)
    80004aa8:	06f05163          	blez	a5,80004b0a <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004aac:	37fd                	addiw	a5,a5,-1
    80004aae:	0007871b          	sext.w	a4,a5
    80004ab2:	c0dc                	sw	a5,4(s1)
    80004ab4:	06e04363          	bgtz	a4,80004b1a <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004ab8:	0004a903          	lw	s2,0(s1)
    80004abc:	0094ca83          	lbu	s5,9(s1)
    80004ac0:	0104ba03          	ld	s4,16(s1)
    80004ac4:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004ac8:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004acc:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004ad0:	0001d517          	auipc	a0,0x1d
    80004ad4:	ac050513          	addi	a0,a0,-1344 # 80021590 <ftable>
    80004ad8:	ffffc097          	auipc	ra,0xffffc
    80004adc:	1b2080e7          	jalr	434(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    80004ae0:	4785                	li	a5,1
    80004ae2:	04f90d63          	beq	s2,a5,80004b3c <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004ae6:	3979                	addiw	s2,s2,-2
    80004ae8:	4785                	li	a5,1
    80004aea:	0527e063          	bltu	a5,s2,80004b2a <fileclose+0xa8>
    begin_op();
    80004aee:	00000097          	auipc	ra,0x0
    80004af2:	acc080e7          	jalr	-1332(ra) # 800045ba <begin_op>
    iput(ff.ip);
    80004af6:	854e                	mv	a0,s3
    80004af8:	fffff097          	auipc	ra,0xfffff
    80004afc:	2b0080e7          	jalr	688(ra) # 80003da8 <iput>
    end_op();
    80004b00:	00000097          	auipc	ra,0x0
    80004b04:	b38080e7          	jalr	-1224(ra) # 80004638 <end_op>
    80004b08:	a00d                	j	80004b2a <fileclose+0xa8>
    panic("fileclose");
    80004b0a:	00004517          	auipc	a0,0x4
    80004b0e:	c7650513          	addi	a0,a0,-906 # 80008780 <syscalls+0x278>
    80004b12:	ffffc097          	auipc	ra,0xffffc
    80004b16:	a2e080e7          	jalr	-1490(ra) # 80000540 <panic>
    release(&ftable.lock);
    80004b1a:	0001d517          	auipc	a0,0x1d
    80004b1e:	a7650513          	addi	a0,a0,-1418 # 80021590 <ftable>
    80004b22:	ffffc097          	auipc	ra,0xffffc
    80004b26:	168080e7          	jalr	360(ra) # 80000c8a <release>
  }
}
    80004b2a:	70e2                	ld	ra,56(sp)
    80004b2c:	7442                	ld	s0,48(sp)
    80004b2e:	74a2                	ld	s1,40(sp)
    80004b30:	7902                	ld	s2,32(sp)
    80004b32:	69e2                	ld	s3,24(sp)
    80004b34:	6a42                	ld	s4,16(sp)
    80004b36:	6aa2                	ld	s5,8(sp)
    80004b38:	6121                	addi	sp,sp,64
    80004b3a:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004b3c:	85d6                	mv	a1,s5
    80004b3e:	8552                	mv	a0,s4
    80004b40:	00000097          	auipc	ra,0x0
    80004b44:	34c080e7          	jalr	844(ra) # 80004e8c <pipeclose>
    80004b48:	b7cd                	j	80004b2a <fileclose+0xa8>

0000000080004b4a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004b4a:	715d                	addi	sp,sp,-80
    80004b4c:	e486                	sd	ra,72(sp)
    80004b4e:	e0a2                	sd	s0,64(sp)
    80004b50:	fc26                	sd	s1,56(sp)
    80004b52:	f84a                	sd	s2,48(sp)
    80004b54:	f44e                	sd	s3,40(sp)
    80004b56:	0880                	addi	s0,sp,80
    80004b58:	84aa                	mv	s1,a0
    80004b5a:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004b5c:	ffffd097          	auipc	ra,0xffffd
    80004b60:	e68080e7          	jalr	-408(ra) # 800019c4 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004b64:	409c                	lw	a5,0(s1)
    80004b66:	37f9                	addiw	a5,a5,-2
    80004b68:	4705                	li	a4,1
    80004b6a:	04f76763          	bltu	a4,a5,80004bb8 <filestat+0x6e>
    80004b6e:	892a                	mv	s2,a0
    ilock(f->ip);
    80004b70:	6c88                	ld	a0,24(s1)
    80004b72:	fffff097          	auipc	ra,0xfffff
    80004b76:	07c080e7          	jalr	124(ra) # 80003bee <ilock>
    stati(f->ip, &st);
    80004b7a:	fb840593          	addi	a1,s0,-72
    80004b7e:	6c88                	ld	a0,24(s1)
    80004b80:	fffff097          	auipc	ra,0xfffff
    80004b84:	2f8080e7          	jalr	760(ra) # 80003e78 <stati>
    iunlock(f->ip);
    80004b88:	6c88                	ld	a0,24(s1)
    80004b8a:	fffff097          	auipc	ra,0xfffff
    80004b8e:	126080e7          	jalr	294(ra) # 80003cb0 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004b92:	46e1                	li	a3,24
    80004b94:	fb840613          	addi	a2,s0,-72
    80004b98:	85ce                	mv	a1,s3
    80004b9a:	05093503          	ld	a0,80(s2)
    80004b9e:	ffffd097          	auipc	ra,0xffffd
    80004ba2:	ace080e7          	jalr	-1330(ra) # 8000166c <copyout>
    80004ba6:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004baa:	60a6                	ld	ra,72(sp)
    80004bac:	6406                	ld	s0,64(sp)
    80004bae:	74e2                	ld	s1,56(sp)
    80004bb0:	7942                	ld	s2,48(sp)
    80004bb2:	79a2                	ld	s3,40(sp)
    80004bb4:	6161                	addi	sp,sp,80
    80004bb6:	8082                	ret
  return -1;
    80004bb8:	557d                	li	a0,-1
    80004bba:	bfc5                	j	80004baa <filestat+0x60>

0000000080004bbc <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004bbc:	7179                	addi	sp,sp,-48
    80004bbe:	f406                	sd	ra,40(sp)
    80004bc0:	f022                	sd	s0,32(sp)
    80004bc2:	ec26                	sd	s1,24(sp)
    80004bc4:	e84a                	sd	s2,16(sp)
    80004bc6:	e44e                	sd	s3,8(sp)
    80004bc8:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004bca:	00854783          	lbu	a5,8(a0)
    80004bce:	c3d5                	beqz	a5,80004c72 <fileread+0xb6>
    80004bd0:	84aa                	mv	s1,a0
    80004bd2:	89ae                	mv	s3,a1
    80004bd4:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004bd6:	411c                	lw	a5,0(a0)
    80004bd8:	4705                	li	a4,1
    80004bda:	04e78963          	beq	a5,a4,80004c2c <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004bde:	470d                	li	a4,3
    80004be0:	04e78d63          	beq	a5,a4,80004c3a <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004be4:	4709                	li	a4,2
    80004be6:	06e79e63          	bne	a5,a4,80004c62 <fileread+0xa6>
    ilock(f->ip);
    80004bea:	6d08                	ld	a0,24(a0)
    80004bec:	fffff097          	auipc	ra,0xfffff
    80004bf0:	002080e7          	jalr	2(ra) # 80003bee <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004bf4:	874a                	mv	a4,s2
    80004bf6:	5094                	lw	a3,32(s1)
    80004bf8:	864e                	mv	a2,s3
    80004bfa:	4585                	li	a1,1
    80004bfc:	6c88                	ld	a0,24(s1)
    80004bfe:	fffff097          	auipc	ra,0xfffff
    80004c02:	2a4080e7          	jalr	676(ra) # 80003ea2 <readi>
    80004c06:	892a                	mv	s2,a0
    80004c08:	00a05563          	blez	a0,80004c12 <fileread+0x56>
      f->off += r;
    80004c0c:	509c                	lw	a5,32(s1)
    80004c0e:	9fa9                	addw	a5,a5,a0
    80004c10:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004c12:	6c88                	ld	a0,24(s1)
    80004c14:	fffff097          	auipc	ra,0xfffff
    80004c18:	09c080e7          	jalr	156(ra) # 80003cb0 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004c1c:	854a                	mv	a0,s2
    80004c1e:	70a2                	ld	ra,40(sp)
    80004c20:	7402                	ld	s0,32(sp)
    80004c22:	64e2                	ld	s1,24(sp)
    80004c24:	6942                	ld	s2,16(sp)
    80004c26:	69a2                	ld	s3,8(sp)
    80004c28:	6145                	addi	sp,sp,48
    80004c2a:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004c2c:	6908                	ld	a0,16(a0)
    80004c2e:	00000097          	auipc	ra,0x0
    80004c32:	3c6080e7          	jalr	966(ra) # 80004ff4 <piperead>
    80004c36:	892a                	mv	s2,a0
    80004c38:	b7d5                	j	80004c1c <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004c3a:	02451783          	lh	a5,36(a0)
    80004c3e:	03079693          	slli	a3,a5,0x30
    80004c42:	92c1                	srli	a3,a3,0x30
    80004c44:	4725                	li	a4,9
    80004c46:	02d76863          	bltu	a4,a3,80004c76 <fileread+0xba>
    80004c4a:	0792                	slli	a5,a5,0x4
    80004c4c:	0001d717          	auipc	a4,0x1d
    80004c50:	8a470713          	addi	a4,a4,-1884 # 800214f0 <devsw>
    80004c54:	97ba                	add	a5,a5,a4
    80004c56:	639c                	ld	a5,0(a5)
    80004c58:	c38d                	beqz	a5,80004c7a <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004c5a:	4505                	li	a0,1
    80004c5c:	9782                	jalr	a5
    80004c5e:	892a                	mv	s2,a0
    80004c60:	bf75                	j	80004c1c <fileread+0x60>
    panic("fileread");
    80004c62:	00004517          	auipc	a0,0x4
    80004c66:	b2e50513          	addi	a0,a0,-1234 # 80008790 <syscalls+0x288>
    80004c6a:	ffffc097          	auipc	ra,0xffffc
    80004c6e:	8d6080e7          	jalr	-1834(ra) # 80000540 <panic>
    return -1;
    80004c72:	597d                	li	s2,-1
    80004c74:	b765                	j	80004c1c <fileread+0x60>
      return -1;
    80004c76:	597d                	li	s2,-1
    80004c78:	b755                	j	80004c1c <fileread+0x60>
    80004c7a:	597d                	li	s2,-1
    80004c7c:	b745                	j	80004c1c <fileread+0x60>

0000000080004c7e <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004c7e:	715d                	addi	sp,sp,-80
    80004c80:	e486                	sd	ra,72(sp)
    80004c82:	e0a2                	sd	s0,64(sp)
    80004c84:	fc26                	sd	s1,56(sp)
    80004c86:	f84a                	sd	s2,48(sp)
    80004c88:	f44e                	sd	s3,40(sp)
    80004c8a:	f052                	sd	s4,32(sp)
    80004c8c:	ec56                	sd	s5,24(sp)
    80004c8e:	e85a                	sd	s6,16(sp)
    80004c90:	e45e                	sd	s7,8(sp)
    80004c92:	e062                	sd	s8,0(sp)
    80004c94:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004c96:	00954783          	lbu	a5,9(a0)
    80004c9a:	10078663          	beqz	a5,80004da6 <filewrite+0x128>
    80004c9e:	892a                	mv	s2,a0
    80004ca0:	8b2e                	mv	s6,a1
    80004ca2:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004ca4:	411c                	lw	a5,0(a0)
    80004ca6:	4705                	li	a4,1
    80004ca8:	02e78263          	beq	a5,a4,80004ccc <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004cac:	470d                	li	a4,3
    80004cae:	02e78663          	beq	a5,a4,80004cda <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004cb2:	4709                	li	a4,2
    80004cb4:	0ee79163          	bne	a5,a4,80004d96 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004cb8:	0ac05d63          	blez	a2,80004d72 <filewrite+0xf4>
    int i = 0;
    80004cbc:	4981                	li	s3,0
    80004cbe:	6b85                	lui	s7,0x1
    80004cc0:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004cc4:	6c05                	lui	s8,0x1
    80004cc6:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004cca:	a861                	j	80004d62 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004ccc:	6908                	ld	a0,16(a0)
    80004cce:	00000097          	auipc	ra,0x0
    80004cd2:	22e080e7          	jalr	558(ra) # 80004efc <pipewrite>
    80004cd6:	8a2a                	mv	s4,a0
    80004cd8:	a045                	j	80004d78 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004cda:	02451783          	lh	a5,36(a0)
    80004cde:	03079693          	slli	a3,a5,0x30
    80004ce2:	92c1                	srli	a3,a3,0x30
    80004ce4:	4725                	li	a4,9
    80004ce6:	0cd76263          	bltu	a4,a3,80004daa <filewrite+0x12c>
    80004cea:	0792                	slli	a5,a5,0x4
    80004cec:	0001d717          	auipc	a4,0x1d
    80004cf0:	80470713          	addi	a4,a4,-2044 # 800214f0 <devsw>
    80004cf4:	97ba                	add	a5,a5,a4
    80004cf6:	679c                	ld	a5,8(a5)
    80004cf8:	cbdd                	beqz	a5,80004dae <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004cfa:	4505                	li	a0,1
    80004cfc:	9782                	jalr	a5
    80004cfe:	8a2a                	mv	s4,a0
    80004d00:	a8a5                	j	80004d78 <filewrite+0xfa>
    80004d02:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004d06:	00000097          	auipc	ra,0x0
    80004d0a:	8b4080e7          	jalr	-1868(ra) # 800045ba <begin_op>
      ilock(f->ip);
    80004d0e:	01893503          	ld	a0,24(s2)
    80004d12:	fffff097          	auipc	ra,0xfffff
    80004d16:	edc080e7          	jalr	-292(ra) # 80003bee <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004d1a:	8756                	mv	a4,s5
    80004d1c:	02092683          	lw	a3,32(s2)
    80004d20:	01698633          	add	a2,s3,s6
    80004d24:	4585                	li	a1,1
    80004d26:	01893503          	ld	a0,24(s2)
    80004d2a:	fffff097          	auipc	ra,0xfffff
    80004d2e:	270080e7          	jalr	624(ra) # 80003f9a <writei>
    80004d32:	84aa                	mv	s1,a0
    80004d34:	00a05763          	blez	a0,80004d42 <filewrite+0xc4>
        f->off += r;
    80004d38:	02092783          	lw	a5,32(s2)
    80004d3c:	9fa9                	addw	a5,a5,a0
    80004d3e:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004d42:	01893503          	ld	a0,24(s2)
    80004d46:	fffff097          	auipc	ra,0xfffff
    80004d4a:	f6a080e7          	jalr	-150(ra) # 80003cb0 <iunlock>
      end_op();
    80004d4e:	00000097          	auipc	ra,0x0
    80004d52:	8ea080e7          	jalr	-1814(ra) # 80004638 <end_op>

      if(r != n1){
    80004d56:	009a9f63          	bne	s5,s1,80004d74 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004d5a:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004d5e:	0149db63          	bge	s3,s4,80004d74 <filewrite+0xf6>
      int n1 = n - i;
    80004d62:	413a04bb          	subw	s1,s4,s3
    80004d66:	0004879b          	sext.w	a5,s1
    80004d6a:	f8fbdce3          	bge	s7,a5,80004d02 <filewrite+0x84>
    80004d6e:	84e2                	mv	s1,s8
    80004d70:	bf49                	j	80004d02 <filewrite+0x84>
    int i = 0;
    80004d72:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004d74:	013a1f63          	bne	s4,s3,80004d92 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004d78:	8552                	mv	a0,s4
    80004d7a:	60a6                	ld	ra,72(sp)
    80004d7c:	6406                	ld	s0,64(sp)
    80004d7e:	74e2                	ld	s1,56(sp)
    80004d80:	7942                	ld	s2,48(sp)
    80004d82:	79a2                	ld	s3,40(sp)
    80004d84:	7a02                	ld	s4,32(sp)
    80004d86:	6ae2                	ld	s5,24(sp)
    80004d88:	6b42                	ld	s6,16(sp)
    80004d8a:	6ba2                	ld	s7,8(sp)
    80004d8c:	6c02                	ld	s8,0(sp)
    80004d8e:	6161                	addi	sp,sp,80
    80004d90:	8082                	ret
    ret = (i == n ? n : -1);
    80004d92:	5a7d                	li	s4,-1
    80004d94:	b7d5                	j	80004d78 <filewrite+0xfa>
    panic("filewrite");
    80004d96:	00004517          	auipc	a0,0x4
    80004d9a:	a0a50513          	addi	a0,a0,-1526 # 800087a0 <syscalls+0x298>
    80004d9e:	ffffb097          	auipc	ra,0xffffb
    80004da2:	7a2080e7          	jalr	1954(ra) # 80000540 <panic>
    return -1;
    80004da6:	5a7d                	li	s4,-1
    80004da8:	bfc1                	j	80004d78 <filewrite+0xfa>
      return -1;
    80004daa:	5a7d                	li	s4,-1
    80004dac:	b7f1                	j	80004d78 <filewrite+0xfa>
    80004dae:	5a7d                	li	s4,-1
    80004db0:	b7e1                	j	80004d78 <filewrite+0xfa>

0000000080004db2 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004db2:	7179                	addi	sp,sp,-48
    80004db4:	f406                	sd	ra,40(sp)
    80004db6:	f022                	sd	s0,32(sp)
    80004db8:	ec26                	sd	s1,24(sp)
    80004dba:	e84a                	sd	s2,16(sp)
    80004dbc:	e44e                	sd	s3,8(sp)
    80004dbe:	e052                	sd	s4,0(sp)
    80004dc0:	1800                	addi	s0,sp,48
    80004dc2:	84aa                	mv	s1,a0
    80004dc4:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004dc6:	0005b023          	sd	zero,0(a1)
    80004dca:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004dce:	00000097          	auipc	ra,0x0
    80004dd2:	bf8080e7          	jalr	-1032(ra) # 800049c6 <filealloc>
    80004dd6:	e088                	sd	a0,0(s1)
    80004dd8:	c551                	beqz	a0,80004e64 <pipealloc+0xb2>
    80004dda:	00000097          	auipc	ra,0x0
    80004dde:	bec080e7          	jalr	-1044(ra) # 800049c6 <filealloc>
    80004de2:	00aa3023          	sd	a0,0(s4)
    80004de6:	c92d                	beqz	a0,80004e58 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004de8:	ffffc097          	auipc	ra,0xffffc
    80004dec:	cfe080e7          	jalr	-770(ra) # 80000ae6 <kalloc>
    80004df0:	892a                	mv	s2,a0
    80004df2:	c125                	beqz	a0,80004e52 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004df4:	4985                	li	s3,1
    80004df6:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004dfa:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004dfe:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004e02:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004e06:	00004597          	auipc	a1,0x4
    80004e0a:	9aa58593          	addi	a1,a1,-1622 # 800087b0 <syscalls+0x2a8>
    80004e0e:	ffffc097          	auipc	ra,0xffffc
    80004e12:	d38080e7          	jalr	-712(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004e16:	609c                	ld	a5,0(s1)
    80004e18:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004e1c:	609c                	ld	a5,0(s1)
    80004e1e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004e22:	609c                	ld	a5,0(s1)
    80004e24:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004e28:	609c                	ld	a5,0(s1)
    80004e2a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004e2e:	000a3783          	ld	a5,0(s4)
    80004e32:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004e36:	000a3783          	ld	a5,0(s4)
    80004e3a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004e3e:	000a3783          	ld	a5,0(s4)
    80004e42:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004e46:	000a3783          	ld	a5,0(s4)
    80004e4a:	0127b823          	sd	s2,16(a5)
  return 0;
    80004e4e:	4501                	li	a0,0
    80004e50:	a025                	j	80004e78 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004e52:	6088                	ld	a0,0(s1)
    80004e54:	e501                	bnez	a0,80004e5c <pipealloc+0xaa>
    80004e56:	a039                	j	80004e64 <pipealloc+0xb2>
    80004e58:	6088                	ld	a0,0(s1)
    80004e5a:	c51d                	beqz	a0,80004e88 <pipealloc+0xd6>
    fileclose(*f0);
    80004e5c:	00000097          	auipc	ra,0x0
    80004e60:	c26080e7          	jalr	-986(ra) # 80004a82 <fileclose>
  if(*f1)
    80004e64:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004e68:	557d                	li	a0,-1
  if(*f1)
    80004e6a:	c799                	beqz	a5,80004e78 <pipealloc+0xc6>
    fileclose(*f1);
    80004e6c:	853e                	mv	a0,a5
    80004e6e:	00000097          	auipc	ra,0x0
    80004e72:	c14080e7          	jalr	-1004(ra) # 80004a82 <fileclose>
  return -1;
    80004e76:	557d                	li	a0,-1
}
    80004e78:	70a2                	ld	ra,40(sp)
    80004e7a:	7402                	ld	s0,32(sp)
    80004e7c:	64e2                	ld	s1,24(sp)
    80004e7e:	6942                	ld	s2,16(sp)
    80004e80:	69a2                	ld	s3,8(sp)
    80004e82:	6a02                	ld	s4,0(sp)
    80004e84:	6145                	addi	sp,sp,48
    80004e86:	8082                	ret
  return -1;
    80004e88:	557d                	li	a0,-1
    80004e8a:	b7fd                	j	80004e78 <pipealloc+0xc6>

0000000080004e8c <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004e8c:	1101                	addi	sp,sp,-32
    80004e8e:	ec06                	sd	ra,24(sp)
    80004e90:	e822                	sd	s0,16(sp)
    80004e92:	e426                	sd	s1,8(sp)
    80004e94:	e04a                	sd	s2,0(sp)
    80004e96:	1000                	addi	s0,sp,32
    80004e98:	84aa                	mv	s1,a0
    80004e9a:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004e9c:	ffffc097          	auipc	ra,0xffffc
    80004ea0:	d3a080e7          	jalr	-710(ra) # 80000bd6 <acquire>
  if(writable){
    80004ea4:	02090d63          	beqz	s2,80004ede <pipeclose+0x52>
    pi->writeopen = 0;
    80004ea8:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004eac:	21848513          	addi	a0,s1,536
    80004eb0:	ffffd097          	auipc	ra,0xffffd
    80004eb4:	2d0080e7          	jalr	720(ra) # 80002180 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004eb8:	2204b783          	ld	a5,544(s1)
    80004ebc:	eb95                	bnez	a5,80004ef0 <pipeclose+0x64>
    release(&pi->lock);
    80004ebe:	8526                	mv	a0,s1
    80004ec0:	ffffc097          	auipc	ra,0xffffc
    80004ec4:	dca080e7          	jalr	-566(ra) # 80000c8a <release>
    kfree((char*)pi);
    80004ec8:	8526                	mv	a0,s1
    80004eca:	ffffc097          	auipc	ra,0xffffc
    80004ece:	b1e080e7          	jalr	-1250(ra) # 800009e8 <kfree>
  } else
    release(&pi->lock);
}
    80004ed2:	60e2                	ld	ra,24(sp)
    80004ed4:	6442                	ld	s0,16(sp)
    80004ed6:	64a2                	ld	s1,8(sp)
    80004ed8:	6902                	ld	s2,0(sp)
    80004eda:	6105                	addi	sp,sp,32
    80004edc:	8082                	ret
    pi->readopen = 0;
    80004ede:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004ee2:	21c48513          	addi	a0,s1,540
    80004ee6:	ffffd097          	auipc	ra,0xffffd
    80004eea:	29a080e7          	jalr	666(ra) # 80002180 <wakeup>
    80004eee:	b7e9                	j	80004eb8 <pipeclose+0x2c>
    release(&pi->lock);
    80004ef0:	8526                	mv	a0,s1
    80004ef2:	ffffc097          	auipc	ra,0xffffc
    80004ef6:	d98080e7          	jalr	-616(ra) # 80000c8a <release>
}
    80004efa:	bfe1                	j	80004ed2 <pipeclose+0x46>

0000000080004efc <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004efc:	711d                	addi	sp,sp,-96
    80004efe:	ec86                	sd	ra,88(sp)
    80004f00:	e8a2                	sd	s0,80(sp)
    80004f02:	e4a6                	sd	s1,72(sp)
    80004f04:	e0ca                	sd	s2,64(sp)
    80004f06:	fc4e                	sd	s3,56(sp)
    80004f08:	f852                	sd	s4,48(sp)
    80004f0a:	f456                	sd	s5,40(sp)
    80004f0c:	f05a                	sd	s6,32(sp)
    80004f0e:	ec5e                	sd	s7,24(sp)
    80004f10:	e862                	sd	s8,16(sp)
    80004f12:	1080                	addi	s0,sp,96
    80004f14:	84aa                	mv	s1,a0
    80004f16:	8aae                	mv	s5,a1
    80004f18:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004f1a:	ffffd097          	auipc	ra,0xffffd
    80004f1e:	aaa080e7          	jalr	-1366(ra) # 800019c4 <myproc>
    80004f22:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004f24:	8526                	mv	a0,s1
    80004f26:	ffffc097          	auipc	ra,0xffffc
    80004f2a:	cb0080e7          	jalr	-848(ra) # 80000bd6 <acquire>
  while(i < n){
    80004f2e:	0b405663          	blez	s4,80004fda <pipewrite+0xde>
  int i = 0;
    80004f32:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004f34:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004f36:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004f3a:	21c48b93          	addi	s7,s1,540
    80004f3e:	a089                	j	80004f80 <pipewrite+0x84>
      release(&pi->lock);
    80004f40:	8526                	mv	a0,s1
    80004f42:	ffffc097          	auipc	ra,0xffffc
    80004f46:	d48080e7          	jalr	-696(ra) # 80000c8a <release>
      return -1;
    80004f4a:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004f4c:	854a                	mv	a0,s2
    80004f4e:	60e6                	ld	ra,88(sp)
    80004f50:	6446                	ld	s0,80(sp)
    80004f52:	64a6                	ld	s1,72(sp)
    80004f54:	6906                	ld	s2,64(sp)
    80004f56:	79e2                	ld	s3,56(sp)
    80004f58:	7a42                	ld	s4,48(sp)
    80004f5a:	7aa2                	ld	s5,40(sp)
    80004f5c:	7b02                	ld	s6,32(sp)
    80004f5e:	6be2                	ld	s7,24(sp)
    80004f60:	6c42                	ld	s8,16(sp)
    80004f62:	6125                	addi	sp,sp,96
    80004f64:	8082                	ret
      wakeup(&pi->nread);
    80004f66:	8562                	mv	a0,s8
    80004f68:	ffffd097          	auipc	ra,0xffffd
    80004f6c:	218080e7          	jalr	536(ra) # 80002180 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004f70:	85a6                	mv	a1,s1
    80004f72:	855e                	mv	a0,s7
    80004f74:	ffffd097          	auipc	ra,0xffffd
    80004f78:	1a8080e7          	jalr	424(ra) # 8000211c <sleep>
  while(i < n){
    80004f7c:	07495063          	bge	s2,s4,80004fdc <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004f80:	2204a783          	lw	a5,544(s1)
    80004f84:	dfd5                	beqz	a5,80004f40 <pipewrite+0x44>
    80004f86:	854e                	mv	a0,s3
    80004f88:	ffffd097          	auipc	ra,0xffffd
    80004f8c:	43c080e7          	jalr	1084(ra) # 800023c4 <killed>
    80004f90:	f945                	bnez	a0,80004f40 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004f92:	2184a783          	lw	a5,536(s1)
    80004f96:	21c4a703          	lw	a4,540(s1)
    80004f9a:	2007879b          	addiw	a5,a5,512
    80004f9e:	fcf704e3          	beq	a4,a5,80004f66 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004fa2:	4685                	li	a3,1
    80004fa4:	01590633          	add	a2,s2,s5
    80004fa8:	faf40593          	addi	a1,s0,-81
    80004fac:	0509b503          	ld	a0,80(s3)
    80004fb0:	ffffc097          	auipc	ra,0xffffc
    80004fb4:	748080e7          	jalr	1864(ra) # 800016f8 <copyin>
    80004fb8:	03650263          	beq	a0,s6,80004fdc <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004fbc:	21c4a783          	lw	a5,540(s1)
    80004fc0:	0017871b          	addiw	a4,a5,1
    80004fc4:	20e4ae23          	sw	a4,540(s1)
    80004fc8:	1ff7f793          	andi	a5,a5,511
    80004fcc:	97a6                	add	a5,a5,s1
    80004fce:	faf44703          	lbu	a4,-81(s0)
    80004fd2:	00e78c23          	sb	a4,24(a5)
      i++;
    80004fd6:	2905                	addiw	s2,s2,1
    80004fd8:	b755                	j	80004f7c <pipewrite+0x80>
  int i = 0;
    80004fda:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004fdc:	21848513          	addi	a0,s1,536
    80004fe0:	ffffd097          	auipc	ra,0xffffd
    80004fe4:	1a0080e7          	jalr	416(ra) # 80002180 <wakeup>
  release(&pi->lock);
    80004fe8:	8526                	mv	a0,s1
    80004fea:	ffffc097          	auipc	ra,0xffffc
    80004fee:	ca0080e7          	jalr	-864(ra) # 80000c8a <release>
  return i;
    80004ff2:	bfa9                	j	80004f4c <pipewrite+0x50>

0000000080004ff4 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004ff4:	715d                	addi	sp,sp,-80
    80004ff6:	e486                	sd	ra,72(sp)
    80004ff8:	e0a2                	sd	s0,64(sp)
    80004ffa:	fc26                	sd	s1,56(sp)
    80004ffc:	f84a                	sd	s2,48(sp)
    80004ffe:	f44e                	sd	s3,40(sp)
    80005000:	f052                	sd	s4,32(sp)
    80005002:	ec56                	sd	s5,24(sp)
    80005004:	e85a                	sd	s6,16(sp)
    80005006:	0880                	addi	s0,sp,80
    80005008:	84aa                	mv	s1,a0
    8000500a:	892e                	mv	s2,a1
    8000500c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000500e:	ffffd097          	auipc	ra,0xffffd
    80005012:	9b6080e7          	jalr	-1610(ra) # 800019c4 <myproc>
    80005016:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005018:	8526                	mv	a0,s1
    8000501a:	ffffc097          	auipc	ra,0xffffc
    8000501e:	bbc080e7          	jalr	-1092(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005022:	2184a703          	lw	a4,536(s1)
    80005026:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000502a:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000502e:	02f71763          	bne	a4,a5,8000505c <piperead+0x68>
    80005032:	2244a783          	lw	a5,548(s1)
    80005036:	c39d                	beqz	a5,8000505c <piperead+0x68>
    if(killed(pr)){
    80005038:	8552                	mv	a0,s4
    8000503a:	ffffd097          	auipc	ra,0xffffd
    8000503e:	38a080e7          	jalr	906(ra) # 800023c4 <killed>
    80005042:	e949                	bnez	a0,800050d4 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005044:	85a6                	mv	a1,s1
    80005046:	854e                	mv	a0,s3
    80005048:	ffffd097          	auipc	ra,0xffffd
    8000504c:	0d4080e7          	jalr	212(ra) # 8000211c <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005050:	2184a703          	lw	a4,536(s1)
    80005054:	21c4a783          	lw	a5,540(s1)
    80005058:	fcf70de3          	beq	a4,a5,80005032 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000505c:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000505e:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005060:	05505463          	blez	s5,800050a8 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80005064:	2184a783          	lw	a5,536(s1)
    80005068:	21c4a703          	lw	a4,540(s1)
    8000506c:	02f70e63          	beq	a4,a5,800050a8 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005070:	0017871b          	addiw	a4,a5,1
    80005074:	20e4ac23          	sw	a4,536(s1)
    80005078:	1ff7f793          	andi	a5,a5,511
    8000507c:	97a6                	add	a5,a5,s1
    8000507e:	0187c783          	lbu	a5,24(a5)
    80005082:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005086:	4685                	li	a3,1
    80005088:	fbf40613          	addi	a2,s0,-65
    8000508c:	85ca                	mv	a1,s2
    8000508e:	050a3503          	ld	a0,80(s4)
    80005092:	ffffc097          	auipc	ra,0xffffc
    80005096:	5da080e7          	jalr	1498(ra) # 8000166c <copyout>
    8000509a:	01650763          	beq	a0,s6,800050a8 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000509e:	2985                	addiw	s3,s3,1
    800050a0:	0905                	addi	s2,s2,1
    800050a2:	fd3a91e3          	bne	s5,s3,80005064 <piperead+0x70>
    800050a6:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800050a8:	21c48513          	addi	a0,s1,540
    800050ac:	ffffd097          	auipc	ra,0xffffd
    800050b0:	0d4080e7          	jalr	212(ra) # 80002180 <wakeup>
  release(&pi->lock);
    800050b4:	8526                	mv	a0,s1
    800050b6:	ffffc097          	auipc	ra,0xffffc
    800050ba:	bd4080e7          	jalr	-1068(ra) # 80000c8a <release>
  return i;
}
    800050be:	854e                	mv	a0,s3
    800050c0:	60a6                	ld	ra,72(sp)
    800050c2:	6406                	ld	s0,64(sp)
    800050c4:	74e2                	ld	s1,56(sp)
    800050c6:	7942                	ld	s2,48(sp)
    800050c8:	79a2                	ld	s3,40(sp)
    800050ca:	7a02                	ld	s4,32(sp)
    800050cc:	6ae2                	ld	s5,24(sp)
    800050ce:	6b42                	ld	s6,16(sp)
    800050d0:	6161                	addi	sp,sp,80
    800050d2:	8082                	ret
      release(&pi->lock);
    800050d4:	8526                	mv	a0,s1
    800050d6:	ffffc097          	auipc	ra,0xffffc
    800050da:	bb4080e7          	jalr	-1100(ra) # 80000c8a <release>
      return -1;
    800050de:	59fd                	li	s3,-1
    800050e0:	bff9                	j	800050be <piperead+0xca>

00000000800050e2 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800050e2:	1141                	addi	sp,sp,-16
    800050e4:	e422                	sd	s0,8(sp)
    800050e6:	0800                	addi	s0,sp,16
    800050e8:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800050ea:	8905                	andi	a0,a0,1
    800050ec:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    800050ee:	8b89                	andi	a5,a5,2
    800050f0:	c399                	beqz	a5,800050f6 <flags2perm+0x14>
      perm |= PTE_W;
    800050f2:	00456513          	ori	a0,a0,4
    return perm;
}
    800050f6:	6422                	ld	s0,8(sp)
    800050f8:	0141                	addi	sp,sp,16
    800050fa:	8082                	ret

00000000800050fc <exec>:

int
exec(char *path, char **argv)
{
    800050fc:	de010113          	addi	sp,sp,-544
    80005100:	20113c23          	sd	ra,536(sp)
    80005104:	20813823          	sd	s0,528(sp)
    80005108:	20913423          	sd	s1,520(sp)
    8000510c:	21213023          	sd	s2,512(sp)
    80005110:	ffce                	sd	s3,504(sp)
    80005112:	fbd2                	sd	s4,496(sp)
    80005114:	f7d6                	sd	s5,488(sp)
    80005116:	f3da                	sd	s6,480(sp)
    80005118:	efde                	sd	s7,472(sp)
    8000511a:	ebe2                	sd	s8,464(sp)
    8000511c:	e7e6                	sd	s9,456(sp)
    8000511e:	e3ea                	sd	s10,448(sp)
    80005120:	ff6e                	sd	s11,440(sp)
    80005122:	1400                	addi	s0,sp,544
    80005124:	892a                	mv	s2,a0
    80005126:	dea43423          	sd	a0,-536(s0)
    8000512a:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000512e:	ffffd097          	auipc	ra,0xffffd
    80005132:	896080e7          	jalr	-1898(ra) # 800019c4 <myproc>
    80005136:	84aa                	mv	s1,a0

  begin_op();
    80005138:	fffff097          	auipc	ra,0xfffff
    8000513c:	482080e7          	jalr	1154(ra) # 800045ba <begin_op>

  if((ip = namei(path)) == 0){
    80005140:	854a                	mv	a0,s2
    80005142:	fffff097          	auipc	ra,0xfffff
    80005146:	258080e7          	jalr	600(ra) # 8000439a <namei>
    8000514a:	c93d                	beqz	a0,800051c0 <exec+0xc4>
    8000514c:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000514e:	fffff097          	auipc	ra,0xfffff
    80005152:	aa0080e7          	jalr	-1376(ra) # 80003bee <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005156:	04000713          	li	a4,64
    8000515a:	4681                	li	a3,0
    8000515c:	e5040613          	addi	a2,s0,-432
    80005160:	4581                	li	a1,0
    80005162:	8556                	mv	a0,s5
    80005164:	fffff097          	auipc	ra,0xfffff
    80005168:	d3e080e7          	jalr	-706(ra) # 80003ea2 <readi>
    8000516c:	04000793          	li	a5,64
    80005170:	00f51a63          	bne	a0,a5,80005184 <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80005174:	e5042703          	lw	a4,-432(s0)
    80005178:	464c47b7          	lui	a5,0x464c4
    8000517c:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005180:	04f70663          	beq	a4,a5,800051cc <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005184:	8556                	mv	a0,s5
    80005186:	fffff097          	auipc	ra,0xfffff
    8000518a:	cca080e7          	jalr	-822(ra) # 80003e50 <iunlockput>
    end_op();
    8000518e:	fffff097          	auipc	ra,0xfffff
    80005192:	4aa080e7          	jalr	1194(ra) # 80004638 <end_op>
  }
  return -1;
    80005196:	557d                	li	a0,-1
}
    80005198:	21813083          	ld	ra,536(sp)
    8000519c:	21013403          	ld	s0,528(sp)
    800051a0:	20813483          	ld	s1,520(sp)
    800051a4:	20013903          	ld	s2,512(sp)
    800051a8:	79fe                	ld	s3,504(sp)
    800051aa:	7a5e                	ld	s4,496(sp)
    800051ac:	7abe                	ld	s5,488(sp)
    800051ae:	7b1e                	ld	s6,480(sp)
    800051b0:	6bfe                	ld	s7,472(sp)
    800051b2:	6c5e                	ld	s8,464(sp)
    800051b4:	6cbe                	ld	s9,456(sp)
    800051b6:	6d1e                	ld	s10,448(sp)
    800051b8:	7dfa                	ld	s11,440(sp)
    800051ba:	22010113          	addi	sp,sp,544
    800051be:	8082                	ret
    end_op();
    800051c0:	fffff097          	auipc	ra,0xfffff
    800051c4:	478080e7          	jalr	1144(ra) # 80004638 <end_op>
    return -1;
    800051c8:	557d                	li	a0,-1
    800051ca:	b7f9                	j	80005198 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    800051cc:	8526                	mv	a0,s1
    800051ce:	ffffd097          	auipc	ra,0xffffd
    800051d2:	8ba080e7          	jalr	-1862(ra) # 80001a88 <proc_pagetable>
    800051d6:	8b2a                	mv	s6,a0
    800051d8:	d555                	beqz	a0,80005184 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800051da:	e7042783          	lw	a5,-400(s0)
    800051de:	e8845703          	lhu	a4,-376(s0)
    800051e2:	c735                	beqz	a4,8000524e <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800051e4:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800051e6:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    800051ea:	6a05                	lui	s4,0x1
    800051ec:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    800051f0:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    800051f4:	6d85                	lui	s11,0x1
    800051f6:	7d7d                	lui	s10,0xfffff
    800051f8:	ac3d                	j	80005436 <exec+0x33a>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800051fa:	00003517          	auipc	a0,0x3
    800051fe:	5be50513          	addi	a0,a0,1470 # 800087b8 <syscalls+0x2b0>
    80005202:	ffffb097          	auipc	ra,0xffffb
    80005206:	33e080e7          	jalr	830(ra) # 80000540 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000520a:	874a                	mv	a4,s2
    8000520c:	009c86bb          	addw	a3,s9,s1
    80005210:	4581                	li	a1,0
    80005212:	8556                	mv	a0,s5
    80005214:	fffff097          	auipc	ra,0xfffff
    80005218:	c8e080e7          	jalr	-882(ra) # 80003ea2 <readi>
    8000521c:	2501                	sext.w	a0,a0
    8000521e:	1aa91963          	bne	s2,a0,800053d0 <exec+0x2d4>
  for(i = 0; i < sz; i += PGSIZE){
    80005222:	009d84bb          	addw	s1,s11,s1
    80005226:	013d09bb          	addw	s3,s10,s3
    8000522a:	1f74f663          	bgeu	s1,s7,80005416 <exec+0x31a>
    pa = walkaddr(pagetable, va + i);
    8000522e:	02049593          	slli	a1,s1,0x20
    80005232:	9181                	srli	a1,a1,0x20
    80005234:	95e2                	add	a1,a1,s8
    80005236:	855a                	mv	a0,s6
    80005238:	ffffc097          	auipc	ra,0xffffc
    8000523c:	e24080e7          	jalr	-476(ra) # 8000105c <walkaddr>
    80005240:	862a                	mv	a2,a0
    if(pa == 0)
    80005242:	dd45                	beqz	a0,800051fa <exec+0xfe>
      n = PGSIZE;
    80005244:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005246:	fd49f2e3          	bgeu	s3,s4,8000520a <exec+0x10e>
      n = sz - i;
    8000524a:	894e                	mv	s2,s3
    8000524c:	bf7d                	j	8000520a <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000524e:	4901                	li	s2,0
  iunlockput(ip);
    80005250:	8556                	mv	a0,s5
    80005252:	fffff097          	auipc	ra,0xfffff
    80005256:	bfe080e7          	jalr	-1026(ra) # 80003e50 <iunlockput>
  end_op();
    8000525a:	fffff097          	auipc	ra,0xfffff
    8000525e:	3de080e7          	jalr	990(ra) # 80004638 <end_op>
  p = myproc();
    80005262:	ffffc097          	auipc	ra,0xffffc
    80005266:	762080e7          	jalr	1890(ra) # 800019c4 <myproc>
    8000526a:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    8000526c:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005270:	6785                	lui	a5,0x1
    80005272:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80005274:	97ca                	add	a5,a5,s2
    80005276:	777d                	lui	a4,0xfffff
    80005278:	8ff9                	and	a5,a5,a4
    8000527a:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    8000527e:	4691                	li	a3,4
    80005280:	6609                	lui	a2,0x2
    80005282:	963e                	add	a2,a2,a5
    80005284:	85be                	mv	a1,a5
    80005286:	855a                	mv	a0,s6
    80005288:	ffffc097          	auipc	ra,0xffffc
    8000528c:	188080e7          	jalr	392(ra) # 80001410 <uvmalloc>
    80005290:	8c2a                	mv	s8,a0
  ip = 0;
    80005292:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005294:	12050e63          	beqz	a0,800053d0 <exec+0x2d4>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005298:	75f9                	lui	a1,0xffffe
    8000529a:	95aa                	add	a1,a1,a0
    8000529c:	855a                	mv	a0,s6
    8000529e:	ffffc097          	auipc	ra,0xffffc
    800052a2:	39c080e7          	jalr	924(ra) # 8000163a <uvmclear>
  stackbase = sp - PGSIZE;
    800052a6:	7afd                	lui	s5,0xfffff
    800052a8:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    800052aa:	df043783          	ld	a5,-528(s0)
    800052ae:	6388                	ld	a0,0(a5)
    800052b0:	c925                	beqz	a0,80005320 <exec+0x224>
    800052b2:	e9040993          	addi	s3,s0,-368
    800052b6:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800052ba:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800052bc:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800052be:	ffffc097          	auipc	ra,0xffffc
    800052c2:	b90080e7          	jalr	-1136(ra) # 80000e4e <strlen>
    800052c6:	0015079b          	addiw	a5,a0,1
    800052ca:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800052ce:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800052d2:	13596663          	bltu	s2,s5,800053fe <exec+0x302>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800052d6:	df043d83          	ld	s11,-528(s0)
    800052da:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    800052de:	8552                	mv	a0,s4
    800052e0:	ffffc097          	auipc	ra,0xffffc
    800052e4:	b6e080e7          	jalr	-1170(ra) # 80000e4e <strlen>
    800052e8:	0015069b          	addiw	a3,a0,1
    800052ec:	8652                	mv	a2,s4
    800052ee:	85ca                	mv	a1,s2
    800052f0:	855a                	mv	a0,s6
    800052f2:	ffffc097          	auipc	ra,0xffffc
    800052f6:	37a080e7          	jalr	890(ra) # 8000166c <copyout>
    800052fa:	10054663          	bltz	a0,80005406 <exec+0x30a>
    ustack[argc] = sp;
    800052fe:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005302:	0485                	addi	s1,s1,1
    80005304:	008d8793          	addi	a5,s11,8
    80005308:	def43823          	sd	a5,-528(s0)
    8000530c:	008db503          	ld	a0,8(s11)
    80005310:	c911                	beqz	a0,80005324 <exec+0x228>
    if(argc >= MAXARG)
    80005312:	09a1                	addi	s3,s3,8
    80005314:	fb3c95e3          	bne	s9,s3,800052be <exec+0x1c2>
  sz = sz1;
    80005318:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000531c:	4a81                	li	s5,0
    8000531e:	a84d                	j	800053d0 <exec+0x2d4>
  sp = sz;
    80005320:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005322:	4481                	li	s1,0
  ustack[argc] = 0;
    80005324:	00349793          	slli	a5,s1,0x3
    80005328:	f9078793          	addi	a5,a5,-112
    8000532c:	97a2                	add	a5,a5,s0
    8000532e:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005332:	00148693          	addi	a3,s1,1
    80005336:	068e                	slli	a3,a3,0x3
    80005338:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000533c:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005340:	01597663          	bgeu	s2,s5,8000534c <exec+0x250>
  sz = sz1;
    80005344:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005348:	4a81                	li	s5,0
    8000534a:	a059                	j	800053d0 <exec+0x2d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000534c:	e9040613          	addi	a2,s0,-368
    80005350:	85ca                	mv	a1,s2
    80005352:	855a                	mv	a0,s6
    80005354:	ffffc097          	auipc	ra,0xffffc
    80005358:	318080e7          	jalr	792(ra) # 8000166c <copyout>
    8000535c:	0a054963          	bltz	a0,8000540e <exec+0x312>
  p->trapframe->a1 = sp;
    80005360:	058bb783          	ld	a5,88(s7)
    80005364:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005368:	de843783          	ld	a5,-536(s0)
    8000536c:	0007c703          	lbu	a4,0(a5)
    80005370:	cf11                	beqz	a4,8000538c <exec+0x290>
    80005372:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005374:	02f00693          	li	a3,47
    80005378:	a039                	j	80005386 <exec+0x28a>
      last = s+1;
    8000537a:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    8000537e:	0785                	addi	a5,a5,1
    80005380:	fff7c703          	lbu	a4,-1(a5)
    80005384:	c701                	beqz	a4,8000538c <exec+0x290>
    if(*s == '/')
    80005386:	fed71ce3          	bne	a4,a3,8000537e <exec+0x282>
    8000538a:	bfc5                	j	8000537a <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    8000538c:	4641                	li	a2,16
    8000538e:	de843583          	ld	a1,-536(s0)
    80005392:	158b8513          	addi	a0,s7,344
    80005396:	ffffc097          	auipc	ra,0xffffc
    8000539a:	a86080e7          	jalr	-1402(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    8000539e:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    800053a2:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    800053a6:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800053aa:	058bb783          	ld	a5,88(s7)
    800053ae:	e6843703          	ld	a4,-408(s0)
    800053b2:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800053b4:	058bb783          	ld	a5,88(s7)
    800053b8:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800053bc:	85ea                	mv	a1,s10
    800053be:	ffffc097          	auipc	ra,0xffffc
    800053c2:	766080e7          	jalr	1894(ra) # 80001b24 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800053c6:	0004851b          	sext.w	a0,s1
    800053ca:	b3f9                	j	80005198 <exec+0x9c>
    800053cc:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    800053d0:	df843583          	ld	a1,-520(s0)
    800053d4:	855a                	mv	a0,s6
    800053d6:	ffffc097          	auipc	ra,0xffffc
    800053da:	74e080e7          	jalr	1870(ra) # 80001b24 <proc_freepagetable>
  if(ip){
    800053de:	da0a93e3          	bnez	s5,80005184 <exec+0x88>
  return -1;
    800053e2:	557d                	li	a0,-1
    800053e4:	bb55                	j	80005198 <exec+0x9c>
    800053e6:	df243c23          	sd	s2,-520(s0)
    800053ea:	b7dd                	j	800053d0 <exec+0x2d4>
    800053ec:	df243c23          	sd	s2,-520(s0)
    800053f0:	b7c5                	j	800053d0 <exec+0x2d4>
    800053f2:	df243c23          	sd	s2,-520(s0)
    800053f6:	bfe9                	j	800053d0 <exec+0x2d4>
    800053f8:	df243c23          	sd	s2,-520(s0)
    800053fc:	bfd1                	j	800053d0 <exec+0x2d4>
  sz = sz1;
    800053fe:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005402:	4a81                	li	s5,0
    80005404:	b7f1                	j	800053d0 <exec+0x2d4>
  sz = sz1;
    80005406:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000540a:	4a81                	li	s5,0
    8000540c:	b7d1                	j	800053d0 <exec+0x2d4>
  sz = sz1;
    8000540e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005412:	4a81                	li	s5,0
    80005414:	bf75                	j	800053d0 <exec+0x2d4>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005416:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000541a:	e0843783          	ld	a5,-504(s0)
    8000541e:	0017869b          	addiw	a3,a5,1
    80005422:	e0d43423          	sd	a3,-504(s0)
    80005426:	e0043783          	ld	a5,-512(s0)
    8000542a:	0387879b          	addiw	a5,a5,56
    8000542e:	e8845703          	lhu	a4,-376(s0)
    80005432:	e0e6dfe3          	bge	a3,a4,80005250 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005436:	2781                	sext.w	a5,a5
    80005438:	e0f43023          	sd	a5,-512(s0)
    8000543c:	03800713          	li	a4,56
    80005440:	86be                	mv	a3,a5
    80005442:	e1840613          	addi	a2,s0,-488
    80005446:	4581                	li	a1,0
    80005448:	8556                	mv	a0,s5
    8000544a:	fffff097          	auipc	ra,0xfffff
    8000544e:	a58080e7          	jalr	-1448(ra) # 80003ea2 <readi>
    80005452:	03800793          	li	a5,56
    80005456:	f6f51be3          	bne	a0,a5,800053cc <exec+0x2d0>
    if(ph.type != ELF_PROG_LOAD)
    8000545a:	e1842783          	lw	a5,-488(s0)
    8000545e:	4705                	li	a4,1
    80005460:	fae79de3          	bne	a5,a4,8000541a <exec+0x31e>
    if(ph.memsz < ph.filesz)
    80005464:	e4043483          	ld	s1,-448(s0)
    80005468:	e3843783          	ld	a5,-456(s0)
    8000546c:	f6f4ede3          	bltu	s1,a5,800053e6 <exec+0x2ea>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005470:	e2843783          	ld	a5,-472(s0)
    80005474:	94be                	add	s1,s1,a5
    80005476:	f6f4ebe3          	bltu	s1,a5,800053ec <exec+0x2f0>
    if(ph.vaddr % PGSIZE != 0)
    8000547a:	de043703          	ld	a4,-544(s0)
    8000547e:	8ff9                	and	a5,a5,a4
    80005480:	fbad                	bnez	a5,800053f2 <exec+0x2f6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005482:	e1c42503          	lw	a0,-484(s0)
    80005486:	00000097          	auipc	ra,0x0
    8000548a:	c5c080e7          	jalr	-932(ra) # 800050e2 <flags2perm>
    8000548e:	86aa                	mv	a3,a0
    80005490:	8626                	mv	a2,s1
    80005492:	85ca                	mv	a1,s2
    80005494:	855a                	mv	a0,s6
    80005496:	ffffc097          	auipc	ra,0xffffc
    8000549a:	f7a080e7          	jalr	-134(ra) # 80001410 <uvmalloc>
    8000549e:	dea43c23          	sd	a0,-520(s0)
    800054a2:	d939                	beqz	a0,800053f8 <exec+0x2fc>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800054a4:	e2843c03          	ld	s8,-472(s0)
    800054a8:	e2042c83          	lw	s9,-480(s0)
    800054ac:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800054b0:	f60b83e3          	beqz	s7,80005416 <exec+0x31a>
    800054b4:	89de                	mv	s3,s7
    800054b6:	4481                	li	s1,0
    800054b8:	bb9d                	j	8000522e <exec+0x132>

00000000800054ba <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800054ba:	7179                	addi	sp,sp,-48
    800054bc:	f406                	sd	ra,40(sp)
    800054be:	f022                	sd	s0,32(sp)
    800054c0:	ec26                	sd	s1,24(sp)
    800054c2:	e84a                	sd	s2,16(sp)
    800054c4:	1800                	addi	s0,sp,48
    800054c6:	892e                	mv	s2,a1
    800054c8:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800054ca:	fdc40593          	addi	a1,s0,-36
    800054ce:	ffffe097          	auipc	ra,0xffffe
    800054d2:	ab8080e7          	jalr	-1352(ra) # 80002f86 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800054d6:	fdc42703          	lw	a4,-36(s0)
    800054da:	47bd                	li	a5,15
    800054dc:	02e7eb63          	bltu	a5,a4,80005512 <argfd+0x58>
    800054e0:	ffffc097          	auipc	ra,0xffffc
    800054e4:	4e4080e7          	jalr	1252(ra) # 800019c4 <myproc>
    800054e8:	fdc42703          	lw	a4,-36(s0)
    800054ec:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffdc992>
    800054f0:	078e                	slli	a5,a5,0x3
    800054f2:	953e                	add	a0,a0,a5
    800054f4:	611c                	ld	a5,0(a0)
    800054f6:	c385                	beqz	a5,80005516 <argfd+0x5c>
    return -1;
  if(pfd)
    800054f8:	00090463          	beqz	s2,80005500 <argfd+0x46>
    *pfd = fd;
    800054fc:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005500:	4501                	li	a0,0
  if(pf)
    80005502:	c091                	beqz	s1,80005506 <argfd+0x4c>
    *pf = f;
    80005504:	e09c                	sd	a5,0(s1)
}
    80005506:	70a2                	ld	ra,40(sp)
    80005508:	7402                	ld	s0,32(sp)
    8000550a:	64e2                	ld	s1,24(sp)
    8000550c:	6942                	ld	s2,16(sp)
    8000550e:	6145                	addi	sp,sp,48
    80005510:	8082                	ret
    return -1;
    80005512:	557d                	li	a0,-1
    80005514:	bfcd                	j	80005506 <argfd+0x4c>
    80005516:	557d                	li	a0,-1
    80005518:	b7fd                	j	80005506 <argfd+0x4c>

000000008000551a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000551a:	1101                	addi	sp,sp,-32
    8000551c:	ec06                	sd	ra,24(sp)
    8000551e:	e822                	sd	s0,16(sp)
    80005520:	e426                	sd	s1,8(sp)
    80005522:	1000                	addi	s0,sp,32
    80005524:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005526:	ffffc097          	auipc	ra,0xffffc
    8000552a:	49e080e7          	jalr	1182(ra) # 800019c4 <myproc>
    8000552e:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005530:	0d050793          	addi	a5,a0,208
    80005534:	4501                	li	a0,0
    80005536:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005538:	6398                	ld	a4,0(a5)
    8000553a:	cb19                	beqz	a4,80005550 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000553c:	2505                	addiw	a0,a0,1
    8000553e:	07a1                	addi	a5,a5,8
    80005540:	fed51ce3          	bne	a0,a3,80005538 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005544:	557d                	li	a0,-1
}
    80005546:	60e2                	ld	ra,24(sp)
    80005548:	6442                	ld	s0,16(sp)
    8000554a:	64a2                	ld	s1,8(sp)
    8000554c:	6105                	addi	sp,sp,32
    8000554e:	8082                	ret
      p->ofile[fd] = f;
    80005550:	01a50793          	addi	a5,a0,26
    80005554:	078e                	slli	a5,a5,0x3
    80005556:	963e                	add	a2,a2,a5
    80005558:	e204                	sd	s1,0(a2)
      return fd;
    8000555a:	b7f5                	j	80005546 <fdalloc+0x2c>

000000008000555c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000555c:	715d                	addi	sp,sp,-80
    8000555e:	e486                	sd	ra,72(sp)
    80005560:	e0a2                	sd	s0,64(sp)
    80005562:	fc26                	sd	s1,56(sp)
    80005564:	f84a                	sd	s2,48(sp)
    80005566:	f44e                	sd	s3,40(sp)
    80005568:	f052                	sd	s4,32(sp)
    8000556a:	ec56                	sd	s5,24(sp)
    8000556c:	e85a                	sd	s6,16(sp)
    8000556e:	0880                	addi	s0,sp,80
    80005570:	8b2e                	mv	s6,a1
    80005572:	89b2                	mv	s3,a2
    80005574:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005576:	fb040593          	addi	a1,s0,-80
    8000557a:	fffff097          	auipc	ra,0xfffff
    8000557e:	e3e080e7          	jalr	-450(ra) # 800043b8 <nameiparent>
    80005582:	84aa                	mv	s1,a0
    80005584:	14050f63          	beqz	a0,800056e2 <create+0x186>
    return 0;

  ilock(dp);
    80005588:	ffffe097          	auipc	ra,0xffffe
    8000558c:	666080e7          	jalr	1638(ra) # 80003bee <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005590:	4601                	li	a2,0
    80005592:	fb040593          	addi	a1,s0,-80
    80005596:	8526                	mv	a0,s1
    80005598:	fffff097          	auipc	ra,0xfffff
    8000559c:	b3a080e7          	jalr	-1222(ra) # 800040d2 <dirlookup>
    800055a0:	8aaa                	mv	s5,a0
    800055a2:	c931                	beqz	a0,800055f6 <create+0x9a>
    iunlockput(dp);
    800055a4:	8526                	mv	a0,s1
    800055a6:	fffff097          	auipc	ra,0xfffff
    800055aa:	8aa080e7          	jalr	-1878(ra) # 80003e50 <iunlockput>
    ilock(ip);
    800055ae:	8556                	mv	a0,s5
    800055b0:	ffffe097          	auipc	ra,0xffffe
    800055b4:	63e080e7          	jalr	1598(ra) # 80003bee <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800055b8:	000b059b          	sext.w	a1,s6
    800055bc:	4789                	li	a5,2
    800055be:	02f59563          	bne	a1,a5,800055e8 <create+0x8c>
    800055c2:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdc9bc>
    800055c6:	37f9                	addiw	a5,a5,-2
    800055c8:	17c2                	slli	a5,a5,0x30
    800055ca:	93c1                	srli	a5,a5,0x30
    800055cc:	4705                	li	a4,1
    800055ce:	00f76d63          	bltu	a4,a5,800055e8 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800055d2:	8556                	mv	a0,s5
    800055d4:	60a6                	ld	ra,72(sp)
    800055d6:	6406                	ld	s0,64(sp)
    800055d8:	74e2                	ld	s1,56(sp)
    800055da:	7942                	ld	s2,48(sp)
    800055dc:	79a2                	ld	s3,40(sp)
    800055de:	7a02                	ld	s4,32(sp)
    800055e0:	6ae2                	ld	s5,24(sp)
    800055e2:	6b42                	ld	s6,16(sp)
    800055e4:	6161                	addi	sp,sp,80
    800055e6:	8082                	ret
    iunlockput(ip);
    800055e8:	8556                	mv	a0,s5
    800055ea:	fffff097          	auipc	ra,0xfffff
    800055ee:	866080e7          	jalr	-1946(ra) # 80003e50 <iunlockput>
    return 0;
    800055f2:	4a81                	li	s5,0
    800055f4:	bff9                	j	800055d2 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    800055f6:	85da                	mv	a1,s6
    800055f8:	4088                	lw	a0,0(s1)
    800055fa:	ffffe097          	auipc	ra,0xffffe
    800055fe:	456080e7          	jalr	1110(ra) # 80003a50 <ialloc>
    80005602:	8a2a                	mv	s4,a0
    80005604:	c539                	beqz	a0,80005652 <create+0xf6>
  ilock(ip);
    80005606:	ffffe097          	auipc	ra,0xffffe
    8000560a:	5e8080e7          	jalr	1512(ra) # 80003bee <ilock>
  ip->major = major;
    8000560e:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005612:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005616:	4905                	li	s2,1
    80005618:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    8000561c:	8552                	mv	a0,s4
    8000561e:	ffffe097          	auipc	ra,0xffffe
    80005622:	504080e7          	jalr	1284(ra) # 80003b22 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005626:	000b059b          	sext.w	a1,s6
    8000562a:	03258b63          	beq	a1,s2,80005660 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    8000562e:	004a2603          	lw	a2,4(s4)
    80005632:	fb040593          	addi	a1,s0,-80
    80005636:	8526                	mv	a0,s1
    80005638:	fffff097          	auipc	ra,0xfffff
    8000563c:	cb0080e7          	jalr	-848(ra) # 800042e8 <dirlink>
    80005640:	06054f63          	bltz	a0,800056be <create+0x162>
  iunlockput(dp);
    80005644:	8526                	mv	a0,s1
    80005646:	fffff097          	auipc	ra,0xfffff
    8000564a:	80a080e7          	jalr	-2038(ra) # 80003e50 <iunlockput>
  return ip;
    8000564e:	8ad2                	mv	s5,s4
    80005650:	b749                	j	800055d2 <create+0x76>
    iunlockput(dp);
    80005652:	8526                	mv	a0,s1
    80005654:	ffffe097          	auipc	ra,0xffffe
    80005658:	7fc080e7          	jalr	2044(ra) # 80003e50 <iunlockput>
    return 0;
    8000565c:	8ad2                	mv	s5,s4
    8000565e:	bf95                	j	800055d2 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005660:	004a2603          	lw	a2,4(s4)
    80005664:	00003597          	auipc	a1,0x3
    80005668:	17458593          	addi	a1,a1,372 # 800087d8 <syscalls+0x2d0>
    8000566c:	8552                	mv	a0,s4
    8000566e:	fffff097          	auipc	ra,0xfffff
    80005672:	c7a080e7          	jalr	-902(ra) # 800042e8 <dirlink>
    80005676:	04054463          	bltz	a0,800056be <create+0x162>
    8000567a:	40d0                	lw	a2,4(s1)
    8000567c:	00003597          	auipc	a1,0x3
    80005680:	16458593          	addi	a1,a1,356 # 800087e0 <syscalls+0x2d8>
    80005684:	8552                	mv	a0,s4
    80005686:	fffff097          	auipc	ra,0xfffff
    8000568a:	c62080e7          	jalr	-926(ra) # 800042e8 <dirlink>
    8000568e:	02054863          	bltz	a0,800056be <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    80005692:	004a2603          	lw	a2,4(s4)
    80005696:	fb040593          	addi	a1,s0,-80
    8000569a:	8526                	mv	a0,s1
    8000569c:	fffff097          	auipc	ra,0xfffff
    800056a0:	c4c080e7          	jalr	-948(ra) # 800042e8 <dirlink>
    800056a4:	00054d63          	bltz	a0,800056be <create+0x162>
    dp->nlink++;  // for ".."
    800056a8:	04a4d783          	lhu	a5,74(s1)
    800056ac:	2785                	addiw	a5,a5,1
    800056ae:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800056b2:	8526                	mv	a0,s1
    800056b4:	ffffe097          	auipc	ra,0xffffe
    800056b8:	46e080e7          	jalr	1134(ra) # 80003b22 <iupdate>
    800056bc:	b761                	j	80005644 <create+0xe8>
  ip->nlink = 0;
    800056be:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800056c2:	8552                	mv	a0,s4
    800056c4:	ffffe097          	auipc	ra,0xffffe
    800056c8:	45e080e7          	jalr	1118(ra) # 80003b22 <iupdate>
  iunlockput(ip);
    800056cc:	8552                	mv	a0,s4
    800056ce:	ffffe097          	auipc	ra,0xffffe
    800056d2:	782080e7          	jalr	1922(ra) # 80003e50 <iunlockput>
  iunlockput(dp);
    800056d6:	8526                	mv	a0,s1
    800056d8:	ffffe097          	auipc	ra,0xffffe
    800056dc:	778080e7          	jalr	1912(ra) # 80003e50 <iunlockput>
  return 0;
    800056e0:	bdcd                	j	800055d2 <create+0x76>
    return 0;
    800056e2:	8aaa                	mv	s5,a0
    800056e4:	b5fd                	j	800055d2 <create+0x76>

00000000800056e6 <sys_dup>:
{
    800056e6:	7179                	addi	sp,sp,-48
    800056e8:	f406                	sd	ra,40(sp)
    800056ea:	f022                	sd	s0,32(sp)
    800056ec:	ec26                	sd	s1,24(sp)
    800056ee:	e84a                	sd	s2,16(sp)
    800056f0:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800056f2:	fd840613          	addi	a2,s0,-40
    800056f6:	4581                	li	a1,0
    800056f8:	4501                	li	a0,0
    800056fa:	00000097          	auipc	ra,0x0
    800056fe:	dc0080e7          	jalr	-576(ra) # 800054ba <argfd>
    return -1;
    80005702:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005704:	02054363          	bltz	a0,8000572a <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    80005708:	fd843903          	ld	s2,-40(s0)
    8000570c:	854a                	mv	a0,s2
    8000570e:	00000097          	auipc	ra,0x0
    80005712:	e0c080e7          	jalr	-500(ra) # 8000551a <fdalloc>
    80005716:	84aa                	mv	s1,a0
    return -1;
    80005718:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000571a:	00054863          	bltz	a0,8000572a <sys_dup+0x44>
  filedup(f);
    8000571e:	854a                	mv	a0,s2
    80005720:	fffff097          	auipc	ra,0xfffff
    80005724:	310080e7          	jalr	784(ra) # 80004a30 <filedup>
  return fd;
    80005728:	87a6                	mv	a5,s1
}
    8000572a:	853e                	mv	a0,a5
    8000572c:	70a2                	ld	ra,40(sp)
    8000572e:	7402                	ld	s0,32(sp)
    80005730:	64e2                	ld	s1,24(sp)
    80005732:	6942                	ld	s2,16(sp)
    80005734:	6145                	addi	sp,sp,48
    80005736:	8082                	ret

0000000080005738 <sys_read>:
{
    80005738:	7179                	addi	sp,sp,-48
    8000573a:	f406                	sd	ra,40(sp)
    8000573c:	f022                	sd	s0,32(sp)
    8000573e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005740:	fd840593          	addi	a1,s0,-40
    80005744:	4505                	li	a0,1
    80005746:	ffffe097          	auipc	ra,0xffffe
    8000574a:	860080e7          	jalr	-1952(ra) # 80002fa6 <argaddr>
  argint(2, &n);
    8000574e:	fe440593          	addi	a1,s0,-28
    80005752:	4509                	li	a0,2
    80005754:	ffffe097          	auipc	ra,0xffffe
    80005758:	832080e7          	jalr	-1998(ra) # 80002f86 <argint>
  if(argfd(0, 0, &f) < 0)
    8000575c:	fe840613          	addi	a2,s0,-24
    80005760:	4581                	li	a1,0
    80005762:	4501                	li	a0,0
    80005764:	00000097          	auipc	ra,0x0
    80005768:	d56080e7          	jalr	-682(ra) # 800054ba <argfd>
    8000576c:	87aa                	mv	a5,a0
    return -1;
    8000576e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005770:	0007cc63          	bltz	a5,80005788 <sys_read+0x50>
  return fileread(f, p, n);
    80005774:	fe442603          	lw	a2,-28(s0)
    80005778:	fd843583          	ld	a1,-40(s0)
    8000577c:	fe843503          	ld	a0,-24(s0)
    80005780:	fffff097          	auipc	ra,0xfffff
    80005784:	43c080e7          	jalr	1084(ra) # 80004bbc <fileread>
}
    80005788:	70a2                	ld	ra,40(sp)
    8000578a:	7402                	ld	s0,32(sp)
    8000578c:	6145                	addi	sp,sp,48
    8000578e:	8082                	ret

0000000080005790 <sys_write>:
{
    80005790:	7179                	addi	sp,sp,-48
    80005792:	f406                	sd	ra,40(sp)
    80005794:	f022                	sd	s0,32(sp)
    80005796:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005798:	fd840593          	addi	a1,s0,-40
    8000579c:	4505                	li	a0,1
    8000579e:	ffffe097          	auipc	ra,0xffffe
    800057a2:	808080e7          	jalr	-2040(ra) # 80002fa6 <argaddr>
  argint(2, &n);
    800057a6:	fe440593          	addi	a1,s0,-28
    800057aa:	4509                	li	a0,2
    800057ac:	ffffd097          	auipc	ra,0xffffd
    800057b0:	7da080e7          	jalr	2010(ra) # 80002f86 <argint>
  if(argfd(0, 0, &f) < 0)
    800057b4:	fe840613          	addi	a2,s0,-24
    800057b8:	4581                	li	a1,0
    800057ba:	4501                	li	a0,0
    800057bc:	00000097          	auipc	ra,0x0
    800057c0:	cfe080e7          	jalr	-770(ra) # 800054ba <argfd>
    800057c4:	87aa                	mv	a5,a0
    return -1;
    800057c6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800057c8:	0007cc63          	bltz	a5,800057e0 <sys_write+0x50>
  return filewrite(f, p, n);
    800057cc:	fe442603          	lw	a2,-28(s0)
    800057d0:	fd843583          	ld	a1,-40(s0)
    800057d4:	fe843503          	ld	a0,-24(s0)
    800057d8:	fffff097          	auipc	ra,0xfffff
    800057dc:	4a6080e7          	jalr	1190(ra) # 80004c7e <filewrite>
}
    800057e0:	70a2                	ld	ra,40(sp)
    800057e2:	7402                	ld	s0,32(sp)
    800057e4:	6145                	addi	sp,sp,48
    800057e6:	8082                	ret

00000000800057e8 <sys_close>:
{
    800057e8:	1101                	addi	sp,sp,-32
    800057ea:	ec06                	sd	ra,24(sp)
    800057ec:	e822                	sd	s0,16(sp)
    800057ee:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800057f0:	fe040613          	addi	a2,s0,-32
    800057f4:	fec40593          	addi	a1,s0,-20
    800057f8:	4501                	li	a0,0
    800057fa:	00000097          	auipc	ra,0x0
    800057fe:	cc0080e7          	jalr	-832(ra) # 800054ba <argfd>
    return -1;
    80005802:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005804:	02054463          	bltz	a0,8000582c <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005808:	ffffc097          	auipc	ra,0xffffc
    8000580c:	1bc080e7          	jalr	444(ra) # 800019c4 <myproc>
    80005810:	fec42783          	lw	a5,-20(s0)
    80005814:	07e9                	addi	a5,a5,26
    80005816:	078e                	slli	a5,a5,0x3
    80005818:	953e                	add	a0,a0,a5
    8000581a:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000581e:	fe043503          	ld	a0,-32(s0)
    80005822:	fffff097          	auipc	ra,0xfffff
    80005826:	260080e7          	jalr	608(ra) # 80004a82 <fileclose>
  return 0;
    8000582a:	4781                	li	a5,0
}
    8000582c:	853e                	mv	a0,a5
    8000582e:	60e2                	ld	ra,24(sp)
    80005830:	6442                	ld	s0,16(sp)
    80005832:	6105                	addi	sp,sp,32
    80005834:	8082                	ret

0000000080005836 <sys_fstat>:
{
    80005836:	1101                	addi	sp,sp,-32
    80005838:	ec06                	sd	ra,24(sp)
    8000583a:	e822                	sd	s0,16(sp)
    8000583c:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000583e:	fe040593          	addi	a1,s0,-32
    80005842:	4505                	li	a0,1
    80005844:	ffffd097          	auipc	ra,0xffffd
    80005848:	762080e7          	jalr	1890(ra) # 80002fa6 <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000584c:	fe840613          	addi	a2,s0,-24
    80005850:	4581                	li	a1,0
    80005852:	4501                	li	a0,0
    80005854:	00000097          	auipc	ra,0x0
    80005858:	c66080e7          	jalr	-922(ra) # 800054ba <argfd>
    8000585c:	87aa                	mv	a5,a0
    return -1;
    8000585e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005860:	0007ca63          	bltz	a5,80005874 <sys_fstat+0x3e>
  return filestat(f, st);
    80005864:	fe043583          	ld	a1,-32(s0)
    80005868:	fe843503          	ld	a0,-24(s0)
    8000586c:	fffff097          	auipc	ra,0xfffff
    80005870:	2de080e7          	jalr	734(ra) # 80004b4a <filestat>
}
    80005874:	60e2                	ld	ra,24(sp)
    80005876:	6442                	ld	s0,16(sp)
    80005878:	6105                	addi	sp,sp,32
    8000587a:	8082                	ret

000000008000587c <sys_link>:
{
    8000587c:	7169                	addi	sp,sp,-304
    8000587e:	f606                	sd	ra,296(sp)
    80005880:	f222                	sd	s0,288(sp)
    80005882:	ee26                	sd	s1,280(sp)
    80005884:	ea4a                	sd	s2,272(sp)
    80005886:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005888:	08000613          	li	a2,128
    8000588c:	ed040593          	addi	a1,s0,-304
    80005890:	4501                	li	a0,0
    80005892:	ffffd097          	auipc	ra,0xffffd
    80005896:	734080e7          	jalr	1844(ra) # 80002fc6 <argstr>
    return -1;
    8000589a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000589c:	10054e63          	bltz	a0,800059b8 <sys_link+0x13c>
    800058a0:	08000613          	li	a2,128
    800058a4:	f5040593          	addi	a1,s0,-176
    800058a8:	4505                	li	a0,1
    800058aa:	ffffd097          	auipc	ra,0xffffd
    800058ae:	71c080e7          	jalr	1820(ra) # 80002fc6 <argstr>
    return -1;
    800058b2:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800058b4:	10054263          	bltz	a0,800059b8 <sys_link+0x13c>
  begin_op();
    800058b8:	fffff097          	auipc	ra,0xfffff
    800058bc:	d02080e7          	jalr	-766(ra) # 800045ba <begin_op>
  if((ip = namei(old)) == 0){
    800058c0:	ed040513          	addi	a0,s0,-304
    800058c4:	fffff097          	auipc	ra,0xfffff
    800058c8:	ad6080e7          	jalr	-1322(ra) # 8000439a <namei>
    800058cc:	84aa                	mv	s1,a0
    800058ce:	c551                	beqz	a0,8000595a <sys_link+0xde>
  ilock(ip);
    800058d0:	ffffe097          	auipc	ra,0xffffe
    800058d4:	31e080e7          	jalr	798(ra) # 80003bee <ilock>
  if(ip->type == T_DIR){
    800058d8:	04449703          	lh	a4,68(s1)
    800058dc:	4785                	li	a5,1
    800058de:	08f70463          	beq	a4,a5,80005966 <sys_link+0xea>
  ip->nlink++;
    800058e2:	04a4d783          	lhu	a5,74(s1)
    800058e6:	2785                	addiw	a5,a5,1
    800058e8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800058ec:	8526                	mv	a0,s1
    800058ee:	ffffe097          	auipc	ra,0xffffe
    800058f2:	234080e7          	jalr	564(ra) # 80003b22 <iupdate>
  iunlock(ip);
    800058f6:	8526                	mv	a0,s1
    800058f8:	ffffe097          	auipc	ra,0xffffe
    800058fc:	3b8080e7          	jalr	952(ra) # 80003cb0 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005900:	fd040593          	addi	a1,s0,-48
    80005904:	f5040513          	addi	a0,s0,-176
    80005908:	fffff097          	auipc	ra,0xfffff
    8000590c:	ab0080e7          	jalr	-1360(ra) # 800043b8 <nameiparent>
    80005910:	892a                	mv	s2,a0
    80005912:	c935                	beqz	a0,80005986 <sys_link+0x10a>
  ilock(dp);
    80005914:	ffffe097          	auipc	ra,0xffffe
    80005918:	2da080e7          	jalr	730(ra) # 80003bee <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000591c:	00092703          	lw	a4,0(s2)
    80005920:	409c                	lw	a5,0(s1)
    80005922:	04f71d63          	bne	a4,a5,8000597c <sys_link+0x100>
    80005926:	40d0                	lw	a2,4(s1)
    80005928:	fd040593          	addi	a1,s0,-48
    8000592c:	854a                	mv	a0,s2
    8000592e:	fffff097          	auipc	ra,0xfffff
    80005932:	9ba080e7          	jalr	-1606(ra) # 800042e8 <dirlink>
    80005936:	04054363          	bltz	a0,8000597c <sys_link+0x100>
  iunlockput(dp);
    8000593a:	854a                	mv	a0,s2
    8000593c:	ffffe097          	auipc	ra,0xffffe
    80005940:	514080e7          	jalr	1300(ra) # 80003e50 <iunlockput>
  iput(ip);
    80005944:	8526                	mv	a0,s1
    80005946:	ffffe097          	auipc	ra,0xffffe
    8000594a:	462080e7          	jalr	1122(ra) # 80003da8 <iput>
  end_op();
    8000594e:	fffff097          	auipc	ra,0xfffff
    80005952:	cea080e7          	jalr	-790(ra) # 80004638 <end_op>
  return 0;
    80005956:	4781                	li	a5,0
    80005958:	a085                	j	800059b8 <sys_link+0x13c>
    end_op();
    8000595a:	fffff097          	auipc	ra,0xfffff
    8000595e:	cde080e7          	jalr	-802(ra) # 80004638 <end_op>
    return -1;
    80005962:	57fd                	li	a5,-1
    80005964:	a891                	j	800059b8 <sys_link+0x13c>
    iunlockput(ip);
    80005966:	8526                	mv	a0,s1
    80005968:	ffffe097          	auipc	ra,0xffffe
    8000596c:	4e8080e7          	jalr	1256(ra) # 80003e50 <iunlockput>
    end_op();
    80005970:	fffff097          	auipc	ra,0xfffff
    80005974:	cc8080e7          	jalr	-824(ra) # 80004638 <end_op>
    return -1;
    80005978:	57fd                	li	a5,-1
    8000597a:	a83d                	j	800059b8 <sys_link+0x13c>
    iunlockput(dp);
    8000597c:	854a                	mv	a0,s2
    8000597e:	ffffe097          	auipc	ra,0xffffe
    80005982:	4d2080e7          	jalr	1234(ra) # 80003e50 <iunlockput>
  ilock(ip);
    80005986:	8526                	mv	a0,s1
    80005988:	ffffe097          	auipc	ra,0xffffe
    8000598c:	266080e7          	jalr	614(ra) # 80003bee <ilock>
  ip->nlink--;
    80005990:	04a4d783          	lhu	a5,74(s1)
    80005994:	37fd                	addiw	a5,a5,-1
    80005996:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000599a:	8526                	mv	a0,s1
    8000599c:	ffffe097          	auipc	ra,0xffffe
    800059a0:	186080e7          	jalr	390(ra) # 80003b22 <iupdate>
  iunlockput(ip);
    800059a4:	8526                	mv	a0,s1
    800059a6:	ffffe097          	auipc	ra,0xffffe
    800059aa:	4aa080e7          	jalr	1194(ra) # 80003e50 <iunlockput>
  end_op();
    800059ae:	fffff097          	auipc	ra,0xfffff
    800059b2:	c8a080e7          	jalr	-886(ra) # 80004638 <end_op>
  return -1;
    800059b6:	57fd                	li	a5,-1
}
    800059b8:	853e                	mv	a0,a5
    800059ba:	70b2                	ld	ra,296(sp)
    800059bc:	7412                	ld	s0,288(sp)
    800059be:	64f2                	ld	s1,280(sp)
    800059c0:	6952                	ld	s2,272(sp)
    800059c2:	6155                	addi	sp,sp,304
    800059c4:	8082                	ret

00000000800059c6 <sys_unlink>:
{
    800059c6:	7151                	addi	sp,sp,-240
    800059c8:	f586                	sd	ra,232(sp)
    800059ca:	f1a2                	sd	s0,224(sp)
    800059cc:	eda6                	sd	s1,216(sp)
    800059ce:	e9ca                	sd	s2,208(sp)
    800059d0:	e5ce                	sd	s3,200(sp)
    800059d2:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800059d4:	08000613          	li	a2,128
    800059d8:	f3040593          	addi	a1,s0,-208
    800059dc:	4501                	li	a0,0
    800059de:	ffffd097          	auipc	ra,0xffffd
    800059e2:	5e8080e7          	jalr	1512(ra) # 80002fc6 <argstr>
    800059e6:	18054163          	bltz	a0,80005b68 <sys_unlink+0x1a2>
  begin_op();
    800059ea:	fffff097          	auipc	ra,0xfffff
    800059ee:	bd0080e7          	jalr	-1072(ra) # 800045ba <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800059f2:	fb040593          	addi	a1,s0,-80
    800059f6:	f3040513          	addi	a0,s0,-208
    800059fa:	fffff097          	auipc	ra,0xfffff
    800059fe:	9be080e7          	jalr	-1602(ra) # 800043b8 <nameiparent>
    80005a02:	84aa                	mv	s1,a0
    80005a04:	c979                	beqz	a0,80005ada <sys_unlink+0x114>
  ilock(dp);
    80005a06:	ffffe097          	auipc	ra,0xffffe
    80005a0a:	1e8080e7          	jalr	488(ra) # 80003bee <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005a0e:	00003597          	auipc	a1,0x3
    80005a12:	dca58593          	addi	a1,a1,-566 # 800087d8 <syscalls+0x2d0>
    80005a16:	fb040513          	addi	a0,s0,-80
    80005a1a:	ffffe097          	auipc	ra,0xffffe
    80005a1e:	69e080e7          	jalr	1694(ra) # 800040b8 <namecmp>
    80005a22:	14050a63          	beqz	a0,80005b76 <sys_unlink+0x1b0>
    80005a26:	00003597          	auipc	a1,0x3
    80005a2a:	dba58593          	addi	a1,a1,-582 # 800087e0 <syscalls+0x2d8>
    80005a2e:	fb040513          	addi	a0,s0,-80
    80005a32:	ffffe097          	auipc	ra,0xffffe
    80005a36:	686080e7          	jalr	1670(ra) # 800040b8 <namecmp>
    80005a3a:	12050e63          	beqz	a0,80005b76 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005a3e:	f2c40613          	addi	a2,s0,-212
    80005a42:	fb040593          	addi	a1,s0,-80
    80005a46:	8526                	mv	a0,s1
    80005a48:	ffffe097          	auipc	ra,0xffffe
    80005a4c:	68a080e7          	jalr	1674(ra) # 800040d2 <dirlookup>
    80005a50:	892a                	mv	s2,a0
    80005a52:	12050263          	beqz	a0,80005b76 <sys_unlink+0x1b0>
  ilock(ip);
    80005a56:	ffffe097          	auipc	ra,0xffffe
    80005a5a:	198080e7          	jalr	408(ra) # 80003bee <ilock>
  if(ip->nlink < 1)
    80005a5e:	04a91783          	lh	a5,74(s2)
    80005a62:	08f05263          	blez	a5,80005ae6 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005a66:	04491703          	lh	a4,68(s2)
    80005a6a:	4785                	li	a5,1
    80005a6c:	08f70563          	beq	a4,a5,80005af6 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005a70:	4641                	li	a2,16
    80005a72:	4581                	li	a1,0
    80005a74:	fc040513          	addi	a0,s0,-64
    80005a78:	ffffb097          	auipc	ra,0xffffb
    80005a7c:	25a080e7          	jalr	602(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005a80:	4741                	li	a4,16
    80005a82:	f2c42683          	lw	a3,-212(s0)
    80005a86:	fc040613          	addi	a2,s0,-64
    80005a8a:	4581                	li	a1,0
    80005a8c:	8526                	mv	a0,s1
    80005a8e:	ffffe097          	auipc	ra,0xffffe
    80005a92:	50c080e7          	jalr	1292(ra) # 80003f9a <writei>
    80005a96:	47c1                	li	a5,16
    80005a98:	0af51563          	bne	a0,a5,80005b42 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005a9c:	04491703          	lh	a4,68(s2)
    80005aa0:	4785                	li	a5,1
    80005aa2:	0af70863          	beq	a4,a5,80005b52 <sys_unlink+0x18c>
  iunlockput(dp);
    80005aa6:	8526                	mv	a0,s1
    80005aa8:	ffffe097          	auipc	ra,0xffffe
    80005aac:	3a8080e7          	jalr	936(ra) # 80003e50 <iunlockput>
  ip->nlink--;
    80005ab0:	04a95783          	lhu	a5,74(s2)
    80005ab4:	37fd                	addiw	a5,a5,-1
    80005ab6:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005aba:	854a                	mv	a0,s2
    80005abc:	ffffe097          	auipc	ra,0xffffe
    80005ac0:	066080e7          	jalr	102(ra) # 80003b22 <iupdate>
  iunlockput(ip);
    80005ac4:	854a                	mv	a0,s2
    80005ac6:	ffffe097          	auipc	ra,0xffffe
    80005aca:	38a080e7          	jalr	906(ra) # 80003e50 <iunlockput>
  end_op();
    80005ace:	fffff097          	auipc	ra,0xfffff
    80005ad2:	b6a080e7          	jalr	-1174(ra) # 80004638 <end_op>
  return 0;
    80005ad6:	4501                	li	a0,0
    80005ad8:	a84d                	j	80005b8a <sys_unlink+0x1c4>
    end_op();
    80005ada:	fffff097          	auipc	ra,0xfffff
    80005ade:	b5e080e7          	jalr	-1186(ra) # 80004638 <end_op>
    return -1;
    80005ae2:	557d                	li	a0,-1
    80005ae4:	a05d                	j	80005b8a <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005ae6:	00003517          	auipc	a0,0x3
    80005aea:	d0250513          	addi	a0,a0,-766 # 800087e8 <syscalls+0x2e0>
    80005aee:	ffffb097          	auipc	ra,0xffffb
    80005af2:	a52080e7          	jalr	-1454(ra) # 80000540 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005af6:	04c92703          	lw	a4,76(s2)
    80005afa:	02000793          	li	a5,32
    80005afe:	f6e7f9e3          	bgeu	a5,a4,80005a70 <sys_unlink+0xaa>
    80005b02:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005b06:	4741                	li	a4,16
    80005b08:	86ce                	mv	a3,s3
    80005b0a:	f1840613          	addi	a2,s0,-232
    80005b0e:	4581                	li	a1,0
    80005b10:	854a                	mv	a0,s2
    80005b12:	ffffe097          	auipc	ra,0xffffe
    80005b16:	390080e7          	jalr	912(ra) # 80003ea2 <readi>
    80005b1a:	47c1                	li	a5,16
    80005b1c:	00f51b63          	bne	a0,a5,80005b32 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005b20:	f1845783          	lhu	a5,-232(s0)
    80005b24:	e7a1                	bnez	a5,80005b6c <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b26:	29c1                	addiw	s3,s3,16
    80005b28:	04c92783          	lw	a5,76(s2)
    80005b2c:	fcf9ede3          	bltu	s3,a5,80005b06 <sys_unlink+0x140>
    80005b30:	b781                	j	80005a70 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005b32:	00003517          	auipc	a0,0x3
    80005b36:	cce50513          	addi	a0,a0,-818 # 80008800 <syscalls+0x2f8>
    80005b3a:	ffffb097          	auipc	ra,0xffffb
    80005b3e:	a06080e7          	jalr	-1530(ra) # 80000540 <panic>
    panic("unlink: writei");
    80005b42:	00003517          	auipc	a0,0x3
    80005b46:	cd650513          	addi	a0,a0,-810 # 80008818 <syscalls+0x310>
    80005b4a:	ffffb097          	auipc	ra,0xffffb
    80005b4e:	9f6080e7          	jalr	-1546(ra) # 80000540 <panic>
    dp->nlink--;
    80005b52:	04a4d783          	lhu	a5,74(s1)
    80005b56:	37fd                	addiw	a5,a5,-1
    80005b58:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005b5c:	8526                	mv	a0,s1
    80005b5e:	ffffe097          	auipc	ra,0xffffe
    80005b62:	fc4080e7          	jalr	-60(ra) # 80003b22 <iupdate>
    80005b66:	b781                	j	80005aa6 <sys_unlink+0xe0>
    return -1;
    80005b68:	557d                	li	a0,-1
    80005b6a:	a005                	j	80005b8a <sys_unlink+0x1c4>
    iunlockput(ip);
    80005b6c:	854a                	mv	a0,s2
    80005b6e:	ffffe097          	auipc	ra,0xffffe
    80005b72:	2e2080e7          	jalr	738(ra) # 80003e50 <iunlockput>
  iunlockput(dp);
    80005b76:	8526                	mv	a0,s1
    80005b78:	ffffe097          	auipc	ra,0xffffe
    80005b7c:	2d8080e7          	jalr	728(ra) # 80003e50 <iunlockput>
  end_op();
    80005b80:	fffff097          	auipc	ra,0xfffff
    80005b84:	ab8080e7          	jalr	-1352(ra) # 80004638 <end_op>
  return -1;
    80005b88:	557d                	li	a0,-1
}
    80005b8a:	70ae                	ld	ra,232(sp)
    80005b8c:	740e                	ld	s0,224(sp)
    80005b8e:	64ee                	ld	s1,216(sp)
    80005b90:	694e                	ld	s2,208(sp)
    80005b92:	69ae                	ld	s3,200(sp)
    80005b94:	616d                	addi	sp,sp,240
    80005b96:	8082                	ret

0000000080005b98 <sys_open>:

uint64
sys_open(void)
{
    80005b98:	7131                	addi	sp,sp,-192
    80005b9a:	fd06                	sd	ra,184(sp)
    80005b9c:	f922                	sd	s0,176(sp)
    80005b9e:	f526                	sd	s1,168(sp)
    80005ba0:	f14a                	sd	s2,160(sp)
    80005ba2:	ed4e                	sd	s3,152(sp)
    80005ba4:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005ba6:	f4c40593          	addi	a1,s0,-180
    80005baa:	4505                	li	a0,1
    80005bac:	ffffd097          	auipc	ra,0xffffd
    80005bb0:	3da080e7          	jalr	986(ra) # 80002f86 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005bb4:	08000613          	li	a2,128
    80005bb8:	f5040593          	addi	a1,s0,-176
    80005bbc:	4501                	li	a0,0
    80005bbe:	ffffd097          	auipc	ra,0xffffd
    80005bc2:	408080e7          	jalr	1032(ra) # 80002fc6 <argstr>
    80005bc6:	87aa                	mv	a5,a0
    return -1;
    80005bc8:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005bca:	0a07c963          	bltz	a5,80005c7c <sys_open+0xe4>

  begin_op();
    80005bce:	fffff097          	auipc	ra,0xfffff
    80005bd2:	9ec080e7          	jalr	-1556(ra) # 800045ba <begin_op>

  if(omode & O_CREATE){
    80005bd6:	f4c42783          	lw	a5,-180(s0)
    80005bda:	2007f793          	andi	a5,a5,512
    80005bde:	cfc5                	beqz	a5,80005c96 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005be0:	4681                	li	a3,0
    80005be2:	4601                	li	a2,0
    80005be4:	4589                	li	a1,2
    80005be6:	f5040513          	addi	a0,s0,-176
    80005bea:	00000097          	auipc	ra,0x0
    80005bee:	972080e7          	jalr	-1678(ra) # 8000555c <create>
    80005bf2:	84aa                	mv	s1,a0
    if(ip == 0){
    80005bf4:	c959                	beqz	a0,80005c8a <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005bf6:	04449703          	lh	a4,68(s1)
    80005bfa:	478d                	li	a5,3
    80005bfc:	00f71763          	bne	a4,a5,80005c0a <sys_open+0x72>
    80005c00:	0464d703          	lhu	a4,70(s1)
    80005c04:	47a5                	li	a5,9
    80005c06:	0ce7ed63          	bltu	a5,a4,80005ce0 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005c0a:	fffff097          	auipc	ra,0xfffff
    80005c0e:	dbc080e7          	jalr	-580(ra) # 800049c6 <filealloc>
    80005c12:	89aa                	mv	s3,a0
    80005c14:	10050363          	beqz	a0,80005d1a <sys_open+0x182>
    80005c18:	00000097          	auipc	ra,0x0
    80005c1c:	902080e7          	jalr	-1790(ra) # 8000551a <fdalloc>
    80005c20:	892a                	mv	s2,a0
    80005c22:	0e054763          	bltz	a0,80005d10 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005c26:	04449703          	lh	a4,68(s1)
    80005c2a:	478d                	li	a5,3
    80005c2c:	0cf70563          	beq	a4,a5,80005cf6 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005c30:	4789                	li	a5,2
    80005c32:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005c36:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005c3a:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005c3e:	f4c42783          	lw	a5,-180(s0)
    80005c42:	0017c713          	xori	a4,a5,1
    80005c46:	8b05                	andi	a4,a4,1
    80005c48:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005c4c:	0037f713          	andi	a4,a5,3
    80005c50:	00e03733          	snez	a4,a4
    80005c54:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005c58:	4007f793          	andi	a5,a5,1024
    80005c5c:	c791                	beqz	a5,80005c68 <sys_open+0xd0>
    80005c5e:	04449703          	lh	a4,68(s1)
    80005c62:	4789                	li	a5,2
    80005c64:	0af70063          	beq	a4,a5,80005d04 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005c68:	8526                	mv	a0,s1
    80005c6a:	ffffe097          	auipc	ra,0xffffe
    80005c6e:	046080e7          	jalr	70(ra) # 80003cb0 <iunlock>
  end_op();
    80005c72:	fffff097          	auipc	ra,0xfffff
    80005c76:	9c6080e7          	jalr	-1594(ra) # 80004638 <end_op>

  return fd;
    80005c7a:	854a                	mv	a0,s2
}
    80005c7c:	70ea                	ld	ra,184(sp)
    80005c7e:	744a                	ld	s0,176(sp)
    80005c80:	74aa                	ld	s1,168(sp)
    80005c82:	790a                	ld	s2,160(sp)
    80005c84:	69ea                	ld	s3,152(sp)
    80005c86:	6129                	addi	sp,sp,192
    80005c88:	8082                	ret
      end_op();
    80005c8a:	fffff097          	auipc	ra,0xfffff
    80005c8e:	9ae080e7          	jalr	-1618(ra) # 80004638 <end_op>
      return -1;
    80005c92:	557d                	li	a0,-1
    80005c94:	b7e5                	j	80005c7c <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005c96:	f5040513          	addi	a0,s0,-176
    80005c9a:	ffffe097          	auipc	ra,0xffffe
    80005c9e:	700080e7          	jalr	1792(ra) # 8000439a <namei>
    80005ca2:	84aa                	mv	s1,a0
    80005ca4:	c905                	beqz	a0,80005cd4 <sys_open+0x13c>
    ilock(ip);
    80005ca6:	ffffe097          	auipc	ra,0xffffe
    80005caa:	f48080e7          	jalr	-184(ra) # 80003bee <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005cae:	04449703          	lh	a4,68(s1)
    80005cb2:	4785                	li	a5,1
    80005cb4:	f4f711e3          	bne	a4,a5,80005bf6 <sys_open+0x5e>
    80005cb8:	f4c42783          	lw	a5,-180(s0)
    80005cbc:	d7b9                	beqz	a5,80005c0a <sys_open+0x72>
      iunlockput(ip);
    80005cbe:	8526                	mv	a0,s1
    80005cc0:	ffffe097          	auipc	ra,0xffffe
    80005cc4:	190080e7          	jalr	400(ra) # 80003e50 <iunlockput>
      end_op();
    80005cc8:	fffff097          	auipc	ra,0xfffff
    80005ccc:	970080e7          	jalr	-1680(ra) # 80004638 <end_op>
      return -1;
    80005cd0:	557d                	li	a0,-1
    80005cd2:	b76d                	j	80005c7c <sys_open+0xe4>
      end_op();
    80005cd4:	fffff097          	auipc	ra,0xfffff
    80005cd8:	964080e7          	jalr	-1692(ra) # 80004638 <end_op>
      return -1;
    80005cdc:	557d                	li	a0,-1
    80005cde:	bf79                	j	80005c7c <sys_open+0xe4>
    iunlockput(ip);
    80005ce0:	8526                	mv	a0,s1
    80005ce2:	ffffe097          	auipc	ra,0xffffe
    80005ce6:	16e080e7          	jalr	366(ra) # 80003e50 <iunlockput>
    end_op();
    80005cea:	fffff097          	auipc	ra,0xfffff
    80005cee:	94e080e7          	jalr	-1714(ra) # 80004638 <end_op>
    return -1;
    80005cf2:	557d                	li	a0,-1
    80005cf4:	b761                	j	80005c7c <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005cf6:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005cfa:	04649783          	lh	a5,70(s1)
    80005cfe:	02f99223          	sh	a5,36(s3)
    80005d02:	bf25                	j	80005c3a <sys_open+0xa2>
    itrunc(ip);
    80005d04:	8526                	mv	a0,s1
    80005d06:	ffffe097          	auipc	ra,0xffffe
    80005d0a:	ff6080e7          	jalr	-10(ra) # 80003cfc <itrunc>
    80005d0e:	bfa9                	j	80005c68 <sys_open+0xd0>
      fileclose(f);
    80005d10:	854e                	mv	a0,s3
    80005d12:	fffff097          	auipc	ra,0xfffff
    80005d16:	d70080e7          	jalr	-656(ra) # 80004a82 <fileclose>
    iunlockput(ip);
    80005d1a:	8526                	mv	a0,s1
    80005d1c:	ffffe097          	auipc	ra,0xffffe
    80005d20:	134080e7          	jalr	308(ra) # 80003e50 <iunlockput>
    end_op();
    80005d24:	fffff097          	auipc	ra,0xfffff
    80005d28:	914080e7          	jalr	-1772(ra) # 80004638 <end_op>
    return -1;
    80005d2c:	557d                	li	a0,-1
    80005d2e:	b7b9                	j	80005c7c <sys_open+0xe4>

0000000080005d30 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005d30:	7175                	addi	sp,sp,-144
    80005d32:	e506                	sd	ra,136(sp)
    80005d34:	e122                	sd	s0,128(sp)
    80005d36:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005d38:	fffff097          	auipc	ra,0xfffff
    80005d3c:	882080e7          	jalr	-1918(ra) # 800045ba <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005d40:	08000613          	li	a2,128
    80005d44:	f7040593          	addi	a1,s0,-144
    80005d48:	4501                	li	a0,0
    80005d4a:	ffffd097          	auipc	ra,0xffffd
    80005d4e:	27c080e7          	jalr	636(ra) # 80002fc6 <argstr>
    80005d52:	02054963          	bltz	a0,80005d84 <sys_mkdir+0x54>
    80005d56:	4681                	li	a3,0
    80005d58:	4601                	li	a2,0
    80005d5a:	4585                	li	a1,1
    80005d5c:	f7040513          	addi	a0,s0,-144
    80005d60:	fffff097          	auipc	ra,0xfffff
    80005d64:	7fc080e7          	jalr	2044(ra) # 8000555c <create>
    80005d68:	cd11                	beqz	a0,80005d84 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005d6a:	ffffe097          	auipc	ra,0xffffe
    80005d6e:	0e6080e7          	jalr	230(ra) # 80003e50 <iunlockput>
  end_op();
    80005d72:	fffff097          	auipc	ra,0xfffff
    80005d76:	8c6080e7          	jalr	-1850(ra) # 80004638 <end_op>
  return 0;
    80005d7a:	4501                	li	a0,0
}
    80005d7c:	60aa                	ld	ra,136(sp)
    80005d7e:	640a                	ld	s0,128(sp)
    80005d80:	6149                	addi	sp,sp,144
    80005d82:	8082                	ret
    end_op();
    80005d84:	fffff097          	auipc	ra,0xfffff
    80005d88:	8b4080e7          	jalr	-1868(ra) # 80004638 <end_op>
    return -1;
    80005d8c:	557d                	li	a0,-1
    80005d8e:	b7fd                	j	80005d7c <sys_mkdir+0x4c>

0000000080005d90 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005d90:	7135                	addi	sp,sp,-160
    80005d92:	ed06                	sd	ra,152(sp)
    80005d94:	e922                	sd	s0,144(sp)
    80005d96:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005d98:	fffff097          	auipc	ra,0xfffff
    80005d9c:	822080e7          	jalr	-2014(ra) # 800045ba <begin_op>
  argint(1, &major);
    80005da0:	f6c40593          	addi	a1,s0,-148
    80005da4:	4505                	li	a0,1
    80005da6:	ffffd097          	auipc	ra,0xffffd
    80005daa:	1e0080e7          	jalr	480(ra) # 80002f86 <argint>
  argint(2, &minor);
    80005dae:	f6840593          	addi	a1,s0,-152
    80005db2:	4509                	li	a0,2
    80005db4:	ffffd097          	auipc	ra,0xffffd
    80005db8:	1d2080e7          	jalr	466(ra) # 80002f86 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005dbc:	08000613          	li	a2,128
    80005dc0:	f7040593          	addi	a1,s0,-144
    80005dc4:	4501                	li	a0,0
    80005dc6:	ffffd097          	auipc	ra,0xffffd
    80005dca:	200080e7          	jalr	512(ra) # 80002fc6 <argstr>
    80005dce:	02054b63          	bltz	a0,80005e04 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005dd2:	f6841683          	lh	a3,-152(s0)
    80005dd6:	f6c41603          	lh	a2,-148(s0)
    80005dda:	458d                	li	a1,3
    80005ddc:	f7040513          	addi	a0,s0,-144
    80005de0:	fffff097          	auipc	ra,0xfffff
    80005de4:	77c080e7          	jalr	1916(ra) # 8000555c <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005de8:	cd11                	beqz	a0,80005e04 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005dea:	ffffe097          	auipc	ra,0xffffe
    80005dee:	066080e7          	jalr	102(ra) # 80003e50 <iunlockput>
  end_op();
    80005df2:	fffff097          	auipc	ra,0xfffff
    80005df6:	846080e7          	jalr	-1978(ra) # 80004638 <end_op>
  return 0;
    80005dfa:	4501                	li	a0,0
}
    80005dfc:	60ea                	ld	ra,152(sp)
    80005dfe:	644a                	ld	s0,144(sp)
    80005e00:	610d                	addi	sp,sp,160
    80005e02:	8082                	ret
    end_op();
    80005e04:	fffff097          	auipc	ra,0xfffff
    80005e08:	834080e7          	jalr	-1996(ra) # 80004638 <end_op>
    return -1;
    80005e0c:	557d                	li	a0,-1
    80005e0e:	b7fd                	j	80005dfc <sys_mknod+0x6c>

0000000080005e10 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005e10:	7135                	addi	sp,sp,-160
    80005e12:	ed06                	sd	ra,152(sp)
    80005e14:	e922                	sd	s0,144(sp)
    80005e16:	e526                	sd	s1,136(sp)
    80005e18:	e14a                	sd	s2,128(sp)
    80005e1a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005e1c:	ffffc097          	auipc	ra,0xffffc
    80005e20:	ba8080e7          	jalr	-1112(ra) # 800019c4 <myproc>
    80005e24:	892a                	mv	s2,a0
  
  begin_op();
    80005e26:	ffffe097          	auipc	ra,0xffffe
    80005e2a:	794080e7          	jalr	1940(ra) # 800045ba <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005e2e:	08000613          	li	a2,128
    80005e32:	f6040593          	addi	a1,s0,-160
    80005e36:	4501                	li	a0,0
    80005e38:	ffffd097          	auipc	ra,0xffffd
    80005e3c:	18e080e7          	jalr	398(ra) # 80002fc6 <argstr>
    80005e40:	04054b63          	bltz	a0,80005e96 <sys_chdir+0x86>
    80005e44:	f6040513          	addi	a0,s0,-160
    80005e48:	ffffe097          	auipc	ra,0xffffe
    80005e4c:	552080e7          	jalr	1362(ra) # 8000439a <namei>
    80005e50:	84aa                	mv	s1,a0
    80005e52:	c131                	beqz	a0,80005e96 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005e54:	ffffe097          	auipc	ra,0xffffe
    80005e58:	d9a080e7          	jalr	-614(ra) # 80003bee <ilock>
  if(ip->type != T_DIR){
    80005e5c:	04449703          	lh	a4,68(s1)
    80005e60:	4785                	li	a5,1
    80005e62:	04f71063          	bne	a4,a5,80005ea2 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005e66:	8526                	mv	a0,s1
    80005e68:	ffffe097          	auipc	ra,0xffffe
    80005e6c:	e48080e7          	jalr	-440(ra) # 80003cb0 <iunlock>
  iput(p->cwd);
    80005e70:	15093503          	ld	a0,336(s2)
    80005e74:	ffffe097          	auipc	ra,0xffffe
    80005e78:	f34080e7          	jalr	-204(ra) # 80003da8 <iput>
  end_op();
    80005e7c:	ffffe097          	auipc	ra,0xffffe
    80005e80:	7bc080e7          	jalr	1980(ra) # 80004638 <end_op>
  p->cwd = ip;
    80005e84:	14993823          	sd	s1,336(s2)
  return 0;
    80005e88:	4501                	li	a0,0
}
    80005e8a:	60ea                	ld	ra,152(sp)
    80005e8c:	644a                	ld	s0,144(sp)
    80005e8e:	64aa                	ld	s1,136(sp)
    80005e90:	690a                	ld	s2,128(sp)
    80005e92:	610d                	addi	sp,sp,160
    80005e94:	8082                	ret
    end_op();
    80005e96:	ffffe097          	auipc	ra,0xffffe
    80005e9a:	7a2080e7          	jalr	1954(ra) # 80004638 <end_op>
    return -1;
    80005e9e:	557d                	li	a0,-1
    80005ea0:	b7ed                	j	80005e8a <sys_chdir+0x7a>
    iunlockput(ip);
    80005ea2:	8526                	mv	a0,s1
    80005ea4:	ffffe097          	auipc	ra,0xffffe
    80005ea8:	fac080e7          	jalr	-84(ra) # 80003e50 <iunlockput>
    end_op();
    80005eac:	ffffe097          	auipc	ra,0xffffe
    80005eb0:	78c080e7          	jalr	1932(ra) # 80004638 <end_op>
    return -1;
    80005eb4:	557d                	li	a0,-1
    80005eb6:	bfd1                	j	80005e8a <sys_chdir+0x7a>

0000000080005eb8 <sys_exec>:

uint64
sys_exec(void)
{
    80005eb8:	7145                	addi	sp,sp,-464
    80005eba:	e786                	sd	ra,456(sp)
    80005ebc:	e3a2                	sd	s0,448(sp)
    80005ebe:	ff26                	sd	s1,440(sp)
    80005ec0:	fb4a                	sd	s2,432(sp)
    80005ec2:	f74e                	sd	s3,424(sp)
    80005ec4:	f352                	sd	s4,416(sp)
    80005ec6:	ef56                	sd	s5,408(sp)
    80005ec8:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005eca:	e3840593          	addi	a1,s0,-456
    80005ece:	4505                	li	a0,1
    80005ed0:	ffffd097          	auipc	ra,0xffffd
    80005ed4:	0d6080e7          	jalr	214(ra) # 80002fa6 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005ed8:	08000613          	li	a2,128
    80005edc:	f4040593          	addi	a1,s0,-192
    80005ee0:	4501                	li	a0,0
    80005ee2:	ffffd097          	auipc	ra,0xffffd
    80005ee6:	0e4080e7          	jalr	228(ra) # 80002fc6 <argstr>
    80005eea:	87aa                	mv	a5,a0
    return -1;
    80005eec:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005eee:	0c07c363          	bltz	a5,80005fb4 <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    80005ef2:	10000613          	li	a2,256
    80005ef6:	4581                	li	a1,0
    80005ef8:	e4040513          	addi	a0,s0,-448
    80005efc:	ffffb097          	auipc	ra,0xffffb
    80005f00:	dd6080e7          	jalr	-554(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005f04:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005f08:	89a6                	mv	s3,s1
    80005f0a:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005f0c:	02000a13          	li	s4,32
    80005f10:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005f14:	00391513          	slli	a0,s2,0x3
    80005f18:	e3040593          	addi	a1,s0,-464
    80005f1c:	e3843783          	ld	a5,-456(s0)
    80005f20:	953e                	add	a0,a0,a5
    80005f22:	ffffd097          	auipc	ra,0xffffd
    80005f26:	fc6080e7          	jalr	-58(ra) # 80002ee8 <fetchaddr>
    80005f2a:	02054a63          	bltz	a0,80005f5e <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005f2e:	e3043783          	ld	a5,-464(s0)
    80005f32:	c3b9                	beqz	a5,80005f78 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005f34:	ffffb097          	auipc	ra,0xffffb
    80005f38:	bb2080e7          	jalr	-1102(ra) # 80000ae6 <kalloc>
    80005f3c:	85aa                	mv	a1,a0
    80005f3e:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005f42:	cd11                	beqz	a0,80005f5e <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005f44:	6605                	lui	a2,0x1
    80005f46:	e3043503          	ld	a0,-464(s0)
    80005f4a:	ffffd097          	auipc	ra,0xffffd
    80005f4e:	ff0080e7          	jalr	-16(ra) # 80002f3a <fetchstr>
    80005f52:	00054663          	bltz	a0,80005f5e <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005f56:	0905                	addi	s2,s2,1
    80005f58:	09a1                	addi	s3,s3,8
    80005f5a:	fb491be3          	bne	s2,s4,80005f10 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f5e:	f4040913          	addi	s2,s0,-192
    80005f62:	6088                	ld	a0,0(s1)
    80005f64:	c539                	beqz	a0,80005fb2 <sys_exec+0xfa>
    kfree(argv[i]);
    80005f66:	ffffb097          	auipc	ra,0xffffb
    80005f6a:	a82080e7          	jalr	-1406(ra) # 800009e8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f6e:	04a1                	addi	s1,s1,8
    80005f70:	ff2499e3          	bne	s1,s2,80005f62 <sys_exec+0xaa>
  return -1;
    80005f74:	557d                	li	a0,-1
    80005f76:	a83d                	j	80005fb4 <sys_exec+0xfc>
      argv[i] = 0;
    80005f78:	0a8e                	slli	s5,s5,0x3
    80005f7a:	fc0a8793          	addi	a5,s5,-64
    80005f7e:	00878ab3          	add	s5,a5,s0
    80005f82:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005f86:	e4040593          	addi	a1,s0,-448
    80005f8a:	f4040513          	addi	a0,s0,-192
    80005f8e:	fffff097          	auipc	ra,0xfffff
    80005f92:	16e080e7          	jalr	366(ra) # 800050fc <exec>
    80005f96:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f98:	f4040993          	addi	s3,s0,-192
    80005f9c:	6088                	ld	a0,0(s1)
    80005f9e:	c901                	beqz	a0,80005fae <sys_exec+0xf6>
    kfree(argv[i]);
    80005fa0:	ffffb097          	auipc	ra,0xffffb
    80005fa4:	a48080e7          	jalr	-1464(ra) # 800009e8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005fa8:	04a1                	addi	s1,s1,8
    80005faa:	ff3499e3          	bne	s1,s3,80005f9c <sys_exec+0xe4>
  return ret;
    80005fae:	854a                	mv	a0,s2
    80005fb0:	a011                	j	80005fb4 <sys_exec+0xfc>
  return -1;
    80005fb2:	557d                	li	a0,-1
}
    80005fb4:	60be                	ld	ra,456(sp)
    80005fb6:	641e                	ld	s0,448(sp)
    80005fb8:	74fa                	ld	s1,440(sp)
    80005fba:	795a                	ld	s2,432(sp)
    80005fbc:	79ba                	ld	s3,424(sp)
    80005fbe:	7a1a                	ld	s4,416(sp)
    80005fc0:	6afa                	ld	s5,408(sp)
    80005fc2:	6179                	addi	sp,sp,464
    80005fc4:	8082                	ret

0000000080005fc6 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005fc6:	7139                	addi	sp,sp,-64
    80005fc8:	fc06                	sd	ra,56(sp)
    80005fca:	f822                	sd	s0,48(sp)
    80005fcc:	f426                	sd	s1,40(sp)
    80005fce:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005fd0:	ffffc097          	auipc	ra,0xffffc
    80005fd4:	9f4080e7          	jalr	-1548(ra) # 800019c4 <myproc>
    80005fd8:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005fda:	fd840593          	addi	a1,s0,-40
    80005fde:	4501                	li	a0,0
    80005fe0:	ffffd097          	auipc	ra,0xffffd
    80005fe4:	fc6080e7          	jalr	-58(ra) # 80002fa6 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005fe8:	fc840593          	addi	a1,s0,-56
    80005fec:	fd040513          	addi	a0,s0,-48
    80005ff0:	fffff097          	auipc	ra,0xfffff
    80005ff4:	dc2080e7          	jalr	-574(ra) # 80004db2 <pipealloc>
    return -1;
    80005ff8:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005ffa:	0c054463          	bltz	a0,800060c2 <sys_pipe+0xfc>
  fd0 = -1;
    80005ffe:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006002:	fd043503          	ld	a0,-48(s0)
    80006006:	fffff097          	auipc	ra,0xfffff
    8000600a:	514080e7          	jalr	1300(ra) # 8000551a <fdalloc>
    8000600e:	fca42223          	sw	a0,-60(s0)
    80006012:	08054b63          	bltz	a0,800060a8 <sys_pipe+0xe2>
    80006016:	fc843503          	ld	a0,-56(s0)
    8000601a:	fffff097          	auipc	ra,0xfffff
    8000601e:	500080e7          	jalr	1280(ra) # 8000551a <fdalloc>
    80006022:	fca42023          	sw	a0,-64(s0)
    80006026:	06054863          	bltz	a0,80006096 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000602a:	4691                	li	a3,4
    8000602c:	fc440613          	addi	a2,s0,-60
    80006030:	fd843583          	ld	a1,-40(s0)
    80006034:	68a8                	ld	a0,80(s1)
    80006036:	ffffb097          	auipc	ra,0xffffb
    8000603a:	636080e7          	jalr	1590(ra) # 8000166c <copyout>
    8000603e:	02054063          	bltz	a0,8000605e <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006042:	4691                	li	a3,4
    80006044:	fc040613          	addi	a2,s0,-64
    80006048:	fd843583          	ld	a1,-40(s0)
    8000604c:	0591                	addi	a1,a1,4
    8000604e:	68a8                	ld	a0,80(s1)
    80006050:	ffffb097          	auipc	ra,0xffffb
    80006054:	61c080e7          	jalr	1564(ra) # 8000166c <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006058:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000605a:	06055463          	bgez	a0,800060c2 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    8000605e:	fc442783          	lw	a5,-60(s0)
    80006062:	07e9                	addi	a5,a5,26
    80006064:	078e                	slli	a5,a5,0x3
    80006066:	97a6                	add	a5,a5,s1
    80006068:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000606c:	fc042783          	lw	a5,-64(s0)
    80006070:	07e9                	addi	a5,a5,26
    80006072:	078e                	slli	a5,a5,0x3
    80006074:	94be                	add	s1,s1,a5
    80006076:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000607a:	fd043503          	ld	a0,-48(s0)
    8000607e:	fffff097          	auipc	ra,0xfffff
    80006082:	a04080e7          	jalr	-1532(ra) # 80004a82 <fileclose>
    fileclose(wf);
    80006086:	fc843503          	ld	a0,-56(s0)
    8000608a:	fffff097          	auipc	ra,0xfffff
    8000608e:	9f8080e7          	jalr	-1544(ra) # 80004a82 <fileclose>
    return -1;
    80006092:	57fd                	li	a5,-1
    80006094:	a03d                	j	800060c2 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80006096:	fc442783          	lw	a5,-60(s0)
    8000609a:	0007c763          	bltz	a5,800060a8 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    8000609e:	07e9                	addi	a5,a5,26
    800060a0:	078e                	slli	a5,a5,0x3
    800060a2:	97a6                	add	a5,a5,s1
    800060a4:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800060a8:	fd043503          	ld	a0,-48(s0)
    800060ac:	fffff097          	auipc	ra,0xfffff
    800060b0:	9d6080e7          	jalr	-1578(ra) # 80004a82 <fileclose>
    fileclose(wf);
    800060b4:	fc843503          	ld	a0,-56(s0)
    800060b8:	fffff097          	auipc	ra,0xfffff
    800060bc:	9ca080e7          	jalr	-1590(ra) # 80004a82 <fileclose>
    return -1;
    800060c0:	57fd                	li	a5,-1
}
    800060c2:	853e                	mv	a0,a5
    800060c4:	70e2                	ld	ra,56(sp)
    800060c6:	7442                	ld	s0,48(sp)
    800060c8:	74a2                	ld	s1,40(sp)
    800060ca:	6121                	addi	sp,sp,64
    800060cc:	8082                	ret
	...

00000000800060d0 <kernelvec>:
    800060d0:	7111                	addi	sp,sp,-256
    800060d2:	e006                	sd	ra,0(sp)
    800060d4:	e40a                	sd	sp,8(sp)
    800060d6:	e80e                	sd	gp,16(sp)
    800060d8:	ec12                	sd	tp,24(sp)
    800060da:	f016                	sd	t0,32(sp)
    800060dc:	f41a                	sd	t1,40(sp)
    800060de:	f81e                	sd	t2,48(sp)
    800060e0:	fc22                	sd	s0,56(sp)
    800060e2:	e0a6                	sd	s1,64(sp)
    800060e4:	e4aa                	sd	a0,72(sp)
    800060e6:	e8ae                	sd	a1,80(sp)
    800060e8:	ecb2                	sd	a2,88(sp)
    800060ea:	f0b6                	sd	a3,96(sp)
    800060ec:	f4ba                	sd	a4,104(sp)
    800060ee:	f8be                	sd	a5,112(sp)
    800060f0:	fcc2                	sd	a6,120(sp)
    800060f2:	e146                	sd	a7,128(sp)
    800060f4:	e54a                	sd	s2,136(sp)
    800060f6:	e94e                	sd	s3,144(sp)
    800060f8:	ed52                	sd	s4,152(sp)
    800060fa:	f156                	sd	s5,160(sp)
    800060fc:	f55a                	sd	s6,168(sp)
    800060fe:	f95e                	sd	s7,176(sp)
    80006100:	fd62                	sd	s8,184(sp)
    80006102:	e1e6                	sd	s9,192(sp)
    80006104:	e5ea                	sd	s10,200(sp)
    80006106:	e9ee                	sd	s11,208(sp)
    80006108:	edf2                	sd	t3,216(sp)
    8000610a:	f1f6                	sd	t4,224(sp)
    8000610c:	f5fa                	sd	t5,232(sp)
    8000610e:	f9fe                	sd	t6,240(sp)
    80006110:	ca5fc0ef          	jal	ra,80002db4 <kerneltrap>
    80006114:	6082                	ld	ra,0(sp)
    80006116:	6122                	ld	sp,8(sp)
    80006118:	61c2                	ld	gp,16(sp)
    8000611a:	7282                	ld	t0,32(sp)
    8000611c:	7322                	ld	t1,40(sp)
    8000611e:	73c2                	ld	t2,48(sp)
    80006120:	7462                	ld	s0,56(sp)
    80006122:	6486                	ld	s1,64(sp)
    80006124:	6526                	ld	a0,72(sp)
    80006126:	65c6                	ld	a1,80(sp)
    80006128:	6666                	ld	a2,88(sp)
    8000612a:	7686                	ld	a3,96(sp)
    8000612c:	7726                	ld	a4,104(sp)
    8000612e:	77c6                	ld	a5,112(sp)
    80006130:	7866                	ld	a6,120(sp)
    80006132:	688a                	ld	a7,128(sp)
    80006134:	692a                	ld	s2,136(sp)
    80006136:	69ca                	ld	s3,144(sp)
    80006138:	6a6a                	ld	s4,152(sp)
    8000613a:	7a8a                	ld	s5,160(sp)
    8000613c:	7b2a                	ld	s6,168(sp)
    8000613e:	7bca                	ld	s7,176(sp)
    80006140:	7c6a                	ld	s8,184(sp)
    80006142:	6c8e                	ld	s9,192(sp)
    80006144:	6d2e                	ld	s10,200(sp)
    80006146:	6dce                	ld	s11,208(sp)
    80006148:	6e6e                	ld	t3,216(sp)
    8000614a:	7e8e                	ld	t4,224(sp)
    8000614c:	7f2e                	ld	t5,232(sp)
    8000614e:	7fce                	ld	t6,240(sp)
    80006150:	6111                	addi	sp,sp,256
    80006152:	10200073          	sret
    80006156:	00000013          	nop
    8000615a:	00000013          	nop
    8000615e:	0001                	nop

0000000080006160 <timervec>:
    80006160:	34051573          	csrrw	a0,mscratch,a0
    80006164:	e10c                	sd	a1,0(a0)
    80006166:	e510                	sd	a2,8(a0)
    80006168:	e914                	sd	a3,16(a0)
    8000616a:	6d0c                	ld	a1,24(a0)
    8000616c:	7110                	ld	a2,32(a0)
    8000616e:	6194                	ld	a3,0(a1)
    80006170:	96b2                	add	a3,a3,a2
    80006172:	e194                	sd	a3,0(a1)
    80006174:	4589                	li	a1,2
    80006176:	14459073          	csrw	sip,a1
    8000617a:	6914                	ld	a3,16(a0)
    8000617c:	6510                	ld	a2,8(a0)
    8000617e:	610c                	ld	a1,0(a0)
    80006180:	34051573          	csrrw	a0,mscratch,a0
    80006184:	30200073          	mret
	...

000000008000618a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000618a:	1141                	addi	sp,sp,-16
    8000618c:	e422                	sd	s0,8(sp)
    8000618e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006190:	0c0007b7          	lui	a5,0xc000
    80006194:	4705                	li	a4,1
    80006196:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006198:	c3d8                	sw	a4,4(a5)
}
    8000619a:	6422                	ld	s0,8(sp)
    8000619c:	0141                	addi	sp,sp,16
    8000619e:	8082                	ret

00000000800061a0 <plicinithart>:

void
plicinithart(void)
{
    800061a0:	1141                	addi	sp,sp,-16
    800061a2:	e406                	sd	ra,8(sp)
    800061a4:	e022                	sd	s0,0(sp)
    800061a6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800061a8:	ffffb097          	auipc	ra,0xffffb
    800061ac:	7f0080e7          	jalr	2032(ra) # 80001998 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800061b0:	0085171b          	slliw	a4,a0,0x8
    800061b4:	0c0027b7          	lui	a5,0xc002
    800061b8:	97ba                	add	a5,a5,a4
    800061ba:	40200713          	li	a4,1026
    800061be:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800061c2:	00d5151b          	slliw	a0,a0,0xd
    800061c6:	0c2017b7          	lui	a5,0xc201
    800061ca:	97aa                	add	a5,a5,a0
    800061cc:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800061d0:	60a2                	ld	ra,8(sp)
    800061d2:	6402                	ld	s0,0(sp)
    800061d4:	0141                	addi	sp,sp,16
    800061d6:	8082                	ret

00000000800061d8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800061d8:	1141                	addi	sp,sp,-16
    800061da:	e406                	sd	ra,8(sp)
    800061dc:	e022                	sd	s0,0(sp)
    800061de:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800061e0:	ffffb097          	auipc	ra,0xffffb
    800061e4:	7b8080e7          	jalr	1976(ra) # 80001998 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800061e8:	00d5151b          	slliw	a0,a0,0xd
    800061ec:	0c2017b7          	lui	a5,0xc201
    800061f0:	97aa                	add	a5,a5,a0
  return irq;
}
    800061f2:	43c8                	lw	a0,4(a5)
    800061f4:	60a2                	ld	ra,8(sp)
    800061f6:	6402                	ld	s0,0(sp)
    800061f8:	0141                	addi	sp,sp,16
    800061fa:	8082                	ret

00000000800061fc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800061fc:	1101                	addi	sp,sp,-32
    800061fe:	ec06                	sd	ra,24(sp)
    80006200:	e822                	sd	s0,16(sp)
    80006202:	e426                	sd	s1,8(sp)
    80006204:	1000                	addi	s0,sp,32
    80006206:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006208:	ffffb097          	auipc	ra,0xffffb
    8000620c:	790080e7          	jalr	1936(ra) # 80001998 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006210:	00d5151b          	slliw	a0,a0,0xd
    80006214:	0c2017b7          	lui	a5,0xc201
    80006218:	97aa                	add	a5,a5,a0
    8000621a:	c3c4                	sw	s1,4(a5)
}
    8000621c:	60e2                	ld	ra,24(sp)
    8000621e:	6442                	ld	s0,16(sp)
    80006220:	64a2                	ld	s1,8(sp)
    80006222:	6105                	addi	sp,sp,32
    80006224:	8082                	ret

0000000080006226 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006226:	1141                	addi	sp,sp,-16
    80006228:	e406                	sd	ra,8(sp)
    8000622a:	e022                	sd	s0,0(sp)
    8000622c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000622e:	479d                	li	a5,7
    80006230:	04a7cc63          	blt	a5,a0,80006288 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006234:	0001c797          	auipc	a5,0x1c
    80006238:	31478793          	addi	a5,a5,788 # 80022548 <disk>
    8000623c:	97aa                	add	a5,a5,a0
    8000623e:	0187c783          	lbu	a5,24(a5)
    80006242:	ebb9                	bnez	a5,80006298 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006244:	00451693          	slli	a3,a0,0x4
    80006248:	0001c797          	auipc	a5,0x1c
    8000624c:	30078793          	addi	a5,a5,768 # 80022548 <disk>
    80006250:	6398                	ld	a4,0(a5)
    80006252:	9736                	add	a4,a4,a3
    80006254:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80006258:	6398                	ld	a4,0(a5)
    8000625a:	9736                	add	a4,a4,a3
    8000625c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006260:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006264:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006268:	97aa                	add	a5,a5,a0
    8000626a:	4705                	li	a4,1
    8000626c:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80006270:	0001c517          	auipc	a0,0x1c
    80006274:	2f050513          	addi	a0,a0,752 # 80022560 <disk+0x18>
    80006278:	ffffc097          	auipc	ra,0xffffc
    8000627c:	f08080e7          	jalr	-248(ra) # 80002180 <wakeup>
}
    80006280:	60a2                	ld	ra,8(sp)
    80006282:	6402                	ld	s0,0(sp)
    80006284:	0141                	addi	sp,sp,16
    80006286:	8082                	ret
    panic("free_desc 1");
    80006288:	00002517          	auipc	a0,0x2
    8000628c:	5a050513          	addi	a0,a0,1440 # 80008828 <syscalls+0x320>
    80006290:	ffffa097          	auipc	ra,0xffffa
    80006294:	2b0080e7          	jalr	688(ra) # 80000540 <panic>
    panic("free_desc 2");
    80006298:	00002517          	auipc	a0,0x2
    8000629c:	5a050513          	addi	a0,a0,1440 # 80008838 <syscalls+0x330>
    800062a0:	ffffa097          	auipc	ra,0xffffa
    800062a4:	2a0080e7          	jalr	672(ra) # 80000540 <panic>

00000000800062a8 <virtio_disk_init>:
{
    800062a8:	1101                	addi	sp,sp,-32
    800062aa:	ec06                	sd	ra,24(sp)
    800062ac:	e822                	sd	s0,16(sp)
    800062ae:	e426                	sd	s1,8(sp)
    800062b0:	e04a                	sd	s2,0(sp)
    800062b2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800062b4:	00002597          	auipc	a1,0x2
    800062b8:	59458593          	addi	a1,a1,1428 # 80008848 <syscalls+0x340>
    800062bc:	0001c517          	auipc	a0,0x1c
    800062c0:	3b450513          	addi	a0,a0,948 # 80022670 <disk+0x128>
    800062c4:	ffffb097          	auipc	ra,0xffffb
    800062c8:	882080e7          	jalr	-1918(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800062cc:	100017b7          	lui	a5,0x10001
    800062d0:	4398                	lw	a4,0(a5)
    800062d2:	2701                	sext.w	a4,a4
    800062d4:	747277b7          	lui	a5,0x74727
    800062d8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800062dc:	14f71b63          	bne	a4,a5,80006432 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800062e0:	100017b7          	lui	a5,0x10001
    800062e4:	43dc                	lw	a5,4(a5)
    800062e6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800062e8:	4709                	li	a4,2
    800062ea:	14e79463          	bne	a5,a4,80006432 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800062ee:	100017b7          	lui	a5,0x10001
    800062f2:	479c                	lw	a5,8(a5)
    800062f4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800062f6:	12e79e63          	bne	a5,a4,80006432 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800062fa:	100017b7          	lui	a5,0x10001
    800062fe:	47d8                	lw	a4,12(a5)
    80006300:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006302:	554d47b7          	lui	a5,0x554d4
    80006306:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000630a:	12f71463          	bne	a4,a5,80006432 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000630e:	100017b7          	lui	a5,0x10001
    80006312:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006316:	4705                	li	a4,1
    80006318:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000631a:	470d                	li	a4,3
    8000631c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000631e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006320:	c7ffe6b7          	lui	a3,0xc7ffe
    80006324:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc0d7>
    80006328:	8f75                	and	a4,a4,a3
    8000632a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000632c:	472d                	li	a4,11
    8000632e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006330:	5bbc                	lw	a5,112(a5)
    80006332:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006336:	8ba1                	andi	a5,a5,8
    80006338:	10078563          	beqz	a5,80006442 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000633c:	100017b7          	lui	a5,0x10001
    80006340:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006344:	43fc                	lw	a5,68(a5)
    80006346:	2781                	sext.w	a5,a5
    80006348:	10079563          	bnez	a5,80006452 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000634c:	100017b7          	lui	a5,0x10001
    80006350:	5bdc                	lw	a5,52(a5)
    80006352:	2781                	sext.w	a5,a5
  if(max == 0)
    80006354:	10078763          	beqz	a5,80006462 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80006358:	471d                	li	a4,7
    8000635a:	10f77c63          	bgeu	a4,a5,80006472 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    8000635e:	ffffa097          	auipc	ra,0xffffa
    80006362:	788080e7          	jalr	1928(ra) # 80000ae6 <kalloc>
    80006366:	0001c497          	auipc	s1,0x1c
    8000636a:	1e248493          	addi	s1,s1,482 # 80022548 <disk>
    8000636e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006370:	ffffa097          	auipc	ra,0xffffa
    80006374:	776080e7          	jalr	1910(ra) # 80000ae6 <kalloc>
    80006378:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000637a:	ffffa097          	auipc	ra,0xffffa
    8000637e:	76c080e7          	jalr	1900(ra) # 80000ae6 <kalloc>
    80006382:	87aa                	mv	a5,a0
    80006384:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006386:	6088                	ld	a0,0(s1)
    80006388:	cd6d                	beqz	a0,80006482 <virtio_disk_init+0x1da>
    8000638a:	0001c717          	auipc	a4,0x1c
    8000638e:	1c673703          	ld	a4,454(a4) # 80022550 <disk+0x8>
    80006392:	cb65                	beqz	a4,80006482 <virtio_disk_init+0x1da>
    80006394:	c7fd                	beqz	a5,80006482 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    80006396:	6605                	lui	a2,0x1
    80006398:	4581                	li	a1,0
    8000639a:	ffffb097          	auipc	ra,0xffffb
    8000639e:	938080e7          	jalr	-1736(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    800063a2:	0001c497          	auipc	s1,0x1c
    800063a6:	1a648493          	addi	s1,s1,422 # 80022548 <disk>
    800063aa:	6605                	lui	a2,0x1
    800063ac:	4581                	li	a1,0
    800063ae:	6488                	ld	a0,8(s1)
    800063b0:	ffffb097          	auipc	ra,0xffffb
    800063b4:	922080e7          	jalr	-1758(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    800063b8:	6605                	lui	a2,0x1
    800063ba:	4581                	li	a1,0
    800063bc:	6888                	ld	a0,16(s1)
    800063be:	ffffb097          	auipc	ra,0xffffb
    800063c2:	914080e7          	jalr	-1772(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800063c6:	100017b7          	lui	a5,0x10001
    800063ca:	4721                	li	a4,8
    800063cc:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800063ce:	4098                	lw	a4,0(s1)
    800063d0:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800063d4:	40d8                	lw	a4,4(s1)
    800063d6:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800063da:	6498                	ld	a4,8(s1)
    800063dc:	0007069b          	sext.w	a3,a4
    800063e0:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800063e4:	9701                	srai	a4,a4,0x20
    800063e6:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800063ea:	6898                	ld	a4,16(s1)
    800063ec:	0007069b          	sext.w	a3,a4
    800063f0:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800063f4:	9701                	srai	a4,a4,0x20
    800063f6:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800063fa:	4705                	li	a4,1
    800063fc:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    800063fe:	00e48c23          	sb	a4,24(s1)
    80006402:	00e48ca3          	sb	a4,25(s1)
    80006406:	00e48d23          	sb	a4,26(s1)
    8000640a:	00e48da3          	sb	a4,27(s1)
    8000640e:	00e48e23          	sb	a4,28(s1)
    80006412:	00e48ea3          	sb	a4,29(s1)
    80006416:	00e48f23          	sb	a4,30(s1)
    8000641a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    8000641e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006422:	0727a823          	sw	s2,112(a5)
}
    80006426:	60e2                	ld	ra,24(sp)
    80006428:	6442                	ld	s0,16(sp)
    8000642a:	64a2                	ld	s1,8(sp)
    8000642c:	6902                	ld	s2,0(sp)
    8000642e:	6105                	addi	sp,sp,32
    80006430:	8082                	ret
    panic("could not find virtio disk");
    80006432:	00002517          	auipc	a0,0x2
    80006436:	42650513          	addi	a0,a0,1062 # 80008858 <syscalls+0x350>
    8000643a:	ffffa097          	auipc	ra,0xffffa
    8000643e:	106080e7          	jalr	262(ra) # 80000540 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006442:	00002517          	auipc	a0,0x2
    80006446:	43650513          	addi	a0,a0,1078 # 80008878 <syscalls+0x370>
    8000644a:	ffffa097          	auipc	ra,0xffffa
    8000644e:	0f6080e7          	jalr	246(ra) # 80000540 <panic>
    panic("virtio disk should not be ready");
    80006452:	00002517          	auipc	a0,0x2
    80006456:	44650513          	addi	a0,a0,1094 # 80008898 <syscalls+0x390>
    8000645a:	ffffa097          	auipc	ra,0xffffa
    8000645e:	0e6080e7          	jalr	230(ra) # 80000540 <panic>
    panic("virtio disk has no queue 0");
    80006462:	00002517          	auipc	a0,0x2
    80006466:	45650513          	addi	a0,a0,1110 # 800088b8 <syscalls+0x3b0>
    8000646a:	ffffa097          	auipc	ra,0xffffa
    8000646e:	0d6080e7          	jalr	214(ra) # 80000540 <panic>
    panic("virtio disk max queue too short");
    80006472:	00002517          	auipc	a0,0x2
    80006476:	46650513          	addi	a0,a0,1126 # 800088d8 <syscalls+0x3d0>
    8000647a:	ffffa097          	auipc	ra,0xffffa
    8000647e:	0c6080e7          	jalr	198(ra) # 80000540 <panic>
    panic("virtio disk kalloc");
    80006482:	00002517          	auipc	a0,0x2
    80006486:	47650513          	addi	a0,a0,1142 # 800088f8 <syscalls+0x3f0>
    8000648a:	ffffa097          	auipc	ra,0xffffa
    8000648e:	0b6080e7          	jalr	182(ra) # 80000540 <panic>

0000000080006492 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006492:	7119                	addi	sp,sp,-128
    80006494:	fc86                	sd	ra,120(sp)
    80006496:	f8a2                	sd	s0,112(sp)
    80006498:	f4a6                	sd	s1,104(sp)
    8000649a:	f0ca                	sd	s2,96(sp)
    8000649c:	ecce                	sd	s3,88(sp)
    8000649e:	e8d2                	sd	s4,80(sp)
    800064a0:	e4d6                	sd	s5,72(sp)
    800064a2:	e0da                	sd	s6,64(sp)
    800064a4:	fc5e                	sd	s7,56(sp)
    800064a6:	f862                	sd	s8,48(sp)
    800064a8:	f466                	sd	s9,40(sp)
    800064aa:	f06a                	sd	s10,32(sp)
    800064ac:	ec6e                	sd	s11,24(sp)
    800064ae:	0100                	addi	s0,sp,128
    800064b0:	8aaa                	mv	s5,a0
    800064b2:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800064b4:	00c52d03          	lw	s10,12(a0)
    800064b8:	001d1d1b          	slliw	s10,s10,0x1
    800064bc:	1d02                	slli	s10,s10,0x20
    800064be:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    800064c2:	0001c517          	auipc	a0,0x1c
    800064c6:	1ae50513          	addi	a0,a0,430 # 80022670 <disk+0x128>
    800064ca:	ffffa097          	auipc	ra,0xffffa
    800064ce:	70c080e7          	jalr	1804(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    800064d2:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800064d4:	44a1                	li	s1,8
      disk.free[i] = 0;
    800064d6:	0001cb97          	auipc	s7,0x1c
    800064da:	072b8b93          	addi	s7,s7,114 # 80022548 <disk>
  for(int i = 0; i < 3; i++){
    800064de:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800064e0:	0001cc97          	auipc	s9,0x1c
    800064e4:	190c8c93          	addi	s9,s9,400 # 80022670 <disk+0x128>
    800064e8:	a08d                	j	8000654a <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    800064ea:	00fb8733          	add	a4,s7,a5
    800064ee:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800064f2:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800064f4:	0207c563          	bltz	a5,8000651e <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    800064f8:	2905                	addiw	s2,s2,1
    800064fa:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800064fc:	05690c63          	beq	s2,s6,80006554 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006500:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006502:	0001c717          	auipc	a4,0x1c
    80006506:	04670713          	addi	a4,a4,70 # 80022548 <disk>
    8000650a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000650c:	01874683          	lbu	a3,24(a4)
    80006510:	fee9                	bnez	a3,800064ea <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006512:	2785                	addiw	a5,a5,1
    80006514:	0705                	addi	a4,a4,1
    80006516:	fe979be3          	bne	a5,s1,8000650c <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000651a:	57fd                	li	a5,-1
    8000651c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000651e:	01205d63          	blez	s2,80006538 <virtio_disk_rw+0xa6>
    80006522:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006524:	000a2503          	lw	a0,0(s4)
    80006528:	00000097          	auipc	ra,0x0
    8000652c:	cfe080e7          	jalr	-770(ra) # 80006226 <free_desc>
      for(int j = 0; j < i; j++)
    80006530:	2d85                	addiw	s11,s11,1
    80006532:	0a11                	addi	s4,s4,4
    80006534:	ff2d98e3          	bne	s11,s2,80006524 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006538:	85e6                	mv	a1,s9
    8000653a:	0001c517          	auipc	a0,0x1c
    8000653e:	02650513          	addi	a0,a0,38 # 80022560 <disk+0x18>
    80006542:	ffffc097          	auipc	ra,0xffffc
    80006546:	bda080e7          	jalr	-1062(ra) # 8000211c <sleep>
  for(int i = 0; i < 3; i++){
    8000654a:	f8040a13          	addi	s4,s0,-128
{
    8000654e:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006550:	894e                	mv	s2,s3
    80006552:	b77d                	j	80006500 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006554:	f8042503          	lw	a0,-128(s0)
    80006558:	00a50713          	addi	a4,a0,10
    8000655c:	0712                	slli	a4,a4,0x4

  if(write)
    8000655e:	0001c797          	auipc	a5,0x1c
    80006562:	fea78793          	addi	a5,a5,-22 # 80022548 <disk>
    80006566:	00e786b3          	add	a3,a5,a4
    8000656a:	01803633          	snez	a2,s8
    8000656e:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006570:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80006574:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006578:	f6070613          	addi	a2,a4,-160
    8000657c:	6394                	ld	a3,0(a5)
    8000657e:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006580:	00870593          	addi	a1,a4,8
    80006584:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006586:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006588:	0007b803          	ld	a6,0(a5)
    8000658c:	9642                	add	a2,a2,a6
    8000658e:	46c1                	li	a3,16
    80006590:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006592:	4585                	li	a1,1
    80006594:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80006598:	f8442683          	lw	a3,-124(s0)
    8000659c:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800065a0:	0692                	slli	a3,a3,0x4
    800065a2:	9836                	add	a6,a6,a3
    800065a4:	058a8613          	addi	a2,s5,88
    800065a8:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    800065ac:	0007b803          	ld	a6,0(a5)
    800065b0:	96c2                	add	a3,a3,a6
    800065b2:	40000613          	li	a2,1024
    800065b6:	c690                	sw	a2,8(a3)
  if(write)
    800065b8:	001c3613          	seqz	a2,s8
    800065bc:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800065c0:	00166613          	ori	a2,a2,1
    800065c4:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    800065c8:	f8842603          	lw	a2,-120(s0)
    800065cc:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800065d0:	00250693          	addi	a3,a0,2
    800065d4:	0692                	slli	a3,a3,0x4
    800065d6:	96be                	add	a3,a3,a5
    800065d8:	58fd                	li	a7,-1
    800065da:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800065de:	0612                	slli	a2,a2,0x4
    800065e0:	9832                	add	a6,a6,a2
    800065e2:	f9070713          	addi	a4,a4,-112
    800065e6:	973e                	add	a4,a4,a5
    800065e8:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    800065ec:	6398                	ld	a4,0(a5)
    800065ee:	9732                	add	a4,a4,a2
    800065f0:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800065f2:	4609                	li	a2,2
    800065f4:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    800065f8:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800065fc:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80006600:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006604:	6794                	ld	a3,8(a5)
    80006606:	0026d703          	lhu	a4,2(a3)
    8000660a:	8b1d                	andi	a4,a4,7
    8000660c:	0706                	slli	a4,a4,0x1
    8000660e:	96ba                	add	a3,a3,a4
    80006610:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006614:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006618:	6798                	ld	a4,8(a5)
    8000661a:	00275783          	lhu	a5,2(a4)
    8000661e:	2785                	addiw	a5,a5,1
    80006620:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006624:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006628:	100017b7          	lui	a5,0x10001
    8000662c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006630:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    80006634:	0001c917          	auipc	s2,0x1c
    80006638:	03c90913          	addi	s2,s2,60 # 80022670 <disk+0x128>
  while(b->disk == 1) {
    8000663c:	4485                	li	s1,1
    8000663e:	00b79c63          	bne	a5,a1,80006656 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006642:	85ca                	mv	a1,s2
    80006644:	8556                	mv	a0,s5
    80006646:	ffffc097          	auipc	ra,0xffffc
    8000664a:	ad6080e7          	jalr	-1322(ra) # 8000211c <sleep>
  while(b->disk == 1) {
    8000664e:	004aa783          	lw	a5,4(s5)
    80006652:	fe9788e3          	beq	a5,s1,80006642 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006656:	f8042903          	lw	s2,-128(s0)
    8000665a:	00290713          	addi	a4,s2,2
    8000665e:	0712                	slli	a4,a4,0x4
    80006660:	0001c797          	auipc	a5,0x1c
    80006664:	ee878793          	addi	a5,a5,-280 # 80022548 <disk>
    80006668:	97ba                	add	a5,a5,a4
    8000666a:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000666e:	0001c997          	auipc	s3,0x1c
    80006672:	eda98993          	addi	s3,s3,-294 # 80022548 <disk>
    80006676:	00491713          	slli	a4,s2,0x4
    8000667a:	0009b783          	ld	a5,0(s3)
    8000667e:	97ba                	add	a5,a5,a4
    80006680:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006684:	854a                	mv	a0,s2
    80006686:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000668a:	00000097          	auipc	ra,0x0
    8000668e:	b9c080e7          	jalr	-1124(ra) # 80006226 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006692:	8885                	andi	s1,s1,1
    80006694:	f0ed                	bnez	s1,80006676 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006696:	0001c517          	auipc	a0,0x1c
    8000669a:	fda50513          	addi	a0,a0,-38 # 80022670 <disk+0x128>
    8000669e:	ffffa097          	auipc	ra,0xffffa
    800066a2:	5ec080e7          	jalr	1516(ra) # 80000c8a <release>
}
    800066a6:	70e6                	ld	ra,120(sp)
    800066a8:	7446                	ld	s0,112(sp)
    800066aa:	74a6                	ld	s1,104(sp)
    800066ac:	7906                	ld	s2,96(sp)
    800066ae:	69e6                	ld	s3,88(sp)
    800066b0:	6a46                	ld	s4,80(sp)
    800066b2:	6aa6                	ld	s5,72(sp)
    800066b4:	6b06                	ld	s6,64(sp)
    800066b6:	7be2                	ld	s7,56(sp)
    800066b8:	7c42                	ld	s8,48(sp)
    800066ba:	7ca2                	ld	s9,40(sp)
    800066bc:	7d02                	ld	s10,32(sp)
    800066be:	6de2                	ld	s11,24(sp)
    800066c0:	6109                	addi	sp,sp,128
    800066c2:	8082                	ret

00000000800066c4 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800066c4:	1101                	addi	sp,sp,-32
    800066c6:	ec06                	sd	ra,24(sp)
    800066c8:	e822                	sd	s0,16(sp)
    800066ca:	e426                	sd	s1,8(sp)
    800066cc:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800066ce:	0001c497          	auipc	s1,0x1c
    800066d2:	e7a48493          	addi	s1,s1,-390 # 80022548 <disk>
    800066d6:	0001c517          	auipc	a0,0x1c
    800066da:	f9a50513          	addi	a0,a0,-102 # 80022670 <disk+0x128>
    800066de:	ffffa097          	auipc	ra,0xffffa
    800066e2:	4f8080e7          	jalr	1272(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800066e6:	10001737          	lui	a4,0x10001
    800066ea:	533c                	lw	a5,96(a4)
    800066ec:	8b8d                	andi	a5,a5,3
    800066ee:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800066f0:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800066f4:	689c                	ld	a5,16(s1)
    800066f6:	0204d703          	lhu	a4,32(s1)
    800066fa:	0027d783          	lhu	a5,2(a5)
    800066fe:	04f70863          	beq	a4,a5,8000674e <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006702:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006706:	6898                	ld	a4,16(s1)
    80006708:	0204d783          	lhu	a5,32(s1)
    8000670c:	8b9d                	andi	a5,a5,7
    8000670e:	078e                	slli	a5,a5,0x3
    80006710:	97ba                	add	a5,a5,a4
    80006712:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006714:	00278713          	addi	a4,a5,2
    80006718:	0712                	slli	a4,a4,0x4
    8000671a:	9726                	add	a4,a4,s1
    8000671c:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006720:	e721                	bnez	a4,80006768 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006722:	0789                	addi	a5,a5,2
    80006724:	0792                	slli	a5,a5,0x4
    80006726:	97a6                	add	a5,a5,s1
    80006728:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000672a:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000672e:	ffffc097          	auipc	ra,0xffffc
    80006732:	a52080e7          	jalr	-1454(ra) # 80002180 <wakeup>

    disk.used_idx += 1;
    80006736:	0204d783          	lhu	a5,32(s1)
    8000673a:	2785                	addiw	a5,a5,1
    8000673c:	17c2                	slli	a5,a5,0x30
    8000673e:	93c1                	srli	a5,a5,0x30
    80006740:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006744:	6898                	ld	a4,16(s1)
    80006746:	00275703          	lhu	a4,2(a4)
    8000674a:	faf71ce3          	bne	a4,a5,80006702 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    8000674e:	0001c517          	auipc	a0,0x1c
    80006752:	f2250513          	addi	a0,a0,-222 # 80022670 <disk+0x128>
    80006756:	ffffa097          	auipc	ra,0xffffa
    8000675a:	534080e7          	jalr	1332(ra) # 80000c8a <release>
}
    8000675e:	60e2                	ld	ra,24(sp)
    80006760:	6442                	ld	s0,16(sp)
    80006762:	64a2                	ld	s1,8(sp)
    80006764:	6105                	addi	sp,sp,32
    80006766:	8082                	ret
      panic("virtio_disk_intr status");
    80006768:	00002517          	auipc	a0,0x2
    8000676c:	1a850513          	addi	a0,a0,424 # 80008910 <syscalls+0x408>
    80006770:	ffffa097          	auipc	ra,0xffffa
    80006774:	dd0080e7          	jalr	-560(ra) # 80000540 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
	...
