#!/bin/bash

function change_base_image(){
    for file in `ls $1`
    do
        if [ -d $1"/"$file ]
        then
            change_base_image $1"/"$file
        elif [[ $file == *Dockerfile* ]]
        then
            sed -i 's/photon:2.0/photon:3.0/' $1"/"$file
            echo $1"/"$file
        fi
    done
}

change_base_image "make/photon"

sed -i 's/BUILDBIN=false/BUILDBIN=true/g' "Makefile"
sed -i 's/CLAIRFLAG=false/CLAIRFLAG=true/g' "Makefile"
sed -i 's/-v $(BUILDPATH):/-v $(COMPILEBUILDPATH):/g' "Makefile"
sed -i 's/-e NPM_REGISTRY=$(NPM_REGISTRY)/-e NPM_REGISTRY=$(NPM_REGISTRY) -e NOTARYFLAG=true -e CHARTFLAG=true -e CLAIRFLAG=true/g' "Makefile"
sed -i '1 a COMPILEBUILDPATH=/go/src' "Makefile"
sed -i 's/=goharbor\//=yugougou\//g' "Makefile"
sed -i 's/VERSIONTAG=dev/VERSIONTAG=v1.8.6/g' "Makefile"
sed -i 's/compile: check_environment versions_prepare compile_core compile_jobservice compile_registryctl compile_notary_migrate_patch/compile: versions_prepare compile_core compile_jobservice compile_registryctl compile_notary_migrate_patch/g' "Makefile"
echo "AMD64 after handle the Makefile is "
cat Makefile

sed -i 's/build: _build_prepare _build_db _build_portal _build_core _build_jobservice _build_log _build_nginx _build_registry _build_registryctl _build_notary _build_clair _build_redis _build_migrator _build_chart_server/build: _build_db  _build_core _build_jobservice _build_nginx _build_registry _build_registryctl _build_notary _build_clair   _build_chart_server _build_portal/g' "make/photon/Makefile"

sed -i 's/=goharbor\//=yugougou\//g' "make/photon/Makefile"

echo "AMD64 after handle the make/photon/Makefile is "
cat make/photon/Makefile


sed -i 's/docker run -it/docker run -i/g' "make/photon/chartserver/builder"
sed -i 's/$PWD/\/go\/src\/make\/photon\/chartserver/g' "make/photon/chartserver/builder"
echo "AMD64 after handle make/photon/chartserver/builder is"
cat make/photon/chartserver/builder



make ui_version compile
make build

docker build -f redis/Dockerfile -t yugougou/harbor-redis:v1.8.6 .

docker login --username yugougou --password dochub_123456
docker push yugougou/harbor-portal:v1.8.6
docker push yugougou/clair-photon:v2.1.0-v1.8.6
docker push yugougou/notary-server-photon:v0.6.1-v1.8.6
docker push yugougou/notary-signer-photon:v0.6.1-v1.8.6
docker push yugougou/harbor-registryctl:v1.8.6
docker push yugougou/registry-photon:v2.7.1-patch-2819-v1.8.6
docker push yugougou/nginx-photon:v1.8.6
docker push yugougou/harbor-jobservice:v1.8.6
docker push yugougou/harbor-core:v1.8.6
docker push yugougou/harbor-db:v1.8.6
docker push yugougou/harbor-redis:v1.8.6
docker push yugougou/chartmuseum-photon:v0.9.0-v1.8.6





docker login armharbor.alauda.cn --username alaudak8s --password t4YSpvPrrFOsjAapawc5
echo 'preapre for build arm64 image'
echo 'mv ./dumb-init_1.2.2_arm64 ./make/photon/clair/dumb-init'
mv ./dumb-init_1.2.2_arm64 ./make/photon/clair/dumb-init

sed -i 's/build --pull/buildx build --allow network.host --platform linux\/arm64 --progress plain --output=type=registry/' "make/photon/Makefile"
sed -i 's/=yugougou\//=armharbor.alauda.cn\/alaudak8s\//g' "make/photon/Makefile"
echo "ARM64 make/photon/Makefile is "
cat make/photon/Makefile

sed -i 's/--rm/--rm --env CGO_ENABLED=0 --env GOOS=linux --env GOARCH=arm64/g' "Makefile"
sed -i 's/=yugougou\//=armharbor.alauda.cn\/alaudak8s\//g' "Makefile"
echo "ARM64 Makefile is "
cat Makefile




sed -i 's/go build -a/GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -a/g' "make/photon/chartserver/compile.sh"
echo "ARM64 make/photon/chartserver/compile.sh is "
cat make/photon/chartserver/compile.sh



sed -i 's/go build/CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build/g' "make/photon/clair/Dockerfile.binary"
echo "ARM64 make/photon/clair/Dockerfile.binary is "
cat make/photon/clair/Dockerfile.binary



sed -i 's/notary-server/linux_arm64\/notary-server/g' make/photon/notary/builder
sed -i 's/notary-signer/linux_arm64\/notary-signer/g' make/photon/notary/builder
echo "ARM64 make/photon/notary/builder is "
cat make/photon/notary/builder



sed -i 's/CGO_ENABLED=0/GOOS=linux GOARCH=arm64 CGO_ENABLED=0/g' "make/photon/registry/Dockerfile.binary"
echo "ARM64 make/photon/registry/Dockerfile.binary is "
cat make/photon/registry/Dockerfile.binary



sed -i '23,24d' "make/photon/notary/binary.Dockerfile"
sed -i 's/bin\/cli/bin\/linux_arm64\/cli/g' "make/photon/notary/binary.Dockerfile"
sed -i '5 a ENV CGO_ENABLED 0 \nENV GOOS linux \nENV GOARCH arm64' "make/photon/notary/binary.Dockerfile"
sed -i '26 a RUN GOPROXY=https://athens.acp.alauda.cn GO111MODULE=on go mod tidy' "make/photon/notary/binary.Dockerfile"
sed -i '26 a RUN GOPROXY=https://athens.acp.alauda.cn GO111MODULE=on go mod vendor' "make/photon/notary/binary.Dockerfile"

echo "ARM64 make/photon/notary/binary.Dockerfile is "
cat make/photon/notary/binary.Dockerfile

echo "build image for arm64"

docker buildx build --allow network.host --platform linux/arm64 --progress plain --output=type=registry -t armharbor.alauda.cn/alaudak8s/harborredis:test -f redis/Dockerfile .

make compile
make build








