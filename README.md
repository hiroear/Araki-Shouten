### アプリケーション概要
「Araki Shouten」
CD・DVDのオンラインショップです。ユーザーサイトと管理者側のダッシュボードを実装しました。
### URL
[サイトURL]:https://araki-shouten.herokuapp.com
[Araki Shouten][サイトURL]
### 機能・使用技術　一覧
* インフラ
    * Heroku
* バックエンド
    * PostgreSQL
    * Ruby 2.7.3
    * Ruby on Rails 5.2.4.2
* フロントエンド
    * HTML
    * CSS
    * Bootstrap
    * Javascript・JQuery
* ユーザーサイト
    * ログイン・ログアウト・パスワード再設定（devise）
    * ページネーション（kaminari）
    * 商品一覧・キーワード検索・カテゴリ検索・ソート機能
    * 商品のレビュー・評価投稿
    * お気に入り機能（socialiizatioin）
    * ショッピングカート（acts_as_shopping_cart）
    * クレジットカード登録・更新・決済: PAY.JP API
    * ユーザー注文履歴・情報登録・編集・退会（論理削除）
* ダッシュボード（管理画面） 
    * 日別 / 月別の合計売上・件数・平均単価算出
    * 全受注データ一覧・詳細画面
    * 商品データ一覧・検索・ソート・新規登録・編集
    * 商品画像アップロード（Active Storage / MiniMagick / AWS S3）
    * 商品データCSV一括登録
    * カテゴリ一覧・新規登録・編集
    * ユーザーデータ一覧・検索・論理削除

### 制作背景
オンラインショップのユーザー側と、商品や顧客を管理する管理者側、両方のサイト制作を通して
様々な機能を組み込むことができ、勉強になると思い制作いたしました。

### 苦労したところ
ダッシュボードTOPの、日別 / 月別の合計売上・件数・平均単価を算出する機能の実装に一番悩みました。  
日 / 月単位の売上データのハッシュをコントローラー側に渡すため、ShoppingCartモデルにクラスメソッドを定義しましたが、開発環境（sqlite）と本番環境（postgreSQL）の２つの場合に分ける為、クラスメソッドを定義する前に SQLクエリを事前に scopeで定義しておく必要がありました。  
その際 PostgreSQLのメソッドや使い方などが初めは分からず、苦戦いたしました。  
作成したいくつかの scopeをそれぞれ組み合わせてクラスメソッドを定義しています。

### 今後改善・追加したい機能
* お気に入り機能の改善。gemを使用せずリロードしないようAjaxでの実装
* 詳細検索機能の追加。ジャンルやフォーマット、キーワードなどをまとめて検索する機能
* レビュー評価ランキング、売れ筋ランキングの追加
* カテゴリのツリー構造の実装

### ゲスト用アカウント
ユーザーサイト / ダッシュボード共通  
Mail: a@example.com  
PW: aaaaaa  

### 利用方法
ユーザーサイトはログインなしでも基本的には閲覧可能です。  
お気に入り機能・カート機能・レビュー投稿・マイページはログインが必要です。  
ダッシュボードはフッターの右下にリンクがあります。ログインが必要です。  