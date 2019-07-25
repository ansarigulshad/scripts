###########################################################
#  Steps to setup & use Automatic Kerberos Setup script   #
###########################################################

### Notes
Kinldy Use __`setup_kdc.sh`__ script on KDC host only.
Before executing __`setup_ambari_krb.sh`__ script, make sure all hadoop service are up and running. You can also do service check for all services to make sure everything is working fine.

## 1. Log in to your kdc host as root

## 2. Download the script
```
$ yum install git -y
$ git clone https://github.com/ansarigulshad/scripts.git
$ cd scripts/shell/kerberos/;chmod +x *.sh
```
## 3. Edit `krb.properties` file and modify values as per your requirements

## 4. Execute `setup_kdc.sh` to setup kdc server automatically
```
$ sh setup_kdc.sh
```

## 5. After Successfull KDC setup, Verify whether you are able to do kinit with admin/admin principal (default password is :hadoop)

```
$ kinit admin/admin
```

## 6. Execute setup_ambari_krb.sh to enable kerberos on HDP cluster through ambari REST API
```
$ sh setup_ambari_krb.sh
```


