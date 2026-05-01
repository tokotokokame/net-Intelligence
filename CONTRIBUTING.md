# コントリビューションガイド

Net.Intelligence へのコントリビューションを歓迎します！

---

## 🐛 バグ報告

[Issues](https://github.com/tokotokokame/net-Intelligence/issues/new?template=bug_report.md) からご報告ください。

報告時に以下の情報をご記載ください：

```
- Android バージョン（例: Android 13）
- 端末機種（例: Pixel 7）
- アプリバージョン（Releases のタグ番号）
- 再現手順（ステップバイステップ）
- 期待する動作
- 実際の動作
- スクリーンショット（あれば）
```

---

## 💡 機能提案

[Issues](https://github.com/tokotokokame/net-Intelligence/issues/new?template=feature_request.md) から提案してください。

---

## 📝 シナリオの追加・修正

新しいサイバー攻撃事例のシナリオを追加したい場合の手順です。

### シナリオ追加の流れ

1. このリポジトリを Fork する
2. ブランチを作成する（例: `scenario/add-ssrf-attack`）
3. 以下のファイルを編集する
4. Pull Request を作成する

### 編集するファイル

#### `lib/data/seed_scenarios.dart`

```dart
Scenario(
  id: 's_real_XXX',            // 一意のID（既存IDと重複しないこと）
  title: 'シナリオのタイトル',
  description: '学習者向けの説明文。何を学ぶシナリオか、どんな状況かを2〜3文で記述。',
  category: ScenarioCategory.security,  // layer1layer2 / layer3 / security / capacity
  difficulty: DifficultyLevel.intermediate,  // beginner / intermediate / advanced
  questionIds: ['q_real_XXX_1', 'q_real_XXX_2'],
  prerequisite: '前提知識（例: VPN・ACL基礎）',
),
```

#### `lib/data/seed_questions.dart`

```dart
Question(
  id: 'q_real_XXX_1',
  type: QuestionType.logChallenge,   // logChallenge または decisionFlow
  scenarioId: 's_real_XXX',
  prompt: '問題文（Syslogを見て何が起きているか選んでください、など）',
  logLines: [
    // 実際のSyslogフォーマットに近い形式で記述
    // 実在する企業名・個人名・実際のIPアドレスは使用しないこと
    'Apr 29 14:23:15 Router-A %OSPF-5-ADJCHG: ...',
  ],
  choices: [
    Choice(id: 'a', text: '誤答の選択肢', isCorrect: false, scoreImpact: 0,
      feedbackText: 'なぜ誤りなのかの説明（1〜2文）'),
    Choice(id: 'b', text: '正解の選択肢', isCorrect: true, scoreImpact: 100,
      feedbackText: '正解の理由（1〜2文）'),
    Choice(id: 'c', text: '誤答の選択肢', isCorrect: false, scoreImpact: 0,
      feedbackText: 'なぜ誤りなのかの説明'),
    Choice(id: 'd', text: '誤答の選択肢', isCorrect: false, scoreImpact: 0,
      feedbackText: 'なぜ誤りなのかの説明'),
  ],
  explanation: Explanation(
    whatHappened: '何が起きていたかの詳細説明（3〜5文）',
    nextActions: [
      '次に確認すること・対処手順（箇条書き）',
      '手順2',
      '手順3',
    ],
    relatedCommands: [
      'show ip ospf neighbor',
      'show interfaces GigabitEthernet0/1',
    ],
    studyReference: '参考: RFC番号・試験範囲・CVE番号など',
  ),
),
```

### シナリオ作成のガイドライン

#### ✅ やること

- 実際に発生した攻撃手口・障害パターンに基づいて作成する
- Syslogは実際のフォーマットに近い形式（タイムスタンプ・デバイス名・%プロセス）で記述する
- 4択の選択肢は「それらしく見える誤答」を用意する（引っかかりやすい選択肢にする）
- 解説の `nextActions` は実際の現場での対処手順を具体的に記述する
- `relatedCommands` は実際に使えるCLIコマンドを記述する

#### ❌ やらないこと

- 実在する企業名・組織名・個人名を記述する（匿名化・一般化すること）
- 実際に悪用可能な攻撃コード・マルウェアのペイロードを含める
- 実在するIPアドレス（RFC 5737: 203.0.113.0/24 や 192.0.2.0/24 のような文書用IPを使うこと）
- 誤った技術情報（コマンドの誤り・プロトコルの誤解釈）

### 追加後の確認

```bash
flutter analyze     # エラーゼロを確認
flutter test test/data/seed_data_test.dart  # 整合性テストがパスすること
flutter build apk --release  # ビルドが成功すること
```

---

## 🔧 コード変更

### 開発環境のセットアップ

```bash
git clone https://github.com/tokotokokame/net-Intelligence.git
cd net-Intelligence
flutter pub get
flutter analyze
flutter test
```

### ブランチ命名規則

| 種類 | 命名例 |
|------|-------|
| 機能追加 | `feat/progress-export` |
| バグ修正 | `fix/choice-button-state` |
| シナリオ追加 | `scenario/add-ssrf-attack` |
| リファクタリング | `refactor/explanation-panel` |

### コミットメッセージ規則

```
feat: 機能の追加
fix: バグ修正
scenario: シナリオ・問題の追加・修正
refactor: リファクタリング（動作変更なし）
test: テストの追加・修正
docs: ドキュメントの更新
chore: ビルド・CI設定等
```

### コーディングルール

- 1ファイル **150行以内** を厳守
- 例外処理は `try-catch` で必ずラップし、`developer.log` でログ出力する
- 外部APIへの通信を追加しないこと（オフライン動作を維持する）

### Pull Request の作成

1. `main` ブランチへの PR を作成する
2. PR の説明に「何を変更したか」「なぜ変更したか」を記載する
3. `flutter analyze` エラーゼロ・全テストパスを確認してから PR を作成する

---

## 📜 行動規範

このプロジェクトは [Contributor Covenant](https://www.contributor-covenant.org/) に従います。

- 攻撃的・差別的な言動は禁止します
- 建設的なフィードバックを心がけてください
- 教育目的のプロジェクトとして、正確な技術情報の記述を優先してください

---

ありがとうございます 🐢
