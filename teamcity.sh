set -e
git_id=$(git rev-parse --short HEAD)
git_branch=$(git symbolic-ref --short HEAD)

registry=docker.montagu.dide.ic.ac.uk:5000
name=montagu-vault

commit_tag=$registry/$name:$git_id
branch_tag=$registry/$name:$git_branch

docker build -t $commit_tag -t $branch_tag .

set -x
docker push $commit_tag
docker push $branch_tag