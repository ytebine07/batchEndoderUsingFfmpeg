#/bin/bash
set +o history
#--------------------------------
#   ヨーヨー動画変換シェル
#
#   このシェルと同一ディレクトリにあるMOVファイルを変換する。
#   起動時に同一ディレクトリにあるMOVファイル一覧を取得し、
#   1個ずつ変換していくが、途中で追加されたファイルが有ったら、
#   それを見つけ、変換する作りのはず。
#--------------------------------
#動作中を判断するファイル名
DOING_FILE_NAME='doing.txt'

#変換後にオリジナル動画ファイルをしまう場所
DONE='./originalFile'           

#変換された動画ファイル名の出力場所
#最後に / をつけること。
TO_DIR='../200_upload/'
#TO_DIR='./enqed/'


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

# プログラム終了されたときに「作業中ファイル」を削除する
trap 'stopScript' 1 2 3 15 
function stopScript(){
    rm $DOING_FILE_NAME
    exit $?
}

# 動作中判定ファイルが存在する間、このループを回り続ける
while [ -e $DOING_FILE_NAME ]
do


    # シェルスクリプトと同一フォルダのファイルを検査し、
    # 変換の受付をしたり、変換自体を実施したりしていく。
    #   for文の引数を`ls *FILENAME | grep -v hogehgoe`にした場合、
    #   ファイル名に空白が入っていた場合、どうしても空白で分けられて渡されてしまうので、
    #   このような記法になっています。

    for FILE in *.{MP4,MTS,MXF}
    do
        # .mp4 ファイルは除外
        if [[ "$FILE" == *".mp4" ]]; then
            continue
        fi

        # 未受付動画ファイルを受け付ける
        # ファイルの先頭に queue_ をつけることで受付を示す
        if [[ -e "$FILE" && ! "$FILE" =~ queue|converting ]] ;
        then
            mv "$FILE" "queue_$FILE"
        fi;

        ## 受け付けたファイルを変換していく
        if [[ -e "$FILE" && "$FILE" =~ queue ]] ;
        then

            #定義系
            CONVERTING_FILE_NAME=`echo $FILE | sed -e "s/queue_/converting_/"`
            CONVERTING_FILE_NAME_NO_EXT=${CONVERTING_FILE_NAME%.*}
            ORIGIN_FILE_NAME=`echo $CONVERTING_FILE_NAME | sed -e "s/converting_//"`
            ORIGIN_FILE_NAME_NO_EXT=${ORIGIN_FILE_NAME%.*}

            #変換中ファイル名に変更
            mv "$FILE" "$CONVERTING_FILE_NAME"

            #ココでエンコード
            #たまに失敗するのでリトライする
            NEXT_WAIT_TIME=0
            until ./encode.sh "${CONVERTING_FILE_NAME}" ${TO_DIR} || [ $NEXT_WAIT_TIME -eq 100 ]; do
               echo "RETRYING........${CONVERTING_FILE_NAME}"
               rm "${TO_DIR}${CONVERTING_FILE_NAME_NO_EXT}.mp4"
               sleep $(( NEXT_WAIT_TIME++ ))
               echo "デデンネ！"
            done

            #元ファイルを置き場に移動
            mv "$CONVERTING_FILE_NAME" "$DONE/$ORIGIN_FILE_NAME"

            #エンコード後のファイル名を変更する
            mv "${TO_DIR}${CONVERTING_FILE_NAME_NO_EXT}.mp4" "${TO_DIR}${ORIGIN_FILE_NAME_NO_EXT}.mp4"
        fi

    done
        # シェルは起動しているが、処理すべきファイルがない場合
        echo "waiting(encoding) - `date "+%Y/%m/%d-%H:%M:%S"`"
        sleep 1
        #clear
done



