/*
 ============================================================================
 Name        : SHA1.c
 Author      : 
 Version     :
 Copyright   : Your copyright notice
 Description : Hello World in C, Ansi-style
 ============================================================================
 */

#include <stdio.h>
#include <stdlib.h>
#include "sha1_calc.h"
#include <inttypes.h>
#include <stdio.h>
int main(void) {
	/*Sha1*/
#if 1
	unsigned char message[18] = "FSoC24/25 is fun!";
	uint32_t* W_1 = calloc(80,sizeof(uint32_t));
	padded_block_message(message, W_1);
	for(int i = 0; i < 80; i++){
		printf("Hexadecimal W_1: 0x%" PRIx32 " " "%d" "\n", W_1[i],i);
	}
	uint32_t* hash_ptr = calloc(5, sizeof(uint32_t));
	const uint32_t* prev_hash = calloc(5,sizeof(uint32_t));
	HashComputation(hash_ptr, W_1,prev_hash);
	free(W_1);
#endif
	/*block length test*/
#if 0
	const char message[18] = "FSoC24/25 is fun!";
	uint32_t lengthinbytes = get_length_in_bytes(message);
	printf("length in bytes %d",lengthinbytes);
	uint32_t last_byte_padded_message = lengthinbytes*8;
#endif
	/*test print_block*/
#if 0
	unsigned char message[18] = "FSoC24/25 is fun!";
	print_block(message);
#endif
	//unsigned int test = RotShift30(0b11111000000000000000000000000000);

	return EXIT_SUCCESS;

}
