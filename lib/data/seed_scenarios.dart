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

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 実際のサイバー攻撃事例に基づくシナリオ（2022〜2025年）
  // ※実在企業名は匿名化・一般化しています
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Scenario(
    id: 's_real_001',
    title: 'VPN機器の脆弱性を突いたランサムウェア侵入',
    description:
        '製造業A社のVPN機器に既知の脆弱性が残存していた。'
        '攻撃者はその脆弱性を悪用して社内ネットワークに侵入し、'
        '基幹サーバのファイルを暗号化した。Syslogから侵入の痕跡を読み取り、'
        '初動対応の優先順位を判断する。（実例: 自動車部品メーカー系 2022年）',
    category: ScenarioCategory.security,
    difficulty: DifficultyLevel.intermediate,
    questionIds: ['q_real_001_1', 'q_real_001_2', 'q_real_001_3'],
    prerequisite: 'VPN・ファイアウォール基礎・ランサムウェアの仕組み',
  ),

  Scenario(
    id: 's_real_002',
    title: 'フィッシングメール→Active Directory完全掌握',
    description:
        '従業員がフィッシングメールを開封し、認証情報が盗まれた。'
        '攻撃者は盗んだアカウントでActive Directoryに侵入し、'
        'ドメイン管理者権限まで昇格。全社ネットワークが掌握され'
        '動画配信サービスも停止した。（実例: メディア企業 2024年6月）',
    category: ScenarioCategory.security,
    difficulty: DifficultyLevel.advanced,
    questionIds: ['q_real_002_1', 'q_real_002_2', 'q_real_002_3'],
    prerequisite: 'Active Directory・Kerberos認証・特権昇格の基礎',
  ),

  Scenario(
    id: 's_real_003',
    title: 'サプライチェーン攻撃：委託先から本社へ侵入',
    description:
        '生命保険会社B社が業務委託した会計事務所がランサムウェア攻撃を受け、'
        '委託先が保有していたB社の顧客データが漏洩した。'
        '自社ではなく取引先のセキュリティ設定を確認するプロセスを学ぶ。'
        '（実例: 生命保険会社 2024年7月）',
    category: ScenarioCategory.security,
    difficulty: DifficultyLevel.advanced,
    questionIds: ['q_real_003_1', 'q_real_003_2'],
    prerequisite: 'サプライチェーンリスク・ゼロトラスト・インシデント報告義務',
  ),

  Scenario(
    id: 's_real_004',
    title: 'リスト型攻撃：不正ログインによる顧客情報漏洩',
    description:
        'EC小売C社のスマートフォンアプリに対し、他サービスから流出した'
        'ID・パスワードのリストを使った認証試行が大量に実行された。'
        '約13万件の顧客情報が流出し、クレジットカード情報も含まれていた。'
        '（実例: 大手小売アプリ 2022年9月）',
    category: ScenarioCategory.security,
    difficulty: DifficultyLevel.beginner,
    questionIds: ['q_real_004_1', 'q_real_004_2'],
    prerequisite: '認証・レート制限・多要素認証の基礎',
  ),

  Scenario(
    id: 's_real_005',
    title: 'ランサムウェアによる港湾物流システム停止',
    description:
        '国内最大規模の港湾のコンテナ管理システムがランサムウェア感染し、'
        'コンテナの搬出入が3日間完全停止した。'
        '物流の連鎖的な障害と、OTシステムへの感染拡大防止を判断する。'
        '（実例: 名古屋港統一ターミナルシステム 2023年7月）',
    category: ScenarioCategory.security,
    difficulty: DifficultyLevel.intermediate,
    questionIds: ['q_real_005_1', 'q_real_005_2'],
    prerequisite: 'OT/ICS環境・エアギャップ・ネットワーク分離の概念',
  ),

  Scenario(
    id: 's_real_006',
    title: 'DDoS攻撃による金融サービス停止（年末年始）',
    description:
        '年末年始の長期休暇中、複数の大手銀行・航空会社が同時にDDoS攻撃を受け、'
        'インターネットバンキングや予約システムが利用不能になった。'
        '繁忙期の手薄な体制でのインシデント対応を学ぶ。'
        '（実例: 国内大手金融機関群 2024〜2025年）',
    category: ScenarioCategory.security,
    difficulty: DifficultyLevel.beginner,
    questionIds: ['q_real_006_1', 'q_real_006_2'],
    prerequisite: 'DDoS・Anycast・ISP連携・BCP基礎',
  ),

  Scenario(
    id: 's_real_007',
    title: 'SQLインジェクションによるデータベース改ざん',
    description:
        '医薬品情報掲載サイトのWebアプリケーションにSQLインジェクション脆弱性があり、'
        'データベース内のテキストが不正な外部サイトへのリンクに書き換えられた。'
        'ログから攻撃を検出し、影響範囲を特定する。'
        '（実例: 医薬品協議会WebDB 2024年12月）',
    category: ScenarioCategory.security,
    difficulty: DifficultyLevel.intermediate,
    questionIds: ['q_real_007_1', 'q_real_007_2'],
    prerequisite: 'Webアプリケーション・SQL・WAF基礎',
  ),

  Scenario(
    id: 's_real_008',
    title: 'ランサムウェアによるバックアップデータの同時破壊',
    description:
        '食品製造D社でランサムウェアが感染し、業務データが暗号化された。'
        'さらに攻撃者はバックアップデータも同時に破壊したため、'
        '復旧の選択肢が身代金支払いしかない状況になった。'
        'バックアップ戦略の見直しと復旧判断を学ぶ。（実例: 製粉大手グループ 2021〜）',
    category: ScenarioCategory.security,
    difficulty: DifficultyLevel.advanced,
    questionIds: ['q_real_008_1', 'q_real_008_2'],
    prerequisite: 'バックアップ戦略・3-2-1ルール・BCP・インシデント対応',
  ),

  Scenario(
    id: 's_real_009',
    title: 'クラウドIAMキー漏洩によるS3バケット削除',
    description:
        'エネルギー系SaaS企業EのIAMユーザーのアクセスキーが不正に取得され、'
        'Amazon S3上のデータが大量に削除された。'
        'ランサムウェアを使わないデータ破壊型攻撃の検出と初動を学ぶ。'
        '（実例: エネクラウド株式会社 2025年）',
    category: ScenarioCategory.security,
    difficulty: DifficultyLevel.advanced,
    questionIds: ['q_real_009_1', 'q_real_009_2'],
    prerequisite: 'AWS IAM・S3・クラウドセキュリティ・アクセスキー管理',
  ),

  Scenario(
    id: 's_real_010',
    title: '海外子会社経由のラテラルムーブメント',
    description:
        '文具大手F社の海外グループ企業がランサムウェアに感染した。'
        '海外拠点のセキュリティ対策が本社より脆弱で、'
        'VPNで繋がった本社ネットワークへの侵害拡大が懸念される。'
        '侵害封じ込めのネットワーク分離を判断する。（実例: 国内文具大手 2023年）',
    category: ScenarioCategory.security,
    difficulty: DifficultyLevel.intermediate,
    questionIds: ['q_real_010_1', 'q_real_010_2'],
    prerequisite: 'ラテラルムーブメント・ネットワーク分離・VPN・マイクロセグメンテーション',
  ),

  Scenario(
    id: 's_real_011',
    title: 'ファイアウォール設定ミスによる不正侵入',
    description:
        '大学のファイアウォール設定変更の際にルールの抜け穴が生まれ、'
        '外部から認証なしでサーバにアクセスできる状態が2ヶ月間続いた。'
        '攻撃者はその間に侵入し、ランサムウェアを実行。'
        '設定変更時のレビュープロセスの重要性を学ぶ。（実例: 東海国立大学機構 2022年）',
    category: ScenarioCategory.layer3,
    difficulty: DifficultyLevel.beginner,
    questionIds: ['q_real_011_1', 'q_real_011_2'],
    prerequisite: 'ファイアウォールACL・設定変更管理・脆弱性スキャン',
  ),

  Scenario(
    id: 's_real_012',
    title: '連携先サーバからの大規模個人情報漏洩',
    description:
        'IT通信G社がデータ処理を委託していた海外の関連会社のサーバが侵害され、'
        'G社の利用者情報約52万件が漏洩した。'
        '「通信の秘密」違反にまで発展したこのインシデントの'
        '連絡体制と情報連携リスクを学ぶ。（実例: LINE ヤフー 2023年）',
    category: ScenarioCategory.security,
    difficulty: DifficultyLevel.intermediate,
    questionIds: ['q_real_012_1', 'q_real_012_2'],
    prerequisite: '個人情報保護法・インシデント報告義務・第三者委託管理',
  ),

  Scenario(
    id: 's_real_013',
    title: '業務委託先ランサムウェア→複数保険会社への情報漏洩連鎖',
    description:
        '印刷・帳票処理会社Hがランサムウェア攻撃を受け、'
        '委託元の複数の銀行・保険会社の顧客情報が漏洩した。'
        '1社の侵害が複数企業に波及する連鎖型インシデントの'
        '情報収集と顧客通知の優先順位を判断する。（実例: イセトー 2024年）',
    category: ScenarioCategory.security,
    difficulty: DifficultyLevel.advanced,
    questionIds: ['q_real_013_1', 'q_real_013_2'],
    prerequisite: '第三者リスク管理・インシデント対応・個人情報保護法72条',
  ),

  Scenario(
    id: 's_real_014',
    title: 'ネットワーク接続IoT機器の脆弱性悪用',
    description:
        'オフィスに設置されたネットワーク接続プリンタにデフォルトパスワードが残っており、'
        '攻撃者がそのプリンタを踏み台にして社内ネットワークを偵察・横移動した。'
        'IoT機器の脆弱性とネットワーク分離（IoT DMZ）を判断する。',
    category: ScenarioCategory.security,
    difficulty: DifficultyLevel.intermediate,
    questionIds: ['q_real_014_1', 'q_real_014_2'],
    prerequisite: 'IoTセキュリティ・デフォルト認証情報・ネットワーク分離',
  ),

  Scenario(
    id: 's_real_015',
    title: 'RDP開放による中小企業へのランサムウェア感染',
    description:
        '中小企業IがリモートワークのためにRDPポート（3389）をインターネットに直接公開していた。'
        '攻撃者はブルートフォースでパスワードを突破し、ランサムウェアを実行。'
        'バックアップも同一ネットワーク内にあり復旧困難な状況に。',
    category: ScenarioCategory.security,
    difficulty: DifficultyLevel.beginner,
    questionIds: ['q_real_015_1', 'q_real_015_2'],
    prerequisite: 'RDP・ブルートフォース・ポート管理・VPNの重要性',
  ),

  Scenario(
    id: 's_real_016',
    title: '二重恐喝：データ暗号化＋ダークウェブ公開脅迫',
    description:
        '病院Jがランサムウェアに感染し、電子カルテが使用不能になった。'
        '攻撃者グループはデータ暗号化後に患者情報をダークウェブに公開すると脅迫。'
        '身代金支払いの判断と対外報告・法的義務を学ぶ。'
        '（実例: 医療機関 2024年〜2025年）',
    category: ScenarioCategory.security,
    difficulty: DifficultyLevel.advanced,
    questionIds: ['q_real_016_1', 'q_real_016_2'],
    prerequisite: '二重恐喝・インシデント対応・医療法・個人情報保護法報告義務',
  ),

  Scenario(
    id: 's_real_017',
    title: 'Webスキミング（クレジットカード情報の盗み取り）',
    description:
        'EC企業KのWebサイトの決済ページに悪意のあるJavaScriptが埋め込まれ、'
        '利用者が入力したクレジットカード情報がリアルタイムで外部サーバに送信されていた。'
        'Webサーバのアクセスログから改ざんを検出するプロセスを学ぶ。',
    category: ScenarioCategory.security,
    difficulty: DifficultyLevel.intermediate,
    questionIds: ['q_real_017_1', 'q_real_017_2'],
    prerequisite: 'Webセキュリティ・Content Security Policy・Magecart攻撃',
  ),

  Scenario(
    id: 's_real_018',
    title: '長期潜伏型APT：侵入から数ヶ月後に発覚',
    description:
        'インフラ企業Lに攻撃者が侵入後、検知を避けながら数ヶ月間にわたり'
        '社内ネットワークを偵察・情報収集していた。'
        '異常な通信パターンをSIEMのアラートから発見し、'
        '感染端末を特定するログ解析を行う。',
    category: ScenarioCategory.security,
    difficulty: DifficultyLevel.advanced,
    questionIds: ['q_real_018_1', 'q_real_018_2'],
    prerequisite: 'APT・SIEM・ログ分析・脅威ハンティング・IOC',
  ),

  Scenario(
    id: 's_real_019',
    title: 'メール誤送信・内部不正による情報漏洩',
    description:
        '情報処理会社Mの元社員が退職前に大量の顧客データをUSBに複製して持ち出し、'
        '競合他社に売却した。さらに別部門では顧客メールを複数企業宛てに誤送信した。'
        '内部脅威の検出と権限管理の見直しを判断する。',
    category: ScenarioCategory.security,
    difficulty: DifficultyLevel.beginner,
    questionIds: ['q_real_019_1', 'q_real_019_2'],
    prerequisite: '内部脅威・DLP・アクセス権限管理・退職者アカウント管理',
  ),

  Scenario(
    id: 's_real_020',
    title: '長期休暇中の無人監視すきを狙った侵入',
    description:
        'ゴールデンウィーク中、IT担当者が不在の中でVPN機器への攻撃が開始された。'
        '平時より監視アラートが届いていたが、担当者が確認しておらず'
        '連休明けに初めて発覚した際にはすでに社内全体に感染が拡大していた。',
    category: ScenarioCategory.security,
    difficulty: DifficultyLevel.intermediate,
    questionIds: ['q_real_020_1', 'q_real_020_2'],
    prerequisite: 'SOC・SIEM・24/365監視体制・インシデントエスカレーション',
  ),

  Scenario(
    id: 's_real_021',
    title: 'DNSキャッシュポイズニングによる偽サイト誘導',
    description:
        'WebサービスNのDNSキャッシュが汚染され、正規ドメインへのアクセスが'
        '攻撃者の偽サイトに誘導された。利用者がIDとパスワードを入力してしまい、'
        '大量の認証情報が盗まれた。DNSの異常を検出するプロセスを学ぶ。',
    category: ScenarioCategory.security,
    difficulty: DifficultyLevel.advanced,
    questionIds: ['q_real_021_1', 'q_real_021_2'],
    prerequisite: 'DNS・DNSSEC・フィッシング・証明書の確認',
  ),

  Scenario(
    id: 's_real_022',
    title: '仮想化基盤（VMware ESXi）の直接攻撃',
    description:
        'データセンター運営会社OのVMware ESXiに脆弱性があり、'
        '攻撃者はハイパーバイザーに直接侵入して仮想マシンを遠隔操作した。'
        'ESXiを再起動しても感染が持続する高度な手口への対応を学ぶ。'
        '（実例: KADOKAWAプライベートクラウド 2024年）',
    category: ScenarioCategory.security,
    difficulty: DifficultyLevel.advanced,
    questionIds: ['q_real_022_1', 'q_real_022_2'],
    prerequisite: 'VMware ESXi・仮想化基盤・ハイパーバイザーセキュリティ',
  ),
];
