# Compiler
CC = gcc

# Targets
all: ecdh_assign_2 rsa_assign_2

# Build ecdh_assign_2
ecdh_assign_2: ecdh_assign_2.c
	$(CC) -o ecdh_assign_2 ecdh_assign_2.c -lsodium

# Build rsa_assign_2
rsa_assign_2: rsa_assign_2.c
	$(CC) rsa_assign_2.c -o rsa_assign_2 -lgmp -lcrypto

# Clean up build files
clean:
	rm -f ecdh_assign_2 rsa_assign_2

.PHONY: all clean
