# batchEndoderUsingFfmpeg
windows10上で動画のエンコードから、youtubeアカウントへのアップロードを行うツールです。

## 事前準備
### 全体的に必要
- Windows上でBashが動く状態にする
  - [Git for Windows](https://gitforwindows.org/) で入る
- WindowsでPATHの通し方  
  - 以下の手順で何個かPATHを通す必要が出てくる
  - http://pineplanter.moo.jp/non-it-salaryman/2016/04/09/windows10-path/ あたりを参考

### エンコードするのに必要
- ffmpegをインストールしてPATHを通す  
  - [ffmpeg](https://www.ffmpeg.org/)からDLしてインストール  

### youtubeアップロードへ必要
- youtube-uploadを取得しPATHを通す    
  - [https://github.com/tokland/youtube-upload](https://github.com/tokland/youtube-upload)  
- Windows上でPythonが動く状態にする  
  - youtube-uploadライブラリを動かすのにPythonが必要なため。3.x系が無難。    
  - [https://www.python.org/](https://www.python.org/)    
- youtubeのアプリケーションアカウントやapiキーを入手    
  - [http://www.inmyzakki.com/entry/2017/05/10/222337](コマンドラインからyoutubeをアップロードする) あたりを参考  
 
