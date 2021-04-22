

## deps

`aur polkit-dump-agent-git python-validity`
`sudo systemctl restart python3-validity`


if does not work after suspend:
`sudo systemctl enable open-fprintd-resume open-fprintd-suspend`

## setup

`fprintd-enroll` and scan your right index finger 8x

`fprintd-verify` to verify


Add pam_fprintd.so as sufficient to the top of the auth section of `/etc/pam.d/{login,su,sudo,gdm,lightdm,i3Lock}`

```
/etc/pam.d/system-local-login

auth		sufficient  	pam_fprintd.so
```

or to do first password and then fp:

```
auth		sufficient  	pam_unix.so try_first_pass likeauth nullok
auth		sufficient  	pam_fprintd.so
```
