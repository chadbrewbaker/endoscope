#include <stdint.h>
#define W 4


void setfront(int* a, int frontval){
   a[0] = frontval;
}


void matrix_mul_gf2(uint16_t *a, uint16_t *b, uint16_t *c) {
  // these arrays can be read in two successive xmm registers or in a single ymm
  uint16_t D[16];       // Temporary
  uint16_t C[16] = {0}; // result
  uint16_t B[16];
  uint16_t A[16];
  int i, j;
  uint16_t top_row;
  // Preprocess B (while reading from input)
  // -- "un-tilt" the diagonal to bit position 0x8000
  for (i = 0; i < W; i++)
    B[i] = (b[i] << i) | (b[i] >> (W - i));
  for (i = 0; i < W; i++)
    A[i] = a[i]; // Just read in matrix 'a'
  // Loop W times
  // Can be parallelized 4x with MMX, 8x with XMM and 16x with YMM instructions
  for (j = 0; j < W; j++) {
    for (i = 0; i < W; i++)
      D[i] = ((int16_t)B[i]) >> 15; // copy sign bit to rows
    for (i = 0; i < W; i++)
      B[i] <<= 1; // Prepare B for next round
    for (i = 0; i < W; i++)
      C[i] ^= A[i] & B[i]; // Add the partial product

    top_row = A[0];
    for (i = 0; i < W - 1; i++)
      A[i] = A[i + 1];
    A[W - 1] = top_row;
  }
  for (i = 0; i < W; i++)
    c[i] = C[i]; // return result
}

void matmul_basicgf2(uint16_t *a, uint16_t *b, uint16_t *c) {
  int i, j, k;
  int index;
  for (i = 0; i < W; i++) {
    for (j = 0; j < W; j++) {
      index = (i * W) + j;
      c[index] = 0;
      for (k = 0; k < W; k++) {
        c[index] += a[(i * W) + k] * b[(k * W) + j];
      }
      c[index] = c[index] % 2;
    }
  }
}

uint16_t packRow(uint16_t *row) { return 0; }

void toPacked(uint16_t *m, uint16_t *packed) {
  int i;
  *packed = 0;
  for (i = 0; i < W; i++) {
	if(m[i])
          *packed += (1<<i);	   
  }
}

void unpackRow(uint16_t r, uint16_t *row) {
  int i;
  for(i=0;i<W;i++){
     row[i] = (1 << i) & r;	 
  }
}

void toUnpacked(uint16_t *packed, uint16_t *m) {
  int i;
  for (i = 0; i < W; i++) {
    unpackRow(packed[i], &m[i * W]);
  }
}


void domultpacked(int x){
    uint16_t a[W];
    uint16_t b[W];
    uint16_t c[W];
    matrix_mul_gf2(a,b,c);
}

void domultunpacked(int x){
	    uint16_t a[W*W];
	        uint16_t b[W*W];
		    uint16_t c[W*W];
matmul_basicgf2(a,b,c);
}


int test() {
  uint16_t row[W];
  uint16_t packed;
  int i;
  for (i = 0; i < W; i++) {
    row[i] = 1;
  }

  toPacked(row, &packed);
  for (i = 0; i < W; i++) {
    row[i] = 0;
  }
  unpackRow(packed, row);

  for (i = 0; i < W; i++) {
    if (!row[i])
      return 1;
  }

  return 0;
}
