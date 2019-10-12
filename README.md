# azure-dsvm
Setting up an Azure Data Science Virtual Machine

# Creating SSL certificate for Jupyterhub

## Set up a web server on port 80
1. Enable and start nginx:
```bash
sudo systemctl enable nginx && sudo systemctl start nginx
```

2. In the Azure-portal, add an incoming firewall rule for port 80

3. Add yourself to the ```www-data``` group:
```bash
sudo usermod -aG www-data $USER
```
Log out and in to activate the group change.

4. Create a directory for the acme-challenge':
```bash
sudo mkdir -p /usr/share/nginx/html/.well-known/acme-challenge
sudo chmod 775 /usr/share/nginx/html/.well-known/acme-challenge
sudo chown www-data.www-data /usr/share/nginx/html/.well-known/acme-challenge
```


## Download ZeroSSL client
1. Add yourself to the docker group:
```bash
sudo usermod -aG docker $USER
```
Log out and in to activate the group change

2. Download the docker image with the ZeroSSL client:
```bash
docker pull zerossl/client
```

3. Create an alias for running the ZeroSSL client:
```bash
alias le.pl='docker run -it -v /etc/jupyterhub/srv:/data -v /usr/share/nginx/html/.well-known/acme-challenge:/webroot -u $(id -u www-data) --rm zerossl/client'
```


## Create new SSL certificates

1. Back up the existing certificate

```bash
le.pl --key account.key --email "martin.hoy@dnvgl.com" --csr domain.csr --csr-key domain.key --crt domain.crt --domains "nautilus.northeurope.cloudapp.azure.com" --generate-missing --path /webroot --unlink --api 2
```

2. Make the certificate directory writable for the www-data user:
```bash
sudo chown www-data /etc/jupyterhub/srv
```

3. Use the client to generate a certificate:
```bash
le.pl --key account.key --email "martin.hoy@dnvgl.com" --csr domain.csr --csr-key server.key --crt server.crt --domains "nautilus.northeurope.cloudapp.azure.com" --generate-missing --path /webroot --unlink --api 2 --live
```
