# ownCA

# Simplifies the creation of self certificate authority and server/client certificate generation
# Based and thanks to this tutorial https://jamielinux.com/docs/openssl-certificate-authority/introduction.html
Author:	Islam Bahnasy
Email:	islam@cybertechlab.com


# Usage:
ownca.sh init-ca"
ownca.sh root-cert"
ownca.sh server-cert <hostname/common_name>
ownca.sh client-cert <hostname/common_name>
ownca.sh show-cert <certificate_filename>
ownca.sh verify-cert <certificate_filename>

