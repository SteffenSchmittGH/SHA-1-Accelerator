/*
 * sha1_calc.h
 *
 *  Created on: 25.11.2024
 *      Author: schmi
 */

#ifndef SHA1_CALC_H_
#define SHA1_CALC_H_
#include <stdint.h>

#define BLOCK_LENGTH 512
#define BLOCK_LENGTH_BYTES 64

unsigned int get_length_in_bytes(const char * message);

void print_block(unsigned char * message);
void padded_block_message(unsigned char* message, uint32_t* W1);
unsigned int RotShift1(uint32_t X);
unsigned int RotShift5(uint32_t X);
unsigned int RotShift30(uint32_t X);
unsigned int PARITY(uint32_t X, uint32_t Y, uint32_t Z);
unsigned int f_t(uint32_t t, uint32_t X, uint32_t Y, uint32_t Z);
unsigned int CH(uint32_t X, uint32_t Y, uint32_t Z);
unsigned int MAJ(uint32_t X, uint32_t Y, uint32_t Z);

void blockDecomposition(const uint32_t *M1,uint32_t *W1);

void HashComputation(uint32_t * hash_ptr, const uint32_t * X, const uint32_t *prev_hash);
#endif /* SHA1_CALC_H_ */
