#!/bin/bash

source scriptUtils.sh

function createjudge() {

  infoln "Enroll the CA admin"
  mkdir -p organizations/peerOrganizations/judge.storage.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/judge.storage.com/
  #  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
  #  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://judgeadmin:judgestorage@localhost:7054 --caname ca-judge --tls.certfiles ${PWD}/organizations/fabric-ca/judge/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-judge.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-judge.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-judge.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-judge.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/judge.storage.com/msp/config.yaml

  infoln "Register peer0"
  set -x
  fabric-ca-client register --caname ca-judge --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/judge/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register user"
  set -x
  fabric-ca-client register --caname ca-judge --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/judge/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register the org admin"
  set -x
  fabric-ca-client register --caname ca-judge --id.name judgejudgeadmin --id.secret judgejudgestorage --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/judge/tls-cert.pem
  { set +x; } 2>/dev/null

  mkdir -p organizations/peerOrganizations/judge.storage.com/peers
  mkdir -p organizations/peerOrganizations/judge.storage.com/peers/peer0.judge.storage.com

  infoln "Generate the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-judge -M ${PWD}/organizations/peerOrganizations/judge.storage.com/peers/peer0.judge.storage.com/msp --csr.hosts peer0.judge.storage.com --tls.certfiles ${PWD}/organizations/fabric-ca/judge/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/judge.storage.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/judge.storage.com/peers/peer0.judge.storage.com/msp/config.yaml

  infoln "Generate the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-judge -M ${PWD}/organizations/peerOrganizations/judge.storage.com/peers/peer0.judge.storage.com/tls --enrollment.profile tls --csr.hosts peer0.judge.storage.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/judge/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/judge.storage.com/peers/peer0.judge.storage.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/judge.storage.com/peers/peer0.judge.storage.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/judge.storage.com/peers/peer0.judge.storage.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/judge.storage.com/peers/peer0.judge.storage.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/judge.storage.com/peers/peer0.judge.storage.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/judge.storage.com/peers/peer0.judge.storage.com/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/judge.storage.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/judge.storage.com/peers/peer0.judge.storage.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/judge.storage.com/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/judge.storage.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/judge.storage.com/peers/peer0.judge.storage.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/judge.storage.com/tlsca/tlsca.judge.storage.com-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/judge.storage.com/ca
  cp ${PWD}/organizations/peerOrganizations/judge.storage.com/peers/peer0.judge.storage.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/judge.storage.com/ca/ca.judge.storage.com-cert.pem

  mkdir -p organizations/peerOrganizations/judge.storage.com/users
  mkdir -p organizations/peerOrganizations/judge.storage.com/users/User1@judge.storage.com

  infoln "Generate the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-judge -M ${PWD}/organizations/peerOrganizations/judge.storage.com/users/User1@judge.storage.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/judge/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/judge.storage.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/judge.storage.com/users/User1@judge.storage.com/msp/config.yaml

  mkdir -p organizations/peerOrganizations/judge.storage.com/users/Admin@judge.storage.com

  infoln "Generate the org admin msp"
  set -x
  fabric-ca-client enroll -u https://judgejudgeadmin:judgejudgestorage@localhost:7054 --caname ca-judge -M ${PWD}/organizations/peerOrganizations/judge.storage.com/users/Admin@judge.storage.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/judge/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/judge.storage.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/judge.storage.com/users/Admin@judge.storage.com/msp/config.yaml

}

function createlawyer() {

  infoln "Enroll the CA admin"
  mkdir -p organizations/peerOrganizations/lawyer.storage.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/lawyer.storage.com/
  #  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
  #  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://lawyeradmin:lawyerstorage@localhost:8054 --caname ca-lawyer --tls.certfiles ${PWD}/organizations/fabric-ca/lawyer/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-lawyer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-lawyer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-lawyer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-lawyer.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/lawyer.storage.com/msp/config.yaml

  infoln "Register peer0"
  set -x
  fabric-ca-client register --caname ca-lawyer --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/lawyer/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register user"
  set -x
  fabric-ca-client register --caname ca-lawyer --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/lawyer/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register the org admin"
  set -x
  fabric-ca-client register --caname ca-lawyer --id.name lawyerlawyeradmin --id.secret lawyerlawyerstorage --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/lawyer/tls-cert.pem
  { set +x; } 2>/dev/null

  mkdir -p organizations/peerOrganizations/lawyer.storage.com/peers
  mkdir -p organizations/peerOrganizations/lawyer.storage.com/peers/peer0.lawyer.storage.com

  infoln "Generate the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-lawyer -M ${PWD}/organizations/peerOrganizations/lawyer.storage.com/peers/peer0.lawyer.storage.com/msp --csr.hosts peer0.lawyer.storage.com --tls.certfiles ${PWD}/organizations/fabric-ca/lawyer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/lawyer.storage.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/lawyer.storage.com/peers/peer0.lawyer.storage.com/msp/config.yaml

  infoln "Generate the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-lawyer -M ${PWD}/organizations/peerOrganizations/lawyer.storage.com/peers/peer0.lawyer.storage.com/tls --enrollment.profile tls --csr.hosts peer0.lawyer.storage.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/lawyer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/lawyer.storage.com/peers/peer0.lawyer.storage.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/lawyer.storage.com/peers/peer0.lawyer.storage.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/lawyer.storage.com/peers/peer0.lawyer.storage.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/lawyer.storage.com/peers/peer0.lawyer.storage.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/lawyer.storage.com/peers/peer0.lawyer.storage.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/lawyer.storage.com/peers/peer0.lawyer.storage.com/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/lawyer.storage.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/lawyer.storage.com/peers/peer0.lawyer.storage.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/lawyer.storage.com/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/lawyer.storage.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/lawyer.storage.com/peers/peer0.lawyer.storage.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/lawyer.storage.com/tlsca/tlsca.lawyer.storage.com-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/lawyer.storage.com/ca
  cp ${PWD}/organizations/peerOrganizations/lawyer.storage.com/peers/peer0.lawyer.storage.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/lawyer.storage.com/ca/ca.lawyer.storage.com-cert.pem

  mkdir -p organizations/peerOrganizations/lawyer.storage.com/users
  mkdir -p organizations/peerOrganizations/lawyer.storage.com/users/User1@lawyer.storage.com

  infoln "Generate the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-lawyer -M ${PWD}/organizations/peerOrganizations/lawyer.storage.com/users/User1@lawyer.storage.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/lawyer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/lawyer.storage.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/lawyer.storage.com/users/User1@lawyer.storage.com/msp/config.yaml

  mkdir -p organizations/peerOrganizations/lawyer.storage.com/users/Admin@lawyer.storage.com

  infoln "Generate the org admin msp"
  set -x
  fabric-ca-client enroll -u https://lawyerlawyeradmin:lawyerlawyerstorage@localhost:8054 --caname ca-lawyer -M ${PWD}/organizations/peerOrganizations/lawyer.storage.com/users/Admin@lawyer.storage.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/lawyer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/lawyer.storage.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/lawyer.storage.com/users/Admin@lawyer.storage.com/msp/config.yaml

}

function createOrderer() {

  infoln "Enroll the CA admin"
  mkdir -p organizations/ordererOrganizations/storage.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/storage.com
  #  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
  #  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/ordererOrganizations/storage.com/msp/config.yaml

  infoln "Register orderer"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register the orderer admin"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  mkdir -p organizations/ordererOrganizations/storage.com/orderers
  mkdir -p organizations/ordererOrganizations/storage.com/orderers/storage.com

  mkdir -p organizations/ordererOrganizations/storage.com/orderers/orderer.storage.com

  infoln "Generate the orderer msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/storage.com/orderers/orderer.storage.com/msp --csr.hosts orderer.storage.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/storage.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/storage.com/orderers/orderer.storage.com/msp/config.yaml

  infoln "Generate the orderer-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/storage.com/orderers/orderer.storage.com/tls --enrollment.profile tls --csr.hosts orderer.storage.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/storage.com/orderers/orderer.storage.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/storage.com/orderers/orderer.storage.com/tls/ca.crt
  cp ${PWD}/organizations/ordererOrganizations/storage.com/orderers/orderer.storage.com/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/storage.com/orderers/orderer.storage.com/tls/server.crt
  cp ${PWD}/organizations/ordererOrganizations/storage.com/orderers/orderer.storage.com/tls/keystore/* ${PWD}/organizations/ordererOrganizations/storage.com/orderers/orderer.storage.com/tls/server.key

  mkdir -p ${PWD}/organizations/ordererOrganizations/storage.com/orderers/orderer.storage.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/storage.com/orderers/orderer.storage.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/storage.com/orderers/orderer.storage.com/msp/tlscacerts/tlsca.storage.com-cert.pem

  mkdir -p ${PWD}/organizations/ordererOrganizations/storage.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/storage.com/orderers/orderer.storage.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/storage.com/msp/tlscacerts/tlsca.storage.com-cert.pem

  mkdir -p organizations/ordererOrganizations/storage.com/users
  mkdir -p organizations/ordererOrganizations/storage.com/users/Admin@storage.com

  infoln "Generate the admin msp"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/storage.com/users/Admin@storage.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/storage.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/storage.com/users/Admin@storage.com/msp/config.yaml

}
