#!/bin/bash
#
# SPDX-License-Identifier: Apache-2.0
# This code is based on code written by the Hyperledger Fabric community. 
# Original code can be found here: https://github.com/hyperledger/fabric-samples/blob/release/fabcar/startFabric.sh
#
# Exit on first error

set -e

# don't rewrite paths for Windows Git Bash users
export MSYS_NO_PATHCONV=1

starttime=$(date +%s)

if [ ! -d ~/.hfc-key-store/ ]; then
	mkdir ~/.hfc-key-store/
fi

# launch network; create channel and join peer to channel
cd ../basic-network/
./start.sh

# Now launch the CLI container in order to install, instantiate chaincode
# and prime the ledger with our 10 tuna catches
docker-compose -f ./docker-compose.yml up -d cli_GovernmentOrg  cli_SupportingEnterpriseOrg  cli_RecipientOrg  cli_SupporterOrg

echo 4개조직 모두 참여 채널
echo 정부
docker exec -e "CORE_PEER_LOCALMSPID=GovernmentOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/GovernmentOrg.example.com/users/Admin@GovernmentOrg.example.com/msp" cli_GovernmentOrg peer chaincode install -n tuna-app -v 1.0 -p github.com/tuna-app
#채널당 한번만 instantiate
docker exec -e "CORE_PEER_LOCALMSPID=GovernmentOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/GovernmentOrg.example.com/users/Admin@GovernmentOrg.example.com/msp" cli_GovernmentOrg peer chaincode instantiate -o orderer.example.com:7050 -C mychannel1 -n tuna-app -v 1.0 -c '{"Args":[""]}' -P "OR ('GovernmentOrgMSP.member','SupportingEnterpriseMSP.member', 'RecipientMSP.member', 'SupporterMSP.member')"
sleep 10 
docker exec -e "CORE_PEER_LOCALMSPID=GovernmentOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/GovernmentOrg.example.com/users/Admin@GovernmentOrg.example.com/msp" cli_GovernmentOrg peer chaincode invoke -o orderer.example.com:7050 -C mychannel1 -n tuna-app -c '{"function":"initLedger","Args":[""]}'
echo 후원업체
docker exec -e "CORE_PEER_LOCALMSPID=SupportingEnterpriseOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/SupportingEnterpriseOrg.example.com/users/Admin@SupportingEnterpriseOrg.example.com/msp" cli_SupportingEnterpriseOrg peer chaincode install -n tuna-app -v 1.0 -p github.com/tuna-app
docker exec -e "CORE_PEER_LOCALMSPID=SupportingEnterpriseOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/SupportingEnterpriseOrg.example.com/users/Admin@SupportingEnterpriseOrg.example.com/msp" cli_SupportingEnterpriseOrg peer chaincode invoke -o orderer.example.com:7050 -C mychannel1 -n tuna-app -c '{"function":"initLedger","Args":[""]}'
echo 피후원자
docker exec -e "CORE_PEER_LOCALMSPID=RecipientOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/RecipientOrg.example.com/users/Admin@RecipientOrg.example.com/msp" cli_RecipientOrg peer chaincode install -n tuna-app -v 1.0 -p github.com/tuna-app
docker exec -e "CORE_PEER_LOCALMSPID=RecipientOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/RecipientOrg.example.com/users/Admin@RecipientOrg.example.com/msp" cli_RecipientOrg peer chaincode invoke -o orderer.example.com:7050 -C mychannel1 -n tuna-app -c '{"function":"initLedger","Args":[""]}'
echo 후원자
docker exec -e "CORE_PEER_LOCALMSPID=SupporterOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/SupporterOrg.example.com/users/Admin@SupporterOrg.example.com/msp" cli_SupporterOrg peer chaincode install -n tuna-app -v 1.0 -p github.com/tuna-app
docker exec -e "CORE_PEER_LOCALMSPID=SupporterOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/SupporterOrg.example.com/users/Admin@SupporterOrg.example.com/msp" cli_SupporterOrg peer chaincode invoke -o orderer.example.com:7050 -C mychannel1 -n tuna-app -c '{"function":"initLedger","Args":[""]}'

echo 정부, 후원자 조직 참여 채널
echo 정부
docker exec -e "CORE_PEER_LOCALMSPID=GovernmentOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/GovernmentOrg.example.com/users/Admin@GovernmentOrg.example.com/msp" cli_GovernmentOrg peer chaincode install -n tuna-app2 -v 1.0 -p github.com/tuna-app
#채널당 한번만 instantiate
docker exec -e "CORE_PEER_LOCALMSPID=GovernmentOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/GovernmentOrg.example.com/users/Admin@GovernmentOrg.example.com/msp" cli_GovernmentOrg peer chaincode instantiate -o orderer.example.com:7050 -C mychannel2 -n tuna-app2 -v 1.0 -c '{"Args":[""]}'  -P "OR ('GovernmentOrgMSP.member', 'SupporterMSP.member')"
sleep 10 
docker exec -e "CORE_PEER_LOCALMSPID=GovernmentOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/GovernmentOrg.example.com/users/Admin@GovernmentOrg.example.com/msp" cli_GovernmentOrg peer chaincode invoke -o orderer.example.com:7050 -C mychannel2 -n tuna-app2 -c '{"function":"initLedger","Args":[""]}'
echo 후원자
docker exec -e "CORE_PEER_LOCALMSPID=SupporterOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/SupporterOrg.example.com/users/Admin@SupporterOrg.example.com/msp" cli_SupporterOrg peer chaincode install -n tuna-app2 -v 1.0 -p github.com/tuna-app
docker exec -e "CORE_PEER_LOCALMSPID=SupporterOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/SupporterOrg.example.com/users/Admin@SupporterOrg.example.com/msp" cli_SupporterOrg peer chaincode invoke -o orderer.example.com:7050 -C mychannel2 -n tuna-app2 -c '{"function":"initLedger","Args":[""]}'

echo 정부, 피후원자조직 참여 채널
echo 정부
docker exec -e "CORE_PEER_LOCALMSPID=GovernmentOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/GovernmentOrg.example.com/users/Admin@GovernmentOrg.example.com/msp" cli_GovernmentOrg peer chaincode install -n tuna-app3 -v 1.0 -p github.com/tuna-app
#채널당 한번만 instantiate
docker exec -e "CORE_PEER_LOCALMSPID=GovernmentOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/GovernmentOrg.example.com/users/Admin@GovernmentOrg.example.com/msp" cli_GovernmentOrg peer chaincode instantiate -o orderer.example.com:7050 -C mychannel3 -n tuna-app3 -v 1.0 -c '{"Args":[""]}' -P "OR ('GovernmentOrgMSP.member', 'RecipientMSP.member')"
sleep 10 
docker exec -e "CORE_PEER_LOCALMSPID=GovernmentOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/GovernmentOrg.example.com/users/Admin@GovernmentOrg.example.com/msp" cli_GovernmentOrg peer chaincode invoke -o orderer.example.com:7050 -C mychannel3 -n tuna-app3 -c '{"function":"initLedger","Args":[""]}'
echo 피후원자
docker exec -e "CORE_PEER_LOCALMSPID=RecipientOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/RecipientOrg.example.com/users/Admin@RecipientOrg.example.com/msp" cli_RecipientOrg peer chaincode install -n tuna-app3 -v 1.0 -p github.com/tuna-app
docker exec -e "CORE_PEER_LOCALMSPID=RecipientOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/RecipientOrg.example.com/users/Admin@RecipientOrg.example.com/msp" cli_RecipientOrg peer chaincode invoke -o orderer.example.com:7050 -C mychannel3 -n tuna-app3 -c '{"function":"initLedger","Args":[""]}'

echo 정부, 후원업체 모두 참여 채널
echo 정부
docker exec -e "CORE_PEER_LOCALMSPID=GovernmentOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/GovernmentOrg.example.com/users/Admin@GovernmentOrg.example.com/msp" cli_GovernmentOrg peer chaincode install -n tuna-app4 -v 1.0 -p github.com/tuna-app
#채널당 한번만 instantiate
docker exec -e "CORE_PEER_LOCALMSPID=GovernmentOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/GovernmentOrg.example.com/users/Admin@GovernmentOrg.example.com/msp" cli_GovernmentOrg peer chaincode instantiate -o orderer.example.com:7050 -C mychannel4 -n tuna-app4 -v 1.0 -c '{"Args":[""]}' -P "OR ('GovernmentOrgMSP.member', 'SupportingEnterpriseMSP.member')"
sleep 10 
docker exec -e "CORE_PEER_LOCALMSPID=GovernmentOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/GovernmentOrg.example.com/users/Admin@GovernmentOrg.example.com/msp" cli_GovernmentOrg peer chaincode invoke -o orderer.example.com:7050 -C mychannel4 -n tuna-app4 -c '{"function":"initLedger","Args":[""]}'
echo 후원업체
docker exec -e "CORE_PEER_LOCALMSPID=SupportingEnterpriseOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/SupportingEnterpriseOrg.example.com/users/Admin@SupportingEnterpriseOrg.example.com/msp" cli_SupportingEnterpriseOrg peer chaincode install -n tuna-app4 -v 1.0 -p github.com/tuna-app
docker exec -e "CORE_PEER_LOCALMSPID=SupportingEnterpriseOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/SupportingEnterpriseOrg.example.com/users/Admin@SupportingEnterpriseOrg.example.com/msp" cli_SupportingEnterpriseOrg peer chaincode invoke -o orderer.example.com:7050 -C mychannel4 -n tuna-app4 -c '{"function":"initLedger","Args":[""]}'

printf "\nTotal execution time : $(($(date +%s) - starttime)) secs ...\n\n"
printf "\nStart with the registerAdmin.js, then registerUser.js, then server.js\n\n"