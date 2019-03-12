# Ｄファイル自力作成について

## モチベーション
DPC準備病院はDファイル作成義務がなく、システムベンダ（富士通）においてもDファイル作成機能を病院に提供していないが、MDVのDPC分析ツール(EVE)ではコーディング精度チェック機能(D比較)が実装されており、DPC準備病院でもDファイルを作成することができれば当機能を利用することができる。

## 必要な外部データのダウンロードとDBへの格納手順
### 平成２８年度電子点数表（厚生労働省ホームページより取得）
#### 1) 厚生労働省ホームページ
http://www.mhlw.go.jp/stf/seisakunitsuite/bunya/0000039920.html
から「平成〇年度電子点数表_yyyymmdd.xlsx」をダウンロード(診断群分類(DPC)電子点数表(平成○年○月○日更新をクリックすると0000151698.zipといった感じのzipファイルがダウンロードされるので、それを開くと上記Excelファイルが現れる。Excelを開くとシートがいくつもあります。左から順に書き出すと以下の通り。

"ＤＰＣ電子点数表の前提条件", "ダミーコード一覧", "１）ＭＤＣ名称", "２）分類名称", "３）病態等分類", <br> 
"４）ＩＣＤ", "５）年齢、出生時体重等", "６）手術", "７）手術・処置等１", "８）手術・処置等２", <br>
"９）定義副傷病名", "10－1）重症度等（ＪＣＳ等）", "10－2）重症度等（手術等）", "10－3）重症度等（重症・軽症）", <br> 
"10－4）重症度等（発症前Rankin Scale等）", "11）診断群分類点数表", "12）変換テーブル", "13)出来高算定手術等コード", "14）CCPM対応"

#### 2) 使用するシートは16シート目「11」診断群分類点数表」
2行目までの空欄行を削除、A列（空欄列）も削除。各カラムは3, 4行目がセル結合されているので結合解除、入院日（日）、点数（点）、有効期間あたりはカラム名が2行に渡っているが1行に統合する。

#### 3) 列数は大したことない(18列)ので、カラム名を目視転記、テーブルを作成
```sql
CREATE TABLE dpcmaster_h28
(番号 INTEGER,
診断群分類番号 TEXT,
傷病名 TEXT,
手術名 TEXT,
手術・処置等１ TEXT,
手術・処置等２ TEXT,
定義副傷病 TEXT,
重症度等 TEXT,
入院期間Ⅰ（日） INTEGER,
入院期間Ⅱ（日） INTEGER,
入院期間Ⅲ（日） INTEGER,
入院期間Ⅰ（点） INTEGER,
入院期間Ⅱ（点） INTEGER,
入院期間Ⅲ（点） INTEGER,
変更区分 INTEGER,
開始日 TEXT,
終了日 TEXT,
更新日 TEXT,
id SERIAL PRIMARY KEY);
```

#### 4) 「平成〇〇年度電子点数表_yyyymmdd.xlsx」をcsv変換
d.csvを得る

#### 5) d.csvをUTF8変換
d8.csvを得る

#### 6) d8.csvをGUIでimport
　　ファイル・オプション:
   　　フォーマット：　csv,
　　列:　idのみチェックを外す
　　Misc. Options:
    　 ヘッダ：　チェック
　　　 デリミター：　空欄

### 医科診療行為マスター（診療報酬情報提供サービスホームページより取得）
（ホームページからダウンロード）
１）診療報酬情報提供サービス(
http://www.iryohoken.go.jp/shinryohoshu/downloadMenu/
)
→社会保険診療報酬支払基金HP(
http://www.ssk.or.jp/seikyushiharai/tensuhyo/kihonmasta/kihonmasta_01.html
)に変更（平成２９年度〜）
から「医科診療行為マスター」をダウンロード

２）ファイルレイアウト（医科診療行為マスター）のデータ項目名を参考に
　カラム名をcsvファイルに直接入力していく

３）カラム名の入力が完了したs.csvをUTF8変換
　　s8.csvを得る

４）医科診療行為マスターCSV加工.ipynbで
　　s8.csvをdfとし、カラム名リストを取得
　　（ipynbを経由する理由：　カラム名が重複しているため、自動アペンディックスを得るため）
　　（参考）
　　　　import pandas as pd
        df = pd.read_csv(''s8.csv'')
        df.columns.tolist()

（テーブル作成）
５）取得したカラム名リストを基にテーブルを作成する（データ型はファイルレイアウト（医科診療行為マスター
http://www.ssk.or.jp/seikyushiharai/tensuhyo/kihonmasta/index.files/kihonmasta_shiyousho.pdf
）を参照）
なお、３）の自動アペンディックスでは.1などポイントが付随するが、これではSQLが走らない。必ずポイントを削除してやること。

（インポート）
６）s8.csvをGUIでimport
　　ファイル・オプション:
   　　フォーマット：　csv,
　　列:　idのみチェックを外す
　　Misc. Options:
    　　ヘッダ：　チェック
　　　　デリミター：　空欄

```sql
CREATE TABLE tensumaster_h28
(
変更区分 INTEGER, 
マスター種別 CHAR(1), 
診療行為コード INTEGER, 
省略漢字有効桁数 INTEGER, 
省略漢字名称 VARCHAR(32),
省略カナ有効桁数 INTEGER, 
省略カナ名称 VARCHAR(20), 
データ規格コード INTEGER, 
漢字有効桁数 INTEGER, 
漢字名称 VARCHAR(6),
点数識別 INTEGER, 
新又は現点数 DOUBLE PRECISION, 
入外適用区分 INTEGER, 
後期高齢者医療適用区分 INTEGER,
点数欄集計先識別（入院外） INTEGER, 
包括対象検査 INTEGER, 
予備 INTEGER,
DPC適用区分 INTEGER,
病院・診療所区分 INTEGER,
画像等手術支援加算 INTEGER,
医療観察法対象区分 INTEGER,
看護加算 INTEGER,
麻酔識別区分 INTEGER,
入院基本料加算区分 INTEGER,
傷病名関連区分 INTEGER,
医学管理料 INTEGER,
実日数 INTEGER,
日数・回数 INTEGER,
医薬品関連区分 INTEGER,
きざみ値計算識別 INTEGER,
下限値 INTEGER,
上限値 INTEGER,
きざみ値 INTEGER,
きざみ点数 DOUBLE PRECISION,
上下限エラー処理 INTEGER,
上限回数 INTEGER,
上限回数エラー処理 INTEGER,
注加算コード INTEGER,
注加算通番 CHAR(1),
通則年齢 INTEGER,
下限年齢 CHAR(2),
上限年齢 CHAR(2),
時間加算区分 INTEGER,
適合区分 INTEGER,
対象施設基準 INTEGER,
処置乳幼児加算区分 INTEGER,
極低出生体重児加算区分 INTEGER,
入院基本料等減算対象識別 INTEGER,
ドナー分集計区分 INTEGER,
検査等実施判断区分 INTEGER,
検査等実施判断グループ区分 INTEGER,
逓減対象区分 INTEGER,
脊髄誘発電位測定等加算区分 INTEGER,
頸部郭清術併施加算区分 INTEGER,
自動縫合器加算区分 INTEGER,
外来管理加算区分 INTEGER,
点数識別1 INTEGER,
旧点数 DOUBLE PRECISION,
漢字名称変更区分 INTEGER,
カナ名称変更区分 INTEGER,
検体検査コメント INTEGER,
通則加算所定点数対象区分 INTEGER,
包括逓減区分 INTEGER,
超音波内視鏡加算区分 INTEGER,
予備1 INTEGER,
点数欄集計先識別（入院） INTEGER,
自動吻合器加算区分 INTEGER,
告示等識別区分（１） INTEGER,
告示等識別区分（２） INTEGER,
地域加算 INTEGER,
病床数区分 INTEGER,
施設基準コード① INTEGER,
施設基準コード② INTEGER,
施設基準コード③ INTEGER,
施設基準コード④ INTEGER,
施設基準コード⑤ INTEGER,
施設基準コード⑥ INTEGER,
施設基準コード⑦ INTEGER,
施設基準コード⑧ INTEGER,
施設基準コード⑨ INTEGER,
施設基準コード⑩ INTEGER,
超音波凝固切開装置等加算区分 INTEGER,
短期滞在手術 INTEGER,
歯科適用区分 INTEGER,
コード表用番号（アルファベット部） CHAR(1),
告示・通知関連番号（アルファベット部） CHAR(1),
変更年月日 INTEGER,
廃止年月日 INTEGER,
公表順序番号 INTEGER,
章 INTEGER,
部 INTEGER,
区分番号 INTEGER,
枝番 INTEGER,
項番 INTEGER,
章1 INTEGER,
部1 INTEGER,
区分番号1 INTEGER,
枝番1 INTEGER,
項番1 INTEGER,
下限年齢1 CHAR(2),
上限年齢1 CHAR(2),
注加算診療行為コード INTEGER,
下限年齢2 CHAR(2),
上限年齢2 CHAR(2),
注加算診療行為コード1 INTEGER,
下限年齢3 CHAR(2),
上限年齢3 CHAR(2),
注加算診療行為コード2 INTEGER,
下限年齢4 CHAR(2),
上限年齢4 CHAR(2),
注加算診療行為コード3 INTEGER,
異動関連 INTEGER,
基本漢字名称 VARCHAR(64),
副鼻腔手術用内視鏡加算 CHAR(1),
副鼻腔手術用軟骨部組織切除機器加算 CHAR(1),
長時間麻酔管理加算 CHAR(1),
点数表区分番号 VARCHAR(30),
非侵襲的血行動態モニタリング CHAR(1),
凍結保存同種組織加算 CHAR(1),
予備2 INTEGER,
予備3 INTEGER,
予備4 INTEGER,
id SERIAL PRIMARY KEY);
```

## Dファイル作成手順
以下Dファイル作成手順を記す。

【使用するファイル】
- 様式1ファイル
- EFファイル
- DPCオーダ一覧（富士通診療DWHより取得）
- 平成28年度電子点数表（厚生労働省ホームページより取得）
- 医科診療行為マスター（診療報酬情報提供サービスホームページ（平成29年度〜は社会保険診療報酬支払基金ホームページ）より取得）

【手順】
1. 様式1ファイルをデータ識別番号と入院年月日をキーにしてEFファイルと左外部結合する。
2. DPCオーダ一覧をデータ識別番号と入院年月日をキーにして1で得られたファイルと左外部結合する。
3. 平成28年度電子点数表を診断群分類番号をキーにして1で得られたファイルと左外部結合する。
4. 3で得られたファイルに対して、DPC期間およびDPC総点数を付加する処理を加える。
5. 4で得られたファイルに対して、算定開始日および算定終了日を付加する処理を加える。
6. EFファイルをレセプト電算コードをキーにして医科診療行為マスターと左外部結合する。
7. 6で得られたファイルのDPC適用区分およびデータ区分を参照し、出来高算定レコードとDPC包括レコードを分ける。
8. 6で得られたファイルおよび7で分けたレコードそれぞれに対して5で得られたファイルをもとに算定開始日、算定終了日および診断群分類番号を付加する処理を加える。
9. 8の処理を経た6で得られたファイルのレコードを、データ識別番号と実施年月日で見て重複する部分を削除する。
10. 9で得られたファイルに対して、データ区分、順序番号、レセプト電算コード、などの項目をDPC入院料特有のデータに書換える。
11. 8の処理を経たDPC包括レコードからDPC期間超えのものだけを抽出する。
12. 11で得られたファイルと8の処理を経た出来高算定レコードを縦方向に単純結合する。
13. 12で得られたファイルと10で得られたファイルを縦方向に単純結合する。























