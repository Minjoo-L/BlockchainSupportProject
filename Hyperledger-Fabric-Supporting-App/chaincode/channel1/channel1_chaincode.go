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
	 "time"
	 "github.com/hyperledger/fabric/core/chaincode/shim"
	 sc "github.com/hyperledger/fabric/protos/peer"
 )
 
 // Define the Smart Contract structure
 type SmartContract struct {
 }
 
 /* Define Supporter structure, with 6 properties.  
 Structure tags are used by encoding/json library
 */

 // 바우처
 type Voucher struct {
	  Amount int `json:"amount"`//금액
	  GiveGet int `json:"giveget"`//산건지 준건지(후원자) 받은건지 쓴건지(피후원자)
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
	 } else if function == "purchaseVoucher" {			// 후원자 바우처 구매
		 return s.purchaseVoucher(APIstub, args)
	 } else if function == "queryVoucher" { 	        // 후원자, 피후원자 바우처 조회 
		 return s.queryVoucher(APIstub, args)
	 } else if function == "allVoucher" {				// 구매된 전체 바우처 조회 (정부)
		 return s.allVoucher(APIstub)
	 } else if function == "donateV" {					// 바우처 후원하기
		 return s.donateV(APIstub, args)
	 } else if function == "voucherUsage"{			// 후원자 바우처 사용내역 조회
		 return s.voucherUsage(APIstub, args);
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
	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2")
	}
	voucherAsBytes, _ := APIstub.GetState(args[0])
	voucher := Voucher{}
	i, err := strconv.Atoi(args[1])

	if voucherAsBytes == nil {
		voucher.Amount = i
		voucher.GiveGet = i
		voucherAsBytes, _ = json.Marshal(voucher)
		err1 := APIstub.PutState(args[0], voucherAsBytes) 
		if err1 != nil {
			return shim.Error(fmt.Sprintf("Failed to purchase voucher"))
		}
	} else {
		json.Unmarshal(voucherAsBytes, &voucher)
		voucher.Amount = voucher.Amount + i;
		voucher.GiveGet = i
		voucherAsBytes, _ = json.Marshal(voucher)
		err := APIstub.PutState(args[0], voucherAsBytes)
		if err != nil{
			return shim.Error(fmt.Sprintf("Fail"))
		}
	}
	
	if err != nil{
		return shim.Error(fmt.Sprintf("Fail"))
	}
	return shim.Success(nil)

}
// 후원자, 피후원자 바우처 조회
func (s *SmartContract) queryVoucher(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
	
	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}
	voucherAsBytes, _ := APIstub.GetState(args[0])
	if voucherAsBytes == nil {//바우처를 구매한 내역이 없다
		voucher := Voucher{}
		voucher.Amount=0
		voucherAsBytes, _ = json.Marshal(voucher)
		return shim.Success(voucherAsBytes)
	}
	return shim.Success(voucherAsBytes)
}

// 후원자 바우처 구매 내역 조회(정부)
func (s *SmartContract) allVoucher(APIstub shim.ChaincodeStubInterface) sc.Response {

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
	
	fmt.Printf("- query all purchased voucher:\n%s\n", buffer.String())

	return shim.Success(buffer.Bytes())
}
// 바우처 후원하기
func (s *SmartContract) donateV(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	voucherAsBytes, _ := APIstub.GetState(args[0])//후원자 id
	voucher2AsBytes, _ := APIstub.GetState(args[1])//피후원자 id
	voucher := Voucher{} //후원자 바우처 업데이트
	voucher2 := Voucher{} //피후원자 바우처 업데이트
	i, err := strconv.Atoi(args[2])

	if voucherAsBytes == nil {//후원자가 바우처를 구매하지 않은 경우
		return shim.Error("Could not donate voucher")
	}
	if voucher2AsBytes == nil {//피후원자가 바우처를 처음 받는 경우
		voucher2.Amount=i
		voucher2.GiveGet=i
		json.Unmarshal(voucherAsBytes, &voucher)
		svoucher := voucher.Amount
		voucher.Amount = svoucher-i
		voucher.GiveGet = -i
		voucherAsBytes, _ = json.Marshal(voucher)
		voucher2AsBytes, _ = json.Marshal(voucher2)
		err1 := APIstub.PutState(args[0], voucherAsBytes)
		err2 := APIstub.PutState(args[1], voucher2AsBytes)
		if err1 != nil {
			return shim.Error(fmt.Sprintf("Fail 1"))
		}
		if err2 != nil {
			return shim.Error(fmt.Sprintf("Fail 2"))
		}
	}else{
		json.Unmarshal(voucherAsBytes, &voucher)
		json.Unmarshal(voucher2AsBytes, &voucher2)
		svoucher := voucher.Amount
		rvoucher := voucher2.Amount
		voucher.Amount = svoucher-i
		voucher.GiveGet = -i
		voucher2.Amount = rvoucher+i
		voucher2.GiveGet = i
		voucherAsBytes, _ = json.Marshal(voucher)
		voucher2AsBytes, _ = json.Marshal(voucher2)
		err1 := APIstub.PutState(args[0], voucherAsBytes)
		err2 := APIstub.PutState(args[1], voucher2AsBytes)
		if err1 != nil {
			return shim.Error(fmt.Sprintf("Fail 1"))
		}
		if err2 != nil {
			return shim.Error(fmt.Sprintf("Fail 2"))
		}
	}
	
	if err != nil{
		return shim.Error(fmt.Sprintf("Fail"))
	}

	return shim.Success(nil)
}
func (s *SmartContract) voucherUsage(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
	// 후원자 바우처 사용 내역
	if len(args) < 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}
	resultsIterator, err := APIstub.GetHistoryForKey(args[0])
	if err != nil {
			return shim.Error(err.Error())
	}
	defer resultsIterator.Close()

	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
			response, err := resultsIterator.Next()
			console.log(response);
			if err != nil {
					return shim.Error(err.Error())
			}
			// Add a comma before array members, suppress it for the first array member
			if bArrayMemberAlreadyWritten == true {
					buffer.WriteString(",")
			}
			buffer.WriteString("{\"TxId\":")
			buffer.WriteString("\"")
			buffer.WriteString(response.TxId)
			buffer.WriteString("\"")

			buffer.WriteString(", \"Value\":")
			// if it was a delete operation on given key, then we need to set the
			//corresponding value null. Else, we will write the response.Value
			//as-is (as the Value itself a JSON)
			if response.IsDelete {
					buffer.WriteString("null")
			} else {
					buffer.WriteString(string(response.Value))
			}

			buffer.WriteString(", \"Timestamp\":")
			buffer.WriteString("\"")
			buffer.WriteString(time.Unix(response.Timestamp.Seconds, int64(response.Timestamp.Nanos)).String())
			buffer.WriteString("\"")

			buffer.WriteString(", \"IsDelete\":")
			buffer.WriteString("\"")
			buffer.WriteString(strconv.FormatBool(response.IsDelete))
			buffer.WriteString("\"")

			buffer.WriteString("}")
			bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	fmt.Printf("- History returning:\n%s\n", buffer.String())
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