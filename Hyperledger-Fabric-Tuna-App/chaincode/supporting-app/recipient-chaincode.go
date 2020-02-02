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
 type Recipient struct {
	Name string `json:"name"`
	ID string `json:"id"`
	Email string `json:"email"`
	Password string `json:"password"`
	Address string `json:"address"`
	PhoneNum string `json:"phoneNum"`
	Story string `json:"story"`
	Status string `json:"status"`
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
	 } else if function == "registerRecipient" { //피후원자 등록
		 return s.registerRecipient(APIstub, args)
	 } else if function == "queryAllRecipient" { //피후원자 조회
		 return s.queryAllRecipient(APIstub)
	 } else if function == "queryRecipient" {	// 내 정보 조회(피후원자)
		return s.queryRecipient(APIstub, args)
	 } else if function == "approveRecipient" {
		 return s.approveRecipient(APIstub, args)
	 } else if function == "changeRecipientInfo"{ // 내 정보 수정 (피후원자)
		 return s.changeRecipientInfo(APIstub, args)
	 }
 
	 return shim.Error("Invalid Smart Contract function name.")
 }
 

 /*
  * The initLedger method *
 Will add test data (1 Supporter)to our network
  */
 func (s *SmartContract) initLedger(APIstub shim.ChaincodeStubInterface) sc.Response {
	recipient := []Recipient{
		Recipient{Name: "김철수", ID: "6001012234560", Email: "kim@gmail.com", Password: "1ARVn2Auq2/WAqx2gNrL+q3RNjAzXpUfCXrzkA6d4Xa22yhRLy4AC50E+6UTPoscbo31nbOoq51gvkuXzJ6B2w==", Address: "서울 살아욤", PhoneNum: "01044441234", Story: "제 아이가 많이 힘듭니다. 저는 장애3급 판정을 받았습니다..", Status: "N"},
		Recipient{Name: "김영희", ID: "9901011234567", Email: "young@gmail.com", Password: "1ARVn2Auq2/WAqx2gNrL+q3RNjAzXpUfCXrzkA6d4Xa22yhRLy4AC50E+6UTPoscbo31nbOoq51gvkuXzJ6B2w==",Address: "경기도 살아욤", PhoneNum: "01012341234", Story: "많이 힘들어요.. 제 아가들을 위해 도와주세요", Status: "Y"},
	}

	recipientAsBytes, _ := json.Marshal(recipient[0])
	APIstub.PutState("6001012234560", recipientAsBytes)
	recipientAsBytes, _ = json.Marshal(recipient[1])
	APIstub.PutState("9901011234567", recipientAsBytes)

	return shim.Success(nil) 
 }
 
 /*
  * The registerRecipient method *
 This method takes in seven arguments (attributes to be saved in the ledger). 
  */
 func (s *SmartContract) registerRecipient(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
 
 
	var recipient = Recipient{ Name: args[0], ID: args[1], Email: args[2], Password: args[3], Address: args[4], PhoneNum: args[5], Story: args[6], Status: args[7] }

	recipientAsBytes, _ := json.Marshal(recipient)
	err := APIstub.PutState(args[1], recipientAsBytes)
	
	if err != nil {
		return shim.Error(fmt.Sprintf("Failed to register recipient: %s", args[0]))
	}

	return shim.Success(nil)

 }

 func (s *SmartContract) queryAllRecipient(APIstub shim.ChaincodeStubInterface) sc.Response {

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

	fmt.Printf("- queryAllRecipient:\n%s\n", buffer.String())

	return shim.Success(buffer.Bytes())
}
func (s *SmartContract) queryRecipient(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	recipientAsBytes, _ := APIstub.GetState(args[0])
	if recipientAsBytes == nil {
		return shim.Error("Could not locate recipient")
	}
	return shim.Success(recipientAsBytes)
	
}
// 피후원자 승인 등록
func (s *SmartContract) approveRecipient(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2")
	}

	recipientAsBytes, _ := APIstub.GetState(args[0])
	if recipientAsBytes == nil {
		return shim.Error("Could not locate recipient")
	}
	recipient := Recipient{}

	json.Unmarshal(recipientAsBytes, &recipient)
	// Normally check that the specified argument is a valid holder of tuna
	// we are skipping this check for this example
	recipient.Status = args[1]

	recipientAsBytes, _ = json.Marshal(recipient)
	err := APIstub.PutState(args[0], recipientAsBytes)
	if err != nil {
		return shim.Error(fmt.Sprintf("Failed to approve recipient: %s", args[0]))
	}

	return shim.Success(nil)
}
//내 정보 수정(피후원자)
func (s *SmartContract) changeRecipientInfo(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 8 {
		return shim.Error("Incorrect number of arguments. Expecting 8")
	}

	userRecipientAsBytes, _ := APIstub.GetState(args[0])
	if userRecipientAsBytes == nil {
		return shim.Error("Could not locate Recipient")
	}
	userRecipient := Recipient{}

	json.Unmarshal(userRecipientAsBytes, &userRecipient)
	// Normally check that the specified argument is a valid holder of tuna
	// we are skipping this check for this example
	userRecipient.ID = args[0]
	userRecipient.Name = args[1]
	userRecipient.Email = args[2]
	userRecipient.Password = args[3]
	userRecipient.Address = args[4]
	userRecipient.PhoneNum = args[5]
	userRecipient.Story = args[6]
	userRecipient.Status = args[7]

	userRecipientAsBytes, _ = json.Marshal(userRecipient)
	err := APIstub.PutState(args[0], userRecipientAsBytes)
	if err != nil {
		return shim.Error(fmt.Sprintf("Failed to change user's personal info(Recipient)"))
	}

	return shim.Success(nil)
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
