#/bin/bash
#--------------------------------
#   ヨーヨー動画変換シェル
#--------------------------------
DOING_FILE_NAME='doing.txt'
DONE='./originalFile'

# 動作中を判定するファイルを作成する
# ファイルの有る間は、動作をし続けることになる。
`touch $DOING_FILE_NAME`
`mkdir $DONE`

# 動作中判定ファイルが存在する間、このループを回り続ける
while [ -e $DOING_FILE_NAME ]
do
    # 未受付動画ファイルを受け付ける
    # ファイルの先頭に queue_ をつけることで受付を占めす
    for FILE in `ls *MOV 2> /dev/null |grep -v queue|grep -v processing`
    do
        mv $FILE queue_$FILE
    done

    # 受け付けたファイルを1つずつエンコード
    # エンコード中のファイルは processing_ が先頭に付く
    for FILE in `ls queue*MOV 2> /dev/null`
    do
        #定義系
        PROCESSING_FILE_NAME=`echo $FILE | sed -e "s/queue_/processing_/"`
        PROCESSING_FILE_NAME_NO_EXT=${PROCESSING_FILE_NAME%.*}
        ORIGIN_FILE_NAME=`echo $PROCESSING_FILE_NAME | sed -e "s/processing_//"`
        ORIGIN_FILE_NAME_NO_EXT=${ORIGIN_FILE_NAME%.*}

        #変換中ファイル名に変更
        mv $FILE $PROCESSING_FILE_NAME

        #ココでエンコード
        `./encode.sh ${PROCESSING_FILE_NAME} ~/Desktop`

        #エンコード後のファイル名を変更する
        mv ~/Desktop/${PROCESSING_FILE_NAME_NO_EXT}.mp4 ~/Desktop/${ORIGIN_FILE_NAME_NO_EXT}.mp4

        #元ファイルを置き場に移動
        mv $PROCESSING_FILE_NAME $DONE/$ORIGIN_FILE_NAME
    done
    echo "waiting"
    sleep 1
done
