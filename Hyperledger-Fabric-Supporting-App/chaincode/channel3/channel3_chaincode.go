//공공기관, 피후원자 참여 채널

 package main

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
 
 /* Define Recipient structure, with 13 properties.  
 Structure tags are used by encoding/json library
 */
 type Recipient struct {
	Name string `json:"name"`
	ID string `json:"id"`
	Age string `json:"age"`
	Sex string `json:"sex"`
	Account string `json:"account`
	Email string `json:"email"`
	Password string `json:"password"`
	Address string `json:"address"`
	PhoneNum string `json:"phoneNum"`
	Job string `json:"job"`
	Story string `json:"story"`
	Status string `json:"status"`
	Reason string `json:"reason"`
}
 
 /*
  * The Init method *
  called when the Smart Contract "channel3-chaincode" is instantiated by the network
  * Best practice is to have any Ledger initialization in separate function 
  -- see initLedger()
  */
 func (s *SmartContract) Init(APIstub shim.ChaincodeStubInterface) sc.Response {
	 return shim.Success(nil)
 }
 
 /*
  * The Invoke method *
  called when an application requests to run the Smart Contract "channel3-chaincode"
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
	 } else if function == "approveRecipient" { //피후원자 승인
		 return s.approveRecipient(APIstub, args)
	 } else if function == "pendingRecipient"{ //피후원자 승인 보류
		return s.pendingRecipient(APIstub, args)
	 } else if function == "changeRecipientInfo"{ // 내 정보 수정 (피후원자)
		 return s.changeRecipientInfo(APIstub, args)
	 } else if function == "queryWithOtherInfo"{ //주민등록번호가 아닌 이메일로 조회
		return s.queryWithOtherInfo(APIstub, args)
	 } else if function == "changeAllRecipientInfo"{ //전체 정보 수정
		 return s.changeAllRecipientInfo(APIstub, args)
	 }
 
	 return shim.Error("Invalid Smart Contract function name.")
 }
 
 /*
  * The initLedger method *
 Will add test data (2 Recipient)to our network
  */
 func (s *SmartContract) initLedger(APIstub shim.ChaincodeStubInterface) sc.Response {
	recipient := []Recipient{
		Recipient{Name: "김철수", ID: "600101-2234560",Age:"61", Sex:"F",Account:"kook,12398237598741", Email: "kim@gmail.com", Password: "1ARVn2Auq2/WAqx2gNrL+q3RNjAzXpUfCXrzkA6d4Xa22yhRLy4AC50E+6UTPoscbo31nbOoq51gvkuXzJ6B2w==", Address: "서울시 중구", PhoneNum: "01044441234", Job:"무직",Story: "제 아이가 많이 힘듭니다. 저는 장애3급 판정을 받았습니다..\n 공백공백공백공백공백공백공백공백공백공백공백공백공백공백공백공백", Status: "N", Reason: ""},
		Recipient{Name: "김영희", ID: "990101-1234567",Age:"22", Sex:"M",Account:"kakao,33301598741", Email: "young@gmail.com", Password: "1ARVn2Auq2/WAqx2gNrL+q3RNjAzXpUfCXrzkA6d4Xa22yhRLy4AC50E+6UTPoscbo31nbOoq51gvkuXzJ6B2w==",Address: "안양시 에이구", PhoneNum: "01012341234",Job:"대학생", Story: "많이 힘들어요.. 제 아가들을 위해 도와주세요", Status: "Y", Reason: ""},
	}

	recipientAsBytes, _ := json.Marshal(recipient[0])
	APIstub.PutState("600101-2234560", recipientAsBytes)
	recipientAsBytes, _ = json.Marshal(recipient[1])
	APIstub.PutState("990101-1234567", recipientAsBytes)

	return shim.Success(nil) 
 }
 
 /*
  * The registerRecipient method *
 This method takes in 13 arguments (attributes to be saved in the ledger). 
  */
 func (s *SmartContract) registerRecipient(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
 
 
	var recipient = Recipient{ Name: args[0], ID: args[1], Age:args[2], Sex:args[3], Account:args[4], Email: args[5], Password: args[6], Address: args[7], PhoneNum: args[8],Job:args[9], Story: args[10], Status: args[11], Reason: ""}

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
	recipient.Status = args[1]

	recipientAsBytes, _ = json.Marshal(recipient)
	err := APIstub.PutState(args[0], recipientAsBytes)
	if err != nil {
		return shim.Error(fmt.Sprintf("Failed to approve recipient: %s", args[0]))
	}

	return shim.Success(nil)
}
// 피후원자 승인 보류
func (s *SmartContract) pendingRecipient(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 3 {
		return shim.Error("Incorrect number of arguments. Expecting 2")
	}

	recipientAsBytes, _ := APIstub.GetState(args[0])
	if recipientAsBytes == nil {
		return shim.Error("Could not locate recipient")
	}
	recipient := Recipient{}

	json.Unmarshal(recipientAsBytes, &recipient)
	recipient.Status = args[1]
	recipient.Reason = args[2]
	recipientAsBytes, _ = json.Marshal(recipient)
	err := APIstub.PutState(args[0], recipientAsBytes)
	if err != nil {
		return shim.Error(fmt.Sprintf("Failed to approve recipient: %s", args[0]))
	}

	return shim.Success(nil)
}
//전체 정보 수정(피후원자)
func (s *SmartContract) changeAllRecipientInfo(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 7 {
		return shim.Error("Incorrect number of arguments. Expecting 5")
	}

	userRecipientAsBytes, _ := APIstub.GetState(args[0])
	if userRecipientAsBytes == nil {
		return shim.Error("Could not locate Recipient")
	}
	userRecipient := Recipient{}

	json.Unmarshal(userRecipientAsBytes, &userRecipient)

	userRecipient.ID = args[0]
	userRecipient.Account=args[1]
	userRecipient.Email = args[2]
	userRecipient.Address = args[3]
	userRecipient.PhoneNum = args[4]
	userRecipient.Job=args[5]
	userRecipient.Story = args[6]

	userRecipientAsBytes, _ = json.Marshal(userRecipient)
	err := APIstub.PutState(args[0], userRecipientAsBytes)
	if err != nil {
		return shim.Error(fmt.Sprintf("Failed to change user's personal info(Recipient)"))
	}

	return shim.Success(nil)
}
func (s *SmartContract) changeRecipientInfo(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
    userRecipientAsBytes, _ := APIstub.GetState(args[0])
    if userRecipientAsBytes == nil {
        return shim.Error("Could not locate Recipient")
    }
    userRecipient := Recipient{}

    json.Unmarshal(userRecipientAsBytes, &userRecipient)

    if len(args) == 3 { // 주소와 폰 번호 바꾸는 경우
        userRecipient.Address = args[1]
        userRecipient.PhoneNum = args[2]
    } else {    // 비밀번호 바꾸는 경우
        userRecipient.Password = args[1]
    }

    userRecipientAsBytes, _ = json.Marshal(userRecipient)
    err := APIstub.PutState(args[0], userRecipientAsBytes)
    if err != nil {
        return shim.Error(fmt.Sprintf("Failed to change user's personal info(Recipient)"))
    }

    return shim.Success(nil)
}

//이메일로 조회
func (s *SmartContract) queryWithOtherInfo(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}
	queryString := 
	`{
		"selector":{
			"email": "`+args[0]+`"
		}
	 }`
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
