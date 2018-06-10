#/bin/bash
#--------------------------------
#   動画をyoutubeへアップロードするツール#
#--------------------------------

#動作中を判断するファイル名
DOING_FILE_NAME='doing.txt'

#アップロード後のファイルの移動場所
#最後に / をつけること。
TO_DIR='./originalFile/'

# 設定ファイルを設置するディレクトリ
CONF_DEV_DIR='./conf/dev'
CONF_PROD_DIR='./conf/prod'

# 多重起動防止
if [ -e $DOING_FILE_NAME ]; then
    echo "多重起動のため停止します"
    echo "多重起動でないのに、このメッセージが表示された場合は $DOING_FILE_NAME を削除して再度実行してください"
    sleep 10
    exit 1
fi

# 開発と本番で設定変えたい箇所を設定
if [[ ! -d $CONF_DEV_DIR && ! -d $CONF_PROD_DIR ]]; then
    echo "設定ファイルを設置するディレクトリがありません"
    echo "ディレクトリと設定ファイルを用意してください $CONF_PROD_DIR, $CONF_PROD_DIR"
    sleep 10
    exit 1
fi

# 本番公開用設定
if [ -d $CONF_PROD_DIR ]; then

    # 公開
    PRIVACY='public'

    CLIENT_SECRETS='./conf/prod/yoyovideoarchive.json'
    CREDENTIALS_FILE='./conf/prod/.youtube-upload-credentials.json'

fi

# 開発環境があれば、それで上書き
if [ -d $CONF_DEV_DIR ]; then

    # 限定公開
    PRIVACY='unlisted'

    CLIENT_SECRETS='./conf/dev/client_secrets.json'
    CREDENTIALS_FILE='./conf/dev/.youtube-upload-credentials.json'

fi

# 設定ファイルが読み込めていなかったら異常終了
if [[ ! -e $CLIENT_SECRETS || ! -e $CREDENTIALS_FILE ]]; then

    echo "youtubeへアップロードするのに必要な設定ファイルが読み込めていません"
    echo "client_secrets.json と credentials.jsonが配置されていることを確認してください"
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
    for FILE in *mp4
    do
        # 未受付動画ファイルを受け付ける
        # ファイルの先頭に queue_ をつけることで受付を示す
        if [[ -e "$FILE" && ! "$FILE" =~ converting|queue|uploading ]] ;
        then
            mv "$FILE" "queue_$FILE"
        fi;

        ## 受け付けたファイルをアップロードしていく
        if [[ -e "$FILE" && "$FILE" =~ queue ]] ;
        then
            #定義系
            UPLOADING_FILE_NAME=`echo $FILE | sed -e "s/queue_/uploading_/"`
            UPLOADING_FILE_NAME_NO_EXT=${UPLOADING_FILE_NAME%.*}
            ORIGIN_FILE_NAME=`echo $UPLOADING_FILE_NAME | sed -e "s/uploading_//"`
            ORIGIN_FILE_NAME_NO_EXT=${ORIGIN_FILE_NAME%.*}
            TITLE_FOR_YOUTUBE=`echo ${ORIGIN_FILE_NAME_NO_EXT} | sed -e "s/_/ /g"`
            CONTEST_NAME=`echo $FILE | awk 'BEGIN{FS="_"}{print $2}'`
            DIVISION_NAME=`echo $FILE | awk 'BEGIN{FS="_"}{print $3}'`
            SECTION_NAME=`echo $FILE | awk 'BEGIN{FS="_"}{print $4}'`

            #変換中ファイル名に変更
            mv "$FILE" "$UPLOADING_FILE_NAME"

            #ココでアップロード
            echo "UPLOADING... ----> ${UPLOADING_FILE_NAME}"

            COMMAND="youtube-upload \
            --title=\"${TITLE_FOR_YOUTUBE}\" \
            --description=\"`cat ./conf/description.txt`\"
            --tags=\"yoyo, yo-yo, ヨーヨー\"
            --category=Entertainment \
            --playlist=\"${CONTEST_NAME} ${SECTION_NAME} ${DIVISION_NAME}\" \
            --privacy \"${PRIVACY}\"  \
            --client-secrets=\"${CLIENT_SECRETS}\" \
            --credentials-file=\"${CREDENTIALS_FILE}\" \
            \"${UPLOADING_FILE_NAME}\"
            "

            echo "[exec command]-----------------------"
            echo $COMMAND
            echo "-------------------------------------"
           
            # ココでアップロード
            # 失敗したときのためにリトライ処理
            NEXT_WAIT_TIME=0
            until eval $COMMAND || [ $NEXT_WAIT_TIME -eq 100 ]; do
               echo "RETRYING........${$COMMAND}"
               sleep $(( NEXT_WAIT_TIME++ ))
            done

            # 元ファイルを、名前を元に戻しながらファイル置き場に移動
            mv "$UPLOADING_FILE_NAME" "${TO_DIR}/$ORIGIN_FILE_NAME"
        fi

    done
        # シェルは起動しているが、処理すべきファイルがない場合
        echo "waiting(uploading) - `date "+%Y/%m/%d-%H:%M:%S"`"
        sleep 1
done
