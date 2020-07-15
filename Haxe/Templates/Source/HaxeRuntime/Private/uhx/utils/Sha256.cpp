#include "HaxeRuntime.h"
#include "uhx/utils/Sha256.h"

/*
 * SHA256 hash adapted from: SHA-256 hash in C and x86 assembly
 *
 * Copyright (c) 2017 Project Nayuki. (MIT License)
 * https://www.nayuki.io/page/fast-sha2-hashes-in-x86-assembly
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 * - The above copyright notice and this permission notice shall be included in
 *   all copies or substantial portions of the Software.
 * - The Software is provided "as is", without warranty of any kind, express or
 *   implied, including but not limited to the warranties of merchantability,
 *   fitness for a particular purpose and noninfringement. In no event shall the
 *   authors or copyright holders be liable for any claim, damages or other
 *   liability, whether in an action of contract, tort or otherwise, arising from,
 *   out of or in connection with the Software or the use or other dealings in the
 *   Software.
 */

inline static void sha256_compress(FSha256Output &state, const uint8 *block) {
	#define ROTR32(x, n)  (((0U + (x)) << (32 - (n))) | ((x) >> (n)))  // Assumes that x is uint32 and 0 < n < 32

	#define LOADSCHEDULE(i)  \
		schedule[i] = (uint32)block[i * 4 + 0] << 24  \
		            | (uint32)block[i * 4 + 1] << 16  \
		            | (uint32)block[i * 4 + 2] <<  8  \
		            | (uint32)block[i * 4 + 3] <<  0;

	#define SCHEDULE(i)  \
		schedule[i] = 0U + schedule[i - 16] + schedule[i - 7]  \
			+ (ROTR32(schedule[i - 15], 7) ^ ROTR32(schedule[i - 15], 18) ^ (schedule[i - 15] >> 3))  \
			+ (ROTR32(schedule[i - 2], 17) ^ ROTR32(schedule[i - 2], 19) ^ (schedule[i - 2] >> 10));

	#define ROUND(a, b, c, d, e, f, g, h, i, k) \
		h = 0U + h + (ROTR32(e, 6) ^ ROTR32(e, 11) ^ ROTR32(e, 25)) + (g ^ (e & (f ^ g))) + UINT32_C(k) + schedule[i];  \
		d = 0U + d + h;  \
		h = 0U + h + (ROTR32(a, 2) ^ ROTR32(a, 13) ^ ROTR32(a, 22)) + ((a & (b | c)) | (b & c));

	uint32 schedule[64];
	LOADSCHEDULE( 0)
	LOADSCHEDULE( 1)
	LOADSCHEDULE( 2)
	LOADSCHEDULE( 3)
	LOADSCHEDULE( 4)
	LOADSCHEDULE( 5)
	LOADSCHEDULE( 6)
	LOADSCHEDULE( 7)
	LOADSCHEDULE( 8)
	LOADSCHEDULE( 9)
	LOADSCHEDULE(10)
	LOADSCHEDULE(11)
	LOADSCHEDULE(12)
	LOADSCHEDULE(13)
	LOADSCHEDULE(14)
	LOADSCHEDULE(15)
	SCHEDULE(16)
	SCHEDULE(17)
	SCHEDULE(18)
	SCHEDULE(19)
	SCHEDULE(20)
	SCHEDULE(21)
	SCHEDULE(22)
	SCHEDULE(23)
	SCHEDULE(24)
	SCHEDULE(25)
	SCHEDULE(26)
	SCHEDULE(27)
	SCHEDULE(28)
	SCHEDULE(29)
	SCHEDULE(30)
	SCHEDULE(31)
	SCHEDULE(32)
	SCHEDULE(33)
	SCHEDULE(34)
	SCHEDULE(35)
	SCHEDULE(36)
	SCHEDULE(37)
	SCHEDULE(38)
	SCHEDULE(39)
	SCHEDULE(40)
	SCHEDULE(41)
	SCHEDULE(42)
	SCHEDULE(43)
	SCHEDULE(44)
	SCHEDULE(45)
	SCHEDULE(46)
	SCHEDULE(47)
	SCHEDULE(48)
	SCHEDULE(49)
	SCHEDULE(50)
	SCHEDULE(51)
	SCHEDULE(52)
	SCHEDULE(53)
	SCHEDULE(54)
	SCHEDULE(55)
	SCHEDULE(56)
	SCHEDULE(57)
	SCHEDULE(58)
	SCHEDULE(59)
	SCHEDULE(60)
	SCHEDULE(61)
	SCHEDULE(62)
	SCHEDULE(63)

	uint32 a = state.Hash[0];
	uint32 b = state.Hash[1];
	uint32 c = state.Hash[2];
	uint32 d = state.Hash[3];
	uint32 e = state.Hash[4];
	uint32 f = state.Hash[5];
	uint32 g = state.Hash[6];
	uint32 h = state.Hash[7];
	ROUND(a, b, c, d, e, f, g, h,  0, 0x428A2F98)
	ROUND(h, a, b, c, d, e, f, g,  1, 0x71374491)
	ROUND(g, h, a, b, c, d, e, f,  2, 0xB5C0FBCF)
	ROUND(f, g, h, a, b, c, d, e,  3, 0xE9B5DBA5)
	ROUND(e, f, g, h, a, b, c, d,  4, 0x3956C25B)
	ROUND(d, e, f, g, h, a, b, c,  5, 0x59F111F1)
	ROUND(c, d, e, f, g, h, a, b,  6, 0x923F82A4)
	ROUND(b, c, d, e, f, g, h, a,  7, 0xAB1C5ED5)
	ROUND(a, b, c, d, e, f, g, h,  8, 0xD807AA98)
	ROUND(h, a, b, c, d, e, f, g,  9, 0x12835B01)
	ROUND(g, h, a, b, c, d, e, f, 10, 0x243185BE)
	ROUND(f, g, h, a, b, c, d, e, 11, 0x550C7DC3)
	ROUND(e, f, g, h, a, b, c, d, 12, 0x72BE5D74)
	ROUND(d, e, f, g, h, a, b, c, 13, 0x80DEB1FE)
	ROUND(c, d, e, f, g, h, a, b, 14, 0x9BDC06A7)
	ROUND(b, c, d, e, f, g, h, a, 15, 0xC19BF174)
	ROUND(a, b, c, d, e, f, g, h, 16, 0xE49B69C1)
	ROUND(h, a, b, c, d, e, f, g, 17, 0xEFBE4786)
	ROUND(g, h, a, b, c, d, e, f, 18, 0x0FC19DC6)
	ROUND(f, g, h, a, b, c, d, e, 19, 0x240CA1CC)
	ROUND(e, f, g, h, a, b, c, d, 20, 0x2DE92C6F)
	ROUND(d, e, f, g, h, a, b, c, 21, 0x4A7484AA)
	ROUND(c, d, e, f, g, h, a, b, 22, 0x5CB0A9DC)
	ROUND(b, c, d, e, f, g, h, a, 23, 0x76F988DA)
	ROUND(a, b, c, d, e, f, g, h, 24, 0x983E5152)
	ROUND(h, a, b, c, d, e, f, g, 25, 0xA831C66D)
	ROUND(g, h, a, b, c, d, e, f, 26, 0xB00327C8)
	ROUND(f, g, h, a, b, c, d, e, 27, 0xBF597FC7)
	ROUND(e, f, g, h, a, b, c, d, 28, 0xC6E00BF3)
	ROUND(d, e, f, g, h, a, b, c, 29, 0xD5A79147)
	ROUND(c, d, e, f, g, h, a, b, 30, 0x06CA6351)
	ROUND(b, c, d, e, f, g, h, a, 31, 0x14292967)
	ROUND(a, b, c, d, e, f, g, h, 32, 0x27B70A85)
	ROUND(h, a, b, c, d, e, f, g, 33, 0x2E1B2138)
	ROUND(g, h, a, b, c, d, e, f, 34, 0x4D2C6DFC)
	ROUND(f, g, h, a, b, c, d, e, 35, 0x53380D13)
	ROUND(e, f, g, h, a, b, c, d, 36, 0x650A7354)
	ROUND(d, e, f, g, h, a, b, c, 37, 0x766A0ABB)
	ROUND(c, d, e, f, g, h, a, b, 38, 0x81C2C92E)
	ROUND(b, c, d, e, f, g, h, a, 39, 0x92722C85)
	ROUND(a, b, c, d, e, f, g, h, 40, 0xA2BFE8A1)
	ROUND(h, a, b, c, d, e, f, g, 41, 0xA81A664B)
	ROUND(g, h, a, b, c, d, e, f, 42, 0xC24B8B70)
	ROUND(f, g, h, a, b, c, d, e, 43, 0xC76C51A3)
	ROUND(e, f, g, h, a, b, c, d, 44, 0xD192E819)
	ROUND(d, e, f, g, h, a, b, c, 45, 0xD6990624)
	ROUND(c, d, e, f, g, h, a, b, 46, 0xF40E3585)
	ROUND(b, c, d, e, f, g, h, a, 47, 0x106AA070)
	ROUND(a, b, c, d, e, f, g, h, 48, 0x19A4C116)
	ROUND(h, a, b, c, d, e, f, g, 49, 0x1E376C08)
	ROUND(g, h, a, b, c, d, e, f, 50, 0x2748774C)
	ROUND(f, g, h, a, b, c, d, e, 51, 0x34B0BCB5)
	ROUND(e, f, g, h, a, b, c, d, 52, 0x391C0CB3)
	ROUND(d, e, f, g, h, a, b, c, 53, 0x4ED8AA4A)
	ROUND(c, d, e, f, g, h, a, b, 54, 0x5B9CCA4F)
	ROUND(b, c, d, e, f, g, h, a, 55, 0x682E6FF3)
	ROUND(a, b, c, d, e, f, g, h, 56, 0x748F82EE)
	ROUND(h, a, b, c, d, e, f, g, 57, 0x78A5636F)
	ROUND(g, h, a, b, c, d, e, f, 58, 0x84C87814)
	ROUND(f, g, h, a, b, c, d, e, 59, 0x8CC70208)
	ROUND(e, f, g, h, a, b, c, d, 60, 0x90BEFFFA)
	ROUND(d, e, f, g, h, a, b, c, 61, 0xA4506CEB)
	ROUND(c, d, e, f, g, h, a, b, 62, 0xBEF9A3F7)
	ROUND(b, c, d, e, f, g, h, a, 63, 0xC67178F2)
	state.Hash[0] = 0U + state.Hash[0] + a;
	state.Hash[1] = 0U + state.Hash[1] + b;
	state.Hash[2] = 0U + state.Hash[2] + c;
	state.Hash[3] = 0U + state.Hash[3] + d;
	state.Hash[4] = 0U + state.Hash[4] + e;
	state.Hash[5] = 0U + state.Hash[5] + f;
	state.Hash[6] = 0U + state.Hash[6] + g;
	state.Hash[7] = 0U + state.Hash[7] + h;
}

void FSha256::Sha256(const uint8 *message, uint32 len, FSha256Output &out)
{
	out.Hash[0] = UINT32_C(0x6A09E667);
	out.Hash[1] = UINT32_C(0xBB67AE85);
	out.Hash[2] = UINT32_C(0x3C6EF372);
	out.Hash[3] = UINT32_C(0xA54FF53A);
	out.Hash[4] = UINT32_C(0x510E527F);
	out.Hash[5] = UINT32_C(0x9B05688C);
	out.Hash[6] = UINT32_C(0x1F83D9AB);
	out.Hash[7] = UINT32_C(0x5BE0CD19);

	#define LENGTH_SIZE 8  // In bytes

	size_t off;
	for (off = 0; len - off >= SHA256_BLOCK_LEN; off += SHA256_BLOCK_LEN)
		sha256_compress(out, &message[off]);

	uint8 block[SHA256_BLOCK_LEN] = {0};
	size_t rem = len - off;
	memcpy(block, &message[off], rem);

	block[rem] = 0x80;
	rem++;
	if (SHA256_BLOCK_LEN - rem < LENGTH_SIZE) {
		sha256_compress(out, block);
		memset(block, 0, sizeof(block));
	}

	block[SHA256_BLOCK_LEN - 1] = (uint8)((len & 0x1FU) << 3);
	len >>= 5;
	for (int i = 1; i < LENGTH_SIZE; i++, len >>= 8)
		block[SHA256_BLOCK_LEN - 1 - i] = (uint8)(len & 0xFFU);
	sha256_compress(out, block);
}


#undef LENGTH_SIZE