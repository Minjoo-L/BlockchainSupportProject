# BlockchainSupportProject

Hyperledger Fabric을 이용한 개인 후원 시스템 by 이민주, 유소영, 하유진

## 1. 환경설정 
### 1-1. 우분투 설치하기


- 필요한 프로그램
```
버추얼 박스 (virtual box)
```
    
우선 버추얼 박스와 우분투의 iso 파일을 다운로드한다. <br> <br>
우분투는 16.04 이상을 사용해야한다. 다운로드를 모두 마쳤다면 버추얼 박스를 실행시키고 새 가상머신을 생성한다. 가상머신의 종류는 리눅스, 버전은 다운로드한 우분투 iso의 비트에 해당하는 Ubuntu로 설정한다. 메모리의 크기는 **2048MB 이상**, 하드 디스크의 크기는 **35GB 이상**으로 설정해주어야 한다.
  
********************************************************************************
  
### 1-2. 필요한 응용 프로그램 설치


하이퍼레저 패브릭을 실행하기 위해서는 몇가지 응용 프로그램을 설치해야한다. <br><br>
필요한 응용 프로그램들과 권장 버전은 아래와 같다.

```
1. curl
2. docker (v1.12 이상)
3. docker-compose (v1.8 이상)
4. golang (v1.101 이상)
5. git client
6. npm (v5.6.0 이상)
7. node (v8.4.0 이상 / v10 이상은 오류가 많이 남)
```

아래의 명령어들을 실행하면 기본 환경 설정을 완료할 수 있다.

```
$ sudo su
$ apt-get update -y
$ apt install -y curl
$ apt install -y docker.io
$ apt install -y docker-compose
$ apt install -y software-properties-common
$ wget https://storage.googleapis.com/golang/go1.10.4.linux-amd64.tar.gz
$ tar xvf go1.10.4.linux-amd64.tar.gz
$ apt-get update
$ apt-get install golang-go
$ apt-get install -y git
$ apt-get install build-essential -y
$ curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
$ source ~/.bashrc
$ nvm install v9.4.0
$ nvm use v9.4.0
$ source ~/.bashrc
```

버전 확인을 통해 모두 잘 설치되었는지 확인해볼 수 있다.
  
********************************************************************************
  
### 1-3. MySQL 설치 및 테이블 생성

클라이언트 응용 프로그램을 실행하기 위해서는 mysql을 설치해야 한다. <br><br> 
mysql은 **8.0 이상**의 버전을 사용해야 한다. 아래의 명령어를 통해 mysql을 설치할 수 있다. server.js 파일에 mysql 비밀번호가 1234로 설정되어 있으며 설치 시 이와 동일하게 비밀번호를 설정하거나 server.js 파일에서 이를 수정하여 사용하면 된다.

```
$ sudo wget https://dev.mysql.com/get/mysql-apt-config_0.8.13-1_all.deb
$ sudo dpkg -i mysql-apt-config_0.8.13-1_all.deb
$ sudo apt-get update
$ sudo apt-get install mysql-server
$ mysql_secure_installation
```

설치가 완료되면 mysql -u root -p 의 명령어를 통해 mysql에 로그인하여 사용할 수 있다. <br>
mysql 설치 이후, 사용자 데이터베이스 userdb와 사용자 테이블 usertbl을 생성해주어야 한다. usertbl은 아래와 같은 형태이다.

|컬럼명|자료형|기타|
|---|---|---|
|Name|varchar(10)|not null|
|Id|varchar(20)|primary key|
|Email|varchar(100)|not null|
|Password|varchar(150)|not null|
|Auth|int|not null|

이후, 초기 데이터를 아래와 같이 넣어준다. <br><br>
auth가 0인 경우는 후원자, 1인 경우는 피후원자, 2인 경우는 공공기관, 3인 경우는 후원기관을 의미한다.

![usertbl](https://user-images.githubusercontent.com/43545606/76099454-7bbcc980-600e-11ea-950d-8b8395a8bb56.png)
  
## 2. 실행 방법
### 2-1. Set up
1. 다음의 명령어를 실행하여 코드를 클론한다.
  ```
  $ git clone https://github.com/Minjoo-L/BlockchainSupportProject.git
  ```
2. BlockchainSupportProject/Hyperledger-Fabric-Supporting-App/supporting-app 폴더로 이동한다.  
  
3. 다음의 명령어를 실행하여 하이퍼레저 패브릭 네트워크를 실행한다.
  ```
  $ ./startFabric.sh
  ```
4. 다음의 명령어를 실행하여 package.json file의 필요한 라이브러리들을 설치해준다.
  ```
  $ npm install
  ```
5. 다음의 명령어를 실행하여 네트워크에 Admin과 User component를 등록한다.
  ```
  $ node registerAdmin.js
  $ node registerUser.js
  ```
6. BlockchainSupportProject/Hyperledger-Fabric-Supporting-App/web 폴더로 이동하여 아래의 명령어를 실행하여 client application을 시작한다.
  ```
  $ node server.js
  ```
  이 과정을 모두 마치면, 포트 8000번에 client application의 네트워크가 세팅되며, localhost:8000을 통해 접속할 수 있다.  
  
********************************************************************************
  
### 2-2. 대표적인 실행 오류와 해결 방법
  
1. admin 등록 실패  
  $ rm -rf ~/.hfc-key-store/* 실행 후 다시  $ ./startFabric.sh 부터 순서대로 실행  
  
2. 올바르게 체인코드 추가 또는 수정하였는데 체인코드 실행 오류가 나거나 변경 사항이 반영되지 않은 경우  
  
- 첫번째 방법
  ```
  $ docker rm -f $(docker ps -aq)	
  $ docker rmi -f $(docker images -a -q)
  ```
  도커 컨테이너 삭제, 도커 이미지 삭제 후 다시 $ ./startFabric.sh 부터 실행  
  
- 두번째 방법  
  
  /supporting-app/startFabric.sh에서 체인코드 이름 변경 또는 버전 변경 후 실행  
  
3. ./startFabric.sh를 실행했을때, ERROR: manifest for hyperledger/fabric-ca:latest not found가 발생하는 경우  
  ```
  $ curl -sSL http://bit.ly/2ysbOFE | bash -s 1.4.4
  ```
4. ./startFabric 실행 시 권한 문제가 발생하는 경우  
  ```
  $ chmod a+x startFabric.sh
  ```
5. User, Admin Component 등록 시 오류가 발생하는 경우  
  ```
  $ rm -rf ~/.hfc-key-store
  $ node registerAdmin.js
  $ node registerUser.js
  ```
  
********************************************************************************
  
