set -e
git_id=$(git rev-parse --short HEAD)
git_branch=$(git symbolic-ref --short HEAD)

registry=docker.montagu.dide.ic.ac.uk:5000
name=montagu-vault

tag=$registry/$name:$git_id

docker build \
	-t $tag \
	-t $registry/$name:$git_branch \
	.

echo "Pushing $tag"
docker push $tag