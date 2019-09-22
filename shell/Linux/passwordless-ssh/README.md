# Script to setup passwordless SSH on Linux


### Step 1: Create a file 'hosts.list' to store server FQDN's (one per line)
##### Example: 
```
$ cat hosts.list
hadoop.master1.us-east1-b.c.x-plateau-236613.internal
hadoop.master2.us-east1-b.c.x-plateau-236613.internal
hadoop.dn1.us-east1-b.c.x-plateau-236613.internal
hadoop.dn2.us-east1-b.c.x-plateau-236613.internal
hadoop.dn3.us-east1-b.c.x-plateau-236613.internal
```

### Step 2: (Optional) Enable Password Authentication [Perform this step only if password login is disabled ]

```
[1]-----Allow Password Authentication-----------------------
sudo sed -i  's/^PasswordAuthentication no.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config && sudo cat /etc/ssh/sshd_config | grep PasswordAuthentication
sudo service sshd restart

[2]----Change/Update Password-----------------------------
# Change Password to $MyPASSWORD if password is not set (skip the step if you do not want to change your password)
su - <yourUsername>
$ echo -e "<yourPassword>\n<<yourPassword>>" | sudo passwd <yourUsername>
```

### Step 3: Update username & password in `setup_passwordless-ssh.sh` file

### Step 4: Execute `setup_passwordless-ssh.sh`
```
sh setup_passwordless-ssh.sh
```
