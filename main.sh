#/bin/bash
#--------------------------------
#   ヨーヨー動画変換シェル
#--------------------------------
DOING_FILE_NAME='doing.txt'
DONE='./done'

# 動作中を判定するファイルを作成する
# ファイルの有る間は、動作をし続けることになる。
`touch $DOING_FILE_NAME`
`mkdir $DONE`
while [ -e $DOING_FILE_NAME ]
do
    # 未受付動画ファイルを受け付ける
    for FILE in `ls *MOV 2> /dev/null |grep -v queue|grep -v processing`
    do
        mv $FILE queue_$FILE
    done

    # 受け付けたファイルを1つずつエンコード
    for FILE in `ls queue*MOV 2> /dev/null`
    #for FILE in `ls *MOV`
    do
        TO_FILE=`echo $FILE | sed -e "s/queue_/processing_/"`
        ORIGIN_FILE=`echo $TO_FILE | sed -e "s/processing_//"`

        #変換中ファイル名に変更
        mv $FILE $TO_FILE
        #ココでエンコード

        #変換後に元ファイルを移動
        echo $ORIGIN_FILE
        mv $TO_FILE $DONE/$ORIGIN_FILE
    done
    echo "waiting"
    sleep 1
done
