set -e
git_id=$(git rev-parse --short=7 HEAD)
git_branch=$(git symbolic-ref --short HEAD)

registry=imperialebola2018
name=ebola-vault

commit_tag=$registry/$name:$git_id
branch_tag=$registry/$name:$git_branch

docker build -t $commit_tag -t $branch_tag .
