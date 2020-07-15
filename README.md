# BlockchainSupportProject

Hyperledger Fabric을 이용한 개인 후원 시스템 by 이민주, 유소영, 하유진

## 1. 환경설정 
### 1-1. 우분투 설치하기


- 필요한 프로그램
```
버추얼 박스 (virtual box)
```
    
우선 버추얼 박스와 우분투의 iso 파일을 다운로드한다. <br>
우분투는 16.04 이상을 사용해야한다. 다운로드를 모두 마쳤다면 버추얼 박스를 실행시키고 새 가상머신을 생성한다. <br>
가상머신의 종류는 리눅스, 버전은 다운로드한 우분투 iso의 비트에 해당하는 Ubuntu로 설정한다. <br>
메모리의 크기는 2048MB 이상, 하드 디스크의 크기는 35GB 이상으로 설정해주어야 한다.


### 1-2. 필요한 응용 프로그램 설치


하이퍼레저 패브릭을 실행하기 위해서는 몇가지 응용 프로그램을 설치해야한다. <br>
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


### 1-3. MySQL 설치 및 테이블 생성


클라이언트 응용 프로그램을 실행하기 위해서는 mysql을 설치해야 한다. 
mysql은 8.0 이상의 버전을 사용해야 한다. 
아래의 명령어를 통해 mysql을 설치할 수 있다. 
server.js 파일에 mysql 비밀번호가 1234로 설정되어 있으며 
설치 시 이와 동일하게 비밀번호를 설정하거나 server.js 파일에서 이를 수정하여 사용하면 된다.


```
$ sudo wget https://dev.mysql.com/get/mysql-apt-config_0.8.13-1_all.deb
$ sudo dpkg -i mysql-apt-config_0.8.13-1_all.deb
$ sudo apt-get update
$ sudo apt-get install mysql-server
$ mysql_secure_installation
```

설치가 완료되면 mysql -u root -p 의 명령어를 통해 mysql에 로그인하여 사용할 수 있다.
mysql 설치 이후, 사용자 데이터베이스 userdb와 사용자 테이블 usertbl을 생성해주어야 한다. usertbl은 아래와 같은 형태이다.


|컬럼명|자료형|기타|
|---|---|---|
|Name|varchar(10)|not null|
|Id|varchar(20)|primary key|
|Email|varchar(100)|not null|
|Password|varchar(150)|not null|
|Auth|int|not null|


이후, 초기 데이터를 아래와 같이 넣어준다. auth가 0인 경우는 후원자, 1인 경우는 피후원자, 2인 경우는 공공기관, 3인 경우는 후원기관을 의미한다.

