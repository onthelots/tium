# 티움 TIUM
> 초록이 머무는 일상, 당신의 공간에 딱 맞는 식물 관리를 함께
- 범정부 및 농림축산식품부 공공데이터를 활용한 식물 정보 및 관리 서비스입니다.

#### <a href="https://momentous-wallet-0f7.notion.site/21a1c3f0e00380b4b1f9cc830a35b448?source=copy_link"><img src="https://img.shields.io/badge/HomePage-009BD5?style=flat&logo=Notion&logoColor=white"/> <a href="https://apps.apple.com/kr/app/%ED%8B%B0%EC%9B%80-%EC%8B%9D%EB%AC%BC%EA%B3%BC-%ED%95%A8%EA%BB%98%ED%95%98%EB%8A%94-%ED%95%98%EB%A3%A8/id6747629769"><img src="https://img.shields.io/badge/AppStore-000000?style=flat&logo=AppStore&logoColor=white"/>

<br>

![combine_light](https://github.com/user-attachments/assets/a9d40934-0abb-45c3-9e37-2c7f02b680b3)

<br> 

# 목차

[1-프로젝트 소개](#1-프로젝트-소개)

- [1-1 개요](#1-1-개요)
- [1-2 개발환경](#1-2-개발환경)

[2-앱-디자인](#2-앱-디자인)
- [2-1 설계 및 기획](#2-1-설계-및-기획)
- [2-2 Architecture](#2-2-Architecture)

[3-프로젝트 특징](#3-프로젝트-특징)

[4-업데이트 및 리팩토링 사항](#4-업데이트-및-리팩토링-사항)


--- 

## 1-프로젝트 소개

### 1-1 개요
`환경에 맞춰 식물을 등록하고, 관리 팁과 상세한 정보를 한눈에 확인하세요.`
- **개발기간** : 2025.06 - 2025.07 (약 4주)
- **참여인원** : 1인 (개인 프로젝트)
- **주요내용**

  - 사용자의 식물 키우기 성향에 따라, 고유한 타입(유형)을 설정하고 맞춤형 정보 제공
  - 초보자를 돕기 위해 생육주기(물주기)에 따른 로컬 알림 시스템 구축
  - 농림축산식품부 공공데이터 API를 활용한 식물 관리법(큐레이션) 제공

<br>

### 1-2 개발환경
- **활용기술 외 키워드**
  - Flutter
    - 사용자 (iOS, Android)
   
  - 상태관리 : BloC, Cubit, Provider
  - DI : get_it
  - Server : Firebase (Functions, Messaging, FireStore)
  - DB : HIVE, Shared Preferences

<br>

## 2-앱 디자인

### 2-1 설계 및 기획
`앱 사용 시나리오에 따른 5단계 플로우 설계`
- 사용자 정보(유형 및 환경) 설정부터 식물 등록 및 관리까지의 과정을 우선 설계함
- 다음과 같이 5단계로 구분, 단계별 앱 설계 및 개발을 순차적으로 실시함

<img width="2944" alt="app_flow" src="https://github.com/user-attachments/assets/6a7b6bfb-ff14-4dd8-a2d3-0ec15a3297d5" />



<br>

### 2-2 Architecture
`Bloc, Clean Architecture 적용, DB 정보를 활용한 알림 등록`
- 공공데이터 API외 외부 데이터소스의 UseCase 활용을 위한 클린아키텍쳐 구상, 의존성 주입(Get_it Locator)
- 로컬 DB(HIVE) 내 사용자 정보 저장, 식물정보를 기반으로 한 Local Notification 구현함
- Bloc, Cubit을 활용한 상태관리를 실시함

<img width="3930" alt="architecture" src="https://github.com/user-attachments/assets/be8f27ae-bbcc-4aad-801e-57fa9bcccdd8" />


<br>

## 3-프로젝트 특징

### 3-1 온보딩 기반 사용자 유형 타입 분류
- 숙련도 햇빛 조건 관리 주기 관심 작물종류를 기반, 10개의 사용자 유형 적용
- 로컬 DB 내 유형정보 저장을 통한 맞춤형 식물관리 및 정보제공 기반 구축

<table>
  <tr>
    <td align="center"><img src="https://github.com/user-attachments/assets/73bc1e8e-7ac8-4f5a-ac65-cce0f680f452" width="250" height="541"/></td>
    <td align="center"><img src="https://github.com/user-attachments/assets/c18bc5a9-d465-4bd9-80d3-100c64e4284b" width="250" height="541"/></td>
    <td align="center"><img src="https://github.com/user-attachments/assets/54c58b9b-292e-4c81-a814-543a3bacf8f5" width="250" height="541"/></td>
  </tr>
  <tr>
    <td align="center">온보딩(요청)</td>
    <td align="center">온보딩(상세)</td>
    <td align="center">사용자 유형</td>
  </tr>
</table>

<br>


### 3-2 공공데이터 연계 식물 정보 제공
- 농림축산식품부, 기상청 OPEN API를 활용한 식물별 목록 및 상세정보 조회 기능 제공
- 날씨 및 환경 변화에 따른 자외선 강도 경고 기능 제공

<table>
  <tr>
    <td align="center"><img src="https://github.com/user-attachments/assets/a6e928a3-6ea7-4fa8-a8d2-11af5abd2c84" width="250" height="541"/></td>
    <td align="center"><img src="https://github.com/user-attachments/assets/ac52e970-49d0-4931-8a67-800ad2ad7470" width="250" height="541"/></td>
    <td align="center"><img src="https://github.com/user-attachments/assets/127dd39a-601f-4bf9-88f8-33f9acc90d95" width="250" height="541"/></td>
  </tr>
  <tr>
    <td align="center">큐레이션 및 날씨정보</td>
    <td align="center">식물 상세정보</td>
    <td align="center">식물 정보검색</td>
  </tr>
</table>

<br>

### 3-3 식물등록 및 관리 기능 및 로컬 알림 시스템 구현
- 내 식물 등록(별명, 사진 외) 및 환경별 관리 기능 제공
- 사용자가 등록한 실제 식물의 기본 생육주기 물주기 에 따라 로컬 알림 제공

<table>
  <tr>
    <td align="center"><img src="https://github.com/user-attachments/assets/6b458ff4-b888-4175-ac6a-bb02d7476d92" width="250" height="541"/></td>
    <td align="center"><img src="https://github.com/user-attachments/assets/f65cec66-f2e6-453e-b2f8-a236b56dafc3" width="250" height="541"/></td>
    <td align="center"><img src="https://github.com/user-attachments/assets/4ea65437-5509-4c14-9ff9-c24c815afb0e" width="250" height="541"/></td>
  </tr>
  <tr>
    <td align="center">식물 등록</td>
    <td align="center">식물 관리</td>
    <td align="center">내 식물 리스트</td>
  </tr>
</table>

<br>

## 4-업데이트 및 리팩토링 사항
### 4-1 우선 순위별 개선항목
1) Issue
- [ ] empty

2) Develop
- [ ] 이미지 분석(Tensorflow 혹은 Google ML)을 통한 식물 인식 모델 구축
- [ ] LLM 모델을 통한 사용자 맞춤형 질의응답 챗봇 생성

<br>
