# メモ

## サーバ側

### Docker

Imageのビルド

```sh
docker build -t svnserver .
```

Containerの作成その1

```sh
docker run --rm --name my-svnserver -p 8080:80 \
  -e SVN_DEFAULT_USER="admin" \
  -e SVN_DEFAULT_USER_PASSWD="manager" \
  -e SVN_DEFAULT_REPOSITORY="default" \
  svnserver
```

Containerの作成その2

```sh
docker run -d --name my-svnserver -p 8080:80 \
  -v svn_root:/var/svn/repos -v auth:/etc/apache2/auth \
  -e SVN_DEFAULT_USER="admin" \
  -e SVN_DEFAULT_USER_PASSWD="manager" \
  -e SVN_DEFAULT_REPOSITORY="default" \
  svnserver
```

Containerの作成その3

```sh
docker-compose up -d
```

### SVNリポジトリの追加

```sh
docker exec -it my-svnserver bash

# su -s /bin/bash www-data
svnadmin create /var/svn/repos/test
svn mkdir file:///var/svn/repos/test/trunk file:///var/svn/repos/test/branches file:///var/svn/repos/test/tags -m "Create repository."
chown -R www-data:www-data /var/svn/repos/test && chmod -R 775 /var/svn/repos/test
```

### ユーザの追加

```sh
docker exec -it my-svnserver bash

htpasswd /etc/apache2/auth/svn.passwd taukajp
```

`/etc/apache2/auth/svn.authz`を修正。developersにユーザを追記

```sh
[groups]
developers = admin, taukajp
...
```

## クライアント側

以下導入

- SnailSVN Lite: SVN for Finder
- brew install svn

チェックアウト

```sh
svn checkout http://localhost:8080/repos/default/trunk default --username taukajp
```

情報確認

```sh
svn info
```

ファイルを新規作成し、コミット

```sh
echo "hello" > readme
svn add readme
svn commit -m 'add readme'
```

アップデート

```sh
svn update
```

状態確認

```sh
svn status
```

ログ確認

```sh
svn log
```

競合の解決

```sh
svn resolved ファイル名
```

ブランチ作成

```sh
svn copy http://localhost:8080/repos/default/trunk http://localhost:8080/repos/default/branches/develop -m 'developブランチを作成'
```

ブランチ切り替え

```sh
svn switch http://localhost:8080/repos/default/branches/develop
```

差分を確認

```sh
svn diff http://localhost:8080/repos/default/branches/develop@5 http://localhost:8080/repos/default/branches/develop@6
```

ブランチの起点を確認

```sh
svn diff --stop-on-copy <http://localhost:8080/repos/default/branches/develop>
```

ブランチをtrunkにマージ

```sh
svn switch http://localhost:8080/repos/default/trunk
svn merge --dry-run http://localhost:8080/repos/default/branches/develop@4 http://localhost:8080/repos/default/branches/develop@5
svn merge http://localhost:8080/repos/default/branches/develop@4 http://localhost:8080/repos/default/branches/develop@5
```

または

```sh
svn switch http://localhost:8080/repos/default/trunk
svn merge --dry-run -r 4:HEAD http://localhost:8080/repos/default/branches/develop
svn merge -r 4:HEAD http://localhost:8080/repos/default/branches/develop
```

または

```sh
svn switch http://localhost:8080/repos/default/trunk
svn merge --dry-run http://localhost:8080/repos/default/branches/develop
svn merge http://localhost:8080/repos/default/branches/develop
```

----------

インポート例

```sh
cd /path/to/test
svn import . http://localhost:8080/repos/test/trunk -m 'Initail import'
```
