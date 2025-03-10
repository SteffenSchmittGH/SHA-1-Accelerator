/*
 * sha1_calc.c
 *
 *  Created on: 25.11.2024
 *      Author: schmi
 */

#ifndef SHA1_CALC_C_
#define SHA1_CALC_C_

#include "sha1_calc.h"
#include <stdint.h>
#include <stdlib.h>
#include <inttypes.h>
#include <stdio.h>

void init_sha1(uint32_t * K, uint32_t * H) {
    for (int i = 0; i < 80; i++) {
        if (i <= 19) {
            K[i] = 0x5a827999;
        } else if (i <= 39) {
            K[i] = 0x6ed9eba1;
        } else if (i <= 59) {
            K[i] = 0x8f1bbcdc;
        } else {
            K[i] = 0xca62c1d6;
        }
    }
    H[0] = 0x67452301;
    H[1] = 0xefcdab89;
    H[2] = 0x98badcfe;
    H[3] = 0x10325476;
    H[4] = 0xc3d2e1f0;
}

uint32_t get_length_in_bytes(const char* message) {
    uint32_t i = 0;
    while (message[i] != '\0') {
        i++;
    }
    return i;
}

void padded_block_message(unsigned char* message, uint32_t* W1) {
    uint32_t lengthOfMessage = get_length_in_bytes((const char*)message);
    uint32_t padded_block_message[16] = { };
    uint32_t padded_block_message_index = 0;

    for (uint32_t i = 0; i <= lengthOfMessage; i += 4) {
        uint32_t help1 = 0, help2 = 0, help3 = 0, help4 = 0;
        help1 = ((uint32_t)message[i] << 24) & 0xff000000;
        help2 = ((uint32_t)message[i + 1] << 16) & 0x00ff0000;
        help3 = ((uint32_t)message[i + 2] << 8) & 0x0000ff00;
        help4 = ((uint32_t)message[i + 3]) & 0x000000ff;
        padded_block_message[padded_block_message_index++] = help1 | help2 | help3 | help4;
    }
    for (uint32_t i = lengthOfMessage + 1; i <= 14; i++) {
        padded_block_message[i] = 0x00;
    }
    int index_finishing_1 = (int)(lengthOfMessage*8/32);
    int shift = 32 - ((lengthOfMessage*8)%32 +1);
    padded_block_message[index_finishing_1] |= (1 << shift);
    padded_block_message[15] = lengthOfMessage*8;//0b10001000;
    uint32_t* M1 = calloc(16, sizeof(uint32_t));
    for (uint32_t i = 0; i < 16; i++) {
        M1[i] = padded_block_message[i];
    }
    blockDecomposition(M1,W1);
    free(M1);
}

void print_block(unsigned char* message) {
    uint32_t lengthOfMessage = get_length_in_bytes((const char*)message);
    uint32_t padded_block_message[16] = { };
    uint32_t padded_block_message_index = 0;

    for (uint32_t i = 0; i <= lengthOfMessage; i += 4) {
        uint32_t help1 = 0, help2 = 0, help3 = 0, help4 = 0;
        help1 = ((uint32_t)message[i] << 24) & 0xff000000;
        help2 = ((uint32_t)message[i + 1] << 16) & 0x00ff0000;
        help3 = ((uint32_t)message[i + 2] << 8) & 0x0000ff00;
        help4 = ((uint32_t)message[i + 3]) & 0x000000ff;
        padded_block_message[padded_block_message_index++] = help1 | help2 | help3 | help4;
    }
    for (uint32_t i = lengthOfMessage + 1; i <= 14; i++) {
        padded_block_message[i] = 0x00;
    }
    int index_finishing_1 = (int)(lengthOfMessage*8/32);
    int shift = 32 - ((lengthOfMessage*8)%32 +1);
    padded_block_message[index_finishing_1] |= (1 << shift);
    padded_block_message[15] = lengthOfMessage*8;//0b10001000;
    uint32_t* M1 = calloc(16, sizeof(uint32_t));
    for (uint32_t i = 0; i < 16; i++) {
        M1[i] = padded_block_message[i];
    }
    for(int i = 0; i < 16; i++){
    	printf("Hexadecimal M1: 0x%" PRIx32 " " "%d" "\n", M1[i], i);
    }
    free(M1);
}

unsigned int RotShift1(uint32_t X) {
    return (X << 1) | (X >> 31);
}

/*
unsigned int RotShift1(uint32_t X){
	unsigned int bitmask1 = 0x80000000;
	unsigned int MSBs1;
	MSBs1 = X & bitmask1;
	MSBs1 = MSBs1 >> (32-1);
	unsigned int X_shifted1;
	X_shifted1 = X << 1;
	unsigned int X_complete1;
	X_complete1 = X_shifted1 | MSBs1;
	return X_complete1;
}
*/
unsigned int RotShift5(uint32_t X) {
    return (X << 5) | (X >> 27);
}


unsigned int RotShift30(uint32_t X) {
    return (X << 30) | (X >> 2);
}

uint32_t CH(uint32_t X, uint32_t Y, uint32_t Z) {
    return (X & Y) ^ ((~X) & Z);
}

uint32_t MAJ(uint32_t X, uint32_t Y, uint32_t Z) {
    return (X & Y) ^ (X & Z) ^ (Y & Z);
}

uint32_t PARITY(uint32_t X, uint32_t Y, uint32_t Z) {
    return X ^ Y ^ Z;
}

void blockDecomposition(const uint32_t* M1, uint32_t* W1) {
    for (uint32_t i = 0; i < 16; i++) {
        W1[i] = M1[i];
    }
    for (uint32_t i = 16; i <= 79; i++) {
        W1[i] = RotShift1(W1[i - 3] ^ W1[i - 8] ^ W1[i - 14] ^ W1[i - 16]);
    }
}

uint32_t f_t(uint32_t t, uint32_t X, uint32_t Y, uint32_t Z) {
    if (t <= 19) {
        return CH(X, Y, Z);
    } else if (t <= 39) {
        return PARITY(X, Y, Z);
    } else if (t <= 59) {
        return MAJ(X, Y, Z);
    } else {
        return PARITY(X, Y, Z);
    }
}

void HashComputation(uint32_t* hash_ptr, const uint32_t* X, const uint32_t *prev_hash) {
    uint32_t* K1 = calloc(80, sizeof(uint32_t));
    uint32_t* H1 = calloc(5, sizeof(uint32_t));
    if (!K1 || !H1) {
        perror("Memory allocation failed");
        free(K1); free(H1);
        return;
    }

    init_sha1(K1,H1);
    for(int i = 0; i < 80; i++){
    	printf("Hexadecimal K: 0x%" PRIx32 " " "%d" "\n", K1[i],i);
    }
for(int i = 1; i < 2; i++){
    uint32_t a = H1[0], b = H1[1], c = H1[2], d = H1[3], e = H1[4];
    uint32_t T;
    uint32_t a_1 = RotShift5((a));
    uint32_t f_1 = f_t(0, b, c, d);
    uint32_t e_1 = e;
    uint32_t K_1 = K1[0];
    uint32_t X_1 = X[0];
    for (uint32_t t = 0; t < 80; t++) {
        T = RotShift5(a) + f_t(t, b, c, d) + e + K1[t] + X[t];
        e = d;
        d = c;
        c = RotShift30(b);
        b = a;
        a = T;
    }
    H1[0] += a;
    H1[1] += b;
    H1[2] += c;
    H1[3] += d;
    H1[4] += e;
}
    for(int i = 0; i < 5; i++){
    	printf("Hexadecimal H1: 0x%" PRIx32 "\n", H1[i]);
    }
    free(H1);free(K1);
    return;
}

#endif /* SHA1_CALC_C_ */
