# OpenTools

OpenTools は BSD Unix 使いのための小道具を集めたものです．リモートホストを指
定してターミナル上でリモートログインしたり，自宅のホームマシンにリモートログイ
ンしてターミナル上で emacs のメールクライアントを起動するなど，大したツールではあ
りませんが，Unix ユーザにとって一手間を省けるスクリプト達です．

---

## コマンド達

主なものは以下の 8 つです．

* **bwsr**	 ブラウザを起動する．
* **mailprc**	 コマンドラインベースの MDA．POP/APOP/Maildir 対応
* **sbackup**	 日，週，月，年単位にリモートバックアップする
* **slgn**	 xterm を立ち上げリモートログインする．色を指定可能
* **w3**	 xterm 上で w3m を立ち上げる．色を指定可能
* **wl**	 ローカルまたはリモートで emacs＋Wanderlust を起動する．装飾を指定可能
* **xemcs**	 XEmacs を起動する．位置と装飾を指定可能
* **xtrm**	 XTerm を起動する．位置と色を指定可能

この他，以下のような補助ツールもあります．

* **autocol**	HTML の table コラムを矯正
* **create-portstree**	固有の ports ツリーを作る
* **latex2latex**	 LaTeX のソースをいじる
* **newest**		 指定したファイルのうち最新のものをピックアップする
* **sct**		 リモートディレクトリツリーコピー．パーミッション・シンボリックリンク保存
* **sdoc2page**		 SmartDoc の HTML → GitHub ページ 変換
* **sdoc2sdoc**		 SmartDoc の HTML を編集

詳しくはそれぞれのヘルプ('`--help`' オプションで表示)を参照してください．今の
ところマニュアルはありません `;-)`

---

## インストール

#### 1. このレポジットリをチェックアウト

`github.com/styckm/opentools` をチェックアウトします．

	% git clone https://github.com/styckm/opentools.git

#### 2. インストール

インストールします．

	# cd opentools
	# make install

デフォルトでは，コマンドは `/usr/local/bin` へ，その他
(ライブラリやインクルードファイル)は `/usr/local/opentools` へインストールさ
れます．インストール先を変更したい場合には DEST にインストール先のディレクト
リを指定して，

	# make DEST=/install_destdir install

とします．設定ファイルは `/usr/local/etc/opentools.conf` です．基本的に
全てのコマンドの初期設定をこのファイルに書くことができます．どのような設定が
できるかは `/usr/local/opentools/include/*.inc` を見てください．各コマンドに
対応するインクルードファイルは以下のとおりです．

* `common.inc`	**共通**	
* `mail.inc`	**mailprc**		
* `misc.inc`	**bwsr**, **sbackup**, **slgn**, **w3**, **wl**, **xemcs**, **xtrm**
* `ports.inc`	**create-portstree**
* `sys.inc`	**newest**, **sct**


### FreeBSD

FreeBSD では package があります．以下のサイトからダウンロードして，

	# pkg add opentools-1.0.xz

してください．なお，ports からインストールしたい人は，スケルトンが
data/ports/opentools-1.0.tar.gz にありますので，

	# cd $PORTSDIR
	# tar xf opentools-1.0.tar.gz
	# cd sysutils/opentools
	# make install

してください．

### NetBSD

pkgsrc はありません．鋭意作るように努力してます `;-p)`

### OpenBSD

こちらも対応する ports はありません．どなたかマージしてくれる人いませんか？

### DragonFly BSD, TureOS, ...

全く調べてませんが，簡単にできるようなら作ります．

## 各コマンドの想定する環境

それぞれ．以下のような環境で実行できるように想定しています．

* **bwsr**
   FireFox と Chrome を起動できること
* **mailprc**
   imget を実行できること．FreeBSD では ports(`mail/im`) をインストールしておくこと．
* **sbackup**
   特にデフォルトの環境で OK だが，リモートサイトにはパスフレーズ無しに
   slogin できるようにしておくこと．
* **slgn**
   特にデフォルトの環境で OK
* **w3**
   w3m がインストールしてあること．FreeBSD では ports(`japanese/w3m`) をインストールしておくこと．
* **wl**
   Emacs/XEmacs 上で Wanderust が使えること．
* **xemcs**
   XEmacs インストールしてあること．
* **xtrm**
   特にデフォルトの環境で OK

---

opentools@TrueFC.org
