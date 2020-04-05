//공공기관, 후원기관, 후원자, 피후원자 모두 참여하는 채널1

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
  */
 func (s *SmartContract) initLedger(APIstub shim.ChaincodeStubInterface) sc.Response {
	 return shim.Success(nil)
 }
 
 /*
  * The registerSupporter method *
 This method takes in seven arguments (attributes to be saved in the ledger). 
  */

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
	queryString := fmt.Sprintf("{\"selector\":{\"status\":\"%s\"}}", args[0])
	resultsIterator, err := APIstub.GetQueryResult(queryString)
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