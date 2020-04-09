## setup_sssd_for_openldap_server

### 1. Execute `setup_sssd.sh` script
```
sh setup_sssd.sh
```

### 2. setup sssd on other nodes
```
for i in `cat /tmp/hosts.list`
do 
echo $i
ssh $i 'yum clean all;yum install sssd authconfig -y;chkconfig sssd on;'
scp /etc/sssd/sssd.conf $i:/etc/sssd/
scp /etc/pam.d/sshd $i:/etc/pam.d/
ssh $i 'chown root:root /etc/sssd/sssd.conf;chmod 600 /etc/sssd/sssd.conf;systemctl restart sssd;authconfig --enablesssdauth --enablesssd --updateall'
done
```
