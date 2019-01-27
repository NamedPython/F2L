# About
Twitterのフォローしている人たちをフィルタリングしてリムーブした上でリストに追加できるもの。

誰が得するか、自分。あとRubyの勉強。

# Deprecated

TwitterのKEYやSECRET取得周りがガラッと変わり、API提供体系も変わったため動かない遺産に。

# How to use

`https://apps.twitter.com/` で自分用のAppを作りましょう。作ったら、

- CONSUMER_KEY
- CONSUMER_SECRET
- ACCESS_TOKEN
- ACCESS_TOKEN_SECRET

をメモる。

`.env` ファイルを作って

```
CONSUMER_KEY = [メモったやつ]
CONSUMER_SECRET = [メ]
...
```
といった具合に書く。これで環境変数(`ENV['CONSUMER_KEY']`とか)が使える。

次にパッケージのインストール。Rubyのバージョンをどうしているかは各環境によりけりですが、自分は`rbenv`の場合で説明します。

`$ bundle install --path vendor/bundle`

できなかったら頑張ってください。

そのまま`bundle exec ruby source.rb`しても、動くは動きますがフィルタが書かれたファイルがなくて怒られるようにしてあります。

`filter_sample.txt`を参考に、`filter_include.txt`にフィルタリングしたいキーワードを列挙します。英字に関しては大文字小文字どちらでもいいようなマッチングをしているので一個だけでOK。改行で列挙してください。

できたら実行に移ります。Twitterのリスト(`f2l`)は勝手に作られるはずです。あったら追加されます。

`$ bundle exec ruby source.rb`

# Others
- 特に綺麗には書いていませんが`Rubocop`様の警告に耳を傾けてコーディングしています。
- フィルタの数は速度にそこまで影響しません。ズバズバ列挙した方が抽出率上がります。
- フィルタの適用範囲はTwitterのBioとUrl欄です。Locationは見てません。
- Twitter APIの制限に引っかかると勝手に待ちます。だいたいのことはコンソールに出力されるのでそちらを参照されたし。
- 問題や指摘等ありましたら`namedpython{at}gmail.com`やIssueまで

# License
Apache-2.0
