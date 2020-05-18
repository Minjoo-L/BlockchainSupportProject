//공공기관, 후원자 조직 참여 채널2

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

 // 후원자
 type Supporter struct {
	 Name string `json:"name"`
	 ID string `json:"id"`
	 Account string `json:"account"`
	 Email  string `json:"email"`
	 Password  string `json:"pw"`
	 Address string `json:"address"`
	 PhoneNum string `json:"phoneNum"`
 }

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
	 } else if function == "registerSupporter" { 		// 후원자 등록
		 return s.registerSupporter(APIstub, args)
	 } else if function == "queryAllSupporter" { 		// 후원자 조회
		 return s.queryAllSupporter(APIstub)
	 } else if function == "querySupporter" { 			// 내 개인정보 조회 (후원자)
		 return s.querySupporter(APIstub, args)
	 } else if function == "changeSupporterInfo" { 		// 내 정보 수정 (후원자)
		 return s.changeSupporterInfo(APIstub, args)
	 }
	 return shim.Error("Invalid Smart Contract function name.")
 }
 

 /*
  * The initLedger method *
 Will add test data (1 Supporter)to our network
  */
 func (s *SmartContract) initLedger(APIstub shim.ChaincodeStubInterface) sc.Response {
	 supporter := []Supporter{
		 Supporter{Name:"Soyoung Yoo", ID:"9912122999999",Account:"국민,12345323987", Email:"ysy@naver.com", Password:"1ARVn2Auq2/WAqx2gNrL+q3RNjAzXpUfCXrzkA6d4Xa22yhRLy4AC50E+6UTPoscbo31nbOoq51gvkuXzJ6B2w==", Address:"Seoul", PhoneNum:"01089145587"},
	 }
 
	supporterAsBytes, _ := json.Marshal(supporter[0])
	APIstub.PutState( "9912122999999", supporterAsBytes)

	 return shim.Success(nil)
 }
 
 /*
  * The registerSupporter method *
 This method takes in seven arguments (attributes to be saved in the ledger). 
  */
 func (s *SmartContract) registerSupporter(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
 
 
	var supporter = Supporter{ Name: args[0], ID: args[1], Account:args[2], Email: args[3], Password: args[4], Address: args[5], PhoneNum: args[6]}

	supporterAsBytes, _ := json.Marshal(supporter)
	err := APIstub.PutState(args[1], supporterAsBytes)
	fmt.Sprintf("신규 등록 후원자의 주민번호는: %s", args[1])
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

func (s *SmartContract) querySupporter(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	supporterAsBytes, _ := APIstub.GetState(args[0])
	if supporterAsBytes == nil {
		return shim.Error("Could not locate supporter")
	}
	return shim.Success(supporterAsBytes)
	
}
//내 정보 수정(후원자)
func (s *SmartContract) changeSupporterInfo(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	userSupporterAsBytes, _ := APIstub.GetState(args[0])
	if userSupporterAsBytes == nil {
		return shim.Error("Could not locate supporter")
	}
	userSupporter := Supporter{}

	json.Unmarshal(userSupporterAsBytes, &userSupporter)
	// Normally check that the specified argument is a valid holder of tuna
	// we are skipping this check for this example

	if len(args) == 3{ //주소와 폰 번호 바꾸는 경우
        userSupporter.Address = args[1]
        userSupporter.PhoneNum = args[2]
    } else {
        userSupporter.Password = args[1]
    }

	userSupporterAsBytes, _ = json.Marshal(userSupporter)
	err := APIstub.PutState(args[0], userSupporterAsBytes)
	if err != nil {
		return shim.Error(fmt.Sprintf("Failed to change user's personal info(supporter)"))
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