#!/bin/sh
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
export PATH=$GOPATH/src/github.com/hyperledger/fabric/build/bin:${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}
CHANNEL_NAME=mychannel
CHANNEL_NO1=1
CHANNEL_NAME1=${CHANNEL_NAME}${CHANNEL_NO1}
CHANNEL_NO2=2
CHANNEL_NAME2=${CHANNEL_NAME}${CHANNEL_NO2}
CHANNEL_NO3=3
CHANNEL_NAME3=${CHANNEL_NAME}${CHANNEL_NO3}

# remove previous crypto material and config transactions
rm -fr config/*
rm -fr crypto-config/*

# generate crypto material
cryptogen generate --config=./cryptogen.yaml
if [ "$?" -ne 0 ]; then
  echo "Failed to generate crypto material..."
  exit 1
fi

# generate genesis block for orderer
configtxgen -profile FourOrgsOrdererGenesis -outputBlock ./genesis.block
if [ "$?" -ne 0 ]; then
  echo "Failed to generate orderer genesis block..."
  exit 1
fi

#-------------------------------------------------------------------------
# CH1
#-------------------------------------------------------------------------
# generate channel configuration transaction
configtxgen -profile FourOrgsChannel -outputCreateChannelTx ./channel"$CHANNEL_NO1".tx -channelID $CHANNEL_NAME1
if [ "$?" -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi

# generate anchor peer transaction - Org1
configtxgen -profile FourOrgsChannel -outputAnchorPeersUpdate ./Org1MSPanchors"$CHANNEL_NO1".tx -channelID $CHANNEL_NAME1 -asOrg Org1MSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org1MSP..."
  exit 1
fi
# generate anchor peer transaction - Org2
configtxgen -profile FourOrgsChannel -outputAnchorPeersUpdate ./Org2MSPanchors"$CHANNEL_NO1".tx -channelID $CHANNEL_NAME1 -asOrg Org2MSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org1MSP..."
  exit 1
fi
# generate anchor peer transaction - Org3
configtxgen -profile FourOrgsChannel -outputAnchorPeersUpdate ./Org3MSPanchors"$CHANNEL_NO1".tx -channelID $CHANNEL_NAME1 -asOrg Org3MSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org1MSP..."
  exit 1
fi
# generate anchor peer transaction - Org4
configtxgen -profile FourOrgsChannel -outputAnchorPeersUpdate ./Org4MSPanchors"$CHANNEL_NO1".tx -channelID $CHANNEL_NAME1 -asOrg Org4MSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org1MSP..."
  exit 1
fi
#-------------------------------------------------------------------------
# CH2
#-------------------------------------------------------------------------
# generate channel configuration transaction
configtxgen -profile ThreeOrgChannel -outputCreateChannelTx ./channel"$CHANNEL_NO2".tx -channelID $CHANNEL_NAME2
if [ "$?" -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi

# generate anchor peer transaction - Org1
configtxgen -profile ThreeOrgChannel -outputAnchorPeersUpdate ./config/Org1MSPanchors"$CHANNEL_NO2".tx -channelID $CHANNEL_NAME2 -asOrg Org1MSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org1MSP..."
  exit 1
fi
# generate anchor peer transaction - Org2
configtxgen -profile ThreeOrgChannel -outputAnchorPeersUpdate ./config/Org2MSPanchors"$CHANNEL_NO2".tx -channelID $CHANNEL_NAME2 -asOrg Org2MSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org1MSP..."
  exit 1
fi
# generate anchor peer transaction - Org3
configtxgen -profile ThreeOrgChannel -outputAnchorPeersUpdate ./config/Org3MSPanchors"$CHANNEL_NO2".tx -channelID $CHANNEL_NAME2 -asOrg Org3MSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org1MSP..."
  exit 1
fi
#-------------------------------------------------------------------------
# CH3
#-------------------------------------------------------------------------
# generate channel configuration transaction
configtxgen -profile TwoOrgChannel -outputCreateChannelTx ./config/channel"$CHANNEL_NO3".tx -channelID $CHANNEL_NAME3
if [ "$?" -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi

# generate anchor peer transaction - Org1
configtxgen -profile TwoOrgChannel -outputAnchorPeersUpdate ./config/Org1MSPanchors"$CHANNEL_NO3".tx -channelID $CHANNEL_NAME3 -asOrg Org1MSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org1MSP..."
  exit 1
fi
# generate anchor peer transaction - Org4
configtxgen -profile TwoOrgChannel -outputAnchorPeersUpdate ./config/Org4MSPanchors"$CHANNEL_NO3".tx -channelID $CHANNEL_NAME3 -asOrg Org4MSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org1MSP..."
  exit 1
fi
#=====================

