## 全員共通の~/.ssh/configを作る
- SSH接続の設定を統一。`Host isucon-server`といった形でSSH接続情報を~/.ssh/configに記述。

## 全員分の~/.ssh/authroized_keysを作る
（運営がGitHubに登録しているSSH鍵で追加している場合はこの作業は不要）
- 3人分の公開鍵を`~/.ssh/authorized_keys`に追加。

## GitHubに手軽にpushできるように、deploy keyをサーバー上のisuconユーザーに入れておく
1. サーバーにSSHでログインし、isuconユーザーになる。
2. ssh-keygenコマンドを実行して新しいSSHキーを生成。(`~/.ssh/id_rsa.pub`で作成)
```bash
ssh-keygen -t rsa -b 4096
```
3. 生成された公開キー（id_rsa.pub）の内容をコピー。
4. GitHubのリポジトリに移動し、Settings > Deploy keys から新しいkeyとして追加。(Allow write accessにチェックを入れる)

この設定により、サーバー上のisuconユーザーはこのSSHキーを使ってGitHubのリポジトリにpushやpullができるようになります。

## コードをリポジトリにpushする
- `git init`でリポジトリを初期化。
- `git add .`でコードをステージング。
- `git config --global user.name ${user-name}`でユーザー名を設定。
- `git config --global user.email ${user-email}`でメールアドレスを設定。
- `git commit -m "first commit"`でコミット。
- `git remote add origin git@github.com:${user-name}/${repository-name}.git`でリモートリポジトリを追加。
- `git push -u origin master`でコードをGitHubにpush。

## OS、ミドルウェアの設定ファイルがある`/etc`もリポジトリに含める。

- `cd ${レポジトリのルートディレクトリ}`
- `sudo cp -r /etc/nginx ./etc/nginx`でnginxの設定ファイルをコピー。
- `sudo cp -r /etc/mysql ./etc/mysql`でMySQLの設定ファイルをコピー。
- `sudo chown -R isucon:isucon ./etc`でコピーした設定ファイルの所有者をisuconユーザーに変更。
- `git add .`でステージング。
- `git commit -m "add etc"`でコミット。
- `git push`でリモートリポジトリにpush。

## ローカルで開発環境を作れないか考えて、作れそうなら作る
- Dockerを使ってローカルにMySQLやアプリケーションサーバーを立てる。

## MySQL・画像などのバックアップを開発環境用に作成
- `mysqldump`でデータベースをバックアップ。

## issueのテンプレートを作成
- 事前に作成してテンプレートを設定する

## 実際に使ってみてどういうアプリケーションなのか把握しつつ、スクショを取って共有する
- `README.md`にアプリケーションの概要を書く
- アプリケーションを操作し、そのスクリーンショットをSlackなどで共有。

## パスの一覧を共有

## スキーマ一覧を共有
- `SHOW TABLES;`でテーブル一覧を確認。
- `DESCRIBE table_name;`でテーブル構造を確認。
- `SHOW INDEX FROM table_name;`でテーブルのインデックスを確認。

## ハードウェアの構成を調べる、動作しているプロセスを確認
- `lscpu`でCPUの情報を確認。
  - CPUの基本情報（コア数、スレッド数、アーキテクチャなど）を表示。
  - 例: `lscpu | grep -E 'Model name|Socket|Thread|Core'` で特定の情報だけをフィルタリング。
- `free -m`
  - メモリ使用状況をMB単位で表示。
    - 例: `free -m | grep Mem` でメモリの総量、使用量、空き量を確認。
- `ps aux`
  - システム上のすべてのプロセスを詳細に表示。
  - 例: `ps aux | grep mysql` でMySQLに関連するプロセスを探す。
- `top`
  - リアルタイムでシステムの状態とプロセスを表示。
  - CPUやメモリの使用率が高いプロセスを特定できる。

## 何もせずにベンチマークを流す
- ベンチをかけながら、サーバーの負荷状況を確認する。
- `top`コマンドでCPU使用率を確認。
- `free`コマンドでメモリ使用量を確認。
- `df`コマンドでディスク使用量を確認。

## スロークエリログを有効にする
- MySQLのスロークエリログを有効にする。

```bash
sudo vim /etc/mysql/mysql.conf.d/mysqld.cnf
```

```bash
[mysqld]
slow_query_log = 1
slow_query_log_file = /var/log/mysql/mysql-slow.log
long_query_time = 0 # 0にすると全てのクエリをログに出力
```

```bash
sudo systemctl restart mysql
# アプリも再起動しないと、DB接続が切れる
```

```bash
# -s c はクエリの実行回数でソート
# -s at はクエリの平均実行時間でソート
# -s t はクエリの合計実行時間でソート
# -t 10 は上位10件を表示
mysqldumpslow -s t -t 10 /var/log/mysql/mysql-slow.log 
mysqldumpslow -s c -t 10 /var/log/mysql/mysql-slow.log 
mysqldumpslow -s at -t 10 /var/log/mysql/mysql-slow.log
```

## 必要そうなINDEXを貼る

[MySQLでインデックスを貼る時に読みたいページまとめ(初心者向け） #MySQL - Qiita](https://qiita.com/C058/items/1c9c57f634ebf54d99bb)

```bash
# INDEXを作成
ALTER TABLE `table_name` ADD INDEX `index_name` (`column_name`);

# INDEXを削除
ALTER TABLE `table_name` DROP INDEX `index_name`;

# INDEXを確認
SHOW INDEX FROM `table_name`;

# EXPLAINを確認
EXPLAIN SELECT * FROM `table_name`;
```

## ルールを読み込んでおいて、注意しないといけないところを洗い出す
- ISUCONのルールや制限事項を確認し、特に注意が必要な点をSlackで共有。
  - Slackだと流れるので、後から見返すのが大変なので、GitHubのissueにまとめておくと良い。
  - それか専用のチャンネルを作っておくと良い。

## issueを作る
- コードを読んでissueで問題点を挙げる。
- ラベルの候補
  - `INDEX`: INDEXを貼る必要がある
  - `N+1`: N+1問題がある
  - `???`: 何が起きているのかわからない、その他
