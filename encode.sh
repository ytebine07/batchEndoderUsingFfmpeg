#/bin/bash
#ffmpegを利用して動画を変換するシェル

#---------------------------
# 設定系
#---------------------------
FFMPEG='ffmpeg'
HOWTOUSE='[How to Use]---------------------------\n'
HOWTOUSE=$HOWTOUSE'  ./encode.sh [input_file] [output_dir]\n'
HOWTOUSE=$HOWTOUSE'---------------------------------------'

#---------------------------
# 引数チェック
#   インプット動画設定
#   アウトプットディレクトリ設定
#---------------------------
# 引数の数をチェック
if [ $# -ne 2 ];then
    echo $HOWTOUSE
    exit 1
fi

# input_fileの存在チェック
if [ ! -e $1 ];then
    echo "\narg1($1) is not a FILE!!\n"
    echo $HOWTOUSE
    exit 1
fi

# output_dirの存在チェック
if [ ! -d $2 ];then
    echo "\narg2($2) is not a DIR!!\n"
    echo $HOWTOUSE
    exit 1
fi

#ココまで来れば引数を変数に代入
INPUT_FILE=$1
FILENAME_WITH_EXT=${INPUT_FILE##*/}
FILENAME=${FILENAME_WITH_EXT%.*}
OUTPUT_DIR=$2
OUTPUT_FILE=$OUTPUT_DIR/$FILENAME.mp4

#echo $FILENAME
#echo $OUTPUT_FILE
#exit 0
#---------------------------
# 動画変換オプション設定
#---------------------------

# threads設定
# CPUに合わせて設定すると早くなるかも
# H.264の場合0を指定すると、コーデック側でCPU*1.5の並列処理を行うらしい。
THREAD='-threads 2' #動かない
THREAD='-threads 0'
THREAD=''

OPTION=${THREAD}



# 動画コーデック設定
V_CODEC='-codec:v h264_qsv'

# 動画ビットレート
V_BITRATE='-b:v 8192000'

# Bフレーム
B_FRAME='-bf 2' #youtubeは2を推奨

# ピクセルフォーマット
P_FMT='-pix_fmt yuv420p'

# 音声設定
A_CODEC='-acodec aac -strict experimental -b:a 384k -r:a 48000'

# メタデータを明示的に先頭へすることで、再生を早める
MOV_FLG='-movflags faststart'

#エンコード後のサイズ設定
SIZE=''             #オリジナルサイズのまま

#フィルター設定
#FILTER='-vf "mp=eq=5:0"'          #明るさ調整
FILTER=''          #何もなければこれ

#動画にテキストを入れる
#FILTER='-vf '
#FILTER=$FILTER'"drawtext='
##FILTER=$FILTER'drawtext='
#FILTER=$FILTER'fontfile=/Library/Fonts/Arial\ Bold.ttf'
#FILTER=$FILTER':fontcolor=ffffff@0.5'  #@で透過率設定
#FILTER=$FILTER":text='2013JN 1A Semifinal Reiki Sekiya'"
#FILTER=$FILTER":fontsize=30:x=20:y=20"
##FILTER=$FILTER"," #複数指定の場合、カンマでつないで設定を書く
#FILTER=$FILTER'"'

OUT_OPTION="${FILTER} ${V_CODEC} ${V_BITRATE} ${B_FRAME} ${BITRATE} ${P_FMT} ${A_CODEC} ${SIZE} ${MOV_FLG}"
#---------------------------
# 動画変換コマンド作成
#---------------------------
#COMMAND="${FFMPEG} ${OPTION} -i ${INPUT_FILE} ${OUT_OPTION} ${OUTPUT_FILE}"
COMMAND="${FFMPEG} ${OPTION} -i ${INPUT_FILE} -i logo.png -filter_complex [1:v]lutyuv=a='val*0.2',[0:v]overlay=W-w:H-h ${OUT_OPTION} ${OUTPUT_FILE}"


echo "[exec command]-----------------------"
echo $COMMAND
echo "-------------------------------------"
eval $COMMAND


sleep 10