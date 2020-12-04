/*******************************************************************
 * Copyright (C) 2013-2020 by Paulo Flores <pff@inesc-id.pt>
 *
 * Time-stamp: "2020-12-02 00:01:13    adet.c    pff@inesc-id.pt
 *
 * Summary: Generate parameters and compare with expected results
 *          from the FPGA.
 *
 *******************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <math.h>

#define COURSE "Digital System Design (2020/21, 1o Sem.) - Prof. Paulo Flores"
#define NAME "ADET - matrices generation, and FPGA output verification"
#define VERSION "1.3"

#define DEBUG 1

/* MODEGEN
   0= rnd,

   seed= 765 => small values 3.4 as 5.7
*/
#define MODEGEN 0

#define GENMODE 1		/* generating mode */
#define CMPMODE 2		/* comparing mode */

/* Number representation macros */
#define SCALE0 (double)(pow(2, 0))
#define SCALE1 (double)(pow(2, -1))
#define SCALE2 (double)(pow(2, -2))
#define SCALE3 (double)(pow(2, -3))
#define SCALE4 (double)(pow(2, -4))
#define SCALE6 (double)(pow(2, -6))
#define SCALE7 (double)(pow(2, -7))
#define SCALE8 (double)(pow(2, -8))
#define SCALE12 (double)(pow(2, -12))
#define SCALE14 (double)(pow(2, -14))
#define SCALE16 (double)(pow(2, -16))
#define SCALE17 (double)(pow(2, -17))
#define SCALE18 (double)(pow(2, -18))

#define SCALEOK SCALE18               /* scale of output average Q14.18*/
#define SCALEUSER (double)(pow(2, -qf)) /* scale used on reading values from FPGA*/

#define MASK4    (0x0000000F)

#define MASKQ34    (0x000003F8)
#define MASKSIGQ34 (0x00000200)
#define MASKNEGQ34 (0xFFFFFC00)

#define MASK12    (0x00000FFF)
#define MASKNEG12 (0xFFFFF000)
#define MASKPOS12 (0x000007FF)
#define MASKSIG12 (0x00000800)

#define MASK16    (0x0000FFFF)
#define MASKNEG16 (0xFFFF0000)
#define MASKPOS16 (0x00007FFF)
#define MASKSIG16 (0x00008000)

#define MASK26    (0x03FFFFFF)
#define MASK27    (0x07FFFFFF)
#define MASK29    (0x1FFFFFFF)

#define MASK32    (0xFFFFFFFF)
#define MASKNEG32 (0x00000000)
#define MASKPOS32 (0x7FFFFFFF)

#define MINSIGNED8b  -128	 /* (int)(-pow(2,  7)) */
#define MINSIGNED16b -32768	 /* (int)(-pow(2, 15)) */
#define MINSIGNED32b -2147483648 /* (int)(-pow(2, 31)) 0x80000000*/

#define MAXSIGNED8b  127	/* (int)(pow(2,  7)-1) */
#define MAXSIGNED16b 32767	/* (int)(pow(2, 15)-1) */
#define MAXSIGNED32b 2147483647	/* (int)(pow(2, 31)-1) 0x7FFFFFFF*/





/* Memeory management macros */
#define SIZEOFINT 4         /* number of char on an int 4 x8bits */
#define HEX 4               /* bits per hex char representation */
#define CHR 8               /* bits on a  char */

#define BITS_WORD_IN  32    /* size of memory word in bits (on the input) was16*/
#define BITS_WORD_OUT 32    /* size of memory word in bits (on the output) */

#define MEMSIZE_INWRDS 256     /* size or memory in words (ints) was2049 */
#define MEMSIZE_INCHAR (MEMSIZE_INWRDS * BITS_WORD_IN / CHR)

#define MEMSIZE_OUTCHAR 1024 /* size or memory in chars read from the BASYS3 */
#define MEMSIZE_OUTWRDS MEMSIZE_OUTCHAR * CHR / BITS_WORD_OUT

#define INIT_SIZE_CHAR 64
#define INIT_SIZE_BITS 256      /* = INIT_SIZE_CHAR * 4 */


#define ADDR_C2W(addr,bits_word) ((addr) * (HEX) / (bits_word))
#define ADDR_W2C(addr,bits_word) ((addr) * (bits_word) / (HEX))

#define PLAT_ADDR 40         /* Memory address in words to write acrh. PLAT*/
#define SEED_ADDR_HEX 48         /* Memory address in words to write the seed */
#define SEED_ADDR_INT 56         /* Memory address in words to write the seed */


#define NMAT 8

#define STRSIZE 80

void usage ();
void generate_param ();
void write_input_param (FILE *f);
void write_param();
void compute_values ();
void read_values ();
void compare_write_values ();
int gen88();
int gen57();
int gen34as57();
int int12(int val);
int int16(int val);

/* Using Global variables to increase program clarity */
/* Input parameters */
int aR[NMAT], aI[NMAT];
int bR[NMAT], bI[NMAT];
int cR[NMAT], cI[NMAT];
int dR[NMAT], dI[NMAT];

int aRTab[NMAT] = {0,  0, 1, -1,  3, -3, 32767, -32768};
int bITab[NMAT] = {0,  1, 0,  0, -5,  5, 32767, -32768};

/* Computed values */
int minMat = 0;
int minDet = MAXSIGNED32b;
int maxMat = 0;
int maxDet = MINSIGNED32b;
int detR[NMAT];			/* real part of determinant  */
int detI[NMAT];			/* imaginary part of determinant  */
int det_1n[NMAT];
int sumDetRp[NMAT];
int sumDetIp[NMAT];
int sumDetR = 0;
int sumDetI = 0;
int averageDetR;
int averageDetI;


/* Computed values from FPGA */
int detR_fpga[NMAT];
int detI_fpga[NMAT];
int averageDetR_fpga;
int averageDetI_fpga;

/* Internal variables */
int mode = GENMODE;
int qi, qf;
unsigned int seed = 0;
unsigned int lixo = 0;
int modegen = -1;
int plat = -1;
char version[STRSIZE];

/* intermidiate computed values */
int p1R[NMAT];
int p1I[NMAT];
int p2R[NMAT];
int p2I[NMAT];


/* file name strings */
char dat[STRSIZE];
char itr[STRSIZE];
char out[STRSIZE];

/* Memories input (write on board) and output (read from board) */
char memDatChar[MEMSIZE_INCHAR]; /* memory download to FPGA in hex chars */
int memDatWrds[MEMSIZE_INWRDS]; /* memory download to FPGA in words (ints) */

char memOutChar[MEMSIZE_OUTCHAR]; /* memory read from the FPGA in hex chars */
int memOutWrds[MEMSIZE_OUTWRDS]; /* memory read from the FPGA in words (ints) */

FILE *DAT, *ITR, *OUT;


int main (int argc, char *argv[])
{

  printf ("%s\n%s (P%d V%s)\n\n", COURSE, NAME, PLAT, VERSION);

  if (argc == 2 || argc == 4) {         /* comparing results */
    mode = CMPMODE;
    sprintf(itr, "%s.itr", argv[1]);
    sprintf(out, "%s.out", argv[1]);
    if (argc == 4) {
      qi = atoi(argv[2]);
      qf = atoi(argv[3]);
    }
    else {
      qi = 14;
      qf = 18;
    }
    if (qi+qf != 32) {
      fprintf(stderr, "Output must fit on 32 bits (Qi+Qf = Q%d.%d != 32)\n", qi, qf);
      exit(-1);
    }

    if (( ITR = fopen(itr, "rb")) == NULL) {
      fprintf(stderr, "Can not open ITR file %s\n", itr);
      exit(-1);
    }
    if (( OUT = fopen(out, "rb")) == NULL) {
      fprintf(stderr, "Can not open OUT file %s\n", out);
      exit(-1);
    }

    if (fscanf(ITR,
               "Parameters: Integer  Hexdecimal   Fix Point 5.7  seed={ %u [%08X] } M%d P%d V%s",
               &seed, &lixo, &modegen, &plat, version) != 5){
      fprintf(stderr, "Can not read header line on file: %s\n", itr);
      exit(-1);
    }

    printf("READ: MODEGEN = %d \t PLAT = %d \t VERSION = %s \t SEED = %u [%08X]\n",  modegen, plat, version, seed, lixo);

    if ( modegen != MODEGEN) {
      fprintf(stderr, "Problems with modegen values on .dat file (prog=%d file=%d).\n", MODEGEN, modegen);
      exit(-1);
    }


    if ( seed != lixo) {
      fprintf(stderr, "Problems with seed values on .dat file (seedDEC=%d seedHEX=%d).\n", seed, lixo);
      exit(-1);
    }


    if (plat != PLAT) {
      fprintf(stderr, "Program not-compatible with .dat file (prog=%d file=%d).\n", PLAT, plat);
      exit(-1);
    }

    if (strcmp(version, VERSION) != 0) {
      fprintf(stderr, "Program version does not match with .dat file (prog=%s file=%s).\n", VERSION, version);
      exit(-1);
    }

  }
  else if (argc == 3) {         /* generating parameters */
    mode = GENMODE;
    seed = (unsigned int) atof(argv[1]);
    sprintf(dat, "%s.dat", argv[2]);
    sprintf(itr, "%s.itr", argv[2]);
    if (( DAT = fopen(dat, "wb")) == NULL) {
      fprintf(stderr, "Can not open file %s\n", dat);
      exit(-1);
    }
    if (( ITR = fopen(itr, "wb")) == NULL) {
      fprintf(stderr, "Can not open file %s\n", itr);
      exit(-1);
    }

  }
  else {
    usage();
    exit(1);
  }

  if ( DEBUG ) {
    printf("Sizeof: char= %lu bytes,  int= %lu bytes,  long= %lu bytes,   RAND_MAX= %lu\n",
           (unsigned long int)sizeof(char),
           (unsigned long int)sizeof(int),
           (unsigned long int)sizeof(long),
	   (unsigned long int)RAND_MAX);
    printf("    Input/data memory: %6d x %3d bits  (%6d x 8 bits) = %3d Kb\n",
           MEMSIZE_INWRDS, BITS_WORD_IN, MEMSIZE_INCHAR, MEMSIZE_INCHAR*CHR/1024);
    printf("Output/results memory: %6d x %3d bits  (%6d x 8 bits) = %3d Kb\n",
           MEMSIZE_OUTWRDS, BITS_WORD_OUT, MEMSIZE_OUTCHAR, MEMSIZE_OUTCHAR*CHR/1024);
    printf("\n");
  }

  if ( sizeof(int) != SIZEOFINT) { /* check the expected size of int */
    fprintf(stderr, "Sizeof int is not compatible (prog=%lu != %d=expected).\n",
            (unsigned long int)sizeof(int), SIZEOFINT);
    exit(-1);
  }

  if ( MEMSIZE_INCHAR % INIT_SIZE_CHAR != 0) {
    fprintf(stderr, "Size of input/data memory (%d words x %d bits) is not compatible with INIT_xx.\nThe value of MEMSIZE_INWRDS should be extended from %d to %d words\n",
            MEMSIZE_INWRDS, BITS_WORD_IN, MEMSIZE_INWRDS,
            (MEMSIZE_INCHAR
             + (INIT_SIZE_CHAR - (MEMSIZE_INCHAR % INIT_SIZE_CHAR)))
            * HEX / BITS_WORD_IN
            ) ;
    exit(-1);
  }

  if ( MEMSIZE_OUTCHAR % INIT_SIZE_CHAR != 0) {
    fprintf(stderr, "Size of output/data memory (%d words x %d bits) is not compatible with INIT_xx.\nThe value of MEMSIZE_OUTWRDS should be extended from %d to %d words\n",
            MEMSIZE_OUTWRDS, BITS_WORD_OUT, MEMSIZE_OUTWRDS,
            (MEMSIZE_OUTCHAR
             + (INIT_SIZE_CHAR - (MEMSIZE_OUTCHAR % INIT_SIZE_CHAR)))
            * HEX / BITS_WORD_OUT
            ) ;
    exit(-1);
  }


  if (seed == 0) {
    seed = (unsigned int) time(NULL);
  }
  srand(seed);

  generate_param();
  compute_values();

  if (mode == GENMODE) {
    write_param();
  }
  else if (mode == CMPMODE) {
    read_values();
    compare_write_values();
  }
  return 0;
}


void usage ()
{
  printf ("usage: adet RndSeed ProbName  - to generate problem parameters.\n");
  printf ("usage: adet ProbName [Qi Qf]  - to compare results (def. Qi.f=Q14.18).\n");
}


void generate_param ()
{
  int k;

  if ( DEBUG ) {
    printf("Parameters: seed={ %u [%08X] } M%d P%d V%s\n\n",
           seed, seed, MODEGEN, PLAT, VERSION);
    /* printf("USG seed= %u [%08X]\n", seed, seed); */
  }

  for (k=0; k < NMAT ; k++) {

    aR[k] = gen57();
    aI[k] = gen57();

    bR[k] = gen57();
    bI[k] = gen57();

    cR[k] = gen57();
    cI[k] = gen57();

    dR[k] = gen57();
    dI[k] = gen57();


    /* if ( MODEGEN == 1) {	/\* all data Q3.4 *\/ */
    if ( seed == 765) {
      aR[k] = gen34as57();
      aI[k] = gen34as57();

      bR[k] = gen34as57();
      bI[k] = gen34as57();

      cR[k] = gen34as57();
      cI[k] = gen34as57();

      dR[k] = gen34as57();
      dI[k] = gen34as57();

    }

    if ( MODEGEN == 2) {
      if (k == 0) {
	/* max detR */
        aR[k] = 0x800;      /* min */
	aI[k] = 0x800;      /* min */
        bR[k] = 0X7FF;      /* MAX */
	bI[k] = 0x800;      /* min */
	cR[k] = 0x800;      /* min */
	cI[k] = 0x800;      /* min */
        dR[k] = 0x800;      /* min */
	dI[k] = 0X7FF;      /* MAX */
      }
      if (k == NMAT-1) {
	/* min detI */
        aR[k] = 0X7FF;      /* MAX */
	aI[k] = 0X7FF;      /* MAX */
        bR[k] = 0x800;      /* min */
	bI[k] = 0x800;      /* min */
	cR[k] = 0x800;      /* min */
	cI[k] = 0x800;      /* min */
        dR[k] = 0x800;      /* min */
	dI[k] = 0x800;      /* min */
       }
    }

    if ( MODEGEN == 3) {
      aR[k] = aRTab[k];
      bI[k] = bITab[k];
    }

    aR[k] = int12(aR[k]);
    aI[k] = int12(aI[k]);

    bR[k] = int12(bR[k]);
    bI[k] = int12(bI[k]);

    cR[k] = int12(cR[k]);
    cI[k] = int12(cI[k]);

    dR[k] = int12(dR[k]);
    dI[k] = int12(dI[k]);

    if ( DEBUG ) {
      printf("MAT %d ------------------------------------------------- %d DBG\n",k,k);
      printf("    A =  INT: %5d +j %5d,  HEX: [%.3X]+j[%.3X],  Q5.7: %11.7f +j %11.7f\n",
	     aR[k], aI[k],
	     MASK12 & aR[k], MASK12 & aI[k],
	     SCALE7 * aR[k], SCALE7 * aI[k]);

      printf("    B =  INT: %5d +j %5d,  HEX: [%.3X]+j[%.3X],  Q5.7: %11.7f +j %11.7f\n",
	     bR[k], bI[k],
	     MASK12 & bR[k], MASK12 & bI[k],
	     SCALE7 * bR[k], SCALE7 * bI[k]);

      printf("    C =  INT: %5d +j %5d,  HEX: [%.3X]+j[%.3X],  Q5.7: %11.7f +j %11.7f\n",
	     cR[k], cI[k],
	     MASK12 & cR[k], MASK12 & cI[k],
	     SCALE7 * cR[k], SCALE7 * cI[k]);

      printf("    D =  INT: %5d +j %5d,  HEX: [%.3X]+j[%.3X],  Q5.7: %11.7f +j %11.7f\n",
	     dR[k], dI[k],
	     MASK12 & dR[k], MASK12 & dI[k],
	     SCALE7 * dR[k], SCALE7 * dI[k]);
      printf("\n");
    }

  }

}




int gen88()			/* signed Q8.8 */
{
  int v;
  v = (rand()/(double)RAND_MAX) * MASKPOS32;
  if ( 0 && DEBUG ) { printf ("Vr= %d  ", v);  }
  v = v & MASK16;
  if ( (MASKSIG16 & v ) != 0  ) {
    v = v | MASKNEG16;          /* siganl extension on negative numbers  */
  }
  if ( 0 && DEBUG ) { printf ("v= %d (%X) \n", v, v); }
  return (v);
}

int gen57()			/* signed Q5.7 */
{
  int v;
  v = (rand()/(double)RAND_MAX) * MASKPOS32;
  if ( 0 && DEBUG ) { printf ("Vr= %d  ", v);  }
  v = v & MASK12;
  if ( (MASKSIG12 & v ) != 0  ) {
    v = v | MASKNEG12;          /* siganl extension on negative numbers  */
  }
  if ( 0 && DEBUG ) { printf ("v= %d (%X) \n", v, v); }
  return (v);
}

int gen34as57()			/* signed Q5.7 */
{
  int v;
  v = (rand()/(double)RAND_MAX) * MASKPOS32;
  if ( 0 && DEBUG ) { printf ("Vr= %d  ", v);  }
  v = v & MASKQ34;
  if ( (MASKSIGQ34 & v ) != 0  ) {
    v = v | MASKNEGQ34;          /* siganl extension on negative numbers  */
  }
  if ( 0 && DEBUG ) { printf ("v= %d (%X) \n", v, v); }
  return (v);
}


int int16(int val)		/* guarentee a 12 bit number */
{
  if ((MASKSIG16 & val) == 0 ) { /* value is positive */
    return (MASKPOS16 & val);	 /* force signal extension as positive */
  }
  else {			/* value is negative  */
    return (MASKNEG16 | val);	/* force signal extension as negative */
  }
}


int int12(int val)		/* guarentee a 12 bit number */
{
  if ((MASKSIG12 & val) == 0 ) { /* value is positive */
    return (MASKPOS12 & val);	 /* force signal extension as positive */
  }
  else {			/* value is negative  */
    return (MASKNEG12 | val);	/* force signal extension as negative */
  }
}

void write_input_param (FILE *f)
{
  int k;
  char sol;

  /* fprintf(f, "Seed:  %u\n", (unsigned int)seed); */
  fprintf(f, "Parameters: Integer  Hexdecimal   Fix Point 5.7  seed={ %u [%08X] } M%d P%d V%s\n",
          seed, seed, MODEGEN, PLAT, VERSION);
  for (k=0; k < NMAT ; k++) {
    sol = ' ';
    if ( k == minMat) {
      sol = '<';
    }
    if ( k == maxMat) {
      sol = '>';
    }


    fprintf(f, "MAT %d ------------------------------------------------------------------------ MAT %d\n",k,k);
    fprintf(f, "    A =  INT: %5d +j %5d,  HEX: [%.3X]+j[%.3X],  Q5.7: %11.7f +j %11.7f\n",
	    aR[k], aI[k],
	    MASK12 & aR[k], MASK12 & aI[k],
	    SCALE7 * aR[k], SCALE7 * aI[k]);

    fprintf(f, "    B =  INT: %5d +j %5d,  HEX: [%.3X]+j[%.3X],  Q5.7: %11.7f +j %11.7f\n",
	    bR[k], bI[k],
	    MASK12 & bR[k], MASK12 & bI[k],
	    SCALE7 * bR[k], SCALE7 * bI[k]);

    fprintf(f, "    C =  INT: %5d +j %5d,  HEX: [%.3X]+j[%.3X],  Q5.7: %11.7f +j %11.7f\n",
	    cR[k], cI[k],
	    MASK12 & cR[k], MASK12 & cI[k],
	    SCALE7 * cR[k], SCALE7 * cI[k]);

    fprintf(f, "    D =  INT: %5d +j %5d,  HEX: [%.3X]+j[%.3X],  Q5.7: %11.7f +j %11.7f\n",
	    dR[k], dI[k],
	    MASK12 & dR[k], MASK12 & dI[k],
	    SCALE7 * dR[k], SCALE7 * dI[k]);


    fprintf(f, "  Computed values:\n");
    fprintf(f, "   %c det[%d] = INT: %9d +j %9d,  HEX: [%.7X]+j[%.7X],  FXP: %17.11f +j %17.11f\n",
	    sol, k,
	    detR[k], detI[k],
	    MASK26 & detR[k], MASK26 & detI[k],
	    SCALE14 * detR[k], SCALE14 * detI[k]);
    fprintf(f, "  det_1n[%d] = INT: %10d,  HEX: [%.7X],  FXP: %17.11f\n", k,
	    det_1n[k], MASK27 & det_1n[k], SCALE14 * det_1n[k]);

    fprintf(f, "  sumDet[%d] = INT: %10d +j %10d,  HEX: [%.8X]+j[%.8X],  FXP: %16.11f +j %16.11f\n", k,
	    sumDetRp[k], sumDetIp[k],
	    MASK29 & sumDetRp[k], MASK29 & sumDetIp[k],
	    SCALE14 * sumDetRp[k], SCALE14 * sumDetIp[k]);

	    fprintf(f, "\n");
  }
  fprintf(f, "Problem Solution ================================================================== Problem Solution\n");
  fprintf(f, "   averageDet = INT: %10d +j %10d,  HEX: [%.8X]+j[%.8X],  FXP: %18.12f +j %18.12f\n",
	  averageDetR, averageDetI,
	  MASK29 & averageDetR, MASK29 & averageDetI,
	  SCALE17 * averageDetR, SCALE17 * averageDetI);
  fprintf(f, "   Matrix with lower  1-norm: %d (LD%d)\n", minMat, minMat);
  fprintf(f, "   Matrix with higher 1-norm: %d (LD%d)\n", maxMat, maxMat+8);
}



void write_param ()
{
  int addr;
  int i, k;
  char sol;
  int seedx, dec;

  int max_blocks, block, addr_block_beg;
  char sep;

  /********************************************************************
   *  Write values on the output and iteration results on ITR file
   *******************************************************************/
  printf(      "Line Results:        Integer         Hexdecimal              Fix Point\n");
  /* write_input_param(stdout); */

  write_input_param(ITR);
  fprintf(ITR, "Mat Results:        Integer  Hexdecimal     Fix Point\n");

  for (k=0 ; k < NMAT; k++) {
    sol = ' ';
    if ( k == minMat) {
      sol = '<';
    }
    if ( k == maxMat) {
      sol = '>';
    }

    printf(" %c det[%d] = INT: %8d +j %8d,  HEX: [%.7X]+j[%.7X],  FXP: %17.11f +j %17.11f\n",
	   sol, k,
	   detR[k], detI[k],
	   MASK26 & detR[k], MASK26 & detI[k],
	   SCALE14 * detR[k], SCALE14 * detI[k]);
    fprintf(ITR, " %c det[%d] = INT: %8d +j %8d,  HEX: [%.7X]+j[%.7X],  FXP: %17.11f +j %17.11f\n",
	    sol, k,
	    detR[k], detI[k],
	    MASK26 & detR[k], MASK26 & detI[k],
	    SCALE14 * detR[k], SCALE14 * detI[k]);
  }
  /* fprintf(stdout, "avgDet = INT: %10d +j %10d,  HEX: [%.8X]+j[%.9X],  FXP: %18.12f +j %18.12f\n", */
  printf("avgDet = INT: %d +j %d,  HEX: [%.8X]+j[%.8X],  FXP: %1.12f +j %1.12f\n",
	 averageDetR, averageDetI,
	 MASK29 & averageDetR, MASK29 & averageDetI,
	 SCALE17 * averageDetR, SCALE17 * averageDetI);

  /* fprintf(ITR, "avgDet = INT: %10d +j %10d,  HEX: [%.8X]+j[%.9X],  FXP: %18.12f +j %18.12f\n", */
  fprintf(ITR, "avgDet = INT: %d +j %d,  HEX: [%.8X]+j[%.8X],  FXP: %1.12f +j %1.12f\n",
	  averageDetR, averageDetI,
	  MASK29 & averageDetR, MASK29 & averageDetI,
	  SCALE17 * averageDetR, SCALE17 * averageDetI);

  fclose(ITR);


  /********************************************************************
   *  Write input memory values on DAT file
   *******************************************************************/
  for ( addr = 0; addr < MEMSIZE_INWRDS ; addr++) {
    memDatWrds[addr] = 0;       /* clean memory DAT word (int) array */
  }
  for ( addr = 0; addr < MEMSIZE_INCHAR ; addr++) {
    memDatChar[addr] = 0x0;     /* clean memory DAT char array */
  }

  addr = 0;
  for (k=0; k < NMAT ; k++) { /* copy matrices coefficients 16b+16b in each address*/
    memDatWrds[addr++] = (((0xA)<<12 | (MASK12 & aR[k]))<<16) | (((0x0)<<12 | (MASK12 & aI[k]))<<0);
    memDatWrds[addr++] = (((0xB)<<12 | (MASK12 & bR[k]))<<16) | (((0x0)<<12 | (MASK12 & bI[k]))<<0);
    memDatWrds[addr++] = (((0xC)<<12 | (MASK12 & cR[k]))<<16) | (((0x0)<<12 | (MASK12 & cI[k]))<<0);
    memDatWrds[addr++] = (((0xD)<<12 | (MASK12 & dR[k]))<<16) | (((0x0)<<12 | (MASK12 & dI[k]))<<0);

    /* memDatWrds[addr++] = aR[k]; */
    /* memDatWrds[addr++] = aI[k]; */

    /* memDatWrds[addr++] = bR[k]; */
    /* memDatWrds[addr++] = bI[k]; */

    /* memDatWrds[addr++] = cR[k]; */
    /* memDatWrds[addr++] = aI[k]; */

    /* memDatWrds[addr++] = dR[k]; */
    /* memDatWrds[addr++] = dI[k]; */
  }

  /* OLD include some watermarking/checking values */
  /* sprintf(&(memDat[PLAT_ADDR]), "%u", (unsigned int)PLAT); */
  /* sprintf(&(memDat[SEED_ADDR]), "%u", (unsigned int)seed); */

  /* include some watermarking/checking values */
  memDatWrds[PLAT_ADDR] = (unsigned int)PLAT;
  /* SEED value in hex */
  for ( addr=0; addr< (int)sizeof(seed)*CHR/BITS_WORD_IN ; addr++ ) {
    memDatWrds[SEED_ADDR_HEX+addr] = (unsigned int)seed>>(addr*BITS_WORD_IN);
  }
  /* SEED value in dec */
  seedx = seed;
  printf("seed %d\n", seed);
  for ( addr=0; seedx > 0 ; addr++ ) {
    int hex = 0;
    for ( i=1; i <=BITS_WORD_IN/HEX; i++) {
      dec = (seedx) % 10;
      hex = (dec<<(4*(i-1))) | hex;
      /* printf("Dec=%d  hex= %d [%.1X]\n",dec, hex, hex); */
      seedx = seedx/10;
    }
    /* printf("[%d] %.8X\n",addr, hex); */
    memDatWrds[SEED_ADDR_INT+addr] = hex;
  }


  /* copy converting from word men to char mem */
  for ( addr = 0; addr < MEMSIZE_INWRDS ; addr++) {
    for ( i=0; i<BITS_WORD_IN/HEX ; i++ ) {
      sprintf(&(memDatChar[addr*BITS_WORD_IN/HEX + i]), "%.1X",
              MASK4 & (memDatWrds[addr] >> (i*HEX)));
      /* printf("[%4d] = %c\n", addr*BITS_WORD_IN/HEX + i, */
      /* 	     memDatChar[addr*BITS_WORD_IN/HEX + i]); */
    }
  }


  /* writing raw memory data to a file  */
  /* for ( addr = 0; addr < MEMSIZE_INWRDS ; addr++) { */
  /*   fwrite(&(memDatWrds[addr]), BITS_WORD_IN/CHR, 1, RAW); */
  /* } */
  /* fclose(RAW); */

  /* writing INIT_xx memory data */
  max_blocks = MEMSIZE_INCHAR / INIT_SIZE_CHAR;
  max_blocks = 8;               /* 2 kbit */
  for ( block = 0 ; block < max_blocks; block++) {
    fprintf(DAT, "INIT_%02X => X\"", block);
    addr_block_beg = block * INIT_SIZE_CHAR + INIT_SIZE_CHAR;
    for (i = 1 ; i <= INIT_SIZE_CHAR; i++) {
      addr = addr_block_beg - (i);
      fprintf(DAT, "%c", memDatChar[addr]); /* write chars in "reverse" order*/
    }
    sep = ',';
    if ( block == max_blocks-1) {
      sep = ' ';
    }
    fprintf(DAT, "\"%c\n", sep);
  }
  fclose(DAT);
}


void compute_values ()
{
  int k;
  maxMat = 0;
  minMat = 0;
  maxDet = 0x80000000; 		/*for 32bits = -1x2^31 */
  minDet = 0x1FFFFFFF;		/*for 32bits = 1x2^31 -1*/
  sumDetR = 0;
  sumDetI = 0;

  for (k=0; k < NMAT ; k++) {

    detR[k] = (aR[k]*dR[k] - aI[k]*dI[k]) - (cR[k]*bR[k] - cI[k]*bI[k]); /** Sum_4 (10.14) = 12.14 */
    detI[k] = (aI[k]*dR[k] + aR[k]*dI[k]) - (cR[k]*bI[k] + cI[k]*bR[k]); /** Sum_4 (10.14) = 12.14 */

    det_1n[k] = abs(detR[k]) + abs(detI[k]); /** 12.14 + 12.14 = 13.14  */

    if ( det_1n[k] < minDet ) { minMat = k; minDet = det_1n[k];}
    if ( det_1n[k] > maxDet ) { maxMat = k; maxDet = det_1n[k];}

    sumDetR += detR[k]; /** Sum_8 (12.14) = 15.14 */
    sumDetRp[k] = sumDetR;
    sumDetI += detI[k]; /** Sum_8 (12.14) = 15.14 */
    sumDetIp[k] = sumDetI;
  }

  averageDetR = (sumDetR / NMAT);
  averageDetI = (sumDetI / NMAT);
}



void read_values () /* read values from the file with data read from memOut FPGA memory */
{
  int addr;
  int k;
  int sign_mask;

  for ( addr = 0; addr < MEMSIZE_OUTCHAR ; addr++) {
    memOutChar[addr] = 0x0;     /* clean memory OUT char array */
  }
  for ( addr = 0; addr < MEMSIZE_OUTWRDS ; addr++) {
    memOutWrds[addr] = 0;       /* clean memory OUT words array */
  }


  for ( addr = 0; addr < MEMSIZE_OUTCHAR ; addr++) {
    if ( fscanf(OUT, "%c", &(memOutChar[addr])) != 1 ) {
      fprintf(stderr, "FPGA file (%s) is not complete with %d bytes on %d.\n",
              out, MEMSIZE_OUTCHAR, addr);
      exit(-1);
    }
  }
  fclose(OUT);



  for ( addr = 0, k=0; k < NMAT ; k++) {
    /* check the sign bit, on a 31 or less bits numbers - NOT NEED ON 32bit NUMBERS */
    sign_mask = 0x00000000; /* positive 16b/23b mask */
    /* if ((0x80 & memOutChar[addr+1]) != 0) { */
    /*  sign_mask = 0xFFFF0000; /\* negative 16b mask *\/ */
    /* } */
    detR_fpga[k] = ((sign_mask) |
		      (0x000000FF & (memOutChar[addr++]<<0  )) |
		      (0x0000FF00 & (memOutChar[addr++]<<8  )) |
      		      (0x00FF0000 & (memOutChar[addr++]<<16 )) |
		      (0xFF000000 & (memOutChar[addr++]<<24 )));

    detI_fpga[k] = ((sign_mask) |
		      (0x000000FF & (memOutChar[addr++]<<0  )) |
		      (0x0000FF00 & (memOutChar[addr++]<<8  )) |
      		      (0x00FF0000 & (memOutChar[addr++]<<16 )) |
		      (0xFF000000 & (memOutChar[addr++]<<24 )));


    /* if ( k >= 2*(NMAT-1)) { break; } */
  }

  averageDetR_fpga = ((sign_mask) |
		      (0x000000FF & (memOutChar[addr++]<<0  )) |
		      (0x0000FF00 & (memOutChar[addr++]<<8  )) |
      		      (0x00FF0000 & (memOutChar[addr++]<<16 )) |
		      (0xFF000000 & (memOutChar[addr++]<<24 )));

  averageDetI_fpga = ((sign_mask) |
		      (0x000000FF & (memOutChar[addr++]<<0  )) |
		      (0x0000FF00 & (memOutChar[addr++]<<8  )) |
      		      (0x00FF0000 & (memOutChar[addr++]<<16 )) |
		      (0xFF000000 & (memOutChar[addr++]<<24 )));

}

void compare_write_values ()
{
  float errorDiff;
  char sol;
  int k;

  printf("Results PC vs FPGA:\n");
  printf("                _____________ PC _________________________  ____________ FPGA ________________________    ___ Difference _____\n");
  printf("Mat              Integer  Hexdecimal    Fix.Point(Q14.18)    Integer  Hexdecimal    Fix.Point(Q%02d.%02d)         Floating\n",
         qi, qf);
  for (k = 0; k < NMAT; k++) {
    sol = ' ';
    if ( k == minMat) {
      sol = '<';
    }
    if ( k == maxMat) {
      sol = '>';
    }
    /* Real */
    printf("%c detRe[%1d] =  %10d  [%.8X]  %18.12f",
	   sol, k, detR[k]<<4, MASK32 & (detR[k]<<4), SCALE18 * (detR[k]<<4));
    printf("  %10d  [%.8X]  %18.12f",
	   detR_fpga[k], MASK32 & detR_fpga[k],  pow(2, -qf) * detR_fpga[k]);

    errorDiff =  SCALE18 * (detR[k]<<4)  -  pow(2, -qf) * detR_fpga[k];
    printf("    %18.12f\n", errorDiff);

    /* Imaginary */
    printf("%c detIm[%1d] =  %10d  [%.8X]  %18.12f",
	   sol, k, detI[k]<<4, MASK32 & (detI[k]<<4), SCALE18 * (detI[k]<<4));
    printf("  %10d  [%.8X]  %18.12f",
	   detI_fpga[k], MASK32 & detI_fpga[k], pow(2, -qf) * detI_fpga[k]);

    errorDiff =  SCALE18 * (detI[k]<<4)  -  pow(2, -qf) * detI_fpga[k];
    printf("    %18.12f\n", errorDiff);
  }
  printf("Average\n");
  sol = ' ';
  /* Real */
  printf("%c avgDetRe[%1d] %10d  [%.8X]  %18.12f",
	 sol, k, averageDetR<<1, MASK32 & (averageDetR<<1), SCALE18 * (averageDetR<<1));
  printf("  %10d  [%.8X]  %18.12f",
	 averageDetR_fpga, MASK32 & averageDetR_fpga, pow(2, -qf) * averageDetR_fpga);

  errorDiff =  SCALE18 * (averageDetR<<1)  -  pow(2, -qf) * averageDetR_fpga;
    printf("    %18.12f\n", errorDiff);

    /* Imaginary */
    printf("%c avgDetIm[%1d] %10d  [%.8X]  %18.12f",
	   sol, k, averageDetI<<1, MASK32 & (averageDetI<<1), SCALE18 * (averageDetI<<1));
    printf("  %10d  [%.8X]  %18.12f",
	   averageDetI_fpga, MASK32 & averageDetI_fpga, pow(2, -qf) * averageDetI_fpga);

    errorDiff =  SCALE18 * (averageDetI<1)  -  pow(2, -qf) * averageDetI_fpga;
    printf("    %18.12f\n", errorDiff);
}
