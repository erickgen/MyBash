#!/bin/bash
source common.sh
project_name=$1
msg_flag=$2
msg_content=$3
if [[ "$project_name" = "" ]];
then
    echo "USAGE: ./code_to_online.sh <project-name> [eg.project1|project2|project3|project4] -m comment" | _color_ red bold
    exit 1
fi
if [[ "$msg_flag" != "-m" || "$msg_content" = "" ]];
then
    echo "USAGE: ./code_to_online.sh <project-name> [eg.project1|project2|project3|project4] -m comment" | _color_ red bold
    exit 1
fi
for var in ${allow_project_list[@]};do
    if [[ "$var" = "$project_name" ]];
    then
        real_project=true
    fi
done

if [[ "$real_project" != true ]];
then
    echo "项目$project_name不存在" | _color_ red bold
    exit 1
fi
file_path=`find / -name "code_to_online.sh"`
cur_path=${file_path/code_to_online.sh/}
code_dir="$cur_path/code/$project_name"

if [ ! -d "$code_dir" ]; then
    cd "${cur_path}/code"
    `/usr/bin/git clone git@$gitserver:git/$project_name.git $project_name`
fi

st=`date +%Y%m%d%H%M%S`
echo "Beging!" | _color_ cyan bold
cd "${code_dir}"
echo "Switching to branch master..." | _color_ cyan bold
/usr/bin/git checkout master
echo "Pulling to master code..." | _color_ cyan bold
/usr/bin/git pull origin master
echo "Switching to branch online..." | _color_ cyan bold
/usr/bin/git checkout online
echo "Pulling to online code..." | _color_ cyan bold
/usr/bin/git pull origin online
echo "Merging master to online..." | _color_ cyan bold
/usr/bin/git merge master --no-ff  -m "Merge branch 'master' into online"


echo "Updating version number..." | _color_ cyan bold
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

echo "Pushing to online..." | _color_ cyan bold
/usr/bin/git push origin online
echo "Creating tag to online..." | _color_ cyan bold
git tag -a "v,$st" -m "$msg_content"
echo "Pushing tag..." | _color_ cyan bold
git push origin "v,$st"

/usr/bin/git checkout master
echo "The latest version:${newversion}" | _color_ blue bold
echo "Done!" | _color_ green bold
