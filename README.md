# 티움 TIUM
> 초록이 머무는 일상, 당신의 공간에 딱 맞는 식물 관리를 함께
- 범정부 및 농림축산식품부 공공데이터를 활용한 식물 정보 및 관리 서비스입니다.

#### <a href="https://momentous-wallet-0f7.notion.site/21a1c3f0e00380b4b1f9cc830a35b448?source=copy_link"><img src="https://img.shields.io/badge/HomePage-009BD5?style=flat&logo=Notion&logoColor=white"/> <a href="https://apps.apple.com/kr/app/%ED%8B%B0%EC%9B%80-%EC%8B%9D%EB%AC%BC%EA%B3%BC-%ED%95%A8%EA%BB%98%ED%95%98%EB%8A%94-%ED%95%98%EB%A3%A8/id6747629769"><img src="https://img.shields.io/badge/AppStore-000000?style=flat&logo=AppStore&logoColor=white"/>

<br>

- 스크린샷 첨부

<br> 

# 목차

[1-프로젝트 소개](#1-프로젝트-소개)

- [1-1 개요](#1-1-개요)
- [1-2 개발환경](#1-2-개발환경)

[2-앱-디자인](#2-앱-디자인)
- [2-1 Screen Flow](#2-1-Screen-Flow)
- [2-2 Architecture](#2-2-Architecture)

[3-프로젝트 특징](#3-프로젝트-특징)

[4-프로젝트 세부과정](#4-프로젝트-세부과정)

[5-업데이트 및 리팩토링 사항](#5-업데이트-및-리팩토링-사항)


--- 

## 1-프로젝트 소개

### 1-1 개요
`환경에 맞춰 식물을 등록하고, 관리 팁과 상세한 정보를 한눈에 확인하세요.`
- **개발기간** : 2025.06 - 2025.07 (약 4주)
- **참여인원** : 1인 (개인 프로젝트)
- **주요내용**

  - 사용자의 식물 키우기 성향에 따라, 타입을 설정하고 맞춤형 정보 제공
  - 초보자를 돕기 위해 필요 시 물주기 알림 발송 시스템 구현
  - 농림축산식품부 공공데이터 API를 활용한 식물 관리법 제공

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

### 2-1 Screen Flow
`사용자 온보딩을 통한 고유 타입 설정 및 맞춤형 정보 제공`
- 4가지 온보딩 정보를 기반으로, 10개의 '식집사 타입'을 사용자에게 부여
- 타입을 기반으로 한 추천 식물 제공 기능 구현

`공공데이터 활용, 생육 방식에 따른 알림시스템 제공`
- 물주기, 광도 등 식물 상세정보 기반으로 한 로컬 알림 기능 제공함으로서 사용자 편의성 제고
- 농림축산식품부(식물), 기상청(날씨) 등 정부에서 제공하는 공공데이터를 적극 활용
- 앱 사용자 모두가 이용할 수 있게끔 계정등록을 DB(HIVE) 방식으로 대체
  
!!!! ----- App Flow 그리기 ----- !!!!

<br>

### 2-2 Architecture
`식물 정보와 사용자 정보`
- abcd
- abcd

`Bloc, Provider, Cubit을 활용한 상태관리, Clean Architecture 적용`
- 원활한 유지보수 및 기능 추가를 위한 Clean Architecture 적용
- 앱 전역에서 사용하는 상태와 특정 화면에서 사용하는 상태를 별도로 분리하여 주입(Get_it Locator), 적용 (Provider)
- 앱 실행 시, 갱신이 필요한 '최신 회차 결과'를 비롯하여 Trigger를 통한 즉각적인 DB 업데이트 (Listener, Trigger)

!!!! ----- Architecture ----- !!!!


<br>

## 3-프로젝트 특징

### 3-1 맞춤형 관리 팁
- 당신에게 꼭 맞는 식물관리 팁을 전해드립니다.

<table>
  <tr>
    <td align="center"><img src="https://github.com/user-attachments/assets/748d5b36-0c7b-4f71-aa36-0f8c5061d22a" width="250" height="541"/></td>
    <td align="center"><img src="https://github.com/user-attachments/assets/9d201138-7d56-44b5-a456-189ee15b84b9" width="250" height="541"/></td>
    <td align="center"><img src="https://github.com/user-attachments/assets/d995b8fb-7fc8-4a1d-9bba-c82a14cb15de" width="250" height="541"/></td>
  </tr>
  <tr>
    <td align="center">Splash 1</td>
    <td align="center">Splash 2</td>
    <td align="center">Splash 3</td>
  </tr>
</table>

<br>


### 3-2 작물 정보 제공
- 농림축산식품부 공공 API를 바탕으로 식물에 대한 기초 정보와 관리법을 제공합니다.

<table>
  <tr>
    <td align="center"><img src="https://github.com/user-attachments/assets/eacd3328-9a65-472a-b227-ebc8f6c34ad5" width="250" height="541"/></td>
    <td align="center"><img src="https://github.com/user-attachments/assets/a2adf22a-d094-4144-9bbf-5ab1f8441caf" width="250" height="541"/></td>
    <td align="center"><img src="https://github.com/user-attachments/assets/3f3cc263-7fc3-4dbb-bf04-9f7cf1e2c7bb" width="250" height="541"/></td>
  </tr>
  <tr>
    <td align="center">Home Screen</td>
    <td align="center">Weekly Screen</td>
    <td align="center">Round List</td>
  </tr>
</table>

<br>

### 3-3 실내 식물 물주기 알림
- 필요한 때에 알림으로 알려드립니다. 초보자도 놓치지 않고 돌볼 수 있어요!

<table>
  <tr>
    <td align="center"><img src="https://github.com/user-attachments/assets/9712174f-6f91-43b0-8449-5c81d563d1d5" width="250" height="541"/></td>
    <td align="center"><img src="https://github.com/user-attachments/assets/35649ac2-46df-40e0-a0aa-251c3f182f2b" width="250" height="541"/></td>
    <td align="center"><img src="https://github.com/user-attachments/assets/e8570bee-f14b-4d7d-b78d-ba09775e8898" width="250" height="541"/></td>
  </tr>
  <tr>
    <td align="center">Question</td>
    <td align="center">Daily Result</td>
    <td align="center">Latest Result</td>
  </tr>
</table>

<br>

## 4-프로젝트 세부과정
### 4-1 Figma를 활용한 Mock-up, App Flow 구현
> 빠른 개발을 위해 디자인 목업 실시
- 색상 팔레트 및 메인테마, 앱 아이콘 등 초기 앱 세팅에 필요한 사항을 선행 작업
- 전반적인 앱 흐름 파악과 빠른 UI 작업을 위해 Figma를 통해 Components 생성

<a href="https://www.figma.com/design/MYK0TassNj2fG4hVPaYZlY/daily_lotto_design?node-id=86-700&t=WqObIinlzsDwdsbQ-1"><img src="https://img.shields.io/badge/Figma-F24E1E?style=flat&logo=figma&logoColor=white"/>


![app_design_figma](https://github.com/user-attachments/assets/81a80590-7452-4eb7-8f1e-04d5f8ee024b)



<br>

### 4-2 LLM, Notification을 위한 Functions 작업 진행
> 공통적으로 활용되는 데이터의 생성 및 관리를 위한 Node.js deploy 실시
- 관련된 주요 기능을 우선 테스트하기 위하여 Firestore functions을 활용하여 google console scheduler 내 적용

![Group 68](https://github.com/user-attachments/assets/c85a2375-14a2-4ce1-8fed-6aff38da9be2)



<br>

### 4-3 개발 및 지원체계 구축
> 사전에 구축한 Figma components를 기반으로 한 빠른 UI 화면 구축 실시
- 앱 테마 및 색상, 공통적인 서비스 (Shared_preference, HIVE, 앱 버전관리, Route) 작업 실시
- Components 별 Constraint와 Size를 기반으로 Widgets 생성
- 공식 페이지, 개인정보 처리방침 외 관련된 지원체계 생성 및 구축

<br>

### 4-4 상태관리를 위한 DI 주입 및 BloC Providing 실시
> 구현된 화면 별, 필요한 데이터 주입 및 Environment에 따른 테스트 실시
- 공통 데이터(-> main), 특정 화면 내 사용되는 상태값으로 구분하여 Provider 생성
- Consumer, Listener, Builder를 적절하게 사용함으로서 불필요한 리빌딩을 줄임


<br>

## 5-업데이트 및 리팩토링 사항
### 5-1 우선 순위별 개선항목
1) Issue
- [ ] empty

2) Develop
- [ ] 이미지 분석(Tensorflow lite)을 통한 식물 인식 모델 구축
- [ ] LLM 모델을 통한 사용자 맞춤형 질의응답 챗봇 생성

<br>
