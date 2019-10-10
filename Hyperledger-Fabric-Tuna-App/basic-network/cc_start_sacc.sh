# Exit on first error
set -e
starttime=$(date +%s)
CHANNEL_NAME=mychannel
CHANNEL_NO1=1
CHANNEL_NAME1=${CHANNEL_NAME}${CHANNEL_NO1}
CC_RUNTIME_LANGUAGE1=golang
CC_SRC_PATH1=github.com/sacc
CC_VERSION1=1.0
CC_NAME1=sacc
CHANNEL_NO2=2
CHANNEL_NAME2=${CHANNEL_NAME}${CHANNEL_NO2}
CC_RUNTIME_LANGUAGE2=golang
CC_SRC_PATH2=github.com/sacc
CC_VERSION2=1.0
CC_NAME2=sacc
CHANNEL_NO3=3
CHANNEL_NAME3=${CHANNEL_NAME}${CHANNEL_NO3}
CC_RUNTIME_LANGUAGE3=golang
CC_SRC_PATH3=github.com/sacc
CC_VERSION3=1.0
CC_NAME3=sacc

docker-compose -f ./docker-compose.yml up -d cli_org1  cli_org2  cli_org3  cli_org4
docker ps -a
echo ==========================================================================
echo        CH1
echo ==========================================================================
# Org1
echo ====  Org1  ========
echo install chaincode to peer0.org1.example.com
#install chaincode to peer0.org1.example.com - 각 endoser peer에 모두 설치 
docker exec  cli_org1 peer chaincode install -n "$CC_NAME1" -v "$CC_VERSION1" -p "$CC_SRC_PATH1" -l "$CC_RUNTIME_LANGUAGE1"
echo instantiate chaincode to mychannel
#instantiate chaincode - 채널 당 한번만 실행 
# 인스턴스 생성 docker ps -a 해보면
# dev-peer0.org1.example.com-sacc-1.0-xxxx 식의 컨테이너 생성됨
docker exec  cli_org1 peer chaincode instantiate -o orderer.example.com:7050 -C "$CHANNEL_NAME1" -n "$CC_NAME1" -l "$CC_RUNTIME_LANGUAGE1" -v "$CC_VERSION1" -c '{"Args":["a","15"]}' -P "OR ('Org1MSP.member','Org2MSP.member','Org3MSP.member','Org4MSP.member')"
sleep 5

docker exec  peer0.org1.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
docker exec  peer0.org1.example.com peer chaincode invoke  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["set","a","130"]}'
sleep 5
docker exec  peer0.org1.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
echo ==========================================================================
echo install chaincode to peer1.org1.example.com
#install chaincode to peer1.org1.example.com - 각 endoser peer에 모두 설치 
docker exec -e CORE_PEER_ADDRESS=peer1.org1.example.com:18051  cli_org1 peer chaincode install -n "$CC_NAME1" -v "$CC_VERSION1" -p "$CC_SRC_PATH1" -l "$CC_RUNTIME_LANGUAGE1"
# endoser peer에서 처음 query 수행하면 인스턴스 생성됨 docker ps -a 해보면
# dev-peer1.org1.example.com-sacc-1.0-xxxx 식의 컨테이너 생성됨
docker exec  peer1.org1.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
docker exec  peer1.org1.example.com peer chaincode invoke  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["set","a","150"]}'
sleep 5
docker exec  peer1.org1.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
docker exec  peer0.org1.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
echo ==========================================================================
echo install chaincode to peer2.org1.example.com
#install chaincode to peer2.org1.example.com - 각 endoser peer에 모두 설치 
docker exec -e CORE_PEER_ADDRESS=peer2.org1.example.com:19051  cli_org1 peer chaincode install -n "$CC_NAME1" -v "$CC_VERSION1" -p "$CC_SRC_PATH1" -l "$CC_RUNTIME_LANGUAGE1"
# endoser peer에서 처음 query 수행하면 인스턴스 생성됨 docker ps -a 해보면
# dev-peer2.org1.example.com-sacc-1.0-xxxx 식의 컨테이너 생성됨
docker exec  peer2.org1.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
docker exec  peer2.org1.example.com peer chaincode invoke  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["set","a","155"]}'
sleep 5
docker exec  peer2.org1.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
docker exec  peer1.org1.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
docker exec  peer0.org1.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
# Org2
echo ====  Org2  ========
echo install chaincode to peer0.org2.example.com
#install chaincode to peer0.org2.example.com - 각 endoser peer에 모두 설치 
docker exec -e CORE_PEER_ADDRESS=peer0.org2.example.com:27051  cli_org2 peer chaincode install -n "$CC_NAME1" -v "$CC_VERSION1" -p "$CC_SRC_PATH1" -l "$CC_RUNTIME_LANGUAGE1"
# endoser peer에서 처음 query 수행하면 인스턴스 생성됨 docker ps -a 해보면
# dev-peer0.org2.example.com-sacc-1.0-xxxx 식의 컨테이너 생성됨
docker exec  peer0.org2.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
sleep 5
docker exec  peer0.org2.example.com peer chaincode invoke  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["set","a","160"]}'
sleep 5
docker exec  peer0.org2.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
echo ==========================================================================
echo install chaincode to peer1.org2.example.com
#install chaincode to peer1.org2.example.com - 각 endoser peer에 모두 설치 
docker exec -e CORE_PEER_ADDRESS=peer1.org2.example.com:28051  cli_org2 peer chaincode install -n "$CC_NAME1" -v "$CC_VERSION1" -p "$CC_SRC_PATH1" -l "$CC_RUNTIME_LANGUAGE1"
# endoser peer에서 처음 query 수행하면 인스턴스 생성됨 docker ps -a 해보면
# dev-peer1.org2.example.com-sacc-1.0-xxxx 식의 컨테이너 생성됨
docker exec  peer1.org2.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
sleep 5
docker exec  peer1.org2.example.com peer chaincode invoke  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["set","a","170"]}'
sleep 5
docker exec  peer1.org2.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
docker exec  peer0.org2.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
docker exec  peer0.org1.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
# Org3
echo ====  Org3  ========
echo install chaincode to peer0.org3.example.com
#install chaincode to peer0.org3.example.com - 각 endoser peer에 모두 설치 
docker exec -e CORE_PEER_ADDRESS=peer0.org3.example.com:37051  cli_org3 peer chaincode install -n "$CC_NAME1" -v "$CC_VERSION1" -p "$CC_SRC_PATH1" -l "$CC_RUNTIME_LANGUAGE1"
# endoser peer에서 처음 query 수행하면 인스턴스 생성됨 docker ps -a 해보면
# dev-peer0.org3.example.com-sacc-1.0-xxxx 식의 컨테이너 생성됨
docker exec  peer0.org3.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
sleep 5
docker exec  peer0.org3.example.com peer chaincode invoke  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["set","a","175"]}'
sleep 5
docker exec  peer0.org3.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
echo ==========================================================================
echo install chaincode to peer1.org3.example.com
#install chaincode to peer1.org3.example.com - 각 endoser peer에 모두 설치 
docker exec -e CORE_PEER_ADDRESS=peer1.org3.example.com:38051  cli_org3 peer chaincode install -n "$CC_NAME1" -v "$CC_VERSION1" -p "$CC_SRC_PATH1" -l "$CC_RUNTIME_LANGUAGE1"
# endoser peer에서 처음 query 수행하면 인스턴스 생성됨 docker ps -a 해보면
# dev-peer1.org3.example.com-sacc-1.0-xxxx 식의 컨테이너 생성됨
docker exec  peer1.org3.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
sleep 5
docker exec  peer1.org3.example.com peer chaincode invoke  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["set","a","180"]}'
sleep 5
docker exec  peer1.org3.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
docker exec  peer0.org3.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
docker exec  peer0.org1.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
docker exec  peer0.org2.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
# Org4
echo ====  Org4  ========
echo install chaincode to peer0.org4.example.com
#install chaincode to peer0.org4.example.com - 각 endoser peer에 모두 설치 
docker exec -e CORE_PEER_ADDRESS=peer0.org4.example.com:47051  cli_org4 peer chaincode install -n "$CC_NAME1" -v "$CC_VERSION1" -p "$CC_SRC_PATH1" -l "$CC_RUNTIME_LANGUAGE1"
# endoser peer에서 처음 query 수행하면 인스턴스 생성됨 docker ps -a 해보면
# dev-peer0.org4.example.com-sacc-1.0-xxxx 식의 컨테이너 생성됨
docker exec  peer0.org4.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
sleep 5
docker exec  peer0.org4.example.com peer chaincode invoke  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["set","a","185"]}'
sleep 5
docker exec  peer0.org4.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
echo ==========================================================================
echo install chaincode to peer1.org4.example.com
#install chaincode to peer1.org4.example.com - 각 endoser peer에 모두 설치 
docker exec -e CORE_PEER_ADDRESS=peer1.org4.example.com:48051  cli_org4 peer chaincode install -n "$CC_NAME1" -v "$CC_VERSION1" -p "$CC_SRC_PATH1" -l "$CC_RUNTIME_LANGUAGE1"
# endoser peer에서 처음 query 수행하면 인스턴스 생성됨 docker ps -a 해보면
# dev-peer1.org4.example.com-sacc-1.0-xxxx 식의 컨테이너 생성됨
docker exec  peer1.org4.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
sleep 5
docker exec  peer1.org4.example.com peer chaincode invoke  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["set","a","190"]}'
sleep 5
docker exec  peer1.org4.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
docker exec  peer0.org4.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
docker exec  peer0.org1.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
docker exec  peer0.org2.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
docker exec  peer0.org3.example.com peer chaincode query  -C "$CHANNEL_NAME1" -n "$CC_NAME1" -c '{"Args":["get","a"]}'
cat <<EOF
Total setup execution time : $(($(date +%s) - starttime)) secs ...
EOF
