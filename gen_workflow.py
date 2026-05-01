import os

os.makedirs('.github/workflows', exist_ok=True)

lines = [
    'name: Build and Release APK\n',
    '\n',
    'on:\n',
    '  push:\n',
    '    branches: [ main ]\n',
    '\n',
    'jobs:\n',
    '  build:\n',
    '    runs-on: ubuntu-latest\n',
    '    steps:\n',
    '      - uses: actions/checkout@v4\n',
    '\n',
    '      - uses: subosito/flutter-action@v2\n',
    '        with:\n',
    '          flutter-version: "3.41.6"\n',
    '          channel: "stable"\n',
    '          cache: true\n',
    '\n',
    '      - name: Install dependencies\n',
    '        run: flutter pub get\n',
    '\n',
    '      - name: Analyze\n',
    '        run: flutter analyze\n',
    '\n',
    '      - name: Test\n',
    '        run: flutter test\n',
    '\n',
    '      - name: Build APK\n',
    '        run: flutter build apk --release\n',
    '\n',
    '      - name: Create Release\n',
    '        uses: softprops/action-gh-release@v2\n',
    '        with:\n',
    '          tag_name: build-${{ github.run_number }}\n',
    '          name: "Net.Intelligence v1.0.0-build${{ github.run_number }}"\n',
    '          body: |\n',
    '            ## Net.Intelligence\n',
    '            ### インストール方法\n',
    '            1. app-release.apk をダウンロード\n',
    '            2. 設定 -> セキュリティ -> 提供元不明のアプリ -> 許可\n',
    '            3. APKをタップしてインストール\n',
    '          files: build/app/outputs/flutter-apk/app-release.apk\n',
    '          draft: false\n',
    '          prerelease: false\n',
    '        env:\n',
    '          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}\n',
]

with open('.github/workflows/build.yml', 'w') as f:
    f.writelines(lines)

# 検証
with open('.github/workflows/build.yml', 'r') as f:
    content = f.read()

checks = [
    '  push:' in content,
    '    branches:' in content,
    '  build:' in content,
    '    runs-on:' in content,
    '      - uses: actions/checkout@v4' in content,
    '        with:' in content,
    '          flutter-version:' in content,
    '          GITHUB_TOKEN:' in content,
]

print('=== 検証結果 ===')
labels = [
    '  push: (2スペース)',
    '    branches: (4スペース)',
    '  build: (2スペース)',
    '    runs-on: (4スペース)',
    '      - uses: checkout (6スペース)',
    '        with: (8スペース)',
    '          flutter-version: (10スペース)',
    '          GITHUB_TOKEN: (10スペース)',
]
all_ok = True
for label, ok in zip(labels, checks):
    status = 'OK' if ok else 'NG'
    if not ok:
        all_ok = False
    print(f'  [{status}] {label}')

if all_ok:
    print('\n全チェックOK: build.yml のインデントは正しいです')
else:
    print('\nNGあり: インデントが正しくありません')
