# batchEndoderUsingFfmpeg
ffmpegを利用したバッチエンコーダー

## 利用方法(windows10想定)

## 1.ffmpegにpathを通す
pathの通し方は以下などを参考  
http://pineplanter.moo.jp/non-it-salaryman/2016/04/09/windows10-path/

## 2.main.shをダブルクリック
コマンドプロンプトが立ち上がり、エンコードが開始されるはず

## ファイル構成
### main.sh
バッチエンコードを実現するためのファイル  
同一フォルダ内の```MOV```で終わるファイルを、順番にendoce.shへ渡していく。
### encode.sh
ffmpegを利用して、エンコードを実施するファイル。引数を渡せば単体利用も可能。
