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

/* Define Tuna structure, with 4 properties.  
Structure tags are used by encoding/json library
*/
//후원자
type Supporter struct {
    Name string `json:"name"`
    ID string `json:"id"`
    Email  string `json:"email"`
    Password string `json:"pw"`
    Address  string `json:"address"`
    PhoneNum string `json:"phoneNum"`
}
//피후원자
type Recipient  struct {
    Name string `json:"name"`
    ID string `json:"id"`
    Email  string `json:"email"`
    Password string `json:"pw"`
    Address  string `json:"address"`
    PhoneNum string `json:"phoneNum"`
    Story  string `json:"story"`
    Status  string `json:"status"`
}
//정부
type Government struct {
    Name string `json:"name"`
    Email  string `json:"email"`
    Password string `json:"pw"`
    Address  string `json:"address"`
    Tel string `json:"phoneNum"`
}
//후원업체
type SupportingEnterprise struct {
    Name string `json:"name"`
    Email  string `json:"email"`
    Password string `json:"pw"` 
    Address  string `json:"address"`
    Tel string `json:"Tel"`
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
 called when an application requests to run the Smart Contract "tuna-chaincode"
 The app also specifies the specific smart contract function to call with args
 */
func (s *SmartContract) Invoke(APIstub shim.ChaincodeStubInterface) sc.Response {

	// Retrieve the requested Smart Contract function and arguments
	function, args := APIstub.GetFunctionAndParameters()
	// Route to the appropriate handler function to interact with the ledger
	if function == "registerSupporter" {	//후원자 정보 등록	//완
		return s.registerSupporter(APIstub, args)
	} else if function == "initLedger" {	//테스트용 저장할 데이터	첵
		return s.initLedger(APIstub)
	} else if function == "applyForRecipient" {   //피후원자 신청	//완  첵
		return s.applyForRecipient(APIstub, args)
	} else if function == "registerRecipient" {			// 피후원자 등록 완료 //완
		return s.registerRecipient(APIstub, args)		
	} else if function == "changeRecipientInfo" {		//피후원자 정보 수정 //완
		return s.changeRecipientInfo(APIstub, args)
	} else if function == "changeSupporterInfo" {		//후원자 정보 수정 //완
		return s.changeSupporterInfo(APIstub, args)
	} else if function == "getRecipientInfo" {			//피후원자 정보 조회 //완
		return s.getRecipientInfo(APIstub, args)
	} else if function == "getSupporterInfo" {			//후원자 정보 조회	//완
		return s.getSupporterInfo(APIstub, args)
	} else if function == "getApplyReciInfo" {		    // 테스트용 전체 피후원자 신청자 정보 조회  첵
		return s.getApplyReciInfo(APIstub)
	}

	return shim.Error("Invalid Smart Contract function name.")
}

/*
 * The queryTuna method *
Used to view the records of one particular tuna
It takes one argument -- the key for the tuna in question
 */
/*func (s *SmartContract) queryTuna(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	tunaAsBytes, _ := APIstub.GetState(args[0])
	if tunaAsBytes == nil {
		return shim.Error("Could not locate tuna")
	}
	return shim.Success(tunaAsBytes)
}*/

func (s *SmartContract) registerSupporter(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	var supporter = Supporter{ Name: args[1], ID: args[2], Email: args[3], Password: args[4], Address: args[5], PhoneNum: args[6] }

	supporterAsBytes, _ := json.Marshal(supporter)
	err := APIstub.PutState(args[0], supporterAsBytes)
	if err != nil {
		return shim.Error(fmt.Sprintf("Failed to register supporter: %s", args[0]))
	}

	return shim.Success(nil)
}

func (s *SmartContract) applyForRecipient(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	var recipient = Recipient{ Name: args[1], ID: args[2],  Email: args[3], Password: args[4], Address: args[5], PhoneNum:args[6], Story: args[7], Status: args[8] }

	recipientAsBytes, _ := json.Marshal(recipient)
	err := APIstub.PutState(args[0], recipientAsBytes)
	if err != nil {
		return shim.Error(fmt.Sprintf("Failed to register supporter: %s", args[0]))
	}
	return shim.Success(nil)
}

// change recipient stauts to 'y' 
func (s *SmartContract) registerRecipient(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

    if len(args) != 1 {
        return shim.Error("Incorrect arguments ==> Recipient Id")
    }

    recipientAsBytes, _ := APIstub.GetState(args[0])
    if recipientAsBytes == nil {
        return shim.Error("Not exist")
    }
    recipient := Recipient{}

    json.Unmarshal(recipientAsBytes, &recipient)
    recipient.Status = "y"

    recipientAsBytes, _ = json.Marshal(recipient)
    err := APIstub.PutState(args[0], recipientAsBytes)
    if err != nil {
        return shim.Error(fmt.Sprintf("Failed to register recipient: %s", args[0]))
    }

    return shim.Success(nil)
}

// change recipient information. change status: n & change personal info
func (s *SmartContract) changeRecipientInfo(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
    if len(args) != 8 {   //위의 데이터 구조를 토대로
        return shim.Error("Incorrect arguments ==> Recipient Id, name, email, password, address, phone number, story, status")
    }
    recipientAsBytes, _ := APIstub.GetState(args[0])
    if recipientAsBytes == nil {
        return shim.Error("Not exist")
    }
    recipient := Recipient{}
    json.Unmarshal(recipientAsBytes, &recipient)
    
    recipient.Name = arg[1]
    recipient.Email = arg[2]
    recipient.Password = arg[3]
    recipient.Address = arg[4]
    recipient.PhoneNum = strconv.Itoa(arg[5])
    recipient.Story = arg[6]
    recipient.Status = "n"

    recipientAsBytes, _ = json.Marshal(recipient)
    err := APIstub.PutState(args[0], recipientAsBytes)
    if err != nil {
        return shim.Error(fmt.Sprintf("Failed to change personal information of recipient: %s", args[0]))
    }
    return shim.Success(recipientAsBytes)
}

// change personal information of supporter
func (s *SmartContract) changeSupporterInfo(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

    if len(args) != 6 {   //위의 데이터 구조를 토대로
        return shim.Error("Incorrect arguments ==> Supporter Id, name, email, password, address, phone number")
    }

    SupporterAsBytes, _ := APIstub.GetState(args[0])
    if SupporterAsBytes == nil {
        return shim.Error("Not exist")
    }
    supporter := Supporter{}  
    json.Unmarshal(SupporterAsBytes, &supporter)

    supporter.Name = arg[1]
    supporter.Email = arg[2]
    supporter.Password = arg[3]
    supporter.Address = arg[4]
    supporter.PhoneNum = strconv.Itoa(arg[5])

    supporterAsBytes, _ = json.Marshal(supporter)
    err := APIstub.PutState(args[0], supporterAsBytes)
    if err != nil {
        return shim.Error(fmt.Sprintf("Failed to change personal information of supporter: %s", args[0]))
    }

    return shim.Success(supporterAsBytes)
}

// get personal information of recipient
func (s *SmartContract) getRecipientInfo(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

    if len(args) != 1 {
        return shim.Error("Incorrect number of arguments. Expecting personal ID") // ID
    }

    recipientAsBytes, _ := APIstub.GetState(args[0])
    if recipientAsBytes == nil {
        return shim.Error("Does not exist")
    }
    return shim.Success(recipientAsBytes)
}

// get personal information of supporter
func (s *SmartContract) getSupporterInfo(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

    if len(args) != 1 {
        return shim.Error("Incorrect number of arguments. Expecting personal ID")
    }

    supporterAsBytes, _ := APIstub.GetState(args[0])
    if supporterAsBytes == nil {
        return shim.Error("Does not exist")
    }
    return shim.Success(supporterAsBytes)
}

/*
 * The initLedger method *
Will add test data (10 tuna catches)to our network
 */
func (s *SmartContract) initLedger(APIstub shim.ChaincodeStubInterface) sc.Response {
	recipient := []Recipient{
		Recipient{Name: "이민주", ID: "1234", Email: "min@gmail.com", Password: "1234", Address: "성남시", PhoneNum: "0000", Story: "안녕", Status:"n"},
		Recipient{Name: "유소영", ID: "5678", Email: "so@gmail.com", Password: "5678", Address: "고양시", PhoneNum: "0123", Story: "오잉", Status:"n"},
		Recipient{Name: "하유진", ID: "9012", Email: "yoo@gmail.com", Password: "9012", Address: "시흥시", PhoneNum: "4567", Story: "꺄악", Status:"n"}
		}

	i := 0
	for i < len(tuna) {
		fmt.Println("i is ", i)
		tunaAsBytes, _ := json.Marshal(tuna[i])
		APIstub.PutState(strconv.Itoa(i+1), tunaAsBytes)
		fmt.Println("Added", tuna[i])
		i = i + 1
	}

	return shim.Success(nil)
}

/*
 * The recordTuna method *
Fisherman like Sarah would use to record each of her tuna catches. 
This method takes in five arguments (attributes to be saved in the ledger). 
 */
/*func (s *SmartContract) recordTuna(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 5 {
		return shim.Error("Incorrect number of arguments. Expecting 5")
	}

	var tuna = Tuna{ Vessel: args[1], Location: args[2], Timestamp: args[3], Holder: args[4] }

	tunaAsBytes, _ := json.Marshal(tuna)
	err := APIstub.PutState(args[0], tunaAsBytes)
	if err != nil {
		return shim.Error(fmt.Sprintf("Failed to record tuna catch: %s", args[0]))
	}

	return shim.Success(nil)
}*/

func (s *SmartContract) getApplyReciInfo(APIstub shim.ChaincodeStubInterface) sc.Response {

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

	fmt.Printf("- queryAllreci:\n%s\n", buffer.String())

	return shim.Success(buffer.Bytes())
}
/*
 * The queryAllTuna method *
allows for assessing all the records added to the ledger(all tuna catches)
This method does not take any arguments. Returns JSON string containing results. 
 */
/*func (s *SmartContract) queryAllTuna(APIstub shim.ChaincodeStubInterface) sc.Response {

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

	fmt.Printf("- queryAllTuna:\n%s\n", buffer.String())

	return shim.Success(buffer.Bytes())
}
*/
/*
 * The changeTunaHolder method *
The data in the world state can be updated with who has possession. 
This function takes in 2 arguments, tuna id and new holder name. 
 */
/*func (s *SmartContract) changeTunaHolder(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2")
	}

	tunaAsBytes, _ := APIstub.GetState(args[0])
	if tunaAsBytes == nil {
		return shim.Error("Could not locate tuna")
	}
	tuna := Tuna{}

	json.Unmarshal(tunaAsBytes, &tuna)
	// Normally check that the specified argument is a valid holder of tuna
	// we are skipping this check for this example
	tuna.Holder = args[1]

	tunaAsBytes, _ = json.Marshal(tuna)
	err := APIstub.PutState(args[0], tunaAsBytes)
	if err != nil {
		return shim.Error(fmt.Sprintf("Failed to change tuna holder: %s", args[0]))
	}

	return shim.Success(nil)
}
*/
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