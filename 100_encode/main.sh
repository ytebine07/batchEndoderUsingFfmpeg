#/bin/bash
#--------------------------------
#   ヨーヨー動画変換シェル
#
#   このシェルと同一ディレクトリにあるMOVファイルを変換する。
#   起動時に同一ディレクトリにあるMOVファイル一覧を取得し、
#   1個ずつ変換していくが、途中で追加されたファイルが有ったら、
#   それを見つけ、変換する作りのはず。
#--------------------------------
DOING_FILE_NAME='doing.txt'     #動作中を判断するファイル名
DONE='./originalFile'           #変換後にオリジナル動画ファイルをしまう場所
TO_DIR='./100_upload/'          #変換された動画ファイル名の出力場所
                                #最後に / をつけること。


# 動作中を判定するファイルを作成する
# ファイルの有る間は、動作をし続けることになる。
`touch $DOING_FILE_NAME`

# オリジナルファイルの保存先作成
if [ ! -d $DONE ]; then
    `mkdir $DONE`
fi

# 変換後のファイルの保存先作成
if [ ! -d $TO_DIR ]; then
    `mkdir $TO_DIR`
fi


# 動作中判定ファイルが存在する間、このループを回り続ける
while [ -e $DOING_FILE_NAME ]
do
    # 未受付動画ファイルを受け付ける
    # ファイルの先頭に queue_ をつけることで受付を占めす
    for FILE in `ls *MTS 2> /dev/null |grep -v queue|grep -v converting`
    do
        mv $FILE queue_$FILE
    done

    # 受け付けたファイルを1つずつエンコード
    # エンコード中のファイルは converting_ が先頭に付く
    for FILE in `ls queue*MTS 2> /dev/null`
    do
        #定義系
        CONVERTING_FILE_NAME=`echo $FILE | sed -e "s/queue_/converting_/"`
        CONVERTING_FILE_NAME_NO_EXT=${CONVERTING_FILE_NAME%.*}
        ORIGIN_FILE_NAME=`echo $CONVERTING_FILE_NAME | sed -e "s/converting_//"`
        ORIGIN_FILE_NAME_NO_EXT=${ORIGIN_FILE_NAME%.*}

        #変換中ファイル名に変更
        mv $FILE $CONVERTING_FILE_NAME

        #ココでエンコード
        #たまに失敗するのでリトライする
        NEXT_WAIT_TIME=0
        until ./encode.sh ${CONVERTING_FILE_NAME} ${TO_DIR} || [ $NEXT_WAIT_TIME -eq 4 ]; do
           echo "RETRYING........${CONVERTING_FILE_NAME}"
           rm ${TO_DIR}${CONVERTING_FILE_NAME_NO_EXT}.mp4
           sleep $(( NEXT_WAIT_TIME++ ))
        done

        #元ファイルを置き場に移動
        mv $CONVERTING_FILE_NAME $DONE/$ORIGIN_FILE_NAME

        #エンコード後のファイル名を変更する
        mv ${TO_DIR}${CONVERTING_FILE_NAME_NO_EXT}.mp4 ${TO_DIR}${ORIGIN_FILE_NAME_NO_EXT}.mp4

    done
    echo "waiting(encoding)"
    sleep 1
done
