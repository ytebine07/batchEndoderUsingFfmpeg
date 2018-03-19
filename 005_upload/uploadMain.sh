#/bin/bash
#--------------------------------
#   動画をyoutubeへアップロードするツール#
#--------------------------------
DOING_FILE_NAME='doing.txt'     #動作中を判断するファイル名
TO_DIR='./originalFile/'               #変換された動画ファイル名の出力場所
                                #最後に / をつけること。

# 多重起動防止
if [ -e $DOING_FILE_NAME ]; then
    echo "多重起動のため停止します"
    sleep 10
    exit 1
fi


# 動作中を判定するファイルを作成する
# ファイルの有る間は、動作をし続けることになる。
`touch $DOING_FILE_NAME`


# 作業後に送付するディレクトリがなければ作成
if [ ! -d $TO_DIR ]; then
    `mkdir $TO_DIR`
fi

# 動作中判定ファイルが存在する間、このループを回り続ける
while [ -e $DOING_FILE_NAME ]
do
    # 未受付動画ファイルを受け付ける
    # ファイルの先頭に queue_ をつけることで受付を占めす
    for FILE in `ls *mp4 2> /dev/null |grep -v queue|grep -v processing`
    do
        mv $FILE queue_$FILE
    done

    # 受け付けたファイルを1つずつエンコード
    # エンコード中のファイルは processing_ が先頭に付く
    for FILE in `ls queue*mp4 2> /dev/null`
    do
        #定義系
        PROCESSING_FILE_NAME=`echo $FILE | sed -e "s/queue_/processing_/"`
        PROCESSING_FILE_NAME_NO_EXT=${PROCESSING_FILE_NAME%.*}
        ORIGIN_FILE_NAME=`echo $PROCESSING_FILE_NAME | sed -e "s/processing_//"`
        ORIGIN_FILE_NAME_NO_EXT=${ORIGIN_FILE_NAME%.*}
        TITLE_FOR_YOUTUBE=`echo ${ORIGIN_FILE_NAME_NO_EXT} | sed -e "s/_/ /g"`
        CONTEST_NAME=`echo $FILE | awk 'BEGIN{FS="_"}{print $2}'`
        DIVISION_NAME=`echo $FILE | awk 'BEGIN{FS="_"}{print $3}'`
        SECTION_NAME=`echo $FILE | awk 'BEGIN{FS="_"}{print $4}'`


        #変換中ファイル名に変更
        mv $FILE $PROCESSING_FILE_NAME


	echo ${CONTEST_NAME} ${SECTION_NAME} ${DIVISION_NAME}

        #ココでアップロード
        echo "UPLOADING... ----> ${PROCESSING_FILE_NAME}"
        youtube-upload --title="${TITLE_FOR_YOUTUBE}" \
        --description="`cat ./description.txt`" \
        --tags="yoyo, yo-yo, ヨーヨー" \
        --category=Entertainment \
        --playlist="${CONTEST_NAME} ${SECTION_NAME} ${DIVISION_NAME}" \
        --privacy private \
        ${PROCESSING_FILE_NAME}

        #元ファイルを、名前を元に戻しながらファイル置き場に移動
        mv $PROCESSING_FILE_NAME ${TO_DIR}/$ORIGIN_FILE_NAME

    done
    echo "waiting(upload)"
    sleep 1
done
