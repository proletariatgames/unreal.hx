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
#pragma once

#include "CoreMinimal.h"
#define SHA256_BLOCK_LEN 64  // In bytes
#define SHA256_STATE_LEN 8  // In words

struct FSha256Output
{
	uint32 Hash[SHA256_STATE_LEN];

	FString ToString() const
	{
		FString RetStr;
		for (int Idx = 0; Idx < 32; Idx++)
		{
			RetStr += FString::Printf(TEXT("%02x"), this->Hash[Idx]);
		}
		return RetStr;
	}
};

struct FSha256
{
	static void Sha256(const uint8 *Message, uint32 Len, FSha256Output &Out);

	static FString Sha256(const uint8 *Message, uint32 Len)
	{
		FSha256Output Out;
		Sha256(Message, Len, Out);
		return Out.ToString();
	}
};