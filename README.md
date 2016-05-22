# ownCA

Simplifies the creation of self certificate authority and server/client certificate generation
Based and thanks to this tutorial https://jamielinux.com/docs/openssl-certificate-authority/introduction.html
Author:	Islam Bahnasy
Email:	islam@cybertechlab.com


# Usage:
ownca.sh init-ca"<br />
ownca.sh root-cert"<br />
ownca.sh server-cert <hostname/common_name><br />
ownca.sh client-cert <hostname/common_name><br />
ownca.sh show-cert <certificate_filename><br />
ownca.sh verify-cert <certificate_filename><br />

