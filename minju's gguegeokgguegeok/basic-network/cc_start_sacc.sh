# Exit on first error
set -e
starttime=$(date +%s)
CHANNEL_NAME=mychannel
CHANNEL_NO1=1
CHANNEL_NAME1=${CHANNEL_NAME}${CHANNEL_NO1}
#${CHANNEL_NAME}${CHANNEL_NO1}
CC_RUNTIME_LANGUAGE1=golang
CC_SRC_PATH1=github.com/tuna-app
CC_VERSION1=1.0
CC_NAME1=tuna-app
CHANNEL_NO2=2
CHANNEL_NAME2=${CHANNEL_NAME}${CHANNEL_NO2}
CC_RUNTIME_LANGUAGE2=golang
CC_SRC_PATH2=github.com/tuna-app
CC_VERSION2=1.0
CC_NAME2=tuna-app
CHANNEL_NO3=3
CHANNEL_NAME3=${CHANNEL_NAME}${CHANNEL_NO3}
CC_RUNTIME_LANGUAGE3=golang
CC_SRC_PATH3=github.com/tuna-app
CC_VERSION3=1.0
CC_NAME3=tuna-app
CHANNEL_NO4=4
CHANNEL_NAME4=${CHANNEL_NAME}${CHANNEL_NO4}
CC_RUNTIME_LANGUAGE4=golang
CC_SRC_PATH4=github.com/tuna-app
CC_VERSION4=1.0
CC_NAME4=tuna-app

docker-compose -f ./docker-compose.yml up -d cli_GovernmentOrg  cli_SupportingEnterpriseOrg  cli_RecipientOrg  cli_SupporterOrg
docker ps -a
echo ==========================================================================
echo        CH1 4개 조직
echo ==========================================================================
# GovernmentOrg
echo ====  GovernmentOrg  ========
echo install chaincode to peer0.GovernmentOrg.example.com
#install chaincode to peer0.GovernmentOrg.example.com - 각 endoser peer에 모두 설치 
docker exec  cli_GovernmentOrg peer chaincode install -n "$CC_NAME1" -v "$CC_VERSION1" -p "$CC_SRC_PATH1" 
echo instantiate chaincode to mychannel
#instantiate chaincode - 채널 당 한번만 실행 
# 인스턴스 생성 docker ps -a 해보면
# dev-peer0.GovernmentOrg.example.com-sacc-1.0-xxxx 식의 컨테이너 생성됨
# cli_GovernmentOrg peer chaincode instantiate -o orderer.example.com:7050 -C FourOrgChannel -n tuna-app -v 1.0 -c '{"Args":[""]}' -P "OR ('GovernmentOrgMSP.member','SupportingEnterpriseMSP.member', 'RecipientMSP.member', 'SupporterMSP.member')"

docker exec cli_GovernmentOrg peer chaincode instantiate -o orderer.example.com:7050 -C "$CHANNEL_NAME1" -n "$CC_NAME1" -v "$CC_VERSION1" -c '{"Args":[""]}' -P "OR ('GovernmentOrgMSP.member','SupportingEnterpriseOrgMSP.member','RecipientOrgMSP.member','SupporterOrgMSP.member')"
sleep 5
echo 됨됨???
docker exec  peer0.GovernmentOrg.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":[""]}'
docker exec  peer0.GovernmentOrg.example.com peer chaincode invoke  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"function":"initLedger","Args":[""]}'
sleep 5
docker exec  peer0.GovernmentOrg.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":[""]}'
echo ==========================================================================
echo install chaincode to peer1.GovernmentOrg.example.com
#install chaincode to peer1.GovernmentOrg.example.com - 각 endoser peer에 모두 설치 
docker exec -e CORE_PEER_ADDRESS=peer1.GovernmentOrg.example.com:18051  cli_GovernmentOrg peer chaincode install -n "$CC_NAME1" -v "$CC_VERSION1" -p "$CC_SRC_PATH1" 
# endoser peer에서 처음 query 수행하면 인스턴스 생성됨 docker ps -a 해보면
# dev-peer1.GovernmentOrg.example.com-sacc-1.0-xxxx 식의 컨테이너 생성됨
docker exec  peer1.GovernmentOrg.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
docker exec  peer1.GovernmentOrg.example.com peer chaincode invoke  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["set","a","150"]}'
sleep 5
docker exec  peer1.GovernmentOrg.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
docker exec  peer0.GovernmentOrg.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
echo ==========================================================================
# SupportingEnterpriseOrg
echo ====  SupportingEnterpriseOrg  ========
echo install chaincode to peer0.SupportingEnterpriseOrg.example.com
#install chaincode to peer0.SupportingEnterpriseOrg.example.com - 각 endoser peer에 모두 설치 
docker exec -e CORE_PEER_ADDRESS=peer0.SupportingEnterpriseOrg.example.com:27051  cli_SupportingEnterpriseOrg peer chaincode install -n "$CC_NAME1" -v "$CC_VERSION1" -p "$CC_SRC_PATH1" -l "$CC_RUNTIME_LANGUAGE1"
# endoser peer에서 처음 query 수행하면 인스턴스 생성됨 docker ps -a 해보면
# dev-peer0.SupportingEnterpriseOrg.example.com-sacc-1.0-xxxx 식의 컨테이너 생성됨
docker exec  peer0.SupportingEnterpriseOrg.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
sleep 5
docker exec  peer0.SupportingEnterpriseOrg.example.com peer chaincode invoke  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["set","a","160"]}'
sleep 5
docker exec  peer0.SupportingEnterpriseOrg.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
echo ==========================================================================
echo install chaincode to peer1.SupportingEnterpriseOrg.example.com
#install chaincode to peer1.SupportingEnterpriseOrg.example.com - 각 endoser peer에 모두 설치 
docker exec -e CORE_PEER_ADDRESS=peer1.SupportingEnterpriseOrg.example.com:28051  cli_SupportingEnterpriseOrg peer chaincode install -n "$CC_NAME1" -v "$CC_VERSION1" -p "$CC_SRC_PATH1" -l "$CC_RUNTIME_LANGUAGE1"
# endoser peer에서 처음 query 수행하면 인스턴스 생성됨 docker ps -a 해보면
# dev-peer1.SupportingEnterpriseOrg.example.com-sacc-1.0-xxxx 식의 컨테이너 생성됨
docker exec  peer1.SupportingEnterpriseOrg.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
sleep 5
docker exec  peer1.SupportingEnterpriseOrg.example.com peer chaincode invoke  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["set","a","170"]}'
sleep 5
docker exec  peer1.SupportingEnterpriseOrg.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
docker exec  peer0.SupportingEnterpriseOrg.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
docker exec  peer0.GovernmentOrg.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
# RecipientOrg
echo ====  RecipientOrg  ========
echo install chaincode to peer0.RecipientOrg.example.com
#install chaincode to peer0.RecipientOrg.example.com - 각 endoser peer에 모두 설치 
docker exec -e CORE_PEER_ADDRESS=peer0.RecipientOrg.example.com:37051  cli_RecipientOrg peer chaincode install -n "$CC_NAME1" -v "$CC_VERSION1" -p "$CC_SRC_PATH1" -l "$CC_RUNTIME_LANGUAGE1"
# endoser peer에서 처음 query 수행하면 인스턴스 생성됨 docker ps -a 해보면
# dev-peer0.RecipientOrg.example.com-sacc-1.0-xxxx 식의 컨테이너 생성됨
docker exec  peer0.RecipientOrg.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
sleep 5
docker exec  peer0.RecipientOrg.example.com peer chaincode invoke  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["set","a","175"]}'
sleep 5
docker exec  peer0.RecipientOrg.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
echo ==========================================================================
echo install chaincode to peer1.RecipientOrg.example.com
#install chaincode to peer1.RecipientOrg.example.com - 각 endoser peer에 모두 설치 
docker exec -e CORE_PEER_ADDRESS=peer1.RecipientOrg.example.com:38051  cli_RecipientOrg peer chaincode install -n "$CC_NAME1" -v "$CC_VERSION1" -p "$CC_SRC_PATH1" -l "$CC_RUNTIME_LANGUAGE1"
# endoser peer에서 처음 query 수행하면 인스턴스 생성됨 docker ps -a 해보면
# dev-peer1.RecipientOrg.example.com-sacc-1.0-xxxx 식의 컨테이너 생성됨
docker exec  peer1.RecipientOrg.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
sleep 5
docker exec  peer1.RecipientOrg.example.com peer chaincode invoke  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["set","a","180"]}'
sleep 5
docker exec  peer1.RecipientOrg.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
docker exec  peer0.RecipientOrg.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
docker exec  peer0.GovernmentOrg.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
docker exec  peer0.SupportingEnterpriseOrg.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
# SupporterOrg
echo ====  SupporterOrg  ========
echo install chaincode to peer0.SupporterOrg.example.com
#install chaincode to peer0.SupporterOrg.example.com - 각 endoser peer에 모두 설치 
docker exec -e CORE_PEER_ADDRESS=peer0.SupporterOrg.example.com:47051  cli_SupporterOrg peer chaincode install -n "$CC_NAME1" -v "$CC_VERSION1" -p "$CC_SRC_PATH1" -l "$CC_RUNTIME_LANGUAGE1"
# endoser peer에서 처음 query 수행하면 인스턴스 생성됨 docker ps -a 해보면
# dev-peer0.SupporterOrg.example.com-sacc-1.0-xxxx 식의 컨테이너 생성됨
docker exec  peer0.SupporterOrg.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
sleep 5
docker exec  peer0.SupporterOrg.example.com peer chaincode invoke  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["set","a","185"]}'
sleep 5
docker exec  peer0.SupporterOrg.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
echo ==========================================================================
echo install chaincode to peer1.SupporterOrg.example.com
#install chaincode to peer1.SupporterOrg.example.com - 각 endoser peer에 모두 설치 
docker exec -e CORE_PEER_ADDRESS=peer1.SupporterOrg.example.com:48051  cli_SupporterOrg peer chaincode install -n "$CC_NAME1" -v "$CC_VERSION1" -p "$CC_SRC_PATH1" -l "$CC_RUNTIME_LANGUAGE1"
# endoser peer에서 처음 query 수행하면 인스턴스 생성됨 docker ps -a 해보면
# dev-peer1.SupporterOrg.example.com-sacc-1.0-xxxx 식의 컨테이너 생성됨
docker exec  peer1.SupporterOrg.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
sleep 5
docker exec  peer1.SupporterOrg.example.com peer chaincode invoke  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["set","a","190"]}'
sleep 5
docker exec  peer1.SupporterOrg.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
docker exec  peer0.SupporterOrg.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
docker exec  peer0.GovernmentOrg.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
docker exec  peer0.SupportingEnterpriseOrg.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
docker exec  peer0.RecipientOrg.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
cat <<EOF
Total setup execution time : $(($(date +%s) - starttime)) secs ...
EOF
