import '../models/question.dart';
import '../models/choice.dart';
import '../models/explanation.dart';

const List<Question> kSeedQuestions = [
  Question(
    id: 'q_l2_001_1',
    type: QuestionType.logChallenge,
    scenarioId: 's_l2_001',
    prompt: '以下のSyslogから何が起きているか選んでください。',
    logLines: [
      'Apr 29 14:23:15 Router-A %OSPF-5-ADJCHG: Process 1, Nbr 10.0.0.2',
      '  on GigabitEthernet0/1 from FULL to DOWN,',
      '  Neighbor Down: Dead timer expired',
      'Apr 29 14:23:16 Router-A %LINK-3-UPDOWN:',
      '  Interface GigabitEthernet0/1, changed state to down',
    ],
    choices: [
      Choice(
        id: 'a', text: 'OSPFの設定パラメータが誤っている',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'OSPF設定ミスなら %OSPF-6-CONFIG 系のログが出ます。Dead timer expiredはタイマー超過です。',
      ),
      Choice(
        id: 'b', text: '物理リンクの断絶によりOSPFネイバーが消失した',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ LINK-3-UPDOWN でリンクダウンが先行し、その結果Dead timerが切れてOSPFネイバーが消失しています。',
      ),
      Choice(
        id: 'c', text: 'BGPセッションが切断された',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'ログに %BGP の記述はありません。%OSPFのログを確認してください。',
      ),
      Choice(
        id: 'd', text: 'ルーティングループが発生している',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'ループなら %OSPF-4-ROUTE_LOOP や %IP-4-DUPADDR 系のログが出ます。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          'GigabitEthernet0/1 が物理的にダウンし（LINK-3-UPDOWN）、'
          'その結果OSPFのDead timerが切れてネイバー関係がFULL→DOWNに遷移した。'
          '物理障害がL3プロトコルに波及した典型的なパターン。',
      nextActions: [
        '対向機器のポート状態を確認する（show interfaces）',
        'ケーブルの物理的な接続・LEDランプを確認する',
        'エラーカウンターを確認する（input/output errors, CRC）',
        'OSPFネイバー状態を確認する（show ip ospf neighbor）',
      ],
      relatedCommands: [
        'show interfaces GigabitEthernet0/1',
        'show ip ospf neighbor',
        'show log | include GigabitEthernet0/1',
        'show ip route ospf',
      ],
      studyReference: 'CCNA: ネットワーク障害のトラブルシューティング / OSPFネイバー状態遷移',
    ),
  ),
  Question(
    id: 'q_l2_001_2',
    type: QuestionType.decisionFlow,
    scenarioId: 's_l2_001',
    prompt:
        '物理リンクダウンを確認した。次にとるべき行動はどれですか？\n'
        '（状況: 深夜のオンコール対応・現地担当者は呼出可能）',
    logLines: [],
    choices: [
      Choice(
        id: 'a', text: 'まずルーターを再起動する',
        isCorrect: false, scoreImpact: -50,
        feedbackText: '再起動は最終手段です。原因を特定せずに再起動すると障害が長期化するリスクがあります。',
      ),
      Choice(
        id: 'b', text: '対向ルーターのポート状態を確認し、迂回経路の有無を確認する',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ まず影響範囲を確認し、迂回経路があれば暫定復旧を優先するのが正しい手順です。',
      ),
      Choice(
        id: 'c', text: 'ISPに障害報告の連絡を入れる',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'ISP連絡は必要ですが、まず自社設備側の確認が先です。ISP側障害と断定する前に内部調査が必要です。',
      ),
      Choice(
        id: 'd', text: '現地担当者を呼んでケーブルの確認を依頼する',
        isCorrect: false, scoreImpact: 50,
        feedbackText: '物理確認は重要ですが、まずリモートで確認できることをやってから現地作業を依頼する順序が効率的です。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          '物理障害対応の優先順位: '
          '①リモートで状態確認 → ②迂回経路で暫定復旧 → ③原因調査 → ④恒久対応 → ⑤ISP連絡（必要な場合）。'
          'すぐに再起動・現地作業・ISP連絡は、状況確認より先に実施すると対応が長期化するリスクがある。',
      nextActions: [
        '対向ルーターにSSH接続してポート状態を確認（show interfaces）',
        '本社経由の迂回経路が使えるか確認（show ip route）',
        '迂回可能ならデフォルトルートを変更して暫定復旧',
        'その後ケーブル確認・ISP連絡・根本原因調査',
      ],
      relatedCommands: [
        'show ip route',
        'ip route 0.0.0.0 0.0.0.0 [迂回先]',
        'show interfaces GigabitEthernet0/1',
      ],
      studyReference: 'CCNP ENARSI: 障害対応プロセスとインシデント管理',
    ),
  ),
  Question(
    id: 'q_l3_001_1',
    type: QuestionType.decisionFlow,
    scenarioId: 's_l3_001',
    prompt:
        '深夜23時、監視ツールのアラート：\n'
        '「拠点AからInternet全断」\n\n'
        '最初にすることはどれですか？',
    logLines: [
      '23:04:11 [ALERT] Host: branch-A-router',
      '  Destination: 8.8.8.8 - UNREACHABLE',
      '23:04:11 [INFO] Internal link branch-A → HQ: UP',
    ],
    choices: [
      Choice(
        id: 'a', text: '拠点Aのルーターにsshでログインしてshow ip routeを確認する',
        isCorrect: false, scoreImpact: 50,
        feedbackText: 'SSH接続は有効ですが、まず監視ツールで全体像（どのリンクがdownか）を把握してから絞り込む方が効率的です。',
      ),
      Choice(
        id: 'b', text: '監視ツールでどのリンクがdownしているか全体像を確認する',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ まず全体像を把握することで、原因の絞り込みが効率化されます。内部リンクはUPなのでISP側を疑う。',
      ),
      Choice(
        id: 'c', text: 'ISPにすぐ障害報告を入れる',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'ISP側が原因かどうか未確認の段階で連絡するのは早計です。自社設備の確認を先に行います。',
      ),
      Choice(
        id: 'd', text: '拠点Aのルーターを再起動する',
        isCorrect: false, scoreImpact: -50,
        feedbackText: '原因未確認での再起動は厳禁。設定が消える・他の障害を誘発するリスクがあります。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          'Internet全断のアラートだが、内部リンク（branch-A→HQ）はUPのまま。'
          'これはISP側のリンクまたはデフォルトルートの消失を示唆している。'
          '全体像を先に把握することで、最短で原因を絞り込める。',
      nextActions: [
        '監視ツールで拠点A-ISP間リンクのステータスを確認',
        '確認後: show ip route でデフォルトルートの有無を確認',
        'ルートが消えていれば迂回経路か手動スタティックルートで暫定復旧',
      ],
      relatedCommands: [
        'show ip route 0.0.0.0',
        'show ip bgp summary',
        'ping 8.8.8.8 source [lo0]',
      ],
      studyReference: 'CCNA: トラブルシューティングの方法論 / OSI参照モデルによる切り分け',
    ),
  ),
  Question(
    id: 'q_l2_002_1',
    type: QuestionType.logChallenge,
    scenarioId: 's_l2_002',
    prompt: '以下のSyslogと状況から、通信できない原因を選んでください。\n'
        '（状況: PC-AとPC-BはSW-1に接続。PCからはpingが通らない）',
    logLines: [
      'SW-1# show vlan brief',
      'VLAN  Name    Status    Ports',
      '1     default active    Gi0/0, Gi0/1',
      '10    Sales   active    (none)',
      '20    Dev     active    (none)',
      '',
      'SW-1# show interfaces Gi0/0 switchport',
      '  Access Mode VLAN: 10 (Sales)',
      '',
      'SW-1# show interfaces Gi0/1 switchport',
      '  Access Mode VLAN: 20 (Dev)',
    ],
    choices: [
      Choice(
        id: 'a', text: 'ケーブルが断線している',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'ポートはactive状態でVLANに割り当てられています。物理断線なら show interfaces でdown状態になります。',
      ),
      Choice(
        id: 'b', text: 'PC-AとPC-BがそれぞれVLAN10とVLAN20に別れているため通信できない',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ 異なるVLAN間はL3（ルーター or SVIによるルーティング）なしには通信できません。',
      ),
      Choice(
        id: 'c', text: 'スパニングツリーがポートをブロッキングしている',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'STPブロッキングなら show spanning-tree で確認できます。このログからは判断できません。',
      ),
      Choice(
        id: 'd', text: 'IPアドレスが重複している',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'IP重複なら %IP-4-DUPADDR のSyslogが出ます。このログには記載がありません。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          'PC-AはVLAN10（Sales）、PC-BはVLAN20（Dev）に割り当てられている。'
          'VLANは論理的なセグメント分離であり、異なるVLAN間はL3ルーティングなしには通信不可。'
          'インターVLANルーティング（Router-on-a-stick またはSVI）の設定が必要。',
      nextActions: [
        '意図したVLAN割り当てかどうか確認する',
        '同じVLANに統一する（または）インターVLANルーティングを設定する',
        'SVIを設定する場合: interface vlan 10 / ip address ...',
      ],
      relatedCommands: [
        'show vlan brief',
        'show interfaces [port] switchport',
        'interface vlan 10',
        'ip routing  (L3スイッチの場合)',
      ],
      studyReference: 'CCNA: VLAN・インターVLANルーティング（Router-on-a-stick・SVI）',
    ),
  ),
  Question(
    id: 'q_sec_001_1',
    type: QuestionType.logChallenge,
    scenarioId: 's_sec_001',
    prompt: '以下のIDSアラートから、発生しているインシデントを選んでください。',
    logLines: [
      '[IDS-ALERT] SYN-FLOOD detected: src=203.0.113.0/24',
      '  dst=10.0.0.1:80, rate=45000pps, duration=00:02:30',
      '[IDS-ALERT] UDP-FLOOD detected: src=198.51.100.0/24',
      '  dst=10.0.0.1:53, rate=12000pps',
      '[INFO] CPU utilization: 98% (threshold: 80%)',
      '[WARN] Connection table: 980000/1000000 entries',
    ],
    choices: [
      Choice(
        id: 'a', text: '内部からの情報漏洩が発生している',
        isCorrect: false, scoreImpact: 0,
        feedbackText: '外部IPからの大量SYN・UDPパケットです。内部漏洩なら内部IPからの外部への不審な通信が見られます。',
      ),
      Choice(
        id: 'b', text: 'DDoS攻撃により、サービスが応答不能になりつつある',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ 外部複数IPからのSYN-FLOOD+UDP-FLOODで、CPU98%・接続テーブルが枯渇寸前。DDoSの典型的な状態。',
      ),
      Choice(
        id: 'c', text: 'OSPFルーティングが不安定になっている',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'OSPFログは出ていません。IDSアラートはL4のフラッドを示しています。',
      ),
      Choice(
        id: 'd', text: 'ストレージの容量が不足している',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'Connection tableのエントリ数はメモリ上のセッションテーブルです。ストレージではありません。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          '外部IPからのSYN-FLOOD（ポート80・HTTP）とUDP-FLOOD（ポート53・DNS）が同時発生。'
          'CPUが98%に達し、接続テーブルも98%消費。このまま放置するとサービス完全停止になる。'
          '複数プロトコルでの同時攻撃はDDoSの典型。',
      nextActions: [
        '上流ISPにnull-routing（ブラックホール）依頼を検討',
        '攻撃元IPレンジをACLでブロック（show ip access-lists）',
        '接続テーブルのタイムアウト値を短縮して枯渇を防ぐ',
        '影響範囲（外部公開サービスの応答確認）を把握する',
      ],
      relatedCommands: [
        'ip access-list extended BLOCK-DDOS',
        ' deny ip 203.0.113.0 0.0.0.255 any',
        'show ip access-lists',
        'show processes cpu sorted',
        'clear ip conn (慎重に使用)',
      ],
      studyReference: 'CCNP Security: DDoS軽減手法・ACLによるトラフィックフィルタリング',
    ),
  ),
  Question(
    id: 'q_cap_001_1',
    type: QuestionType.logChallenge,
    scenarioId: 's_cap_001',
    prompt: '以下のインターフェース統計から帯域逼迫の原因として最も可能性が高いものは？',
    logLines: [
      'GigabitEthernet0/0  - WAN (bandwidth: 100Mbps)',
      '  Input rate:  94 Mbps (94% utilization)',
      '  Output rate: 88 Mbps (88% utilization)',
      '  Output drops: 12,458 packets',
      '',
      'Top talkers (last 5min):',
      '  192.168.10.50 → external: 52 Mbps  [dst port: 1935 RTMP]',
      '  192.168.10.51 → external: 28 Mbps  [dst port: 443  HTTPS]',
      '  192.168.10.1  → external:  8 Mbps  [dst port: 80   HTTP]',
    ],
    choices: [
      Choice(
        id: 'a', text: 'WAN回線の物理障害でスループットが低下している',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'インターフェースはUpで帯域を使い切っています。物理障害ではなく帯域の使い切りです。',
      ),
      Choice(
        id: 'b', text: '特定ホストが動画配信（RTMP）で帯域を大量消費している',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ 192.168.10.50が52Mbps（全体の55%）をRTMP（ポート1935：動画ストリーミング）で消費しています。',
      ),
      Choice(
        id: 'c', text: 'DNSの名前解決が遅いため全体が遅くなっている',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'DNSトラフィックはTop talkersに出ていません。帯域使用量の統計から原因を判断します。',
      ),
      Choice(
        id: 'd', text: 'ルーターのCPUが高負荷になっている',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'Output dropsはキューからのドロップです。CPU高負荷とは別の現象です（show processes cpuで確認）。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          'WAN回線（100Mbps）に対して94%の入力・88%の出力が発生し、パケットドロップが12,458件。'
          'Top talkersを見ると192.168.10.50がRTMP（ポート1935）で52Mbpsを独占。'
          '業務時間帯に動画ストリーミングが帯域を圧迫している可能性が高い。',
      nextActions: [
        '192.168.10.50のユーザーに確認（業務上の動画配信か否か）',
        'QoSポリシーでRTMPトラフィックの帯域を制限する',
        '業務トラフィック（HTTPS）を優先キューに配置する',
        '中長期的にWAN帯域の増速を検討する',
      ],
      relatedCommands: [
        'show interfaces GigabitEthernet0/0',
        'show policy-map interface GigabitEthernet0/0',
        'ip nbar protocol-discovery',
        'show ip nbar protocol-discovery top-n 10',
      ],
      studyReference: 'CCNP ENCOR: QoS設計・帯域制限（Policing）・NBAR',
    ),
  ),
];
