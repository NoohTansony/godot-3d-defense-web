# Mini3DDefense (Godot 4)

아주 간단한 3D 디펜스 게임 MVP입니다.

## 플레이
- 적이 바깥에서 생성되어 중앙 Base로 돌진
- 터렛이 자동으로 적을 사격
- 적이 Base에 닿으면 Base HP 감소
- HP 0이면 게임오버

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
