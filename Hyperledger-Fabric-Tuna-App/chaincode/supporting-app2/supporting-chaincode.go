// SPDX-License-Identifier: Apache-2.0

/*
  Sample Chaincode based on Demonstrated Scenario
 This code is based on code written by the Hyperledger Fabric community.
  Original code can be found here: https://github.com/hyperledger/fabric-samples/blob/release/chaincode/fabcar/fabcar.go
 */

 package main

 /* Imports  
 * 4 utility libraries for handling bytes, reading and writing JSON, 
 formatting, and string manipulation  
 * 2 specific Hyperledger Fabric specific libraries for Smart Contracts  
 */ 
 import (
	 "bytes"
	 "encoding/json"
	 "fmt"
 
	 "github.com/hyperledger/fabric/core/chaincode/shim"
	 sc "github.com/hyperledger/fabric/protos/peer"
 )
 
 // Define the Smart Contract structure
 type SmartContract struct {
 }
 
 /* Define Supporter structure, with 6 properties.  
 Structure tags are used by encoding/json library
 */
 type Supporter struct {
	 Name string `json:"name"`
	 ID string `json:"id"`
	 Email  string `json:"email"`
	 Password  string `json:"pw"`
	 Address string `json:"address"`
	 PhoneNum string `json:"phoneNum"`
 }
 
 /*
  * The Init method *
  called when the Smart Contract "tuna-chaincode" is instantiated by the network
  * Best practice is to have any Ledger initialization in separate function 
  -- see initLedger()
  */
 func (s *SmartContract) Init(APIstub shim.ChaincodeStubInterface) sc.Response {
	 return shim.Success(nil)
 }
 
 /*
  * The Invoke method *
  called when an application requests to run the Smart Contract "supporting-chaincode"
  The app also specifies the specific smart contract function to call with args
  */
 func (s *SmartContract) Invoke(APIstub shim.ChaincodeStubInterface) sc.Response {
 
	 // Retrieve the requested Smart Contract function and arguments
	 function, args := APIstub.GetFunctionAndParameters()
	 // Route to the appropriate handler function to interact with the ledger
	 if function == "initLedger" {
		 return s.initLedger(APIstub)
	 } else if function == "registerSupporter" { //후원자 등록
		 return s.registerSupporter(APIstub, args)
	 } else if function == "queryAllSupporter" { //후원자 조회
		 return s.queryAllSupporter(APIstub)
	 }
 
	 return shim.Error("Invalid Smart Contract function name.")
 }
 

 /*
  * The initLedger method *
 Will add test data (1 Supporter)to our network
  */
 func (s *SmartContract) initLedger(APIstub shim.ChaincodeStubInterface) sc.Response {
	 supporter := []Supporter{
		 Supporter{Name:"Soyoung Yoo", ID:"123456", Email:"ysy@naver.com", Password:"1ARVn2Auq2/WAqx2gNrL+q3RNjAzXpUfCXrzkA6d4Xa22yhRLy4AC50E+6UTPoscbo31nbOoq51gvkuXzJ6B2w==", Address:"Seoul", PhoneNum:"01089145587"},
	 }
 
	supporterAsBytes, _ := json.Marshal(supporter[0])
	APIstub.PutState("123456", supporterAsBytes)

	 return shim.Success(nil)
 }
 
 /*
  * The registerSupporter method *
 This method takes in seven arguments (attributes to be saved in the ledger). 
  */
 func (s *SmartContract) registerSupporter(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
 
 
	var supporter = Supporter{ Name: args[0], ID: args[1], Email: args[2], Password: args[3], Address: args[4], PhoneNum: args[5] }

	supporterAsBytes, _ := json.Marshal(supporter)
	err := APIstub.PutState(args[1], supporterAsBytes)
	if err != nil {
		return shim.Error(fmt.Sprintf("Failed to register supporter: %s", args[0]))
	}

	return shim.Success(nil)

 }

 func (s *SmartContract) queryAllSupporter(APIstub shim.ChaincodeStubInterface) sc.Response {

	startKey := "0"
	endKey := "999"

	resultsIterator, err := APIstub.GetStateByRange(startKey, endKey)
	if err != nil {
		return shim.Error(err.Error())
	}
	defer resultsIterator.Close()

	// buffer is a JSON array containing QueryResults
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return shim.Error(err.Error())
		}
		// Add comma before array members,suppress it for the first array member
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"Key\":")
		buffer.WriteString("\"")
		buffer.WriteString(queryResponse.Key)
		buffer.WriteString("\"")

		buffer.WriteString(", \"Record\":")
		// Record is a JSON object, so we write as-is
		buffer.WriteString(string(queryResponse.Value))
		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	fmt.Printf("- querySupporter:\n%s\n", buffer.String())

	return shim.Success(buffer.Bytes())
}

 
 /*
  * main function *
 calls the Start function 
 The main function starts the chaincode in the container during instantiation.
  */
 func main() {
 
	 // Create a new Smart Contract
	 err := shim.Start(new(SmartContract))
	 if err != nil {
		 fmt.Printf("Error creating new Smart Contract: %s", err)
	 }
 }