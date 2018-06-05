
--DROP PROCEDURE SP_LOAD_BUN_NOTE

CREATE PROCEDURE SP_LOAD_BUN_NOTE
       @USER_ID  NVARCHAR(64)   /*ユーザーID*/
      ,@SERIAL   NVARCHAR(50)   /*シリアル*/
      ,@MODE     NVARCHAR(1)    /*処理モード*/
      ,@JOKEN_W  NVARCHAR(MAX)  /*読込時条件*/
AS
/*[モード] 0:読込*/
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
          FROM W_BUN_NOTE
         WHERE W_BUN_NOTE.W_USER_ID = @USER_ID

        /*読込データをワークテーブルへ格納*/
        SET @INS_SQL = 'INSERT INTO '
                     + '       W_BUN_NOTE '
                     + 'SELECT ''' + @USER_ID + ''''                             /* ユーザーID*/
                     + '      ,''' + @SERIAL  + ''''                             /* シリアル*/
                     + '      ,ROW_NUMBER() OVER (ORDER BY JURI_NO,JURI_EDA_NO)' /* 行番号*/
                     + '      ,'   + @MODE                                       /* 処理モード*/
                     + '      ,''True'''                                         /* 選択フラグ*/
                     + '      ,V_BUN_NOTE.*'                                     /* 分析ノートビュー*/
                     + '      ,1 '                                               /* DBS領域 レコード状態*/
                     + '      ,''' + @USER_ID + ''''                             /* DBS領域 作成ユーザＩＤ*/
                     + '      ,''DT'' + ' + 'CONVERT(VARCHAR(24),GETDATE(),120)' /* DBS領域 作成日時*/
                     + '      ,''' + @USER_ID + ''''                             /* DBS領域 更新ユーザＩＤ*/
                     + '      ,''DT'' + ' + 'CONVERT(VARCHAR(24),GETDATE(),120)' /* DBS領域 更新日時*/
                     + '  FROM V_BUN_NOTE '
                     + @JOKEN_W

        /*ワークテーブルＩＮＳＥＲＴ用ＳＱＬ実行*/
        EXEC(@INS_SQL)

      END

    --ワークテーブル削除処理
    ELSE IF @MODE = 1
     BEGIN

        --ワークテーブルクリア
        DELETE
          FROM W_BUN_NOTE
         WHERE W_BUN_NOTE.W_USER_ID = @USER_ID

     END

END TRY


 /*例外処理*/
BEGIN CATCH

    /* トランザクションをロールバック（キャンセル）*/
    ROLLBACK TRANSACTION SAVE1

    /*ワークテーブルクリア*/
    DELETE
      FROM W_BUN_NOTE
     WHERE W_BUN_NOTE.W_USER_ID = @USER_ID

END CATCH

END
