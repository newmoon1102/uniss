--DROP PROCEDURE SP_LOAD_URAGAKI_LABEL

CREATE PROCEDURE SP_LOAD_URAGAKI_LABEL
       @USER_ID  NVARCHAR(64)   /*ユーザーID*/
      ,@SERIAL   NVARCHAR(50)   /*シリアル*/
      ,@MODE     NVARCHAR(1)    /*処理モード*/
      ,@JOKEN_W  NVARCHAR(MAX)  /*読込時条件*/
AS
/* [モード] 0:読込 / 1:ワークテーブル削除 / 2:発行済みフラグセット */
BEGIN
    /*戻り値用テーブル変数*/
    DECLARE @TBL TABLE (
      RESULT_CD       int NOT NULL
     ,RESULT_MESSAGE  NVARCHAR(max)
    )

    /*読込処理 ワークテーブルＩＮＳＥＲＴ用*/
    DECLARE @INS_SQL AS NVARCHAR(MAX)

    /*セーブポイント生成*/
    SAVE TRANSACTION SAVE1

BEGIN TRY

    /*読込処理*/
    IF @MODE = 0
      BEGIN

        /*ワークテーブルクリア*/
        DELETE
          FROM W_URAGAKI_LABEL
         WHERE W_URAGAKI_LABEL.W_USER_ID = @USER_ID

        /*読込データをワークテーブルへ格納*/
        SET @INS_SQL = 'INSERT INTO '
                     + '       W_URAGAKI_LABEL '
                     + 'SELECT ''' + @USER_ID + ''''                                 /* ユーザーID */
                     + '      ,''' + @SERIAL  + ''''                                 /* シリアル */
                     + '      ,ROW_NUMBER() OVER (ORDER BY JURI_NO,JURI_EDA_NO,SEQ)' /* 行番号 */
                     + '      ,'   + @MODE                                           /* 処理モード */
                     + '      ,''True'''                                             /* 選択フラグ */
                     + '      ,V_URAGAKI_LABEL.*'                                    /* 裏書ラベルビュー */
                     + '      ,1 '                                                   /* DBS領域 レコード状態 */
                     + '      ,''' + @USER_ID + ''''                                 /* DBS領域 作成ユーザＩＤ */
                     + '      ,''DT'' + ' + 'CONVERT(VARCHAR(24),GETDATE(),120)'     /* DBS領域 作成日時 */
                     + '      ,''' + @USER_ID + ''''                                 /* DBS領域 更新ユーザＩＤ */
                     + '      ,''DT'' + ' + 'CONVERT(VARCHAR(24),GETDATE(),120)'     /* DBS領域 更新日時 */
                     + '  FROM V_URAGAKI_LABEL '
                     + @JOKEN_W

        /*ワークテーブルＩＮＳＥＲＴ用ＳＱＬ実行*/
        EXEC(@INS_SQL)

      END

    --ワークテーブル削除処理
    ELSE IF @MODE = 1
     BEGIN

        --ワークテーブルクリア
        DELETE
          FROM W_URAGAKI_LABEL
         WHERE W_URAGAKI_LABEL.W_USER_ID = @USER_ID

     END

    --発行済みフラグセット処理
    ELSE IF @MODE = 2
      BEGIN

        --発行済みフラグセット
        UPDATE T_BUN_JUCHU_SHOSAI
           SET
               T_BUN_JUCHU_SHOSAI.URAGAKI_PRINT_FLG = 'True'
          FROM W_URAGAKI_LABEL
         INNER JOIN
               T_BUN_JUCHU_SHOSAI
            ON T_BUN_JUCHU_SHOSAI.JURI_NO = W_URAGAKI_LABEL.JURI_NO
           AND T_BUN_JUCHU_SHOSAI.JURI_EDA_NO = W_URAGAKI_LABEL.JURI_EDA_NO
           AND T_BUN_JUCHU_SHOSAI.SEQ = W_URAGAKI_LABEL.SEQ
         WHERE W_URAGAKI_LABEL.W_USER_ID  = @USER_ID
           AND W_URAGAKI_LABEL.W_SERIAL   = @SERIAL
           AND W_URAGAKI_LABEL.SELECT_FLG = 'True'

      END

END TRY


 /*例外処理*/
BEGIN CATCH

    /* トランザクションをロールバック（キャンセル）*/
    ROLLBACK TRANSACTION SAVE1

    /*ワークテーブルクリア*/
    DELETE
      FROM W_URAGAKI_LABEL
     WHERE W_URAGAKI_LABEL.W_USER_ID = @USER_ID

END CATCH

END
