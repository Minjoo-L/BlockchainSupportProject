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
	 "strconv"
 
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
	 Email  string `json:"email"`
	 Password  string `json:"pw"`
	 Address string `json:"address"`
	 PhoneNum string `json:"phoneNum"`
 }

 // 바우처 (일단은 금액만)
 type Voucher struct {
	  Amount string `json:"amount"`
	  SuppEnter string `json:"suppEnter"` // 후원 업체
	  Status string `json:"status"` // 기부 여부
 }

 // 현재까지 구매된 바우처 개수
 var numOfVou uint64 = 1

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
	 } else if function == "registerSupporter" { 		// 후원자 등록
		 return s.registerSupporter(APIstub, args)
	 } else if function == "queryAllSupporter" { 		// 후원자 조회
		 return s.queryAllSupporter(APIstub)
	 } else if function == "querySupporter" { 			// 내 개인정보 조회 (후원자)
		 return s.querySupporter(APIstub, args)
	 } else if function == "changeSupporterInfo" { 		// 내 정보 수정 (후원자)
		 return s.changeSupporterInfo(APIstub, args)
	 } else if function == "purchaseVoucher" {			// 후원자 바우처 구매
		 return s.purchaseVoucher(APIstub, args)
	 } else if function == "queryPurchaseVoucher" { 	// 후원자 바우처 구매 내역 조회 
		 return s.queryPurchaseVoucher(APIstub, args)
	 } else if function == "allVoucher" {				// 구매된 전체 바우처 조회 (정부)
		 return s.allVoucher(APIstub)
	 } else if function == "donateV" {					// 바우처 후원하기
		 return s.donateV(APIstub, args)
	 } else if function == "recievedVoucher"{ //받은 바우처 내역 확인(피후원자)
		return s.recievedVoucher(APIstub, args);
	 }
 
	 return shim.Error("Invalid Smart Contract function name.")
 }
 

 /*
  * The initLedger method *
 Will add test data (1 Supporter)to our network
  */
 func (s *SmartContract) initLedger(APIstub shim.ChaincodeStubInterface) sc.Response {
	 supporter := []Supporter{
		 Supporter{Name:"Soyoung Yoo", ID:"9912122999999", Email:"ysy@naver.com", Password:"1ARVn2Auq2/WAqx2gNrL+q3RNjAzXpUfCXrzkA6d4Xa22yhRLy4AC50E+6UTPoscbo31nbOoq51gvkuXzJ6B2w==", Address:"Seoul", PhoneNum:"01089145587"},
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
 
 
	var supporter = Supporter{ Name: args[0], ID: args[1], Email: args[2], Password: args[3], Address: args[4], PhoneNum: args[5] }

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

	/*if len(args) != 6 {
		return shim.Error("Incorrect number of arguments. Expecting 6")
	}*/

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
       // fmt.Sprintf("들어오나?")
    } else {
        userSupporter.Password = args[1]
    }
/*
	userSupporter.ID = args[0]
	userSupporter.Name = args[1]
	userSupporter.Email = args[2]
	userSupporter.Password = args[3]
	userSupporter.Address = args[4]
	userSupporter.PhoneNum = args[5]
*/
	userSupporterAsBytes, _ = json.Marshal(userSupporter)
	err := APIstub.PutState(args[0], userSupporterAsBytes)
	if err != nil {
		return shim.Error(fmt.Sprintf("Failed to change user's personal info(supporter)"))
	}

	return shim.Success(nil)
}

// 후원자 바우처 구매 
func (s *SmartContract) purchaseVoucher(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
	// DApp에서 Id를 입력 받으니까 id랑 amount를 매개변수로 받는다.
	// 판매된 바우처 개수를 알아서 그 개수로 키 값을 생성한다.
	if len(args) != 3 {
		return shim.Error("Incorrect number of arguments. Expecting 3")
	}
	
	voucher := Voucher{}

	voucher.Amount = args[1]
	voucher.SuppEnter = args[2]
	voucher.Status = "N" // 아직 기부되지 않은 바우처

	voucherAsBytes, _ := json.Marshal(voucher)
	err := APIstub.PutState("Nv-" + args[0] +strconv.FormatUint(numOfVou, 10), voucherAsBytes) 

	numOfVou = numOfVou + 1 

	if err != nil {
		return shim.Error(fmt.Sprintf("Failed to purchase voucher"))
	}
	return shim.Success(nil)

}
// 후원자 바우처 구매 내역 조회
func (s *SmartContract) queryPurchaseVoucher(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	id := "Nv-"+args[0]

	startKey := "0"
	endKey := "999"

	resultsIterator, err := APIstub.GetStateByRange(id+startKey, id+endKey)
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
	
	fmt.Printf("- query purchased voucher:\n%s\n", buffer.String())

	return shim.Success(buffer.Bytes())
}

// 후원자 바우처 구매 내역 조회(정부)
func (s *SmartContract) allVoucher(APIstub shim.ChaincodeStubInterface) sc.Response {

	startKey := "0"
	endKey := "999"

	resultsIterator, err := APIstub.GetStateByRange("Nv-"+startKey, "Nv-"+endKey)
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
	
	fmt.Printf("- query all purchased voucher:\n%s\n", buffer.String())

	return shim.Success(buffer.Bytes())
}
// 바우처 후원하기
func (s *SmartContract) donateV(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	voucherAsBytes, _ := APIstub.GetState(args[0])
	key := "GET-"+args[1]
	//fmt.Sprintf(key)
	fmt.Sprintf(args[0], args[1])
	if voucherAsBytes == nil {
		return shim.Error("Could not donate voucher")
	}
	voucher := Voucher{}

	json.Unmarshal(voucherAsBytes, &voucher)
	// Normally check that the specified argument is a valid holder of tuna
	// we are skipping this check for this example
	voucher.Status = args[1]

	voucherAsBytes, _ = json.Marshal(voucher)
	err := APIstub.PutState(args[0], voucherAsBytes)
	err1 := APIstub.PutState(key, voucherAsBytes)
	if err != nil {
		return shim.Error(fmt.Sprintf("Fail"))
	} else if err1 != nil {
		return shim.Error(fmt.Sprintf("Fail 1"))
	}

	return shim.Success(nil)
}
func (s *SmartContract) recievedVoucher(APIstub shim.ChaincodeStubInterface, args []string) sc.Response{

	startKey := "0"
	endKey := "999"

	resultsIterator, err := APIstub.GetStateByRange("Nv-"+startKey, "Nv-"+endKey)
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
		fmt.Printf(queryResponse.Status)
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
	
	fmt.Printf("- query all recieved voucher:\n%s\n", buffer.String())

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