#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error, print all commands.
set -ev
CHANNEL_NAME=mychannel
CHANNEL_NO1=1
CHANNEL_NAME1=${CHANNEL_NAME}${CHANNEL_NO1}
CHANNEL_NO2=2
CHANNEL_NAME2=${CHANNEL_NAME}${CHANNEL_NO2}
CHANNEL_NO3=3
CHANNEL_NAME3=${CHANNEL_NAME}${CHANNEL_NO3}

# don't rewrite paths for Windows Git Bash users
export MSYS_NO_PATHCONV=1

docker-compose -f docker-compose.yaml down
#couchdb1 2 3 4 내가 뺌
docker-compose -f docker-compose.yaml up -d ca.org1.example.com ca.org2.example.com  ca.org3.example.com ca.org4.example.com orderer.example.com peer0.org1.example.com peer1.org1.example.com peer2.org1.example.com peer0.org2.example.com peer1.org2.example.com peer0.org3.example.com peer1.org3.example.com peer0.org4.example.com peer1.org4.example.com

docker ps -a

# wait for Hyperledger Fabric to start
# incase of errors when running later commands, issue export FABRIC_START_TIMEOUT=<larger number>
export FABRIC_START_TIMEOUT=10
#echo ${FABRIC_START_TIMEOUT}
sleep ${FABRIC_START_TIMEOUT}

#===============================================================================
# CH1
#===============================================================================
# Create the channel
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer0.org1.example.com peer channel create -o orderer.example.com:7050 -c "$CHANNEL_NAME1" -f /etc/hyperledger/configtx/channel"$CHANNEL_NO1".tx 
# Org1
# Join peer0.org1.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer0.org1.example.com peer channel join -b "$CHANNEL_NAME1".block

# update  mychannel
docker exec  -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer0.org1.example.com peer channel update -o orderer.example.com:7050 -c "$CHANNEL_NAME1" -f /etc/hyperledger/configtx/Org1MSPanchors"$CHANNEL_NO1".tx 

#fetch
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer1.org1.example.com peer channel fetch 0 "$CHANNEL_NAME1".block --channelID "$CHANNEL_NAME1" --orderer orderer.example.com:7050

# Join peer1.org1.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer1.org1.example.com peer channel join -b "$CHANNEL_NAME1".block

#fetch
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer2.org1.example.com peer channel fetch 0 "$CHANNEL_NAME1".block --channelID "$CHANNEL_NAME1" --orderer orderer.example.com:7050

# Join peer2.org1.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer2.org1.example.com peer channel join -b "$CHANNEL_NAME1".block
# Org2
#fetch
docker exec -e "CORE_PEER_LOCALMSPID=Org2MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org2.example.com/msp" peer0.org2.example.com peer channel fetch 0 "$CHANNEL_NAME1".block --channelID "$CHANNEL_NAME1" --orderer orderer.example.com:7050

# Join peer0.org2.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=Org2MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org2.example.com/msp" peer0.org2.example.com peer channel join -b "$CHANNEL_NAME1".block

# update  mychannel
docker exec  -e "CORE_PEER_LOCALMSPID=Org2MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org2.example.com/msp" peer0.org2.example.com peer channel update -o orderer.example.com:7050 -c "$CHANNEL_NAME1" -f /etc/hyperledger/configtx/Org2MSPanchors"$CHANNEL_NO1".tx 

#fetch
docker exec -e "CORE_PEER_LOCALMSPID=Org2MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org2.example.com/msp" peer1.org2.example.com peer channel fetch 0 "$CHANNEL_NAME1".block --channelID "$CHANNEL_NAME1" --orderer orderer.example.com:7050

# Join peer1.org2.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=Org2MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org2.example.com/msp" peer1.org2.example.com peer channel join -b "$CHANNEL_NAME1".block
# Org3
#fetch
docker exec -e "CORE_PEER_LOCALMSPID=Org3MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org3.example.com/msp" peer0.org3.example.com peer channel fetch 0 "$CHANNEL_NAME1".block --channelID "$CHANNEL_NAME1" --orderer orderer.example.com:7050

# Join peer0.org3.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=Org3MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org3.example.com/msp" peer0.org3.example.com peer channel join -b "$CHANNEL_NAME1".block

# update  mychannel
docker exec  -e "CORE_PEER_LOCALMSPID=Org3MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org3.example.com/msp" peer0.org3.example.com peer channel update -o orderer.example.com:7050 -c "$CHANNEL_NAME1" -f /etc/hyperledger/configtx/Org3MSPanchors"$CHANNEL_NO1".tx 

#fetch
docker exec -e "CORE_PEER_LOCALMSPID=Org3MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org3.example.com/msp" peer1.org3.example.com peer channel fetch 0 "$CHANNEL_NAME1".block --channelID "$CHANNEL_NAME1" --orderer orderer.example.com:7050

# Join peer1.org3.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=Org3MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org3.example.com/msp" peer1.org3.example.com peer channel join -b "$CHANNEL_NAME1".block
# Org4
#fetch
docker exec -e "CORE_PEER_LOCALMSPID=Org4MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org4.example.com/msp" peer0.org4.example.com peer channel fetch 0 "$CHANNEL_NAME1".block --channelID "$CHANNEL_NAME1" --orderer orderer.example.com:7050

# Join peer0.org4.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=Org4MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org4.example.com/msp" peer0.org4.example.com peer channel join -b "$CHANNEL_NAME1".block

# update  mychannel
docker exec  -e "CORE_PEER_LOCALMSPID=Org4MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org4.example.com/msp" peer0.org4.example.com peer channel update -o orderer.example.com:7050 -c "$CHANNEL_NAME1" -f /etc/hyperledger/configtx/Org4MSPanchors"$CHANNEL_NO1".tx 

#fetch
docker exec -e "CORE_PEER_LOCALMSPID=Org4MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org4.example.com/msp" peer1.org4.example.com peer channel fetch 0 "$CHANNEL_NAME1".block --channelID "$CHANNEL_NAME1" --orderer orderer.example.com:7050

# Join peer1.org4.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=Org4MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org4.example.com/msp" peer1.org4.example.com peer channel join -b "$CHANNEL_NAME1".block

#===============================================================================
# CH2
#===============================================================================
# Create the channel
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer0.org1.example.com peer channel create -o orderer.example.com:7050 -c "$CHANNEL_NAME2" -f /etc/hyperledger/configtx/channel"$CHANNEL_NO2".tx 
# Org1
# Join peer0.org1.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer0.org1.example.com peer channel join -b "$CHANNEL_NAME2".block

# update  mychannel
docker exec  -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer0.org1.example.com peer channel update -o orderer.example.com:7050 -c "$CHANNEL_NAME2" -f /etc/hyperledger/configtx/Org1MSPanchors"$CHANNEL_NO2".tx 

#fetch
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer1.org1.example.com peer channel fetch 0 "$CHANNEL_NAME2".block --channelID "$CHANNEL_NAME2" --orderer orderer.example.com:7050

# Join peer1.org1.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer1.org1.example.com peer channel join -b "$CHANNEL_NAME2".block

#fetch
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer2.org1.example.com peer channel fetch 0 "$CHANNEL_NAME2".block --channelID "$CHANNEL_NAME2" --orderer orderer.example.com:7050

# Join peer2.org1.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer2.org1.example.com peer channel join -b "$CHANNEL_NAME2".block
# Org2
#fetch
docker exec -e "CORE_PEER_LOCALMSPID=Org2MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org2.example.com/msp" peer0.org2.example.com peer channel fetch 0 "$CHANNEL_NAME2".block --channelID "$CHANNEL_NAME2" --orderer orderer.example.com:7050

# Join peer0.org2.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=Org2MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org2.example.com/msp" peer0.org2.example.com peer channel join -b "$CHANNEL_NAME2".block

# update  mychannel
docker exec  -e "CORE_PEER_LOCALMSPID=Org2MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org2.example.com/msp" peer0.org2.example.com peer channel update -o orderer.example.com:7050 -c "$CHANNEL_NAME2" -f /etc/hyperledger/configtx/Org2MSPanchors"$CHANNEL_NO2".tx 

#fetch
docker exec -e "CORE_PEER_LOCALMSPID=Org2MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org2.example.com/msp" peer1.org2.example.com peer channel fetch 0 "$CHANNEL_NAME2".block --channelID "$CHANNEL_NAME2" --orderer orderer.example.com:7050

# Join peer1.org2.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=Org2MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org2.example.com/msp" peer1.org2.example.com peer channel join -b "$CHANNEL_NAME2".block
# Org3
#fetch
docker exec -e "CORE_PEER_LOCALMSPID=Org3MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org3.example.com/msp" peer0.org3.example.com peer channel fetch 0 "$CHANNEL_NAME2".block --channelID "$CHANNEL_NAME2" --orderer orderer.example.com:7050

# Join peer0.org3.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=Org3MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org3.example.com/msp" peer0.org3.example.com peer channel join -b "$CHANNEL_NAME2".block

# update  mychannel
docker exec  -e "CORE_PEER_LOCALMSPID=Org3MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org3.example.com/msp" peer0.org3.example.com peer channel update -o orderer.example.com:7050 -c "$CHANNEL_NAME2" -f /etc/hyperledger/configtx/Org3MSPanchors"$CHANNEL_NO2".tx 

#fetch
docker exec -e "CORE_PEER_LOCALMSPID=Org3MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org3.example.com/msp" peer1.org3.example.com peer channel fetch 0 "$CHANNEL_NAME2".block --channelID "$CHANNEL_NAME2" --orderer orderer.example.com:7050

# Join peer1.org3.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=Org3MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org3.example.com/msp" peer1.org3.example.com peer channel join -b "$CHANNEL_NAME2".block

#===============================================================================
# CH3
#===============================================================================
# Create the channel
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer0.org1.example.com peer channel create -o orderer.example.com:7050 -c "$CHANNEL_NAME3" -f /etc/hyperledger/configtx/channel"$CHANNEL_NO3".tx 
# Org1
# Join peer0.org1.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer0.org1.example.com peer channel join -b "$CHANNEL_NAME3".block

# update  mychannel
docker exec  -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer0.org1.example.com peer channel update -o orderer.example.com:7050 -c "$CHANNEL_NAME3" -f /etc/hyperledger/configtx/Org1MSPanchors"$CHANNEL_NO3".tx 

#fetch
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer1.org1.example.com peer channel fetch 0 "$CHANNEL_NAME3".block --channelID "$CHANNEL_NAME3" --orderer orderer.example.com:7050

# Join peer1.org1.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer1.org1.example.com peer channel join -b "$CHANNEL_NAME3".block

#fetch
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer2.org1.example.com peer channel fetch 0 "$CHANNEL_NAME3".block --channelID "$CHANNEL_NAME3" --orderer orderer.example.com:7050

# Join peer2.org1.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer2.org1.example.com peer channel join -b "$CHANNEL_NAME3".block

# Org4
#fetch
docker exec -e "CORE_PEER_LOCALMSPID=Org4MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org4.example.com/msp" peer0.org4.example.com peer channel fetch 0 "$CHANNEL_NAME3".block --channelID "$CHANNEL_NAME3" --orderer orderer.example.com:7050

# Join peer0.org4.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=Org4MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org4.example.com/msp" peer0.org4.example.com peer channel join -b "$CHANNEL_NAME3".block

# update  mychannel
docker exec  -e "CORE_PEER_LOCALMSPID=Org4MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org4.example.com/msp" peer0.org4.example.com peer channel update -o orderer.example.com:7050 -c "$CHANNEL_NAME3" -f /etc/hyperledger/configtx/Org4MSPanchors"$CHANNEL_NO3".tx 

#fetch
docker exec -e "CORE_PEER_LOCALMSPID=Org4MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org4.example.com/msp" peer1.org4.example.com peer channel fetch 0 "$CHANNEL_NAME3".block --channelID "$CHANNEL_NAME3" --orderer orderer.example.com:7050

# Join peer1.org4.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=Org4MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org4.example.com/msp" peer1.org4.example.com peer channel join -b "$CHANNEL_NAME3".block