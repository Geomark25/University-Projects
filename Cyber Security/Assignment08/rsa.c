#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <time.h>
#include <gmp.h>
#include <openssl/sha.h>
#include <sys/resource.h>
#include <linux/time.h>
#include <bits/getopt_core.h>



//For time measurments
double diff_in_seconds(struct timespec start, struct timespec end) {
    return (end.tv_sec - start.tv_sec) + (end.tv_nsec - start.tv_nsec) / 1e9;
}

//For storage measurments
double get_peak_memory_kb() {
    struct rusage usage;
    getrusage(RUSAGE_SELF, &usage);
    return (double)usage.ru_maxrss;
}

//------------------- Key Generation -------------------//
void key_generation(int key_length) {
    mpz_t p,q,n,d,e,lambda;
    mpz_inits(p,q,n,d,e,lambda,NULL);
    mpz_set_ui(e, 65537);

    //Generation of a random number
    gmp_randstate_t state;
    gmp_randinit_default(state);
    gmp_randseed_ui(state, time(NULL));

    // Generate two random primes
    mpz_urandomb(p,state,key_length/2);
    mpz_nextprime(p,p);
    mpz_urandomb(q,state,key_length/2);
    mpz_nextprime(q,q);

    // n = p*q
    mpz_mul(n,p,q);

    // lambda = (p-1)*(q-1)
    mpz_sub_ui(p,p,1);
    mpz_sub_ui(q,q,1);
    mpz_mul(lambda,p,q);

    // d = e^-1 mod lambda
    if(mpz_invert(d,e,lambda) == 0){
        fprintf(stdout, "Error: e and lambda not coprime!\n");
        mpz_clears(p,q,n,d,e,lambda,NULL);
        gmp_randclear(state);
        return;
    }

    // Save public key
    FILE *pub = fopen("pub.key","w");
    gmp_fprintf(pub,"%Zx\n%Zx\n",n,e);
    fclose(pub);

    // Save private key
    FILE *priv = fopen("priv.key","w");
    gmp_fprintf(priv,"%Zx\n%Zx\n",n,d);
    fclose(priv);

    //It clears all the values and states after it finishes
    mpz_clears(p,q,n,d,e,lambda,NULL);
    gmp_randclear(state);
    fprintf(stdout, "Keys saved to pub.key and priv.key\n");
}


//------------------- Encryption -------------------//
void encryption(const char *input_file, const char *output_file, const char *key_file){
    mpz_t n, e, m, c;
    mpz_inits(n, e, m, c, NULL);

    /* Read public key */
    FILE *fk = fopen(key_file, "r");
    if(!fk){ perror("key file"); exit(-1); }
    gmp_fscanf(fk, "%Zx\n%Zx\n", n, e);
    fclose(fk);

    /* Read input file */
    FILE *fin = fopen(input_file, "rb");
    if(!fin){ perror("input file"); exit(-1); }
    fseek(fin, 0, SEEK_END);
    long size = ftell(fin);
    rewind(fin);
    if(size <= 0){
        fprintf(stdout, "Input file empty!\n");
        exit(-1);
    }

    unsigned char *buf = malloc(size);
    fread(buf, 1, size, fin);
    fclose(fin);

    /* Import plaintext into mpz */
    mpz_import(m, size, 1, 1, 0, 0, buf);
    free(buf);

    /* RSA encryption */
    mpz_powm(c, m, e, n);

    /* Export ciphertext to raw bytes */
    size_t cipher_len;
    unsigned char *cipher_buf =
        (unsigned char *)mpz_export(NULL, &cipher_len, 1, 1, 0, 0, c);

    /* Write ciphertext using fwrite */
    FILE *fout = fopen(output_file, "wb");
    if(!fout){ perror("output file"); exit(-1); }

    /* Write length first (needed for decryption) */
    fwrite(&cipher_len, sizeof(cipher_len), 1, fout);

    /* Write ciphertext bytes */
    fwrite(cipher_buf, 1, cipher_len, fout);

    fclose(fout);

    free(cipher_buf);
    mpz_clears(n, e, m, c, NULL);

    fprintf(stdout, "File encrypted -> %s\n", output_file);
}

//------------------- Decryption -------------------//
void decryption(const char *input_file, const char *output_file, const char *key_file){
    mpz_t n, d, c, m;
    mpz_inits(n, d, c, m, NULL);

    /* Read private key */
    FILE *fk = fopen(key_file, "r");
    if(!fk){ perror("key file"); exit(-1); }
    gmp_fscanf(fk, "%Zx\n%Zx\n", n, d);
    fclose(fk);

    /* Open encrypted file (binary) */
    FILE *fin = fopen(input_file, "rb");
    if(!fin){ perror("input file"); exit(-1); }

    /* Read ciphertext length */
    size_t cipher_len;
    if(fread(&cipher_len, sizeof(cipher_len), 1, fin) != 1){
        perror("fread length");
        exit(-1);
    }

    /* Read ciphertext bytes */
    unsigned char *cipher_buf = malloc(cipher_len);
    if(!cipher_buf){
        perror("malloc");
        exit(-1);
    }

    if(fread(cipher_buf, 1, cipher_len, fin) != cipher_len){
        perror("fread ciphertext");
        exit(-1);
    }
    fclose(fin);

    /* Import ciphertext into mpz */
    mpz_import(c, cipher_len, 1, 1, 0, 0, cipher_buf);
    free(cipher_buf);

    /* RSA decryption */
    mpz_powm(m, c, d, n);

    /* Export plaintext */
    size_t plain_len;
    unsigned char *plain_buf =
        (unsigned char *)mpz_export(NULL, &plain_len, 1, 1, 0, 0, m);

    /* Write decrypted file */
    FILE *fout = fopen(output_file, "wb");
    if(!fout){ perror("output file"); exit(-1); }

    fwrite(plain_buf, 1, plain_len, fout);
    fclose(fout);

    free(plain_buf);
    mpz_clears(n, d, c, m, NULL);

    fprintf(stdout, "File decrypted -> %s\n", output_file);
}


//------------------- Signing -------------------//
void sign_file(const char *input_file, const char *signature_file, const char *private_key_file){
    mpz_t n,d,hash_int,signature;
    mpz_inits(n,d,hash_int,signature,NULL);

    FILE *fk = fopen(private_key_file,"r");
    gmp_fscanf(fk,"%Zx\n%Zx\n",n,d);
    fclose(fk);

    FILE *fin = fopen(input_file,"rb");
    fseek(fin,0,SEEK_END);
    long size = ftell(fin);
    rewind(fin);
    unsigned char *buf = malloc(size);
    fread(buf,1,size,fin);
    fclose(fin);

    unsigned char hash[SHA256_DIGEST_LENGTH];
    SHA256(buf,size,hash);
    free(buf);

    mpz_import(hash_int,SHA256_DIGEST_LENGTH,1,1,0,0,hash);
    mpz_powm(signature,hash_int,d,n);

    FILE *fsig = fopen(signature_file,"w");
    gmp_fprintf(fsig,"%Zx\n",signature);
    fclose(fsig);

    mpz_clears(n,d,hash_int,signature,NULL);
    fprintf(stdout, "Signature saved to %s\n",signature_file);
}

//------------------- Verification -------------------//
void verify_file(const char *input_file, const char *signature_file, const char *public_key_file){
    mpz_t n,e,hash_int,sig_int,verify;
    mpz_inits(n,e,hash_int,sig_int,verify,NULL);

    FILE *fk = fopen(public_key_file,"r");
    gmp_fscanf(fk,"%Zx\n%Zx\n",n,e);
    fclose(fk);

    FILE *fin = fopen(input_file,"rb");
    fseek(fin,0,SEEK_END);
    long size = ftell(fin);
    rewind(fin);
    unsigned char *buf = malloc(size);
    fread(buf,1,size,fin);
    fclose(fin);

    unsigned char hash[SHA256_DIGEST_LENGTH];
    SHA256(buf,size,hash);
    free(buf);

    mpz_import(hash_int,SHA256_DIGEST_LENGTH,1,1,0,0,hash);

    FILE *fsig = fopen(signature_file,"r");
    gmp_fscanf(fsig,"%Zx\n",sig_int);
    fclose(fsig);

    mpz_powm(verify,sig_int,e,n);

    if(mpz_cmp(verify,hash_int)==0)
        fprintf(stdout, "Signature is VALID\n");
    else
        fprintf(stdout, "Signature is INVALID\n");

    mpz_clears(n,e,hash_int,sig_int,verify,NULL);
}

//--------------------------------PERFORMANCE---------------------------------//


void comparison(const char* performance_file) {
    FILE *f = fopen(performance_file,"w");
    if(!f){
        perror("perf file");
        exit(-1);
    }

    int sizes[] = {1024, 2048, 4096};
    struct timespec start,end;

    const char *input_filename = "plaintext.txt";

    for(int i=0;i<3;i++){
        int key_size = sizes[i];

        char pub_key[64], priv_key[64], enc_file[64], dec_file[64], sig_file[64];
        sprintf(pub_key, "public_key_%d", key_size);
        sprintf(priv_key, "private_key_%d", key_size);
        sprintf(enc_file, "enc_%d.txt", key_size);
        sprintf(dec_file, "dec_%d.txt", key_size);
        sprintf(sig_file, "signature_%d.txt", key_size);

        fprintf(f,"=== Key Length %d ===\n", key_size);
        

        // Encryption
        clock_gettime(CLOCK_MONOTONIC,&start);
        encryption(input_filename, enc_file, pub_key);
        clock_gettime(CLOCK_MONOTONIC,&end);
        double time_enc = diff_in_seconds(start,end);
        double mem_enc = get_peak_memory_kb();
        fprintf(f,"Encryption: %.3f s, Peak Memory: %.3f KB\n", time_enc, mem_enc);

        // Decryption
        clock_gettime(CLOCK_MONOTONIC,&start);
        decryption(enc_file, dec_file, priv_key);
        clock_gettime(CLOCK_MONOTONIC,&end);
        double time_dec = diff_in_seconds(start,end);
        double mem_dec = get_peak_memory_kb();
        fprintf(f,"Decryption: %.3f s, Peak Memory: %.3f KB\n", time_dec, mem_dec);

        // Signing
        clock_gettime(CLOCK_MONOTONIC,&start);
        sign_file(input_filename, sig_file, priv_key);
        clock_gettime(CLOCK_MONOTONIC,&end);
        double time_sign = diff_in_seconds(start,end);
        double mem_sign = get_peak_memory_kb();
        fprintf(f,"Signing: %.3f s, Peak Memory: %.3f KB\n", time_sign, mem_sign);

        // Verification
        clock_gettime(CLOCK_MONOTONIC,&start);
        verify_file(input_filename, sig_file, pub_key);
        clock_gettime(CLOCK_MONOTONIC,&end);
        double time_verify = diff_in_seconds(start,end);
        double mem_verify = get_peak_memory_kb();
        fprintf(f,"Verification: %.3f s, Peak Memory: %.3f KB\n\n", time_verify, mem_verify);

        // Cleanup generated files for this iteration
        remove(pub_key);
        remove(priv_key);
        remove(enc_file);
        remove(dec_file);
        remove(sig_file);
    }

    fclose(f);
    fprintf(stdout, "Performance results saved to %s\n", performance_file);
}

//--------------------------------MAIN-------------------
int main(int argc, char *argv[]){
    int opt;
    char *input_file = NULL;
    char *output_file = NULL;
    char *key_file = NULL;
    char *perf_file = NULL;

    if(argc < 2){
        fprintf(stdout, "No arguments provided. Use -h for help.\n");
        return 0;
    }

    while((opt = getopt(argc, argv, "i:o:k:g:desva:h")) != -1){
        switch(opt){
            case 'i':
                if(!optarg){ 
                    fprintf(stdout, "Error: -i requires an input file\n");
                    return -1; 
                }
                input_file = optarg;
                break;
            case 'o':
                if(!optarg){
                    fprintf(stdout, "Error: -o requires an output file\n"); 
                    return -1;
                 }
                output_file = optarg;
                break;
            case 'k':
                if(!optarg){ 
                    fprintf(stdout, "Error: -k requires a key file\n"); 
                    return -1;
                 }
                key_file = optarg;
                break;
            case 'g':
                if(!optarg){ 
                    fprintf(stdout, "Error: -g requires key length\n"); 
                    return -1; 
                }
                    key_generation(atoi(optarg));
                break;
            case 'd':
                if(!input_file){
                     fprintf(stdout, "Error: Decryption requires -i <input file>\n"); 
                     return -1;
                     }
                if(!output_file){
                     fprintf(stdout, "Error: Decryption requires -o <output file>\n"); 
                     return -1;
                     }
                if(!key_file){ 
                    fprintf(stdout, "Error: Decryption requires -k <private key>\n");
                     return -1;
                }
                decryption(input_file, output_file, key_file);
                break;
            case 'e':
                if(!input_file){ 
                    fprintf(stdout, "Error: Encryption requires -i <input file>\n"); 
                    return -1;
                 }
                if(!output_file){
                     fprintf(stdout, "Error: Encryption requires -o <output file>\n"); 
                     return -1;
                     }
                if(!key_file){ 
                    fprintf(stdout, "Error: Encryption requires -k <public key>\n"); 
                    return -1;
                 }
                encryption(input_file, output_file, key_file);
                break;
            case 's':
                if(!input_file){
                     fprintf(stdout, "Error: Signing requires -i <input file>\n"); 
                    return -1; 
                }
                if(!output_file){ 
                    fprintf(stdout, "Error: Signing requires -o <signature file>\n");
                     return -1; 
                }
                if(!key_file){ 
                    fprintf(stdout, "Error: Signing requires -k <private key>\n"); 
                return -1;
                 }
                sign_file(input_file, output_file, key_file);
                break;
            case 'v':
                if(!input_file){ 
                    fprintf(stdout, "Error: Verification requires -i <input file>\n");
                     return -1;
                 }
                if(!output_file){ 
                    fprintf(stdout, "Error: Verification requires -o <signature file>\n"); 
                    return -1; 
                }
                if(!key_file){ 
                    fprintf(stdout, "Error: Verification requires -k <public key>\n");
                     return -1; 
                }
                verify_file(input_file, output_file, key_file);
                break;
            case 'a':
                if(!optarg){ 
                    fprintf(stdout, "Error: -a requires a performance output file\n"); 
                    return -1;
                 }
                comparison(optarg);
                break;
            case 'h':
                fprintf(stdout, "Usage:\n"
                       "  -g <bits>        Generate RSA keys\n"
                       "  -e -i in -o out -k pub.key   Encrypt file\n"
                       "  -d -i in -o out -k priv.key  Decrypt file\n"
                       "  -s -i in -o sig -k priv.key  Sign file\n"
                       "  -v -i in -o sig -k pub.key   Verify signature\n"
                       "  -a <file>        Run performance test\n");
                return 0;
            default:
                fprintf(stdout, "Invalid option. Use -h for help.\n");
                return -1;
        }
    }

    return 0;
}
