//공공기관, 후원기관 참여 채널4

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
 type Recipient struct {
	Name string `json:"name"`
	Age string `json:"age"`
	Sex string `json:"sex"`
	ID string `json:"id"`
	Address string `json:"address"`
	Job string `json:"job"`
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
	 }else if function == "recipientNonIdent" {
		return s.recipientNonIdent(APIstub, args)
	 }else if function == "queryAllRecipient" {
		return s.queryAllRecipient(APIstub)
	 }else if function == "queryRecipient" {
		 return s.queryRecipient(APIstub, args)
	 }else if function == "cancelApprove" {
		 return s.cancelApprove(APIstub, args)
	 }
	 return shim.Error("Invalid Smart Contract function name.")
 }
 
 /*
  * The initLedger method *
 Will add test data (1 Supporter)to our network
  */
 func (s *SmartContract) initLedger(APIstub shim.ChaincodeStubInterface) sc.Response {
	recipient := []Recipient{
		Recipient{ Name: "김블록", Age:"22", Sex:"M", ID: "990101-1234567", Address: "안양시 에이구",Job:"대학생", Story: "많이 힘들어요.. 제 아가들을 위해 도와주세요", Status:"Y"},
	}
	recipientAsBytes, _ := json.Marshal(recipient[0])
	err := APIstub.PutState("990101-1234567", recipientAsBytes)

	if err != nil {
		return shim.Error(fmt.Sprintf("Failed to initLedger"))
	}
	return shim.Success(nil)
 }
 func (s *SmartContract) recipientNonIdent(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
	var recipient = Recipient{ Name: args[0], Age:args[1], Sex:args[2], ID: args[3], Address: args[4],Job:args[5], Story: args[6], Status: args[7]}

	recipientAsBytes, _ := json.Marshal(recipient)
	err := APIstub.PutState(args[3], recipientAsBytes)
	
	if err != nil {
		return shim.Error(fmt.Sprintf("Failed to register recipient: %s", args[0]))
	}
	return shim.Success(recipientAsBytes)
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
func (s *SmartContract) cancelApprove(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

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
