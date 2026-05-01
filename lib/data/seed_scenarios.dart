import '../models/scenario.dart';

const List<Scenario> kSeedScenarios = [
  Scenario(
    id: 's_l2_001',
    title: '物理リンク断絶によるOSPFネイバー消失',
    description:
        'ルーターのSyslogに複数のアラートが出力された。'
        '何が起きているか正確に読み取り、次の対処を判断する。',
    category: ScenarioCategory.layer1layer2,
    difficulty: DifficultyLevel.beginner,
    questionIds: ['q_l2_001_1', 'q_l2_001_2'],
    prerequisite: 'OSPF基礎・物理層の概念',
  ),
  Scenario(
    id: 's_l2_002',
    title: 'VLANミス設定によるセグメント分離',
    description:
        '同じスイッチに接続しているのに通信できないと報告が入った。'
        'SyslogとVLAN設定から原因を特定する。',
    category: ScenarioCategory.layer1layer2,
    difficulty: DifficultyLevel.intermediate,
    questionIds: ['q_l2_002_1'],
    prerequisite: 'VLAN・802.1Qの基礎',
  ),
  Scenario(
    id: 's_l3_001',
    title: 'デフォルトルート消失によるインターネット全断',
    description:
        '深夜に拠点からインターネットへの通信が全断した。'
        '監視ツールのアラートと判断フローで最短復旧を目指す。',
    category: ScenarioCategory.layer3,
    difficulty: DifficultyLevel.beginner,
    questionIds: ['q_l3_001_1', 'q_l3_001_2', 'q_l3_001_3'],
    prerequisite: 'デフォルトルート・BGPの基礎',
  ),
  Scenario(
    id: 's_l3_002',
    title: 'OSPFネイバーが確立しない原因特定',
    description:
        '新規ルーターを追加したがOSPFネイバーが張れない。'
        'Syslogと設定から原因を3ステップで特定する。',
    category: ScenarioCategory.layer3,
    difficulty: DifficultyLevel.intermediate,
    questionIds: ['q_l3_002_1', 'q_l3_002_2'],
    prerequisite: 'OSPFネイバー確立プロセス（8状態）',
  ),
  Scenario(
    id: 's_sec_001',
    title: 'DDoS攻撃受信時の初動対応優先順位',
    description:
        '大量の不審トラフィックを検知。IDS/IDSアラートと'
        'トラフィック統計から初動対応を判断する。',
    category: ScenarioCategory.security,
    difficulty: DifficultyLevel.intermediate,
    questionIds: ['q_sec_001_1', 'q_sec_001_2'],
    prerequisite: 'DoS/DDoS・IDS基礎・ACL',
  ),
  Scenario(
    id: 's_cap_001',
    title: '帯域逼迫の原因特定と対処',
    description:
        '業務時間帯に全体が遅いという報告。'
        'インターフェース統計とQoS設定から原因を絞り込む。',
    category: ScenarioCategory.capacity,
    difficulty: DifficultyLevel.advanced,
    questionIds: ['q_cap_001_1', 'q_cap_001_2'],
    prerequisite: 'QoS・DSCP・帯域監視',
  ),
];
