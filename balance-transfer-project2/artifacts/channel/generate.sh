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
CHANNEL_NO4=4
CHANNEL_NAME4=${CHANNEL_NAME}${CHANNEL_NO4}

# remove previous crypto material and config transactions
rm -fr config/*
rm -fr crypto-config/*

# generate crypto material
bin/cryptogen generate --config=./cryptogen.yaml
if [ "$?" -ne 0 ]; then
  echo "Failed to generate crypto material..."
  exit 1
fi

# generate genesis block for orderer
bin/configtxgen -profile FourOrgsOrdererGenesis -outputBlock ./genesis.block
if [ "$?" -ne 0 ]; then
  echo "Failed to generate orderer genesis block..."
  exit 1
fi

#-------------------------------------------------------------------------
# CH1 4개 조직
#-------------------------------------------------------------------------
# generate channel configuration transaction
bin/configtxgen -profile FourOrgsChannel -outputCreateChannelTx ./channel"$CHANNEL_NO1".tx -channelID $CHANNEL_NAME1
if [ "$?" -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi

# generate anchor peer transaction - GovernmentOrg
bin/configtxgen -profile FourOrgsChannel -outputAnchorPeersUpdate ./GovernmentOrgMSPanchors"$CHANNEL_NO1".tx -channelID $CHANNEL_NAME1 -asOrg GovernmentOrgMSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for GovernmentOrgMSP..."
  exit 1
fi
# generate anchor peer transaction - SupportingEnterpriseOrg
bin/configtxgen -profile FourOrgsChannel -outputAnchorPeersUpdate ./SupportingEnterpriseOrgMSPanchors"$CHANNEL_NO1".tx -channelID $CHANNEL_NAME1 -asOrg SupportingEnterpriseOrgMSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for GovernmentOrgMSP..."
  exit 1
fi
# generate anchor peer transaction - RecipientOrg
bin/configtxgen -profile FourOrgsChannel -outputAnchorPeersUpdate ./RecipientOrgMSPanchors"$CHANNEL_NO1".tx -channelID $CHANNEL_NAME1 -asOrg RecipientOrgMSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for GovernmentOrgMSP..."
  exit 1
fi
# generate anchor peer transaction - SupporterOrg
bin/configtxgen -profile FourOrgsChannel -outputAnchorPeersUpdate ./SupporterOrgMSPanchors"$CHANNEL_NO1".tx -channelID $CHANNEL_NAME1 -asOrg SupporterOrgMSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for GovernmentOrgMSP..."
  exit 1
fi
#-------------------------------------------------------------------------
# CH2 피후원자+정부
#-------------------------------------------------------------------------
# generate channel configuration transaction
bin/configtxgen -profile RecipientGovernmentOrgsChannel -outputCreateChannelTx ./channel"$CHANNEL_NO2".tx -channelID $CHANNEL_NAME2
if [ "$?" -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi

# generate anchor peer transaction - GovernmentOrg
bin/configtxgen -profile RecipientGovernmentOrgsChannel -outputAnchorPeersUpdate ./GovernmentOrgMSPanchors"$CHANNEL_NO2".tx -channelID $CHANNEL_NAME2 -asOrg GovernmentOrgMSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for GovernmentOrgMSP..."
  exit 1
fi
# generate anchor peer transaction - RecipientOrg
bin/configtxgen -profile RecipientGovernmentOrgsChannel -outputAnchorPeersUpdate ./RecipientOrgMSPanchors"$CHANNEL_NO2".tx -channelID $CHANNEL_NAME2 -asOrg RecipientOrgMSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for GovernmentOrgMSP..."
  exit 1
fi
#-------------------------------------------------------------------------
# CH3 정부+후원업체
#-------------------------------------------------------------------------
# generate channel configuration transaction
bin/configtxgen -profile GovernmentSupportingEnterpriseOrgsChannel -outputCreateChannelTx ./channel"$CHANNEL_NO3".tx -channelID $CHANNEL_NAME3
if [ "$?" -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi

# generate anchor peer transaction - GovernmentOrg
bin/configtxgen -profile GovernmentSupportingEnterpriseOrgsChannel -outputAnchorPeersUpdate ./GovernmentOrgMSPanchors"$CHANNEL_NO3".tx -channelID $CHANNEL_NAME3 -asOrg GovernmentOrgMSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for GovernmentOrgMSP..."
  exit 1
fi
# generate anchor peer transaction - SupporterOrg
bin/configtxgen -profile GovernmentSupportingEnterpriseOrgsChannel -outputAnchorPeersUpdate ./SupportingEnterpriseOrgMSPanchors"$CHANNEL_NO3".tx -channelID $CHANNEL_NAME3 -asOrg SupportingEnterpriseOrgMSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for GovernmentOrgMSP..."
  exit 1
fi
#=====================

#-------------------------------------------------------------------------
# CH4 후원자+정부
#-------------------------------------------------------------------------
# generate channel configuration transaction
bin/configtxgen -profile SupporterGovernmentOrgsChannel -outputCreateChannelTx ./channel"$CHANNEL_NO4".tx -channelID $CHANNEL_NAME4
if [ "$?" -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi

# generate anchor peer transaction - GovernmentOrg
bin/configtxgen -profile SupporterGovernmentOrgsChannel -outputAnchorPeersUpdate ./GovernmentOrgMSPanchors"$CHANNEL_NO4".tx -channelID $CHANNEL_NAME4 -asOrg GovernmentOrgMSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for GovernmentOrgMSP..."
  exit 1
fi
# generate anchor peer transaction - SupporterOrg
bin/configtxgen -profile SupporterGovernmentOrgsChannel -outputAnchorPeersUpdate ./SupporterOrgMSPanchors"$CHANNEL_NO4".tx -channelID $CHANNEL_NAME4 -asOrg SupporterOrgMSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for GovernmentOrgMSP..."
  exit 1
fi
#=====================

