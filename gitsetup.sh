#!/bin/bash

declare -a COLORS
for (( i = 0 ; i < 10 ; i++ )); do
	COLORS[$i]="\033[1;3${i}m"
done
COLORS[10]="\033[1;0m"

print_msg()
{
	local state=
	case $1 in
		'0') state="[${COLORS[2]}OK${COLORS[10]}]";;
		'1') state="[${COLORS[1]}Fail${COLORS[10]}]";;
		'2') state="[${COLORS[2]}Skip${COLORS[10]}]";;
	esac
	echo -e "- $2\t\t\t$state"
}

if [ $# -gt 0 ]; then
	GIT_USER=$1
else
	CVS_USER=`env | grep CVSROOT | cut -d ':' -f 3 | cut -d '@' -f 1`

	if [ -z ${CVS_USER} ]; then
		echo "Cannot get user name from argument or CVSROOT variables."
		echo "Usage: "
		echo "  $0 [userID]"
		exit -1
	else
		GIT_USER=${CVS_USER}
	fi
fi

if [ -f "/root/.ssh/id_rsa.pub" ]; then
	echo "the ssh key is already generated, use the old one."
else
	ssh-keygen -f /root/.ssh/id_rsa -N ""
fi

cat <<EOF
==================================================
Please import your ssh key by following the wiki
(http://synowiki.synology.com/index.php?title=Adding_a_SSH_key_to_GitLab),
otherwise you will not able to clone repostiory from git server by ssh.
==================================================
EOF
EXPORT_GIT_VAR_CMD="export GIT_AUTHOR_NAME=${GIT_USER}"
EXPORT_GIT_MAIL_CMD="export GIT_AUTHOR_EMAIL=${GIT_USER}@synology.com"
GIT_VAR_IN_BASHRC=`cat ~/.bashrc | grep GIT_AUTHOR_NAME`
GIT_VAR=`env | grep GIT_AUTHOR_NAME`

# if GIT_AUTHOR_NAME is not defined, setup it

if [ -z "${GIT_VAR}" ]; then
	${EXPORT_GIT_VAR_CMD}
	${EXPORT_GIT_MAIL_CMD}
	print_msg 0 "Export GIT_AUTHOR_XXXX \t"
fi

# set global git config for user/email
git config --global user.name ${GIT_USER}
git config --global user.email ${GIT_USER}@synology.com
git config --global core.filemode true
git config --global core.editor vim
git config --global alias.st status
git config --global alias.ci commit
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.df diff
git config --global alias.pick cherry-pick
git config --global alias.fp format-patch
git config --global alias.la "log --graph --decorate --pretty=oneline --abbrev-commit --all"
git config --global alias.ll "log --graph --decorate --pretty=oneline --abbrev-commit"
git config --global alias.lf "log --stat --decorate --format=fuller abbrev-commit"
git config --global color.ui auto
git config --global color.diff auto
git config --global color.status auto
git config --global color.branch auto
git config --global color.log auto
git config --global push.default simple
print_msg 0 "Setup common global configurations"

if [ -z "${GIT_VAR_IN_BASHRC}" ]; then
	echo ${EXPORT_GIT_VAR_CMD} >> ~/.bashrc
	echo ${EXPORT_GIT_MAIL_CMD} >> ~/.bashrc
	print_msg 0 "Export GIT_AUTHOR_XXXX to .bashrc"
else
	print_msg 2 "Export GIT_AUTHOR_XXXX to .bashrc"
fi

echo "Done."
