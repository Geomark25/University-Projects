#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <openssl/ssl.h>
#include <openssl/err.h>

#define FAIL -1

int OpenConnection(const char *hostname, int port)
{
    int sd;
    struct hostent *host;
    struct sockaddr_in addr;

    if ((host = gethostbyname(hostname)) == NULL)
    {
        perror(hostname);
        abort();
    }

    sd = socket(PF_INET, SOCK_STREAM, 0);
    bzero(&addr, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_port = htons(port);
    addr.sin_addr.s_addr = *(long*)(host->h_addr);

    if (connect(sd, (struct sockaddr*)&addr, sizeof(addr)) != 0)
    {
        close(sd);
        perror("Connection failed");
        abort();
    }

    return sd;
}

SSL_CTX* InitCTX(void)
{
    /* TODO:
     * 1. Initialize SSL library (SSL_library_init, OpenSSL_add_all_algorithms, SSL_load_error_strings)
     * 2. Create a new TLS client context (TLS_client_method)
     * 3. Load CA certificate to verify server
     * 4. Configure SSL_CTX to verify server certificate
     */
    SSL_CTX *ctx = NULL;


    /* 1.Initialize SSL library */
    SSL_library_init();
    OpenSSL_add_all_algorithms();
    SSL_load_error_strings();

    const SSL_METHOD *method = TLS_client_method();
    ctx = SSL_CTX_new(method);

    if (ctx == NULL)
    {
        ERR_print_errors_fp(stderr);
        abort();
    }

    /*Enforce TLS 1.2 only (assigment requirement).*/
    #if OPENSSL_VERSION_NUMBER >= 0x10100000L
        SSL_CTX_set_min_proto_version(ctx,TLS1_2_VERSION);
        SSL_CTX_set_max_proto_version(ctx,TLS1_2_VERSION);
    #endif

/* 3. Load CA certificate to verify server*/

    if(SSL_CTX_load_verify_locations(ctx,"rca.crt",NULL)!=1)
    {
        fprintf(stderr,"Error loading CA certificate(ca.crt).Make sure ca.crt is present\n");
        ERR_print_errors_fp(stderr);
        SSL_CTX_free(ctx);
        abort();
    }


    /* 4.Configure SSL_CTX to verify server certificate*/
    SSL_CTX_set_verify(ctx,SSL_VERIFY_PEER,NULL);
    SSL_CTX_set_verify_depth(ctx,4);


    return ctx;
}

void LoadCertificates(SSL_CTX* ctx, char* CertFile, char* KeyFile)
{
    
     /* 1. Load client certificate using SSL_CTX_use_certificate_file*/
     if(SSL_CTX_use_certificate_file(ctx,CertFile,SSL_FILETYPE_PEM)<=0)
     {
        fprintf(stderr,"Error loading client certificate from %s\n",CertFile);
        ERR_print_errors_fp(stderr);
        abort();
     }

     /* 2. Load client private key using SSL_CTX_use_PrivateKey_file*/
     if(SSL_CTX_use_PrivateKey_file(ctx,KeyFile,SSL_FILETYPE_PEM) <=0)
     {
        fprintf(stderr,"Error loading client private key from %s\n",KeyFile);
        ERR_print_errors_fp(stderr);
        abort();
     }
     /* 3. Verify that private key matches certificate using SSL_CTX_check_private_key*/
     if(!SSL_CTX_check_private_key(ctx))
     {
        fprintf(stderr,"Private key does not match the certificate public key\n");
        ERR_print_errors_fp(stderr);
        abort();
     }
}

int main(int argc, char *argv[])
{
    if (argc != 3)
    {
        printf("Usage: %s <hostname> <port>\n", argv[0]);
        exit(0);
    }

    char *hostname = argv[1];
    int port = atoi(argv[2]);
    SSL_CTX *ctx;
    SSL *ssl;
    int server;

    
     /* 1. Initialize SSL context using InitCTX*/
    ctx = InitCTX();
    
     /* 2. Load client certificate and key using LoadCertificates*/
    LoadCertificates(ctx,"rclient.crt","rclient.key");
    
    server = OpenConnection(hostname, port);
    ssl = SSL_new(ctx);
    if(!ssl)
    {
        fprintf(stderr,"Unable to create SSL structure\n");
        close(server);
        SSL_CTX_free(ctx);
        return 1;
    } 

    SSL_set_fd(ssl, server);

    
     /* 1. Establish SSL connection using SSL_connect*/
    if(SSL_connect(ssl)<=0)
    {
        fprintf(stderr,"SSL connect error\n");
        ERR_print_errors_fp(stderr);
        SSL_free(ssl);
        close(server);
        SSL_CTX_free(ctx);
        return 1;

    }

    printf("Connected with %s encryption\n",SSL_get_cipher(ssl));


     /* 2. Ask user to enter username and password*/
    char username[64],password[64];
    printf("Enter username: ");
    if(scanf("%63s" , username) !=1) username[0] = '\0';
    printf("Enter password: ");
    if(scanf("%63s" , password) !=1) password[0] = '\0';

     /* 3. Build XML message dynamically*/
    char msg[256];
    snprintf(msg,sizeof(msg), "<Body><UserName>%s</UserName><Password>%s</Password></Body>", username,password);
    
    
    /* 4. Send XML message over SSL*/
    int written = SSL_write(ssl,msg,strlen(msg));
    if(written <=0)
    {
        fprintf(stderr,"SSL_write failed\n");
        ERR_print_errors_fp(stderr);
    }
       
    /* 5. Read server response and print it*/
    char buf[2048];
    int bytes = SSL_read(ssl,buf,sizeof(buf)-1);
    if(bytes>0)
    {
        buf[bytes]= '\0';
        printf("Server response: \n%s\n" ,buf);

    }
    else
    {
        fprintf(stderr,"No response or SSL_read error\n");
        ERR_print_errors_fp(stderr);
    }


    /*Clean up */ 
    SSL_shutdown(ssl);
    SSL_free(ssl);
    close(server);
    SSL_CTX_free(ctx);
    return 0;
}