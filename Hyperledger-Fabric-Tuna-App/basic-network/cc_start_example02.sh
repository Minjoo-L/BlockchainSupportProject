# Exit on first error
set -e
starttime=$(date +%s)
CHANNEL_NAME=mychannel
CC_RUNTIME_LANGUAGE=golang
CC_SRC_PATH=github.com/chaincode_example02/go
CC_NAME=example02
CC_VERSION=1.0

docker-compose -f ./docker-compose.yml up -d cli_GovernmentOrg cli_SupportingEnterpriseOrg
docker ps -a
# GovernmentOrg
echo ==========================================================================
echo        GovernmentOrg
echo ==========================================================================
echo  install chaincode to peer0.GovernmentOrg.example.com
#install chaincode to peer0.GovernmentOrg.example.com - 각 endoser peer에 모두 설치 
docker exec  cli_GovernmentOrg peer chaincode install -n "$CC_NAME" -v "$CC_VERSION" -p "$CC_SRC_PATH" -l "$CC_RUNTIME_LANGUAGE"
echo  instantiate chaincode to mychannel
#instantiate chaincode - 채널 당 한번만 실행 
# 인스턴스 생성 docker ps -a 해보면
# dev-peer0.GovernmentOrg.example.com-example02-1.0-xxxx 식의 컨테이너 생성됨
docker exec  cli_GovernmentOrg peer chaincode instantiate -o orderer.example.com:7050 -C "$CHANNEL_NAME" -n "$CC_NAME" -l "$CC_RUNTIME_LANGUAGE" -v "$CC_VERSION" -c '{"Args":["init","a","100","b","200"]}' -P "OR ('GovernmentOrgMSP.member','SupportingEnterpriseOrgMSP.member')"
sleep 5

docker exec  peer0.GovernmentOrg.example.com peer chaincode query  -C "$CHANNEL_NAME" -n "$CC_NAME" -c '{"Args":["query","a"]}'
docker exec  peer0.GovernmentOrg.example.com peer chaincode query  -C "$CHANNEL_NAME" -n "$CC_NAME" -c '{"Args":["query","b"]}'
docker exec  peer0.GovernmentOrg.example.com peer chaincode invoke  -C "$CHANNEL_NAME" -n "$CC_NAME" -c '{"Args":["invoke","a","b","10"]}'
sleep 5
docker exec  peer0.GovernmentOrg.example.com peer chaincode query  -C "$CHANNEL_NAME" -n "$CC_NAME" -c '{"Args":["query","a"]}'
docker exec  peer0.GovernmentOrg.example.com peer chaincode query  -C "$CHANNEL_NAME" -n "$CC_NAME" -c '{"Args":["query","b"]}'
echo ==========================================================================
echo  install chaincode to peer1.GovernmentOrg.example.com
#install chaincode to peer1.GovernmentOrg.example.com - 각 endoser peer에 모두 설치 
docker exec -e CORE_PEER_ADDRESS=peer1.GovernmentOrg.example.com:18051  cli_GovernmentOrg peer chaincode install -n "$CC_NAME" -v "$CC_VERSION" -p "$CC_SRC_PATH" -l "$CC_RUNTIME_LANGUAGE"
# endoser peer에서 처음 query 수행하면 인스턴스 생성됨 docker ps -a 해보면
# dev-peer1.GovernmentOrg.example.com-example02-1.0-xxxx 식의 컨테이너 생성됨
docker exec  peer1.GovernmentOrg.example.com peer chaincode query  -C "$CHANNEL_NAME" -n "$CC_NAME" -c '{"Args":["query","a"]}'
sleep 5
docker exec  peer1.GovernmentOrg.example.com peer chaincode query  -C "$CHANNEL_NAME" -n "$CC_NAME" -c '{"Args":["query","b"]}'
docker exec  peer1.GovernmentOrg.example.com peer chaincode invoke  -C "$CHANNEL_NAME" -n "$CC_NAME" -c '{"Args":["invoke","a","b","5"]}'
sleep 5
docker exec  peer1.GovernmentOrg.example.com peer chaincode query  -C "$CHANNEL_NAME" -n "$CC_NAME" -c '{"Args":["query","a"]}'
docker exec  peer1.GovernmentOrg.example.com peer chaincode query  -C "$CHANNEL_NAME" -n "$CC_NAME" -c '{"Args":["query","b"]}'

docker exec  peer0.GovernmentOrg.example.com peer chaincode query  -C "$CHANNEL_NAME" -n "$CC_NAME" -c '{"Args":["query","a"]}'
docker exec  peer0.GovernmentOrg.example.com peer chaincode query  -C "$CHANNEL_NAME" -n "$CC_NAME" -c '{"Args":["query","b"]}'

# SupportingEnterpriseOrg
echo ==========================================================================
echo        SupportingEnterpriseOrg
echo ==========================================================================
echo  install chaincode to peer0.SupportingEnterpriseOrg.example.com
#install chaincode to peer0.SupportingEnterpriseOrg.example.com - 각 endoser peer에 모두 설치 
docker exec -e CORE_PEER_ADDRESS=peer0.SupportingEnterpriseOrg.example.com:27051  cli_SupportingEnterpriseOrg   peer chaincode install -n "$CC_NAME" -v "$CC_VERSION" -p "$CC_SRC_PATH" -l "$CC_RUNTIME_LANGUAGE"
# endoser peer에서 처음 query 수행하면 인스턴스 생성됨 docker ps -a 해보면
# dev-peer0.SupportingEnterpriseOrg.example.com-example02-1.0-xxxx 식의 컨테이너 생성됨
# docker exec  -e CORE_PEER_ADDRESS=peer0.SupportingEnterpriseOrg.example.com:7051  cli_SupportingEnterpriseOrg   peer chaincode query -o orderer.example.com:7050 -C "$CHANNEL_NAME" -n "$CC_NAME" -c '{"Args":["query","a"]}'
docker exec  peer0.SupportingEnterpriseOrg.example.com peer chaincode query  -C "$CHANNEL_NAME" -n "$CC_NAME" -c '{"Args":["query","a"]}'
sleep 5
docker exec  peer0.SupportingEnterpriseOrg.example.com peer chaincode query  -C "$CHANNEL_NAME" -n "$CC_NAME" -c '{"Args":["query","b"]}'
# docker exec  -e CORE_PEER_ADDRESS=peer0.SupportingEnterpriseOrg.example.com:7051   cli_SupportingEnterpriseOrg   peer chaincode invoke -o orderer.example.com:7050  -C "$CHANNEL_NAME" -n "$CC_NAME" -c '{"Args":["invoke","a","b","5"]}'
docker exec  peer0.SupportingEnterpriseOrg.example.com peer chaincode invoke  -C "$CHANNEL_NAME" -n "$CC_NAME" -c '{"Args":["invoke","a","b","5"]}'
sleep 5
docker exec  peer0.SupportingEnterpriseOrg.example.com peer chaincode query  -C "$CHANNEL_NAME" -n "$CC_NAME" -c '{"Args":["query","a"]}'
docker exec  peer0.SupportingEnterpriseOrg.example.com peer chaincode query  -C "$CHANNEL_NAME" -n "$CC_NAME" -c '{"Args":["query","b"]}'
echo ==========================================================================
echo  install chaincode to peer1.SupportingEnterpriseOrg.example.com
#install chaincode to peer1.SupportingEnterpriseOrg.example.com - 각 endoser peer에 모두 설치 
docker exec -e CORE_PEER_ADDRESS=peer1.SupportingEnterpriseOrg.example.com:28051  cli_SupportingEnterpriseOrg peer chaincode install -n "$CC_NAME" -v "$CC_VERSION" -p "$CC_SRC_PATH" -l "$CC_RUNTIME_LANGUAGE"
# endoser peer에서 처음 query 수행하면 인스턴스 생성됨 docker ps -a 해보면
# dev-peer1.SupportingEnterpriseOrg.example.com-example02-1.0-xxxx 식의 컨테이너 생성됨
docker exec  peer1.SupportingEnterpriseOrg.example.com peer chaincode query  -C "$CHANNEL_NAME" -n "$CC_NAME" -c '{"Args":["query","a"]}'
sleep 5
docker exec  peer1.SupportingEnterpriseOrg.example.com peer chaincode query  -C "$CHANNEL_NAME" -n "$CC_NAME" -c '{"Args":["query","b"]}'
docker exec  peer1.SupportingEnterpriseOrg.example.com peer chaincode invoke  -C "$CHANNEL_NAME" -n "$CC_NAME" -c '{"Args":["invoke","a","b","5"]}'
sleep 5
docker exec  peer1.SupportingEnterpriseOrg.example.com peer chaincode query  -C "$CHANNEL_NAME" -n "$CC_NAME" -c '{"Args":["query","a"]}'
docker exec  peer1.SupportingEnterpriseOrg.example.com peer chaincode query  -C "$CHANNEL_NAME" -n "$CC_NAME" -c '{"Args":["query","b"]}'

docker exec  peer0.SupportingEnterpriseOrg.example.com peer chaincode query  -C "$CHANNEL_NAME" -n "$CC_NAME" -c '{"Args":["query","a"]}'
docker exec  peer0.SupportingEnterpriseOrg.example.com peer chaincode query  -C "$CHANNEL_NAME" -n "$CC_NAME" -c '{"Args":["query","b"]}'

docker exec  peer0.GovernmentOrg.example.com peer chaincode query  -C "$CHANNEL_NAME" -n "$CC_NAME" -c '{"Args":["query","a"]}'
docker exec  peer0.GovernmentOrg.example.com peer chaincode query  -C "$CHANNEL_NAME" -n "$CC_NAME" -c '{"Args":["query","b"]}'

cat <<EOF
Total setup execution time : $(($(date +%s) - starttime)) secs ...
EOF
