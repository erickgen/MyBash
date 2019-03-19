#!/bin/bash
branch_flag=$1
branch_name=$2
msg_flag=$3
msg_remark=$4
if [[ "$branch_flag" != "-b" || "$branch_name" = "" ]];
then
    echo "USAGE: ./sync_to_test.sh -b branch_name -m comment"
    exit 1
fi
if [[ "$msg_flag" != "-m" || "$msg_remark" = "" ]];
then
    echo "USAGE: ./sync_to_test.sh -b branch_name -m comment"
    exit 1
fi

cur_branch_name=`git branch |grep '*' |cut -d "*" -f2`
st=`date +%Y%m%d%H%M%S`
echo "Beging!"

echo "Switching to branch test"
/usr/bin/git checkout test
echo "Pulling to test code..."
/usr/bin/git pull origin test
echo "Merging dev_branch to test..."
/usr/bin/git merge $branch_name --no-ff  -m "Merge branch '$branch_name' into test"

echo "Updating version number..."
verfile='version.xml'
version=`cat $verfile | sed -n -e '3p' | cut -d ":" -f2 | cut -d "<" -f1`
ver1=`echo $version | cut -d "." -f1`
ver2=`echo $version | cut -d "." -f2`
ver3=`echo $version | cut -d "." -f3`
if [ $ver3 = '99' ]; then
    ver3=0
    if [ $ver2 = '99' ]; then
        ver2=0
        let ver1+=1
    else
        let ver2+=1
    fi
else
    let ver3+=1
fi
newversion="$ver1.$ver2.$ver3"
`sed -i s/$version/$newversion/g $verfile`
/usr/bin/git commit -m 'update version number' $verfile

echo "Pushing to test"
/usr/bin/git push origin test
echo "Creating tag to test..."
git tag -a "v,$st" -m "$msg_remark"
echo "Pushing tag..."
git push origin "v,$st"

/usr/bin/git checkout $cur_branch_name
echo "The latest version:${newversion}"
echo "Done!"
