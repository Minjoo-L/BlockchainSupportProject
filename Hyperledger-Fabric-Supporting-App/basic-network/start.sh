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
CHANNEL_NO4=4
CHANNEL_NAME4=${CHANNEL_NAME}${CHANNEL_NO4}

# don't rewrite paths for Windows Git Bash users
export MSYS_NO_PATHCONV=1

docker-compose -f docker-compose.yml down --remove-orphans

docker-compose -f docker-compose.yml up -d ca.GovernmentOrg.example.com ca.SupportingEnterpriseOrg.example.com  ca.RecipientOrg.example.com  ca.SupporterOrg.example.com orderer.example.com peer0.GovernmentOrg.example.com peer1.GovernmentOrg.example.com couchdb1 peer0.SupportingEnterpriseOrg.example.com peer1.SupportingEnterpriseOrg.example.com couchdb2 peer0.RecipientOrg.example.com peer1.RecipientOrg.example.com couchdb3 peer0.SupporterOrg.example.com peer1.SupporterOrg.example.com couchdb4 cli_GovernmentOrg  cli_SupportingEnterpriseOrg  cli_RecipientOrg  cli_SupporterOrg

docker ps -a

# wait for Hyperledger Fabric to start
# incase of errors when running later commands, issue export FABRIC_START_TIMEOUT=<larger number>
export FABRIC_START_TIMEOUT=10
#echo ${FABRIC_START_TIMEOUT}
sleep ${FABRIC_START_TIMEOUT}

#===============================================================================
# CH1 4개조직
#===============================================================================
# Create the channel
docker exec -e "CORE_PEER_LOCALMSPID=GovernmentOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@GovernmentOrg.example.com/msp" peer0.GovernmentOrg.example.com peer channel create -o orderer.example.com:7050 -c "$CHANNEL_NAME1" -f /etc/hyperledger/configtx/channel"$CHANNEL_NO1".tx 
# GovernmentOrg
# Join peer0.GovernmentOrg.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=GovernmentOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@GovernmentOrg.example.com/msp" peer0.GovernmentOrg.example.com peer channel join -b "$CHANNEL_NAME1".block

# update  mychannel
docker exec  -e "CORE_PEER_LOCALMSPID=GovernmentOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@GovernmentOrg.example.com/msp" peer0.GovernmentOrg.example.com peer channel update -o orderer.example.com:7050 -c "$CHANNEL_NAME1" -f /etc/hyperledger/configtx/GovernmentOrgMSPanchors"$CHANNEL_NO1".tx 

#fetch
docker exec -e "CORE_PEER_LOCALMSPID=GovernmentOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@GovernmentOrg.example.com/msp" peer1.GovernmentOrg.example.com peer channel fetch 0 "$CHANNEL_NAME1".block --channelID "$CHANNEL_NAME1" --orderer orderer.example.com:7050

# Join peer1.GovernmentOrg.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=GovernmentOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@GovernmentOrg.example.com/msp" peer1.GovernmentOrg.example.com peer channel join -b "$CHANNEL_NAME1".block

# SupportingEnterpriseOrg
#fetch
docker exec -e "CORE_PEER_LOCALMSPID=SupportingEnterpriseOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@SupportingEnterpriseOrg.example.com/msp" peer0.SupportingEnterpriseOrg.example.com peer channel fetch 0 "$CHANNEL_NAME1".block --channelID "$CHANNEL_NAME1" --orderer orderer.example.com:7050

# Join peer0.SupportingEnterpriseOrg.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=SupportingEnterpriseOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@SupportingEnterpriseOrg.example.com/msp" peer0.SupportingEnterpriseOrg.example.com peer channel join -b "$CHANNEL_NAME1".block

# update  mychannel
docker exec  -e "CORE_PEER_LOCALMSPID=SupportingEnterpriseOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@SupportingEnterpriseOrg.example.com/msp" peer0.SupportingEnterpriseOrg.example.com peer channel update -o orderer.example.com:7050 -c "$CHANNEL_NAME1" -f /etc/hyperledger/configtx/SupportingEnterpriseOrgMSPanchors"$CHANNEL_NO1".tx 

#fetch
docker exec -e "CORE_PEER_LOCALMSPID=SupportingEnterpriseOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@SupportingEnterpriseOrg.example.com/msp" peer1.SupportingEnterpriseOrg.example.com peer channel fetch 0 "$CHANNEL_NAME1".block --channelID "$CHANNEL_NAME1" --orderer orderer.example.com:7050

# Join peer1.SupportingEnterpriseOrg.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=SupportingEnterpriseOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@SupportingEnterpriseOrg.example.com/msp" peer1.SupportingEnterpriseOrg.example.com peer channel join -b "$CHANNEL_NAME1".block
# RecipientOrg
#fetch
docker exec -e "CORE_PEER_LOCALMSPID=RecipientOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@RecipientOrg.example.com/msp" peer0.RecipientOrg.example.com peer channel fetch 0 "$CHANNEL_NAME1".block --channelID "$CHANNEL_NAME1" --orderer orderer.example.com:7050

# Join peer0.RecipientOrg.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=RecipientOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@RecipientOrg.example.com/msp" peer0.RecipientOrg.example.com peer channel join -b "$CHANNEL_NAME1".block

# update  mychannel
docker exec  -e "CORE_PEER_LOCALMSPID=RecipientOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@RecipientOrg.example.com/msp" peer0.RecipientOrg.example.com peer channel update -o orderer.example.com:7050 -c "$CHANNEL_NAME1" -f /etc/hyperledger/configtx/RecipientOrgMSPanchors"$CHANNEL_NO1".tx 

#fetch
docker exec -e "CORE_PEER_LOCALMSPID=RecipientOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@RecipientOrg.example.com/msp" peer1.RecipientOrg.example.com peer channel fetch 0 "$CHANNEL_NAME1".block --channelID "$CHANNEL_NAME1" --orderer orderer.example.com:7050

# Join peer1.RecipientOrg.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=RecipientOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@RecipientOrg.example.com/msp" peer1.RecipientOrg.example.com peer channel join -b "$CHANNEL_NAME1".block
# SupporterOrg
#fetch
docker exec -e "CORE_PEER_LOCALMSPID=SupporterOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@SupporterOrg.example.com/msp" peer0.SupporterOrg.example.com peer channel fetch 0 "$CHANNEL_NAME1".block --channelID "$CHANNEL_NAME1" --orderer orderer.example.com:7050

# Join peer0.SupporterOrg.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=SupporterOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@SupporterOrg.example.com/msp" peer0.SupporterOrg.example.com peer channel join -b "$CHANNEL_NAME1".block

# update  mychannel
docker exec  -e "CORE_PEER_LOCALMSPID=SupporterOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@SupporterOrg.example.com/msp" peer0.SupporterOrg.example.com peer channel update -o orderer.example.com:7050 -c "$CHANNEL_NAME1" -f /etc/hyperledger/configtx/SupporterOrgMSPanchors"$CHANNEL_NO1".tx 

#fetch
docker exec -e "CORE_PEER_LOCALMSPID=SupporterOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@SupporterOrg.example.com/msp" peer1.SupporterOrg.example.com peer channel fetch 0 "$CHANNEL_NAME1".block --channelID "$CHANNEL_NAME1" --orderer orderer.example.com:7050

# Join peer1.SupporterOrg.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=SupporterOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@SupporterOrg.example.com/msp" peer1.SupporterOrg.example.com peer channel join -b "$CHANNEL_NAME1".block

#===============================================================================
# CH2 공공기관+후원자
#===============================================================================
# Create the channel
docker exec -e "CORE_PEER_LOCALMSPID=GovernmentOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@GovernmentOrg.example.com/msp" peer0.GovernmentOrg.example.com peer channel create -o orderer.example.com:7050 -c "$CHANNEL_NAME2" -f /etc/hyperledger/configtx/channel"$CHANNEL_NO2".tx 
# GovernmentOrg
# Join peer0.GovernmentOrg.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=GovernmentOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@GovernmentOrg.example.com/msp" peer0.GovernmentOrg.example.com peer channel join -b "$CHANNEL_NAME2".block

# update  mychannel
docker exec  -e "CORE_PEER_LOCALMSPID=GovernmentOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@GovernmentOrg.example.com/msp" peer0.GovernmentOrg.example.com peer channel update -o orderer.example.com:7050 -c "$CHANNEL_NAME2" -f /etc/hyperledger/configtx/GovernmentOrgMSPanchors"$CHANNEL_NO2".tx 

#fetch
docker exec -e "CORE_PEER_LOCALMSPID=GovernmentOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@GovernmentOrg.example.com/msp" peer1.GovernmentOrg.example.com peer channel fetch 0 "$CHANNEL_NAME2".block --channelID "$CHANNEL_NAME2" --orderer orderer.example.com:7050

# Join peer1.GovernmentOrg.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=GovernmentOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@GovernmentOrg.example.com/msp" peer1.GovernmentOrg.example.com peer channel join -b "$CHANNEL_NAME2".block

# SupporterOrg
#fetch
docker exec -e "CORE_PEER_LOCALMSPID=SupporterOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@SupporterOrg.example.com/msp" peer0.SupporterOrg.example.com peer channel fetch 0 "$CHANNEL_NAME2".block --channelID "$CHANNEL_NAME2" --orderer orderer.example.com:7050

# Join peer0.SupporterOrg.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=SupporterOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@SupporterOrg.example.com/msp" peer0.SupporterOrg.example.com peer channel join -b "$CHANNEL_NAME2".block

# update  mychannel
docker exec  -e "CORE_PEER_LOCALMSPID=SupporterOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@SupporterOrg.example.com/msp" peer0.SupporterOrg.example.com peer channel update -o orderer.example.com:7050 -c "$CHANNEL_NAME2" -f /etc/hyperledger/configtx/SupporterOrgMSPanchors"$CHANNEL_NO2".tx 

#fetch
docker exec -e "CORE_PEER_LOCALMSPID=SupporterOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@SupporterOrg.example.com/msp" peer1.SupporterOrg.example.com peer channel fetch 0 "$CHANNEL_NAME2".block --channelID "$CHANNEL_NAME2" --orderer orderer.example.com:7050

# Join peer1.SupporterOrg.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=SupporterOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@SupporterOrg.example.com/msp" peer1.SupporterOrg.example.com peer channel join -b "$CHANNEL_NAME2".block

#===============================================================================
# CH3 공공기관 피후원자
#===============================================================================
# Create the channel
docker exec -e "CORE_PEER_LOCALMSPID=GovernmentOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@GovernmentOrg.example.com/msp" peer0.GovernmentOrg.example.com peer channel create -o orderer.example.com:7050 -c "$CHANNEL_NAME3" -f /etc/hyperledger/configtx/channel"$CHANNEL_NO3".tx 
# GovernmentOrg
# Join peer0.GovernmentOrg.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=GovernmentOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@GovernmentOrg.example.com/msp" peer0.GovernmentOrg.example.com peer channel join -b "$CHANNEL_NAME3".block

# update  mychannel
docker exec  -e "CORE_PEER_LOCALMSPID=GovernmentOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@GovernmentOrg.example.com/msp" peer0.GovernmentOrg.example.com peer channel update -o orderer.example.com:7050 -c "$CHANNEL_NAME3" -f /etc/hyperledger/configtx/GovernmentOrgMSPanchors"$CHANNEL_NO3".tx 

#fetch
docker exec -e "CORE_PEER_LOCALMSPID=GovernmentOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@GovernmentOrg.example.com/msp" peer1.GovernmentOrg.example.com peer channel fetch 0 "$CHANNEL_NAME3".block --channelID "$CHANNEL_NAME3" --orderer orderer.example.com:7050

# Join peer1.GovernmentOrg.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=GovernmentOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@GovernmentOrg.example.com/msp" peer1.GovernmentOrg.example.com peer channel join -b "$CHANNEL_NAME3".block

# RecipientOrg
#fetch
docker exec -e "CORE_PEER_LOCALMSPID=RecipientOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@RecipientOrg.example.com/msp" peer0.RecipientOrg.example.com peer channel fetch 0 "$CHANNEL_NAME3".block --channelID "$CHANNEL_NAME3" --orderer orderer.example.com:7050

# Join peer0.RecipientOrg.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=RecipientOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@RecipientOrg.example.com/msp" peer0.RecipientOrg.example.com peer channel join -b "$CHANNEL_NAME3".block

# update  mychannel
docker exec  -e "CORE_PEER_LOCALMSPID=RecipientOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@RecipientOrg.example.com/msp" peer0.RecipientOrg.example.com peer channel update -o orderer.example.com:7050 -c "$CHANNEL_NAME3" -f /etc/hyperledger/configtx/RecipientOrgMSPanchors"$CHANNEL_NO3".tx 

#fetch
docker exec -e "CORE_PEER_LOCALMSPID=RecipientOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@RecipientOrg.example.com/msp" peer1.RecipientOrg.example.com peer channel fetch 0 "$CHANNEL_NAME3".block --channelID "$CHANNEL_NAME3" --orderer orderer.example.com:7050

# Join peer1.RecipientOrg.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=RecipientOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@RecipientOrg.example.com/msp" peer1.RecipientOrg.example.com peer channel join -b "$CHANNEL_NAME3".block

#===============================================================================
# CH4 공공기관 후원업체
#===============================================================================
# Create the channel
docker exec -e "CORE_PEER_LOCALMSPID=GovernmentOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@GovernmentOrg.example.com/msp" peer0.GovernmentOrg.example.com peer channel create -o orderer.example.com:7050 -c "$CHANNEL_NAME4" -f /etc/hyperledger/configtx/channel"$CHANNEL_NO4".tx 
# GovernmentOrg
# Join peer0.GovernmentOrg.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=GovernmentOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@GovernmentOrg.example.com/msp" peer0.GovernmentOrg.example.com peer channel join -b "$CHANNEL_NAME4".block

# update  mychannel
docker exec  -e "CORE_PEER_LOCALMSPID=GovernmentOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@GovernmentOrg.example.com/msp" peer0.GovernmentOrg.example.com peer channel update -o orderer.example.com:7050 -c "$CHANNEL_NAME4" -f /etc/hyperledger/configtx/GovernmentOrgMSPanchors"$CHANNEL_NO4".tx 

#fetch
docker exec -e "CORE_PEER_LOCALMSPID=GovernmentOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@GovernmentOrg.example.com/msp" peer1.GovernmentOrg.example.com peer channel fetch 0 "$CHANNEL_NAME4".block --channelID "$CHANNEL_NAME4" --orderer orderer.example.com:7050

# Join peer1.GovernmentOrg.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=GovernmentOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@GovernmentOrg.example.com/msp" peer1.GovernmentOrg.example.com peer channel join -b "$CHANNEL_NAME4".block

# SupportingEnterpriseOrg
#fetch
docker exec -e "CORE_PEER_LOCALMSPID=SupportingEnterpriseOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@SupportingEnterpriseOrg.example.com/msp" peer0.SupportingEnterpriseOrg.example.com peer channel fetch 0 "$CHANNEL_NAME4".block --channelID "$CHANNEL_NAME4" --orderer orderer.example.com:7050

# Join peer0.SupportingEnterpriseOrg.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=SupportingEnterpriseOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@SupportingEnterpriseOrg.example.com/msp" peer0.SupportingEnterpriseOrg.example.com peer channel join -b "$CHANNEL_NAME4".block

# update  mychannel
docker exec  -e "CORE_PEER_LOCALMSPID=SupportingEnterpriseOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@SupportingEnterpriseOrg.example.com/msp" peer0.SupportingEnterpriseOrg.example.com peer channel update -o orderer.example.com:7050 -c "$CHANNEL_NAME4" -f /etc/hyperledger/configtx/SupportingEnterpriseOrgMSPanchors"$CHANNEL_NO4".tx 

#fetch
docker exec -e "CORE_PEER_LOCALMSPID=SupportingEnterpriseOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@SupportingEnterpriseOrg.example.com/msp" peer1.SupportingEnterpriseOrg.example.com peer channel fetch 0 "$CHANNEL_NAME4".block --channelID "$CHANNEL_NAME4" --orderer orderer.example.com:7050

# Join peer1.SupportingEnterpriseOrg.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=SupportingEnterpriseOrgMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@SupportingEnterpriseOrg.example.com/msp" peer1.SupportingEnterpriseOrg.example.com peer channel join -b "$CHANNEL_NAME4".block