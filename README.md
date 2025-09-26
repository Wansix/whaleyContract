# 🐋 Whaley NFT 프로젝트 스마트 컨트랙트

Whaley NFT 프로젝트의 스마트 컨트랙트 레포지토리입니다. 이 프로젝트는 ERC721 기반의 NFT 민팅, 화이트리스트 관리, 스테이킹 기능을 제공합니다.

## 📋 컨트랙트 개요

### 1. HCProjectWhitelists (`hc_whitelists.sol`)
화이트리스트 관리를 담당하는 컨트랙트입니다.

**주요 기능:**
- 2단계 화이트리스트 관리 (Whitelist1, Whitelist2)
- 관리자 권한 기반 화이트리스트 추가/삭제
- 단일 또는 배치 주소 추가 지원

**핵심 구조:**
```solidity
struct Whitelists {
    bool whitelist1;
    bool whitelist2;
}
```

### 2. MintNewWhaleyProject (`newMint.sol`)
메인 NFT 민팅 컨트랙트입니다.

**주요 기능:**
- 8단계 민팅 페이즈 관리 (Init → Whitelist1 → ... → Done)
- 2단계 퍼블릭 세일 (Public1, Public2)
- 에어드롭 기능
- 메타데이터 URI 관리 및 리빌 기능

**민팅 페이즈:**
1. `Init` - 초기 상태
2. `Whitelist1` - 화이트리스트 1단계
3. `WaitingWhitelist2` - 화이트리스트 2단계 대기
4. `Whitelist2` - 화이트리스트 2단계
5. `WaitingPublic1` - 퍼블릭 1단계 대기
6. `Public1` - 퍼블릭 1단계 (150개, 1개 제한)
7. `WaitingPublic2` - 퍼블릭 2단계 대기
8. `Public2` - 퍼블릭 2단계 (477개, 15개 제한)
9. `Done` - 완료

**민팅 설정:**
- 총 NFT 수량: 1,000개
- 판매 NFT 수량: 777개
- Public1: 150개 (1개 제한)
- Public2: 477개 (15개 제한)
- 최대 트랜잭션: 3개

### 3. NftStaker (`staking.sol`)
NFT 스테이킹 컨트랙트입니다.

**주요 기능:**
- 3개 NFT 동시 스테이킹
- 스테이킹 요청/해제 시스템
- 관리자 승인 기반 언스테이킹
- 스테이킹된 주소 추적

**스테이킹 프로세스:**
1. `stake()` - 3개 NFT 스테이킹
2. `unstakeRequest()` - 언스테이킹 요청
3. `releaseUnstake()` - 관리자 승인 (배치 처리)
4. `unstake()` - 실제 언스테이킹 실행

## 🛠 기술 스택

- **Solidity**: ^0.8.0
- **OpenZeppelin**: ERC721, Ownable, Access Control
- **표준**: ERC721 (NFT 표준)

## 📁 파일 구조

```
whaleyContract/
├── hc_whitelists.sol    # 화이트리스트 관리 컨트랙트
├── newMint.sol          # 메인 민팅 컨트랙트
├── staking.sol          # NFT 스테이킹 컨트랙트
└── README.md           # 프로젝트 문서
```

## 🔧 주요 기능

### 민팅 시스템
- **단계별 민팅**: 화이트리스트 → 퍼블릭 1단계 → 퍼블릭 2단계
- **수량 제한**: 각 페이즈별 개인별 민팅 제한
- **가격 설정**: 페이즈별 민팅 가격 설정 가능
- **에어드롭**: 기존 NFT 홀더 대상 에어드롭 지원

### 화이트리스트 관리
- **2단계 화이트리스트**: Whitelist1, Whitelist2
- **배치 관리**: 여러 주소 동시 추가/삭제
- **관리자 권한**: 소유자 및 지정된 관리자만 관리 가능

### 스테이킹 시스템
- **3개 NFT 스테이킹**: 동시에 3개 NFT 스테이킹 필요
- **승인 기반 언스테이킹**: 관리자 승인 후 언스테이킹 가능
- **배치 처리**: 여러 사용자 동시 승인 처리

## 🔐 권한 관리

모든 컨트랙트는 `Ownable` 패턴을 사용하며, 추가 관리자 설정이 가능합니다:
- `onlyOwner`: 컨트랙트 소유자만 접근 가능
- `admin`: 소유자가 지정한 관리자 접근 가능

## 📝 사용 예시

### 민팅
```solidity
// 퍼블릭 민팅 (2개 민팅)
mintContract.batchMintNFT{value: mintPrice * 2}(2);
```

### 화이트리스트 추가
```solidity
// 화이트리스트 1단계에 주소 추가
whitelistContract.addToWhitelist(Phase.Whitelist1, addresses);
```

### 스테이킹
```solidity
// 3개 NFT 스테이킹
stakingContract.stake(tokenId1, tokenId2, tokenId3);
```

## ⚠️ 주의사항

1. **메타데이터**: 민팅 후 리빌 기능을 통해 메타데이터 공개
2. **페이즈 관리**: 관리자가 수동으로 페이즈 진행
3. **스테이킹**: 3개 NFT를 모두 소유해야 스테이킹 가능
4. **언스테이킹**: 관리자 승인 후 언스테이킹 가능

## 🔗 배포된 컨트랙트 주소

### 메인넷 배포 주소
- **메인 NFT 컨트랙트**: `0x8B8aD5618fa85B9Be0713732CDe5adbeF15CE1Dc`
- **화이트리스트 컨트랙트**: `0x6Dae4db07314A470965a43F1B5eB0Ee57a6255ba`
- **스테이킹 컨트랙트**: `0xEDc47aFB189F8DB9b93d014E3aE3eE35994E9aCf`


