#include <stdio.h>
#include <string.h>
#include <gmp.h>
#include <sodium.h>
#include <ctype.h>

#define DEFAULT_CONTEXT     "ECDH_KDF"
#define ENCRYPTION_KEY_ID   1
#define MAC_KEY_ID          2

/*  Private and public keys                 */
uint8_t alice_pk[crypto_kx_PUBLICKEYBYTES];
uint8_t alice_sk[crypto_box_SECRETKEYBYTES];
uint8_t bob_pk[crypto_kx_PUBLICKEYBYTES];
uint8_t bob_sk[crypto_box_SECRETKEYBYTES];

uint8_t alice_shared_secret[crypto_kx_SECRETKEYBYTES];
uint8_t bob_shared_secret[crypto_kx_SECRETKEYBYTES];

uint8_t alice_encryption_key[crypto_kdf_KEYBYTES];
uint8_t bob_encryption_key[crypto_kdf_KEYBYTES];
uint8_t alice_mac_key[crypto_kdf_KEYBYTES];
uint8_t bob_mac_key[crypto_kdf_KEYBYTES];



/*  Definetly not a help message screen     */
void printHelpMessage(){
    printf("Command Line Options for ECDH Tool:\n");
    printf("-o <path>       Path to output file\n");
    printf("-a <number>     Alice's private key (optional, hexadecimal format)\n");
    printf("-b <number>     Bob's private key (optional, hexadecimal format)\n");
    printf("-c <context>    Context string for key derivation (default: \"ECDH_KDF\")\n");
    printf("-h              This help message\n");
}

/*  Convert inputed hex to uint8_t          */
void fprintf_hex(FILE* file, const uint8_t data[], size_t len){
    for(size_t i = 0; i < len; i++){
        fprintf(file, "%02x", data[i]);
    }
    fprintf(file, "\n\n");
}

void outputIntoFile(FILE* outputfile){
    fprintf(outputfile, "Alice's Public Key:\n");
    fprintf_hex(outputfile, alice_pk, sizeof alice_pk);
    fprintf(outputfile, "Bob's Public Key:\n");
    fprintf_hex(outputfile, bob_pk, sizeof bob_pk);
    fprintf(outputfile, "Shared Secret (Alice):\n");
    fprintf_hex(outputfile, alice_shared_secret, sizeof alice_shared_secret);
    fprintf(outputfile, "Shared Secret (Bob):\n");
    fprintf_hex(outputfile, bob_shared_secret, sizeof bob_shared_secret);
    fprintf(outputfile, "%s\n\n", memcmp(alice_shared_secret, bob_shared_secret, crypto_kx_SECRETKEYBYTES) == 0 ? "Shared secrets match!" : "Shared secrets do not match!");
    fprintf(outputfile, "Derived Encryption Key (Alice):\n");
    fprintf_hex(outputfile, alice_encryption_key, sizeof alice_encryption_key);
    fprintf(outputfile, "Derived Encryption Key (Bob):\n");
    fprintf_hex(outputfile, bob_encryption_key, sizeof bob_encryption_key);
    fprintf(outputfile, "%s\n\n", memcmp(alice_encryption_key, bob_encryption_key, crypto_kx_SECRETKEYBYTES) == 0 ? "Encryption keys match!" : "Encryption keys do not match!");
    fprintf(outputfile, "Derived MAC Key (Alice):\n");
    fprintf_hex(outputfile, alice_mac_key, sizeof alice_mac_key);
    fprintf(outputfile, "Derived MAC Key (Bob):\n");
    fprintf_hex(outputfile, bob_mac_key, sizeof bob_mac_key);
    fprintf(outputfile, "%s", memcmp(alice_mac_key, bob_mac_key, crypto_kx_SECRETKEYBYTES) == 0 ? "MAC keys match!" : "MAC keys do not match!");
}

int hex_to_bytes(const char *hexstr, uint8_t *out) {
    if (hexstr[0] == '0' && (hexstr[1] == 'x' || hexstr[1] == 'X'))
        hexstr += 2;

    size_t len = strlen(hexstr);
    if (len % 2 != 0) {
        fprintf(stderr, "Error: Odd number of hex digits\n");
        return 0;
    }

    size_t num_bytes = len / 2;
    if (num_bytes > crypto_box_SECRETKEYBYTES) {
        fprintf(stderr, "Error: Input too long (max %d bytes)\n", crypto_box_SECRETKEYBYTES);
        return 0;
    }

    for (size_t i = 0; i < num_bytes; i++) {
        char byte_str[3] = { hexstr[2*i], hexstr[2*i + 1], '\0' };
        if (!isxdigit(byte_str[0]) || !isxdigit(byte_str[1])) {
            fprintf(stderr, "Error: Invalid hex digit\n");
            return 0;
        }

        out[i] = (uint8_t) strtoul(byte_str, NULL, 16);
    }

    return 1;
}

/*  Derive Public key from private key (if not initialized, make random key)    */
void deriveKeypair(uint8_t pk[], uint8_t sk[], int arg){
    if(!arg){
        randombytes_buf(sk, sizeof(uint8_t) * crypto_box_SECRETKEYBYTES);
    }
    crypto_scalarmult_base(pk, sk);
}

int main(int argc, char* argv[]){

    if(sodium_init() < 0){
        fprintf(stderr, "Libsodium could not initialize. Terminating...\n");
        return -1;
    }
    
    char* temp = NULL;
    char* context = NULL;
    FILE* outputfile = NULL;
    char* filename = NULL;

    int argA = 0, argB = 0;
    
    /*  Analyse inputed arguments   */
    if(argc > 1){
        for(int i = 1; i < argc; i++){
            if(strcmp(argv[i], "-h") == 0){
                printHelpMessage();
                return 0;
            }
        }
        for(int i = 1; i < argc; i++){
            if(strcmp(argv[i], "-o") == 0){
                if(i++ == argc){
                    printf("Too few Arguments!\n");
                    return -1;
                }
                temp = argv[i];
                if(temp[0] == '-'){
                    printf("Output file declaration is mandatory. Restart process and add output file!\n");
                    return -1;
                }
                else{
                    filename = (char *)malloc(sizeof(char) * strlen(temp));
                    outputfile = fopen(temp, "w");
                    strcpy(filename, temp);
                }
            }
            else if(strcmp(argv[i], "-a") == 0){
                if(i++ == argc){
                    printf("Too few Arguments!\n");
                    return -1;
                }
                temp = argv[i];
                if(strlen(temp) <= 66){
                    argA = hex_to_bytes(temp, alice_sk);
                }
                else{
                    printf("Invalid Alice's private key. Make sure it is no more than 64 alphanumeric characters! Resolving to random key generation...\n");
                }
            }
            else if(strcmp(argv[i], "-b") == 0){
                if(i++ == argc){
                    printf("Too few Arguments!\n");
                    return -1;
                }
                temp = argv[i];
                if(strlen(temp) <= 66){
                    argB = hex_to_bytes(temp, bob_sk);
                }
                else{
                    printf("Invalid Bob's private key. Make sure it is no more than 64 alphanumeric characters! Resolving to random key generation...\n");
                }
            }
            else if(strcmp(argv[i], "-c") == 0){
                if(i++ == argc){
                    printf("Too few Arguments!\n");
                    return -1;
                }
                temp = argv[i];
                if(temp[0] == '-'){
                    printf("Do not use \'-\' for context string! Resolving to default...\n");
                }
                else if(strlen(temp) > crypto_kdf_CONTEXTBYTES){
                    printf("Context must not be more than 8 characters. Resolving to default...\n");
                }
                else{
                    context = (char*)malloc(sizeof(char) * strlen(temp));
                    strcpy(context, temp);
                }
            }
        }
    }
    else{
        printf("Program must have arguments, use \"./ecdh_assign_2 -h\" for help.\n");
        return -1;
    }

    if(outputfile == NULL){
        printf("Output file declaration is mandatory. Restart process and add output file!\n");
        return -1;
    }

    /*  Got all arguments, start key generation */
    deriveKeypair(alice_pk, alice_sk, argA);
    deriveKeypair(bob_pk, bob_sk, argB);

    /*  Calculate shared secret for each one    */
    if(crypto_scalarmult(alice_shared_secret, alice_sk, bob_pk) != 0){
        return -1;
    }
    if(crypto_scalarmult(bob_shared_secret, bob_sk, alice_pk) != 0){
        return -1;
    }

    /*  Derive Encryption and MAC Keys          */
    crypto_kdf_derive_from_key(alice_encryption_key, sizeof alice_encryption_key, ENCRYPTION_KEY_ID, context == NULL ? DEFAULT_CONTEXT : context, alice_shared_secret);
    crypto_kdf_derive_from_key(bob_encryption_key, sizeof bob_encryption_key, ENCRYPTION_KEY_ID, context == NULL ? DEFAULT_CONTEXT : context, bob_shared_secret);
    crypto_kdf_derive_from_key(alice_mac_key, sizeof alice_mac_key, MAC_KEY_ID, context == NULL ? DEFAULT_CONTEXT : context, alice_shared_secret);
    crypto_kdf_derive_from_key(bob_mac_key, sizeof bob_mac_key, MAC_KEY_ID, context == NULL ? DEFAULT_CONTEXT : context, bob_shared_secret);

    /*  Output everything into output file      */
    outputIntoFile(outputfile);

    printf("Finished and output has been written in %s\n\n", filename);

    free(filename);
    free(context);
    fclose(outputfile);
    return 0;
}