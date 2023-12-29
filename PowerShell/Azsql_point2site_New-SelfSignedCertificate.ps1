#Create a self-signed root certificate

$cert = PKI\New-SelfSignedCertificate -CertStoreLocation Cert:\CurrentUser\My -KeyAlgorithm RSA -KeyExportPolicy Exportable -KeyLength 2048 -KeySpec Signature -KeyUsage CertSign -KeyUsageProperty Sign -NotAfter (Get-Date).AddMonths(24) -Subject CN=P2SRootCert -Type Custom

#Generate a client certificate
#Get-ChildItem -Path "Cert:\CurrentUser\My"

#$cert = Get-ChildItem -Path  "Cert:\CurrentUser\My\<Add ThumbPrint>"

PKI\New-SelfSignedCertificate -CertStoreLocation Cert:\CurrentUser\My -KeyAlgorithm RSA -KeyExportPolicy Exportable -KeyLength 2048 -KeySpec Signature -KeyUsage CertSign -KeyUsageProperty Sign -NotAfter (Get-Date).AddMonths(24) -Signer $cert -Subject CN=P2SChildCert -TextExtension @('2.5.29.37={text}1.3.6.1.5.5.7.3.2') -Type Custom