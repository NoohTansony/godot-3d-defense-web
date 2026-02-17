# Mini3DDefense (Godot 4)

아주 간단한 3D 디펜스 게임 MVP입니다.

## 플레이
- 적이 바깥에서 생성되어 중앙 Base로 돌진
- 터렛이 자동으로 적을 사격
- 적이 Base에 닿으면 Base HP 감소
- HP 0이면 게임오버
- 적 처치/웨이브 클리어로 Gold 획득
- 슬롯 빌드/업그레이드 + 광역 스킬로 운영

## 조작
- `1~6` : 해당 슬롯에 터렛 설치
- `Q W E R T Y` : 해당 슬롯 터렛 업그레이드
- `Space` : Nova (광역 피해 스킬)
- `Enter` : 게임오버 후 재시작

## 실행 방법
1. Godot 4.x 실행
2. `godot-3d-defense/project.godot` 열기
3. `F5`로 실행

## 파일 구조
- `scenes/main.tscn` : 메인 씬
- `scenes/enemy.tscn` : 적
- `scenes/turret.tscn` : 터렛
- `scenes/bullet.tscn` : 탄환
- `scripts/*.gd` : 게임 로직

## 빠른 튜닝 포인트
- `scripts/main.gd`
  - `spawn_interval`
  - `enemies_per_wave`
- `scripts/enemy.gd`
  - `speed`, `hp`, `touch_damage`
- `scripts/turret.gd`
  - `fire_rate`, `range`
- `scripts/bullet.gd`
  - `speed`, `damage`
