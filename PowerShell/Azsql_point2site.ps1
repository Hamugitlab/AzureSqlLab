#Configure a point-to-site connection to Azure SQL Managed Instance from on-premises
# We call this the root certificate and by importing it to Azure we trust certificates signed by it.
# Generate CARoot private key 
openssl genrsa -aes256 -out MyAzureVPN.key 2048
# Generate a CARoot certificate valid for 10 years
openssl req -x509 -sha256 -new -key MyAzureVPN.key -out MyAzureVPN.cer -days 3650 -subj /CN=”MyAzureVPN”

#  In Azure portal navigate to “Virtual Networks/Manage Certificates/Upload” and import MyAzureVPN.cer. 

# Next we create client certificates by issuing the bellow
# Generate a certificate request
openssl genrsa -out client1Cert.key 2048
openssl req -new -out client1Cert.req -key client1Cert.key -subj /CN="MyAzureVPN"
# Generate a certificate from the certificate request and sign it as the CA that you are.
openssl x509 -req -sha256 -in client1Cert.req -out client1Cert.cer -CAkey MyAzureVPN.key -CA MyAzureVPN.cer -days 1800 -CAcreateserial -CAserial serial
# Pack key and certificate in a .pfx(pkcs12 format)
openssl pkcs12 -export -out client1Cert.pfx -inkey client1Cert.key -in client1Cert.cer -certfile MyAzureVPN.cer

























# Generate a certificate request
openssl genrsa -out client1Cert.key 2048 openssl req -new -out client1Cert.req -key client1Cert.key -subj /CN="MyAzureVPN"
# Generate a certificate from the certificate request and sign it as the CA that you are.

openssl x509 -req -sha256 -in client1Cert.req -out client1Cert.cer -CAkey MyAzureVPN.key -CA MyAzureVPN.cer -days 1800 -CAcreateserial -CAserial serial
# Pack key and certificate in a .pfx(pkcs12 format)

openssl pkcs12 -export -out client1Cert.pfx -inkey client1Cert.key -in client1Cert.cer -certfile MyAzureVPN.cer