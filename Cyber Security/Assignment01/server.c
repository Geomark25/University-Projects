#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <openssl/ssl.h>
#include <openssl/err.h>

#define FAIL -1

int OpenListener(int port) {
    int sd;
    struct sockaddr_in addr;

    sd = socket(PF_INET, SOCK_STREAM, 0);
    bzero(&addr, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_port = htons(port);
    addr.sin_addr.s_addr = INADDR_ANY;

    if (bind(sd, (struct sockaddr*)&addr, sizeof(addr)) != 0) {
        perror("Can't bind port");
        abort();
    }

    if (listen(sd, 10) != 0) {
        perror("Can't configure listening port");
        abort();
    }

    return sd;
}

SSL_CTX* InitServerCTX(void) {

    SSL_CTX *ctx = NULL;

    SSL_library_init();
    OpenSSL_add_all_algorithms();
    SSL_load_error_strings();

    ctx = SSL_CTX_new(TLS_server_method());

    if (ctx == NULL) {
        ERR_print_errors_fp(stderr);
        abort();
    }

    #if OPENSSL_VERSION_NUMBER >= 0x10100000L
        SSL_CTX_set_min_proto_version(ctx,TLS1_2_VERSION);
        SSL_CTX_set_max_proto_version(ctx,TLS1_2_VERSION);
    #endif

    if(SSL_CTX_load_verify_locations(ctx, "ca.crt", NULL) != 1){
        ERR_print_errors_fp(stderr);
        abort();    
    }

    SSL_CTX_set_verify(ctx, SSL_VERIFY_PEER | SSL_VERIFY_FAIL_IF_NO_PEER_CERT, NULL);

    return ctx;
}

void LoadCertificates(SSL_CTX* ctx, char* CertFile, char* KeyFile) {

    if(!SSL_CTX_use_certificate_file(ctx, CertFile, SSL_FILETYPE_PEM)){
        ERR_print_errors_fp(stderr);
        abort();
    }

    if(!SSL_CTX_use_PrivateKey_file(ctx, KeyFile, SSL_FILETYPE_PEM )){
        ERR_print_errors_fp(stderr);
        abort();
    }

    if(!SSL_CTX_check_private_key(ctx)){
        ERR_print_errors_fp(stderr);
        abort();
    }

}

void ShowCerts(SSL* ssl) {

    X509* cert = SSL_get_peer_certificate(ssl);

    if(cert == NULL){
        printf("No client certificate found\n");
        return;
    }

    char* subject_name = X509_NAME_oneline(X509_get_subject_name(cert),0,0);
    char* issuer_name = X509_NAME_oneline(X509_get_issuer_name(cert),0,0);

    if(subject_name){
        printf("Subject: %s\n", subject_name);
        OPENSSL_free(subject_name);
    }
    if(issuer_name){
        printf("Issuer: %s\n", issuer_name);
        OPENSSL_free(issuer_name);
    }

    X509_free(cert);
}

void getXMLCredentials(char* username, char* password, const char* buf) {
    const char* u_open = "<UserName>";
    const char* u_close = "</UserName>";
    const char* p_open = "<Password>";
    const char* p_close = "</Password>";

    char* u_start = strstr(buf, u_open);
    char* u_end   = strstr(buf, u_close);
    char* p_start = strstr(buf, p_open);
    char* p_end   = strstr(buf, p_close);

    if (u_start && u_end && (u_end > u_start)) {
        size_t len = u_end - (u_start + strlen(u_open));
        strncpy(username, u_start + strlen(u_open), len);
        username[len] = '\0';
        printf("Username received: %s\n", username);
    } else {
        printf("Username not found in XML.\n");
    }

    if (p_start && p_end && (p_end > p_start)) {
        size_t len = p_end - (p_start + strlen(p_open));
        strncpy(password, p_start + strlen(p_open), len);
        password[len] = '\0';
        printf("Password received: %s\n", password);
    } else {
        printf("Password not found in XML.\n");
    }
}

void sendResponse(int valid, SSL* ssl){
    char msg[256];
    if(valid){
        snprintf(msg, sizeof(msg), "<Body><Name>Megas</Name></Body>");
    }
    else{
        snprintf(msg, sizeof(msg), "Invalid message");
    }
    SSL_write(ssl, msg, strlen(msg));
}

void Servlet(SSL* ssl) {
    char buf[1024] = {0};
    char* pred_username = "Pelorios";
    char* pred_password = "Antonis";
    char username[1024] = {0};
    char password[1024] = {0};
    int valid = 0;

    if (SSL_accept(ssl) == FAIL) {
        if(SSL_get_error(ssl, FAIL) == SSL_ERROR_SSL){
            fprintf(stderr, "Client tried to connect with Invalid/No certificate");
        }
        else{
            ERR_print_errors_fp(stderr);
        }
        return;
    }

    ShowCerts(ssl);

    int bytes = SSL_read(ssl, buf, sizeof(buf));
    if (bytes <= 0) {
        SSL_free(ssl);
        return;
    }
    buf[bytes] = '\0';
    printf("Client message: %s\n", buf);

    /* TODO:
     * 1. Parse XML from client message to extract username and password
     * 2. Compare credentials to predefined values (e.g., "sousi"/"123")
     * 3. Send appropriate XML response back to client
     */

    getXMLCredentials(username, password, buf);
    if(strcmp(username, pred_username) == 0 && strcmp(password, pred_password) == 0){
        valid = 1;
    }
    sendResponse(valid, ssl);
    
    int sd = SSL_get_fd(ssl);
    SSL_free(ssl);
    close(sd);
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("Usage: %s <port>\n", argv[0]);
        exit(0);
    }

    int port = atoi(argv[1]);
    SSL_CTX *ctx;

    /* TODO:
     * 1. Initialize SSL context using InitServerCTX
     * 2. Load server certificate and key using LoadCertificates
     */

    ctx = InitServerCTX();

    LoadCertificates(ctx, "server.crt", "server.key");

    int server = OpenListener(port);

    while (1) {
        struct sockaddr_in addr;
        socklen_t len = sizeof(addr);
        SSL *ssl;

        int client = accept(server, (struct sockaddr*)&addr, &len);
        printf("\n\nConnection from %s:%d\n", inet_ntoa(addr.sin_addr), ntohs(addr.sin_port));

        /* TODO:
         * 1. Create new SSL object from ctx
         * 2. Set file descriptor for SSL using SSL_set_fd
         * 3. Call Servlet to handle the client
         */

        ssl = SSL_new(ctx);

        if(!ssl){
            fprintf(stderr, "Unable to create SSL structure\n");
            close(server);
            SSL_CTX_free(ctx);
            return -1;
        }

        SSL_set_fd(ssl, client);

        Servlet(ssl);
    }

    close(server);
    SSL_CTX_free(ctx);
}